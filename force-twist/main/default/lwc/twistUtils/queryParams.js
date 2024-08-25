class QueryParam {
    /**
     * @param {String} name
     * @param {Boolean} mandatory
     */
    constructor(name, mandatory) {
        this.name = name;
        this.mandatory = mandatory;
    }
}

class MandatoryQueryParam extends QueryParam {
    /**
     * @param {String} name
     */
    constructor(name) {
        super(name, true);
    }
}

class OptionalQueryParam extends QueryParam {
    /**
     * @param {String} name
     */
    constructor(name) {
        super(name, false);
    }
}

const twistQueryParams = {
    login: [
        new MandatoryQueryParam('langCountry'),
        new MandatoryQueryParam('origin'),
        new MandatoryQueryParam('state'),
        new MandatoryQueryParam('code-challenge'),
        new MandatoryQueryParam('redirect-uri'),
        new MandatoryQueryParam('client-id'),
        new OptionalQueryParam('dispatchCountry'),
        new OptionalQueryParam('404Log'),
        new OptionalQueryParam('utm_campaign'),
        new OptionalQueryParam('cid')
    ],
    forgotPassword: [
        new MandatoryQueryParam('langCountry'),
        new MandatoryQueryParam('origin'),
        new MandatoryQueryParam('state'),
        new MandatoryQueryParam('code-challenge'),
        new MandatoryQueryParam('redirect-uri'),
        new MandatoryQueryParam('client-id'),
        new OptionalQueryParam('sessionInfo'),
        new OptionalQueryParam('dispatchCountry'),
        new OptionalQueryParam('token-invalid-error-message')

    ],
    alternativeLogin: [
        new MandatoryQueryParam('langCountry'),
        new MandatoryQueryParam('origin'),
        new MandatoryQueryParam('state'),
        new MandatoryQueryParam('code-challenge'), //codeChallenge
        new MandatoryQueryParam('redirect-uri'), //redirectUri
        new MandatoryQueryParam('client-id'), //clientId
        new OptionalQueryParam('sessionInfo'),
        new OptionalQueryParam('dispatchCountry')
    ],
    resetPassword: [
        new MandatoryQueryParam('langCountry'),
        new MandatoryQueryParam('origin'),
        new OptionalQueryParam('token'),
        new OptionalQueryParam('state'),
        new MandatoryQueryParam('client-id'),
        new OptionalQueryParam('code-challenge'),
        new MandatoryQueryParam('redirect-uri'),
        new OptionalQueryParam('dispatchCountry')
    ],
    accountCreation: [
        new MandatoryQueryParam('langCountry'),
        new MandatoryQueryParam('origin'),
        new MandatoryQueryParam('state'),
        new MandatoryQueryParam('code-challenge'),
        new MandatoryQueryParam('redirect-uri'),
        new MandatoryQueryParam('client-id'),
        new OptionalQueryParam('cid'),
        new OptionalQueryParam('dispatchCountry'),
        new OptionalQueryParam('404Log'),
        new OptionalQueryParam('social_id'),
        new OptionalQueryParam('utm_campaign')
    ],
    error404: [
        new MandatoryQueryParam('langCountry'),
        new MandatoryQueryParam('origin'),
        new MandatoryQueryParam('client-id'),
        new OptionalQueryParam('dispatchCountry'),
        new OptionalQueryParam('404Log')
    ]
}

/**
 * @param {Object} queryParams
 * @param {Array} mandatoryParams
 * @returns {Boolean}
 */
function doParamsSetIncludeAllMandatoryParams(queryParams, mandatoryParams) {
    return areThereMultipleParamsSets(mandatoryParams)
        ? mandatoryParams.some(paramSet => doParamsSetIncludeAllMandatoryParams(queryParams, paramSet))
        : mandatoryParams.every(param => queryParams.hasOwnProperty(param));
}

/**
 * @param {String} pageName
 * @return {Boolean}
 */
function doesPageNameExist(pageName) {
    return Object.keys(twistQueryParams).includes(pageName);
}

/**
 * @param {Object} queryParams
 * @return {Object|null} returns null if one mandatory params of the child component is missing in queryParams
 */
function extractMainChildComponentQueryParams(queryParams) {
    const pageName = queryParams.page;
    if (!doesPageNameExist(pageName)) {
        console.error(`Unknown page name "${pageName}"`);
        return null;
    }

    const mandatoryParams = getMandatoryParams(pageName);
    if (!doParamsSetIncludeAllMandatoryParams(queryParams, mandatoryParams)) {
        console.error('At least one mandatory param is missing');
        console.error('queryParams', JSON.parse(JSON.stringify(queryParams)));
        console.error('mandatoryParams', mandatoryParams);
        return null;
    }

    const result = {};
    const allParams =  twistQueryParams[pageName].map(o => o.name);
    allParams.forEach(param => result[param] = queryParams[param]);
    return result;
}
/**
 * @param {String} pageName
 * @return {Array}
 */
function getMandatoryParams(pageName) {
    const params = twistQueryParams[pageName];
    return areThereMultipleParamsSets(params)
        ? params.map(paramsSet => paramsSet.map(queryParam => (queryParam.mandatory ? queryParam.name : null)).filter(paramName => paramName !== null))
        : params.map(queryParam => (queryParam.mandatory ? queryParam.name : null)).filter(paramName => paramName !== null);
}

/**
 * @param {Array} params
 * @return {Boolean}
 */
function areThereMultipleParamsSets(params) {
    return Array.isArray(params[0]);
}

export { extractMainChildComponentQueryParams }