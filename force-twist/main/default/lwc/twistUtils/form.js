function clearFormErrrors(form) {
    for (const key of Object.keys(form)) {
        form[key].error = null;
    }
}

/**
* @param {Object} form
* @param {Object} response
*/
function updateFormErrors(form, response) {
    delete response.success;
    for (const key of Object.keys(response)) {
        form[key].error = response[key];
    }
}

/**
* @param {String} email
* @param {Boolean} allowPlusCharacter
* @return {Boolean}
*/
function isEmailValid(email, allowPlusCharacter) {
    const regex = allowPlusCharacter ? /^\s*\w+([\.\+-]\w+)*@\w+([\.-]\w+)*(\.\w{2,3})+\s*$/ : /^\s*\w+([\.-]\w+)*@\w+([\.-]\w+)*(\.\w{2,3})+\s*$/;
    return regex.test(email);
}

/**
 * @param {String} string
 * @return {Boolean}
 */
function hasHeightChars(string) {
    return string && string.length >= 8;
}

/**
 * @param {String} string
 * @return {Boolean}
 */
function hasDigit(string) {
    return /.*[0-9]+.*/g.test(string);
}

/**
 * @param {String} string
 * @return {Boolean}
 */
function hasUpperCaseLetter(string) {
    return /.*[A-Z]+.*/g.test(string);
}

/**
 * @param {String} string
 * @return {Boolean}
 */
function hasLowerCaseLetter(string) {
    return /.*[a-z]+.*/g.test(string);
}

/**
 * @param {String} string
 * @return {Boolean}
 */
function hasSpecialChar(string) {
    return /.*[!?#$&{}*+,-.:;<=>?@[\]^_|~]+.*/g.test(string);
}

/**
 * @param {String} password
 * @return {Boolean}
 */
function doesPasswordMatchStringPattern(password) {
    return hasHeightChars(password)
        && hasDigit(password)
        && hasUpperCaseLetter(password)
        && hasLowerCaseLetter(password)
        && hasSpecialChar(password);
}

/**
 * @param {String} birthdate
 * @param {Integer} legalAge
 * @return {Boolean}
 */
function hasLegalAge(birthdate, legalAge) {
    if (birthdate === undefined || !birthdate || !legalAge) { // Business rule: age restriction evaluated only if birthdate is filled and legal age is provided
        return true;
    }

    const dateNow = new Date();
    const dateOfBirth = new Date(birthdate);
    dateOfBirth.setFullYear(dateOfBirth.getFullYear() + legalAge);
    return dateOfBirth <= dateNow;
}

/**
 * @param {Element} fieldElement
 * @param {String} errorMessage
 */
function setFieldErrorMessage(fieldElement, errorMessage) {
    if (fieldElement) {
        fieldElement.setCustomValidity(errorMessage);
        fieldElement.reportValidity();
    }
}

/**
 * @param {Element} fieldElement
 */
function removeFieldErrorMessage(fieldElement) {
    setFieldErrorMessage(fieldElement, "");
}

function focusOnEmail(emailField) {
    emailField.focus();
}

export {
    clearFormErrrors,
    updateFormErrors,
    isEmailValid,
    hasHeightChars,
    hasDigit,
    setFieldErrorMessage,
    removeFieldErrorMessage,
    hasUpperCaseLetter,
    hasLowerCaseLetter,
    hasSpecialChar,
    doesPasswordMatchStringPattern,
    hasLegalAge,
    focusOnEmail
}