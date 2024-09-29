import { LightningElement,track  } from 'lwc';
import searchDigitalStore from "@salesforce/apex/icx_searchDigitalStoreController.searchDigitalStore";

export default class Icx_searchDigitalStore extends LightningElement {

    @track storeSelected=undefined;
    @track storeSelectedObj = undefined
    @track autoCompleteOptions=[];
    handleInputChange(event) {
        const inputVal = event.target.value; // gets search input value

        searchDigitalStore({ searchKey: inputVal })
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
        this.storeSelected = event.currentTarget.dataset.id;
        this.storeSelectedObj = this.autoCompleteOptions.filter(item=> item.Id = this.storeSelected)[0];
        this.dispatchEvent(new CustomEvent('digitalstoreevent', { digitalStore: this.storeSelected  }));

    }

    handleCloseSection()
    {
        this.storeSelected = undefined;
        this.storeSelectedObj = undefined;
        this.dispatchEvent(new CustomEvent('digitalstoreevent', { digitalStore: ""  }));

    }

   
}