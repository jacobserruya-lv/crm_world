import { LightningElement,api,track,wire } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';
import { registerListener, unregisterAllListeners,invokeWorkspaceAPI } from 'c/utils';


export default class Icx_dreamProductDetails extends LightningElement {
    

     productDetailsPart1;
     productDetailsPart2;
     productName;
     productImage;

    cellClass="large_cell slds-hide";
    isAccountKeyInformation=false;
     queryString = window.location.search;
     urlParams = new URLSearchParams(this.queryString);
     productDetailsID = this.urlParams.get('c__productDetailsID')



    isDataLoaded;
   

    connectedCallback() {
        var productDetails =  JSON.parse(sessionStorage.getItem('productDetails'));

        
        if(productDetails !=null)
        { 
            
        
     
            this.productDetailsPart1 = productDetails.productDetails.slice(0,parseInt((productDetails.productDetails.length-1)/2, 10)+1);
            this.productDetailsPart2 = productDetails.productDetails.slice(parseInt((productDetails.productDetails.length-1)/2, 10)+1,productDetails.productDetails.length);
    
            this.productName = productDetails.productName;
            this.productImage = productDetails.productImage;
            this.isDataLoaded = true;


        }
        else{
            registerListener('productDetails'+this.productDetailsID, this.handleEventInfo, this)
            .then(result => {
                console.log('nao in then product information');
    
               
                if(!this.isDataLoaded)
                {
                        invokeWorkspaceAPI('getFocusedTabInfo').then(focusedTab => {
                            invokeWorkspaceAPI('closeTab', {
                              tabId: focusedTab.tabId
                            })
                        })
                
                }
            })
        }
     

         

    }
 
 
    
      disconnectedCallback() {
        unregisterAllListeners(this);
      }
    
      handleEventInfo(infoReceived) {
        console.log('nao in for the event2');
        console.log(infoReceived);

        if(infoReceived!=null){

          


            //add id of the product for each product details
            sessionStorage.setItem('productDetails'+this.productDetailsID, JSON.stringify(infoReceived));
            this.isDataLoaded = true;

           
         
          
        }
      
     
      }

    get documentIcon(){
        return imagesResource+ '/images/client360/documentIcon.svg'

    }

 

}