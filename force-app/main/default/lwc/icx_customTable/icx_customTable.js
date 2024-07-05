import { LightningElement,api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';



export default class Icx_customTable extends NavigationMixin( LightningElement ) {
    @api columns;
    @api isAccountKeyInformation;
    @api cellClass;
    @api ableToAccessCti;
    @api authToEditModal;
    @api lineClass;
    @api accountId;
    phoneLabel = 'Mobile Phone';
    
    
    
    get displayCtiIcon()
    {
      console.log('Show the value of this.authToEditModal' , this.authToEditModal);
      console.log('Show the value of this.account.Can_Be_Contacted_By_Phone  ' , this.ableToAccessCti );
      return this.authToEditModal && this.ableToAccessCti? true :false;
    }
    
    renderedCallback(){
        
        console.log(' in custom table',JSON.stringify(this.columns));
        let tableTR =  this.template.querySelectorAll('tr').forEach(el=> {

            if( el.dataset.index  && this.isAccountKeyInformation==true ){
                el.className = this.lineClass ? this.lineClass.replace('slds-hide',''):'';
            }

        });

        console.log('the this.columns' ,JSON.stringify(this.columns));

        let tableTD =  this.template.querySelectorAll('td').forEach(el=> {
            if( el.dataset.label ){
                el.className = this.cellClass.replace('slds-hide','');
            }
            else if( el.dataset.text && this.columns[el.dataset.text].type=='text' ){
                el.className = this.cellClass.replace('slds-hide','');
            }
            else if( el.dataset.phone && this.columns[el.dataset.phone].type=='phone' ){
                el.className = this.cellClass.replace('slds-hide','');
                console.log('Show here results of permission',this.authToEditModal);
            }
            else if( el.dataset.checkbox && this.columns[el.dataset.checkbox].type=='checkbox' ){
                console.log('into checkbox');
                el.className = this.cellClass.replace('slds-hide','');
                let allChildren = el.querySelectorAll(":scope > lightning-input").forEach(item => item.checked = this.columns[el.dataset.checkbox].value=="true"? true:false );
            }
            else if( el.dataset.url && this.columns[el.dataset.url].type=='url' ){
                el.className = this.cellClass.replace('slds-hide','');
            }

           


        });
        
  
        

    }




    //send event to the parent to open subtab for more client information when we are in the clien info case
    handleClickMoreInformationButton(){

        this.dispatchEvent(new CustomEvent('information'));

     
    }

     
}