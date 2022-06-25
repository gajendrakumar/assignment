# Creates ECS cluster to run the project's Docker image on.

resource "aws_ecs_cluster" "rearc-ecs-cluster" {
  name = "rearc-ecs-cluster"
}

resource "aws_launch_configuration" "ecs-example-launchconfig" {
  name_prefix          = "ecs-launchconfig"
  image_id             = var.ECS_AMIS[var.AWS_REGION]
  instance_type        = var.ECS_INSTANCE_TYPE
  iam_instance_profile = aws_iam_instance_profile.ecs-ec2-role.id
  security_groups      = [aws_security_group.ecs-securitygroup.id]
  user_data            = "#!/bin/bash\necho 'ECS_CLUSTER=rearc-ecs-cluster' > /etc/ecs/ecs.config\nstart ecs"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs-example-autoscaling" {
  name                 = "ecs-example-autoscaling"
  vpc_zone_identifier  = [aws_subnet.rearc-public-1.id, aws_subnet.rearc-public-2.id]
  launch_configuration = aws_launch_configuration.ecs-example-launchconfig.name
  min_size             = 1
  max_size             = 1
  tag {
    key                 = "Name"
    value               = "ecs-ec2-container"
    propagate_at_launch = true
  }
}

# Creates a log group for the ECS cluster

resource "aws_cloudwatch_log_group" "rearc-log-group" {
  name = "rearc-log-group"
}

# creating ecr repository
resource "aws_ecr_repository" "rearc-container-repo" {
  name = "rearc-container-repo"
}

# The task and container definitions

resource "aws_ecs_task_definition" "rearc-task-definition" {
  family = "rearc-task-definition"
  container_definitions = jsonencode([
    {
      "name": "rearc-container-definition",
      "image": "${aws_ecr_repository.rearc-container-repo.repository_url}:latest",
      "essential": true,
      "memoryReservation": 128
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ]
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.rearc-log-group.name}"
          "awslogs-region": "${var.AWS_REGION}"
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ])
}

# The ECS Service makes it possible to specify the given tasks to launch on the ECS
# Cluster, and configure related attributes like the network and load balancer environments. 

resource "aws_ecs_service" "rearc-ecs-service" {
  name = "rearc-ecs-service"
  cluster = aws_ecs_cluster.rearc-ecs-cluster.id
  task_definition = aws_ecs_task_definition.rearc-task-definition.id
  desired_count = 1

  load_balancer {
    elb_name       = aws_elb.myapp-elb.name
    container_name = "myapp"
    container_port = 3000
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_iam_server_certificate" "rearc-ssl-cert" {
  name = "rearc-ssl-cert"
  certificate_body = file("rearc_cert/cert.pem")
  private_key = file("rearc_cert/key.pem")
}

# load balancer
resource "aws_elb" "myapp-elb" {
  name = "myapp-elb"

  listener {
    instance_port     = 3000
    instance_protocol = "https"
    lb_port           = 443
    lb_protocol       = "https"
    ssl_policy = "ELBSecurityPolicy-2016-08"
    certificate_arn = aws_iam_server_certificate.rearc-ssl-cert.arn
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    target              = "HTTP:3000/"
    interval            = 60
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  subnets         = [aws_subnet.rearc-public-1.id, aws_subnet.rearc-public-2.id]
  security_groups = [aws_security_group.myapp-elb-securitygroup.id]

  tags = {
    Name = "myapp-elb"
  }
}
