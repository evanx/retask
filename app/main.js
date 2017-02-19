
module.exports = async context => {
    const {config, logger, client} = context;
    Object.assign(global, context);
    try {
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
    } catch (err) {
       throw err;
    } finally {
    }
};
