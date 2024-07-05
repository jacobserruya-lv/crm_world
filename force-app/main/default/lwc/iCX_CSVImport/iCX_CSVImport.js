import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import createDPCA from '@salesforce/apex/ICX_CSVImportCtrl.createDPCA';
import createDPCAPreupload from '@salesforce/apex/ICX_CSVImportCtrl.createDPCAPreupload';
//import createVideoSessionMember from '@salesforce/apex/ICX_CSVImportCtrl.createVideoSessionMember';

const columnsCase = [
    { label: 'DPCA Id', fieldName: 'Id' } ,
    { label: 'Status', fieldName: 'Status' } ,
    { label: 'Client Dream Id', fieldName: 'AccountDreamId' },
    { label: 'Client Name ', fieldName: 'AccountName'}, 
    { label: 'Country', fieldName: 'Country'}, 
    { label: 'Origin', fieldName: 'Origin'},
    { label: 'Record Type', fieldName: 'RecordType'},
];

// const columnsVideoSession = [
//     { label: 'Video Session Member Id', fieldName: 'Id' } ,
//     { label: 'Video Session Member Name', fieldName: 'Name' } ,
//     { label: 'Client Dream Id', fieldName: 'AccountDreamId' },
//     { label: 'Client Name ', fieldName: 'AccountName'}, 
  
// ];

export default class ICX_CSVImport extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track error;
    @track columnsCase = columnsCase;
    // @track columnsVideoSession = columnsVideoSession;
    @track data;
    @track isLoading = false;
    @track isSuccess = false;
    @track isDPCA = false;
    // @track isVideoSession = false;
    @track getCurrentFile;
    @track getResultVal ;
    @track isErrFile = false;

    //Send email button
    isDisabled = false;

    // accepted parameters
    get acceptedCSVFormats() {
        return ['.csv'];
    }
    
    get isGetCurrentFile() {
        return ((this.getCurrentFile != null) && !(this.isErrFile == true));
    }

    handleMissingEmailDownload() {
        const csvContent = this.getResultVal?.join("\n");
        const downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvContent);
        downloadElement.target = '_self';

        //Add random char to bypass caching issue
        const randomChar1 = String.fromCharCode(Math.floor(Math.random() * 26) + 'a'.charCodeAt(0));

        downloadElement.download = 'DpcaImportErrorReport'+randomChar1+'.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
      }

      ActionCreateDPCA(){
        createDPCA({contentDocumentId : this.getCurrentFile})
        .then(result => {
               let lstDPCA = [];
               result.forEach(mycase => {
               let myDPCA = {};
               myDPCA.AccountDreamId = mycase.Account.DREAMID__c;
               myDPCA.AccountName = mycase.Account.Name;
               myDPCA.RecordType = mycase.RecordType.Name;
               myDPCA.Id = mycase.Id;
               myDPCA.Status = mycase.Status;
               myDPCA.Country = mycase.Country__c;
               myDPCA.Origin = mycase.Origin;
               lstDPCA.push(myDPCA);            
           });

            this.data = lstDPCA;  
            this.isDPCA = true;       
            this.isSuccess  = true;
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Operation compeleted successfully !',
                    variant: 'Success',
                }),
            );

            this.isDisabled = true;
        })
        .catch(error => {
            this.error = error;
            this.isSuccess  = false;
            this.isLoading = false;
          
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please respect the import file format, '+this.error.body.message,
                    variant: 'error',
                }),
            );     
        })

        //Reload function not implemented yet
        // setTimeout(function() {
        //     window.location.reload();
        // }, 5000);
        // window.location.reload();
      }

    uploadFileHandler(event) {
        console.log('objectApiName : ' +this.objectApiName);  
        console.log('recordId : ' +this.recordId);        
        sessionStorage.setItem('contentDocumentIdSession',uploadedFiles[0].documentId);

        // Get the list of records from the uploaded files
        const uploadedFiles = event.detail.files;
        //spinner disabled
           this.isLoading = true;
        // calling apex class csvFileread method
        // Video Session way not used yet
        /* if(this.objectApiName=='Video_Session__c'){
            createVideoSessionMember({contentDocumentId : uploadedFiles[0].documentId,videoSessionId:this.recordId})
            .then(result => {
                   let lstVideoSessionMembers= [];
                   result.forEach(videoSessionMember => {
                   let myVideoSessionMember = {};
                   myVideoSessionMember.AccountDreamId = videoSessionMember.Client__r.DREAMID__c;
                   myVideoSessionMember.AccountName = videoSessionMember.Client__r.Name;
                   myVideoSessionMember.Name = videoSessionMember.Name;
                   myVideoSessionMember.Id = videoSessionMember.Id;
                  
                   lstVideoSessionMembers.push(myVideoSessionMember);            
               });
    
                this.data = lstVideoSessionMembers;  
                this.isVideoSession = true;       
                this.isSuccess  = true;
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Video Session Members are created for current Video Session !',
                        variant: 'Success',
                    }),
                );
            })
            .catch(error => {
                this.error = error;
                this.isSuccess  = false;
                this.isLoading = false;
              
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'FILE FORMAT ERROR : ',
                        variant: 'error',
                    }),
                );     
            })
          }else{*/
            createDPCA({contentDocumentId : uploadedFiles[0].documentId})
        .then(result => {
               let lstDPCA = [];
               result.forEach(mycase => {
               let myDPCA = {};
               myDPCA.AccountDreamId = mycase.Account.DREAMID__c;
               myDPCA.AccountName = mycase.Account.Name;
               myDPCA.RecordType = mycase.RecordType.Name;
               myDPCA.Id = mycase.Id;
               myDPCA.Status = mycase.Status;
               myDPCA.Country = mycase.Country__c;
               myDPCA.Origin = mycase.Origin;
               lstDPCA.push(myDPCA);            
           });

            this.data = lstDPCA;  
            this.isDPCA = true;       
            this.isSuccess  = true;
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Operation compeleted successfully !',
                    variant: 'Success',
                }),
            );
        })
        .catch(error => {
            this.error = error;
            this.isSuccess  = false;
            this.isLoading = false;
          
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please respect the import file format, '+this.error.body.message,
                    variant: 'error',
                }),
            );     
        })
//    }
    }

    uploadFileHandlerPreUpload(event){
        // Get the list of records from the uploaded files
        const uploadedFiles = event.detail.files;
        this.getCurrentFile = uploadedFiles[0].documentId;

        //spinner disabled
           this.isLoading = true;       
            createDPCAPreupload({contentDocumentId : uploadedFiles[0].documentId})
        .then(result => {
            this.getResultVal = result;

            if(result.length > 0)
                this.isErrFile = true;

           this.isDPCA = true;     
           this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.isSuccess  = false;
            this.isLoading = false;
          
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Please respect the import file format, '+this.error.body.message,
                    variant: 'error',
                }),
            );     
        })
   }
    }
// }