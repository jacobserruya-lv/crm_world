import { NavigationMixin } from 'lightning/navigation';

/**
 * @param {Boolean} openInNewWindow 
 */
function openLink(url, openInNewWindow) {
    if(openInNewWindow) {
        window.open(url, '_blank');
    }
    else{
        location.href = url;
    }
}

/**
* @param {String} redirectUri
*/
function redirectTo(redirectUri) {
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__webPage',
        attributes: { url: redirectUri }
    })
    .then(url => {
        location.href = url;
    });
}

/**
* @return {Boolean}
*/
function isMobileDevice() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Windows Phone/gi.test(navigator.userAgent);
}

/**
* @param {Object} queryParams
* @returns {Boolean}
*/
function shouldRedirectToLvApp(queryParams) {
    return isMobileDevice()
    && !queryParams.hasOwnProperty('skip')
    && queryParams.hasOwnProperty('cid')
    && queryParams.origin !== 'lvapp'
    && (queryParams.hasOwnProperty('utm_campaign') || queryParams.hasOwnProperty('campaign'));
}

/**
* @param {String} documentCookies
* @param {String} cookieName
* @returns {String}
*/
function getCookie(documentCookies, cookieName) {
    const name = cookieName + "=";
    const cDecoded = decodeURIComponent(documentCookies);
    const cArr = cDecoded.split('; ');
    let result;
    cArr.forEach(val => {
        if (val.indexOf(name) === 0) {
            result = val.substring(name.length);
        }
    })
    return result || '';
}

export {
    redirectTo,
    shouldRedirectToLvApp,
    openLink,
    getCookie,
    isMobileDevice
}