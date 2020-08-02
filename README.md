# IsieIam_microservices
IsieIam microservices repository

[![Build Status](https://travis-ci.com/Otus-DevOps-2020-05/IsieIam_microservices.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2020-05/IsieIam_microservices)

<details>
<summary>Домашнее задание к лекции №17 (Docker контейнеры. Docker под капотом)
</summary>

### Предзадание:
>В репозитории должна быть настроена интеграция с travis-ci по аналогии с репозиторием infra.

- Добавлен pre-commit, шаблон pullrequest, переиспользован gitignore с пред заданий.
- Сделана интеграция c travis, настроены уведомления по commit и build-ам в slack.

### Задание:

- Установлен Docker, docker-compose, docker-machine
- Запущен контейнер с Helloworld
- Задание с docker images:
>Для сдачи домашнего задания, необходимо сохранить вывод команды docker images в файл docker-monolith/docker-1.log и закоммитить в репозиторий

Сделано.
- Пробежал по командам которые не встречал еще в работе, а так для памяти шпаргалка по докеру: https://habr.com/ru/company/flant/blog/336654/
- Опробован в работе docker-machine:
```
СОздаем произвольныйх хост в YC:
yc compute instance create \
  --name docker-host \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/appuser.pub

Сетапим на уделнную машину все что нужно docker-machine:
docker-machine create \
  --driver generic \
  --generic-ip-address=84.201.175.120 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/appuser.pub\
  docker-host

Переключаемся на докер демон у удаленного хоста:
eval $(docker-machine env docker-host)
Так вернуться на локальный
eval $(docker-machine env --unset)

Все удалить:
docker-machine rm docker-host
yc compute instance delete docker-host
```
- Создан докер файл и необходимоые файлы для установки monolith
- На основе созданного образа, запущен контейнер в YC, проверена работоспособность.
- Зарегистрировался в https://hub.docker.com запушил туда созданный образ с monolith

### Задание со * №1:
>На основе вывода команд:
```
$ docker inspect <u_container_id>
$ docker inspect <u_image_id>
```
>объясните чем отличается контейнер от образа. Объяснение допишите в файл dockermonolith/docker-1.log

Сделано, пояснение занесено в файл.

### Задание со * №2:

>Теперь, когда есть готовый образ с приложением, можно автоматизировать поднятие нескольких инстансов в Yandex Cloud, установку на них докера и запуск там образа /otus-reddit:1.0
>Нужно реализовать в виде прототипа в директории /docker-monolith/infra/
>Поднятие инстансов с помощью Terraform, их количество задается переменной;
>Несколько плейбуков Ansible с использованием динамического инвентори для установки докера и запуска там образа приложения;
>Шаблон пакера, который делает образ с уже установленным Docker;

В каталоге docker-monolith/infra созданы 3 каталога
 - каталог ansible - содержит в себе:
```
два playbook:
packer_docker.yml - отвечает за создание packer-ом образа с установленным docker и python-docker.
start_dockerc.yml - отвечает за запуск нужного контейнера
слегка доработанный скрипт dynakic inventory
get_inventory.py - который собирает инвентори из YC и группирует хосты по начальному имени инстанса до символа "-".
```
 - каталог packer - содержит в себе:
```
docker.json - описательная часть образа c provisioner packer_docker.yml
variables.json.example - пример переменных
```

 - каталог terraform - содержит в себе:
```
main.tf - упрощенное создание инстансов с требуемым парамтером на кол-во
файлы взятые с первого ДЗ по терраформу :)
variables.tf
output.tf
```

Для запуска:
- из каталога infra packer build -var-file packer/variables.json packer/docker.json
- смотрим id образа: yc compute image list и вставляем ее в terraform.tvars
- в каталоге infra/terrafrom: terraform apply
- и из каталога infra/ansible ansible-playbook ./playbooks/start_dockerc.yml

</details>
