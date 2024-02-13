output "yamldecode_function" {
  value= yamldecode(file("./control-planes.yaml"))
}
