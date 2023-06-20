resource "aws_sns_topic" "user_updates" {
  name = "snapshot-deletion"
  
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = var.email
}


#### sns email

data "template_file" "key_policy" {
    template = file("policy/sns_policy.json")
}

resource "aws_id" "key" {
    enable_key_rotation = true
    master_key = data.template_file.key_policy.rendered
}

resource "aws_sns_topic" "lambda-email" {
  name = "lambda_email_resource"
  displayed_name = "lambda_email_resource"
  key_id = aws_id.key.key_id
}

data "template_file" "lambda_email_template" {
  template = file("python_script/lambda-email.py")
  vars = {
    lambda_email_sns_topic = aws_sns_topic.lambda-email.arn
  }
}

data "archive_file" "lambda_email_script" {
  type = "zip"
  output_path = "python_script/lambda-email.zip"
  source = {
    content = data.template_file.lambda_email_template.rendered
    filename = "lambda-email.py"
  }
}

resource "aws_lambda_function" "lambda_email_function" {
  function_name = "lambda-email"
  description = "Warning about deletion of snapshots."
  handler = "lambda_email.lambda_handler"
  role = aws_iam_role.snapshot_deletion_lambda.arn
  runtime = "python3.9"
  timeout = "10"
  filename = data.archive_file.lambda_email_script.output_path
  source_code_hash = data.archive_file.lambda_email_script.output_base64sha256
  publish = false
}