import { LightningElement,wire,api} from 'lwc';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';
import MetapackError from '@salesforce/schema/CareService__c.Metapack_Error__c';

export default class ICX_ErrorShippingLabel extends LightningElement {
    @api recordId;
    @wire(getRecord, {
		recordId: "$recordId",
		fields: [MetapackError]
	})
	currentRecord;

    get errorMessage(){
        return getFieldValue(this.currentRecord.data, MetapackError)
    }
}