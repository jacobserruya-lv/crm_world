import { LightningElement } from 'lwc';

import getSFAgentAccessToken from '@salesforce/apex/ICX_TWIST_OOB.getSFAgentAccessToken';
import getOOBEndpoint from '@salesforce/apex/ICX_TWIST_OOB.getOOBEndpoint';
import getUserLocal from '@salesforce/apex/ICX_TWIST_OOB.getUserLocal';
import getUserCountryIsoCode2ToUse from '@salesforce/apex/ICX_TWIST_OOB.getUserCountryIsoCode2ToUse';

import getPayloadLocal from '@salesforce/apex/ICX_TWIST_OOB.getPayloadLocal';
import IsIdentityUser from '@salesforce/apex/ICX_TWIST_OOB.IsIdentityUser';
import activateIdentityUser from '@salesforce/apex/ICX_TWIST_OOB.activateIdentityUser';

import hasClientelingExceptionPermission from '@salesforce/customPermission/ICX_Clienteling_Exception';


const fetchOOB = async (accountId, dreamId, countryIso2Code) =>
    {

        console.log('icx_oob_utils . fetchOOB');
        console.log('icx_oob_utils . accountId:'+accountId);
        console.log('icx_oob_utils . dreamId:'+dreamId);
        console.log('icx_oob_utils . countryIso2Code:'+countryIso2Code);
    let payload;
    let calloutURI;
    let calloutURIJWT;

    let returnValue;

    try {
        // 1.1 - Retrieve : - Token
        //                  - OOB EndPoint details
        //                  - User Local
        //                  - user identity details
        let [sfAgentAccessToken, endpoint, userLocal, payloadLocal, userCountryIsocode2, userIdentity ] = await Promise.all([
            getSFAgentAccessToken(),
            getOOBEndpoint({countryIso2Code : countryIso2Code}),
            getUserLocal({countryIso2Code : countryIso2Code}),
            getPayloadLocal(),
            getUserCountryIsoCode2ToUse(),
            IsIdentityUser({recordId: accountId})
        ]).catch((error)=>{
            console.error('await Promise.all error : ' + error.message);
            throw error;
        });
        

        // 1.2 - Retrieve Payload to send AND callout URI
        if (!userIdentity) {
            payload = {
                "sfid_agent_access_token": sfAgentAccessToken,
                "account_id": accountId?accountId:"",
                "dream_id": dreamId?dreamId:"",
                "userCountryIso2": userCountryIsocode2,
                "csc_allowClientelingException":hasClientelingExceptionCustomPermission()==true ? true: false

            }
            calloutURI = endpoint.Endpoint__c+'/agent/'+userLocal+'/guest';
        } 
        else if (!userIdentity.IsActive)
        {
            await activateIdentityUser({recordId:accountId})
            .then((response)=>
            {
                userIdentity = response;
            })
            .catch((error)=>{
                
                console.error('Activate identity user error : ', error);
                return(getReturn(null, error))
            });
        }
        if(userIdentity && userIdentity.IsActive) {
            payload = 
            {
                "user_id": userIdentity?userIdentity.Id:null,
                "username": userIdentity?userIdentity.Username:null,
                "sfid_agent_access_token": sfAgentAccessToken,
                "locale": payloadLocal,
                "userCountryIso2": userCountryIsocode2,
                "csc_allowClientelingException":hasClientelingExceptionCustomPermission()==true ? true: false
            }        
            calloutURI = endpoint.Endpoint__c+'/agent/'+userLocal+'/login';
        }

        calloutURIJWT = endpoint.Endpoint__c+'/agent/'+userLocal+'/jwt';

        console.log('oob init- payload :'+JSON.stringify(payload));
        console.log('oob init- calloutURI :'+calloutURI);
        console.log('oob init- calloutURIJWT :'+calloutURIJWT);

        
        let fetchOOBRes =  fetchUtils('POST', endpoint, calloutURI, payload);
        await fetchOOBRes.then((response) => {            
            console.log('oob init- fetchOOBRes start:');
            console.log('oob init- fetchOOBRes start - response:'+response);
            if(response.status==200) {                
                returnValue = (getReturn('200', null));
            }
            else {
                returnValue = (getReturn(response.status, 'An error occured, please try again later'));
            }            
            })
            .catch((error)=>{
                console.error('oob error : ', error);
                throw error;
            });

            if(returnValue.status==200)
            {                
                let fetchOOJWTBRes =  fetchUtils('POST', endpoint, calloutURIJWT, payload);
                await fetchOOJWTBRes.then((response) => {             
                    console.log('oob init- calloutURIJWT start:');
                    console.log('oob init- calloutURIJWT start:'+response);
                    if(response.status==200)
                    {
                        returnValue = (getReturn('200', null));
                    }
                    else{
                        returnValue = (getReturn(response.status, 'An error occured, please try again later'));
                    }                        
                })
                .catch((error)=>{
                    console.error('oobjwt error : ', error);
                    throw error;
                });
            }
        

        return returnValue;

        }
    catch(error) {
        console.error(error.message);
        return(getReturn(null, error.message))
        };
    }

const fetchUtils =  (method, endpoint, callout, payload) =>
    {
        return fetch(callout, {
            method: method,
            contentType:"application/json; charset=utf-8",
            body: JSON.stringify(payload),

            headers: {
                'Content-Type': 'application/json',
                'Accept-Language' : '*',
                'client_id':endpoint.ClientId__c,
                'client_secret':endpoint.ClientSecret__c,
        
                },
                credentials: 'include'


        });
    }

function getReturn(status, errorMessage) {
    let returnValue = {
        'status':status,
        'errorMessage': errorMessage
      }
    console.log('getReturn : '+JSON.stringify(returnValue));
    return returnValue;
}

function hasClientelingExceptionCustomPermission()
{
    return hasClientelingExceptionPermission;
}

export {
    fetchOOB
}