import { LightningElement, api, track,wire } from 'lwc';
import OOBVisibleByCountry from '@salesforce/apex/ICX_TWIST_OOB.OOBVisibleByCountry';
import getRedirectionURL from '@salesforce/apex/ICX_TWIST_OOB.getRedirectionURL';
import getRedirectionEndpoint from '@salesforce/apex/ICX_TWIST_OOB.getRedirectionEndpoint';

import hasOOBPermission from '@salesforce/customPermission/ICX_OOB';
import { fetchOOB  } from 'c/icx_oob_utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class Icx_oobButton extends LightningElement {
    @api label;
    @api accountId;
    @track isFetching;
    @api btnClass;
    @api dreamId;
    @track isButtonVisibleByCountry=false;


 

  


    @wire(OOBVisibleByCountry)
    wiredOOBVisibleByCountry({ error, data }) {
        if (data) {
            this.isButtonVisibleByCountry = data;
        } 
    }

   
    hasOOBPermission() {
        return hasOOBPermission;
      }

    get isButtonVisible()
    {
        return this.isButtonVisibleByCountry && this.hasOOBPermission();
    }


     async OOB_onclick(){

        this.isFetching = true;

        let [redirectionURL, localURL] = await Promise.all([
            getRedirectionURL(),
            getRedirectionEndpoint({landingPage : '/homepage'})
        ]).catch((error)=>{
            console.error('await Promise.all error : ' + error.message);
            throw error;
        });

        fetchOOB(this.accountId, this.dreamId).then((returnValue) => {
            if (returnValue.status==200 && redirectionURL && localURL)
            {

                window.open(redirectionURL+"/"+localURL, "Order On Behalf"); 

            }
            else{
                this.ToastError(returnValue.errorMessage);
            }
            this.isFetching = false; 

          });
    }

    OOB_onclick2(){
        this.isFetching = true;
        OOBFetch(this.accountId, this.dreamId).then(() => {
            this.isFetching = false; 

          });
    }

    ToastError (error)  {

        const evt = new ShowToastEvent({
            title: 'ERROR : ' + error,
            variant: 'error',
        });
        dispatchEvent(evt);
    }


}