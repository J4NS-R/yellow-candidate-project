resource "aws_ecs_cluster" "cluster" {
  name = local.proj_name
}

data "template_file" "node_app_defn" {
  template = file("./templates/node-app-defn.json.tpl")

  vars = {
    pg_host              = aws_db_instance.pg.address,
    pg_db                = aws_db_instance.pg.db_name,
    pg_user              = aws_db_instance.pg.username,
    min_age              = 18
    max_age              = 60
    upstream_payment_url = "https://example.org/"
    origin               = "http://${aws_lb.node_ingress.dns_name}"
    pg_pass_ref          = "${data.aws_secretsmanager_secret.terrasecrets.arn}/db-password"
    api_key_ref          = "${data.aws_secretsmanager_secret.terrasecrets.arn}/api-key"
  }
}
resource "aws_ecs_task_definition" "node" {
  container_definitions    = data.template_file.node_app_defn.rendered
  requires_compatibilities = ["EC2"]
  family                   = "service"
  execution_role_arn       = aws_iam_role.node_app.arn
  tags = {
    Name = "${local.proj_name}-node-app"
  }
}

resource "aws_ecs_service" "node" {
  name            = local.proj_name
  task_definition = aws_ecs_task_definition.node.arn
  desired_count   = 1
  cluster         = aws_ecs_cluster.cluster.arn
  load_balancer {
    target_group_arn = aws_lb_target_group.node_app.arn
    container_name   = "node"
    container_port   = 3000
  }
}

# Load balancer
resource "aws_lb" "node_ingress" {
  name               = "${local.proj_name}-ingress"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.euw1b.id, aws_subnet.euw1a.id]
  depends_on         = [aws_internet_gateway.igw]
}
resource "aws_lb_target_group" "node_app" {
  name     = "${local.proj_name}-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}
resource "aws_lb_listener" "node_app" {
  load_balancer_arn = aws_lb.node_ingress.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.node_app.arn
  }
}

# ECS task role and policies
resource "aws_iam_role" "node_app" {
  name               = "${local.proj_name}-node-app"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ecs-tasks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
  }
  EOF
}

resource "aws_iam_policy_attachment" "node_app_ecs_exec" {
  name       = "${local.proj_name}-node-app-ecs-exec"
  roles      = [aws_iam_role.node_app.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy" "node_app_secrets" {
  role   = aws_iam_role.node_app.id
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Effect": "Allow",
        "Resource": [
          "${data.aws_secretsmanager_secret.terrasecrets.arn}"
        ]
      }
    ]
  }
  EOF
}
