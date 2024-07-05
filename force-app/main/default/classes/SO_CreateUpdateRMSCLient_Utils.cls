/**
* [SO_CreateUpdateRMSCLient_Utils]
* Utility Class handling the RMS Client Creation and update from SFDC.
*
* This Class is called and used from the next Classes:
* -    SO_ClientSearch_CTRL
* -    SO_NewEditViewClient_CTRL
*
* This Class uses the next Web Services:
*  -   SO_WS_RMS_DoClientCreationUpdate
*
* Modification History:
*  -   26/10/2016 | MTOU | Harmo: using "Contactable XXX" fields instead of "Do Not XXX"
*
* @CreatedBy       J.C on December 2015
* @LastModifiedBy  N.G on March 2016
*/
public without sharing class SO_CreateUpdateRMSCLient_Utils
{
    /**
     * Inner Class that will return the Web Service Callout result and fields such as:
     *  - calloutSuccessResult : true if the callout succeeded, false otherwise
     *  - calloutClientRmsId  : The client created/updated RMS Id
     *  
     * @CreatedBy       J.C on December 2015
     * @LastModifiedBy  J.C on December 2015
     */
    public Class SO_CreateUpdateRmsClientResult
    {
        public Boolean calloutSuccessResult;
        public String calloutClientRmsId;
    }

    /**
     * [createSFDCAccountIntoRMS : The function creates a SFDC Account into the L.V RMS using a Web Service callout via the Class SO_WS_RMS_DoClientCreationUpdate]
     * The Web Service Callout is used when choosing an Account from Salesforce.
     * 
     * The Callout response contains :
     * -   The ExternalId (RMS ID) of the Account that was Created if successfull - NULL if an Error occured.
     * -   The Error that occured -  NULL if no Error occured.
     * 
     * If the Callout succeeded the next is done:
     *  -   The SFDC Opportunity SPO_RMSClientId__c field is updated with the RMS Id received.
     *
     * @CreatedBy       J.C on December 2015
     * @LastModifiedBy  J.C on December 2015
     * @return          [True if the Web Service Callout succeeded, False otherwise]
     */
    public static SO_CreateUpdateRmsClientResult createUpdateSFDCAccountIntoRMS(Account accountToCreate, String rmsId)
    {
        System.debug('SFDC createUpdateSFDCAccountIntoRMS accountToCreate: ' + accountToCreate);
        SO_CreateUpdateRMSCLient_Utils.SO_CreateUpdateRmsClientResult calloutResult = new SO_CreateUpdateRMSCLient_Utils.SO_CreateUpdateRmsClientResult();
        calloutResult.calloutSuccessResult = false;

        SO_WS_RMS_DoClientCreationUpdate.Result result = SO_CreateUpdateRMSCLient_Utils.CreateAccountIntoRMS_WS(accountToCreate, rmsId);
        calloutResult.calloutSuccessResult = true;
        calloutResult.calloutClientRmsId = result.RMSId;
        return calloutResult;
    }

    /**
     * [queryRelatedAccount Query the SFDC Account fields to prepare the Account Creation into the RMS Callout]
     * @param  accountId [Id of the Account to retreive]
     * @CreatedBy      J.C on December 2015
     * @LastModifiedBy J.C on December 2015
     * @return         [The Account retreived]
     */
    public static Account queryRelatedAccount(Id accountId)
    {
        Account acc = new Account();
        List<Account> accountList = [SELECT Id, DREAMID__c, Salutation, FirstName, LastName, FirstName2__pc, Lastname2__pc, PersonTitle, Nationality__pc,
                                            PreferredLanguage__pc, PassportNumber__pc, Company__pc, PrimaryAddressLine1__pc, PrimaryAddressLine2__pc,
                                            PrimaryAddressLine3__pc, PrimaryZipCode__pc, PrimaryCity__pc, SPO_Country_code__pc, PrimaryStateProvince__pc,
                                            HomePhoneCountryCode__pc, PersonHomePhone, MobilePhoneCountryCode__pc, PersonMobilePhone, WorkPhoneCountryCode__pc,
                                            Phone, BirthdateDay__pc, BirthDateMonth__pc, BirthDateYear__pc, PersonDoNotCall, DoNotSMS__pc, 
                                            DoNotContactbyPost__pc, PersonHasOptedOutOfEmail, PersonEmail, NationalityCountryCode__pc,
                                            TypologyCode__pc, SPO_Primary_Province_State__pc, HomeAddressCountryCode__pc,
                                            LocalHomePhone__pc, LocalMobilePhone__pc, LocalWorkPhone__pc
                                    FROM Account
                                    WHERE Id = :accountId];
        if(accountList != Null && accountList.Size() > 0){
            acc = accountList[0];
        }
        return acc;
    }

    /**
     * [createAccountIntoRMS_WS : The function creates/updates an Account into the L.V RMS using a Web Service callout via the Class SO_WS_RMS_DoClientCreationUpdate]
     * This function will be used to Create and to Update SFDC Accounts into L.V RMS.
     * 
     * The Callout response contains :
     * -   The ExternalId (RMS ID) of the Account that was Created/Updated if successfull - NULL if an Error occured.
     * -   The Error that occured -  NULL if no Error occured.
     *
     * @param  account  [The SFDC Account that needs to be Created/Updated into the L.V RMS]
     * @CreatedBy       J.C on December 2015
     * @LastModifiedBy  J.C on December 2015
     * @return          [The RMS Account Id received if the Callout succeeded, Null otherwise]
     */
    private static SO_WS_RMS_DoClientCreationUpdate.Result createAccountIntoRMS_WS(Account accountToCreate, String rmsId, Boolean use_v5)
    {
        String calloutAccountIdResult = '';
        SO_WS_RMS_DoClientCreationUpdate ws                  = new SO_WS_RMS_DoClientCreationUpdate();
        SO_WS_RMS_DoClientCreationUpdate.DataInput dataInput = new SO_WS_RMS_DoClientCreationUpdate.DataInput();

        /**
         * Waiting for intructions, some fields need to be Hard coded or commented for now.
         * Later they will be used and some more fields could be added.
         */
        dataInput.RMSId                             = String.isNotBlank(rmsId) ? rmsId : String.isNotBlank(accountToCreate.RMSId__pc) ? accountToCreate.RMSId__pc : '';
        dataInput.WW_RMSId                          = String.isNotBlank(accountToCreate.WW_RMSId__c) ? accountToCreate.WW_RMSId__c : '';
        dataInput.StoreCode                         = SO_Session.theCurrentBrief == null ? accountTocreate.AttachedStore__pc: SO_Session.theCurrentBrief.SPO_StoreCode__c;
        dataInput.DreamId                           = '';
        dataInput.FirstName                         = accountToCreate.FirstName;
        dataInput.LastName                          = accountToCreate.LastName;
        dataInput.FirstName2                        = accountToCreate.FirstName2__pc;
        dataInput.LastName2                         = accountToCreate.Lastname2__pc;
        dataInput.Title                             = accountToCreate.Salutation; 

        dataInput.Nationality                       = String.isNotBlank(accountToCreate.NationalityCountryCode__pc) ? accountToCreate.NationalityCountryCode__pc : accountToCreate.HomeAddressCountryCode__pc;
        dataInput.Nationality                       = String.isBlank(dataInput.Nationality) || dataInput.Nationality == '999' ? '777' : dataInput.Nationality;

        dataInput.PrimaryAddressCountry             = String.isNotBlank(accountToCreate.SPO_Country_code__pc) ? accountToCreate.SPO_Country_code__pc : accountToCreate.HomeAddressCountryCode__pc;
        
        dataInput.TypeOfClient                      = String.isNotBlank(accountToCreate.TypologyCode__pc) ?  accountToCreate.TypologyCode__pc : '2';
        dataInput.PreferredLanguage                 = accountToCreate.PreferredLanguage__pc;
        dataInput.PassportNumber                    = accountToCreate.PassportNumber__pc;
        dataInput.Company                           = accountToCreate.Company__pc;              
        dataInput.PrimaryAddressLine1               = accountToCreate.PrimaryAddressLine1__pc;
        dataInput.PrimaryAddressLine2               = accountToCreate.PrimaryAddressLine2__pc;
        dataInput.PrimaryAddressLine3               = accountToCreate.PrimaryAddressLine3__pc;
        dataInput.PrimaryAddressZipCode             = accountToCreate.PrimaryZipCode__pc;
        dataInput.PrimaryAddressCity                = accountToCreate.PrimaryCity__pc;

        if(accountToCreate.SPO_Country_code__pc != 'CHN')
        {
            dataInput.PrimaryAddressProvinceOrState   = accountToCreate.PrimaryStateProvince__pc;
        }
        else
        {
            dataInput.PrimaryAddressProvinceOrState   = accountToCreate.SPO_Primary_Province_State__pc;
        }

        //Phone numbers according to ticket 697 - 14-3-16:
        dataInput.HomePhoneNumberCountry            = accountToCreate.HomePhoneCountryCode__pc;
        dataInput.MobilePhoneNumberCountry          = accountToCreate.MobilePhoneCountryCode__pc != null ? accountToCreate.MobilePhoneCountryCode__pc :  getCountryPhoneISO2(accountToCreate.MobilePhoneCountryCallingCode__pc) ;
        dataInput.WorkPhoneNumberCountry            = accountToCreate.WorkPhoneCountryCode__pc;
        dataInput.HomePhoneNumber                   = accountToCreate.LocalHomePhone__pc;   
        dataInput.MobilePhoneNumber                 = accountToCreate.LocalMobilePhone__pc; 
        dataInput.WorkPhoneNumber                   = accountToCreate.LocalWorkPhone__pc; 

        dataInput.BirthdateDay                      = accountToCreate.BirthdateDay__pc;
        dataInput.BirthDateMonth                    = accountToCreate.BirthDateMonth__pc;
        dataInput.BirthDateYear                     = accountToCreate.BirthDateYear__pc;

        // ---Begin MTO - Harmo: using "Contactable by..fields"----//
        /*dataInput.PersonDoNotCall                   = accountToCreate.PersonDoNotCall;
        dataInput.DoNotSMS                          = accountToCreate.DoNotSMS__pc;
        dataInput.DoNotContactbyPost                = accountToCreate.DoNotContactbyPost__pc;
        dataInput.PersonHasOptedOutOfEmail          = accountToCreate.PersonHasOptedOutOfEmail;*/
        dataInput.PersonDoNotCall                   = accountToCreate.Can_Be_Contacted_By_Phone__pc != NULL? !accountToCreate.Can_Be_Contacted_By_Phone__pc: NULL ;
        dataInput.DoNotSMS                          = accountToCreate.Can_Be_Contacted_By_SMS__pc != NULL? !accountToCreate.Can_Be_Contacted_By_SMS__pc: NULL;
        dataInput.DoNotContactbyPost                = accountToCreate.Can_Be_Contacted_By_Mail__pc != NULL? !accountToCreate.Can_Be_Contacted_By_Mail__pc: NULL;
        dataInput.PersonHasOptedOutOfEmail          = accountToCreate.Can_Be_Contacted_By_Email__pc != NULL? !accountToCreate.Can_Be_Contacted_By_Email__pc: NULL;
        // ---End MTO--- //
        dataInput.PersonalEmail                     = accountToCreate.PersonEmail;

        System.debug('SFDC dataInput: ' + dataInput);
        SO_WS_RMS_DoClientCreationUpdate.Result calloutResult = use_v5? ws.doClientCreationUpdatev5(dataInput) : ws.doClientCreationUpdate(dataInput);
        
        system.debug('SFDC createAccountIntoRMS_WS calloutResult.error: ' + calloutResult.Error);
        system.debug('SFDC createAccountIntoRMS_WS calloutResult.RMSId: ' + calloutResult.RMSId);


        if(String.isNotBlank(calloutResult.Error)){
            SO_UTIL.exceptionDump('createAccountIntoRMS_WS.createAccountIntoRMS_WS >> ' + calloutResult.Error);
            //throw new SO_UTIL.RMSException(calloutResult.Error);
        }
        else if(String.isBlank(calloutResult.RMSId) && String.isBlank(calloutResult.WW_RMSId)){
            String msg = 'RMS Empty result';
            SO_UTIL.exceptionDump('createAccountIntoRMS_WS.createAccountIntoRMS_WS >> ' + msg);
            //throw new SO_UTIL.RMSException(msg);   
        }
        return calloutResult;
    }

    private static SO_WS_RMS_DoClientCreationUpdate.Result createAccountIntoRMS_WS(Account accountToCreate, String rmsId)
    {
        return createAccountIntoRMS_WS(accountToCreate, rmsId, false);
    }

    @future(callout=true)
    public static void createAccountIntoRMS_WS_v5(ID accountToCreateId)
    {
    try {       
        List<Account> accounts = [SELECT Id, 
                FirstName, 
                LastName, 
                FirstName2__pc, 
                Lastname2__pc,
                AttachedStore__pc,
                Salutation,
                NationalityCountryCode__pc,
                SPO_Country_code__pc,
                TypologyCode__pc,
                PreferredLanguage__pc,
                PassportNumber__pc,
                Company__pc,
                PrimaryAddressLine1__pc,
                PrimaryAddressLine2__pc,
                PrimaryAddressLine3__pc,
                PrimaryZipCode__pc,
                PrimaryCity__pc,
                SPO_Primary_Province_State__pc,
                PrimaryStateProvince__pc,
                HomePhoneCountryCode__pc,
                MobilePhoneCountryCode__pc,
                MobilePhoneCountryCallingCode__pc,
                WorkPhoneCountryCode__pc,
                LocalHomePhone__pc,
                LocalMobilePhone__pc,
                LocalWorkPhone__pc,
                BirthdateDay__pc,
                BirthDateMonth__pc,
                BirthDateYear__pc,
                Can_Be_Contacted_By_Phone__pc,
                Can_Be_Contacted_By_SMS__pc,
                Can_Be_Contacted_By_Mail__pc,
                Can_Be_Contacted_By_Email__pc,
                PersonEmail,
                Status_RMSID__c,
                WW_RMSId__c,
                RMSId__pc,
                HomeAddressCountryCode__pc

            from Account where Id =: accountToCreateId];
        if (accounts.isEmpty()){
            throw new SO_UTIL.RMSException('no accounts for accountId : ' + accountToCreateId);
        }
        Account accountToCreate = accounts[0];
        System.debug(accountToCreate);
        SO_WS_RMS_DoClientCreationUpdate.Result result =  createAccountIntoRMS_WS(accountToCreate, (accountToCreate.RMSId__pc != null ? accountToCreate.RMSId__pc : ''), true);
        if(String.isNotBlank(result.Error)){
            accountToCreate.Status_RMSID__c = 'Failed';
            accountToCreate.Error_RMSID__c =  SO_UTIL.exceptionDump('createAccountIntoRMS_WS.createAccountIntoRMS_WS >> ' + result.Error);
            
        }
        else if(String.isBlank(result.RMSId) && String.isBlank(result.WW_RMSId)){
            accountToCreate.Status_RMSID__c = 'Failed';
            accountToCreate.Error_RMSID__c =  SO_UTIL.exceptionDump('createAccountIntoRMS_WS.createAccountIntoRMS_WS >> RMS Empty result'); 
        }
        else if(result.RMSId != accountToCreate.RMSId__pc) {
            accountToCreate.RMSId__pc = result.RMSId;
            accountToCreate.WW_RMSId__c = result.WW_RMSId;
            accountToCreate.Status_RMSID__c = 'Success'; 
            accountToCreate.Error_RMSID__c = null;
        }
        update accountToCreate;
    } catch (Exception e) {
        new Logs.ERROR('SO_CreateUpdateRMSClient_Utils','CALLOUT',e);
    }
    }


    /**
     * [createAccountIntoRMS_WS : The function get L.V RMS client and map the RMS fields into SFDC Account
     *
     * @param  account  [The L.V RMS client to be map into the SFDC Account.]
     * @CreatedBy       E.M on January 2016
     * @LastModifiedBy  E.M on January 2016
     * @return          [The SFDC Account withe the RMS results map in to the account ]
     */
    // public static Account MapRmsClientIntoSfdcClient(SO_WS_RMS_DoClientEnquiry.Result incomingRmsClient,Account sfdcClientToMap)
    // {
    //     system.debug('SFDC MapRmsClientIntoSfdcClient incomingRmsClient ' + incomingRmsClient);

    //     sfdcClientToMap.Salutation                 = incomingRmsClient.Civility;
    //     sfdcClientToMap.FirstName                  = incomingRmsClient.FirstName;
    //     sfdcClientToMap.LastName                   = incomingRmsClient.LastName;
    //     sfdcClientToMap.Firstname2__pc             = incomingRmsClient.FirstName2;
    //     sfdcClientToMap.Lastname2__pc              = incomingRmsClient.LastName2;

    //     sfdcClientToMap.TypologyCode__pc           = incomingRmsClient.TypologyCode;
    //     sfdcClientToMap.BirthdateDay__pc           = incomingRmsClient.BirthdateDay;
    //     sfdcClientToMap.BirthDateMonth__pc         = incomingRmsClient.BirthdateMonth;
    //     sfdcClientToMap.BirthdateYear__pc          = incomingRmsClient.BirthdateYear;
    //     sfdcClientToMap.PersonEmail                = incomingRmsClient.Email;

    //     //AEF: removed for Ticket 0677
    //     //sfdcClientToMap.SPO_VATNumber__pc          = incomingRmsClient.VatNumber;
    //     //sfdcClientToMap.SPO_TaxID__pc              = incomingRmsClient.Taxid;

    //     // --- Added by MTOU - Harmo: populating "Contactable" fields --- //
    //     /*sfdcClientToMap.NationalityCountryCode__pc = incomingRmsClient.Nationality;
    //     sfdcClientToMap.PersonDoNotCall            = incomingRmsClient.DonotCall;
    //     sfdcClientToMap.DoNotSMS__pc               = incomingRmsClient.DoNotSMS;
    //     sfdcClientToMap.DoNotContactbyPost__pc     = incomingRmsClient.DoNotContactbyPost;
    //     sfdcClientToMap.PersonHasOptedOutOfEmail   = incomingRmsClient.HasOptedoutofEmail;*/

    //     sfdcClientToMap.Can_Be_Contacted_By_Phone__pc    = incomingRmsClient.DonotCall != NULL? !incomingRmsClient.DonotCall: NULL;
    //     sfdcClientToMap.Can_Be_Contacted_By_SMS__pc      = incomingRmsClient.DoNotSMS != NULL? !incomingRmsClient.DoNotSMS: NULL;
    //     sfdcClientToMap.Can_Be_Contacted_By_Mail__pc     = incomingRmsClient.DoNotContactbyPost != NULL? !incomingRmsClient.DoNotContactbyPost: NULL;
    //     sfdcClientToMap.Can_Be_Contacted_By_Email__pc    = incomingRmsClient.HasOptedoutofEmail != NULL? !incomingRmsClient.HasOptedoutofEmail: NULL;
    //     // ---End MTOU--- //

    //     sfdcClientToMap.PrimaryAddressLine1__pc    = incomingRmsClient.PrimaryAddressLine1;
    //     sfdcClientToMap.PrimaryAddressLine2__pc    = incomingRmsClient.PrimaryAddressLine2;
    //     sfdcClientToMap.PrimaryAddressLine3__pc    = incomingRmsClient.PrimaryAddressLine3;
    //     sfdcClientToMap.PrimaryZipCode__pc         = incomingRmsClient.PrimaryZipCode;
    //     sfdcClientToMap.PrimaryCity__pc            = incomingRmsClient.PrimaryCity;
    //     //sfdcClientToMap.PrimaryCountry__pc         = incomingRmsClient.PrimaryCountry;
    //     sfdcClientToMap.SPO_Country_code__pc         = incomingRmsClient.PrimaryCountry;
    //     sfdcClientToMap.HomeAddressCountryCode__pc = incomingRmsClient.PrimaryCountry;

    //     if(sfdcClientToMap.SPO_Country_code__pc != 'CHN')
    //     {
    //         sfdcClientToMap.PrimaryStateProvince__pc   = incomingRmsClient.PrimaryStateProvince;
    //     }
    //     else
    //     {
    //         sfdcClientToMap.SPO_Primary_Province_State__pc   = incomingRmsClient.PrimaryStateProvince;
    //     }
        
    //     //sfdcClientToMap.HomePhoneCountryCode__pc   = incomingRmsClient.HomePhoneCountryCode;        
    //     sfdcClientToMap.PersonHomePhone            = incomingRmsClient.HomePhone;
    //     //sfdcClientToMap.MobilePhoneCountryCode__pc = incomingRmsClient.MobilePhoneCountryCode;
    //     sfdcClientToMap.PersonMobilePhone          = incomingRmsClient.MobilePhone;
    //     //sfdcClientToMap.WorkPhoneCountryCode__pc   = incomingRmsClient.WorkPhoneCountryCode;
    //     sfdcClientToMap.Phone                      = incomingRmsClient.Phone;

    //     return sfdcClientToMap;
    // }
    public static Account MapRmsClientIntoSfdcClientMulesoft(SO_WS_RMS_DoClientEnquiryMulesoft.Result incomingRmsClient,Account sfdcClientToMap)
    {
        system.debug('SFDC MapRmsClientIntoSfdcClient incomingRmsClient ' + incomingRmsClient);

        sfdcClientToMap.Salutation                 = incomingRmsClient.Civility;
        sfdcClientToMap.FirstName                  = incomingRmsClient.FirstName;
        sfdcClientToMap.LastName                   = incomingRmsClient.LastName;
        sfdcClientToMap.Firstname2__pc             = incomingRmsClient.FirstName2;
        sfdcClientToMap.Lastname2__pc              = incomingRmsClient.LastName2;

        sfdcClientToMap.TypologyCode__pc           = incomingRmsClient.TypologyCode;
        sfdcClientToMap.BirthdateDay__pc           = incomingRmsClient.BirthdateDay;
        sfdcClientToMap.BirthDateMonth__pc         = incomingRmsClient.BirthdateMonth;
        sfdcClientToMap.BirthdateYear__pc          = incomingRmsClient.BirthdateYear;
        sfdcClientToMap.PersonEmail                = incomingRmsClient.Email;

        //AEF: removed for Ticket 0677
        //sfdcClientToMap.SPO_VATNumber__pc          = incomingRmsClient.VatNumber;
        //sfdcClientToMap.SPO_TaxID__pc              = incomingRmsClient.Taxid;

        // --- Added by MTOU - Harmo: populating "Contactable" fields --- //
        /*sfdcClientToMap.NationalityCountryCode__pc = incomingRmsClient.Nationality;
        sfdcClientToMap.PersonDoNotCall            = incomingRmsClient.DonotCall;
        sfdcClientToMap.DoNotSMS__pc               = incomingRmsClient.DoNotSMS;
        sfdcClientToMap.DoNotContactbyPost__pc     = incomingRmsClient.DoNotContactbyPost;
        sfdcClientToMap.PersonHasOptedOutOfEmail   = incomingRmsClient.HasOptedoutofEmail;*/

        sfdcClientToMap.Can_Be_Contacted_By_Phone__pc    = incomingRmsClient.DonotCall != NULL? !incomingRmsClient.DonotCall: NULL;
        sfdcClientToMap.Can_Be_Contacted_By_SMS__pc      = incomingRmsClient.DoNotSMS != NULL? !incomingRmsClient.DoNotSMS: NULL;
        sfdcClientToMap.Can_Be_Contacted_By_Mail__pc     = incomingRmsClient.DoNotContactbyPost != NULL? !incomingRmsClient.DoNotContactbyPost: NULL;
        sfdcClientToMap.Can_Be_Contacted_By_Email__pc    = incomingRmsClient.HasOptedoutofEmail != NULL? !incomingRmsClient.HasOptedoutofEmail: NULL;
        // ---End MTOU--- //

        sfdcClientToMap.PrimaryAddressLine1__pc    = incomingRmsClient.PrimaryAddressLine1;
        sfdcClientToMap.PrimaryAddressLine2__pc    = incomingRmsClient.PrimaryAddressLine2;
        sfdcClientToMap.PrimaryAddressLine3__pc    = incomingRmsClient.PrimaryAddressLine3;
        sfdcClientToMap.PrimaryZipCode__pc         = incomingRmsClient.PrimaryZipCode;
        sfdcClientToMap.PrimaryCity__pc            = incomingRmsClient.PrimaryCity;
        //sfdcClientToMap.PrimaryCountry__pc         = incomingRmsClient.PrimaryCountry;
        sfdcClientToMap.SPO_Country_code__pc         = incomingRmsClient.PrimaryCountry;
        sfdcClientToMap.HomeAddressCountryCode__pc = incomingRmsClient.PrimaryCountry;

        if(sfdcClientToMap.SPO_Country_code__pc != 'CHN')
        {
            sfdcClientToMap.PrimaryStateProvince__pc   = incomingRmsClient.PrimaryStateProvince;
        }
        else
        {
            sfdcClientToMap.SPO_Primary_Province_State__pc   = incomingRmsClient.PrimaryStateProvince;
        }
        
        //sfdcClientToMap.HomePhoneCountryCode__pc   = incomingRmsClient.HomePhoneCountryCode;        
        sfdcClientToMap.PersonHomePhone            = incomingRmsClient.HomePhone;
        //sfdcClientToMap.MobilePhoneCountryCode__pc = incomingRmsClient.MobilePhoneCountryCode;
        sfdcClientToMap.PersonMobilePhone          = incomingRmsClient.MobilePhone;
        //sfdcClientToMap.WorkPhoneCountryCode__pc   = incomingRmsClient.WorkPhoneCountryCode;
        sfdcClientToMap.Phone                      = incomingRmsClient.Phone;

        return sfdcClientToMap;
    }

    /**
     * [createAccountIntoRMS_WS : The function get Cloned client and map it to local client.
     *
     * @param  localClient   [The local client]
     * @param  clonedClient  [The cloned client]
     * @CreatedBy       N.G on January 2016
     * @LastModifiedBy  N.g on January 2016
     */
    public static void mapClonedClientToLocalClient(Account localClient, Account clonedClient)
    {
        system.debug('SFDC mapClonedClientToLocalClient clonedClient ' + clonedClient);
        
        localClient.Salutation                      = clonedClient.Salutation;
        localClient.FirstName                       = clonedClient.FirstName;
        localClient.LastName                        = clonedClient.LastName;
        localClient.Firstname2__pc                  = clonedClient.Firstname2__pc;
        localClient.Lastname2__pc                   = clonedClient.Lastname2__pc;

        localClient.TypologyCode__pc                = clonedClient.TypologyCode__pc;
        localClient.BirthdateDay__pc                = clonedClient.BirthdateDay__pc;
        localClient.BirthDateMonth__pc              = clonedClient.BirthDateMonth__pc;
        localClient.BirthdateYear__pc               = clonedClient.BirthdateYear__pc;
        localClient.PersonEmail                     = clonedClient.PersonEmail;

        //AEF: removed for Ticket 0677
        //localClient.SPO_VATNumber__pc               = clonedClient.SPO_VATNumber__pc;
        //localClient.SPO_TaxID__pc                   = clonedClient.SPO_TaxID__pc;

        localClient.NationalityCountryCode__pc      = clonedClient.NationalityCountryCode__pc;

        // ---Added by MTOU: populating "Contactable" fields ---//
        /*localClient.PersonDoNotCall                 = clonedClient.PersonDoNotCall;
        localClient.DoNotSMS__pc                    = clonedClient.DoNotSMS__pc;
        localClient.DoNotContactbyPost__pc          = clonedClient.DoNotContactbyPost__pc;
        localClient.PersonHasOptedOutOfEmail        = clonedClient.PersonHasOptedOutOfEmail;*/
        
        localClient.Can_Be_Contacted_By_Phone__pc   = clonedClient.Can_Be_Contacted_By_Phone__pc;
        localClient.Can_Be_Contacted_By_SMS__pc     = clonedClient.Can_Be_Contacted_By_SMS__pc;
        localClient.Can_Be_Contacted_By_Mail__pc    = clonedClient.Can_Be_Contacted_By_Mail__pc;
        localClient.Can_Be_Contacted_By_Email__pc   = clonedClient.Can_Be_Contacted_By_Email__pc;
        // ---End MTOU--- //

        localClient.PrimaryAddressLine1__pc         = clonedClient.PrimaryAddressLine1__pc;
        localClient.PrimaryAddressLine2__pc         = clonedClient.PrimaryAddressLine2__pc;
        localClient.PrimaryAddressLine3__pc         = clonedClient.PrimaryAddressLine3__pc;
        localClient.PrimaryZipCode__pc              = clonedClient.PrimaryZipCode__pc;
        localClient.PrimaryCity__pc                 = clonedClient.PrimaryCity__pc;
        localClient.SPO_Country_code__pc            = clonedClient.SPO_Country_code__pc;
        localClient.HomeAddressCountryCode__pc      = clonedClient.HomeAddressCountryCode__pc; 

        localClient.PrimaryStateProvince__pc        = clonedClient.PrimaryStateProvince__pc;
        localClient.SPO_Primary_Province_State__pc  = clonedClient.SPO_Primary_Province_State__pc;

        localClient.HomePhoneCountryCode__pc        = clonedClient.HomePhoneCountryCode__pc;
        localClient.PersonHomePhone                 = clonedClient.PersonHomePhone;
        localClient.MobilePhoneCountryCode__pc      = clonedClient.MobilePhoneCountryCode__pc;
        localClient.PersonMobilePhone               = clonedClient.PersonMobilePhone;
        localClient.WorkPhoneCountryCode__pc        = clonedClient.WorkPhoneCountryCode__pc;
        localClient.Phone                           = clonedClient.Phone;
        localClient.LocalHomePhone__pc              = clonedClient.LocalHomePhone__pc;   
        localClient.LocalMobilePhone__pc            = clonedClient.LocalMobilePhone__pc; 
        localClient.LocalWorkPhone__pc              = clonedClient.LocalWorkPhone__pc; 
        
        system.debug('SFDC mapClonedClientToLocalClient localClient ' + localClient);
    }

    /**
     * @description:  synchronization SFDC account with RMS client data
     * @author:       Efraim Fligil
    */
    public static Account syncClient(String storeCode, String rmsId, Account sfdcClient,String wwRmsClientCode) {
     
        SO_WS_RMS_DoClientEnquiryMulesoft ws = new SO_WS_RMS_DoClientEnquiryMulesoft();
        SO_WS_RMS_DoClientEnquiryMulesoft.DataInput dataIn = new SO_WS_RMS_DoClientEnquiryMulesoft.DataInput();

        //dataIn.StoreCode = pageSwitcher.currentUser.DefaultStore__c;
        dataIn.StoreCode = storeCode;
        dataIn.RMSId = rmsId; //'01295Q'; 
        dataIn.wwRmsClientCode = wwRmsClientCode; //'01295Q'; 

        System.debug('SFDC dataIn >> ' + dataIn);

        SO_WS_RMS_DoClientEnquiryMulesoft.Result result = ws.doClientEnquiry(dataIn);

        System.debug('SFDC WS result  >> ' + result);
        if(String.isNotBlank(result.error)) {

            SO_UTIL.exceptionDump(result.error);
            throw new SO_UTIL.RMSException(Label.SO_LV_WS_Error);
        }
        return MapRmsClientIntoSfdcClientMulesoft(result, sfdcClient); 
        } 
       

    

    public static String getCountryPhoneISO2(String code) {
        if(String.isBlank(code)){
            return  null;
        }
        Decimal codeInt  = Decimal.valueOf(code.removeStart('+'));
        List<Country__c> countries  = [Select Iso2Code__c FROM Country__c Where Calling_Code__c =: codeInt];
        if(!countries.isEmpty())
            return countries[0].Iso2Code__c ;
        return null;
    }
}