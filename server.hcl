data_dir = "/opt/nomad/data"

tls {
  http = false

  rpc= true
  ca_file = "/root/nomad-certs/nomad-agent-ca.pem"
  cert_file = "/root/nomad-certs/global-server-nomad.pem"
  key_file  = "/root/nomad-certs/global-server-nomad-key.pem"
  verify_server_hostname = true
  verify_https_client    = true
}

acl {
  enabled = true
}

advertise {
  http = "45.86.183.34:4646"
  rpc = "45.86.183.34:4647"
  serf = "45.86.183.34:4648"
}

server {
  enabled = true
}



plugin "docker" {
  config {
    allow_privileged = true
    volumes {
      enabled = true
    }
  }
}
