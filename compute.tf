data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_launch_template" "app_template" {
  name_prefix   = "template-ubuntu-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y apache2 php
              sudo systemctl start apache2
              sudo systemctl enable apache2
              
              sudo tee /var/www/html/index.php << 'PHP_EOF'
              <?php
              $start = time();
              while (time() - $start < 1) {
                  passthru("openssl speed sha256"); 
              }
              echo "Servidor sufriendo bajo estres";
              ?>
              PHP_EOF

              sudo rm -f /var/www/html/index.html
              EOF
  )

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  tags = {
    Name = "launch-template-app"
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "asg-sistema-web"
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  vpc_zone_identifier = [aws_subnet.private_1a.id, aws_subnet.private_1b.id]

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "EC2-Instancia-Asg"
    propagate_at_launch = true
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_alta_alarma" {
  alarm_name          = "alarma-cpu-alta-1-minuto"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60 
  statistic           = "Average"
  threshold           = 15.0

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.cpu_scaling.arn]
}

resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "politica-escalado-rapido-pasos"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

    
