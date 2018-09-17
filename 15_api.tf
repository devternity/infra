
//                _               _
//               (_)             | |
//     __ _ _ __  _    __ _  __ _| |_ _____      ____ _ _   _
//    / _` | '_ \| |  / _` |/ _` | __/ _ \ \ /\ / / _` | | | |
//   | (_| | |_) | | | (_| | (_| | ||  __/\ V  V / (_| | |_| |
//    \__,_| .__/|_|  \__, |\__,_|\__\___| \_/\_/ \__,_|\__, |
//         | |         __/ |                             __/ |
//         |_|        |___/                             |___/
//

resource "aws_api_gateway_rest_api" "DevTernityAPI" {
  name                    = "DevTernity API"
  description             = "API to support DevTernity automation"
}

resource "aws_api_gateway_api_key" "DevTernityAPIKey" {
  name                    = "devternity_api_key"
  description             = "Default DevTernity API key"
}

resource "aws_api_gateway_deployment" "DevTernityAPIDeployment" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  stage_name              = "prod"
//  stage_description       = "${timestamp()}" // forces to 'create' a new deployment each run
}

resource "aws_api_gateway_usage_plan" "devternity_api_usage_plan" {

  name         = "devternity-api-usage-plan"
  description  = "DevTernity API Default Usage Plan"

  api_stages {
    api_id = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
    stage  = "${aws_api_gateway_deployment.DevTernityAPIDeployment.stage_name}"
  }

  quota_settings {
    limit  = 200
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }

}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = "${aws_api_gateway_api_key.DevTernityAPIKey.id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.devternity_api_usage_plan.id}"
}

resource "aws_api_gateway_resource" "DevTernityAPITicket" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  parent_id               = "${aws_api_gateway_rest_api.DevTernityAPI.root_resource_id}"
  path_part               = "ticket"
}

resource "aws_api_gateway_method" "DevTernityAPITicketPOST" {
  api_key_required        = true
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  resource_id             = "${aws_api_gateway_resource.DevTernityAPITicket.id}"
  http_method             = "POST"
  authorization           = "NONE"
}

resource "aws_api_gateway_integration" "DevTernityAPITicketPOSTIntegration" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  resource_id             = "${aws_api_gateway_resource.DevTernityAPITicket.id}"
  http_method             = "${aws_api_gateway_method.DevTernityAPITicketPOST.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             = "${aws_iam_role.devternity_api_executor.arn}"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:devternity_ticket_generator/invocations"
}

resource "aws_api_gateway_method_response" "DevTernityAPITicketPOSTResponse" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  resource_id             = "${aws_api_gateway_resource.DevTernityAPITicket.id}"
  http_method             = "${aws_api_gateway_method.DevTernityAPITicketPOST.http_method}"
  status_code             = "200"
  response_models         = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "DevTernityAPITicketPOSTError" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  resource_id             = "${aws_api_gateway_resource.DevTernityAPITicket.id}"
  http_method             = "${aws_api_gateway_method.DevTernityAPITicketPOST.http_method}"
  status_code             = "500"
  response_models         = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "DevTernityAPITicketPOSTIntegrationResponse" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  resource_id             = "${aws_api_gateway_resource.DevTernityAPITicket.id}"
  http_method             = "${aws_api_gateway_method.DevTernityAPITicketPOST.http_method}"
  status_code             = "200"
}

resource "aws_api_gateway_resource" "DevTernityAPICard" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  parent_id               = "${aws_api_gateway_rest_api.DevTernityAPI.root_resource_id}"
  path_part               = "card"
}

resource "aws_api_gateway_method" "DevTernityAPICardPOST" {
  api_key_required        = true
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  resource_id             = "${aws_api_gateway_resource.DevTernityAPICard.id}"
  http_method             = "POST"
  authorization           = "NONE"
}

resource "aws_api_gateway_integration" "DevTernityAPICardPOSTIntegration" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  resource_id             = "${aws_api_gateway_resource.DevTernityAPICard.id}"
  http_method             = "${aws_api_gateway_method.DevTernityAPICardPOST.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             = "${aws_iam_role.devternity_api_executor.arn}"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:devternity_card_generator/invocations"
}

resource "aws_api_gateway_method_response" "DevTernityAPICardPOSTResponse" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  resource_id             = "${aws_api_gateway_resource.DevTernityAPICard.id}"
  http_method             = "${aws_api_gateway_method.DevTernityAPICardPOST.http_method}"
  status_code             = "200"
  response_models         = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "DevTernityAPICardPOSTError" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  resource_id             = "${aws_api_gateway_resource.DevTernityAPICard.id}"
  http_method             = "${aws_api_gateway_method.DevTernityAPICardPOST.http_method}"
  status_code             = "500"
  response_models         = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "DevTernityAPICardPOSTIntegrationResponse" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  resource_id             = "${aws_api_gateway_resource.DevTernityAPICard.id}"
  http_method             = "${aws_api_gateway_method.DevTernityAPICardPOST.http_method}"
  status_code             = "200"
}
