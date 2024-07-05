/*
CreatedDate: July 2022
Company: Balink
Author: Naomi Baroghel
Description: Controller for Client360 page
*/

public with sharing class icx_Client360_API {

    public icx_Client360_API() {}


    //current version
    @AuraEnabled(cacheable=true)
    public static  Object getSearchResults(String searchRequest){ 

        try{

            String requestBody = '{ "keywords":"'+searchRequest+'"}';
            String results = ICX_WS_Client360.Client360_search(requestBody);
            system.debug(' search  result obj : ' + results);
            
            return results;
        }  catch(Exception error)
        {
            system.debug(' error search   ' +error);
            // throw new AuraHandledException(error.getMessage());
            return error;        
            
        }

    }
 
    //current version
    @AuraEnabled(cacheable=true)
    public static  Object getAdvancedSearchResults(String searchRequest)
    { 
        try{

        
        system.debug(' searchRequest advanced :  '  + searchRequest);

      
            String results = ICX_WS_Client360.Client360_search_form(searchRequest);

            
             system.debug(' search advanced result result obj : ' + results);
          
        return results;
        }  catch(Exception error)
        {
            system.debug(' error search advanced  ' +error);
            // throw new AuraHandledException(error.getMessage());
            return error;        

        }

    }
    

    //current version
    @AuraEnabled(cacheable=true)
    public static Object getContact(String dreamId){
        try{       
        String result = ICX_WS_Client360.Client360_Profile(dreamId);

        System.debug('data profile:   ' + result);
        ICX_Client360_API_Helper.profileObj currentProfile = (ICX_Client360_API_Helper.profileObj) JSON.deserialize(result, ICX_Client360_API_Helper.profileObj.class);
        System.debug(' currentProfile: ' + currentProfile);

        ICX_Client360_API_Helper.WrapperAccountKeyInfo WrapperAccountKeyInfo = new ICX_Client360_API_Helper.WrapperAccountKeyInfo();

        ICX_Client360_API_Helper.accountWrapper contact = new ICX_Client360_API_Helper.accountWrapper();


        contact.Name = currentProfile.firstName + ' ' + currentProfile.lastName;
         contact.salutation = currentProfile.civility?.label;
         contact.Gender = currentProfile.gender?.label;

        //  contact.Nationality = currentProfile.nationality?.label; //no need ?
          contact.firstName = currentProfile.firstName;
          contact.lastName = currentProfile.lastName;
          contact.firstName2 = currentProfile.firstName2;
          contact.lastName2 = currentProfile.lastName2; 
          contact.birthdate = currentProfile.birthDate;
          
          contact.PersonMobilePhone = currentProfile.mobilePhoneNumber!=null?currentProfile.mobilePhoneNumber.internationalPrefix+currentProfile.mobilePhoneNumber.phoneNumber:'';
          contact.email = currentProfile.emailAddress?.emailAddress;
          contact.address = currentProfile.residencePostalAddress?.addressLine1;
          contact.Can_Be_Contacted_By_Email = currentProfile.canBeContactedByEmail!=null?currentProfile.canBeContactedByEmail:false;
          contact.Can_Be_Contacted_By_Phone =  currentProfile.canBeContactedByPhoneCall!=null?currentProfile.canBeContactedByPhoneCall:false;
          contact.Can_Be_Contacted_By_SMS =  currentProfile.canBeContactedBySms!=null?currentProfile.canBeContactedBySms:false;
          contact.Can_Be_Contacted_By_Address = currentProfile.canBeContactedByMail!=null?currentProfile.canBeContactedByMail:false;
        //   contact.Prefered_Language = currentProfile.preferredLanguage?.code;
          contact.Prefered_Language = currentProfile.residencePostalAddress?.countryCodeIso;

          contact.segmentationClient = currentProfile.segmentation;
          contact.displayedSegment = currentProfile.segmentation;
          contact.dreamID = currentProfile.identifiers?.dreamId;

          system.debug(' currentProfile.accounts: ' + currentProfile.accounts);
          if(currentProfile.accounts != null && currentProfile.accounts.size() > 0) {

            for(ICX_Client360_API_Helper.account currentAccount : currentProfile.accounts) {
                if (currentAccount.emailAddress != null) {
                    contact.myLVemail = currentAccount.emailAddress;
                    contact.lastActivityDate = currentAccount.lastLoginDate != null ? currentAccount.lastLoginDate : null;
                    String currentDate = currentAccount.lastLoginDate != null ? Date.newInstance(Integer.valueOF(currentAccount.lastLoginDate.split('T')[0].split('-')[0]),Integer.valueOF(currentAccount.lastLoginDate.split('T')[0].split('-')[1]),Integer.valueOF(currentAccount.lastLoginDate.split('T')[0].split('-')[2])).format() : '';
                    contact.lastActivity = currentAccount.emailAddress+' | Last Login :  ' + currentDate;
                    break;
                }
            }
          }

          if(currentProfile.attachment?.forcedAttachmentStore!=null)
          {

            List<Store__c> clientStore = [SELECT Id,RetailStoreId__c,Name FROM Store__c WHERE RetailStoreId__c =: currentProfile.attachment.forcedAttachmentStore];
            if(clientStore.size()>0)  
            {

                contact.StoreID =  clientStore[0].Id;
                contact.StoreName =  clientStore[0].Name;
                contact.StoreRetailID = clientStore[0].RetailStoreId__c;
            }
          }
          if(currentProfile.clientAdvisorForcedAttachment?.clientAdvisor?.worldwideId !=null)
          {
            List<User> CA =  [SELECT Id,Name FROM User WHERE WWEmployeeNumber__c=:currentProfile.clientAdvisorForcedAttachment.clientAdvisor.worldwideId];
            if(CA.size()>0)
            {

                contact.OwnerName = CA[0]?.name;
                contact.OwnerID = CA[0]?.Id; 
            }
          }
          contact.firstPurchaseDate = currentProfile.firstTransactionDate;
          contact.lastPurchaseDate = currentProfile.lastTransactionDate;
          contact.lastContact = currentProfile.lastContactDate;
          contact.greyMarketStatus = currentProfile.greyMarketStatus;
          contact.isUserIdentity = currentProfile.identifiers?.userIdentitySalesforceId!=null? true: false;
          System.debug(' contact wrapper: ' + contact);


          WrapperAccountKeyInfo.account=contact;
          ICX_Client360_API_Helper.WrapperLabelValueList clientKeyInfoWrapper  = new ICX_Client360_API_Helper.WrapperLabelValueList();
          // clientKeyInfoWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('X Store ID',clientKeyInfoObj.XStoreID,'text'));    //not in mvp
           clientKeyInfoWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Type',currentProfile.clientType?.label,'text'));    
           clientKeyInfoWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Typology',currentProfile.clientType?.label,'text'));    
           clientKeyInfoWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Nationality',currentProfile.nationality?.label,'text'));    
           clientKeyInfoWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Birthdate',currentProfile.birthDate!=null? Date.newInstance(Integer.valueOf(currentProfile.birthDate.split('-')[0]),Integer.valueOf(currentProfile.birthDate.split('-')[1]),Integer.valueOf(currentProfile.birthDate.split('-')[2])).format():'','text'));    
           clientKeyInfoWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Gender',currentProfile.gender?.label,'text'));    
           clientKeyInfoWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Email',currentProfile.emailAddress?.emailAddress,'text'));    
           clientKeyInfoWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Mobile Phone',currentProfile.mobilePhoneNumber!=null?currentProfile.mobilePhoneNumber.internationalPrefix+currentProfile.mobilePhoneNumber.phoneNumber:'','text'));    
           clientKeyInfoWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Address',currentProfile.residencePostalAddress?.addressLine1,'text'));    

           if(currentProfile.residencePostalAddress!=null && currentProfile.residencePostalAddress.countryCodeIso!=null)
            {
                String countryLabel = [SELECT Id, Picklist__c FROM CountryMapping__mdt WHERE Iso3Code__c =:currentProfile.residencePostalAddress.countryCodeIso AND Picklist__c!=null LIMIT 1]?.Picklist__c;
                clientKeyInfoWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Country',countryLabel,'text'));    
            }
            else
            {
                clientKeyInfoWrapper.item.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Country',null,'text'));    

            }
   
           clientKeyInfoWrapper.Id = '0';
           System.debug(' clientKeyInfoWrapper: ' + clientKeyInfoWrapper);

          WrapperAccountKeyInfo.clientKeyInfo=clientKeyInfoWrapper;

           System.debug(' WrapperAccountKeyInfo: ' + WrapperAccountKeyInfo);


        return WrapperAccountKeyInfo;
    }
    catch(Exception error)
    {
        system.debug(' error contact api ' +error);
        // throw new AuraHandledException(error.getMessage());
        return error;        
    }
    }



 

    //current version
    @AuraEnabled(cacheable=true)
    public static  Object   getContactInformation(String dreamId) {
    
        try{
            String result = ICX_WS_Client360.Client360_Profile(dreamId);

            System.debug('data profile information: ' + result);
            ICX_Client360_API_Helper.profileObj currentProfile = (ICX_Client360_API_Helper.profileObj) JSON.deserialize(result, ICX_Client360_API_Helper.profileObj.class);
            System.debug(' currentProfile: ' + currentProfile);

            ICX_Client360_API_Helper.WrapperClientInfo currentClientInfo = new ICX_Client360_API_Helper.WrapperClientInfo();

            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Client Name',  currentProfile.civility.label+ ' ' +currentProfile.firstName + ' ' + currentProfile.lastName ,'text'));            
            //  currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('age', String.valueOf(resultMap.get('age')),'text'));            
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Birthdate',currentProfile.birthDate,'text'));            
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Nationality',currentProfile.nationality.label,'text'));            
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Contact Preference','' ,'text'));            //missing on the api
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Last Segmentation',currentProfile.segmentation,'text'));   
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Typology',currentProfile.clientType?.label,'text'));                     
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Preferred CA',currentProfile.clientAdvisorForcedAttachment?.clientAdvisor?.name,'text'));            
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Attached Store',currentProfile.storeForcedAttachment?.store?.label,'text'));
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Dreamd ID',currentProfile.identifiers?.dreamId ,'text'));
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('WW ID',currentProfile.identifiers?.worldwideId ,'text'));
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('X Store ID','','text'));   // missing in api
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Passport #',currentProfile.passportNumbers!=null && currentProfile.passportNumbers.size()>0?currentProfile.passportNumbers[0]:null,'text'));            
            currentClientInfo.clientInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Comment','','text'));        //missing in api     

            
            //not in api
            //  currentClientInfo.eventGift.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('invitedToAPCREvent',String.valueOf(resultMap.get('invitedToAPCREvent') != null?resultMap.get('invitedToAPCREvent'):''),'checkbox')); 
            //  currentClientInfo.eventGift.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('giftsOfferedForThisClient',String.valueOf(resultMap.get('giftsOfferedForThisClient') != null?resultMap.get('giftsOfferedForThisClient'):''),'url'));            
        

            currentClientInfo.address1.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Address Line 1',currentProfile.residencePostalAddress?.addressLine1,'text'));            
            currentClientInfo.address1.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Address Line 2',currentProfile.residencePostalAddress?.addressLine2,'text'));            
            currentClientInfo.address1.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Address Line 3',currentProfile.residencePostalAddress?.addressLine3,'text'));            
            currentClientInfo.address1.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Postal Code',currentProfile.residencePostalAddress?.postalCode,'text'));      
            currentClientInfo.address1.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Town/City',currentProfile.residencePostalAddress?.city,'text'));            
            currentClientInfo.address1.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Province/State',currentProfile.residencePostalAddress?.state,'text'));            
            //  currentClientInfo.address1.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('country',String.valueOf(resultMap.get('country') != null?resultMap.get('country'):''),'text'));            
            currentClientInfo.address1.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Can Be Contacted By Mail',String.valueOf(currentProfile.canBeContactedByMail),'checkbox'));            

            currentClientInfo.otherContactInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Email Address',currentProfile.emailAddress?.emailAddress,'text'));    
            currentClientInfo.otherContactInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Phone Country Code',currentProfile.mobilePhoneNumber?.countryCodeIso,'text'));       
            currentClientInfo.otherContactInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Home Phone',currentProfile.homePhoneNumber?.phoneNumber,'text'));       
            currentClientInfo.otherContactInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Work Phone',currentProfile.workPhoneNumber?.phoneNumber,'text'));       
            currentClientInfo.otherContactInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Mobile Phone',currentProfile.mobilePhoneNumber?.phoneNumber,'text'));       
            currentClientInfo.otherContactInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Can Be Contacted By Email',String.valueOf(currentProfile.canBeContactedByEmail),'checkbox'));       
            currentClientInfo.otherContactInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Can Be Contacted By Phone',String.valueOf(currentProfile.canBeContactedByPhoneCall),'checkbox'));       
            currentClientInfo.otherContactInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Can Be Contacted By SMS',String.valueOf(currentProfile.canBeContactedBySms),'checkbox'));       
            currentClientInfo.otherContactInformation.add(ICX_Client360_API_Helper.Create_WrapperLabel_Value('Preferred Language',currentProfile.preferredLanguage?.code,'text'));       



            currentClientInfo.Id =0;
            return currentClientInfo;
            
        }
        catch(Exception error)
        {
            system.debug(' error getContactInformation api ' +error);
            // throw new AuraHandledException(error.getMessage());
            return error;        
            
        }
    }
    


    //current version
    @AuraEnabled(cacheable=true)
    public static  Object getAggregate(String dreamId) { 

        try{

        

        Object results = ICX_WS_Client360.Client360_Aggregates(dreamId);
        system.debug('getAggregate' + results);
        return results;
    }
    catch(Exception error)
    {
        system.debug(' error aggregate api ' +error);
        // throw new AuraHandledException(error.getMessage());
        return error;        

    }

    }



 

    //current version
    @AuraEnabled(cacheable=true)
    public static Object getPurchases(String dreamId,String newSearch, String scrollType,String refSaleID,String numTrans)
    {
        try{
            String purchasesResult = ICX_WS_Client360.Client360_Purchases(dreamId,newSearch,scrollType,refSaleID,numTrans);
            System.debug('purchasesResult: ' + purchasesResult);
            
            // if(purchasesResult!=null)
            // {
                
                
                ICX_Client360_API_Helper.purchasesObj purchaseObj = (ICX_Client360_API_Helper.purchasesObj)JSON.deserialize(purchasesResult, ICX_Client360_API_Helper.purchasesObj.class);
                ICX_Client360_API_Helper.purchasesWrapper  purchasesList = new ICX_Client360_API_Helper.purchasesWrapper();
                

                Map<String,String> clientAdvisorName  = new Map<String,String>();
                List<String> clientAdvisorList = new List<String>();
                // List<ICX_Client360_API_Helper.purchases>  purchasesList = new List<ICX_Client360_API_Helper.purchasesWrapper>();
                if(purchaseObj.data!=null)
                {

                    for(ICX_Client360_API_Helper.data currentPurchase : purchaseObj.data)
                    {      
                        if(currentPurchase.purchaseDetail[0].clientAdvisorWWid!=null)
                        {

                            clientAdvisorList.add(currentPurchase.purchaseDetail[0].clientAdvisorWWid);
                        } 
                    }  
                    
                    List<User> clientAdvisorUser =[SELECT Id,Name,WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c IN:clientAdvisorList];

                    for(User currentUser : clientAdvisorUser)
                    {
                        clientAdvisorName.put(currentUser.WWEmployeeNumber__c,currentUser.Name);
                    }

                        for(ICX_Client360_API_Helper.data currentPurchase : purchaseObj.data)
                    {
                        ICX_Client360_API_Helper.purchases purchaseWrapper = new ICX_Client360_API_Helper.purchases();
                        
                        purchaseWrapper.purchasedProductDate = currentPurchase.purchaseDate;
                        purchaseWrapper.type = currentPurchase.purchaseType ;
                        purchaseWrapper.StoreName = currentPurchase.purchaseStorelabel;
                        purchaseWrapper.sku = currentPurchase.purchaseDetail.size()>0?currentPurchase.purchaseDetail[0].productSKU:null;
                        purchaseWrapper.size = null;// missing in the api
                        purchaseWrapper.currencyCode = currentPurchase.purchaseStoreCountry;
                        if(currentPurchase.purchaseDetail.size()>0)
                        {
                            
                            // purchaseWrapper.OwnerName = currentPurchase.purchaseDetail[0].clientAdvisorWWid!=null? [SELECT Id,Name FROM User WHERE WWEmployeeNumber__c=:currentPurchase.purchaseDetail[0].clientAdvisorWWid LIMIT 1]?.Name:null ;
                            purchaseWrapper.OwnerName = currentPurchase.purchaseDetail[0].clientAdvisorWWid!=null? clientAdvisorName.get(currentPurchase.purchaseDetail[0].clientAdvisorWWid)!=null?clientAdvisorName.get(currentPurchase.purchaseDetail[0].clientAdvisorWWid):null:null;

                            purchaseWrapper.quantity = String.valueOf(currentPurchase.purchaseDetail[0].quantity);
                            purchaseWrapper.sales = String.valueOf(currentPurchase.purchaseDetail[0].amountTTC);
                            if(currentPurchase.purchaseDetail[0].product!=null)
                            {
                                purchaseWrapper.productName = currentPurchase.purchaseDetail[0].product.name; 
                                purchaseWrapper.article = currentPurchase.purchaseDetail[0].product.name;
                                purchaseWrapper.productImage = currentPurchase.purchaseDetail[0].product.image;

                                purchaseWrapper.categorie = (currentPurchase.purchaseDetail[0].product.categoryIdentifier!=null && currentPurchase.purchaseDetail[0].product.categoryIdentifier.size()>0)?currentPurchase.purchaseDetail[0].product.categoryIdentifier[0]:''; 
                            }
                        }
                        purchaseWrapper.paymentMethod = currentPurchase.paymentMethod.size()>0?currentPurchase.paymentMethod[0].paymentMode:null;
                        purchaseWrapper.transactionNumber = currentPurchase.ticketNumber;
                        
                        purchasesList.purchases.add(purchaseWrapper);
                        purchasesList.refSaleID = currentPurchase.wwsid;
                        
                    }
                    
            }
        // }
        
        return purchasesList;
    }
    catch(Exception error)
    {
        system.debug(' error purchase api ' +error);
        // throw new AuraHandledException(error.getMessage());
        return error;        

        
    }

    }

   



}