import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';

import getActionReasons from '@salesforce/apex/OrderActionReasonService.getByAction';
import {getRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import RMS_ID_FIELD from '@salesforce/schema/User.RMS_ID__c';
import WWEMPLOYEENUMBER_FIELD from '@salesforce/schema/User.WWEmployeeNumber__c';

import actionRefund from '@salesforce/apex/Account_OrderDetailsControllerLC.sendActionRefund';

export default class Icx_orderActionRefund extends LightningModal {
    @api content;
    @api orderdetailsapi; // Order__c.orderNumber__c
    @api products; // list of product to display
    @api orderaction; // [{ label: 'Exchange', value: 'exchange' }, { label: 'Return', value: 'return' }, ...] 
    
    @track userId = USER_ID;
    
    isLoading = false;
    wwemployeeid;
    reasons;

    @wire(getRecord, {
        recordId: "$userId",
        fields: [NAME_FIELD, RMS_ID_FIELD, WWEMPLOYEENUMBER_FIELD]
      }) wireuser({error, data}) {
          console.log('JGU-icx_orderHighlightPanel-@wire (getRecord User - data) : '+JSON.stringify(data));
          // console.log('JGU-@wire (getRecord User - error) : '+JSON.stringify(error));
          if (error) {
            this.errorUser = error ; 
          } else if (data) {
              this.wwemployeeid = data.fields.WWEmployeeNumber__c.value;
          }
      }

    @wire(getActionReasons, {action : '$orderaction.value'})
      wiredgetActionReasons({ error, data }) {
          let options = [];
          if(data) {
              for(let i =0; i < data.length; i++) {
                  let option = {label: data[i].MasterLabel, value: data[i].Reason_Code__c};
                  options.push(option);
              }
              
          }
          else if (error) {
  
          }
          console.log('reasons:'+options);
          this.reasons = options;
      }

    handleSelectAll(event) {
        console.log('SelecteAll');
        const tiles = this.template.querySelectorAll('c-icx_order-action-refund-tile');
            
        for (let i = 0; i < tiles.length; i++) {
            console.log('tiles[i]:'+tiles[i]);
            tiles[i].setCheckedValue(event.target.checked);
        }
    }

    handleCancel() {
        this.close('cancel');
    }

    async handleSave() {
        this.isLoading = true;
        this.disableClose = true;

        var tiles = this.template.querySelectorAll('c-icx_order-action-refund-tile');
        let isOk = false;

        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            element.reportValidity();
        });

        // For each products
        for (let i = 0; i < tiles.length; i++) {
            let jsonRecord;
            // if the product is selected
            if (tiles[i].isChecked) {                
                console.log('icx_orderActionRefund - amount:' +tiles[i].amount);
                console.log('icx_orderActionRefund - methodSelected:' +tiles[i].methodSelected);
                console.log('icx_orderActionRefund - reasonSelected:' +tiles[i].reasonSelected);
                isOk = ( (tiles[i].methodSelected != null) && (tiles[i].reasonSelected != null) );
                console.log('icx_orderActionRefund - isOk:' +isOk);
                console.log('icx_orderActionRefund - reason.Id:' + tiles[i].product?.reason.Id)
            }
        }   
        

        if (isOk){
            var jsonResponse = [];

            // For each product selected
            for (let i=0; i<tiles.length; i++) {
                if (tiles[i].isChecked) {     
                   let productToRefund =  tiles[i];
                
                    await actionRefund({
                        amount : parseFloat(+tiles[i].amount),
                        paymentMethod : tiles[i].methodSelected,
                        employeeId : this.wwemployeeid,
                        orderNumber : this.orderdetailsapi.order_id,
                        orderAction : this.orderaction.value,
                        reasonCode : tiles[i].reasonSelected,
                        shippingId :tiles[i].product?.reason.Id,
                        shippingNumber: tiles[i].product?.request_id
                    })
                    .then(result => {           
                        console.log('JGU-result OK: '+JSON.stringify(result));
                        jsonResponse.push(result);
                    })
                    .catch(error => {
                        console.log('JGU-result Error: '+JSON.stringify(error));
                        jsonResponse.push(error);
                    });
                }
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