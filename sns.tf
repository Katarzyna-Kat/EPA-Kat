resource "aws_sns_topic" "user_updates" {
  name = "snapshot_deletion"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = var.email
}

data "template_file" "access_sns_snapshot_deletion" {
  template = file("functions_folder/main_code/snapshot_deletion.py")

  vars = {
    snapshot_deletion_sns_topic = aws_sns_topic.user_updates.arn
  }
}

