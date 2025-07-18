variable "namespace" {
  type    = string
  default = "default"
}

variable "compose_path" {
  type    = string
  default = "./"
}

job "docker-example1_compose-up-for2VM" {
  type = "batch"
  namespace = var.namespace

  constraint {
    attribute = "${node.class}"
    value     = var.namespace
  }

  group "compose" {
    task "send-compose-file" {
      driver = "raw_exec" 

      artifact {
        source      = "git::https://github.com/semon24/Automate-Update-Images"
        destination = "/tmp/repo"
      }	
      
      config {
        command = "sh"
        args    = ["-c", 
          "mv tmp/repo/group2/compose-file.yml $var.compose_path"]
      }
    }
  }
}
