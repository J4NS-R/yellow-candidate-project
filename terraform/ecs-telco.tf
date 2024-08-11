resource "aws_ecs_task_definition" "telco" {
  container_definitions = jsonencode([
    {
      name      = "wiremock",
      image     = "ghcr.io/j4ns-r/yellow-candidate-project-telco:latest",
      essential = true,
      portMappings = [
        {
          "containerPort" : 8080,
          "hostPort" : 8080
        }
      ],
      logConfiguration = {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : aws_cloudwatch_log_group.ecs_log_group.name,
          "awslogs-region" : local.aws_region,
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  family                   = "telco"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.node_app.arn
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size
  cpu    = "512"
  memory = "1024"
  tags = {
    Name = "${local.proj_name}-telco"
  }
}

resource "aws_ecs_service" "telco" {
  name            = "telco"
  task_definition = aws_ecs_task_definition.telco.arn
  desired_count   = 1
  cluster         = aws_ecs_cluster.cluster.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = aws_subnet.private.*.id
    security_groups  = [aws_security_group.vpc.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.telco.arn
    container_name   = "wiremock"
    container_port   = 8080
  }
  depends_on = [aws_alb_listener.node_app, aws_iam_policy_attachment.node_app_ecs_exec]
}

# Load balancer
resource "aws_alb" "telco_ingress" {
  name               = "${local.proj_name}-telco-ing"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  depends_on         = [aws_internet_gateway.gw]
  security_groups    = [aws_security_group.node_app_ingress.id]
}
resource "aws_alb_target_group" "telco" {
  name        = "${local.proj_name}-tg-telco"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    healthy_threshold   = "2"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/__admin/mappings"
    unhealthy_threshold = "2"
  }
}
resource "aws_alb_listener" "telco" {
  load_balancer_arn = aws_alb.telco_ingress.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.yellow.arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.telco.arn
  }
}
