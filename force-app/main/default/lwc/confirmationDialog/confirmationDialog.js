import { LightningElement,api } from 'lwc';

export default class ConfirmationDialog extends LightningElement {
    
    @api header; 
    @api name; 
    @api message; 
    @api confirmLabel; 
    @api cancelLabel; 
  

    //handles button clicks
    handleClick(event){
        event.target.disabled = true; 
        event.stopPropagation();
        const actionName = event.target.name;
       
        this.dispatchEvent(new CustomEvent(actionName));
    }
}