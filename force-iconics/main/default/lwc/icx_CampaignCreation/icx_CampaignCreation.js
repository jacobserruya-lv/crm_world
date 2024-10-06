import { LightningElement,wire,track } from 'lwc';
import { getObjectInfo,getPicklistValues } from "lightning/uiObjectInfoApi";
import { deleteRecord } from 'lightning/uiRecordApi';


import createCampaign from '@salesforce/apex/ICX_CampaignCreationController.createCampaign';
import createCampaignContentDocumentLink from '@salesforce/apex/ICX_CampaignCreationController.createCampaignContentDocumentLink';
import createCampaignCatalogItem from '@salesforce/apex/ICX_CampaignCreationController.createCampaignCatalogItem';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";


import CAMPAIGN_OBJECT from "@salesforce/schema/Campaign__c";
import PRIORITY_FIELD from "@salesforce/schema/Campaign__c.Priority__c";
import COUNTRY_FIELD from "@salesforce/schema/Campaign__c.Country__c";



export default class Icx_CampaignCreation extends NavigationMixin(LightningElement) {
    @track campaignRecordTypeId;
    @track countryOptions;
    @track priorityOptions;


    @track campaignNameValue;
    @track descriptionValue;
    @track startDateValue;
    @track endDateValue;
    @track countryValue;
    @track priorityValue;
    @track toolkitCommentValue;
    @track toolkitIdList=[];
    @track contentVersionList=[];
    @track productSKUList=[];

    nbStep=2;
    @track stepPosition=1; 

    imageExtensions = ['png','jpg','gif','jpeg'];
    supportedIconExtensions = ['ai','attachment','audio','box_notes','csv','eps','excel','exe',
                        'flash','folder','gdoc','gdocs','gform','gpres','gsheet','html','image','keynote','library_folder',
                        'link','mp4','overlay','pack','pages','pdf','ppt','psd','quip_doc','quip_sheet','quip_slide',
                        'rtf','slide','stypi','txt','unknown','video','visio','webex','word','xml','zip'];


    @wire(getObjectInfo, { objectApiName: CAMPAIGN_OBJECT })
    results({ error, data }) {
      if (data) {
        this.campaignRecordTypeId = data.defaultRecordTypeId;

      } else if (error) {
        console.log('nao error campaignRecordTypeId ',error)

      }
    }

    @wire(getPicklistValues, { recordTypeId: "$campaignRecordTypeId", fieldApiName: COUNTRY_FIELD })
    picklistCountryResults({ error, data }) {
        if (data) {
        this.countryOptions = data.values;

        } else if (error) {
            console.log('nao error countryOptions ',error)
        }
    }


    @wire(getPicklistValues, { recordTypeId: "$campaignRecordTypeId", fieldApiName: PRIORITY_FIELD })
    picklistPriorityResults({ error, data }) {
        if (data) {
        this.priorityOptions = data.values;

        } else if (error) {
            console.log('nao error priorityOptions ',error)
        }
    }



    //handle func

    handleCampaigneNameChange(event)
    {
        this.campaignNameValue = event.target.value;
        console.log('nao this.campaignNameValue ',this.campaignNameValue  )

    }
    handleDescriptionChange(event)
    {
        this.descriptionValue = event.target.value;
    }
    handleStartDateChange(event)
    {
        this.startDateValue = event.target.value;
        console.log('nao this.startDateValue ',this.startDateValue  )
    }
    handleEndDateChange(event)
    {
        this.endDateValue = event.target.value;
    }
    handleCountryChange(event)
    {
        this.countryValue = event.target.value;
        console.log('nao this.countryValue ',this.countryValue  )

    }
    handlePriorityChange(event)
    {
        this.priorityValue = event.target.value;
    }
    handleToolkitCommentChange(event)
    {
        this.toolkitCommentValue = event.target.value;
    }
   
   

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log('No. of files uploaded : ' + uploadedFiles.length);
        console.log('nao file  : ' + JSON.stringify(uploadedFiles));
        try{
            

            for(let i=0; i<uploadedFiles.length;i++)
                { 
                    const duplicate = this.checkDuplicateFile(uploadedFiles[i]);
                    if(!duplicate)
                    {

                        let currentContentVersion ={};
                        currentContentVersion.Id =uploadedFiles[i].contentVersionId;
                        currentContentVersion.ContentDocumentId =uploadedFiles[i].documentId;
                        currentContentVersion.Title = uploadedFiles[i].name.split('.')[0];
                        currentContentVersion.FileExtension = uploadedFiles[i].name.split('.')[1];
                        currentContentVersion.Size='';
                        
                        if(this.imageExtensions.includes(currentContentVersion.FileExtension)){
                            currentContentVersion.icon = 'doctype:image';
                        }else{
                            if(this.supportedIconExtensions.includes(currentContentVersion.FileExtension)){
                                currentContentVersion.icon = 'doctype:' + currentContentVersion.FileExtension;
                            }
                            else
                            file.icon ='doctype:unknown';
                    }
                    this.contentVersionList.push(currentContentVersion);
                    this.initiateToolkitIdList();
                }
                else
                {
                    this.deleteRecord(uploadedFiles[i].documentId);
                    const evt = new ShowToastEvent({
                        title: "Duplicate",
                        message: "This file is already uploaded",
                        variant: "error",
                      });
                      this.dispatchEvent(evt);
                }
            }
        }
        catch(error)
        {
            console.error('nao error on uplode file', error);
        }

    }



    handleNext()
    {
        this.stepPosition+=1;
    }
    handleBack()
    {
        this.stepPosition-=1;

    }
    

    handleDeleteFile(event)
    {
        this.contentVersionList = this.contentVersionList.filter(contentVersion => contentVersion.Id!=event.detail);
        this.initiateToolkitIdList();
        console.log('nao this.contentVersionList remove',this.contentVersionList);
    }
    handleProductSKUList(event)
    {
        console.log('nao this.productSKUList parent event', event.detail);

        this.productSKUList = JSON.parse(event.detail);
        console.log('nao this.productSKUList parent', this.productSKUList);
        console.log('nao this.productSKUList[0] parent', this.productSKUList[0]);

    }

    handleCreate(event)
    {

        event.target.disabled = true;
        createCampaign({campaignName:this.campaignNameValue,description:this.descriptionValue,startDate:this.startDateValue,endDate:this.endDateValue,country:this.countryValue,priority:this.priorityValue,toolkitComment:this.toolkitCommentValue})
        .then(campaignResult=>{

            if(campaignResult)
            {

                createCampaignCatalogItem({campaignId:campaignResult,productSKUList:this.productSKUList})
                .then(productResult =>
                {
                    if(productResult)
                    {
                        if(this.toolkitIdList.length>0)
                        {
                            createCampaignContentDocumentLink({campaignId:campaignResult,contentDocumentList:this.toolkitIdList})
                            .then(documentResult=>
                            {
                                if(documentResult)
                                {
                                    const evt = new ShowToastEvent({
                                        title: "Success",
                                    message: "Campaign created !",
                                    variant: "success",
                                    });
                                    this.dispatchEvent(evt);
                                
                                    this[NavigationMixin.Navigate]({
                                        type: "standard__recordPage",
                                        attributes: {
                                            recordId: campaignResult,
                                            objectApiName: "Campaign__c", 
                                            actionName: "view",
                                        },
                                    });

                                }
                                else
                                {
                                    const evt = new ShowToastEvent({
                                        title: "Error",
                                        message: "There was a an error during campaign creation, please try again later. If it is persist, contact your administator",
                                        variant: "error",
                                    });
                                    this.dispatchEvent(evt);

                                    this.deleteRecord(campaignResult);
                                    for(let i=0;i<productResult.length;i++)
                                    {
                                        this.deleteRecord(productResult[i]);
                                    }

                                }
                            })
                            .catch(error=>{
                                console.error('campaign content document link creation error',error);
                                const evt = new ShowToastEvent({
                                    title: "Error",
                                    message: error,
                                    variant: "error",
                                });
                                this.dispatchEvent(evt);
                                this.deleteRecord(campaignResult);
                                for(let i=0;i<productResult.length;i++)
                                {
                                    this.deleteRecord(productResult[i]);
                                }
                            })
                        }
                        else
                        {
                            const evt = new ShowToastEvent({
                                title: "Success",
                            message: "Campaign created !",
                            variant: "success",
                            });
                            this.dispatchEvent(evt);
                        
                            this[NavigationMixin.Navigate]({
                                type: "standard__recordPage",
                                attributes: {
                                    recordId: campaignResult,
                                    objectApiName: "Campaign__c", 
                                    actionName: "view",
                                },
                            });
                        }
                    }
                    else
                    {
                        const evt = new ShowToastEvent({
                            title: "Error",
                            message: "There was a an error during campaign creation, please try again later. If it is persist, contact your administator",
                            variant: "error",
                        });
                        this.dispatchEvent(evt);
                        this.deleteRecord(campaignResult);
                    }

                })
                .catch(error=>{
                    console.error('campaign catalog item creation error',error);
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: error,
                        variant: "error",
                    });
                    this.dispatchEvent(evt);
                    this.deleteRecord(campaignResult);                
                })

            }
            else
            {
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: "There was a an error during campaign creation, please try again later. If it is persist, contact your administator",
                    variant: "error",
                });
                this.dispatchEvent(evt);
            }
        })
        .catch(error=>{
            console.error('campaign creation error',error);
            const evt = new ShowToastEvent({
                title: "Error",
                message: error,
                variant: "error",
            });
            this.dispatchEvent(evt);
        })
        .finally(() => {
            event.target.disabled = false;
          })
    }

 
    

    // get func
    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg'];
    }


    get isFirstStep()
    {
        return this. stepPosition<this.nbStep;

    }

    get isNextDisabled()
    {
        if(this.getIsNotBlank(this.campaignNameValue)  && this.getIsNotBlank(this.startDateValue) && this.getIsNotBlank(this.endDateValue) && this.getIsNotBlank(this.countryValue) && this.getIsNotBlank(this.priorityValue))
        {
            return false;
        }
        return true;
    }
    get isCreateDisabled()
    {

        return !this.productSKUList?.length>0;
    }
    get isFileAvailable()
    {
        return this.contentVersionList? this.contentVersionList.length>0 ? true:false:false;    

    }

    
    //help func
    getIsNotBlank(value)
    {
        return value!=null && value!='';
    }

    initiateToolkitIdList()
    {
        this.toolkitIdList=[];
        for(let i=0;i<this.contentVersionList.length;i++)
        {
            this.toolkitIdList.push(this.contentVersionList[i].ContentDocumentId);
        }
    }

    checkDuplicateFile(contentVersionFile)
    {
        return this.contentVersionList.filter(contentVersion => contentVersion.Title ==contentVersionFile.name.split('.')[0] && contentVersion.FileExtension == contentVersionFile.name.split('.')[1]).length>0;

    }
    async deleteRecord(recordId)
    {
        await deleteRecord(recordId);
    }

    

    
}