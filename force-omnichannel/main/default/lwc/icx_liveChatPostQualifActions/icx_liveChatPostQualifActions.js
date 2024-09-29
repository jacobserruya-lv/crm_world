import { LightningElement, track, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';

export default class Icx_liveChatePostQualifAction extends NavigationMixin(LightningElement) {
    //@api recordId;
    @track isNewPODOpen = false;
    @track isNewOEOpen = false;

    _recordId;
    @api set recordId(value)
    {
      this._recordId = value;
      console.log('Display here the value of request Id',this._recordId);
    }


    get recordId() {
      return this._recordId;
  }

    handleOnClickNewPOD() {
        this.isNewPODOpen = true;
        console.log(this.recordId)
    }

    closeNewPOD() {
        this.isNewPODOpen = false;
    }

    handleOnClickNewOE() {
        this.isNewOEOpen = true;
        console.log(this.recordId)
    }

    closeNewOE() {
        this.isNewOEOpen = false;
    }

    
    get inputVariables() {
        return [
          {
            // Match with the input variable name declared in the flow.
            name: "recordId",
            type: "String",
            // Initial value to send to the flow input.
            value: this.recordId,
          },

        ];
      }

      handleStatusChange(event) {
        if (event.detail.status === 'FINISHED' || event.detail.status === 'FINISHED_SCREEN') {
            this.isNewOEOpen = false; // Close the modal when the flow finishes
            this.isNewPODOpen = false;
        }
    }

    openFlowInNewTab() {
        // Construct the URL for the flow
        const flowApiName = 'ICXNewOE';
        const inputVariables = JSON.stringify(this.inputVariables); // Assuming inputVariables is a property in your component
  
        // Navigate to the flow in a new tab
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/flow/${flowApiName}?flowInputVariables=${encodeURIComponent(inputVariables)}`,
                target: '_blank'
            }
        });
    }

}