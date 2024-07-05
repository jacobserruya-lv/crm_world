import { LightningElement, api, track, wire } from 'lwc';





export default class Icx_infoClient360 extends LightningElement {
    @track error;
    @api dreamId;
    @api accountLoading;




    connectedCallback() {
       }




    //for the tab

    handleActive(event) {
        console.log(event)
        const tab = event.target;
        this.tabContent = `Tab ${event.target.value} is now active`;
    }
}