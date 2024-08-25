import { api, LightningElement, wire } from 'lwc';

export default class Icx_orderActionsShippingTile extends LightningElement {
    /** Product and Order information to display */
    _orderShipping;
    _isChecked;
    _reasonSelected = 'none';
    /** Product image to display. */
    pictureUrl;

    @api message;

    // Param : Product to display
    @api
    get product() {
        return this._orderShipping;
    }
    set product(value) {
        // console.log('JGU-product: '+JSON.stringify(value));
        this._orderShipping = value;
        this.pictureUrl = value.productImage + '?wid=50&amp;hei=50';
    }

    // Is the product selected ?
    @api 
    get isChecked() {
        return this._isChecked;
    }
    set isChecked(value) {
        if (value) {
            this._isChecked = 'checked';
            console.log('this.reasons.length:'+this.reasons.length);
            if (this.reasons.length == 1) {
                this.reasonSelected = this.reasons[0].value;
            }
        }
        else {
            this._isChecked = null;
            this.reasonSelected = 'none';
        }
    }

    // The reason selected
    @api 
    get reasonSelected() {
        return this._reasonSelected;
    }
    set reasonSelected(value) {
        this._reasonSelected = value;
    }

    // List of reasons available
    @api
    get reasons() {
        return this._reasons;
    }
    set reasons(value) {
        this._reasons = value;
        if (value.length == 1) {
            this.reasonSelected = value[0].value;
        }
    }

    @api
    setCheckedValue(isChecked) {
        console.log('setCheckedValue:'+isChecked);
        if (isChecked)
            this.isChecked = 'checked';
        else {
            this.isChecked = null;
            this.reasonSelected = 'none';
        }
    }

    @api
    setMessage(message) {
        this.message = message;
    }

    @api
    hasMessage() {        
        return !(typeof this.message === 'undefined' || this.message === null || this.message === '');
    }

    // When change the value in  "reason" combobox
    handleReasonChange(event) {        
        setTimeout(() => (this.template.querySelector('lightning-combobox').reportValidity(), this.myValue = null))
        this.reasonSelected = event.detail.value;        
    }
    

    // When click on "Checkbox" in order to select the product
    handleClick(event) {
        
        this.dispatchEvent(new CustomEvent('productselected', {
            detail: {
                event: event,
                product: this.product
            }
        }));

        this.setCheckedValue(event.target.checked);
        
        if (this.isChecked)
            setTimeout(() => (this.template.querySelector('lightning-combobox')?.reportValidity(), this.myValue = null))
     }

}