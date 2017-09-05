
output "api_gw_key" {
  value = "${aws_api_gateway_api_key.DevTernityAPIKey.value}"
}

output "api_gw_id" {
  value = "${aws_api_gateway_deployment.DevTernityAPIDeployment.rest_api_id}"
}

output "api_gw_url" {
  value = "${aws_api_gateway_deployment.DevTernityAPIDeployment.invoke_url}"
}

output "deployer_access_key_id" {
  value = "${aws_iam_access_key.devternity_deployer_key.id}"
}

output "deployer_secret_key" {
  value = "${aws_iam_access_key.devternity_deployer_key.secret}"
}

