import { LightningElement,track, api } from 'lwc';

const columns = [
  { label: 'Client ID', fieldName: 'Id' },
  {label: 'Client Name', fieldName: 'linkName', type: 'url',
    typeAttributes: {label: { fieldName: 'Name' }}},
  { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
  { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date' },
  { label: 'Segmentation', fieldName: 'Segmentation__c' },
  { label: 'Preferred CA', fieldName: 'TECHPreferredCA__c', type: 'date' },
];

export default class icx_dreamAccountMultiMatch extends LightningElement {
    @track isShowModal = false;
    @api accountlist;
    
    columns = columns;
    data = [];
    selectedAccount = '';

    connectedCallback() {
        console.log("LWC MultiMatch Account List: ", this.accountlist);
        this.data = this.accountlist;
    }

    showModalBox() {  
        this.data = this.accountlist;
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    handleSave(){     
        if(this.selectedAccount !== undefined){
            // alert('string not blank')
            let selectedContact = null;
            for (let i = 0; i < this.accountlist.length; i++) {
                var account = this.accountlist[i];
       
                if(account.Id == this.selectedAccount){
                    selectedContact = account.PersonContactId;
                    // alert('Selected Contact: '+ selectedContact);
                    break;
                }     
            }

            var clientselectedEvent = new CustomEvent('clientselected', { 
                bubbles: true , composed : true,
                detail:        
                {accountId : this.selectedAccount, contactId : selectedContact}
            });
            this.dispatchEvent(clientselectedEvent);
        }
        this.isShowModal = false;
    }

    getSelectedName(event) {
        const selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++) {
            // alert('You selected: ' + selectedRows[i].Id);
            this.selectedAccount = selectedRows[i].Id;
        }
    }
}