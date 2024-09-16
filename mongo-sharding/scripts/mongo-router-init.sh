#!/bin/bash

echo "Starting replica set initialize"

until mongosh --host localhost --eval "print(\"Waited for connection\")"
do
    sleep 2
done
echo "Connection finished"
echo "Creating replica set"

sh.addShard( "shard1/localhost:27018");
sh.addShard( "shard2/localhost:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

echo "Replica set created"
