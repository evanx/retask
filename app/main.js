
module.exports = async context => {
    const {config, logger, client} = context;
    Object.assign(global, context);
    try {
        while (true) {
            const [key, snapshot] = await multiExecAsync(client, multi => {
                multi.brpoplpush(config.inq, config.busyq, 1);
            });
            if (!key) {
                if (config.exit === 'empty') {
                    break;
                }
                continue;
            }
            if (key === 'none') {
                break;
            }
            try {

    } catch (err) {
       throw err;
    } finally {
    }
};
