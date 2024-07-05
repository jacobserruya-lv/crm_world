import { LightningElement, api } from 'lwc';

export default class ICX_customizableProductsContainer extends LightningElement {
    @api products;
    @api physicalStoresSelected;
    @api selectCountry;

}