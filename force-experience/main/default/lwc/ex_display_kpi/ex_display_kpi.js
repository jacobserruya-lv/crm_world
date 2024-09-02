import { LightningElement,api } from 'lwc';

export default class Ex_display_kpi extends LightningElement {

    @api title
    @api counter
    @api counter2
    
    get displayCounter2(){
        return this.counter2 != undefined && this.counter2 != null;
    }
}