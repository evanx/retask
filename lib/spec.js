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
        },
        loggerLevel: {
            description: 'the logging level',
            default: 'info',
            options: ['debug', 'warn', 'error']
        }
    },
    development: {
        loggerLevel: 'debug'
    },
    test: {
        loggerLevel: 'debug'
    }
}
