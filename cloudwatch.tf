
# ---------------------------------------
# EC2 High CPU Alarm
# ---------------------------------------
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "ec2-cpu-high"
  alarm_description   = "EC2 CPU utilization exceeds 80%"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  period             = 300

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"
  statistic   = "Average"
  threshold   = 80

  dimensions = {
    InstanceId = aws_instance.my_ec2.id
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.ec2_alerts.arn]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ec2-cpu-alarm"
  })
}

# ----------------------------------------
# EC2 Status Check Alarm
# ----------------------------------------

resource "aws_cloudwatch_metric_alarm" "ec2_status_check" {
  alarm_name        = "ec2-status-check"
  alarm_description = "EC2 Instance status check failed"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300

  metric_name = "StatusCheckFailed"
  namespace   = "AWS/EC2"
  statistic   = "Maximum"
  threshold   = 0

  dimensions = {
    InstanceId = aws_instance.my_ec2.id
  }

  treat_missing_data = "missing"

  alarm_actions = [
    aws_sns_topic.ec2_alerts.arn
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ec2-status-check-alarm"
  })
}

# ----------------------------------------
# EC2 High Memory Alarm
# ----------------------------------------

resource "aws_cloudwatch_metric_alarm" "ec2_high_memory" {
  alarm_name        = "ec2-high-memory"
  alarm_description = "EC2 memory utilization exceeds 80%"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60

  metric_name = "mem_used_percent"
  namespace   = "Custom/EC2"
  statistic   = "Average"
  threshold   = 80

  dimensions = {
    host = "ip-172-31-22-134"
  }
  
  treat_missing_data = "missing"  

  alarm_actions = [
    aws_sns_topic.ec2_alerts.arn
  ]
}

# ----------------------------------------
# EC2 High Disk Utilization Alarm
# ----------------------------------------

resource "aws_cloudwatch_metric_alarm" "ec2_high_disk" {
  alarm_name        = "ec2-high-disk"
  alarm_description = "EC2 root filesystem disk utilization exceeds 80%"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60

  metric_name = "disk_used_percent"
  namespace   = "Custom/EC2"
  statistic   = "Average"
  threshold   = 80

  dimensions = {
    device = "nvme0n1p1"
    fstype = "ext4"
    host   = "ip-172-31-22-134"
    path   = "/"
  }
  
  treat_missing_data = "missing"  

  alarm_actions = [
    aws_sns_topic.ec2_alerts.arn
  ]
}

# ----------------------------------------
# CloudWatch Dashboard
# ----------------------------------------

resource "aws_cloudwatch_dashboard" "ec2_dashboard" {
  dashboard_name = "ec2-metric-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "EC2 CPU Utilization"
          region = var.aws_region

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              aws_instance.my_ec2.id
            ]
          ]

          period  = 300
          stat    = "Average"
          view    = "timeSeries"
          stacked = false
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "EC2 Network Traffic"
          region = var.aws_region

          metrics = [
            [
              "AWS/EC2",
              "NetworkIn",
              "InstanceId",
              aws_instance.my_ec2.id
            ],
            [
              "AWS/EC2",
              "NetworkOut",
              "InstanceId",
              aws_instance.my_ec2.id
            ]
          ]

          period  = 300
          stat    = "Average"
          view    = "timeSeries"
          stacked = false
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "EC2 Status Checks"
          region = var.aws_region

          metrics = [
            [
              "AWS/EC2",
              "StatusCheckFailed",
              "InstanceId",
              aws_instance.my_ec2.id
            ],
            [
              "AWS/EC2",
              "StatusCheckFailed_Instance",
              "InstanceId",
              aws_instance.my_ec2.id
            ],
            [
              "AWS/EC2",
              "StatusCheckFailed_System",
              "InstanceId",
              aws_instance.my_ec2.id
            ]
          ]

          period  = 300
          stat    = "Maximum"
          view    = "timeSeries"
          stacked = false
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          title  = "EC2 Memory Utilization"
          region = var.aws_region

          metrics = [
            [
              "Custom/EC2",
              "mem_used_percent",
              "host",
              "ip-172-31-22-134"
            ]
          ]

          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          stacked = false
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          title  = "EC2 Root Disk Utilization"
          region = var.aws_region

          metrics = [
            [
              "Custom/EC2",
              "disk_used_percent",
              "device",
              "nvme0n1p1",
              "fstype",
              "ext4",
              "host",
              "ip-172-31-22-134",
              "path",
              "/"
            ]
          ]

          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          stacked = false
        }
      }
    ]
  })
}
