#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "Этот скрипт должен быть запущен с правами root" >&2
  exit 1
fi

read -p "Введите имя нового пользователя: " username

useradd -m -s /bin/bash "$username"

passwd "$username"

usermod -aG sudo "$username"

USER_HOME="/home/$username"
CERT_DIR="/etc/nomad.d/nomad-certs"
CONFIG_DIR="/etc/nomad.d/nomad-config"
SERVICE_FILE="/etc/systemd/system"
DATA_NOMAD="/var/lib/nomad"

mkdir -p "$CERT_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$SERVICE_FILE"
mkdir -p "$DATA_NOMAD/"{data,plugins}
mkdir -p "/var/lib/alloc_mounts"

chown -R root:"$username" "/var/lib/alloc_mounts"
chmod -R 770 "/var/lib/alloc_mounts"

chown -R root:"$username" "$CERT_DIR" "$CONFIG_DIR"
chmod -R 770 "$CERT_DIR" "$CONFIG_DIR"

chown -R root:"$username" "$DATA_NOMAD"
chmod -R 775 "$DATA_NOMAD"

chown -R root:"$username" "$SERVICE_FILE"
chmod -R 775 "$SERVICE_FILE"

# Копируем сертификаты (предполагаем, что они лежат рядом со скриптом)
CERTS=("global-client-nomad.pem" "global-client-nomad-key.pem" "nomad-agent-ca.pem")
for cert in "${CERTS[@]}"; do
  if [ -f "$cert" ]; then
    cp "$cert" "$CERT_DIR/"
    chown "$username:$username" "$CERT_DIR/$cert"
    chmod 700 "$CERT_DIR/$cert"
    echo "[+] Сертификат $cert скопирован в $CERT_DIR"
  else
    echo "[-] Внимание: файл сертификата $cert не найден!" >&2
  fi
done


cat > "client.hcl" <<EOF
data_dir = "$DATA_NOMAD"

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

  ca_file   = "/etc/nomad.d/nomad-certs/nomad-agent-ca.pem"
  cert_file = "/etc/nomad.d/nomad-certs/global-client-nomad.pem"
  key_file  = "/etc/nomad.d/nomad-certs/global-client-nomad-key.pem"
}
EOF


if [ -f "client.hcl" ]; then
  cp "client.hcl" "$CONFIG_DIR/"
  chown "$username:$username" "$CONFIG_DIR/client.hcl"
  chmod 774 "$CONFIG_DIR/client.hcl"
  echo "[+] Конфигурационный файл client.hcl скопирован в $CONFIG_DIR"
else
  echo "[-] Внимание: файл client.hcl не найден!" >&2
fi




cat > "client.service" <<EOF
[Unit]
Description=Nomad Client
After=network.target

[Service]
User=$username
Group=$username
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.d/nomad-config/client.hcl
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65536
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


if [ -f "client.service" ]; then
    echo "[+] Копируем service-файл..."
    cp "client.service" "$SERVICE_FILE/"
    chown "$username:$username" "$SERVICE_FILE/client.service"
    chmod 774 "$SERVICE_FILE/client.service"
fi

echo "Пользователь $username создан и добавлен в группу sudo (имеет права root через sudo)"


echo "Идет установка Docker..."
sudo apt update
sudo apt install curl software-properties-common ca-certificates apt-transport-https -y
wget -O- https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable"| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce -y

echo "Добавляем пользователя в группу docker"

sudo usermod -aG docker $username

echo "Установка Nomad..."
chmod +x nomad
mv nomad /usr/local/bin/
nomad  --version

echo "  su - $username"
echo "смена пользователя"

