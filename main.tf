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


##### zipping python
provider "archive" {}
data "archive_file" "zip" {
  type        = "zip"
  source_dir = "${var.upload_file_path}/"
  output_path = "lambda_snapshot_deletion.zip"
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

data "aws_iam_policy" "AmazonS3FullAccess" {
    arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
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

resource "aws_iam_role_policy_attachment" "Policy_attachment_S3" {
  role       = "${aws_iam_role.snapshot_deletion_lambda.name}"
  policy_arn = "${data.aws_iam_policy.AmazonS3FullAccess.arn}"
}

resource "aws_lambda_function" "lambda" {
  function_name = "lambda_snapshot_deletion"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role    = aws_iam_role.snapshot_deletion_lambda.arn
  handler = "lambda_snapshot_deletion.lambda_handler"
  runtime = "python3.9"
  timeout = "60"
}

##### trigger
resource "aws_cloudwatch_event_rule" "every_3_days" {
    name = "every_3_days"
    description = "Trigger to run once every 3 days"
    schedule_expression = "cron(0 11 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "lambda_3_days" {
    rule = aws_cloudwatch_event_rule.every_3_days.name
    target_id = "lambda"
    arn = aws_lambda_function.lambda.arn
    input = <<JSON
  {
    "dry_run": true
  }
  JSON
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_3_days.arn
}


##### alarms
resource "aws_cloudwatch_metric_alarm" "errors" {
  alarm_name                = "lambda-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = 3600
  statistic                 = "Average"
  threshold                 = 1
  alarm_description         = "This metric monitors errors that appear in lambda"
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:eu-north-1:867736086712:lambda_snapshot_deletion"]
  insufficient_data_actions = []
  dimensions = {
    FunctionName = "lambda_snapshot_deletion"
    }
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name                = "CPU"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 3600
  statistic                 = "Average"
  threshold                 = 0.5
  alarm_description         = "This metric monitors ec2 cpu utilization"
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:eu-north-1:867736086712:lambda_snapshot_deletion"]
  insufficient_data_actions = []
  dimensions = {
    InstanceId = "i-0a425e5ffbb6c01ec"
    }
}

resource "aws_cloudwatch_metric_alarm" "S3_size" {
  alarm_name                = "S3-size"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "BucketSizeBytes"
  namespace                 = "AWS/S3"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 2000000
  alarm_description         = "This metric monitors ec2 cpu utilization"
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:eu-north-1:867736086712:lambda_snapshot_deletion"]
  insufficient_data_actions = []
  dimensions = {
    BucketName = "tf-state-epa"
    }
}