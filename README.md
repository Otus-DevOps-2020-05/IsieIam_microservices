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
- Проверил запуск контейнера с моего образа с hub.docker.com:
```
docker run --name reddit -d -p 9292:9292 isieiam/otus-reddit:1.0
```

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
слегка доработанный скрипт dynamic inventory
get_inventory.py - который собирает инвентори из YC и группирует хосты по начальному имени инстанса до символа "-".
```
 - каталог packer - содержит в себе:
```
docker.json - описательная часть образа c provisioner packer_docker.yml
variables.json.example - пример переменных
```

 - каталог terraform - содержит в себе:
```
main.tf - упрощенное создание инстансов с требуемым парамтером на кол-во VM
файлы взятые с первого ДЗ по терраформу :)
variables.tf
output.tf
```

Для запуска:
- из каталога infra: packer build -var-file packer/variables.json packer/docker.json
- смотрим id образа: yc compute image list и вставляем ее в terraform.tvars
- в каталоге infra/terrafrom: terraform apply
- и из каталога infra/ansible: ansible-playbook ./playbooks/start_dockerc.yml

</details>


<details>
<summary>Домашнее задание к лекции №18 (Docker образы. Микросервисы)
</summary>

### Задание:

 - Разбит Monolith на 3 микросервиса в Docker
 - docker файлы прогнаны через web lint-сервис: https://hadolint.github.io/hadolint/ что увидел поправил, за исключением версий пакетов у apt :)
 - Сервисы запущены на YC через docker-machine и проверена работоспособность
 - Оптимизированы(удалены лишние команды, схлопнуты часть слоев, подчищены временные файлы, кешы, удалены ненужные пакеты) образы на базе предложенных начальных образов (за исключением post - там вроде уже особо некуда)
 - к mongo подключен volume, проверено сохранение данных при рестарте контейнера.

### Задание со * №1:

>Запустите контейнеры с другими сетевыми алиасами

>Адреса для взаимодействия контейнеров задаются через ENV - переменные внутри Dockerfile 'ов

>При запуске контейнеров ( docker run ) задайте им переменные окружения соответствующие новым сетевым алиасам, не пересоздавая образ

>Проверьте работоспособность сервиса

Контейнеры запустить можно так:
```
docker run -d --network=reddit --network-alias=post_db_n --network-alias=comment_db_n mongo:latest
docker run -d --network=reddit --network-alias=post_n --env POST_DATABASE_HOST=post_db_n isieiam/post:1.0
docker run -d --network=reddit --network-alias=comment_n --env COMMENT_DATABASE_HOST=comment_db_n isieiam/comment:1.0
docker run -d --network=reddit -p 9292:9292 --env COMMENT_SERVICE_HOST=comment_n --env POST_SERVICE_HOST=post_n isieiam/ui:1.0
```

т.е. поменялись alias и переопределились env переменные на новые alias

### Задание со * №2:

>Попробуйте собрать образ на основе Alpine Linux
>Придумайте еще способы уменьшить размер образа
>Можете реализовать как только для UI сервиса, так и для остальных ( post , comment )
>Все оптимизации проводите в Dockerfile сервиса. Дополнительные варианты решения уменьшения размера образов можете оформить в виде файла Dockerfile.<цифра> в папке сервиса

ui и comment переведены на ruby-alpine образ (не самый актуальный, т.к. версия bundle нужна старая по requirements) и дополнительно часть слоев схлопнута.

Общий принцип - все что добавляет "байты" в слое, желательно в этом же слое и подчищать :)

Созданы Dockerfile.1 для ui и comment и результат примерно следующий:
- версии 1.0/2.0 - это оптимизация на базе дефолтного начального образа
- версии 1.0u/2.0u - это образ alpine + оптимизация по слоям с очисткой

```
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
isieiam/comment     1.0u                0076875e1a3b        4 seconds ago        70.4MB
isieiam/comment     1.0                 8b2ed232ac1b        About a minute ago   737MB
isieiam/ui          2.0u                0c3d3cc120f8        23 minutes ago       72.5MB
isieiam/ui          2.0                 f4ebe5fe7d37        24 minutes ago       199MB
isieiam/ui          1.0                 60566ef44aef        2 hours ago          760MB
isieiam/post        1.0                 26eea89db2fd        2 hours ago          110MB
```

- проверено что приложение после манипуляций все еще работает.
- для билда использовать(для памяти):

```
docker build -t isieiam/post:1.0 ./post-py
docker build -t isieiam/comment:1.0u ./comment
docker build -t isieiam/ui:2.0u ./ui
```

- для запуска использовать:

```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post isieiam/post:1.0
docker run -d --network=reddit --network-alias=comment isieiam/comment:1.0u
docker run -d --network=reddit -p 9292:9292 isieiam/ui:2.0u
```

</details>
