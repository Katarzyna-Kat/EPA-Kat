#resource "aws_lambda_function" "check_lambda" {
#    filename = "check_lambda.zip"
#    function_name = "checkLambda"
#    role = "arn:aws:iam::867736086712:role/snapshot_deletion_lambda"
#    handler = "snapshot-deletion.lambda_handler"
#    runtime = "python3.9"
#}