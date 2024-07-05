import { LightningElement ,track,api} from 'lwc';

export default class Account_DigitalOrderPopup extends LightningElement {
    @track digitalorder;
    

    @api
    get mydigitalorder(){
        return this.digitalorder;
    }

    set mydigitalorder(value) {
        this.digitalorder = value;
    } 

}