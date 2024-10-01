import { LightningElement, track } from 'lwc';
import getOptionValues from "@salesforce/apex/icx_NewPODController.getOptionValues";


export default class Icx_unknownProductDetails extends LightningElement {

    @track genderOptions;
    @track categoryOptions;
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
            })
            .catch((error) => {
              console.error(error);
            });

      getOptionValues({selectedObject : 'Case',selectedField:'POD_gender__c'})
      .then((result) => {
          this.genderOptions = result.map(op => JSON.parse(op));
        })
        .catch((error) => {
          console.error(error);
        });

      getOptionValues({selectedObject : 'Case',selectedField:'POD_Category__c'})
      .then((result) => {
          this.categoryOptions = result.map(op => JSON.parse(op));
        })
        .catch((error) => {
          console.error(error);
        });        
        
    }

    handleGenderChange(event)
    {
        this.dispatchEvent(new CustomEvent('genderevent', { detail: event.target.value  }));
    }
    handleCategoryChange(event)
    {
        this.dispatchEvent(new CustomEvent('cotegoryevent', { detail: event.target.value  }));
    }
    handleCollectionChange(event)
    {
        this.dispatchEvent(new CustomEvent('collectionevent', { detail: event.target.value  }));
    }
    handleProductDescriptionChange(event)
    {
        this.dispatchEvent(new CustomEvent('productdescriptionevent', { detail: event.target.value  }));

    }
}