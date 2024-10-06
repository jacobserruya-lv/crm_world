import { LightningElement, api } from "lwc";
import { FlowNavigationNextEvent } from 'lightning/flowSupport';


export default class CSC_Request_Or_Escalation extends LightningElement {
    
     _recordId;
     displayFlow = true;
     isShowModal =true;

    @api
    set recordId(value) {
        this._recordId = value;
        console.log('Display here the value of request Id', this._recordId);
    }

    get recordId() {
        return this._recordId;
    }

    get inputVariables() {
        return [
            {
                name: "recordId",
                type: "String",
                value: this.recordId,
            },
        ];
    }

    handleFlowStatusChange(event) {
         console.log('handleFlowStatusChange', event.target.value);
         this.displayFlow = true;
         this.isShowModal = true;
    }


    connectedCallback() {
        console.log('Display here the value of request Id', this.recordId);
    }

    
    hideModalBox() {  
        this.isShowModal = false;
    }

}