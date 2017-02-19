
module.exports = async context => {
    const {config, logger, client} = context;
    Object.assign(global, context);
    try {
    } catch (err) {
       throw err;
    } finally {
    }
};
