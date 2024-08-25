import { LightningElement, api, track, wire } from 'lwc';
import getProductsData from '@salesforce/apex/Ctrl_ProductCatalog.getCustomizableProdMDT';

export default class ProductCatalog_StaticPage extends LightningElement {
    @api countriesSelected;
    @api physicalStoresSelected;
    @track productCategories = [];
    @track categories = [];


    @wire(getProductsData, {})
    wiredProducts({ error, data }) {
        if (data) {

            this.categories = [...new Set(data.map(element => element.ProductCategory__c))];
            this.productCategories = this.categories.map(el => ({ categoryName: el, products: data.filter(pro => pro.ProductCategory__c == el) }));

        } else if (error) {
            console.log("Error at retrieve data", error);
        }
    }

}