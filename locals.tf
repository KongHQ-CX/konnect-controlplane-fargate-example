locals {
  control_planes = yamldecode(file("./control-planes.yaml"))
}
