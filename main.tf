module "kong_fargate" {
  source = "../konnect-terraform-ecs-fargate"

  for_each = {
    for control_plane in local.control_planes.control_planes : control_plane.name => control_plane
  }

  ecs_cluster_name = each.value["ecs_cluster"]

  kong_image_repository = each.value["kong_image_repository"]
  kong_image_tag = each.value["kong_image_tag"]

  cluster_cert_secret_arn = can(each.value["cluster_cert_secret_arn"]) ? each.value["cluster_cert_secret_arn"] : null
  cluster_cert_key_secret_arn = can(each.value["cluster_cert_key_secret_arn"]) ? each.value["cluster_cert_key_secret_arn"] : null
  alb_certificate_arn = each.value["load_balancer_cert_arn"]

  control_plane_address = each.value["cluster_endpoint"]
  telemetry_address = each.value["telemetry_endpoint"]

  runtime_group = each.key
  control_plane_id = each.value["id"]
  vpc_id = each.value["vpc_id"]
  subnets = each.value["subnet_ids"]

  konnect_pat = var.konnect_pat
}

terraform {
  backend "s3" {
    bucket = "cx-emea-terraform-state"
    key    = "jack.tysoe/fargate-demo.tfstate"
    region = "eu-west-1"
  }
}
