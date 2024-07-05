import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import sendAction from '@salesforce/apex/Account_OrderDetailsControllerLC.sendAction';

export default class Icx_orderActionApproveRejectPMA extends LightningModal {
    @api content;
    @api orderdetailsapi; // Order__c.orderNumber__c
    @api products; // list of product to display
    @api orderaction; // [{ label: 'Exchange', value: 'exchange' }, { label: 'Return', value: 'return' }, ...] 
    
    isLoading = false;
    @track selectedaction = '';

    get options() {
        return [
            { label: 'Approve', value: 'confirm_manual_review' },
            { label: 'Reject', value: 'cancel' }
        ];
    }
    handleRadioChange(event) {
        const selectedOption = event.detail.value;
        this.selectedaction = selectedOption;
    }

    handleCancel() {
        this.close('cancel');
    }

    async handleSave() {
        this.isLoading = true;
        this.disableClose = true;

        let isOk = true;   
        
        isOk = (this.selectedaction != null) && (this.selectedaction != '');

        if (isOk){
            var jsonResponse = [];
            var bodyToSend;
            // For each product selected
            for (let i=0; i<this.products.length; i++) {
                let productToApproveRefusePMA =  this.products[i];            

                bodyToSend  = {
                    requesting_system: 'ICONICS',
                    id: productToApproveRefusePMA.request_id,
                    line_number: parseInt(productToApproveRefusePMA.line_number),
                    item_id: productToApproveRefusePMA.item_id,
                    action_message: '',
                    action: this.selectedaction
                }

                console.log('Icx_orderActionApproveRejectPMA-bodyToSend'+bodyToSend);
                console.log('Icx_orderActionApproveRejectPMA-bodyToSend'+JSON.stringify(bodyToSend));

                await sendAction({
                    body : bodyToSend,
                    shippingId: productToApproveRefusePMA.reason.Id
                })
                .then(result => {           
                    console.log('Icx_orderActionApproveRejectPMA-result OK: '+JSON.stringify(result));
                    jsonResponse.push(result);
                })
                .catch(error => {
                    console.log('Icx_orderActionApproveRejectPMA-result Error: '+JSON.stringify(error.body.message));
                    let response = {
                        "status": "error",
                        "message": JSON.stringify(error.body.message)
                    };

                    jsonResponse.push(response);
                });
            }

            this.isLoading = false;
            this.disableClose = false;

            this.close(jsonResponse);
        }
        else {            
            this.isLoading = false;
            this.disableClose = false;
        }
    }
}