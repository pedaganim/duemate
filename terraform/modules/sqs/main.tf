# Dead Letter Queue for Notifications
resource "aws_sqs_queue" "notification_dlq" {
  name                      = "${var.queue_name_prefix}-notification-dlq"
  message_retention_seconds = 1209600 # 14 days

  tags = merge(
    var.tags,
    {
      Name = "${var.queue_name_prefix}-notification-dlq"
      Type = "DeadLetterQueue"
    }
  )
}

# Notification Queue
resource "aws_sqs_queue" "notification" {
  name                       = "${var.queue_name_prefix}-notification"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notification_dlq.arn
    maxReceiveCount     = 3
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.queue_name_prefix}-notification"
      Type = "NotificationQueue"
    }
  )
}

# Queue policy to allow EventBridge and Lambda to send messages
resource "aws_sqs_queue_policy" "notification" {
  queue_url = aws_sqs_queue.notification.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgeAndLambda"
        Effect = "Allow"
        Principal = {
          Service = ["events.amazonaws.com", "lambda.amazonaws.com"]
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.notification.arn
      }
    ]
  })
}
