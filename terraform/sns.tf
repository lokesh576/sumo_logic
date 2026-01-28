resource "aws_sns_topic" "alerts" {
  name = "${var.application_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.sns_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email
}