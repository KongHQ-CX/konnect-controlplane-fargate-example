module "kong_fargate" {
  source = "../../konnect-terraform-ecs-fargate"

  cluster_cert = "-----BEGIN CERTIFICATE-----\nMIIDrDCCApagAwIBAgIBATALBgkqhkiG9w0BAQ0wQDE+MAkGA1UEBhMCRVUwMQYD\nVQQDHioAawBvAG4AbgBlAGMAdAAtAGQAYQB0AGEAZABvAGcALQB0AGUAcwB0AHMw\nHhcNMjQwMjA1MDQxODI1WhcNMzQwMjA1MDQxODI1WjBAMT4wCQYDVQQGEwJFVTAx\nBgNVBAMeKgBrAG8AbgBuAGUAYwB0AC0AZABhAHQAYQBkAG8AZwAtAHQAZQBzAHQA\nczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALiDKlomT8KiWsVAXXgU\nUR2Ze+xSxL7fd++GdMGBaoyIiC+l4snLLtAa1uFqLCPSDb+S+dTrD/6pHNxBp3GY\nDmarNjqgfNGLnkQ4z6xJXZseBBiJmxgcZhgfXHLNOaWeyxOmY5evsDRWDl25vUG8\n01h/zYI6aLjdwbZMTjP5mzB7wD26HN8EFl5am2nT1uZvjaGxbcWU1DPnz/10lRWi\nbhB63DFjAGWfVBahgH3SHCihPwgbbYtlSWUaBcCtCw7QxfxB9H2XGvSXNmcGVbrj\nV2nvVgS+watK3pwV2YvuRZDjmo48a+PlNt1brS9y3Km0ApsgLPwfbUPlpyn73BSc\nXfMCAwEAAaOBtDCBsTASBgNVHRMBAf8ECDAGAQH/AgEDMAsGA1UdDwQEAwIABjAd\nBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwFwYJKwYBBAGCNxQCBAoMCGNl\ncnRUeXBlMCMGCSsGAQQBgjcVAgQWBBQBAQEBAQEBAQEBAQEBAQEBAQEBATAcBgkr\nBgEEAYI3FQcEDzANBgUpAQEBAQIBCgIBFDATBgkrBgEEAYI3FQEEBgIEABQACjAL\nBgkqhkiG9w0BAQ0DggEBALREq5v6SRCru4ARrxjK+hjb4GSCt31LPlZzO9ajw0GW\nmUpYauTCwUoTptj7X1It60ajgcCcATfv0om2NJULLmKa3rR8HkETSzdFEZVAJZvH\n3o88c+1/RftQB4FuHlaCWByyE8BnYWf7ydj2E2eoGK+IFoVrljeHjcKykwDy1aug\ni4/JfRIeor3NnQPrLF+Jrc36kjdtwOAA63+x8a2OFM/Hryd/9ERx/5cSo8H9lNCF\ndgrGJVs54HsA6cCcwl2lq7+PrLtvQx4fPSK4YopcxqIkoXLXiLDdeRPhuYKg7UlZ\nPwKnqE+R2YyCvw5BSH7WH+wJuqrkKPupYXq/G1mJN8Y=\n-----END CERTIFICATE-----"
  cluster_cert_secret_arn = "arn:aws:secretsmanager:eu-west-1:412431539555:secret:konnect/cluster_certs/datadog-testing/key-Gt5MHu"
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

  control_plane_address = "eab705ce6f.eu.cp0.konghq.com"
  telemetry_address = "eab705ce6f.eu.tp0.konghq.com"
}
