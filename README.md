# retask

Redis-based dispatcher to parallel pipelines.

<img src="https://raw.githubusercontent.com/evanx/retask/master/docs/readme/main.png"/>

## Use case

## Config

See `config.js`
```javascript
module.exports = {
    description: 'Redis-based dispatcher to parallel pipelines.',
    required: {
        host: {
            description: 'the Redis host',
            default: 'localhost'
        },
        port: {
            description: 'the Redis port',
            default: 6379
        },
        inq: {
            description: 'the source queue',
        },
        outqs: {
            description: 'the target queues',
            elementType: 'string'
        }
    }
}
```

## Docker

You can build as follows:
```shell
docker build -t retask https://github.com/evanx/retask.git
```

See `test/demo.sh` https://github.com/evanx/retask/blob/master/test/demo.sh

Builds:
- isolated network `retask-network`
- isolated Redis instance named `retask-redis`
- this utility `evanx/retask`

First we create the isolated network:
```shell
docker network create -d bridge retask-network
```

Then the Redis container on that network:
```
redisContainer=`docker run --network=retask-network \
    --name $redisName -d redis`
redisHost=`docker inspect $redisContainer |
    grep '"IPAddress":' | tail -1 | sed 's/.*"\([0-9\.]*\)",/\1/'`
```
where we parse its IP number into `redisHost`

We push an item to the input queue:
```
redis-cli -h $redisHost lpush in:q '{"twitter": "@evanxsummers"}'
```

We build a container image for this service:
```
docker build -t retask https://github.com/evanx/retask.git
```

We interactively run the service on our test Redis container:
```
docker run --name retask-instance --rm -i \
  --network=retask-network \
  -e host=$redisHost \
  -e inq=in:q \
  -e outqs=out1:q,out2:q \
  retask
```
```
evan@dijkstra:~/retask$ sh test/demo.sh
...
+ redis-cli -h $redisHost lrange out1:q 0 -1
```


## Implementation

See `app/main.js`
```javascript

```

### Appication archetype

Incidently `app/index.js` uses the `redis-app-rpf` application archetype.
```
require('redis-app-rpf')(require('./spec'), require('./main'));
```
where we extract the `config` from `process.env` according to the `spec` and invoke our `main` function.

See https://github.com/evanx/redis-app-rpf.

This provides lifecycle boilerplate to reuse across similar applications.

<hr>
https://twitter.com/@evanxsummers
