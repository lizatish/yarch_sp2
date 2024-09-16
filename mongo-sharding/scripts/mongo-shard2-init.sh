#!/bin/bash
echo "Starting replica set initialize"

until mongosh --host localhost --eval "print(\"Waited for connection\")"
do
    sleep 2
done
echo "Connection finished"
echo "Creating replica set"
mongosh --port 27019 <<EOF
rs.initiate({
    _id: "shard2",
    members: [{
        _id: 1,
        host: "shard2:27019"
    }]
})
EOF

echo "Replica set created"

