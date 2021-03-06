# retask

Redis-based dispatcher to parallel task pipelines.

<img src="https://raw.githubusercontent.com/evanx/retask/master/docs/readme/main.png"/>

## Use case

We require a persistent pubsub setup via Redis lists, e.g. to support parallel task queues.

Some "publisher" pushes a message onto a Redis list. This service pops each message, and pushes it onto multiple target lists, one for each subscriber. Each subscriber pops messages from their own dedicated Redis list.

This replaces a previously implemented solution for the same use case: https://github.com/evanx/mpush-redis

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
        popTimeout: {
            description: 'the timeout for brpoplpush',
            unit: 'seconds',
            default: 10
        },
        inq: {
            description: 'the source queue',
        },
        busyq: {
            description: 'the pending queue for brpoplpush',
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

#### Isolated test network

First we create the isolated network:
```shell
docker network create -d bridge retask-network
```

#### Disposable Redis instance

Then the Redis container on that network:
```
redisContainer=`docker run --network=retask-network \
    --name $redisName -d redis`
redisHost=`docker inspect $redisContainer |
    grep '"IPAddress":' | tail -1 | sed 's/.*"\([0-9\.]*\)",/\1/'`
```
where we parse its IP number into `redisHost`

#### Setup test data

We push an item to the input queue:
```
redis-cli -h $redisHost lpush in:q '46664'
```

#### Build and run

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
  -e busyq=busy:q \
  -e outqs=out1:q,out2:q \
  retask
```

#### Verify results

```
evan@dijkstra:~/retask$ sh test/demo.sh
...
+ redis-cli -h $redisHost lrange out1:q 0 -1
1) 46664
+ redis-cli -h $redisHost lrange out2:q 0 -1
1) 46664
```

#### Teardown

```
docker rm -f retask-redis
docker network rm retask-network
```

## Implementation

See `app/main.js`
```javascript
while (true) {
    const item = await client.brpoplpushAsync(config.inq, config.busyq, config.popTimeout);
    logger.debug('pop', config.inq, config.busyq, config.popTimeout, item);
    if (!item) {
        break;
    }
    if (item === 'exit') {
        await client.lrem(config.busyq, 1, item);
        break;
    }
    await multiExecAsync(client, multi => {
        config.outqs.forEach(outq => multi.lpush(outq, item));
        multi.lrem(config.busyq, 1, item);
    });
}
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
