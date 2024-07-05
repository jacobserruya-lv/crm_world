import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

// Lightning Message Service and message channels
import { publish, MessageContext } from 'lightning/messageService';
import ORDER_REFRESH_MESSAGE from '@salesforce/messageChannel/OrderRefresh__c';
import hasOrderActionsVisibility from '@salesforce/customPermission/ICX_Order_Actions';
import hasOrderActionReturnVisibility from '@salesforce/customPermission/ICX_Order_Action_Return';
import hasOrderActionRefundShippingFeesVisibility from '@salesforce/customPermission/ICX_Order_Action_Refund_Shipping_Fees';
import hasOrderActionRefundVisibility from '@salesforce/customPermission/ICX_Order_Action_Refund';
import hasOrderActionExchangeVisibility from '@salesforce/customPermission/ICX_Order_Action_Exchange';
import hasOrderActionPreventExchangeVisibility from '@salesforce/customPermission/ICX_Order_Action_Prevent_Exchange';
import hasOrderActionDeclareNoShowCODVisibility from '@salesforce/customPermission/ICX_Order_Action_Declare_No_Show_COD';
import hasOrderActionDeclareFundReceptionVisibility from '@salesforce/customPermission/ICX_Order_Action_Declare_Fund_Reception';
import hasOrderActionAproveRejectPMAVisibility from '@salesforce/customPermission/ICX_Order_Action_Approve_Reject_PMA';

import MyModal from 'c/icx_orderActions';
import ModalDeclareFundReception from 'c/icx_orderActionDeclareFundReception';
import ModalRefund from 'c/icx_orderActionRefund';
import ModalRefundShippingFees from 'c/icx_orderActionRefundShippingFees';
import ModalApproveRejectPMA from 'c/icx_orderActionApproveRejectPMA';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ICX_Order_highlight_Panel_LWC extends NavigationMixin( LightningElement) {
    @track error;
    @api 
    get orderdetailsapi() {
      return this._orderdetailsapi;
    }
    set orderdetailsapi(value) {
      this._orderdetailsapi = value;
      console.log('First loading options:' + this.options());
      this.optionsToDisplay = this.options();
    }

    /** Load context for Lightning Messaging Service */
    @wire(MessageContext) messageContext;

    get hasOrderActionsVisibility() {
      // return isOrderActionsVisibility;
      return hasOrderActionsVisibility;
    }

    @track
    optionsToDisplay;
        
    // Retrieve the values available in the button "Order Actions"
    options() {
      //console.log('JGU-productsByOrderActions: '+JSON.stringify(this.orderdetailsapi));
      let productsByOrderActions = this.orderdetailsapi.productsByOrderActions;
      let productsByOrderActionsMap = new Map();
      // console.log('JGU-productsByOrderAction: '+JSON.stringify(productsByOrderAction));
      
      for (var key in productsByOrderActions) {
        // console.log('JGU-debug for '+key);
        productsByOrderActionsMap.set(key, productsByOrderActions[key]);
      }

      let orderActions = [
        { label: 'Change Shipping Address', value: 'changeShippingAddress', disabled: true, isTwist: true },
        { label: 'Other Payment method', value: 'otherPaymentMethod', disabled: true, isTwist: true },
        { label: 'Send New Payment Link', value: 'sendNewPaymentLink', disabled: true, isTwist: true },
        { label: 'Checkout', value: 'checkout', disabled: true, isTwist: true },
        { label: 'Declare Funds Reception', value: 'declareFundsReception', disabled: true, isTwist: true },
        { label: 'Declare No Show COD', value: 'declareNoShowCOD', disabled: true, isTwist: true },
        { label: 'Return', value: 'return', disabled: true, isTwist: true },
        { label: 'Exchange', value: 'exchange', disabled: true, isTwist: true },
        { label: 'Refund', value: 'refund', disabled: true, isTwist: true },
        { label: 'Refund Shipping Fees', value: 'refund_delivery_fees', disabled: true, isTwist: true },
        { label: 'Approve/Reject PMA', value: 'approveRejectPMA', disabled: true, isTwist: true }];

      // If the user is allowed to process "Order Actions"
      console.log('this.hasOrderActionsVisibility:'+this.hasOrderActionsVisibility);
      console.log('hasOrderActionsVisibility:'+hasOrderActionsVisibility);

      console.log('this.hasOrderActionReturnVisibility:'+this.hasOrderActionReturnVisibility);
      console.log('hasOrderActionReturnVisibility:'+hasOrderActionReturnVisibility);
      //if (this.hasOrderActionsVisibility) {
        // Loop over Order Actions
        for (let i=0; i<orderActions.length; i++) {
          // We don't process the Order Action, if the order action is dedicated to TWIST but the order is NOT TWIST
          if ( !(orderActions[i].isTwist && !this.orderdetailsapi.isTwist) ) {
            // Return
            if (hasOrderActionReturnVisibility && orderActions[i].value == 'return') {
              for(var j=0; j < this.orderdetailsapi.order_lines.length; j++) {
                if( this.orderdetailsapi.order_lines[j].isReturnAvailable ) {
                  orderActions[i].disabled = false;
                }
              }
            }
            // DECLARE NO SHOW - COD
            else if (hasOrderActionDeclareNoShowCODVisibility && orderActions[i].value == 'declareNoShowCOD') {
              for(var j=0; j < this.orderdetailsapi.order_lines.length; j++) {
                if( this.orderdetailsapi.order_lines[j].isDeclareNoShowCODAvailable ) {
                  orderActions[i].disabled = false;                  
                }
              }
            }
            // DECLARE FUNDS RECEPTION
            else if (hasOrderActionDeclareFundReceptionVisibility && orderActions[i].value == 'declareFundsReception') {
              for(var j=0; j < this.orderdetailsapi.order_lines.length; j++) {
                if( this.orderdetailsapi.order_lines[j].isDeclareFundsReceptionAvailable ) {
                  orderActions[i].disabled = false;
                }
              }
            }
            // DECLARE REFUND
            else if (hasOrderActionRefundVisibility && orderActions[i].value == 'refund') {
              for(var j=0; j < this.orderdetailsapi.order_lines.length; j++) {
                if( this.orderdetailsapi.order_lines[j].isRefundAvailable ) {              
                  orderActions[i].disabled = false;
                }
              }
            }
            // EXCHANGE
            else if (hasOrderActionExchangeVisibility && !hasOrderActionPreventExchangeVisibility && orderActions[i].value == 'exchange') {
              for(var j=0; j < this.orderdetailsapi.order_lines.length; j++) {
                if( this.orderdetailsapi.order_lines[j].isExchangeAvailable ) {
                  orderActions[i].disabled = false;
                }
              }
            }
            // APPROVE/REJECT PMA
            else if (hasOrderActionAproveRejectPMAVisibility && orderActions[i].value == 'approveRejectPMA') {
              for(var j=0; j < this.orderdetailsapi.order_lines.length; j++) {
                if( this.orderdetailsapi.order_lines[j].isApproveRejectPMAAvailable ) {
                  orderActions[i].disabled = false;
                }
              }
            }
            else if (productsByOrderActionsMap.has(orderActions[i].value)) {
              // REFUND DELIVERY FEES
              if (orderActions[i].value == 'refund_delivery_fees') {
                orderActions[i].disabled = !hasOrderActionRefundShippingFeesVisibility;
              }
              else {
                orderActions[i].disabled = false;
              }
            }
          }
        }
      console.log('First loading options: '+orderActions);
      return orderActions;
    }    

    async handleAction(event) {
      let orderdetailsapi = this.orderdetailsapi;

      let products = [];
      let orderActionResult = [];

      // ******************************************************************************************** //
      // TWIST-27416: Error message to be displayed if exchange is impossible due to missing Dream ID //
      // ******************************************************************************************** //
      if (event.detail.value == 'exchange' && orderdetailsapi.account.DREAMID__c == null) {
        let message = 'This client does not have a Dream ID. No exchange possible on this order for the moment. Please retry later';
        orderActionResult.push(JSON.parse('{"status":"info", "message":"' + message + '"}'));
      }
      else {
        // 
        for(var i=0; i < orderdetailsapi.order_lines.length; i++) {
          // *************** //
          // Action : RETURN //
          // *************** //
          if(event.detail.value == 'return') {
            if( orderdetailsapi.order_lines[i].isReturnAvailable ) {
              products.push(orderdetailsapi.order_lines[i]);
            }
          }
          // ******************************************* //
          // Action : DECLARE NO SHOW (CASH ON DELIVERY) //
          // ******************************************* //
          if(event.detail.value == 'declareNoShowCOD') {
            if( orderdetailsapi.order_lines[i].isDeclareNoShowCODAvailable ) {
              products.push(orderdetailsapi.order_lines[i]);
            }
          }
          // ******************************** //
          // Action : DECLARE FUNDS RECEPTION //
          // ******************************** //
          else if (event.detail.value == 'declareFundsReception') {
          if( orderdetailsapi.order_lines[i].isDeclareFundsReceptionAvailable ) {
              products.push(orderdetailsapi.order_lines[i]);
            }
          }
          // *************** //
          // Action : REFUND //
          // *************** //
          else if (event.detail.value == 'refund') {
            if( orderdetailsapi.order_lines[i].isRefundAvailable ) {
              products.push(orderdetailsapi.order_lines[i]);
            }
            // else {
            //   products.push(orderdetailsapi.order_lines[i]);
            // }
          }        
          // ***************** //
          // Action : EXCHANGE //
          // ***************** //
          else if (event.detail.value == 'exchange') {
            if( orderdetailsapi.order_lines[i].isExchangeAvailable ) {
              products.push(orderdetailsapi.order_lines[i]);
            }
          }
          // *************************** //
          // Action : APPROVE/REFUSE PMA //
          // *************************** //
          else if (event.detail.value == 'approveRejectPMA') {
            if( orderdetailsapi.order_lines[i].isApproveRejectPMAAvailable ) {
              products.push(orderdetailsapi.order_lines[i]);
            }
          }
          else {
            if(orderdetailsapi.order_lines[i].available_actions.includes(event.detail.value)) {
                products.push(orderdetailsapi.order_lines[i]);
            }
          }
        }

        let options = this.optionsToDisplay;
        let orderAction;
        for(let i=0; i<options.length; i++) {
          if (options[i].value == event.detail.value) {
            // orderAction = options[i].label;
            orderAction = options[i];
            break;
          }
        }

        console.log('orderAction:'+JSON.stringify(orderAction));
        console.log('products:'+JSON.stringify(products));
        
        //orderActionResult;
        console.log('orderAction-start');
        if (event.detail.value == 'declareFundsReception') {        
          console.log('orderAction - declareFundsReception');
          orderActionResult = await ModalDeclareFundReception.open({
            size: 'small',
            content:'Modal opened',
            orderdetailsapi: orderdetailsapi,
            orderaction: orderAction
          });
        }
        else if (event.detail.value == 'refund') {
          console.log('orderAction - '+event.detail.value);
          orderActionResult = await ModalRefund.open({
            size: 'small',
            content:'Modal opened',
            orderdetailsapi: orderdetailsapi,
            products: products,
            orderaction: orderAction
          });
        }      
        else if (event.detail.value == 'refund_delivery_fees') {
          console.log('orderAction - '+event.detail.value);
          orderActionResult = await ModalRefundShippingFees.open({
            size: 'small',
            content:'Modal opened',
            orderdetailsapi: orderdetailsapi,
            products: products,
            orderaction: orderAction
          });
        }
        else if (event.detail.value == 'approveRejectPMA') {
          console.log('orderAction - '+event.detail.value);
          orderActionResult = await ModalApproveRejectPMA.open({
            size: 'small',
            content:'Modal opened',
            orderdetailsapi: orderdetailsapi,
            products: products,
            orderaction: orderAction
          });
        }
        else if (event.detail.value == 'exchange') {
          console.log('orderAction - '+event.detail.value);
          orderActionResult = await MyModal.open({
            size: 'small',
            content:'Modal opened',
            orderid: orderdetailsapi.order_id,
            orderdetailsapi: orderdetailsapi,
            products: products,
            orderaction: orderAction,
            isoneproductonly: true
          });
        }
        else {
          console.log('JGU-orderdetailsapi: '+orderdetailsapi);
          console.log('JGU-orderid: '+orderdetailsapi.order_id);
          orderActionResult = await MyModal.open({
            size: 'small',
            content:'Modal opened',
            orderid: orderdetailsapi.order_id,
            orderdetailsapi: orderdetailsapi,
            products: products,
            orderaction: orderAction
          });
        }
        console.log('orderAction-end');

        //actionResult = orderActionResult;
        // console.log('orderActionResult:'+actionResult);
        
        console.log('JGU-before2:actionResult1:'+orderActionResult);
        console.log('JGU-before2:actionResult2:'+JSON.stringify(orderActionResult));
        // console.log('JGU-before2:actionResult3:'+JSON.stringify(actionResult[0].body));
        // console.log('JGU-before2:actionResult3:'+JSON.stringify(actionResult[0].body?.message));
        // console.log('JGU-before2:actionResult4:'+ orderActionResult[0]?.body?.status);
        // console.log('JGU-before2:actionResult5:'+ orderActionResult.length);

        this.orderRefresh();
      }

      let evt;
      if (orderActionResult != null && orderActionResult != 'cancel') {
        for(let i=0; i < orderActionResult.length; i++) {
          evt = new ShowToastEvent({
            title: orderActionResult[i].status,
            message:orderActionResult[i].message,
            variant: orderActionResult[i].status,
            mode: 'pester'
          });
          console.log('JGU-this.dispatchEvent(evt):'+evt);
          this.dispatchEvent(evt);
        }
      }



      // console.log('orderActionResult:'+orderActionResult[0].shippingNumber);
      // console.log('orderActionResult:'+orderActionResult[0].reasonSelected);
      // console.log('orderActionResult:'+orderActionResult[0].status);

    }

    orderRefresh(){
       // Published ProductSelected message
       publish(this.messageContext, ORDER_REFRESH_MESSAGE, {
          orderId: null
       });
    }

    handleOpenRecord(event) {
      // Stop the event's default behavior (don't follow the HREF link) and prevent click bubbling up in the DOM...
      event.preventDefault();
      event.stopPropagation();
      // Navigate as requested...
      this.navigateToRecordPage(event.target.dataset.recordId);
    }

    navigateToRecordPage(navigateToId) {
      // Navigate to the Account home page
      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
          recordId: navigateToId,
          actionName: 'view',
        },
      });
    }


}