import { LightningElement, api, wire, track } from 'lwc';


import getContactInformation from '@salesforce/apex/icx_Client360_API.getContactInformation';

import { CurrentPageReference } from 'lightning/navigation';
import { ToastError } from 'c/utils';


export default class Icx_dreamClientInformation extends LightningElement {




    clientInformationPart1;
    clientInformationPart2;
    eventGiftPart1;
    eventGiftPart2;
    address1Part1;
    address1Part2;
    address2Part1;
    address2Part2;
    otherContactInformationPart1;
    otherContactInformationPart2;
    @track isLoading = true;
    @track accountId;

    moreInformation;
    isAccountKeyInformation = false;
    cellClass = "large_cell slds-hide";

    isDataLoaded;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.accountId = currentPageReference.state?.c__accountId;

        }
    }

    connectedCallback() {
        getContactInformation({ dreamId: this.accountId })
            .then(result => {
                if (result && !result.message) {
                    this.moreInformation = result;
                    console.log('moreInformation :', this.moreInformation);
                    this.clientInformationPart1 = this.moreInformation.clientInformation.slice(0, parseInt((this.moreInformation.clientInformation.length - 1) / 2, 10) + 1);
                    this.clientInformationPart2 = this.moreInformation.clientInformation.slice(parseInt((this.moreInformation.clientInformation.length - 1) / 2, 10) + 1, this.moreInformation.clientInformation.length);

                    this.eventGiftPart1 = this.moreInformation.eventGift.slice(0, parseInt((this.moreInformation.eventGift.length - 1) / 2, 10) + 1);
                    this.eventGiftPart2 = this.moreInformation.eventGift.slice(parseInt((this.moreInformation.eventGift.length - 1) / 2, 10) + 1, this.moreInformation.eventGift.length);

                    this.address1Part1 = this.moreInformation.address1.slice(0, parseInt((this.moreInformation.address1.length - 1) / 2, 10) + 1);
                    this.address1Part2 = this.moreInformation.address1.slice(parseInt((this.moreInformation.address1.length - 1) / 2, 10) + 1, this.moreInformation.address1.length);

                    this.address2Part1 = this.moreInformation.address2.slice(0, parseInt((this.moreInformation.address2.length - 1) / 2, 10) + 1);
                    this.address2Part2 = this.moreInformation.address2.slice(parseInt((this.moreInformation.address2.length - 1) / 2, 10) + 1, this.moreInformation.address2.length);

                    this.otherContactInformationPart1 = this.moreInformation.otherContactInformation.slice(0, parseInt((this.moreInformation.otherContactInformation.length - 1) / 2, 10) + 1);
                    this.otherContactInformationPart2 = this.moreInformation.otherContactInformation.slice(parseInt((this.moreInformation.otherContactInformation.length - 1) / 2, 10) + 1, this.moreInformation.otherContactInformation.length);

                    this.error = undefined;
                    this.isLoading = false;

                } else {
                    const error = result;
                    console.error('error purchases :', error);
                    const errorJSON = JSON.parse(error.message);
                    this.errorPurchases = errorJSON.errorMessage;
                    ToastError(this.errorPurchases, this);
                }

            })
            .catch(error => {
                this.error = error;
                this.moreInformation = undefined;

                console.error('error get client info :', error);

                ToastError(error.body?.message, this);


            });





    }



}