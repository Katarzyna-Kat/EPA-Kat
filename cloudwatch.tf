resource "aws_lambda_function" "check_lambda" {
    filename = "check_lambda.zip"
    function_name = "checkLambda"
    role = "arn:aws:iam::867736086712:role/snapshot_deletion_lambda"
    handler = "index.handler"
    runtime = 
}

resource "aws_cloudwatch_event_rule" "every_week" {
    name = "every-week"
    description = "Trigger to run once a week"
    schedule_expression = "cron(0 10 ? * FRI *)"
}

resource "aws_cloudwatch_event_target" "check_lambda_weekly" {
    rule = aws_cloudwatch_event_rule.every_week.name
    target_id = "check_lambda"
    arn = aws_lambda_function.check_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.check_lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_week.arn
}