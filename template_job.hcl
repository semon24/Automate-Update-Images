job "docker-compose-up-for2VM" {
  type        = "service"

  # Ограничение по имени ноды (если нужно)
  constraint {
    attribute = "${node.class}"
    value     = "docker1"
  }

  group "compose" {
    task "run-compose" {
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