data "archive_file" "notes_api" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/build/notes-api.zip"
}

resource "aws_cloudwatch_log_group" "notes_api" {
  name              = "/aws/lambda/${local.name_prefix}"
  retention_in_days = 30
  tags              = local.common_tags
}

resource "aws_iam_role" "lambda" {
  name               = "${local.name_prefix}-lambda"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }] })
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "lambda" {
  name = "notes-api-runtime"
  role = aws_iam_role.lambda.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["logs:CreateLogStream", "logs:PutLogEvents"], Resource = "${aws_cloudwatch_log_group.notes_api.arn}:*" },
    { Effect = "Allow", Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:Scan"], Resource = aws_dynamodb_table.notes.arn }
  ] })
}

resource "aws_lambda_function" "notes_api" {
  function_name    = local.name_prefix
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.notes_api.output_path
  source_code_hash = data.archive_file.notes_api.output_base64sha256
  timeout          = 10
  environment { variables = { NOTES_TABLE = aws_dynamodb_table.notes.name } }
  tags = local.common_tags
}
