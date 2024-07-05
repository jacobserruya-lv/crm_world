import { api, LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getGuidId } from 'c/utils';
import iconResource from '@salesforce/resourceUrl/iconics';
import imagesResource from '@salesforce/resourceUrl/iconics';
// import ICONS from '@salesforce/resourceUrl/static_icons';

// import iconResource from './force-app/main/default/staticResources/appointmentsVue/static/img/icons/icons8-merge-24.png';

export default class Icx_dynamicTable extends NavigationMixin(LightningElement) {
    @api tableData = [];
    @api isWithSubtitles;
    @api myRowClass;
    @api listData = [];
    @api clickFunction;
    @api otherDataType;
    @api createNewButton;
    @api createDistantCareServiceButton;
    @api isProductRow;
    @api searchResult;
    @api createRecord;
    @api isViewMoreButtonDisplay = false;
    @api myImageClass;
    @api autorizeToDisplay;
    @api infoSource;
    @api authToMerge;
    @track disableMerge = true;
    checkBox;
    saveMergeRecordsIds = [];
    copysaveMergeRecordsIds = [];
    displayMergeButton = false;

    // mergeIcon = ICONS + '/icons/icons8-merge-24';



    connectedCallback() {

        if (this.infoSource == 'searchPage' && this.authToMerge) {
            this.displayMergeButton = true;
        }

    }


    renderedCallback() {
        let tableData = this.template.querySelectorAll("lightning-input").forEach(el => {
            if (this.saveMergeRecordsIds.includes(el.dataset.index)) {
                el.checked = true;
            }
        })
    }




    handleClickRow(event) {

        this.dispatchEvent(new CustomEvent('recorddetails', { detail: event.currentTarget.dataset.index }));
    }

		    handleLinkNavigation(event) {
        this.dispatchEvent(new CustomEvent('linkdetails', { detail: event.currentTarget.dataset.id}));
    }
		
    //not for mvp 
    handleCheckbox(event) {

        if (event.detail.checked) {
            this.saveMergeRecordsIds.push(event.currentTarget.dataset.index);



        } else if (event.detail.checked != true) {
            let unCheckIndex = event.currentTarget.dataset.index;
            // this.saveMergeRecordsIds.splice(event.currentTarget.dataset.index,1);
            this.saveMergeRecordsIds = this.saveMergeRecordsIds.filter(function (id) {
                return id != unCheckIndex;
            })
        }
        if (this.saveMergeRecordsIds.length > 1) {
            this.disableMerge = false;

        }
        else { this.disableMerge = true }
    }

    handleMergeAction() {
        this.dispatchEvent(new CustomEvent('mergerecords', { detail: this.saveMergeRecordsIds }));
    }


    handleCreateButton(event) {
        this.dispatchEvent(new CustomEvent('createrecord', { detail: event.actionName }));
    }


    get isViewMoreDisplay() {

        return this.tableData.title?.length > 3 && this.isViewMoreButtonDisplay ? true : false;
    }




    handleListView(e) {
        const evt = new CustomEvent('viewrecordlist', {
            // detail contains only primitives
            detail: e.detail.actionName
            // Fire the event from c-tile
        });
        this.dispatchEvent(evt);
    }

    get mergeButtonIcon() {
        return iconResource + '/images/client360/mergeButton.svg';
    }

    handleRowId() {
        let tableData = this.tableData;
        if (this.tableData.rows) {
            for (let i = 0; i < this.tableData.rows.length; i++) {
                tableData.rows.id = i;
            }

        }
        this.tableData = tableData;
    }

    get getGuidId() {
        return getGuidId();
    }

}