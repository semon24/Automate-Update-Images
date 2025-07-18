job "docker-example1_compose-up-for2VM" {
  type = "batch"
  namespace = "group2"

  constraint {
    attribute = "${node.class}"
    value     = "docker1"
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
          "mv tmp/repo/group2/compose-file.yml /nginx-compose/"]
      }
    }
  }
}
