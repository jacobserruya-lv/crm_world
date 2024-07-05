import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import iconics from '@salesforce/resourceUrl/iconics';
import { loadStyle} from 'lightning/platformResourceLoader';





export default class Icx_customCard extends NavigationMixin(LightningElement) {
    @api listData;
    @api readOnly;
    @api items;
    @api indexParent
    @api error;
    @api isNotWithPicture;
    @api isCareService;
    @api editRecord;
    @api deleteRecord;
    @api redText;


    connectedCallback() {
        console.log(this.listData);
        console.log('This is the edit record of editRecord', this.editRecord);
        loadStyle(this, iconics + 'styles/client360.css');
    }

    renderedCallback() {


        console.log("listData" + this.listData);
        let tableData = this.template.querySelectorAll("[data-index_parent]").forEach(el => {
            if (el.dataset.image && this.listData[el.dataset.index_parent].item[el.dataset.image].type == 'image') {
                console.log(' img:', this.listData[el.dataset.index_parent].item[el.dataset.image])
                el.className = el.className.replace('slds-hide', '');
                if (!this.listData[el.dataset.index_parent].item[el.dataset.image].value) {
                    this.isNotWithPicture = true;
                }
            }
            else if (el.dataset.html && this.listData[el.dataset.index_parent].item[el.dataset.html].type == 'image-html') {
                console.log(' img-html:', this.listData[el.dataset.index_parent].item[el.dataset.html])
                el.className = el.className.replace('slds-hide', '');
                if (!el.value) {
                    this.isNotWithPicture = true;
                }
            }
            else if (el.dataset.top && this.listData[el.dataset.index_parent].item[el.dataset.top].type.includes('top')) {
                el.className = el.className.replace('slds-hide', '');
            }
            else if (el.dataset.label && !this.listData[el.dataset.index_parent].item[el.dataset.label].type.includes('hide') && !this.listData[el.dataset.index_parent].item[el.dataset.label].type.includes('top') && !this.listData[el.dataset.index_parent].item[el.dataset.label].type.includes('image')) {
                el.className = el.className.replace('slds-hide', '');
            }
            else if (el.dataset.value && !this.listData[el.dataset.index_parent].item[el.dataset.value].type.includes('hide') && !this.listData[el.dataset.index_parent].item[el.dataset.value].type.includes('top') && !this.listData[el.dataset.index_parent].item[el.dataset.value].type.includes('status') && !this.listData[el.dataset.index_parent].item[el.dataset.value].type.includes('image')) {
                el.className = el.className.replace('slds-hide', '');
            }
            else if (el.dataset.status && this.listData[el.dataset.index_parent].item[el.dataset.status].type.includes('status')) {
                el.className = el.className.replace('slds-hide', '');
                if (this.listData[el.dataset.index_parent].item[el.dataset.status].value && !(this.listData[el.dataset.index_parent].item[el.dataset.status].value.toLowerCase().includes('cancelled'))) { // || this.listData[el.dataset.index_parent].item[el.dataset.status].value.includes('cancelled'))) {
                    el.className = el.className.replace('red', '');
                }
            }
        });



    }


    handleNavigation(event) {
      

        this.dispatchEvent(new CustomEvent('recorddetails', { detail: event.currentTarget.dataset.index_parent }));

    }


    onCardEditSelect(event) {
    
        this.dispatchEvent(new CustomEvent('editrecord', {
            detail: event.currentTarget.dataset.index_parent
        }));
    }


    onCardDelete(event) {

        console.log('event in the delete card list', event.currentTarget.dataset.index_parent);

        this.dispatchEvent(new CustomEvent('deleterecord', {
            detail:  event.currentTarget.dataset.index_parent
        }));
    }

    get isButtonDisplay() {
        console.log('buttonDisplay', this.editRecord, this.deleteRecord)
        return this.editRecord || this.deleteRecord;
    }


    navigateToEditAccountPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Calling_Campaign__c',
                actionName: 'edit'
            },
        });
    }
}