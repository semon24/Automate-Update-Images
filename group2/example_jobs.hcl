job "docker-example1_compose-up-for2VM" {
  type = "batch"
  namespace = "group2"
  # Ограничение по имени ноды (если нвыавыавыававыаужно)fdsfsеееdfsdfdsfsdf
  constraint {
    attribute = "${node.class}"
    value     = "docker1"
  }

  group "compose" {
    task "run-compose" {
      kill_timeout = "30s"
      driver = "raw_exec"  # Прямой запуск на хосте

      config {
        command = "/usr/bin/docker-compose" # Полный путь
        args = [
          "-f", "/nginx-compose/docker-compose.yml",
          "up"
        ]
      }
    }
  }
}
