resource "aws_autoscaling_group" "example" {

    name = var.cluster_name

    vpc_zone_identifier = var.subnet_ids
    target_group_arns = var.target_group_arns
    health_check_type = var.health_check_type

    min_size = var.min_size
    max_size = var.max_size

    instance_refresh {
        strategy = "Rolling"
        preferences {
            min_healthy_percentage = 50
        }
    }

    lifecycle {
        # Validation after we executed terraform apply
        postcondition {
            condition = length(self.availability_zones) > 1
            error_message = "You must use more than one AZ for high availability"
        }
    }

    launch_template {
        id = aws_launch_template.example.id
        version = "$Latest"
    }

    tag {
        key = "Name"
        value = "${var.cluster_name}-asg"
        propagate_at_launch = true
    }

    dynamic "tag" {
        for_each = var.custom_tags

        content {
            key = tag.key
            value = tag.value
            propagate_at_launch = true
        }
    }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {

    count = var.enable_autoscaling ? 1 : 0

    scheduled_action_name = "scale_out_during_business_hours"
    min_size = 2
    max_size = 5
    desired_capacity = 5
    recurrence = "0 9 * * *"

    autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
    
    count = var.enable_autoscaling ? 1 : 0
    
    scheduled_action_name = "scale_in_at_night"
    min_size = 2
    max_size = 5
    desired_capacity = 2
    recurrence = "0 17 * * *"

    autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_launch_template" "example" {
    
    image_id = var.ami
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = var.user_data

    lifecycle {
        create_before_destroy = true

        # Validation before apply
        # Same as in validation in variables, but we do not tied down to hardcoded values
        precondition {
            condition = data.aws_ec2_instance_type.instance.free_tier_eligible
            error_message = "${var.instance_type} is not part of the AWS Free Tier"
        }
    }
}

resource "aws_security_group" "instance" {
    name = "${var.cluster_name}-instance"
}

resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name  = "${var.cluster_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count = format("%.1s", var.instance_type) == "t" ? 1 : 0

  alarm_name  = "${var.cluster_name}-low-cpu-credit-balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}

data "aws_ec2_instance_type" "instance" {
  instance_type = var.instance_type
}

locals {
    http_port = 80
    any_port = 0
    any_protocol = "-1"
    tcp_protocol = "tcp"
    all_ips = ["0.0.0.0/0"]
}