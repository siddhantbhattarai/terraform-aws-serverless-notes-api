resource "aws_apigatewayv2_api" "notes" {
  name          = "${local.name_prefix}-http"
  protocol_type = "HTTP"
  tags          = local.common_tags
}

resource "aws_apigatewayv2_integration" "notes" {
  api_id                 = aws_apigatewayv2_api.notes.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.notes_api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "notes" {
  for_each  = toset(["GET /notes", "POST /notes", "GET /notes/{id}", "DELETE /notes/{id}"])
  api_id    = aws_apigatewayv2_api.notes.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.notes.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.notes.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.notes_api.arn
    format          = jsonencode({ requestId = "$context.requestId", status = "$context.status" })
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notes_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.notes.execution_arn}/*/*"
}
