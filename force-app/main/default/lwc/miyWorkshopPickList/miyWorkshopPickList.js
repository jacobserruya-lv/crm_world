import { LightningElement, api } from 'lwc';

import WORKSHOP_LIST from '@salesforce/schema/ProductCatalogue__c.Workshop__c';

export default class LwcGetRecordId extends LightningElement {
    @api firmOrder;
    @api creationStatus;
    fields = [WORKSHOP_LIST];
    
    connectedCallback(){
        let creationStatusCheck = this.firmOrder.Creation_Status__c;
        creationStatusCheck === 'Order to Check/Validate' ? this.creationStatus = true : this.creationStatus = false;
    }
}