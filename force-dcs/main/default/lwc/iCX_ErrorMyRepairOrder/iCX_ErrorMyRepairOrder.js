import { LightningElement,wire,api} from 'lwc';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';
import MyRepairError from '@salesforce/schema/CareService__c.MyRepair_Error__c';


export default class ICX_ErrorMyRepairOrder extends LightningElement {
    
    @api recordId;
    @wire(getRecord, {
		recordId: "$recordId",
		fields: [MyRepairError]
	})
	currentRecord;

    get errorMessage(){
        return getFieldValue(this.currentRecord.data, MyRepairError)
    }
}