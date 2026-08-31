output "api_endpoint" { value = aws_apigatewayv2_api.notes.api_endpoint }
output "notes_table_name" { value = aws_dynamodb_table.notes.name }
output "lambda_function_name" { value = aws_lambda_function.notes_api.function_name }
