import { LightningElement, api } from 'lwc';
import { copyToClipboard } from 'c/icx_utils';
export default class Icx_clientOrderDetails extends LightningElement {
    @api orderid; // Salesforce ID
    @api orderdetailsapi;

    message = 'salesforce casts';

    //document.queryCommandSupported('copy')
  async handleCopyClientEmail() {
    await copyToClipboard(this.orderdetailsapi.sold_to.email, 'Client email was successfully copied', this);
  }

  async handleCopyValidationLink() {
    await copyToClipboard(this.orderdetailsapi.payAfterAgreementLink, 'Validation link was successfully copied', this);
  }

    // async handleCopyClientEmail() {
    //     let msg = this.orderdetailsapi.sold_to.email;

    //     if (navigator.clipboard && window.isSecureContext) {
    //         navigator.clipboard.writeText(msg);
    //     } else {
    //         let textArea = document.createElement("textarea");
    //         textArea.value = msg;
    //         textArea.style.position = "fixed";
    //         textArea.style.left = "-999999px";
    //         textArea.style.top = "-999999px";
    //         document.body.appendChild(textArea);
    //         textArea.focus();
    //         textArea.select();
    //         // return new Promise((res, rej) => {
    //         //     document.execCommand("copy") ? res() : rej();
                
    //         // }); 
    //         var result = document.execCommand("copy");
    //         textArea.remove();
    //     }

    //     let evt = new ShowToastEvent({
    //         title: 'Copy to clipboard',
    //         message: 'Client email was successfully copied',
    //         variant: 'success',
    //         mode: 'pester'
    //       });
    //       console.log('JGU-this.dispatchEvent(evt):'+evt);
    //       this.dispatchEvent(evt);
    // }

    // async handleCopyValidationLink() {
    //     let msg = this.orderdetailsapi.payAfterAgreementLink;

    //     if (navigator.clipboard && window.isSecureContext) {
    //         navigator.clipboard.writeText(msg);
    //     } else {
    //         let textArea = document.createElement("textarea");
    //         textArea.value = msg;
    //         textArea.style.position = "fixed";
    //         textArea.style.left = "-999999px";
    //         textArea.style.top = "-999999px";
    //         document.body.appendChild(textArea);
    //         textArea.focus();
    //         textArea.select();
    //         // return new Promise((res, rej) => {
    //         //     document.execCommand("copy") ? res() : rej();
                
    //         // }); 
    //         var result = document.execCommand("copy");
    //         textArea.remove();
    //     }

    //     let evt = new ShowToastEvent({
    //         title: 'Copy to clipboard',
    //         message: 'Validation link was successfully copied',
    //         variant: 'success',
    //         mode: 'pester'
    //       });
    //       console.log('JGU-this.dispatchEvent(evt):'+evt);
    //       this.dispatchEvent(evt);
    // }
}