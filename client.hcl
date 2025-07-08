data_dir = "/opt/nomad-client/data"


client {
  enabled = true
  servers = ["45.86.183.34:4647"]
}

acl {
  enabled = true
}

tls {
  http = true
  rpc  = true

  ca_file   = "/root/nomad-certs/nomad-agent-ca.pem"
  cert_file = "/root/nomad-certs/global-client-nomad.pem"
  key_file  = "/root/nomad-certs/global-client-nomad-key.pem"
}



