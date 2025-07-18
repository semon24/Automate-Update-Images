variable "namespace" {
  type    = string
  default = "default"
}

variable "compose_path" {
  type    = string
  default = "./"
}

job "compose-up" {
  type = "batch"
  namespace = var.namespace

  constraint {
    attribute = "${node.class}"
    value     = var.namespace
  }

  group "compose" {
    task "compose-up" {
      driver = "raw_exec"  

      config {
        command = "/usr/bin/docker-compose" 
        args = [
          "-f", var.compose_path,
          "up"
        ]
      }
    }
  }
}
