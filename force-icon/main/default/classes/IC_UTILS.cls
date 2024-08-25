/**
    About
    -----
    Description: Shared utilities for ICON porject
    Created for: SOW: IC00 ICON project
    Create date: FEB 2013

    Details
    -------
    This class contains methods that cover
        - ByPass trigger 
        - Get Record Types for Task, .. 
        - Describe schema, fields and assigned object,  
        - Append List to Map
        - Get Salesforce with current instance
        - Get Custom Settings
    
    Update History
    --------------
    Feb 2013 / IC001/ Created by Maroun Imad
    April 2014 / IC0N Release 2014/ Modified by Pape Babacar DIOUF  - Capgemini (Pape-Babacar.Diouf@capgemini.com)
    August 2016 New function to get 'management level' field for a defined user (support to new relic integration)
	June 2018 Add function return boolean user profile ICONICS 

    Issues / TODOs
    --------------
*/

public class IC_UTILS {
    
    public static string bypassTrigger = ''; //List of bypassed triggers
    public static boolean IsIconics = false;
    
    public static final User user;
    
    static {
        System.debug('*** PAD constructor : BEGIN run by ' +  UserInfo.getName()+ ' User Id: ' + UserInfo.getUserId());

        // "Automated process" user can create records but this user is not displayed
        List<User> luser = [Select BypassApexTriggers__c, profile.name from User where Id=:UserInfo.getUserId() limit 1];
        if (luser.size() > 0) {
            user = luser[0];
            bypassTrigger = ';'+ user.BypassApexTriggers__c + ';'; 
            //LEL Check if user Iconics profiles        
            If (user.profile.name.contains('ICONiCS')){
                IsIconics = true;
            } else {
                IsIconics = false;
            }
        }               
        System.debug('*** PAD constructor : END ***');
    }   
    
    /**
    * get The default user currency 
    */
    public static String getDefaultUserCurrency(){
        User currentUser = [Select Id, Currency__c from User where Id=:UserInfo.getUserId() limit 1];
        if(currentUser.Currency__c == null)
            return 'usd';
        else if(currentUser.Currency__c.contains('USD'))
            return 'usd';
        else if(currentUser.Currency__c.contains('EUR'))
            return 'eur';
        else if(currentUser.Currency__c.contains('JPY'))
            return 'yen';
        else if(currentUser.Currency__c.contains('CNY'))
            return 'yuan';
        return 'usd';
    }
    
    
    
    /**
    * get The default currency step 
    */
    public static Integer getDefaultCurrencyStep(){
        User currentUser = [Select Id, Currency__c from User where Id=:UserInfo.getUserId() limit 1];
        if(currentUser.Currency__c == null)
            return 0;
        else if(currentUser.Currency__c.contains('USD'))
            return 1;
        else if(currentUser.Currency__c.contains('EUR'))
            return 2;
        else if(currentUser.Currency__c.contains('JPY'))
            return 3;
        else if(currentUser.Currency__c.contains('CNY'))
            return 4;
        return 1;
    }
    
    
    
    
    /**
    * get The default currency step 
    */
    public static String getUserCountry(){
        User userr = [Select Id, Country__c From User WHERE Id = :UserInfo.getUserId() limit 1];
        return userr.Country__c;
    }
    
    
    

    /**
    * Check current user if is owner of record 
    * @param ownerId of any record from any object
    * @return boolean
    */
    public static boolean isRecordOwner(string ownerId){
        if (EMPTY(ownerId)) return false ;
        return (UserInfo.getUserId() == ownerId);

    }

    /**
    ** Check if current user has access to record
    ** @param recordId If of record in any object
    */
    public static boolean hasRecordAccess (String recordId) {
        UserRecordAccess a = [SELECT RecordId, HasReadAccess, HasEditAccess, HasAllAccess, MaxAccessLevel 
                              FROM UserRecordAccess
                              WHERE UserId = :UserInfo.getUserId()
                                AND RecordId = :recordId limit 1];
        if (IC_UTILS.empty(a)) return false;
        return (a.HasEditAccess || a.HasAllAccess);
    } 
         
    /**
    * Method used for the class PAD
    * @param c object of type 
    * @return boolean
    */
    public static boolean canTrigger(string Name){
        return (bypassTrigger.indexof(';' + Name + ';') == -1);
    }
    
    public static boolean isIconicsProfile(){
        return (IsIconics);

    }
    
    /**** Describe Info ****/
    public static Map<String, Schema.SObjectType> globalDescibe_Map
    {
        get
        {
            if (globalDescibe_Map==null)
            {
                globalDescibe_Map = Schema.getGlobalDescribe();
            }
            return globalDescibe_Map;
        }
        set;
    }
    
    static map<String, Map<String, Schema.SObjectField>> objectField_Map = new map<String, Map<String, Schema.SObjectField>>(); // map: object API name >> <field API name, describe info>
    public static Map<String, Schema.SObjectField> getFieldMap(String typeName)
    {
        if (objectField_Map.containsKey(typeName))
        {
            return objectField_Map.get(typeName);
        } else if (globalDescibe_Map.containsKey(typeName))
        {
            Schema.SObjectType productSchema = IC_UTILS.globalDescibe_Map.get(typeName);
            Map<String, Schema.SObjectField> fieldMap = productSchema.getDescribe().fields.getMap();
            objectField_Map.put(typeName,fieldMap);
            return fieldMap;
        }
        return null;
    }
    
    /**
    * Return List of Text fields in object
    * @param typeName object Name
    */
    static map<String, Map<String, Schema.SObjectField>> objectTextField_Map = new map<String, Map<String, Schema.SObjectField>>(); // map: object API name >> <field API name, describe info>
    public static Map<String, Schema.SObjectField> getTextFieldMap(String typeName)
    {
        if (objectTextField_Map.containsKey(typeName))
        {
            return objectTextField_Map.get(typeName);
        } else {
            Map<String, Schema.SObjectField> fieldsMap = getFieldMap(typeName);
            Map<String, Schema.SObjectField> textFieldsMap = new Map<String, Schema.SObjectField>();
            
            for (String field : fieldsMap.keySet()){
                Schema.DescribeFieldResult describeResult = fieldsMap.get(field).getDescribe();
                if(describeResult.getType()==Schema.DisplayType.TextArea || describeResult.getType()==Schema.DisplayType.String || describeResult.getName()=='Subject') {
                    if((!describeResult.isNameField() && describeResult.isAccessible()) || describeResult.getName()=='Subject') {
                        textFieldsMap.put(field, fieldsMap.get(field));
                    }
                }
            }
            objectTextField_Map.put(typeName,textFieldsMap);       
            return textFieldsMap;
        }
    }
        
    static map<Schema.SObjectField, Schema.DescribeFieldResult> objectFieldDescribe_Map = new map<Schema.SObjectField, Schema.DescribeFieldResult>(); // map: SObjectField >> DescribeFieldResult - used to reduce repeated describe calls in loops
    public static Schema.DescribeFieldResult getFieldDescribe(Schema.SObjectField field)
    {
        if (objectFieldDescribe_Map.containsKey(field))
        {
            return objectFieldDescribe_Map.get(field);
        } else if (field!=null)
        {
            Schema.DescribeFieldResult describeResult = field.getDescribe();
            objectFieldDescribe_Map.put(field,describeResult);
            return describeResult;
        }
        return null;
    }
    
    public static Schema.DescribeFieldResult getFieldDescribe(String typeName, String fieldName)
    {
        Map<String, Schema.SObjectField> fieldMap = getFieldMap(typeName);
        if (fieldMap.containsKey(fieldName)!=null) 
        {
            Schema.DescribeFieldResult fieldResult = getFieldDescribe(fieldMap.get(fieldName));
            if (fieldResult!=null) return fieldResult;
        }
        return null;
    }
    
    public static String getFieldLabel(String typeName, String fieldName)
    {
        Schema.DescribeFieldResult field = getFieldDescribe( typeName,  fieldName);
        if (field!=null) return field.getLabel();
        return '';
    }

    public static String getFieldDefaultValue(String typeName, String fieldName)
    {
        Schema.DescribeFieldResult field = getFieldDescribe( typeName,  fieldName);
        if (field!=null) return String.valueOf(field.getDefaultValueFormula());
        return '';
    }    
    
    /**** Maps ****/
    public static Map<Object,Object[]> mapListAppend(Map<Object,Object[]> m, Object key, Object value)
    {
        Object[] theList = new Object[]{};
        if (m.containsKey(key))
        {
            theList = m.get(key);
        }
        theList.add(value);
        m.put(key, theList);
        return m;
    }
    

    /**** Profiles ****/
    static String saProfile; // Profile for SA
    public static String getSAProfile()
    {
        if (IC_Utils.empty(saProfile)) 
        {
            saProfile = [Select Id from Profile where Name='ICON_SA'].Id;
        }
        return saProfile;
    }
    static String identityProfile; // Profile for SA
    public static String getIdentityProfile()
    {
        if (IC_Utils.empty(identityProfile)) 
        {
            identityProfile = [Select Id from Profile where Name='Identity User' and UserLicense.name ='External Identity' LIMIT 1].Id;
        }
        return identityProfile;
    }
    
     /**** User Default Store ****/
    static String userStore; // Store for user
    public static String getUserStore()
    {
        if (IC_Utils.empty(userStore)) 
        {
            userStore = [ Select Id, DefaultStore__c From User Where Id = :UserInfo.getUserId()].DefaultStore__c;
        }
        return userStore;
    }

    /**** User MANAGEMENT ZONE LEVEL ****/
    static String userManagement;
    public static String getUserManagement()
    {
        if (IC_Utils.empty(userManagement)) 
        {
            userManagement = [ Select Id, MANAGEMENT_ZONE_LEVEL__c From User Where Id = :UserInfo.getUserId()]?.MANAGEMENT_ZONE_LEVEL__c;
        }
        return userManagement;
    }   
       
    /**** User DreamId ****/
    static String dreamId; // dream id
    public static String getDreamId()
    {
        if (IC_Utils.empty(dreamId)) 
        {

            dreamId = [ Select Id, DREAMId__c From User Where Id = :UserInfo.getUserId()].DREAMId__c;
        }

        return dreamId;
    }
    
    
    //retrieving ids of different profiles
    
    
    static String sysAdminProfile; // Profile for System Admin
    public static String getSysAdminProfile()
    {
        if (IC_Utils.empty(sysAdminProfile)) 
        {
            sysAdminProfile = [Select Id from Profile where Id=:Label.IC_System_Admin_Profile_Id].Id;
        }
        return sysAdminProfile;
    }
    
    static String saManagerProfile; // Profile for SA Manager
    public static String getSAManagerProfile()
    {
        if (IC_Utils.empty(saManagerProfile)) 
        {
            saManagerProfile = [Select Id from Profile where Name='ICON_SA Manager'].Id;
        }
        return saManagerProfile;
    }
    
    static String saAnimatorProfile; // Profile for SA Animator
    public static String getSAAnimatorProfile()
    {
        if (IC_Utils.empty(saAnimatorProfile)) 
        {
            saAnimatorProfile = [Select Id from Profile where Name='ICON_SA Animator'].Id;
        }
        return saAnimatorProfile;
    }
    
    static String corporateProfile; // Profile for CorporateProfile manager of SA and SA Manager
    public static String getCorporateProfile()
    {
        if (IC_Utils.empty(corporateProfile)) 
        {
            corporateProfile = [Select Id from Profile where Name='ICON_Corporate'].Id;
        }
        return corporateProfile;
    }

    static String dreamProfile; // Interface Dream profile
    public static String getDreamProfile()
    {
        if (IC_Utils.empty(dreamProfile)) 
        {
            dreamProfile = [Select Id from Profile where Name='ICON_Interface DREAM'].Id;
        }
        return dreamProfile;
    }
    
    static String lvAdminProfile; // LV Admin profile
    public static String getLVAdminProfile()
    {
        if (IC_Utils.empty(lvAdminProfile)) 
        {
            lvAdminProfile = [Select Id from Profile where Name='ICON_LV Administrator'].Id;
        }
        return lvAdminProfile;
    }

    static String lvCountryAdminProfile; // LV Country Admin profile
    public static String getLVCountryAdminProfile()
    {
        if (IC_Utils.empty(lvCountryAdminProfile)) 
        {
            lvCountryAdminProfile = [Select Id from Profile where Name='ICON_LV_Country_Admin'].Id;
        }
        return lvCountryAdminProfile;
    }

    static String IconMonitoringProfile; // ICON Monitoring profile
    public static String getIconMonitoringProfile()
    {
        if (IC_Utils.empty(IconMonitoringProfile)) 
        {
            IconMonitoringProfile = [Select Id from Profile where Name='ICON_Monitoring'].Id;
        }
        return IconMonitoringProfile;
    }

    static String IconStarCorporateProfile; // ICON STAR Corporate profile
    public static String getIconStarCorporateProfile()
    {
        if (IC_Utils.empty(IconStarCorporateProfile)) 
        {
            IconStarCorporateProfile = [Select Id from Profile where Name='ICON_STAR_Corporate'].Id;
        }
        return IconStarCorporateProfile;
    }

    static String StarCorporateProfile; // STAR Corporate profile
    public static String getStarCorporateProfile()
    {
        if (IC_Utils.empty(StarCorporateProfile)) 
        {
            StarCorporateProfile = [Select Id from Profile where Name='STAR_Corporate'].Id;
        }
        return StarCorporateProfile;
    }
    
    // 28/12/2016 MTOU: getting Interface datastage profile
    static String InterfaceDatastageProfile;
    public static String getInterfaceDatastageProfile()
    {
        if(IC_Utils.empty(InterfaceDatastageProfile))
        {
            InterfaceDatastageProfile = [Select Id from Profile where Name = 'LV_Interface_Datastage'].id;
        }
        return InterfaceDatastageProfile;
    }


    
    /**** Check connected user profile ****/
    public static Boolean isSA()
    {
        return (getSAProfile() ==  UserInfo.getProfileId());
    }

    public static Boolean isSAManager()
    {
        return (getSAManagerProfile() ==  UserInfo.getProfileId());
    }
    
    public static Boolean isSAAnimator()
    {
        return (getSAAnimatorProfile() ==  UserInfo.getProfileId());
    }
    
    public static Boolean isCorporate()
    {
        return (getCorporateProfile() ==  UserInfo.getProfileId());
    }

    public static Boolean isInterfaceDream()
    {
        return (getDreamProfile() ==  UserInfo.getProfileId());
    }
    
    public static Boolean isLVAdmin()
    {
        return (getLVAdminProfile() ==  UserInfo.getProfileId());
    }
    
    public static Boolean isLVCountryAdmin()
    {
        return (getLVCountryAdminProfile() ==  UserInfo.getProfileId());
    }
    
    public static Boolean isICONMonitoring()
    {
        return (getIconMonitoringProfile() ==  UserInfo.getProfileId());
    }
    
    public static Boolean isICONSTARCorporate()
    {
        return (getIconStarCorporateProfile() ==  UserInfo.getProfileId());
    }
    
    public static Boolean isSTARCorporate()
    {
        return (getStarCorporateProfile() ==  UserInfo.getProfileId());
    }
    
    public static Boolean isSystemAdmin()
    {
        return (getSysAdminProfile() ==  UserInfo.getProfileId());
    }

    // 28/12/2016 MTOU: getting Interface Datastage user
    public static Boolean isInterfaceDatastage()
    {
        return (getInterfaceDatastageProfile() == UserInfo.getProfileId());
    }
    
    /**** Record Types ****/
    static String taskRT; // RT for exchange rates set up by users for their own use
    public static String getTaskRT()
    {
        if (IC_Utils.empty(taskRT)) 
        {
            taskRT = [Select Id from RecordType where DeveloperName='TSK_To_Do' and sObjectType = 'TASK'].Id;
        }
        return taskRT;
    }

    static String taskDreamRT; // RT for exchange rates set up by users for their own use
    public static String getTaskDreamRT()
    {
        if (IC_Utils.empty(taskDreamRT)) 
        {
            taskDreamRT = [Select Id from RecordType where DeveloperName='DREAMContact' and sObjectType = 'TASK'].Id;
        }
        return taskDreamRT;
    }
    
    /**** URL ****/
    public static String sfInstance {
        public get {
            if (sfInstance == null) {
                //
                // Possible Scenarios:
                //
                // (1) ion--test1--nexus.cs0.visual.force.com  --- 5 parts, Instance is 2nd part
                // (2) na12.salesforce.com      --- 3 parts, Instance is 1st part
                // (3) ion.my.salesforce.com    --- 4 parts, Instance is not determinable
    
                // Split up the hostname using the period as a delimiter
                List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api','').split('\\.');
                if (parts.size() == 3) sfInstance = parts[0];
                else if (parts.size() == 5) sfInstance = parts[1];
                else sfInstance = null;
            } return sfInstance;
        } private set;
    }
    
    // And you can then get the Salesforce base URL like this:
    public static String baseURL() 
    {
         return 'https://' + sfInstance + '.salesforce.com';
    }
   
    public static Map<String,String> getURLParameters(String url) 
    {
        Map<String,String> paramsMap = new Map<String,String>();
        if (empty(url)) return paramsMap;
        String[] params = url.substring(url.indexof('?')+1).split('&');
        for (String param  : params) {
            String[] paramValue = param.split('=');
            if (paramValue.size() < 2) paramsMap.put(paramValue[0], '');
            else paramsMap.put(paramValue[0], paramValue[1]); 
        }
        return paramsMap;
    }
    
    /**** Lists ****/
    //Convert a List to a Set
    public static Set<String> toSet(List<String> l)
    {
        Set<String> s = new Set<String>();
        s.addAll(l);
        return s;
    }

    // Return a set from an object list  of a field
    public static set<String> getIdList(List<Sobject> items, String fieldName)
    {
       Set<String> s = new Set<String>();
   
       for(Sobject ob : items)
       {
            s.add((string)ob.get(fieldName));
       }
       return s;         
    }  
        
    // Convert a mutiselect staring of values into a string list
    public static String[] deserializeMultiSelect(String mutiSelectList)
    {
        return mutiSelectList!=null ? mutiSelectList.split(';') : new String[]{};
    }
    
    // Convert a string list or set or mutiselect picklist string into a CSV set
    public static String serializeWithQuotes(String[] aList)
    {
        String csv = '';
        for (String s:aList)
        {
            csv += '\''+s+'\',';
        }
        csv = csv.removeEnd(',');
        return csv;
    }
    public static String serializeWithQuotes(String mutiSelectList)
    {
        String[] aList = mutiSelectList!=null ? mutiSelectList.split(';') : new String[]{};
        return serializeWithQuotes(aList);
    }
    public static String serializeWithQuotes(Set<String> aSet)
    {
        String[] aList = new String[]{};
        aList.addAll(aSet);
        return serializeWithQuotes(aList);
    }
       
    //Sort sObjects (alt do this in dynamic soql if using soql based pagination)
    public static void orderList(List<Sobject> items, String sortField, String theOrder)
    {
        theOrder = theOrder.toLowerCase();  
       List<Sobject> resultList = new List<Sobject>();
   
        //Create a map that can be used for sorting 
       Map<object, List<Sobject>> objectMap = new Map<object, List<Sobject>>();
       
       for(Sobject ob : items)
       {
            if(objectMap.get(ob.get(sortField)) == null)
            {
                objectMap.put(ob.get(sortField), new List<Sobject>()); 
            }
            objectMap.get(ob.get(sortField)).add(ob);
        }       
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();
       
        for(object key : keys){ 
            resultList.addAll(objectMap.get(key)); 
        }
       
        //Apply the sorted values to the source list
        items.clear();
        if(theOrder == 'asc')
        {
            for(Sobject ob : resultList)
            {
                items.add(ob); 
            }
        }
        else if(theOrder == 'desc')
        {
            for(integer i = resultList.size()-1; i >= 0; i--)
            {
                items.add(resultList[i]);  
            }
        }
    }  
    
    /**** Math ****/
    public static Decimal round(decimal aNumber, integer places)
    {
        return aNumber.setScale(places,System.RoundingMode.HALF_UP);
    }
    
    /**** Generic shortcut methods ****/
    public static Boolean empty(Object o)
    {
        return o==null || String.valueOf(o)=='';
    }
    public static Boolean empty(Integer o)
    {
        return o==null || o==0;
    }
    public static Boolean empty(Decimal o)
    {
        return o==null || o==0;
    }
     /**** Security ****/
    public static Boolean isCheckIpActive()
    {
        Boolean ipTocheck = (Boolean)cs('Check_IpAddress__c');
        return ipTocheck;
    }
      
    public static String cs_Login_Page()
    {
        return (String)cs('Login_Page__c','https://icon-louisvuitton.dev1.cs15.force.com/login');
    }
    
    public static String cs_Email_Domain()
    {
        return (String)cs('Email_Domain__c','@fr.vuitton.com.dev1');
    }
    
    public static String cs_Domain()
    {
        return (String)cs('Domain__c','cs15.salesforce.com');
    }

    public static String cs_Default_ShowAs()
    {
        return (String)cs('Default_ShowAs__c','Busy');
    }

    public static String cs_Callback_Link(String cb)
    {
        String url = '';
        try {
            url = (String)cs('Link_' + cb + '__c','IC_Home');
        } catch(Exception e) {
            url = 'IC_Home';
        }
        return url;
    }
    
    public static Integer cs_Sesssion_Timeout()
    {
        return Integer.valueOf(cs('Session_Timeout__c'));
    }

    static Object cs(String field, Object defaultValue)
    {
        Object value = cs(field);
        return value == null ? defaultValue : value;
    }
    static Object cs(String field)
    {
        Object value =  ICONSettings__c.getOrgDefaults().get(field);
        return value;
    }
     
     
    /**  Returns List of picklist Values  **/
    
    public static List<String> getPickListVal(String obj, String fld, String fldEx) {
        
      System.debug ('*** Start to get Picklist Values on ' + obj + '/'+ fld);
      List<String> options = new List<String>();            
      // Get the object type of the SObject.
      SobjectType objType = Schema.getGlobalDescribe().get(obj);
      //Schema.sObjectType objType = sobj.getSObjectType(); 
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      // Get a map of fields for the SObject
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      // Get the list of picklist values for this field.
      list<Schema.PicklistEntry> values =
         fieldMap.get(fld).getDescribe().getPickListValues();
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a : values)
      { 
        if (a.getValue()!=fldEx){
         options.add(a.getValue());
        } 
      }
      System.debug ('***  options size=' + options.size());
      System.debug ('*** End to get Picklist Values ');
      return options;
    }
    
    /**
     *  Translate the locale to a culture name
     *  @see https://github.com/jquery/globalize
     *  @return (String)
    **/
    public static String getLocale(){
        //-- @TODO: use a custom setting for the ballback instead of a separate file.
        String localization = UserInfo.getLocale();
        //localization = 'cucamonga';
        localization = localization.replace( '_', '-' );
        return( localization );
    }
    
    /**
     *  Translate the locale to a culture name
     *  @see https://github.com/jquery/globalize
     *  @return (String)
    **/
    public static String getLang(){
        String lang = UserInfo.getLanguage();
        lang = lang.replace( '_', '-' );
        return( lang );
    }  
    
    
    /**
     *  Check if the user country is included in the list of countries to display the second name.
     *  @see https://github.com/jquery/globalize
     *  @return (Boolean)
    **/
    public static Boolean canDisplaySecondName(){
        ICONSettings__c settings = [Select i.Name, i.Id, i.CountryWhereDisplayName2__c From ICONSettings__c i limit 1][0];
        String countiesAsOneString = settings.CountryWhereDisplayName2__c;
        
        if (!IC_Utils.empty(countiesAsOneString )) 
        {
            User userr = [Select Country__c from User where Id=:UserInfo.getUserId() limit 1];
            
            List<String> countries = countiesAsOneString.split(',');
            for(String country : countries){
                country = country.trim();
                if(userr.Country__c == country)
                    return true;
            }
        }
        return false;
    }
    
    
    /**
     *  Check if the user country is included in the list of countries to display We Chat icon.
     *  @see https://github.com/jquery/globalize
     *  @return (Boolean)
    **/
    public static Boolean canShowWeChat(){
        ICONSettings__c settings = [Select i.Name, i.Id, i.ShowWeChat__c From ICONSettings__c i limit 1][0];
        String countiesAsOneString = settings.ShowWeChat__c;
        
        if (!IC_Utils.empty(countiesAsOneString )) 
        {
            User userr = [Select Country__c from User where Id=:UserInfo.getUserId() limit 1];
            
            List<String> countries = countiesAsOneString.split(',');
            for(String country : countries){
                country = country.trim();
                if(userr.Country__c == country)
                    return true;
            }
        }
        return false;
    }   
    
    
    
    /**
    * Method to retrieve the translation of picklist values
    * @param objectName the object name 
    * @param fieldName the picklist field name
    * @param picklistValue the value of picklist
    * @return string (the translation of picklist value)
    */
    public static String getTranslationPicklistValue(String objectName, String fieldName, String picklistValue){
        if(picklistValue == null)
            return '';
        String picklistLabel = '';
        list<Schema.PicklistEntry> ctrPLV =  IC_UTILS.getFieldDescribe(objectName, fieldName).getPicklistValues();
        for(Schema.PicklistEntry plv : ctrPLV){
            if(plv.getValue() == picklistValue){
                picklistLabel = plv.getLabel();
                return picklistLabel;
            }
        }
        return picklistValue;
    }
    
    
    
   /**
    * Method to retrieve the value of picklist label
    * @param objectName the object name 
    * @param fieldName the picklist field name
    * @param picklistLabel the label of picklist
    * @return string (the translation of picklist value)
    */
    public static String getValuePicklistLabel(String objectName, String fieldName, String picklistLabel){
        if(picklistLabel == null)
            return '';
        String picklistValue = '';
        list<Schema.PicklistEntry> ctrPLV =  IC_UTILS.getFieldDescribe(objectName, fieldName).getPicklistValues();
        for(Schema.PicklistEntry plv : ctrPLV){
            if(plv.getLabel() == picklistLabel){
                picklistValue = plv.getValue();
                return picklistValue;
            }
        }
        return picklistValue;
    }
    
    
    
     
   /**
     *  Translate the locale to a culture name
    **/
    public static Boolean CLL_CreatedBy_TCL(Id clientListId){
        List<CLI_CliList__c> listt = [Select Id, TECH_CreatedFromTCLScreen__c From CLI_CliList__c  Where Id = :clientListId];
        if(listt.size()> 0){
            CLI_CliList__c cll = listt[0];
            if(cll.TECH_CreatedFromTCLScreen__c)
                return cll.TECH_CreatedFromTCLScreen__c;
            else
                return false;
        }
        return false;
    }  
    
    
    
    /**
     *  Get Indexed Days From Birthdate Scheduled Days 
    **/
    public static List<String> getIndexedDays_BR(){
        List<String> theList = new List<String>();
        
        ICONSettings__c settings = [Select Name, Id, BirthdateScheduledDays__c From ICONSettings__c i limit 1][0];
        String BirthdateScheduledDays = settings.BirthdateScheduledDays__c;
        if(BirthdateScheduledDays == '' || BirthdateScheduledDays == null) return theList;
        List<String> BirthdateScheduledDaysList =  BirthdateScheduledDays.split(',');
        for(integer i=0; i<BirthdateScheduledDaysList.size(); i++){
            BirthdateScheduledDaysList[i] = BirthdateScheduledDaysList[i].trim();
        }
        if(BirthdateScheduledDaysList.size() == 1){
            if(Integer.valueOf(BirthdateScheduledDaysList[0]) == Date.today().day()){
                theList = new List<String> { '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31' };
                return theList;
            }
        }
        else if(BirthdateScheduledDaysList.size() == 2){
            if(Integer.valueOf(BirthdateScheduledDaysList[0]) == Date.today().day()){
                theList = new List<String> { '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15' };
                return theList;
            }
            else if(Integer.valueOf(BirthdateScheduledDaysList[1]) == Date.today().day()){
                theList = new List<String> { '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31' };
                return theList;
            }
        }
        else if(BirthdateScheduledDaysList.size() == 3){
            if(Integer.valueOf(BirthdateScheduledDaysList[0]) == Date.today().day()){
                theList = new List<String> { '1', '2', '3', '4', '5', '6', '7', '8', '9', '10' };
                return theList;
            }
            else if(Integer.valueOf(BirthdateScheduledDaysList[1]) == Date.today().day()){
                theList = new List<String> { '11', '12', '13', '14', '15', '16', '17', '18', '19', '20' };
                return theList;
            }
            else if(Integer.valueOf(BirthdateScheduledDaysList[2]) == Date.today().day()){
                theList = new List<String> { '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31' };
                return theList;
            }
        }
        return theList;
    }
     
     
    
    
    /**
     *  Get Indexed Days From Anniversary Scheduled Days 
    **/
    public static List<String> getIndexedDays_AR(){
        List<String> theList = new List<String>();
        
        ICONSettings__c settings = [Select Name, Id, AnniversaryScheduledDays__c From ICONSettings__c i limit 1][0];
        String AnniversaryScheduledDays = settings.AnniversaryScheduledDays__c;
        if(AnniversaryScheduledDays == '' || AnniversaryScheduledDays == null) return theList;
        List<String> AnniversaryScheduledDaysList =  AnniversaryScheduledDays.split(',');
        for(integer i=0; i<AnniversaryScheduledDaysList.size(); i++){
            AnniversaryScheduledDaysList[i] = AnniversaryScheduledDaysList[i].trim();
        }
        if(AnniversaryScheduledDaysList.size() == 1){
            if(Integer.valueOf(AnniversaryScheduledDaysList[0]) == Date.today().day()){
                theList = new List<String> { '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31' };
                return theList;
            }
        }
        else if(AnniversaryScheduledDaysList.size() == 2){
            if(Integer.valueOf(AnniversaryScheduledDaysList[0]) == Date.today().day()){
                theList = new List<String> { '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15' };
                return theList;
            }
            else if(Integer.valueOf(AnniversaryScheduledDaysList[1]) == Date.today().day()){
                theList = new List<String> { '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31' };
                return theList;
            }
        }
        else if(AnniversaryScheduledDaysList.size() == 3){
            if(Integer.valueOf(AnniversaryScheduledDaysList[0]) == Date.today().day()){
                theList = new List<String> { '1', '2', '3', '4', '5', '6', '7', '8', '9', '10' };
                return theList;
            }
            else if(Integer.valueOf(AnniversaryScheduledDaysList[1]) == Date.today().day()){
                theList = new List<String> { '11', '12', '13', '14', '15', '16', '17', '18', '19', '20' };
                return theList;
            }
            else if(Integer.valueOf(AnniversaryScheduledDaysList[2]) == Date.today().day()){
                theList = new List<String> { '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31' };
                return theList;
            }
        }
        return theList;
    }
    
    
    /**
     *  Get All the sub roles ids from of the roles given in parameter 
    **/
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

        Set<ID> currentRoleIds = new Set<ID>();
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null]) {
            currentRoleIds.add(userRole.Id);
        }
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
    }
    
    
    /**
    public static String getPersonAccountRT(){
        String paRT = '';
        paRT = [Select Id from RecordType where DeveloperName='ACC_PersonAccount' and sObjectType = 'Account'].Id;
        return paRT;
    }
    
    public static String getStarAccountRT(){
        String paRT = '';
        paRT = [Select Id from RecordType where DeveloperName='ACC_StarAccount' and sObjectType = 'Account'].Id;
        return paRT;
    }
    **/

/*    
    public static Boolean inStarApp()
    {
        String appStarLabel = 'STAR';
        Boolean inStarApp = false;

        // Get tab set describes for each app
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();

        // Iterate through each tab set describe for each app and display the info
        for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
            if (tsr.getLabel() == appStarLabel && tsr.isSelected()){
                inStarApp = true;  
                break;
            }
            else {
                inStarApp = false;
            }
         }  
         return inStarApp;    

      } 
*/  
//  public static String AdminProfile = 'System Administrator';
//  public static String STARCorporateProfile ='STAR_Corporate';
//  public static String ICONSTARCorporateProfile='ICON_STAR_Corporate';
    
    static String userCountry;
    public static String countryNameDisplay () {
        
        if (IC_Utils.empty(userCountry)){
            userCountry = [ Select Id, Country__c From User Where Id = :UserInfo.getUserId()].Country__c;
        }
        System.debug('*** userCountry ***' + userCountry);
        
        List<CountryConfig__c> settings = [Select Name, ClientNameDisplay__c From CountryConfig__c];
        if (IC_Utils.empty(settings)) return '';
        
        for(CountryConfig__c dcl : settings){
            System.debug('*** dcl.Name ***' + dcl.Name); 
            String countryName = dcl.Name.toUpperCase();
            
            if(countryName.equals(userCountry)){
                return (dcl.ClientNameDisplay__c != null? dcl.ClientNameDisplay__c : '');
            }
        } 
        return '';        
    }
    /***
     * Pilot Settings
     */

    public static Boolean isInPilotStores()  {
        User u = [SELECT DefaultStore__c FROM User WHERE Id = :UserInfo.getUserId()];
        List<IconSetting__mdt> iconSettings = [
            SELECT Text__c, Boolean__c
            FROM IconSetting__mdt 
            WHERE QualifiedApiName ='Pilot_Store_Codes'
        ];
        if(iconSettings.size() > 0) {
            Boolean isExclude = iconSettings[0].Boolean__c;
            if(iconSettings[0].Text__c == null || u.DefaultStore__c == null) {
                return isExclude;    
            } 
            else {
                Boolean isContained = iconSettings[0].Text__c.indexOf(u.DefaultStore__c) > -1;
                return isExclude == false ? isContained : !isContained;
            }
        }
        return true;
    }



    public static Boolean isInPilotBeta(String application)  {
        try {
            User u = [SELECT DefaultStore__c, MANAGEMENT_ZONE_LEVEL__c, country__c, ProfileId FROM User WHERE Id = :UserInfo.getUserId()];
            List<Pilot_Setting__mdt> pilotSettings = [
                SELECT Application__c, Mode__c, Stores__c, Countries__c, Zones__c, Excluded_Countries__c, Excluded_Stores__c,
                ProfileIds__c, Excluded_ProfileIds__c, High_Priority_Excluded_ProfileIds__c, High_Priority_ProfileIds__c
                FROM Pilot_Setting__mdt 
                WHERE Application__c = : application LIMIT 1
            ];
            if(pilotSettings.size() > 0) {
                Pilot_Setting__mdt pilotSetting = pilotSettings[0];
                if(pilotSetting.Mode__c.equalsIgnoreCase('WW_Deployed')) {
                    return true;
                } else if(pilotSetting.Mode__c.equalsIgnoreCase('Unavailable')){
                    return false;
                } else if (pilotSetting.Mode__c.equalsIgnoreCase('Pilot')){
                    return isPriorityProfileId(u, pilotSetting.High_Priority_ProfileIds__c) ||
                    !isPriorityExcludedProfileId(u, pilotSetting.High_Priority_Excluded_ProfileIds__c) && isProfileId(u, pilotSetting.ProfileIds__c, pilotSetting.Excluded_ProfileIds__c) && (isStore(u, pilotSetting.Stores__c) ||
                        isCountry(u, pilotSetting.Countries__c, pilotSetting.Excluded_Stores__c) ||
                        isZone(u,  pilotSetting.Zones__c, pilotSetting.Excluded_Stores__c, pilotSetting.Excluded_Countries__c ))
                        ;
                }
                return true;
            }
            return true;
        } catch (Exception e ) {
            system.debug(e.getMessage());
            return isInPilotStores();
        }
        
    }
    
    
    public static Boolean isInPilotVirtual()  {
        try {
            User u = [SELECT DefaultStore__c, MANAGEMENT_ZONE_LEVEL__c, country__c, ProfileId FROM User WHERE Id = :UserInfo.getUserId()];
            List<Pilot_Setting__mdt> virtualSettings = [
                SELECT Application__c, Mode__c, Stores__c, Countries__c, Zones__c, Excluded_Countries__c, Excluded_Stores__c,
                ProfileIds__c, Excluded_ProfileIds__c, High_Priority_Excluded_ProfileIds__c, High_Priority_ProfileIds__c
                FROM Pilot_Setting__mdt 
                WHERE QualifiedApiName = 'OSA_Virtual_Settings' LIMIT 1
            ];
            if(virtualSettings.size() > 0) {
                Pilot_Setting__mdt virtualSetting = virtualSettings[0];
                if(virtualSetting.Mode__c.equalsIgnoreCase('WW_Deployed')) {
                    return true;
                } else if(virtualSetting.Mode__c.equalsIgnoreCase('Unavailable')){
                    return false;
                } else if (virtualSetting.Mode__c.equalsIgnoreCase('Pilot')){
                    return isPriorityProfileId(u, virtualSetting.High_Priority_ProfileIds__c) ||
                    !isPriorityExcludedProfileId(u, virtualSetting.High_Priority_Excluded_ProfileIds__c) && isProfileId(u, virtualSetting.ProfileIds__c, virtualSetting.Excluded_ProfileIds__c) && (isStore(u, virtualSetting.Stores__c) ||
                        isCountry(u, virtualSetting.Countries__c, virtualSetting.Excluded_Stores__c) ||
                        isZone(u,  virtualSetting.Zones__c, virtualSetting.Excluded_Stores__c, virtualSetting.Excluded_Countries__c ))
                        ;
                }
                return true;
            }
            return true;
        } catch (Exception e ) {
            system.debug(e.getMessage());
            return false;
        }
        
    }

    public static Boolean isUserInPilot(String feature)  {
        try {
            User u = [SELECT DefaultStore__c, MANAGEMENT_ZONE_LEVEL__c, country__c, ProfileId FROM User WHERE Id = :UserInfo.getUserId()];
            List<Pilot_Setting__mdt> pilotSettings = [
                SELECT Application__c, Mode__c, Stores__c, Countries__c, Zones__c, Excluded_Countries__c, Excluded_Stores__c,
                ProfileIds__c, Excluded_ProfileIds__c, High_Priority_Excluded_ProfileIds__c, High_Priority_ProfileIds__c
                FROM Pilot_Setting__mdt 
                WHERE QualifiedApiName = :feature LIMIT 1
            ];
            if(pilotSettings.size() > 0) {
                Pilot_Setting__mdt pilotSetting = pilotSettings[0];
                if(pilotSetting.Mode__c.equalsIgnoreCase('WW_Deployed')) {
                    return true;
                } else if(pilotSetting.Mode__c.equalsIgnoreCase('Unavailable')){
                    return false;
                } else if (pilotSetting.Mode__c.equalsIgnoreCase('Pilot')){
                    return isPriorityProfileId(u, pilotSetting.High_Priority_ProfileIds__c) ||
                    !isPriorityExcludedProfileId(u, pilotSetting.High_Priority_Excluded_ProfileIds__c) && isProfileId(u, pilotSetting.ProfileIds__c, pilotSetting.Excluded_ProfileIds__c) && (isStore(u, pilotSetting.Stores__c) ||
                        isCountry(u, pilotSetting.Countries__c, pilotSetting.Excluded_Stores__c) ||
                        isZone(u,  pilotSetting.Zones__c, pilotSetting.Excluded_Stores__c, pilotSetting.Excluded_Countries__c ))
                        ;
                }
                return true;
            }
            return true;
        } catch (Exception e ) {
            system.debug(e.getMessage());
            return false;
        }
        
    }
    

    private static Boolean isStore(User u, String stores) {
        if(String.isBlank(stores) || String.isBlank(u.DefaultStore__c)) {
            system.debug('isStores false');
            return false;
        }
        system.debug('isStores ' + (stores.containsIgnoreCase(u.DefaultStore__c)));
        return stores.containsIgnoreCase(u.DefaultStore__c);
    }

    private static Boolean isCountry(User u, String countries, String excludedStores) {
        if(String.isBlank(countries) || String.isBlank(u.country__c)) {
            system.debug('isCountry false');
            return false;
        }
        system.debug('isCountry ' + (countries.containsIgnoreCase(u.country__c) && ( String.isBlank(excludedStores) || !excludedStores.containsIgnoreCase(u.DefaultStore__c))));
        return countries.containsIgnoreCase(u.country__c) && ( String.isBlank(excludedStores) || !excludedStores.containsIgnoreCase(u.DefaultStore__c));
    }

    private static Boolean isZone(User u, String zones, String excludedStores, String excludedCountries) {
        if(String.isBlank(zones) || String.isBlank(u.MANAGEMENT_ZONE_LEVEL__c)) {
            system.debug('iszone false');
            return false;
        }
        system.debug('iszone ' + (zones.containsIgnoreCase(u.MANAGEMENT_ZONE_LEVEL__c) &&
        ( String.isBlank(excludedStores) || !excludedStores.containsIgnoreCase(u.DefaultStore__c)) && 
        ( String.isBlank(excludedCountries) || !excludedCountries.containsIgnoreCase(u.country__c))));
        return zones.containsIgnoreCase(u.MANAGEMENT_ZONE_LEVEL__c) &&
        ( String.isBlank(excludedStores) || !excludedStores.containsIgnoreCase(u.DefaultStore__c)) && 
        ( String.isBlank(excludedCountries) || !excludedCountries.containsIgnoreCase(u.country__c));
    }

    private static Boolean isProfileId(User u, String profileIds, String excludedProfileIds) {
        if(String.isBlank(profileIds)) {
            system.debug('isProfileId' + (String.isBlank(excludedProfileIds) || !excludedProfileIds.contains(u.ProfileId)));
            return (String.isBlank(excludedProfileIds) || !excludedProfileIds.contains(u.ProfileId));
        } 
        system.debug('isProfileId' + (profileIds.contains(u.ProfileId)  && (String.isBlank(excludedProfileIds) || !excludedProfileIds.contains(u.ProfileId))));
        return profileIds.contains(u.ProfileId)  && (String.isBlank(excludedProfileIds) || !excludedProfileIds.contains(u.ProfileId));
    }

    private static Boolean isPriorityProfileId(User u, String profileIds) {
        if(String.isBlank(profileIds)) {
            system.debug('isPriorityProfileId false');
            return false;
        } 
        system.debug('isPriorityProfileId '  +(profileIds.contains(u.ProfileId)));
        return profileIds.contains(u.ProfileId) ;
    }

    private static Boolean isPriorityExcludedProfileId(User u, String excludedProfileIds) {
        if(String.isBlank(excludedProfileIds)) {
            system.debug('isPriorityExcludedProfileIds false');
            return false;
        } 
        system.debug('isPriorityExcludedProfileIds ' + (excludedProfileIds.contains(u.ProfileId) ));
        return excludedProfileIds.contains(u.ProfileId) ;
    }

    /**
     * Notification Permission
     */

    public static Boolean isNotificationAllowed(string application, string store, string country, string zone) {
        try {
            String query = 'SELECT Application__c, Mode__c, Countries__c, Excluded_Countries__c, Excluded_Stores__c, Stores__c, Zones__c '+
            'FROM Notification_Permission__mdt WHERE '+
            'Application__c =: application '
            //+ 'AND Channel__c = :channel ' +
            // 'AND Scenario__c = :scenario ' 
            ;
            

            List<Notification_Permission__mdt> notifSettings = Database.query(query);
            if(notifSettings.size() > 0) {
                Notification_Permission__mdt notifSetting = notifSettings[0];
                if(notifSetting.Mode__c.equalsIgnoreCase('WW')) {
                    return true ;
                } else if(notifSetting.Mode__c.equalsIgnoreCase('Unavailable')){
                    return false;
                } else if (notifSetting.Mode__c.equalsIgnoreCase('Filtered')){
                    return !isExcludedNotifStore(store, notifSetting.Excluded_Stores__c) && !isExcludedNotifCountry(country, notifSetting.Excluded_Countries__c);                   
                }
                return true;
            }
            return true;
        }catch(Exception e){
            System.debug(e.getMessage() + e.getLineNumber());
            return true;
        }
    }

    public static Notification_Permission__mdt getNotificationPermissionByApplication(string application) {
        String query = 'SELECT Application__c, Mode__c, Countries__c, Excluded_Countries__c, Excluded_Stores__c, Stores__c, Zones__c '+
            'FROM Notification_Permission__mdt WHERE '+
            'Application__c =: application ';

        List<Notification_Permission__mdt> notifSettings = Database.query(query);    

        return !notifSettings.isEmpty() ? notifSettings.get(0) : null;
    }

    public static Boolean isNotificationsAllowed(Notification_Permission__mdt notifSetting, string store, string country, string zone) {
        try {
            
            if(notifSetting.Mode__c.equalsIgnoreCase('WW')) {
                return true ;
            } else if(notifSetting.Mode__c.equalsIgnoreCase('Unavailable')){
                return false;
            } else if (notifSetting.Mode__c.equalsIgnoreCase('Filtered')){
                return !isExcludedNotifStore(store, notifSetting.Excluded_Stores__c) && !isExcludedNotifCountry(country, notifSetting.Excluded_Countries__c);                   
            }
            return true;
          
        }catch(Exception e){
            System.debug(e.getMessage() + e.getLineNumber());
            return true;
        }
    }

    private static Boolean isExcludedNotifStore(String currentStore, String excludedStores) {
        if(String.isBlank(excludedStores) || String.isBlank(currentStore) ) {
            return false;
        }
        return excludedStores.containsIgnoreCase(currentStore);
    }

    private static Boolean isExcludedNotifCountry(String currentCountry, String excludedCountries) {
        if(String.isBlank(excludedCountries) || String.isBlank(currentCountry)) {
            return false;
        }
        return excludedCountries.containsIgnoreCase(currentCountry);
    }

 @TestVisible    private static Boolean isNotifStore(String currentStore, String stores, String excludedStores) {
        if(String.isBlank(stores) && isExcludedNotifStore(currentStore, excludedStores) || String.isBlank(currentStore)) {
            system.debug('isStores false');
            return false;
        }
        return String.isBlank(stores) || stores.containsIgnoreCase(currentStore);
    }

 @TestVisible   private static Boolean isNotifCountry(String currentCountry, String currentStore, String countries, String excludedStores,  String excludedCountries) {
        if(String.isBlank(countries) && isExcludedNotifCountry(currentCountry, excludedCountries)  || String.isBlank(currentCountry)) {
            system.debug('isCountry false');
            return false;
        }
        system.debug('isCountry ' + (countries.containsIgnoreCase(currentCountry) && ( String.isBlank(excludedStores) || !excludedStores.containsIgnoreCase(currentStore))));
        return countries.containsIgnoreCase(currentCountry) && ( String.isBlank(excludedStores) || !excludedStores.containsIgnoreCase(currentStore));
    }

  @TestVisible  private static Boolean isNotifZone(String currentZone, String currentCountry, String currentStore, String zones, String excludedStores, String excludedCountries) {
        if(String.isBlank(zones) || String.isBlank(currentZone)) {
            system.debug('iszone false');
            return false;
        }
        system.debug('iszone ' + (zones.containsIgnoreCase(currentZone) &&
        ( String.isBlank(excludedStores) || !excludedStores.containsIgnoreCase(currentStore)) && 
        ( String.isBlank(excludedCountries) || !excludedCountries.containsIgnoreCase(currentCountry))));
        return zones.containsIgnoreCase(currentZone) &&
        ( String.isBlank(excludedStores) || !excludedStores.containsIgnoreCase(currentStore)) && ( String.isBlank(excludedCountries) || !excludedCountries.containsIgnoreCase(currentCountry));
    }
      
}