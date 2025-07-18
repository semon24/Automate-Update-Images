job "compose-up" {
  type = "batch"
  namespace = "group2"

  constraint {
    attribute = "${node.class}"
    value     = "docker1"
  }

  group "compose" {
    task "compose-up" {
      driver = "raw_exec"  

      config {
        command = "/usr/bin/docker-compose" 
        args = [
          "-f", "/nginx-compose/compose-file.yml",
          "up"
        ]
      }
    }
  }
}
