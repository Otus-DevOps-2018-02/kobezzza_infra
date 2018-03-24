# kobezzza_infra

kobezzza Infra repository

## ДЗ №4
#### Самостоятельное задание (слайд 35)

Подключиться через хост bastion можно, например, такого вида командой:

```bash
ssh -i ~/.ssh/appuser -o ProxyCommand="ssh -i ~/.ssh/appuser -W %h:%p appuser@35.195.175.234" appuser@10.132.0.3
```

Для подключения простой командой вида `ssh someinternalhost` нужно воспользоваться возможностями файла конфигурации ssh.
Например, создать файл `~/.ssh/config` (если он еще не создан)
и добавить в него содержимое:

```bash
Host bastion
  Hostname 35.195.175.234
  User appuser
  IdentityFile ~/.ssh/appuser

Host someinternalhost
  Hostname 10.132.0.3
  User appuser
  IdentityFile ~/.ssh/appuser
  ProxyCommand ssh bastion -W %h:%p
```

#### Параметры для проверки:

bastion_IP = 35.195.175.234

someinternalhost_IP = 10.132.0.3

## ДЗ №5
#### Дополнительное задание. Стартовый скрипт (слайд 20)

```bash
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=./startup-script.sh
```

#### Дополнительное задание. Правило брандмауэра (слайд 21)

```bash
gcloud compute firewall-rules create default-puma-server\
   --allow=tcp:9292 \
   --description="Access puma server from external network"\
   --source-ranges=0.0.0.0/0\
   --target-tags=puma-server 
```

#### Параметры для проверки:

testapp_IP = 35.189.221.21

testapp_port = 9292

## ДЗ №6
#### Дополнительное задание. Immutable сервер (слайд 31)

**immutable.json**

```json
{
  "variables": {
    "project_id": null,
    "source_image_family": null,
    "machine_type": "f1-micro",
    "disk_size": "10",
    "disk_type": "pd-standard",
    "network": "default"
  },
  "builders": [{
    "type": "googlecompute",
    "project_id": "{{user `project_id`}}",
    "image_name": "reddit-full-{{timestamp}}",
    "image_family": "reddit-full",
    "image_description": "My awesome reddit application",
    "source_image_family": "{{user `source_image_family`}}",
    "disk_size": "{{user `disk_size`}}",
    "disk_type": "{{user `disk_type`}}",
    "network": "{{user `network`}}",
    "tags": ["puma-server"],
    "zone": "europe-west1-b",
    "ssh_username": "appuser",
    "machine_type": "{{user `machine_type`}}"
  }],
  "provisioners": [
    {
      "type": "shell",
      "script": "scripts/install_ruby.sh",
      "execute_command": "sudo {{.Path}}"
    },
    {
      "type": "shell",
      "script": "scripts/install_mongodb.sh",
      "execute_command": "sudo {{.Path}}"
    },
    {
      "type": "file",
      "source": "files/reddit.service",
      "destination": "/tmp/reddit.service"
    },
    {
      "type": "shell",
      "script": "scripts/deploy.sh",
      "execute_command": "sudo {{.Path}}"
    }
  ]
}
```

**systemd service**

```
[Unit]
Description=Reddit App
Requires=mongod.service
After=network.target mongod.service

[Service]
User=appuser
WorkingDirectory=/home/appuser/reddit
ExecStart=/usr/local/bin/puma -b tcp://0.0.0.0:9292
Restart=always

[Install]
WantedBy=multi-user.target
```

**deploy.sh**

```bash
#!/bin/bash

git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install

mv /tmp/reddit.service /etc/systemd/system/reddit.service
systemctl enable reddit
```

#### Дополнительное задание (слайд 32)

```bash
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family=reddit-full \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure
```

#### Параметры для проверки:

testapp_IP = 35.205.147.7

testapp_port = 9292
