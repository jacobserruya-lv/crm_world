/**
 * @description transforms 'c-twist-login' into 'TwistLogin'
 * @param {String} name
 * @returns {String}
 */
function lwcNameToCamelCase(name) {
    return name.replace(/^c-/, str => str[1].toUpperCase()).replace(/-./g, str => str[1].toUpperCase());
}

/**
 * @description Tests if string1 includes string2
 * @param {String} string1
 * @param {String} string2
 * @param {Boolean} ignoreCase
 * @return {Boolean}
 */
function includesString(string1, string2, ignoreCase) {
    if (string1 === undefined || string2 === undefined || !string1 || !string2) {
        return false;
    }
    ignoreCase = ignoreCase || true;
    if (ignoreCase) {
        string1 = string1.toLowerCase();
        string2 = string2.toLowerCase();
    }
    return string1.includes(string2);
}

export {
    lwcNameToCamelCase,
    includesString
};