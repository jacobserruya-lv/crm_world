import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import getContact from '@salesforce/apex/icx_Client360_API.getContact';

import { ToastError } from 'c/utils';







export default class Icx_dreamAccountClient extends LightningElement {
    @track accountId;
    @track account;
    @track clientKeyInfo;
    @track errMessage;
    @track isLoading = true;




    // CHN_Visibility = true;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.accountId = currentPageReference.state?.c__accountId;

        }
    }

    connectedCallback() {

        this.getContact();


    }

    getContact() {
        getContact({ dreamId: this.accountId })
            .then(result => {

                if (!result.account) {
                    this.account = undefined;
                    this.clientKeyInfo = undefined;

                    console.error('error API getcontact :', result);
                    let error = result;
                    const errorJSON = JSON.parse(error.message);

                    if (errorJSON.statusCode == '404') {

                        this.errMessage = 'Sorry this record doesn\'t exist. Please contact your administrator if the error persiste.';
                    }
                    else if (errorJSON.statusCode == '403') {
                        this.errMessage = 'Sorry, you don\'t have access to this record.'
                    }
                    else {
                       // this.errMessage = 'Sorry, an error occured, please try again later.'

                        ToastError(errorJSON.errorMessage, this);
                    }
                }
                else {

                    this.account = result.account;
                    this.clientKeyInfo = result.clientKeyInfo.item;
                    this.errMessage = undefined;

                }


            })
            .catch(error => {
                console.error('error getcontact :', error);
                this.account = undefined;
                this.clientKeyInfo = undefined;
               // this.errMessage = 'Sorry, an error occured, please try again later.'

                ToastError(error, this);

            })
            .finally(() => {
                this.isLoading = false;

            });
    }






}