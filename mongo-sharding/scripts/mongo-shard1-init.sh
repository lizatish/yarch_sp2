#!/bin/bash

echo "Starting replica set initialize"

until mongosh --host localhost --eval "print(\"Waited for connection\")"
do
    sleep 2
done
echo "Connection finished"
echo "Creating replica set"
mongosh --host localhost --port 27018 <<EOF
rs.initiate({
    _id: "shard1",
    members: [{
        _id: 0,
        host: "localhost:27018"
    }]
})
EOF

echo "Replica set created"



