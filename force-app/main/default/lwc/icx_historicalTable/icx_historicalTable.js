import { api, LightningElement } from 'lwc';
import {getGuidId} from 'c/utils';

export default class Icx_historicalTable extends LightningElement {
    @api isLoading;
    @api categories;

    connectedCallback() {
    }

    get getGuidId()
    {
        return getGuidId();
    }

    // divide the categories list to 2 lists
    get firstCategories() {
        return this.categories.slice(0, Math.ceil(this.categories.length / 2));
    }

    get lastCategories() {
        return this.categories.slice(Math.ceil(this.categories.length / 2));
    }
}