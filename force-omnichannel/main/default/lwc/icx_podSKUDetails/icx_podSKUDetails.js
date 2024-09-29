import { LightningElement, api,track } from 'lwc';
import getOptionValues from "@salesforce/apex/icx_NewPODController.getOptionValues";
import { NavigationMixin } from 'lightning/navigation';

export default class Icx_podSKUDetails extends NavigationMixin(LightningElement) {

    @api selectedProductObj;
    @api imgWidth ="5%";
    @api isClosable=false;
    @api isHotSKU = false;
    @api isCollection = false;
    @track collectionOptions;
  



    connectedCallback()
    {
      this.init();
    }

      init()
      {
        getOptionValues({selectedObject : 'Case',selectedField:'Collection__c'})
            .then((result) => {
                this.collectionOptions = result.map(op => JSON.parse(op));
                console.log('nao this.collectionOptions', this.collectionOptions);
              })
              .catch((error) => {
                console.error(error);
              });
          
      }


      handleNameClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.optionid,
                objectApiName: 'ProductCatalogue__c',
                actionName: 'view'
            },
        });
    }

    closeSection()
    {
        this.dispatchEvent(new CustomEvent('closesection'));
 
    }
    handleHotSkuChange(event)
    {

        this.dispatchEvent(new CustomEvent('hotskuevent', { detail: event.target.checked  }));
     
    }
    handleCollectionChange(event)
    {

        this.dispatchEvent(new CustomEvent('collectionevent', { detail: event.target.value  }));

    }

}