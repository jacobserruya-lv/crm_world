import { api, track, wire } from 'lwc';
import { LightningElement } from 'lwc';

export default class Icx_orderActionRefundTile extends LightningElement {
    _orderShipping;
    _isChecked;

    // Param : Product to display
    @api
    get product() {
        return this._orderShipping;
    }
    set product(value) {
        // console.log('JGU-product: '+JSON.stringify(value));
        this._orderShipping = value;        
        this.amount = value.unit_price;
        this.pictureUrl = value.productImage + '?wid=50&amp;hei=50';
    }

    @api reasons;
        
    // 
    amountOptions =  [ 
        {value:"total", label:"Total"}];
    // Refund payment methods
    methods = [
        {label:'Bank Transfer' ,value:'BANK_TRANSFER'},
        {label:'Cash on Delivery' ,value:'COD'},
        {label:'Credit Card' ,value:'CREDIT_CARD'}
    ];
    // Refund reason
    // reasons = [ 
    //     {value:"manual_refund_confirmation", label:"Manual Refund Confirmation"}, 
    //     {value:"lost_package_defect", label:"Lost Package/Defect"}, 
    //     {value:"shipping_fees_refund", label:"Shipping fees Refund"}, 
    //     {value:"other", label:"Other"}];
    

    @api amountSelected = this.amountOptions[0].value;
    @api methodSelected;
    @api reasonSelected;
    @api amount;

 
    // Is the product selected ?
    @api 
    get isChecked() {
        return this._isChecked;
    }
    set isChecked(value) {
        console.log('icx_orderActionRefundTile.isChecked('+value+')');
        if (value) {
            this._isChecked = 'checked';
            // if (this.methods.length == 1) {
            //     this.methodSelected = this.methods[0].value;
            // }
            // if (this.reasons.length == 1) {
            //     this.reasonSelected = this.reasons[0].value;
            // }
        }
        else {
            this._isChecked = null;
            this.methodSelected = null;
            this.reasonSelected = null;
        }
    }   

    @api
    setCheckedValue(isChecked) {
        console.log('icx_orderActionRefundTile.setCheckedValue('+isChecked+')');
        if (isChecked)
            this.isChecked = 'checked';
        else {
            this.isChecked = null;
            this.reasonSelected = 'none';
        }
    }

    // When change the value in  "reason" combobox
    handleMethodChange(event) {        
        setTimeout(() => (this.template.querySelector('lightning-combobox').reportValidity(), this.myValue = null))
        this.methodSelected = event.detail.value;        
    }

    // When change the value in  "reason" combobox
    handleReasonChange(event) {        
        setTimeout(() => (this.template.querySelector('lightning-combobox').reportValidity(), this.myValue = null))
        this.reasonSelected = event.detail.value;        
    }

    // When click on "Checkbox" in order to select the product
    handleClick(event) {
        this.setCheckedValue(event.target.checked);
        
        // if (this.isChecked)
        //     setTimeout(() => (this.template.querySelector('lightning-combobox')?.reportValidity(), this.myValue = null))
        }
}