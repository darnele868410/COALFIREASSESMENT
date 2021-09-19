

# resource "aws_autoscaling_attachment" "asg_attachment_RHEL" {
#   autoscaling_group_name = aws_autoscaling_group.RHEL_ASG.id
#   alb_target_group_arn   = aws_lb_target_group.TG-for-RHEL.arn
# }

# resource "aws_lb_target_group" "TG-for-RHEL" {

#   health_check {
#     interval            = 10
#     path                = "/"
#     protocol            = "HTTP"
#     timeout             = 5
#     healthy_threshold   = 5
#     unhealthy_threshold = 2

#   }
#   name        = "TG-for-RHEL"
#   vpc_id      = aws_vpc.CoalFire_VPC.id
#   target_type = "instance"
#   port        = 80
# }

# resource "aws_lb" "CoalFire_LB" {
#   name               = "CoalFire_LB"
#   internal           = true
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.Web-ASG-SG.id]  
#   subnet_id           = [aws_subnet.PrivateSubnet2.id]
#   private_ipv4_address = "10.1.3.96"



#   enable_deletion_protection = true

#   access_logs {
#     bucket  = "testcoalfirebucketforassesment1104558112"
#     prefix  = "Logs"
#     enabled = true
#   }

#   tags = {
#    Name = "CoalFire_LB"
#   }
# }

# resource "aws_lb_listener" "RHEL_LISTINER" {
#   load_balancer_arn = aws_lb.CoalFire_LB.arn
#   port              = "80"
#   protocol          = "HTTP"
  

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.TG-for-RHEL.arn
#   }

# resource "aws_lb_target_group_attachment" "TG-ATTACHMENT" {
#   target_group_arn = aws_lb_target_group.TG-for-RHEL.arn
#   target_id        = aws_lb_target_group.TG-for-RHEL.id
#   port             = 80
# }

# }