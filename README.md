# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs

## Задание 2. Шардирование

### 1) Настраиваем сервер конфигурации.

Выполняем в терминале:
> docker exec -it configSrv mongosh --port 27017

Выполняем в контейнере:
> rs.initiate(
> {
_id : "config_server",
> configsvr: true,
> members: [
{ _id : 0, host : "configSrv:27017" }
]
> }
);
> exit

### 2) Настраиваем шард1 и шард2

Выполняем в терминале:
> docker exec -it shard1 mongosh --port 27018

Выполняем в контейнере:
> rs.initiate(
> {
_id : "shard1",
> members: [
{ _id : 0, host : "shard1:27018" },
// { _id : 1, host : "shard2:27019" }
]
> }
);
> exit

Выполняем в терминале:
> docker exec -it shard2 mongosh --port 27019

Выполняем в контейнере:

> rs.initiate(
> {
_id : "shard2",
> members: [
// { _id : 0, host : "shard1:27018" },
{ _id : 1, host : "shard2:27019" }
]
> }
);
> exit

### 3) Настраиваем роутер1 и роутер2

Выполняем в терминале:
> docker exec -it router1 mongosh --port 27020

Выполняем в контейнере:
> sh.addShard( "shard1/shard1:27018");
> sh.addShard( "shard2/shard2:27019");
> sh.enableSharding("somedb");
> sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
> exit

Выполняем в терминале:
> docker exec -it router2 mongosh --port 27021

Выполняем в контейнере:
> sh.addShard( "shard1/shard1:27018");
> sh.addShard( "shard2/shard2:27019");
> sh.enableSharding("somedb");
> sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
> exit

### 4) Проверяем работоспособность

Для этого зальем данные на роутеры и проверим, что данными заполняются оба шарда.
Выполняем в терминале:
> docker exec -it router1 mongosh --port 27020

Заполняем роутер1 1000 записей. Выполняем в контейнере:
> use somedb
> for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
> db.helloDoc.countDocuments()
> exit

Проверяем данные на первом шарде. Выполняем в терминале:
> docker exec -it shard1 mongosh --port 27018

Выполняем в контейнере:
> use somedb;
> db.helloDoc.countDocuments();
> exit

Выведенное число должен быть примерно равно размеру половины коллекции (±500).

Проверяем данные на втором шарде. Выполняем в терминале:
> docker exec -it shard2 mongosh --port 27019

Выполняем в контейнере:
> use somedb;
> db.helloDoc.countDocuments();
> exit

Выведенное число должен быть примерно равно размеру половины коллекции (±500).

Повторим все то же самое для второго роутера. Выполняем в терминале:
> docker exec -it router2 mongosh --port 27021

Заполняем роутер2 1000 записей. Выполняем в контейнере:
> use somedb
> for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
> db.helloDoc.countDocuments()
> exit

Проверяем данные на первом шарде. Выполняем в терминале:
> docker exec -it shard1 mongosh --port 27018

Выполняем в контейнере:
> use somedb;
> db.helloDoc.countDocuments();
> exit

Выведенное число должен быть примерно равно размеру половины коллекции (±1000).

Проверяем данные на втором шарде. Выполняем в терминале:
> docker exec -it shard2 mongosh --port 27019

Выполняем в контейнере:
> use somedb;
> db.helloDoc.countDocuments();
> exit

Выведенное число должен быть примерно равно размеру половины коллекции (±1000).
