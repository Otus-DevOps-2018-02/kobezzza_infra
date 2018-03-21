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
#### Дополнительное задание. Стартовый скрипт. (слайд 20)

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

#### Дополнительное задание. Правило файволла (слайд 21)

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
