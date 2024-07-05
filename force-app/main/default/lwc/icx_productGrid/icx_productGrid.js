import { api, LightningElement } from 'lwc';

export default class Icx_productGrid extends LightningElement {
    @api products;
    @api isLoading;
    @api openDetails;
    @api cardClass;
}