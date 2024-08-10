resource "aws_autoscaling_group" "asg" {
  min_size            = 1
  desired_capacity    = 2
  max_size            = 3
  vpc_zone_identifier = [aws_subnet.euw1a.id, aws_subnet.euw1b.id]

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_iam_role" "ecs_ec2" {
  name               = "ecs-ec2"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
  }
  EOF
}
resource "aws_iam_policy_attachment" "ecs_ec2" {
  name       = "${local.proj_name}-ecs-ec2"
  roles      = [aws_iam_role.ecs_ec2.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_ec2" {
  name = "ecsInstanceRole"
  role = aws_iam_role.ecs_ec2.name
}

data "template_file" "ecssh" {
  template = file("./templates/ecs.sh.tpl")
  vars = {
    cluster_name = local.cluster_name
  }
}

resource "aws_launch_template" "ecs" {
  name_prefix            = "ecs-template"
  instance_type          = "t3.micro"
  image_id               = "ami-0913391b29f78da7c" # ECS-Optimized
  key_name               = "ec2ecsglog"
  vpc_security_group_ids = [aws_security_group.vpc.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_ec2.name
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-instance"
    }
  }
  user_data = base64encode(data.template_file.ecssh.rendered)
}

resource "aws_ecs_capacity_provider" "cluster" {
  name = local.proj_name
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.asg.arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 3
    }
  }
}
resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = [aws_ecs_capacity_provider.cluster.name]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.cluster.name
  }
}
