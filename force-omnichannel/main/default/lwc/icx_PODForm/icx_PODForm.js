import { LightningElement,api,track } from 'lwc';
import getProductDetails from "@salesforce/apex/icx_NewPODController.getProductDetails";




export default class Icx_PODForm  extends LightningElement {
    @api selectedProduct;
    @track selectedProductObj;


    @api hotSKUValue;
    @api collectionValue;
    @api genderValue;
    @api categoryValue;
    @api productDescription;
    @api digitalStoreValue
    @api priceValue;
    @api currencyValue;
    @api contactPreferenceValue;
    @api commentValue;
    @api desiredDateValue;
    

      renderedCallback()
      {
        if(this.selectedProduct && !this.selectedProductObj) //prevent rendered loop
        {
            getProductDetails({recordId : this.selectedProduct})
            .then((result) => {
                this.selectedProductObj = result;
              })
              .catch((error) => {
                console.error(error);
              });

          
        }
      }



      // handle function 

    handleHotSkuSelection(event)
    {
        this.hotSKUValue = event.detail;
    }
    handleCollectionSelection(event)
    {
      this.collectionValue = event.detail;
    }
    handleGenderSelection(event)
    {
      this.genderValue = event.detail;
    }
    handleCategorySelection(event)
    {
      this.categoryValue = event.detail
    }
    handleProductDescriptionSelection(event)
    {
      this.productDescription = event.detail;
    }

    handlePriceSelection(event)
    {
      this.priceValue = event.detail;
    }
    handleCurrencySelection(event)
    {
      this.currencyValue = event.detail;
    }
    handleContactPreferenceSelection(event)
    {
      this.contactPreferenceValue = event.detail;
    }
    handleCommentSelection(event)
    {
      this.commentValue = event.detail;
    }

    handleDigitalStoreSelection(event)
    {
      this.digitalStoreValue = event.detail;
    }

    
    handleDesiredDateSelection(event)
    {
      this.desiredDateValue = event.detail;
    }
 

}