module "kong_fargate" {
  source = "../../konnect-terraform-ecs-fargate"

  cluster_cert_secret_arn = "arn:aws:secretsmanager:eu-west-1:412431539555:secret:konnect/cluster_certs/datadog-testing/cert-94hvCl"
  cluster_cert_key_secret_arn = "arn:aws:secretsmanager:eu-west-1:412431539555:secret:konnect/cluster_certs/datadog-testing/key-Gt5MHu"
  vpc_id = "vpc-02b37f5fafc2d3bc9"
  subnets = [
    "subnet-0a0e73ca1fe3ec11b",
    "subnet-030d314843e5f227e"
  ]
  kong_image_repository = "kong/kong-gateway"
  kong_image_tag = "3.5.0.3"

  runtime_group = "datadog-tests"

  ecs_cluster_name = "jack-template-builder"
  alb_certificate_arn = "arn:aws:acm:eu-west-1:412431539555:certificate/6b3656af-4c08-4cab-9525-703949a7b2cf"

  control_plane_address = "0756c71da2.eu.cp0.konghq.com"
  telemetry_address = "0756c71da2.eu.tp0.konghq.com"
}
