import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import iconics from '@salesforce/resourceUrl/iconics';
import { loadStyle } from 'lightning/platformResourceLoader';
// import getContact from '@salesforce/apex/icx_Client360_API.getContact';
import { CurrentPageReference } from 'lightning/navigation';

import { invokeWorkspaceAPI } from 'c/utils';









export default class Icx_dreamAccountKeyInformation  extends NavigationMixin( LightningElement ) {

    @api accountId;
    @api accessCti;
    @api passAuthToEdit;
    // @api moreInformationData;
    @api clientKeyInfo;
    @api isLoading;

    isAccountKeyInformation = true;
    lineClass = "colored_line slds-hide";
    cellClass="large_cell2 slds-hide slds-truncate";
    moreClientInfo=true;
    moreClientInfoSF=true;

    dreamAccountClient= false;
    labelSubTab='Client Information';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.dreamAccountClient = currentPageReference.state?.c__dreamAccountClient;
       }
    }

    connectedCallback(){
      loadStyle(this, iconics + '/styles/prechat-slds.css');
      console.log(' clientKeyInfo in the component', JSON.stringify(this.clientKeyInfo));
      console.log(' display in the authEdit', this.passAuthToEdit);
    }


    
    get phoneBadge(){
      console.log('Show the value of this.displayPhoneIcone ' , this.phoneIconDisplay);
      console.log('Show the value of this.authToEditModal ' , this.authToEditModal);
     return !this.phoneIconDisplay ? 'highlight__icon-detail_badge_grey': this.accessCti ? 'highlight__icon-detail_badge_green':'highlight__icon-detail_badge_red ';
  }

  get displayCtiIcon()
  {
    console.log('Show the value of this.authToEditModal ' , this.authToEditModal);
    console.log('Show the value of this.account.Can_Be_Contacted_By_Phone  ' , this.accessCti );
    return this.authToEditModal && this.accessCti ? true :false;
  }




openMoreInformation() {

  if(!this.dreamAccountClient)

   {


     console.log(' display in the authEdit 222', this.passAuthToEdit);
  this[NavigationMixin.Navigate]({
    type: 'standard__component',
    attributes: {
      componentName: "c__icx_dreamRedirection"
  },
  state: {
    c__accountId: this.accountId,
    c__authToEdit: this.passAuthToEdit,
    c__moreClientInfoSF : this.moreClientInfoSF,
    c__label : this.labelSubTab

}
  });
}
  else{




this.openMoreInfoClient360(this.accountId);
  }

  }
 
     

  openMoreInfoClient360(accountId)
  {
          invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
          if (isConsole) {
              invokeWorkspaceAPI('getAllTabInfo').then(response => {
                  let focusTabId;
                  for (var i = 0; i < response.length; i++) 
                  {
                      
                          let tab = response[i];
               
                      if(accountId ==tab.pageReference.state.c__accountId && tab.pageReference.state.c__moreClientInfo )
                      {
  
                          focusTabId = tab.tabId;

  
  
                      }
                  }
                  if(focusTabId)
                  {

                      invokeWorkspaceAPI('closeTab', {tabId:focusTabId })
                      .then(response => {
                          console.log(" closeTab ID: ", response);
                          
                          
                      });
                  }
                  console.log(' display in the authEdit 333', this.passAuthToEdit);
                  this[NavigationMixin.Navigate]({
                    type: 'standard__component',
                    attributes: {
                      componentName: "c__icx_dreamRedirection"
                  },
                  state: {
                    c__accountId: this.accountId,
                    c__moreClientInfo : this.moreClientInfo,
                    c__label : this.labelSubTab
                
                }
                });
                  });
          }
      });


   
  }
 
}