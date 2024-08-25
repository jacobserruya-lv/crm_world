import { LightningElement, api, track } from 'lwc';

export default class Ct_searchableCombobox extends LightningElement {
    @api valueChangeCb;
    @api isRequired = false;
    @api title = 'Searchable Combobox';
    @api options = [];

    @track isShowPicklist = false;
    @track searchValue = '';

    get placeholder() {
        return !!this.options?.length ? 'Select an option' : 'No options available';
    }

    get disabledInput() {
        return !this.options?.length;
    }

    get shouldDisplayResults() {
        return this.isShowPicklist && this.searchResults.length;
    }

    get inputField() {
        return this.template?.querySelector('.input-search');
    }
    
    get searchResults() {
        const value = this.searchValue?.toLowerCase();
        
        if (!this.options) {
            return [];
        }

        return value ? this.options?.filter((picklistOption) =>
            picklistOption.label.toLowerCase().includes(value)
        ) : [...this.options];
    }

    get picklistOrdered() {
        return this.options && [...this.options].sort((a,b)=>{
            if(a.label < b.label){
                return -1
            }
        }) || [];
    }

    search(event) {
      this.searchValue = event.detail.value;
      this.valueChangeCb('');
      this.isShowPicklist = true; 
    }
  
    selectSearchResult(event) {
      const { value, label } = event.currentTarget.dataset;
      this.searchValue = label;
      this.valueChangeCb(value);
      this.togglePicklist();
      const inputElement = this.template.querySelector('.input-search');
      requestAnimationFrame(() => inputElement?.reportValidity());
    }

    togglePicklist() {
        this.isShowPicklist = !this.isShowPicklist; 
    }

    @api
    closePicklist() {
        this.isShowPicklist = false;
    }

    @api
    reset() {
        this.isShowPicklist = false;
        this.searchValue = '';
    }
}