job "docker-example1_compose-up-for2VM" {
  type = "service"
  namespace = "group2"

  constraint {
    attribute = "${node.class}"
    value     = "docker1"
  }

  group "compose" {
    task "run-compose" {
      driver = "raw_exec"  

      config {
        command = "/usr/bin/docker-compose" 
        args = [
          "-f", "/nginx-compose/docker-compose.yml",
          "up",
        ]
      }
    }
  }
}
