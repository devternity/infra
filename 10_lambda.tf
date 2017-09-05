
provider "aws" {
  region                  = "${var.aws_region}"
}

resource "aws_s3_bucket" "devternity_images" {
  bucket                  = "devternity-images"
  acl                     = "private"
}

resource "aws_s3_bucket" "devternity_code" {
  bucket                  = "devternity-code"
  acl                     = "private"
}

resource "aws_iam_user" "devternity_deployer" {
  name = "devternity_deployer"
}

resource "aws_iam_access_key" "devternity_deployer_key" {
  user = "${aws_iam_user.devternity_deployer.name}"
}

resource "aws_iam_user_policy_attachment" "devternity_deployer_policy_attachment" {
  user       = "${aws_iam_user.devternity_deployer.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}

resource "aws_iam_user" "devternity_s3_user" {
  name = "devternity_s3_user"
}

resource "aws_iam_access_key" "devternity_s3_user_key" {
  user = "${aws_iam_user.devternity_s3_user.name}"
}

resource "aws_iam_user_policy" "devternity_s3_user_policy" {
  name = "devternity_s3_user_policy"
  user = "${aws_iam_user.devternity_s3_user.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "${aws_s3_bucket.devternity_images.arn}",
        "${aws_s3_bucket.devternity_code.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl"
      ],
      "Resource": [
        "${aws_s3_bucket.devternity_images.arn}/*",
        "${aws_s3_bucket.devternity_code.arn}/*"
      ]
    }
  ]
}
EOF
}

//    _                 _         _
//   | |               | |       | |
//   | | __ _ _ __ ___ | |__   __| | __ _
//   | |/ _` | '_ ` _ \| '_ \ / _` |/ _` |
//   | | (_| | | | | | | |_) | (_| | (_| |
//   |_|\__,_|_| |_| |_|_.__/ \__,_|\__,_|
//
//

resource "aws_iam_role" "devternity_lambda_executor" {
  name                    = "devternity_lambda_executor"
  assume_role_policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      }
    },
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "devternity_lambda_executor_policy" {
    name                  = "devternity_lambda_executor_policy"
    role                  = "${aws_iam_role.devternity_lambda_executor.id}"
    policy                = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": [
        "${aws_s3_bucket.devternity_images.arn}",
        "${aws_s3_bucket.devternity_code.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl"
      ],
      "Resource": [
        "${aws_s3_bucket.devternity_images.arn}/*",
        "${aws_s3_bucket.devternity_code.arn}/*"
      ]
    }
  ]
}
EOF
}

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


//                _               _
//               (_)             | |
//     __ _ _ __  _    __ _  __ _| |_ _____      ____ _ _   _
//    / _` | '_ \| |  / _` |/ _` | __/ _ \ \ /\ / / _` | | | |
//   | (_| | |_) | | | (_| | (_| | ||  __/\ V  V / (_| | |_| |
//    \__,_| .__/|_|  \__, |\__,_|\__\___| \_/\_/ \__,_|\__, |
//         | |         __/ |                             __/ |
//         |_|        |___/                             |___/
//

resource "aws_iam_role" "devternity_api_executor" {
  name                    = "devternity_api_executor"
  assume_role_policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      }
    },
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "devternity_api_executor_policy" {
  name = "devternity_api_executor_policy"
  role = "${aws_iam_role.devternity_api_executor.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
      ],
      "Resource": "*"
    },
     {
        "Effect": "Allow",
        "Action": [
            "lambda:InvokeFunction"
        ],
        "Resource": ["${aws_lambda_function.devternity_ticket_generator.arn}"]
    }
  ]
}
EOF
}

resource "aws_api_gateway_account" "api_gateway" {
  cloudwatch_role_arn = "${aws_iam_role.api_gateway_cloudwatch.arn}"
}

resource "aws_iam_role" "api_gateway_cloudwatch" {
  name = "api_gateway_cloudwatch_global"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "api_gateway_cloudwatch_policy" {
  name = "default"
  role = "${aws_iam_role.api_gateway_cloudwatch.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_api_gateway_rest_api" "DevTernityAPI" {
  name                    = "DevTernity API"
  description             = "API to support DevTernity automation"
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

resource "aws_api_gateway_api_key" "DevTernityAPIKey" {
  name                    = "devternity_api_key"
  description             = "Default DevTernity API key"
}

resource "aws_api_gateway_deployment" "DevTernityAPIDeployment" {
  rest_api_id             = "${aws_api_gateway_rest_api.DevTernityAPI.id}"
  stage_name              = "prod"
  stage_description       = "${timestamp()}" // forces to 'create' a new deployment each run
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