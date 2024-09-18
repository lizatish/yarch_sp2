#!/bin/sh

# Настраиваем сервер конфигурации
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({
    _id: "config_server",
    configsvr: true,
    members: [{
        _id: 0,
        host: "configSrv:27017"
    }]
});
EOF

# Настраиваем шард1
docker compose exec -T shard1_replica1 mongosh --port 27017 --quiet <<EOF
rs.initiate({
    _id: "shard1",
    members: [{
        _id: 0,
        host: "shard1_replica1:27017"
    },
    {
        _id: 1,
        host: "shard1_replica2:27017"
    },
    {
        _id: 2,
        host: "shard1_replica3:27017"
    }]
});
EOF

# Настраиваем шард2
docker compose exec -T shard2_replica1 mongosh --port 27017 --quiet <<EOF
rs.initiate({
    _id: "shard2",
    members: [{
        _id: 0,
        host: "shard2_replica1:27017"
    },
    {
        _id: 1,
        host: "shard2_replica2:27017"
    },
    {
        _id: 2,
        host: "shard2_replica3:27017"
    }]
});
EOF


# Настраиваем роутер1 и роутер2
docker compose exec -T router1 mongosh --port 27020 --quiet <<EOF
sh.addShard( "shard1/shard1_replica1:27017");
sh.addShard( "shard1/shard1_replica2:27017");
sh.addShard( "shard1/shard1_replica3:27017");
sh.addShard( "shard2/shard2_replica1:27017");
sh.addShard( "shard2/shard2_replica2:27017");
sh.addShard( "shard2/shard2_replica3:27017");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF

docker compose exec -T router2 mongosh --port 27021 --quiet <<EOF
sh.addShard( "shard1/shard1_replica1:27017");
sh.addShard( "shard1/shard1_replica2:27017");
sh.addShard( "shard1/shard1_replica3:27017");
sh.addShard( "shard2/shard2_replica1:27017");
sh.addShard( "shard2/shard2_replica2:27017");
sh.addShard( "shard2/shard2_replica3:27017");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF

# Проверяем работоспособность: заполняем оба роутера по 1000 документов
docker compose exec -T router1 mongosh --port 27020 --quiet <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
db.helloDoc.countDocuments()
EOF

docker compose exec -T router2 mongosh --port 27021 --quiet <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
db.helloDoc.countDocuments()
EOF
