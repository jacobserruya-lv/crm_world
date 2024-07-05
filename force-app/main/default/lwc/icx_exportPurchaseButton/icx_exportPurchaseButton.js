import { LightningElement, api, wire, track } from 'lwc';
import getExportPurchasesTracability from '@salesforce/apex/ICX_Client360_SF.getExportTracabilty';
import createExportPurchase from '@salesforce/apex/ICX_PurchasesExport.createExportPurchase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasExportButtonPermission from '@salesforce/customPermission/icx_exportButton';  // temporary


export default class ExportButtonComponent extends LightningElement {
    @api accountId;
    exportPurchasesTracabilityRecord;
    pollingInterval;
    @track buttonLabel ='Export';
    @track buttonDisabled = false;
    isError = false;




    connectedCallback() {
        console.log('this.accountId', this.accountId);
        if(this.accountId) this.checkStatus();
    }

    disconnectedCallback() {
        this.stopPolling();
    }    

    get showButton() {
        return hasExportButtonPermission;  // Returns true if the user has the icx_exportButton custom permission
    }

    checkStatus() {
        let result =  getExportPurchasesTracability({ dreamId: this.accountId })
        .then((result)=>{
            this.exportPurchasesTracabilityRecord = result;
            console.log('exportPurchasesTracabilityRecord', this.exportPurchasesTracabilityRecord);
            if(this.exportPurchasesTracabilityRecord != null) {
                this.exportPurchasesTracabilityRecordId = this.exportPurchasesTracabilityRecord.Id;
                console.log('result is not null');
                if(this.exportPurchasesTracabilityRecord.Status__c == 'Ready To Download') {
                    console.log('exportPurchasesTracabilityRecord.Status__c == Ready To Download');
                    this.buttonLabel = 'Download File';
                    if (this.buttonDisabled == true) {
                        this.showToast('Success', 'File ready to download', 'success');
                    }
                    this.buttonDisabled = false;
                    this.stopPolling();
                } 
                // else if (this.exportPurchasesTracabilityRecord.Status__c == 'Failed') {
                //     console.error('exportPurchasesTracabilityRecord.Status__c == Failed');
                //     this.stopPolling();
                //     this.showToast('Error', 'Error while creating the file, please try again', 'error');
                //     this.buttonLabel = 'Export';
                //     this.buttonDisabled = false;
                // }
            }
            else { // if (exportPurchasesTracabilityRecord == null)
                console.log('exportPurchasesTracabilityRecord is null');
                if (this.buttonDisabled == true) {
                    this.showToast('Error', 'Error while creating the file, please try again', 'error');
                } 
                this.buttonLabel = 'Export';
                this.buttonDisabled = false;
                this.stopPolling();
            }})
        .catch((error)=>{
            console.error('get status export error : ' , error);
            this.isError = true;
            this.stopPolling();
            if (window.confirm('Error while creating the file, reload is needed, do you want to reload?')) {
                window.location.reload();
            }
        });
    }
        
    async startPolling() {
        console.log('startPolling');
        this.pollingInterval = setInterval(async () => {
            this.checkStatus();
        }, 3000);
    }

    stopPolling() {
        clearInterval(this.pollingInterval);
    }

    handleClick() {
        if (this.isError) {
            if (window.confirm('Reload is needed, do you want to reload?')) {
                window.location.reload();
            }
        } else {
            if (this.buttonLabel == 'Export') {
                console.log('this.createFile');
                this.createFile();
            } else if (this.buttonLabel == 'Download File') {
                console.log('this.downloadFile');
                this.downloadFile();
            } else {
                console.error('Invalid buttonAction');
            }
        }
    }

    createFile() {
        this.buttonDisabled = true;

        console.log('createFile this.accountId', this.accountId);
            createExportPurchase({ dreamId: this.accountId })
            .then(result => {
                this.startPolling();
                this.buttonLabel = 'Export In Progress';

            })
            .catch(error => {
                this.error = error;
                console.error('error while creating the file', error);
                this.buttonDisabled = false;
                this.showToast('Error', 'Error while creating the file, please try again', 'error');
            });
    }

    downloadFile() {
        console.log('downloadFile');
        console.log('download this.accountId', this.accountId);
        
        if (this.exportPurchasesTracabilityRecord.Public_File_Link__c != null) {
            // download URL
            console.log('this.exportPurchasesTracabilityRecord.Public_File_Link__c', this.exportPurchasesTracabilityRecord.Public_File_Link__c);
            window.location.href = this.exportPurchasesTracabilityRecord.Public_File_Link__c;
        } else {
            // handle error
            console.error('Error while downloading the file');
            this.showToast('Error', 'Error while downloading the file, please try again', 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}