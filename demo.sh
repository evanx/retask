
name='retask'
network="$name-network"
redisName="$name-redis"

removeContainers() {
    for name in $@
    do
      if docker ps -a -q -f "name=/$name" | grep '\w'
      then
        docker rm -f `docker ps -a -q -f "name=/$name"`
      fi
    done
}

removeNetwork() {
    if docker network ls -q -f name=^$network | grep '\w'
    then
      docker network rm $network
    fi
}

(
  removeContainers $redisName
  removeNetwork
  set -u -e -x
  sleep 1
  docker network create -d bridge retask-network
  redisContainer=`docker run --network=retask-network \
      --name $redisName -d redis`
  redisHost=`docker inspect $redisContainer |
      grep '"IPAddress":' | tail -1 | sed 's/.*"\([0-9\.]*\)",/\1/'`
  sleep 1
  redis-cli -h $redisHost lpush in:q '{"twitter": "@evanxsummers"}'
  redis-cli -h $redisHost keys '*'
  docker build -t retask https://github.com/evanx/retask.git
  docker run --name retask-instance --rm -i \
    --network=retask-network \
    -e host=$redisHost \
    -e inq=in:q \
    -e outqs=out1:q,out2:q \
    -e ttl=1 \
    retask
  sleep 2
  redis-cli -h $redisHost keys '*'
  docker rm -f $redisName
  docker network rm $network
)
