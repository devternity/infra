

//    _                 _         _
//   | |               | |       | |
//   | | __ _ _ __ ___ | |__   __| | __ _
//   | |/ _` | '_ ` _ \| '_ \ / _` |/ _` |
//   | | (_| | | | | | | |_) | (_| | (_| |
//   |_|\__,_|_| |_| |_|_.__/ \__,_|\__,_|
//
//

resource "aws_lambda_function" "devternity_ticket_generator" {
  s3_bucket               = "${aws_s3_bucket.devternity_code.bucket}"
  s3_key                  = "ticket-generator.zip"
  function_name           = "devternity_ticket_generator"
  description             = "DevTernity ticket generator"
  role                    = "${aws_iam_role.devternity_lambda_executor.arn}"
  handler                 = "lv.latcraft.devternity.tickets.TicketGenerator::generate"
  runtime                 = "java8"
  memory_size             = "1024"
  timeout                 = "300"
  environment {
    variables = {
      HOME                = "/var/task"
      JAVA_FONTS          = "/var/task/fonts"
    }
  }
}

resource "aws_lambda_alias" "devternity_ticket_generator_alias" {
  name                    = "devternity_ticket_generator_latest"
  function_name           = "${aws_lambda_function.devternity_ticket_generator.arn}"
  function_version        = "$LATEST"
}

resource "aws_lambda_permission" "devternity_ticket_generator_api_gatewaypermission" {
  statement_id            = "AllowExecutionFromAPIGateway"
  action                  = "lambda:InvokeFunction"
  function_name           = "${aws_lambda_function.devternity_ticket_generator.arn}"
  qualifier               = "${aws_lambda_alias.devternity_ticket_generator_alias.name}"
  principal               = "apigateway.amazonaws.com"
  source_arn              = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.DevTernityAPI.id}/*/POST/ticket"
}

resource "aws_lambda_function" "devternity_card_generator" {
  s3_bucket               = "${aws_s3_bucket.devternity_code.bucket}"
  s3_key                  = "card-generator.zip"
  function_name           = "devternity_card_generator"
  description             = "DevTernity card generator"
  role                    = "${aws_iam_role.devternity_lambda_executor.arn}"
  handler                 = "lv.latcraft.devternity.cards.CardGenerator::generate"
  runtime                 = "java8"
  memory_size             = "1024"
  timeout                 = "300"
  environment {
    variables = {
      HOME                = "/var/task"
      JAVA_FONTS          = "/var/task/fonts"
    }
  }
}

resource "aws_lambda_alias" "devternity_card_generator_alias" {
  name                    = "devternity_card_generator_latest"
  function_name           = "${aws_lambda_function.devternity_card_generator.arn}"
  function_version        = "$LATEST"
}

resource "aws_lambda_permission" "devternity_card_generator_api_gatewaypermission" {
  statement_id            = "AllowExecutionFromAPIGateway"
  action                  = "lambda:InvokeFunction"
  function_name           = "${aws_lambda_function.devternity_card_generator.arn}"
  qualifier               = "${aws_lambda_alias.devternity_card_generator_alias.name}"
  principal               = "apigateway.amazonaws.com"
  source_arn              = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.DevTernityAPI.id}/*/POST/ticket"
}

