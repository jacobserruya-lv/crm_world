import { LightningElement,api,track, wire} from 'lwc';
// Lightning Message Service and message channels
import { publish, subscribe, MessageContext } from 'lightning/messageService';
//import PRODUCTS_FILTERED_MESSAGE from '@salesforce/messageChannel/ProductsFiltered__c';
import ORDER_REFRESH_MESSAGE from '@salesforce/messageChannel/OrderRefresh__c';
import sendAction from '@salesforce/apex/Account_OrderDetailsControllerLC.sendAction';
import getOrderDetails from '@salesforce/apex/Account_OrderDetailsControllerLC.getOrderDetailsTwist';

import getBackOfficeUser from '@salesforce/apex/Account_OrderDetailsControllerLC.backOfficeUser2';
import getReasonPicklist from '@salesforce/apex/Account_OrderDetailsControllerLC.reasonPicklist';
import getActionPicklist from '@salesforce/apex/Account_OrderDetailsControllerLC.actionPicklist';


import hasServeInLastPermission from '@salesforce/customPermission/ICX_ServeInLast';
import hasServeInPriorityPermission from '@salesforce/customPermission/ICX_ServeInPriority';
import hasReAttemptAllocationPermission from '@salesforce/customPermission/ICX_ReAttemptAllocation';
import hasOrderShippingCancelPermission from '@salesforce/customPermission/ICX_OrderShippingCancel';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Icx_fulfillmentActions extends LightningElement {  
    @api
    get product() {
        return this._orderShipping;
    }
    set product(value) {
        // console.log('JGU-product: '+JSON.stringify(value));
        this.selectedaction = null;
        this.selectedreason = null;
        
        this._orderShipping = value;
        getActionPicklist()
        .then(result => {
            var action = [];
            for(let key in result){ 
                if(result.hasOwnProperty(key)){
                    action.push({'value':key , 'label':result[key]});
                }
            } 
            this.allActionValues = action;
            console.log('icx_fulfillmentActions - allActionValues: '+ JSON.stringify(this.allActionValues));
            
            
            var availableAction = this.product.available_actions;
            // if(availableAction!=null && this.backOfficeUser ){
            //     this.actionValues = this.allActionValues.filter(element=> availableAction.includes(element.value));
                
            // }else{
            //     this.actionValues = this.allActionValues.filter(element=>element.value == 'cancel' && availableAction.includes(element.value));
            // }    

            this.setFulfilmentAction(availableAction);
          

            

        })
        .then(result => {
            this.isLoading = false;
        }
        )

    }

    get hasServeInLastPermission() {
        return hasServeInLastPermission;
      }

      get hasServeInPriorityPermission() {
        return hasServeInPriorityPermission;
      }

      get hasReAttemptAllocationPermission() {
        return hasReAttemptAllocationPermission;
      }

      get hasOrderShippingCancelPermission() {
        return hasOrderShippingCancelPermission;
      }
  

    

    reasonValues;  
    @track reason = {label:'' ,value:''};  

    @track isLoading = false;

    allActionValues;

    backOfficeUser = false ;
    @track actionValues = {label:'' ,value:''};

    @track selectedaction = '';
    @track selectedreason = '';

    connectedCallback() { 

        getBackOfficeUser()
        .then(result => {
            this.backOfficeUser = result;
            console.log('icx_fulfillmentActions - backofficeuser: '+this.backOfficeUser);
            return getReasonPicklist();
        })
        .then(result => {
            this.reasonValues = result;
            console.log('icx_fulfillmentActions - reasonValues: '+this.reasonValues);
            return getActionPicklist();
            })
        .then(result => {
            var action = [];
            for(let key in result){ 
                if(result.hasOwnProperty(key)){
                    action.push({'value':key , 'label':result[key]});
                }
            } 
            this.allActionValues = action;
            console.log('icx_fulfillmentActions - allActionValues: '+ JSON.stringify(this.allActionValues));
            
            
            var availableAction = this.product.available_actions;
            // if(availableAction!=null && this.backOfficeUser ){
            //     this.actionValues = this.allActionValues.filter(element=> availableAction.includes(element.value));
                
            // }else{
            //     this.actionValues = this.allActionValues.filter(element=>element.value == 'cancel' && availableAction.includes(element.value));
            // }

            //this.setFulfilmentAction(availableAction);

        })
    }

    get actionName() {
        return 'action' + this.product.shippingNumber ;
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

    onclick(event){
        this.isLoading = !this.isLoading;
    }

    handleClick(event){
        var orderline,selectedLabel, selectedAction ,ordershippingId ,ordershipping ,bodyTosend ;
        event.preventDefault();
        event.stopPropagation()

        this.isLoading = true;

        event.target.disabled = true; 
        this.template.querySelector('[data-id="cmb-reason"]').disabled = true;
        //this.template.querySelector('[data-id="rdo-action"]').disabled = true;


        orderline = this.product;
        ordershippingId = orderline.shippingNumber;
        selectedLabel = this.selectedreason;
        this.selectedreason = null;
        selectedAction = this.selectedaction;        
        this.selectedaction = null;

        console.log('icx_fulfillmentActions - before reason');
        ordershipping = orderline.reason ? orderline.reason.Id : null; // salesforce id 
        console.log('icx_fulfillmentActions - after reason');

        // this.orderRefresh();

        // /!\ When the 'cancel' is asked by the client we have to send 'cancel_by_customer' instead of 'cancel'
        if (selectedAction == 'cancel') {
            if (selectedLabel == 'Client Cancelled') {
                selectedAction = 'cancel_by_customer';
            }
        }

        bodyTosend = {
            id: ordershippingId.split('-')[0],
            requesting_system: 'ICONICS',
            item_id: orderline.SKU,
            line_number: parseInt(ordershippingId.split('-')[1]),
            action_message: selectedLabel,
            action: selectedAction
        };  
        console.log('JGU-bodyToSend: '+JSON.stringify(bodyTosend));
        // debugger;    
        sendAction({
            body : bodyTosend,
            shippingId :ordershipping 
        })
        .then(result => {           
            
            console.log('JGU-result: '+JSON.stringify(result));
            //this.getOrderDetailsApex();
            this.orderRefresh();
            this.showToast(result);           
            this.template.querySelector('[data-id="cmb-reason"]').disabled = false;  
            this.template.querySelector('[data-id="cmb-reason"]').value = false;        
            this.template.querySelector('[data-id="btn-submit"]').disabled = true;
        })
        .catch(error => {
            this.showToast(JSON.parse(error.body.message));
            this.isLoading = false;
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


     /** Load context for Lightning Messaging Service */
     @wire(MessageContext) messageContext;

    orderRefresh(){
        console.log('orderRefresh() - OrderShipping : '+this.product.reason.Id);
         // Published ProductSelected message
         publish(this.messageContext, ORDER_REFRESH_MESSAGE, {
            orderId: this.product.reason?.Id
         });
    }


    setFulfilmentAction(availableAction)
    {

         this.actionValues = {label:'' ,value:''};

            if(availableAction!=null) 
            {
             
                if(this.hasServeInLastPermission)
                {
                    this.actionValues = this.actionValues.label==""? this.allActionValues.filter(element=>element.value == 'deprioritize' && availableAction.includes(element.value)): this.actionValues.concat(this.allActionValues.filter(element=>element.value == 'deprioritize' && availableAction.includes(element.value)));
                }
                if(this.hasServeInPriorityPermission)
                {
                    this.actionValues = this.actionValues.label==""? this.allActionValues.filter(element=>element.value == 'prioritize' && availableAction.includes(element.value)): this.actionValues.concat(this.allActionValues.filter(element=>element.value == 'prioritize' && availableAction.includes(element.value)));
                    
                }
                if(this.hasReAttemptAllocationPermission)
                {
                    this.actionValues = this.actionValues.label==""? this.allActionValues.filter(element=>element.value == 'process_atp' && availableAction.includes(element.value)): this.actionValues.concat(this.allActionValues.filter(element=>element.value == 'process_atp' && availableAction.includes(element.value)));
                    
                }
                if(this.hasOrderShippingCancelPermission)
                {
                
                this.actionValues = this.actionValues.label==""? this.allActionValues.filter(element=>element.value == 'cancel' && availableAction.includes(element.value)): this.actionValues.concat(this.allActionValues.filter(element=>element.value == 'cancel' && availableAction.includes(element.value)));
                }
            }
                
            
            
            // else{
            //     this.actionValues = this.allActionValues.filter(element=>element.value == 'cancel' && availableAction.includes(element.value));
            // }    
 

    }
    // refreshTab(result){
    //     debugger;
    //     const refreshShipping = new CustomEvent('finish',{
    //         detail: { result },
    //     });
    //     this.dispatchEvent(refreshShipping);    
    // }

    // getOrderDetailsApex(){

    //     getOrderDetails({
    //         orderId : this.orderNumber,
    //         isRecordId :false 
    //     })
    //     .then(result => {           
            
    //         if(result.StatusCode == '200'){
    //           // result.orderLines.forEach(element => element.statusHistory.reverse());
    //             this.refreshTab( result); 
    //         }
    //     })
    //     .catch(error => {
    //         this.showToast(JSON.parse(error));
    //     });
    // }
}