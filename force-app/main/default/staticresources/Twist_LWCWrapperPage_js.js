const pageQueryParam2lwcName = {
    login: 'twistLoginWrapper',
    forgotPassword: 'twistForgotPasswordWrapper',
    resetPassword: 'twistResetPasswordWrapper',
    accountCreation: 'twistAccountCreationWrapper',
    alternativeLogin: 'twistAlternativeLoginWrapper',
    error404: 'twistError404Wrapper',
    testGoogleAnalytics: 'testGoogleAnalyticsWrapper'
};

/**
* @param {String} str
* @returns {String}
*/
const kebabCaseToCamelCase = str => str.replace(/-./g, c => c[1].toUpperCase());

/**
* @param {URL} url
* @returns {Object}
*/
const buildQueryParamsObject = url => {
    const oQueryParams = {};
    url.searchParams.forEach((value, key) => {
        oQueryParams[key] = value;
    });
    return oQueryParams;
}

/**
* @param {Object} oQueryParams
* @returns {Boolean}
*/
const isQueryParamsObjectValid = oQueryParams => {
    if (!Object.keys(oQueryParams).length) {
        console.error('Error: query params are missing');
        return false;
    }
    if (!oQueryParams.hasOwnProperty('page')) {
        console.error('Error: query param "page" is missing');
        return false;
    }
    if (!pageQueryParam2lwcName.hasOwnProperty(oQueryParams.page)) {
        console.error(`Error: page "${oQueryParams.page}" does not exist`);
        return false;
    }
    return true;
}

/**
* @param {String} page
* @returns {String}
*/
const getLwcName = page => pageQueryParam2lwcName[page];

const getCookie = name => {
    var value = "; " + document.cookie;
    var parts = value.split("; " + name + "=");
    if (parts.length == 2) {
        return parts.pop().split(";").shift();
    }
}

const loadScript = (src, async = true, type = "text/javascript") => {
    return new Promise((resolve, reject) => {
        try {
            const tag = document.createElement("script");
            const container = document.head || document.body;
            
            tag.type = type;
            tag.async = async;
            tag.src = src;
            
            tag.addEventListener("load", () => {
                resolve({ loaded: true, error: false });
            });
            
            tag.addEventListener("error", () => {
                reject({
                    loaded: false,
                    error: true,
                    message: `Failed to load script with src ${src}`
                });
            });
            
            container.prepend(tag);
        }
        catch (error) {
            reject(error);
        }
    });
};