resource "aws_iam_user" "devternity_deployer" {
  name = "devternity_deployer"
}

resource "aws_iam_access_key" "devternity_deployer_key" {
  user = aws_iam_user.devternity_deployer.name
}

resource "aws_iam_user_policy_attachment" "devternity_deployer_policy_attachment" {
  user       = aws_iam_user.devternity_deployer.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}

resource "aws_iam_user" "devternity_s3_user" {
  name = "devternity_s3_user"
}

resource "aws_iam_access_key" "devternity_s3_user_key" {
  user = aws_iam_user.devternity_s3_user.name
}

resource "aws_iam_user_policy" "devternity_s3_user_policy" {
  name   = "devternity_s3_user_policy"
  user   = aws_iam_user.devternity_s3_user.name
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

resource "aws_iam_role" "devternity_lambda_executor" {
  name               = "devternity_lambda_executor"
  assume_role_policy = <<EOF
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
  name   = "devternity_lambda_executor_policy"
  role   = aws_iam_role.devternity_lambda_executor.id
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

resource "aws_iam_role" "devternity_api_executor" {
  name               = "devternity_api_executor"
  assume_role_policy = <<EOF
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
  name   = "devternity_api_executor_policy"
  role   = aws_iam_role.devternity_api_executor.id
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
        "Resource": [
            "${aws_lambda_function.devternity_ticket_generator.arn}",
            "${aws_lambda_function.devternity_card_generator.arn}"
        ]
    }
  ]
}
EOF

}

resource "aws_api_gateway_account" "api_gateway" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

resource "aws_iam_role" "api_gateway_cloudwatch" {
  name               = "api_gateway_cloudwatch_global"
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
  name   = "default"
  role   = aws_iam_role.api_gateway_cloudwatch.id
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

