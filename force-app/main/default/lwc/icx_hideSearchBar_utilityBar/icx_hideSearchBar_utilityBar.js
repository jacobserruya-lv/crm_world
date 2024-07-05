import { LightningElement ,api,wire,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import styleResource from '@salesforce/resourceUrl/iconics';

export default class Icx_hideSearchBar_utilityBar extends LightningElement {
    hideSFsearchBar;

    connectedCallback()
    {
        Promise.all([
            loadStyle(this, styleResource + '/styles/prechat-slds.css'),
        ])
        .catch(error => console.error(' error in loading style' , error));

        this.hideSFsearchBar = 'hide_search_standart_salesforce';
    }
}