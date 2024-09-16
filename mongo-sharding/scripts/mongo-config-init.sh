#!/bin/bash

echo "Starting replica set initialize"

sleep 20

until mongosh --eval "print(\"Waited for connection\")"
do
    sleep 20
done
echo "Connection finished"
echo "Creating replica set"
mongosh --port 27017 <<EOF
rs.initiate({
    _id: "config_server",
    configsvr: true,
    members: [{
        _id: 0,
        host: "173.17.0.10:27017"
    }]
})
EOF
echo "Replica set created"


