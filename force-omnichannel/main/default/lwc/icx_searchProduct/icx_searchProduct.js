import { LightningElement,api, track } from 'lwc';
import searchProduct from "@salesforce/apex/icx_searchProductController.searchProduct";


export default class Icx_searchProduct extends LightningElement {


    @api selectedProduct = undefined;
    @api selectedProductObj = undefined;
    @track autoCompleteOptions=[];
    @track searchTerm;

    handleInputChange(event) {
        const inputVal = event.target.value; // gets search input value

        searchProduct({ searchKey: inputVal })
        .then((result) => {
            this.autoCompleteOptions = result ? result : undefined;
            // filters in real time the list received from the wired Apex method
            // this.autoCompleteOptions = this.objectsList.filter(item => item.Name.toLowerCase().includes(inputVal.toLowerCase()));

            this.autoCompleteOptions = this.autoCompleteOptions.sort((a, b) => a.Name.localeCompare(b.Name));

            // makes visible the combobox, expanding it.
            if (this.autoCompleteOptions.length && inputVal) {
                this.template.querySelector('.slds-combobox.slds-dropdown-trigger.slds-dropdown-trigger_click')?.classList.add('slds-is-open');
                this.template.querySelector('.slds-combobox.slds-dropdown-trigger.slds-dropdown-trigger_click')?.focus();
            }
          })
          .catch((error) => {
            console.error(error);
          });

        
    }

    handleOptionClick(event)
    {
        this.selectedProduct = event.currentTarget.dataset.id;
        this.selectedProductObj= this.autoCompleteOptions.filter(item=> item.Id = this.selectedProduct)[0];
        

    }


    handleCloseSection()
    {
        this.selectedProduct = undefined;
        this.selectedProductObj = undefined;
    }

  

   
}