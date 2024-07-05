import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Icx_account_highlightIndicatorPopup extends NavigationMixin(LightningElement) {
    @api indicators;
    @api showCscIndicator;
    @api showCscIndicatorPendingAnswers;
    @api showCscIndicatorPendingCareService;
    @api showCscIndicatorPendingComplaints;
    @api showCscIndicatorResolvedComplaints;
    @api showCscIndicatorPendingSurveys;


   
    goToPendingAnswers(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        let selectedItem = event.currentTarget; // Get the target object
        let index = selectedItem.dataset.index; // Get its value i.e. the index
        let caseSelected = this.indicators.pendingAnswersList[index];

        this.navigateToRecordViewPage(caseSelected.id);
    }
    goToPendingCareService(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        let selectedItem = event.currentTarget; // Get the target object
        let index = selectedItem.dataset.index; // Get its value i.e. the index
        let careSelected = this.indicators.pendingCareServiceList[index];

        this.navigateToRecordViewPage(careSelected.Id);
    }
    goToPendingComplaints(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        let selectedItem = event.currentTarget; // Get the target object
        let index = selectedItem.dataset.index; // Get its value i.e. the index
        let caseSelected = this.indicators.pendingComplaintsList[index];

        this.navigateToRecordViewPage(caseSelected.id);
    }
    goToResolvedComplaints(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        let selectedItem = event.currentTarget; // Get the target object
        let index = selectedItem.dataset.index; // Get its value i.e. the index
        let caseSelected = this.indicators.resolvedComplaintsList[index];

        this.navigateToRecordViewPage(caseSelected.id);
    }
    
    goToOpenCase(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        let selectedItem = event.currentTarget; // Get the target object
        let index = selectedItem.dataset.index; // Get its value i.e. the index
        let caseSelected = this.indicators.openCaseList[index];

        this.navigateToRecordViewPage(caseSelected.id);
    }
    goToFollowupRequestRecord(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        let selectedItem = event.currentTarget; // Get the target object
        let index = selectedItem.dataset.index; // Get its value i.e. the index
        let caseSelected = this.indicators.followupRequestList[index];

        this.navigateToRecordViewPage(caseSelected.id);
    }
    goToPendingAnswerRecord(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        let selectedItem = event.currentTarget; // Get the target object
        let index = selectedItem.dataset.index; // Get its value i.e. the index
        let caseSelected = this.indicators.pendingAnswerList[index];

        this.navigateToRecordViewPage(caseSelected.id);
    }

    goToComplaintCase(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        let selectedItem = event.currentTarget; // Get the target object
        let index = selectedItem.dataset.index; // Get its value i.e. the index
        let caseSelected = this.indicators.complaintList[index];

        this.navigateToRecordViewPage(caseSelected.id);
    }

    goToCareService(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        let selectedItem = event.currentTarget; // Get the target object
        let index = selectedItem.dataset.index; // Get its value i.e. the index
        let careSelected = this.indicators.careList[index];

        this.navigateToRecordViewPage(careSelected.Id);
    }

    goToPendingSurveys(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        let selectedItem = event.currentTarget; // Get the target object
        let index = selectedItem.dataset.index; // Get its value i.e. the index
        let caseSelected = this.indicators.surveysPendingList[index];

        this.navigateToRecordViewPage(caseSelected.id);
    }

    navigateToRecordViewPage(recordId) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                //objectApiName: 'namespace__ObjectName', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

}