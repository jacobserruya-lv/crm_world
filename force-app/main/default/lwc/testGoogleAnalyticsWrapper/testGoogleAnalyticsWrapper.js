import { LightningElement, track, api } from 'lwc';

export default class TestGoogleAnalyticsWrapper extends LightningElement {

    @api autodata;
    @api queryParams;
    @api page;

    @track oQueryParams;

    connectedCallback() {
        this.oQueryParams = JSON.parse(this.queryParams);
    }

}