import { LightningElement, api } from "lwc";

export default class Icx_newOE extends LightningElement {
    _recordId;

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
         const flowFinishedEvent = new CustomEvent('flowfinish');
         if (event.detail.status === 'FINISHED' || event.detail.status === 'FINISHED_SCREEN') {
          this.dispatchEvent(flowFinishedEvent);
         }

    }


    connectedCallback() {
        console.log('Display here the value of request Id', this.recordId);
    }
    
}