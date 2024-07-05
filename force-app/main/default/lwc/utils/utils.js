import {
    api,
    LightningElement,
    track,
    wire
} from 'lwc';
import USER_ID from '@salesforce/user/Id';
import LOCALE from '@salesforce/i18n/locale';


import getAuthorizationProfiles from '@salesforce/apex/ICX_Client360_SF.getAuthorizationProfiles';
import getUserProfileId from '@salesforce/apex/ICX_Client360_SF.getUserProfileId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';




    








 
 
 



const events = {};

/**
 * Registers a callback for an event
 * @param {string} eventName - Name of the event to listen for.
 * @param {function} callback - Function to invoke when said event is fired.
 * @param {object} thisArg - The value to be passed as the this parameter to the callback function is bound.
 */
const registerListener = (eventName, callback, thisArg) => {

    if (!events[eventName]) {
        events[eventName] = [];
    }

    const duplicate = events[eventName].find(listener => {
        return listener.callback === callback && listener.thisArg === thisArg;
    });

    if (!duplicate) {
        events[eventName].push({
            callback,
            thisArg
        });
    }
};

/**
 * Unregisters a callback for an event
 * @param {string} eventName - Name of the event to unregister from.
 * @param {function} callback - Function to unregister.
 * @param {object} thisArg - The value to be passed as the this parameter to the callback function is bound.
 */
const unregisterListener = (eventName, callback, thisArg) => {
    if (events[eventName]) {
        events[eventName] = events[eventName].filter(
            listener =>
            listener.callback !== callback || listener.thisArg !== thisArg
        );
    }
};

/**
 * Unregisters all event listeners bound to an object.
 * @param {object} thisArg - All the callbacks bound to this object will be removed.
 */
const unregisterAllListeners = thisArg => {
    Object.keys(events).forEach(eventName => {
        events[eventName] = events[eventName].filter(
            listener => listener.thisArg !== thisArg
        );
    });
};

/**
 * Fires an event to listeners.
 * @param {object} pageRef - Reference of the page that represents the event scope.
 * @param {string} eventName - Name of the event to fire.
 * @param {*} payload - Payload of the event to fire.
 */
const fireEvent = (pageRef, eventName, payload) => {
    if (events[eventName]) {
        const listeners = events[eventName];
        listeners.forEach(listener => {
            try {
                listener.callback.call(listener.thisArg, payload);
            } catch (error) {
                // fail silently
            }
        });
    }
};

const profilesCheckout = async (objectName) => {

    let authProfile;
   await getAuthorizationProfiles({userId: USER_ID,objectName:objectName})
            .then(result => {
                console.log(' utils profile autho result :', result);
                authProfile =result;
              
            })
            .catch(error => {
                console.log(' error utils:' + error);
            });

    return JSON.stringify(authProfile);
}

 const getUserProfileIdSF = async() =>
{
    let profileId;
    await getUserProfileId({userId:USER_ID})
    .then(res=>{
        console.log(' utils profile autho result',res)
        profileId = res;
    })
    .catch(error => {
        console.log(' error profileId:' + error);
    });

    return profileId;
}


const invokeWorkspaceAPI = (methodName, methodArgs) => {
    return new Promise((resolve, reject) => {
        const apiEvent = new CustomEvent("internalapievent", {
            bubbles: true,
            composed: true,
            cancelable: false,
            detail: {
                category: "workspaceAPI",
                methodName: methodName,
                methodArgs: methodArgs,
                callback: (err, response) => {
                    if (err) {

                        return reject(err);
                    } else {
                        return resolve(response);
                    }
                }
            }
        });

        window.dispatchEvent(apiEvent);
    });
}

const join = (dateToFormat, myFormat, separator) => {
    const format = (m) => {
        let f = new Intl.DateTimeFormat('en', m);
        return f.format(dateToFormat);
    }
    return myFormat.map(format).join(separator);
}

const sortData = (dataToOrder, fieldname, direction) => {
    let parseData = JSON.parse(JSON.stringify(dataToOrder));
    // Return the value stored in the field
    let keyValue = (a) => {
        return a[fieldname];
    };
    // cheking reverse direction
    let isReverse = direction === 'asc' ? 1 : -1;
    // sorting data
    parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; // handling null values
        y = keyValue(y) ? keyValue(y) : '';
        // sorting values based on direction
        return isReverse * ((x > y) - (y > x));
    });

    return dataToOrder = parseData;
}

const isEmpty = (str) => {
    return (!str || 0 === str.length);
}

const getGuidId = () => {
    let s4 = () => {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    }
    //return id of format 'aaaaaaaa'-'aaaa'-'aaaa'-'aaaa'-'aaaaaaaaaaaa'
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
}

const ToastError = (error,component) => {

    const evt = new ShowToastEvent({
        title: 'ERROR : ' + error,
        variant: 'error',
    });
    component.dispatchEvent(evt);
}



const dateFormat = (date) => {
    return date.split('T')[0];
}

const dateFormat2 = (year, month, day) => {
    //month is define from 0 for jenuary to 11 for december
    return new Date(year, month-1,day).toLocaleDateString(LOCALE);
}

export {
    registerListener,
    unregisterListener,
    unregisterAllListeners,
    fireEvent,
    invokeWorkspaceAPI,
    join,
    sortData,
    isEmpty,
    getUserProfileIdSF,
    profilesCheckout,
    getGuidId,
    ToastError,
    dateFormat,
    dateFormat2

};