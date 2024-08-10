resource "aws_ecs_cluster" "cluster" {
  name = local.cluster_name
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
    origin               = "http://${aws_alb.node_ingress.dns_name}"
    pg_pass_ref          = "${data.aws_secretsmanager_secret.terrasecrets.arn}:db-password::"
    api_key_ref          = "${data.aws_secretsmanager_secret.terrasecrets.arn}:api-key::"
    log_group            = aws_cloudwatch_log_group.ecs_log_group.name
    aws_region           = local.aws_region
  }
}
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ecs/register-task-definition.html
resource "aws_ecs_task_definition" "node" {
  container_definitions    = data.template_file.node_app_defn.rendered
  requires_compatibilities = ["FARGATE"]
  family                   = "service"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.node_app.arn
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size
  cpu    = "512"
  memory = "1024"
  tags = {
    Name = "${local.proj_name}-node-app"
  }
}

resource "aws_ecs_service" "node_app" {
  name            = local.proj_name
  task_definition = aws_ecs_task_definition.node.arn
  desired_count   = 1
  cluster         = aws_ecs_cluster.cluster.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = aws_subnet.private.*.id
    security_groups  = [aws_security_group.vpc.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.node_app.arn
    container_name   = "node"
    container_port   = 3000
  }
  #   capacity_provider_strategy {
  #     capacity_provider = aws_ecs_capacity_provider.cluster.name
  #     weight            = 100
  #   }
  depends_on = [aws_lb_listener.node_app, aws_iam_policy_attachment.node_app_ecs_exec]
}

# Load balancer
resource "aws_alb" "node_ingress" {
  name               = "${local.proj_name}-ingress"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  depends_on         = [aws_internet_gateway.gw]
  security_groups    = [aws_security_group.node_app_ingress.id]
}
resource "aws_alb_target_group" "node_app" {
  name        = "${local.proj_name}-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "2"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}
resource "aws_lb_listener" "node_app" {
  load_balancer_arn = aws_alb.node_ingress.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.node_app.arn
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
