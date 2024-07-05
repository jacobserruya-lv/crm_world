import { LightningElement,track,wire,api } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';
import getCareServiceRecords from '@salesforce/apex/ICX_Client360_SF.getCareServiceRecords';
import { profilesCheckout } from 'c/utils';
import USER_ID from '@salesforce/user/Id';
import getUserProfileId from '@salesforce/apex/ICX_Client360_SF.getUserProfileId';
import { NavigationMixin } from 'lightning/navigation';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {ToastError } from 'c/utils';

import CS_OBJECT from "@salesforce/schema/CareService__c";

export default class Icx_dreamCareServiceSF extends NavigationMixin(LightningElement){

    @api recordId;
    @track listStoreCareService = [];
    @track listDistantCareService = [];
    @track tableDataStoreCareService = [];
    @track tableDataDistantCareService =[];
    @track listStoreCareServiceSize = 0;
    @track listDistantCareServiceSize = 0;
    @track editcareService;
    @track createcareService;
    @track deleteRecordIdSelected;
    @track isDialogVisibleConfirm;
    @track deletecareService;
    @track userProfileId;
    @track recordList = [];
    @track pageIndex = 0;
    isViewMoreButton = true;
    isOtherDataType;
    isLoadingDistantCareService = true;
    isLoadingMoreDistantCareService = false;
    isLoadingMoreStoreCareService = false;
    counter = 0;
    isLoadingStoreCareService = true;
    distantCareServiceOffset = 0;
    distantCareServiceLimit = 4;
    storeCareServiceOffset = 0;
    storeCareServiceLimit = 4;
    percentOnScroll = 50;
    myTextClass;
    myTextClassBold;

    @track isMoreDistantCareService = true;
    @track isMoreStoreCareService = true;

    error;

    objectInfo;
    objectName = 'CareService__c';
    conditionStoreCareService = 'WHERE Client__c =: accountId';

    conditionDistantCareService = 'WHERE Client__c =: accountId';


    @wire(getObjectInfo, { objectApiName: CS_OBJECT })
    objectInfo;

@wire(getUserProfileId, { userId: USER_ID})
wiredgetUserProfileId({ error, data }) {

    if (data) {
        this.userProfileId = data

        console.log('userProfileId',this.userProfileId);

    }
    
    if (error) {
        console.error(error);
    }
}



handleResultCareService(result,listCareService)
{
    let tempLength = listCareService.length;
    for (let i = 0; i < result.length; i++) {
        listCareService.push(result[i]);
        for(let j=0; j<listCareService[i].item.length; j++)
        {
        

            if(listCareService[tempLength+i].item[j].type=='image-html' &&  new DOMParser().parseFromString(listCareService[tempLength+i].item[j].value, "text/html").querySelector("img").getAttribute('src')==' ' )
            {

                listCareService[tempLength+i].item[j].value='<img src="https://fr.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louis%20vuitton--12345_PM2_Front%20view.jpgz" alt="image not available" style="height:100px; width:100px;" border="0"/>';
                console.log(listCareService[tempLength+i].item[j].value);
            }
        }
    }
}

connectedCallback() {

        //define distant and store title
        this.tableDataDistantCareService.title = {
            type: 'text',
            label: 'Distant Care Service',
            iconSrc: imagesResource + `/images/client360/careServiceIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            hasLength:true,
            length:this.listDistantCareServiceSize
        }
    
        
        this.tableDataStoreCareService.title = {
            type: 'text',
            label: 'Store Care Service',
            iconSrc: imagesResource + `/images/client360/careServiceIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            hasLength:true,
            length:this.listStoreCareServiceSize
            
        }
      

    //     if(this.objectInfo.data)
    //     {

        
    //     console.log('nao this.objectInfo', this.objectInfo);
    //     console.log('nao this.objectInfo.data',this.objectInfo.data);
    //         const recTyps = this.objectInfo.data.recordTypeInfos;
        
    
    // this.conditionStoreCareService = 'WHERE Client__c =: accountId AND RecordTypeId = \''+    Object.keys(recTyps).find(recTyp => recTyps[recTyp].name == 'Store Care Service')+'\'';
    // this.conditionDistantCareService = 'WHERE Client__c =: accountId AND RecordTypeId =\''+    Object.keys(recTyps).find(recTyp => recTyps[recTyp].name == 'Distant Care Service')+'\'';
    // console.log('this.conditionStoreCareService ',this.conditionStoreCareService );

    // console.log('this.conditionDistantCareService ',this.conditionDistantCareService );
    // getrecordsListSize({accountId:this.recordId ,objectName:this.objectName,condition:this.conditionStoreCareService})
    // .then((result) => {
    //     console.log(' store care service length ',result);

    //     this.listStoreCareServiceSize = result;
    //     this.tableDataStoreCareService.title.length = this.listStoreCareServiceSize;

    // })
    // .catch((error) => {


    //     console.error(' store care service length error',error);
        
    // });
    // getrecordsListSize({accountId:this.recordId ,objectName:this.objectName,condition:this.conditionDistantCareService})
    // .then((result) => {
    //     console.log(' distant care service length ',result);

    //     this.listDistantCareServiceSize = result;
    //     this.tableDataDistantCareService.title.length = this.listDistantCareServiceSize;


    // })
    // .catch((error) => {


    //     console.error(' distant care service length error',error);
        
    // });

    //     }



    //get distant care service, 1st iteration
    getCareServiceRecords({ accountId: this.recordId,myLimit:this.distantCareServiceLimit ,myOffset:this.distantCareServiceOffset,type:'Distant'})
        .then((result) => {
       
            this.error = undefined;
            this.isLoadingDistantCareService = false;
            console.log(' distance care service callback result' , result)
           let tempResult = JSON.parse(JSON.stringify(result)); //need to create a deep copy to be able to change the value wich is in read only in the result
           this.handleResultCareService(tempResult, this.listDistantCareService);


        //    this.tableDataDistantCareService.title.length = this.listDistantCareService.length;

            console.log(' distance care service callback result after img generation' , this.listDistantCareService)


       
    
        })
        .catch((error) => {
            this.isLoadingDistantCareService = false;
    
            this.error = error;    
            //this.listDistantCareService = undefined;
    
            console.log('wire distant care service error',this.error);
            
        });


        //get store care service, 1st iteration
        getCareServiceRecords({ accountId: this.recordId,myLimit:this.storeCareServiceLimit ,myOffset:this.storeCareServiceOffset,type:'Store'})
        .then((result) => {
       
            this.error = undefined;
            this.isLoadingStoreCareService = false;
            console.log(' store care service callback result' , result)


            let tempResult = JSON.parse(JSON.stringify(result)); //need to create a deep copy to be able to change the value wich is in read only in the result
            this.handleResultCareService(tempResult, this.listStoreCareService );
 
            // this.tableDataStoreCareService.title.length = this.listStoreCareService.length;
            console.log(' store care service callback result after img generation' , this.listStoreCareService)

    
        })
        .catch((error) => {
            this.isLoadingStoreCareService = false;
    
            this.error = error;    
           // this.listStoreCareService = undefined;
    
            console.log('wire store care service error',this.error);
            
        });




    // event on scroll window to load more records
    window.addEventListener('scroll', event => 
    {
        const scrollable = document.documentElement.scrollHeight - window.innerHeight; 
        const scrolled = Math.ceil(window.scrollY);
        const fireScrollEvent = Math.ceil((this.percentOnScroll / 100) * scrollable) ;
        console.log('scrollable',scrollable);
        console.log('fireScrollEvent',Math.ceil(fireScrollEvent));
        console.log('scrolled',scrolled);
        
        
        if(scrolled >= Math.ceil(fireScrollEvent) && !this.isLoadingMoreDistantCareService && !this.isLoadingMoreStoreCareService)
        {
            console.log('Now loading is needed');
            this.distantCareServiceOffset+=this.distantCareServiceLimit;
            this.storeCareServiceOffset+=this.storeCareServiceLimit;
            

            //get distant care service after event scroll
            if(this.isMoreDistantCareService)
            {
                this.isLoadingMoreDistantCareService=true;
                getCareServiceRecords({ accountId: this.recordId,myLimit:this.distantCareServiceLimit ,myOffset:this.distantCareServiceOffset,type:'Distant'})
                .then((result) => {
                    console.log(' result care service scroll' , result);
                    console.log('This is the updated offSet');
                    console.log(' this.listDistantCareService before ', this.listDistantCareService)

                  
                    
                    let tempResult = JSON.parse(JSON.stringify(result)); //need to create a deep copy to be able to change the value wich is in read only in the result
                    this.handleResultCareService(tempResult, this.listDistantCareService );
         
                    

                    // this.tableDataDistantCareService.title.length = this.listDistantCareService.length;

                   
                    console.log(' this.listStoreCareService after ', this.listDistantCareService)
                    
                    this.distantCareServiceOffset+=this.distantCareServiceLimit;
                    
                    if( result.length<this.distantCareServiceLimit)
                    {
                        this.isMoreDistantCareService=false;
                    }
                    this.error = undefined;
                    this.isLoadingMoreDistantCareService=false;
                    
                })
                .catch((error) => {
                    console.error(error);
                    this.isLoadingMoreDistantCareService=false;

                });
            }
            

            //get store care service after event scroll

            if(this.isMoreStoreCareService)
            {
                
                this.isLoadingMoreStoreCareService = true;
                getCareServiceRecords({ accountId: this.recordId ,myLimit:this.storeCareServiceLimit ,myOffset:this.storeCareServiceOffset ,type:'Store'})
                .then((result) => {
                    
                    console.log(' result care service scroll' , result);
                    console.log('This is the updated offSet');
                    console.log(' this.listStoreCareService before ', this.listStoreCareService)
                    
                    let tempResult = JSON.parse(JSON.stringify(result)); //need to create a deep copy to be able to change the value wich is in read only in the result
                    this.handleResultCareService(tempResult, this.listStoreCareService );
         
    
                    // this.tableDataStoreCareService.title.length = this.listStoreCareService.length;

                    
                    console.log(' this.listStoreCareService after ', this.listStoreCareService)
                    
                    this.storeCareServiceOffset+=this.storeCareServiceLimit;
                    
                    if( result.length<this.storeCareServiceLimit)
                    {
                        this.isMoreStoreCareService=false;
                    }
                    this.isLoadingMoreStoreCareService = false;
                    this.error = undefined;
                })
                .catch((error) => {
                    console.error(error);
                    this.isLoadingMoreStoreCareService = false;
                });
            }
            
        }
    });
    
    
    profilesCheckout("CareService__c" ) .then(result => {
        let careServiceAuth = result;
        // this.editcareService = JSON.parse(careServiceAuth).PermissionsEdit;
        // this.deletecareService = JSON.parse(careServiceAuth).PermissionsDelete;
        // this.createcareService =  JSON.parse(careServiceAuth).PermissionsCreate;
     
    })
    .catch(error => {
        console.error(' error utils:' + error);
    });        

}

renderedCallback()
{
    if(this.objectInfo.data)
    {

    
   
        const recTyps = this.objectInfo.data.recordTypeInfos;
    

this.conditionStoreCareService = 'WHERE Client__c =: accountId AND RecordTypeId = \''+    Object.keys(recTyps).find(recTyp => recTyps[recTyp].name == 'Store Care Service')+'\'';
this.conditionDistantCareService = 'WHERE Client__c =: accountId AND RecordTypeId =\''+    Object.keys(recTyps).find(recTyp => recTyps[recTyp].name == 'Distant Care Service')+'\'';
console.log('this.conditionStoreCareService ',this.conditionStoreCareService );

console.log('this.conditionDistantCareService ',this.conditionDistantCareService );
getrecordsListSize({accountId:this.recordId ,objectName:this.objectName,condition:this.conditionStoreCareService})
.then((result) => {
    console.log(' store care service length ',result);

    this.listStoreCareServiceSize = result;
    this.tableDataStoreCareService.title.length = this.listStoreCareServiceSize;

})
.catch((error) => {


    console.error(' store care service length error',error);
    
});
getrecordsListSize({accountId:this.recordId ,objectName:this.objectName,condition:this.conditionDistantCareService})
.then((result) => {
    console.log(' distant care service length ',result);

    this.listDistantCareServiceSize = result;
    this.tableDataDistantCareService.title.length = this.listDistantCareServiceSize;


})
.catch((error) => {


    console.error(' distant care service length error',error);
    
});

    }

}



get isLoading()
{
    return this.isLoadingDistantCareService || this.isLoadingStoreCareService ? true : false;
 }
 

 activateModalDistant(event)
    {
       
        const recordObject = this.listDistantCareService[event.detail];
        const {Id} = recordObject;
        this.deleteRecordIdSelected = Id;
  
        if(this.deleteRecordIdSelected)
        {
            this.isDialogVisibleConfirm = true;
        }
    }

 activateModalStore(event)
    {
        const recordObject = this.listStoreCareService[event.detail];
        const {Id} = recordObject;
        this.deleteRecordIdSelected = Id;
  
        if(this.deleteRecordIdSelected)
        {
            this.isDialogVisibleConfirm = true;
        }
    }

    handelCancelEvent(evt)
    {
        this.isDialogVisibleConfirm = false;
    }

    handleStoreEditNavigation(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                recordId: this.listStoreCareService[event.detail].Id,
                objectApiName: 'CareService__c',
                actionName: 'edit'
            },
        });
    }

    handleDistantEditNavigation(event){
        console.log('nap dcs edit navigation',this.listDistantCareService[event.detail].Id)
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                recordId: this.listDistantCareService[event.detail].Id,
                objectApiName: 'CareService__c',
                actionName: 'edit'
            },
        });
    }

    navigateToStoreCareService(event){
        let careServiceId = this.listStoreCareService[event.detail].Id;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: careServiceId,
                    objectApiName: 'CareService__c',
                    actionName: 'view'
                },
            });
     }

 navigateToDistantCareService(event){
    let careServiceId = this.listDistantCareService[event.detail].Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: careServiceId,
                objectApiName: 'CareService__c',
                actionName: 'view'
            },
        });
 }









}