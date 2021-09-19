
###Launch Config for ASG #################
resource "aws_launch_configuration" "RHEL_WEB_ASG" {
  name            = "RHEL_WEB_ASG_LCFG"
  image_id        = var.AMI
  instance_type   = var.SIZE
  key_name        = var.SSH_KEY
  security_groups = [aws_security_group.Web-ASG-SG.id]
  user_data       = <<EOF
#!/bin/bash
cd /home/ec2-user
sudo yum update -y
sudo yum upgrade -y
yum install httpd -y
systemctl enable httpd
systemctl start httpd
echo "THIS IS A TEST website!!" > /var/www/html/index.html
EOF

  root_block_device {
    volume_size = 20
  }

}

###AutoScaling Group #################################
resource "aws_autoscaling_group" "RHEL_ASG" {
  name                      = "RHEL_ASG"
  max_size                  = 6
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  termination_policies      = ["OldestInstance"]
  launch_configuration      = aws_launch_configuration.RHEL_WEB_ASG.id
  vpc_zone_identifier       = [aws_subnet.PrivateSubnet2.id]
  tag {
    key                 = "name"
    value               = "RHELASG"
    propagate_at_launch = true
  }
}
###Policy#################################################
resource "aws_autoscaling_policy" "RHEL_WEB_ASG_POLICY" {
  name                   = "RHEL_SCALING_POLICY"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.RHEL_ASG.name

}
###AutoScalingPlan#########################################
resource "aws_autoscalingplans_scaling_plan" "RHEL_Scaling_Plan" {
  name = "RHEL_Scaling_Plan"

  application_source {
    tag_filter {
      key    = "name"
      values = ["RHEL_ASG"]
    }
  }

  scaling_instruction {
    max_capacity       = 6
    min_capacity       = 2
    resource_id        = format("autoScalingGroup/%s", aws_autoscaling_group.RHEL_ASG.id)
    scalable_dimension = "autoscaling:autoScalingGroup:DesiredCapacity"
    service_namespace  = "autoscaling"

    target_tracking_configuration {
      predefined_scaling_metric_specification {
        predefined_scaling_metric_type = "ASGAverageCPUUtilization"
      }

      target_value = 1
    }
  }
}

###Cloudwatch to trigger autoscaling########################

