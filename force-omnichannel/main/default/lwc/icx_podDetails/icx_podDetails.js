import { LightningElement,track } from 'lwc';
import getOptionValues from "@salesforce/apex/icx_NewPODController.getOptionValues";

export default class Icx_podDetails extends LightningElement {

    @track contactPreferenceOptions;
    @track currencyOptions;


    connectedCallback()
    {
      this.init();
    }

    init()
      {

          getOptionValues({selectedObject : 'Case',selectedField:'Contact_preference_from_client__c'})
        .then((result) => {
            this.contactPreferenceOptions = result.map(op => JSON.parse(op));
            console.log('nao this.contactPreferenceOptions', this.contactPreferenceOptions);
          })
          .catch((error) => {
            console.error(error);
          });

          getOptionValues({selectedObject : 'Case',selectedField:'Currency__c'})
        .then((result) => {
            this.currencyOptions = result.map(op => JSON.parse(op));
            console.log('nao this.currencyOptions', this.currencyOptions);
          })
          .catch((error) => {
            console.error(error);
          });
      }


      handlePriceChange(event)
      {
        this.dispatchEvent(new CustomEvent('priceevent', { detail: event.target.value  }));


      }
      handleCurrencyChange(event)
      {
        this.dispatchEvent(new CustomEvent('currencyevent', { detail:event.target.value  }));

      }
      handlecontactPreferenceChange(event)
      {
        this.dispatchEvent(new CustomEvent('contactpreferenceevent', { detail: event.target.value  }));

      }
      handleCommentChange(event)
      {
        this.dispatchEvent(new CustomEvent('commentevent', { detail: event.target.value  }));

      }
      handleDesiredDateChange(event)
      {
        this.dispatchEvent(new CustomEvent('desireddateevent', { detail: event.target.value  }));
      }
    
}