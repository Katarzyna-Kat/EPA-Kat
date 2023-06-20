terraform {
  backend "s3" {
    bucket                  = "tf-state-epa"
    key                     = "terraform-epa"
    region                  = "eu-north-1"
    shared_credentials_file = "~/.aws/credentials"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "archive" {}
data "archive_file" "zip" {
  type        = "zip"
  source_file = "snapshot-deletion.py"
  output_path = "snapshot-deletion.zip"
}

### trust relationship
data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

### creating role
resource "aws_iam_role" "snapshot_deletion_lambda" {
  name               = "snapshot_deletion_lambda"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}

### policy to attch from existing
data "aws_iam_policy" "AWSAmazonEC2FullAccess" {
    arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
    arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "AWSXRayDaemonWriteAccess" {
    arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

data "aws_iam_policy" "AmazonSNSFullAccess" {
    arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

### attaching policies
resource "aws_iam_role_policy_attachment" "Policy_attachment_EC2" {
  role       = "${aws_iam_role.snapshot_deletion_lambda.name}"
  policy_arn = "${data.aws_iam_policy.AWSAmazonEC2FullAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "Policy_attachment_Lambda" {
  role       = "${aws_iam_role.snapshot_deletion_lambda.name}"
  policy_arn = "${data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn}"
}

resource "aws_iam_role_policy_attachment" "Policy_attachment_xRay" {
  role       = "${aws_iam_role.snapshot_deletion_lambda.name}"
  policy_arn = "${data.aws_iam_policy.AWSXRayDaemonWriteAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "Policy_attachment_SNS" {
  role       = "${aws_iam_role.snapshot_deletion_lambda.name}"
  policy_arn = "${data.aws_iam_policy.AmazonSNSFullAccess.arn}"
}

### lambda function
resource "aws_lambda_function" "lambda" {
  function_name = "snapshot-deletion"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role    = aws_iam_role.snapshot_deletion_lambda.arn
  handler = "snapshot-deletion.lambda_handler"
  runtime = "python3.9"
}

resource "aws_cloudwatch_event_rule" "every_5_days" {
    name = "every-5_days"
    description = "Trigger to run once every 5 days"
    schedule_expression = "cron(0 9 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_5_days" {
    rule = aws_cloudwatch_event_rule.every_5_days.name
    target_id = "lambda"
    arn = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_5_days.arn
}
