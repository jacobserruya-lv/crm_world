import { LightningElement,api,track} from 'lwc';
import sendAction from '@salesforce/apex/Account_OrderDetailsControllerLC.sendAction';
import getOrderDetails from '@salesforce/apex/Account_OrderDetailsControllerLC.getOrderDetails';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Icx_kbrw_order_action extends LightningElement { 
    @api orderNumber;   
    @api orderDetails;   
    @api reasonValues;  
    @track reason = {label:'' ,value:''};  

    @api allActionValues;

    @api backOfficeUser = false ;
    @track actionValues = null; 

    selectedaction = ''
    selectedreason = '';

    connectedCallback() {
       
        var availableAction = this.orderDetails.availableActions;
        if (this.allActionValues != null) {
            if(availableAction!=null && this.backOfficeUser ){
                this.actionValues = this.allActionValues.filter(element=> availableAction.includes(element.value));

            } else {
                this.actionValues = this.allActionValues.filter(element=>element.value == 'cancel' && availableAction.includes(element.value));
            }      
        }
    }

    get actionName() {
        return 'action' + this.orderDetails.requestId ;
    }

    get actions() {
       return this.actionValues ;
    }

    get displayaction() {
        return this.actions.length > 0 ;
    }

    handleSelectedAction(event){
        var labelAction = event.target.options.find(opt => opt.value === event.detail.value).label;
        
        this.selectedaction = event.detail.value ;
        var getReason = this.reasonValues[labelAction] ;        
        var reass = [];

        if(getReason)   getReason.forEach(element => { reass.push({label:element ,value:element})});
        this.reason = reass;
      
        this.template.querySelector('[data-id="cmb-reason"]').disabled = false;
        this.template.querySelector('[data-id="cmb-reason"]').required = labelAction.includes('Undo') || labelAction.includes('re-attempt') ? false : true;
		this.template.querySelector('[data-id="btn-submit"]').disabled = labelAction.includes('Undo') || labelAction.includes('re-attempt') ? false : true;

    }

    handleSelectedReason(event){
        this.selectedreason = event.detail.value ;
        this.template.querySelector('[data-id="btn-submit"]').disabled = false;
    }

    handleClick(event){
        var orderline,selectedLabel ,ordershippingId ,ordershipping ,bodyTosend ;
        event.preventDefault();
        event.stopPropagation()

        event.target.disabled = true; 
        this.template.querySelector('[data-id="cmb-reason"]').disabled = true;
        this.template.querySelector('[data-id="rdo-action"]').disabled = true;


        orderline = this.orderDetails
        ordershippingId = orderline.requestId;
        selectedLabel = this.selectedreason; 
        ordershipping = orderline.reason ? orderline.reason.Id : null; // salesforce id 
      
        bodyTosend = {
            id: ordershippingId.split('-')[0],
            requesting_system: 'ICONICS',
            item_id: orderline.SKU,
            line_number: parseInt(ordershippingId.split('-')[1]),
            action_message: selectedLabel,
            action: this.selectedaction
        };  
        debugger;    
        sendAction({
            body : bodyTosend,
            shippingId :ordershipping 
        })
        .then(result => {           
            
           this.getOrderDetailsApex()
           this.showToast(result)
        })
        .catch(error => {
            this.showToast(JSON.parse(error.body.message));
        });
    }

    showToast(mess) {

        const evt = new ShowToastEvent({
            title: mess.status,
            message:mess.message,
            variant: mess.status,
            mode: 'pester'
        });
        this.dispatchEvent(evt);        
    }

    refreshTab(result){
        debugger;
        const refreshShipping = new CustomEvent('finish',{
            detail: { result },
        });
        this.dispatchEvent(refreshShipping);    
    }

    getOrderDetailsApex(){

        getOrderDetails({
            orderId : this.orderNumber,
            isRecordId :false 
        })
        .then(result => {           
            
            if(result.StatusCode == '200'){
              // result.orderLines.forEach(element => element.statusHistory.reverse());
                this.refreshTab( result); 
            }
        })
        .catch(error => {
            this.showToast(JSON.parse(error));
        });
    }






}