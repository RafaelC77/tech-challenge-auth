data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "lambda/index.js"
  output_path =  "lambda/index.zip"
}

resource "aws_iam_role" "lambda_role" {
  assume_role_policy = file("lambda-policy.json")
  name = "lambda_role"
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.lambda_role
}

resource "aws_lambda_function" "auth_lambda_function" {
  function_name = "lambda_auth"
  filename = "lambda/index.js"
  role = aws_iam_role.lambda_role.arn
  handler = "index.handler"
  runtime = "nodejs20.x"
  timeout = 30
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      LOGIN_BY_CPF_URL = var.LOGIN_BY_CPF_URL
    }
  }
}

resource "aws_lambda_permission" "api_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_lambda_function.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
  statement_id  = "AllowAPIGatewayInvoke"
}