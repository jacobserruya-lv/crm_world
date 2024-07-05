/**
* @param {Promise[]} promises
* @param {Array} promisesResult
* @return {Promise}
*/
async function syncPromises(promises, promisesResult) {
    promisesResult = promisesResult || [];
    if (!promises.length) {
        return promisesResult;
    }
    const currentPromise = promises.shift();
    const result = await currentPromise;
    promisesResult.push(result)
    return syncPromises(promises, promisesResult);
}

/**
* @deprecated
* @description Thanks to the ES 2018 version of "for" and combining with "await", processes an array of Promises sequentially
* @param {Promise[]} promises
* @returns {Promise}
*/
const resolveSequentially = (...promises) => new Promise((resolve, reject) => {
    (async () => {
        const result = [];
        for (const promise of promises) {
            try {
                result.push(await promise);
            }
            catch (error) {
                reject(error);
            }
        }
        resolve(result);
    })();
})

export { syncPromises }