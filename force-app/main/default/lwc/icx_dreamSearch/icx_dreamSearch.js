/*
Author : Naomi Baroghel
Created Date : 24/05/2022
Description : search for read only app DREAM
*/


import { LightningElement,wire,track } from 'lwc';

import getSearchResults from '@salesforce/apex/icx_Client360_API.getSearchResults';
import getAdvancedSearchResults from '@salesforce/apex/icx_Client360_API.getAdvancedSearchResults';
import getCountry from '@salesforce/apex/ICX_Client360_SF.getCountry';
import getStore from '@salesforce/apex/ICX_Client360_SF.getStore';
import getMember from '@salesforce/apex/ICX_Client360_SF.isGroupMember';
import getPhoneCode from '@salesforce/apex/ICX_Client360_SF.getPhoneCode';
import sendToMerge from '@salesforce/apex/ICX_WS_Manual_Merge.Merge_TECH_IntegrationManager_Creation';
import getAccount from '@salesforce/apex/ICX_Client360_SF.getAccount';
import iconResource from '@salesforce/resourceUrl/iconics';
import dreamSearch from '@salesforce/resourceUrl/dreamSearch';
import USER_ID from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/ICX_Account_Highlight.getUserInfo';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';



import { isEmpty,invokeWorkspaceAPI ,ToastError,dateFormat2 } from 'c/utils';



import imagesResource from '@salesforce/resourceUrl/iconics';


import { NavigationMixin } from 'lightning/navigation';


export default class Icx_dreamSearch extends NavigationMixin(LightningElement)  {
    searchKey ='';
    @track searchData = undefined;
    @track locationpage = undefined; 
    @track tableData= [];
    @track searchDataLenght;
    @track isMergeModalOpen = false;
    @track MergesSuccessModal = false;
    @track MyLVModalError = false;
    @track MyLVError = false;
    @track GMBlueError = false;
    @track GMGreenError = false;
    @track isExpanded = false;
    @track mainHeader = undefined;
    @track container = undefined; 
    @track displayHeader = false;
    @track backButtonDisplay = undefined;
    @track backgroundHearder  = undefined ;
    @track filterButton = false;
    isLoading = false;
    errorMsg;
    userDetails;
    advancedSearch = false;
    dreamAccountClient = true;
    countryList = [ {label: "",value: "empty"}];
    storeList = [ {label: "",value: "empty"}];
    phoneCodeList = [];
    phoneCodeValue;
    isUserIconics;
    flagValidation = true;
    suggestionResult=[];
    origin = 'searchPage';
    isCheckboxType =true;
    clientsDetails = []; 
    isMemberOfGroup;
    meregActionResponse;
    jsonMergefile;
    clientCountry ;
    clientStore;   
    memberDetails;
    tempStr1;
    tempStr2;
    upDateRes;
    storeValue;



   

    get backgrounddisplay(){
  
        if (this.displaySearch){ 
            console.log('in fonction return the url background ') ; 
            return `background-image: url('/resource/iconics/images/client360/backgroundCloud2.jpg');background-repeat: no-repeat;background-position: center;background-size: cover;height: 80vh; display: flex; align-content: space-between; justify-content: center; flex-direction: column;`;
            

        }if (this.advancedSearch){

            this.backgroundHearder = `background-image: url('/resource/iconics/images/client360/headerAdvancedSearch.png')`;
            return `background-color: #ffffff`;
            
        } if (this.searchData){
            this.backgroundHearder =   `background: #F5F5F3;` ;
            return `background-color: #ffffff`;
        } else {
     
            return `background-color: #ffffff`;}
    }
    

    @track searchRequest = {"c360GoldenId": null,"worldwideId": null,"dreamId": null,"salesforceId": null,"userIdentitySalesforceId": null,"atgId": null,"rmsLocalId": null,"firstName": null,"lastName": null,"firstName2": null,"lastName2": null,"birthDate": null,"passportNumber": null,"fiscalNumber": null,"emailAddress": null,"phoneNumber": null,"residencePostalAddress": null,"greyMarketStatusDate": null,"lastContactDate": null,"serialNumber": null,"lockNumber": null};



    @wire(getUserInfo, { userId : USER_ID  })
   wiredgetUserInfo({ error, data }) 
   {
    this.userDetails = data;
    this.error = undefined;

    if(this.userDetails && this.userDetails.Profile.Name.includes('Client 360'))
    {
        this.isUserIconics = true;

    }
    else{
        console.error(error);
    }
   }

   @wire(getMember,{userId: USER_ID})
   wiregetMember({error,data})
   {
    this.memberDetails = data;

    if(this.memberDetails)
    {
      this.isMemberOfGroup = true;
    }
    else{
        console.error(error);
    }

   }

   get permissionToMerge(){
        return  this.isMemberOfGroup;
   }


    handleFormInputChange(event){
        this.searchRequest[event.target.name] = isEmpty(event.target.value)? null : event.target.value;
    }
    handleFormInputChangeAddress(event){
        if(!this.searchRequest['residencePostalAddress'])
        {
            this.searchRequest['residencePostalAddress'] =  {"addressLine1": null,"addressLine2": null,"addressLine3": null,"countryCodeIso": null,"state": null,"city": null,"postalCode": null}; 
        }
        this.searchRequest['residencePostalAddress'][event.target.name] = isEmpty(event.target.value)? null : event.target.value;

        if( this.searchRequest['residencePostalAddress'] )
        {
            let flagBlank=true;
            for (let key in this.searchRequest['residencePostalAddress'])
            {
                if(this.searchRequest['residencePostalAddress'][key]!=null)
                {

                    flagBlank=false;
                }
            }
            if(flagBlank)
            {
                this.searchRequest['residencePostalAddress'] = null;

            }
        }
        
    }
    handleFormInputChangePhone(event){
        this.searchRequest[event.target.name] = isEmpty(event.target.value)? null : this.phoneCodeValue+ event.target.value;
        console.log(' searchRequest phone : ', this.searchRequest);


    }
    handleFormInputChangePhoneCode(event){
        this.phoneCodeValue = event.target.value;
    }
    handleFormInputChanteDate(event)
    {

        if(!isEmpty(event.target.value))
        {
            
            this.searchRequest[event.target.name] =  new Date(Date.UTC(event.target.value.split('-')[0], event.target.value.split('-')[1], event.target.value.split('-')[2]))
        }
        else{
            this.searchRequest[event.target.name] = null
        }
        
    }
    
    closeMergeModal()
    {
        this.isMergeModalOpen = false;
    }
    closeMergeSuccessModal()
    {
        this.searchData=undefined;
        this.MergesSuccessModal =false;
    }

    closeMyLVModalError()
    {
        this.MyLVModalError = false;
        this.searchData=undefined;
  
    }
    
    connectedCallback(){
        loadStyle(this, dreamSearch + 'dreamSearch.css');
    }

   

    @wire(getCountry) 
    wiredCountry({error,data}) {
        if(data){

        for(let key in data){
            var item = {
                label: key,
                value: data[key]
            };
            this.countryList.push(item); 
        }
        this.countryList = this.countryList.sort((a,b) => a.label.localeCompare(b.label))
    }
        else{
            console.error(error);
        }
      }

    @wire(getStore) 
    wiredStore({error,data}) {
        if(data){

        for(let key in data){
            var item = {
                label: key,
                value: data[key]
            };
            this.storeList.push(item);       
        }


    }
        else{
            console.error(error);
        }
      }

      @wire(getPhoneCode) 
    wiredPhoneCode({error,data}) {
        if(data){
          for (let i = 0; i < data.length; i++) {
            var item = {
               label: '+'+data[i],
               value: '+'+data[i]
           };
           this.phoneCodeList.push(item);  
        }
        this.phoneCodeValue = this.phoneCodeList[0].value;
    }
        else{
            console.error(error);
        }
      }
    
    
      handleSearch(event)
      {
        let tableData = this.template.querySelectorAll("[data-id]").forEach(el => {
            if(el.dataset.id=='searchWord' && el.value!='')
            {
                this.searchKey = el.value;

            }
        })

          if(  this.searchKey != ''){
  
          this.isLoading = true;
          getSearchResults({searchRequest:this.searchKey})
              .then(result=>{


                if(!result.message)
                {

                    this.resultSearchFormat(JSON.parse(result));
                
                }
                else{
                    var errorJSON = JSON.parse(result.message);
                    console.error(errorJSON.errorMessage);
                    ToastError(errorJSON.errorMessage, this);

                }
           
  
  
              })
              .catch((error)=>{
                  ToastError(error, this);

                    console.error(error);
                  this.errorMsg = "Sorry, we encounter an error. Please try again later.";
                  this.searchData = undefined;

  
  
              })
              .finally(()=>{
  
                  this.isLoading = false;
              })
         
          }
  
  
   
      }

    
    handleKeySearch(event)
    {
        if(event.keyCode === 13 && event.target.value!= ''){

        this.isLoading = true;
        this.searchKey = event.target.value;
        getSearchResults({searchRequest:this.searchKey})
            .then(result=>{

                if(!result.message)
                {

                    this.resultSearchFormat(JSON.parse(result));
                }
                else{
                    var errorJSON = JSON.parse(result.message);
                    console.error(errorJSON.errorMessage);
                    ToastError(errorJSON.errorMessage, this);

                }                


            })
            .catch((error)=>{
                ToastError(error, this);

                console.error(error);

                this.errorMsg = "Sorry, we encounter an error. Please try again later.";
                this.searchData = undefined;



            })
            .finally(()=>{

                this.isLoading = false;
            })
       
        }


        //not for mvp
        //************suggestion part, cannot be used if we don't have limitation to 3 on the call api
        // else if(event.target.value.length>=3)
        // {
        //     console.log(' length>=3');
        //     this.searchKey = event.target.value;
        //     this.isLoading=true;
        //     getSearchResults({searchRequest:this.searchKey})
        //     .then(result=>{

        //         this.resultSuggestionSearch(JSON.parse(result));


        //     })
        //     .catch((error)=>{
        //         console.error(' error suggestion result', error);
        //        // this.resultSearchError(error);                


        //     })
        // }
    }

    
    handleAdvancedSearch(){




        let flagSearch = false;
        this.flagValidation = true;
        let querySelectorList = this.template.querySelectorAll("[data-field]").forEach(el => {

            if (!isEmpty(el.value)) {
                flagSearch = true;
            }

            if(!el.validity.valid)
            {

                this.flagValidation=false;
            }
        })
  
        
        if(flagSearch && this.flagValidation)
        {


            this.isLoading = true;

        getAdvancedSearchResults({searchRequest:JSON.stringify(this.searchRequest)})
            .then(result=>{

                if(!result.message)
                {

                    this.resultSearchFormat(JSON.parse(result));
                }
                else{
                    var errorJSON = JSON.parse(result.message);
                    console.error(errorJSON.errorMessage);
                    ToastError(errorJSON.errorMessage, this);

                }   


            })
            .catch((error)=>{
              

                ToastError(error, this);
                console.error(error);

                this.errorMsg = "Sorry, we encounter an error. Please try again later.";
                this.searchData = undefined;



            })
            .finally(()=>{

                this.isLoading = false;
                this.advancedSearch = false;
            })
       
       }
    }
    

    //not for mvp
    resultSuggestionSearch(result)
    {

        if(result.length>=1){
            this.suggestionResult=result.slice(0, 3);
            this.tableData.idList = this.suggestionResult.map(currentData => ( {
                dreamId: currentData.identifiers?currentData.identifiers.dreamId:'',
                Address : currentData.residencePostalAddress?.addressLine1?currentData.residencePostalAddress.addressLine1:'',
                salesforceId: currentData.identifiers?currentData.identifiers.salesforceId:'',
                Name : currentData.firstName +' '+ currentData.lastName
              } ));
        }
        this.isLoading = false;


    }
    get mergeIcon()
    {
        return iconResource + '/images/client360/mergeIcon.svg';
    }
    get rejectionIcon()
    {
        return iconResource + '/images/client360/Warning-Iconx2.png';
    }
    outsider()
    {

    }

    resultSearchFormat(result)
    {

        this.searchData = result;
        this.displayHeader = true ;
        this.backButtonDisplay = true; 
        this.locationpage = 'searchData' ;
        console.log('display results:::',this.searchData);

       

        if(this.searchData == null || this.searchData.length<1){
            let myError=[];
            myError.status=404;
            myError.message='Response return null';
            this.resultSearchError(myError);                

        }
        else if(this.searchData.statusCode!=null && this.searchData.statusCode=='400'){
            let myError=[];
            myError.status=400;
            myError.message=this.searchData.messageError;
            this.resultSearchError(myError);                

        }
        else {
        
        this.searchDataLenght = this.searchData.length;

        if(this.isMemberOfGroup)
        //    if(hasAuthtoMerge)
        {

            this.tableData.headers = [
                { type: 'text', label: 'Dream ID', isWithFilter: true},
                { type: 'text', label: 'Civility' },
                { type: 'text', label: 'Last Name'},
                { type: 'text', label: 'First Name' },
                { type: 'text', label: 'Address' },
                { type: 'text', label: 'MyLV Email' },
                { type: 'text', label: 'Email' },
    
                { type: 'text', label: 'Phone' },
                { type: 'text', label: 'Country/Region' },
                { type: 'text', label: 'Attached Store' },
                { type: 'text', label: 'Segmentation' },
                { type: 'checkbox', label:'Merge'},
              //  { type: 'text', label: 'Segmentation', isWithFilter: true },
              //  { type: 'text', label: 'Typology', isWithFilter: true },
                // { type: 'text', label: 'Merge', isWithFilter: false }
    
            ]
        }else{
            this.tableData.headers = [
                { type: 'text', label: 'Dream ID' },
                { type: 'text', label: 'Civility' },
                { type: 'text', label: 'Last Name'},
                { type: 'text', label: 'First Name' },
                { type: 'text', label: 'Address' },
                { type: 'text', label: 'MyLV Email' },
                { type: 'text', label: 'Email' },
    
                { type: 'text', label: 'Phone' },
                { type: 'text', label: 'Country/Region' },
                { type: 'text', label: 'Attached Store' },
                { type: 'text', label: 'Segmentation' },
              //  { type: 'text', label: 'Segmentation', isWithFilter: true },
              //  { type: 'text', label: 'Typology', isWithFilter: true },
                // { type: 'text', label: 'Merge', isWithFilter: false }
            ]
        }

        

        if(this.isMemberOfGroup)
        {

            console.log(' this.clientStoreArr', this.clientStoreArr);


            this.tableData.rows = this.searchData.map((currentData,key) => {
                return [
                    { value: currentData.identifiers?currentData.identifiers.dreamId:'', type: 'text', label: 'Dream ID',  class: 'dreamID' },
                    { value: currentData.civility?currentData.civility:'', type: 'text', label: 'Civility' },
                    { value: currentData.lastName, type: 'text', label: 'Last Name' },
                    { value: currentData.firstName, type: 'text', label: 'First Name' },
                    { value: currentData.residencePostalAddress?.addressLine1?currentData.residencePostalAddress.addressLine1:'', type: 'text', label: 'Address' },
                    { value: currentData.accounts?currentData.accounts.find(x => {return x.email != null})?.email:'',type: 'text', label: 'Email' },
                    { value: currentData.emailAddress?.emailAddress ,type: 'text', label: 'Email' },
                    { value: currentData.mobilePhoneNumber?currentData.mobilePhoneNumber.internationalPhoneNumber:'', type: 'text', label: 'Phone' },
                    { value: currentData.residencePostalAddress?.countryCodeIso? this.countryList.find(country=>country.value==currentData.residencePostalAddress.countryCodeIso).label:'', type: 'text', label: 'country' },
                    { value: currentData.forcedAttachmentStoreCode? this.storeList.find(store=>store.value==currentData.forcedAttachmentStoreCode)?.label :'', type: 'text', label: 'attachedStore' },
                    { value: currentData.segmentation?currentData.segmentation:'', type: 'text', label: 'segmentation' },
                    { 'isCheckboxType': true, type:'boolean', label:'Merge'},
                 ]
            });
        }
        else{
            this.tableData.rows = this.searchData.map((currentData,key) => {

                return [
                    { value: currentData.identifiers?currentData.identifiers.dreamId:'', type: 'text', label: 'Dream ID',  class: 'dreamID' },
                    { value: currentData.civility?currentData.civility:'', type: 'text', label: 'Civility' },
                    { value: currentData.lastName, type: 'text', label: 'Last Name' },
                    { value: currentData.firstName, type: 'text', label: 'First Name' },
                    { value: currentData.residencePostalAddress?.addressLine1?currentData.residencePostalAddress.addressLine1:'', type: 'text', label: 'Address' },
                    { value: currentData.accounts?currentData.accounts.find(x => {return x.email != null})?.email:'',type: 'text', label: 'Email' },
                    { value: currentData.emailAddress?.emailAddress ,type: 'text', label: 'Email' },
                    { value: currentData.mobilePhoneNumber?currentData.mobilePhoneNumber.internationalPhoneNumber:'', type: 'text', label: 'Phone' },
                    { value: currentData.residencePostalAddress?.countryCodeIso? this.countryList.find(country=>country.value==currentData.residencePostalAddress.countryCodeIso).label:'', type: 'text', label: 'country' },
                    { value: currentData.forcedAttachmentStoreCode? this.storeList.find(store=>store.value==currentData.forcedAttachmentStoreCode)?.label :'', type: 'text', label: 'attachedStore' },
                    { value: currentData.segmentation?currentData.segmentation:'', type: 'text', label: 'segmentation' },
                 //   { value: currentData.segmentation, type: 'text', label: 'Segmentation' },
                 //   { value: currentData.typology, type: 'text', label: 'Typology' }
    
                ]
            });
        }


        this.tableData.idList = this.searchData.map(currentData => ( {
            dreamId: currentData.identifiers?currentData.identifiers.dreamId:'',
            salesforceId: currentData.identifiers?currentData.identifiers.salesforceId:'',
            userIdentitySalesforceId: currentData.identifiers?currentData.identifiers.userIdentitySalesforceId:'',
            Name : currentData.firstName +' '+ currentData.lastName,
            firstName: currentData.firstName ,
            lastName: currentData.lastName,
            mobilePhoneNumber:currentData.mobilePhoneNumber?.internationalPhoneNumber?currentData.mobilePhoneNumber.internationalPhoneNumber:'00 00 00 00',
            MyLVEmail:currentData.accounts?currentData.accounts.find(x => {return x.email != null})?.email:'-',
            Email: currentData.emailAddress?currentData.emailAddress.emailAddress:'-',
            Address : currentData.residencePostalAddress?.addressLine1?currentData.residencePostalAddress.addressLine1:'-',            
            greyMarketStatus: currentData.greyMarketStatus,
            
          } )

        );

        this.errorMsg = undefined;
        this.advancedSearch = false;
        this.isLoading = false;
        //console.log('display tableData:::',this.tableData);

        // this.suggestionResult=undefined;
        }
    }

    callToMerge(event)
    {
        this.clientsDetails =[];
        let searchClientId;
        for(let i = 0 ; i < event.detail.length ; i++)
        {
            searchClientId = this.tableData.idList[event.detail[i]];
            this.clientsDetails.push(searchClientId);
        }
        console.log('Display client details',JSON.parse(JSON.stringify(this.clientsDetails)));
       

        this.isMergeModalOpen = true;
    }

    mergeConfirmation()
    {
        let blueflag=0;
        let redflag=0;
        let greenflag=0;
       
        let lvAccountNum = 0;
        this.MyLVError = false;
        this.GMBlueError = false;
        this.GMGreenError = false;
        for(let i =0 ;i < this.clientsDetails.length;i++)
        {
            console.log('this.clientsDetails[i].MyLVEmail',(this.clientsDetails[i].MyLVEmail));
            console.log('this.clientsDetails[i].userIdentitySalesforceId',(this.clientsDetails[i].userIdentitySalesforceId));
            console.log('this.clientsDetails[i].greyMarketStatus',(this.clientsDetails[i].greyMarketStatus));
            if(this.clientsDetails[i].greyMarketStatus && this.clientsDetails[i].greyMarketStatus?.toLowerCase()=='green')
            {
                greenflag+=1;
                //console.log('greenflag',greenflag);
            }
            if(this.clientsDetails[i].greyMarketStatus && this.clientsDetails[i].greyMarketStatus?.toLowerCase()=='blue')
            {
                blueflag+=1;
                //console.log('blueflag',blueflag);
            }
            if(this.clientsDetails[i].greyMarketStatus && this.clientsDetails[i].greyMarketStatus?.toLowerCase()=='red')
            {
                redflag+=1;
                //console.log('redflag',redflag);
            }
            // OLD CHECK For MyLV account by email if(this.clientsDetails[i].MyLVEmail && this.clientsDetails[i].MyLVEmail!='-')
            // The new check is based on the field userIdentitySalesforceId
            if(this.clientsDetails[i].userIdentitySalesforceId && this.clientsDetails[i].userIdentitySalesforceId!='')
            {
                lvAccountNum+=1;
            }
            console.log('lvAccountNum',lvAccountNum);
        }
        if(blueflag==1){
            //console.log('blueflag error to show: ',blueflag);
            this.MyLVModalError = true;
            this.GMBlueError=true;
        }
        else if(greenflag>=1 && redflag >=1){
            //console.log('green/red flag error to show / green: '+greenflag +' red: '+redflag);
            this.MyLVModalError = true;
            this.GMGreenError=true;
        }
        else if(lvAccountNum > 1){
            //console.log('lvAccountNum: ',lvAccountNum);
            this.MyLVModalError = true;
            this.MyLVError=true;
        }
        
        let clients ="clients";
        let clientsArray = this.clientsDetails.map(item =>{
            let clientItem = {
                "dreamId":item.dreamId,
                "salesforceId":item.salesforceId,
                "userIdentitySalesforceId":item.userIdentitySalesforceId
            };
            return clientItem;
        });
        
        let clientsToMergeArray = JSON.stringify(clientsArray);
        sendToMerge({clientToMerge:clientsToMergeArray})
        .then((result)=>{
            console.log('merge manual OK', result);
            if(!this.MyLVModalError){
                this.MergesSuccessModal = true;
            }
        })
        .catch((error)=>{
            console.error('error merge manual', error);

        });
        
        this.isMergeModalOpen = false;

        
        
    }

    resultSearchError(error){
                if(error.status==404)
                {
                    this.errorMsg = "No results found.";

                }
                else if(error.status==400)
                {
                    this.errorMsg = error.message;
                }
                else{
                    this.errorMsg = "Sorry, we encounter an error. Please try again later.";

                }
                console.error(error);
                this.searchData = undefined;

                this.isLoading = false;
                this.advancedSearch = false;
                // this.suggestionResult=undefined;

    }

    get advancedSearchIcon()
    {
        return imagesResource +'/images/client360/advancedSearchIcon.svg'
    }



    get displaySearch()
    {
        return this.advancedSearch == true || this.searchData!= undefined || this.errorMsg != undefined  ? false:true;
        
    }
    advancedSearchDisplay(event)
    {
        if (event.target.dataset.id == 'searchData'){

            this.locationpage ='oldsearchdata';
        }else {

            this.locationpage = 'advancedsearchpage'
        }
        console.log('tesstttttt after clic '  + this.locationpage);
       
       
        this.searchData = undefined;
        this.advancedSearch = true;
        this.backButtonDisplay = true;
        this.displayHeader = true;
        this.errorMsg = undefined;
        this.flagValidation = true;
        this.searchKey=undefined;

    }
    advancedSearchNotDisplay()
    {
        this.advancedSearch = false;
        this.errorMsg = undefined;
    }

    backFromResult(event){
        if (event.currentTarget.dataset.id == 'advancedsearchpage' ){
            this.searchData=undefined;
            this.displayHeader =false;
            this.errorMsg = undefined;
            this.advancedSearch = false;
            this.searchKey=undefined;
            this.clientsDetails = [];
        }
        if ( event.currentTarget.dataset.id == 'searchData'){
            this.searchData=undefined;
            this.errorMsg = undefined;
            this.advancedSearch = false;
            this.displayHeader =false;
            this.searchKey=undefined;
            this.clientsDetails = [];
        }
        if (event.currentTarget.dataset.id == 'oldsearchdata'){
            this.searchData=true;
            this.errorMsg = undefined;
            this.advancedSearch = false;
            this.searchKey=undefined;
            this.clientsDetails = [];
            this.locationpage ='searchData';
        }
          const keys = Object.keys(this.searchRequest);
            for (let i = 0; i < keys.length; i++) {
            const key = keys[i];
            this.searchRequest[key] = null;
        }
    }
    handleSuggestionResultNavigation(event)
    {
        this.navigateToAccount({ detail: event.currentTarget.dataset.index });

    }

    navigateToAccount(event){

        let searchResultID = this.tableData.idList[event.detail];
        if(!searchResultID.salesforceId)
        {
            this.openClient360(searchResultID);
        }
        else{
           let record =  getAccount({accountId:searchResultID.salesforceId})
           .then(res=>{
              this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: searchResultID.salesforceId,
                    objectApiName: 'Account',
                    actionName: 'view'
                },
            })
        })
            .catch(error=>{
                this.openClient360(searchResultID);

            });
           
          
        }


    }

    openClient360(searchResultID)
    {
            invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
            if (isConsole) {
                invokeWorkspaceAPI('getAllTabInfo').then(response => {
                    let focusTabId;
                    for (var i = 0; i < response.length; i++) 
                    {
                        
                            let tab = response[i];
                      
                        if(searchResultID.dreamId ==tab.pageReference.state.c__accountId && tab.pageReference.state.c__dreamAccountClient )
                        {
    
                            focusTabId = tab.tabId;

    
    
                        }
                    }
                    if(focusTabId)
                    {

                        invokeWorkspaceAPI('closeTab', {tabId:focusTabId })
                        .then(response => {
                            
                            
                        });
                    }
               
                        this[NavigationMixin.Navigate]({
                            type: 'standard__component',
                            attributes: {
                              componentName: "c__icx_dreamRedirection"
                          },
                          state: {
                            c__accountId: searchResultID.dreamId,
                            c__accountName: searchResultID.Name,
                            c__dreamAccountClient: this.dreamAccountClient
                
                         }
                        });
                    });
            }
        });


     
    }
}