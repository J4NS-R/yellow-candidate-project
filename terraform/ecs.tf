resource "aws_ecs_task_definition" "node" {
  container_definitions = jsonencode([
    {
      name      = "node"
      image     = "ghcr.io/j4ns-r/yellow-candidate-project:1.0.0"
      cpu       = 512 # 1 vCPU = 1024 units
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
  family = "service"
  tags = {
    Name = "${local.proj_name}-node-app"
  }
}

resource "aws_ecs_service" "node" {
  name            = local.proj_name
  task_definition = aws_ecs_task_definition.node.arn
  desired_count   = 1
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
