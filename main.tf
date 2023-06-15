provider "aws" {
  region =var.aws_region
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

resource "aws_lambda_function" "lambda" {
  function_name = "snapshot-deletion"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role    = aws_iam_role.snapshot_deletion_lambda.arn
  handler = "snapshot-deletion.lambda_handler"
  runtime = "python3.9"
}