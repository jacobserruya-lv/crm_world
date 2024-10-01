public with sharing class ICX_OrderSearch_Helper {

    class OrderSearchException extends Exception{}

    public ICX_OrderSearch_Helper() {

    }

    // 
    // public static Object initOrderSearch() {
    //     // // 1 - Exclude existing shippingNumber in OrderSearch__c
    //     List<Order_Search__c> shippingNumberExistingList = [Select Id FROM Order_Search__c];

    //     // 2 - Retrieve data
        // List<OrderLine__c> orderLineList = [SELECT SKU__c,
        //                                             ProductReferential__r.ProductCategory__c,
        //                                             Order__c,
        //                                                 Order__r.OrderNumber__c,
        //                                                 Order__r.Store__c,
        //                                                 Order__r.OwnerId__r.Name,
        //                                                 Order__r.OwnerId__r.WWEmployeeNumber__c,
        //                                                 Order__r.CreatedDate,
        //                                                 Order__r.statusiconics__c,
        //                                                 Order__r.Account__c,
        //                                                     Order__r.Account__r.DREAMID__c,
        //                                                     Order__r.Account__r.Name,
        //                                                     Order__r.Account__r.Segmentation__c,
        //                                                     Order__r.Account__r.PersonEmail,
        //                                                     Order__r.Account__r.PersonMobilePhone,
        //                                                     Order__r.Account__r.PersonHomePhone,
        //                                                     Order__r.Account__r.Phone,
        //                                             OrderShipping__c,
        //                                                 OrderShipping__r.Name,
        //                                                 OrderShipping__r.ShippingNumber__c,
        //                                                 OrderShipping__r.StatusIconics__c,
        //                                                 OrderShipping__r.Status__c
        //                                     FROM OrderLine__c
        //                                     WHERE OrderShipping__r.ShippingNumber__c not in :shippingNumberList];

    //     // 3 - Insert data

    //     List<Order_Search__c> soList = new List<Order_Search__c>();
    //     Order_Search__c so;
    //     for(OrderLine__c ol : orderLineList) {
    //         system.debug('ol.OrderShipping__r.ShippingNumber__c,:'+ol.OrderShipping__r.ShippingNumber__c);

    //         so = new Order_Search__c();
    //         so.Product_Sku__c                       = ol.SKU__c;
    //         so.Product_category__c                  = ol.ProductReferential__r.ProductCategory__c;
    //         so.Order__c                             = ol.Order__c;
    //         so.Order_Number__c                      = ol.Order__r.OrderNumber__c;
    //         //so.Order_Store__c                       = ol.Order__r.Store__c;
    //         so.Order_Owner_Name__c                  = ol.Order__r.OwnerId__r.Name;
    //         so.Order_Owner_WWID__c                  = ol.Order__r.OwnerId__r.WWEmployeeNumber__c;
    //         so.Order_Date_create_date__c            = ol.Order__r.CreatedDate;
    //         so.Order_Status_reworked__c             = ol.Order__r.StatusIconics__c;
    //         so.Client__c                            = ol.Order__r.Account__c;
    //         so.Client_DREAM_ID__c                   = ol.Order__r.Account__r.DREAMID__c;
    //         so.Client_Name__c                       = ol.Order__r.Account__r.Name;
    //         so.Client_Segmentation__c               = ol.Order__r.Account__r.Segmentation__c;
    //         //so.Order_Account_PersonEmail__c         = ol.Order__r.Account__r.PersonEmail;
    //         so.Client_Phone_Mobile__c               = ol.Order__r.Account__r.PersonMobilePhone;
    //         so.Client_Phone_Home__c                 = ol.Order__r.Account__r.PersonHomePhone;
    //         so.Client_Phone_Work__c                 = ol.Order__r.Account__r.Phone;
    //         //so.OrderShipping__c                     = ol.OrderShipping__c;
    //         so.Shipping_Group_Number__c             = ol.OrderShipping__r.ShippingNumber__c;
    //         so.Shipping_Group_Name__c               = ol.OrderShipping__r.Name;
    //         so.Shipping_Group_Status_KBRW_not_rework__c       = ol.OrderShipping__r.StatusIconics__c;
    //         so.Shipping_Group_Status_reworked__c    = ol.OrderShipping__r.Status__c;

    //         soList.add(so);
    //     }

    //     // Database.insert(soList);

    //     return new Map<Id, Object>();
    // }

    // public static Object updateAccountData(List<SObject> triggerNew, Map<Id,Account> triggerNewMap, Map<Id,Account> triggerOldMap){
    //     return new Map<Id, Object>();
    // } 

    public static List<Order_Search__c> getOrderSearchByOrder(String entityName, List<String> orderIds){
        // 1) Retrieve dynamically all fields in SELECT
        // 2) Set dynamically the WHERE clause
        System.debug('getOrderSearchByOrder(List<String> orderIds):'+orderIds);
        List<Order_Search__c> orderSearchMap;
        
        Integer nbOfTry = 0;
        Boolean hasRetry = false;

        do {
            try {
                hasRetry = false;
                if (entityName == 'OrderLine__c') {
                    orderSearchMap = [SELECT Id, Client__c FROM Order_Search__c WHERE Order_Line__c in :orderIds FOR UPDATE];
                } else if (entityName == 'OrderShipping__c') { 
                    orderSearchMap = [SELECT Id FROM Order_Search__c WHERE Order_Shipping__c in :orderIds FOR UPDATE];
                } else if (entityName == 'Order__c') { 
                    orderSearchMap = [SELECT Id FROM Order_Search__c WHERE Order__c in :orderIds FOR UPDATE];
                } else if (entityName == 'account') { 
                    orderSearchMap = [SELECT Id FROM Order_Search__c WHERE Client__c in :orderIds FOR UPDATE] ;
                } else if (entityName == 'contact') { 
                    orderSearchMap = [SELECT Id FROM Order_Search__c WHERE Client__r.PersonContactId in :orderIds FOR UPDATE] ;
                } 
            }
            catch(QueryException e) {
                nbOfTry++;
                if (nbOfTry <= 5) {
                    hasRetry = true;
                }
                else {
                    throw e;
                }
            }
        } while (hasRetry);


        return orderSearchMap;

    } 

    // public static void updateOrderShipping(){

    // } 

    // public static void updateOrderLine(){

    // } 

    public static String getSelectClauseQuery(ICX_Order_Search_Listener__mdt osl ) {
        return '';
    }


    public static void updOrderSearchFromUserAccountId(List<Order_Search__c> orderSearchToUpdateList, ICX_Order_Search_Listener__mdt osl, List<String> recordIds) {
        List<Id> accountIds = new List<Id>();
        Map<String, String> mappingMap= new Map<String, String>();

        for(Order_Search__c orderSearch : orderSearchToUpdateList) {
            accountIds.add(orderSearch.Client__c);
        }

        // Construct the SOQL query
        String selectClause='';
        String keyMap = 'accountId';
        Boolean hasKey = false;
        String objectName, fieldName, fieldNameTarget, relatedPath;
        for (ICX_Order_Search_Field__mdt osf: osl.ICX_Order_Search_Fields__r) {

            OrderSearchFieldWrapper osfw = new OrderSearchFieldWrapper(osf);

            objectName      = osfw.getSourceObject();
            fieldName       = osfw.getSourceField();
            fieldNameTarget = osfw.getTargetField();
            relatedPath     = (osfw.getRelationshipInListenedObject()!=null?osfw.getRelationshipInListenedObject()+'.':'');

            mappingMap.put(fieldNameTarget, relatedPath+fieldName);
            if (!haskey) {
                haskey = (fieldName == keyMap);
            }
            selectClause = (selectClause?.length()==0?'':selectClause+', ') + relatedPath+fieldName;
        }
        System.debug('selectClause:' + selectClause);
        System.debug('mappingMap:' + mappingMap);

        if (!hasKey) {
            selectClause = selectClause + ',' + keyMap;
        }

        // String query = 'SELECT ' + selectClause + 'FROM OrderLine__c'+ 'WHERE id in'
        List<User> users = Database.query('SELECT ' + selectClause + ' FROM User '+ 'WHERE accountId in :accountIds and accountId != null');

        //
        Map<Id, User> userByClientId = new Map<Id, User>();
        for (User u: users) {
            userByClientId.put(u.accountId, u);
        }
        //
        String fieldInQuery;
        for(Order_Search__c orderSearch: orderSearchToUpdateList) {
            User u = userByClientId.get(orderSearch.client__c);
            system.debug('updOrderSearchFromUserAccountId-user u:'+u);
            if (u != null) {
                for(String fieldNameOrderSearch: mappingMap.keySet()) {
                    system.debug('updOrderSearchFromUserAccountId-fieldNameOrderSearch:'+fieldNameOrderSearch);
                    fieldInQuery = mappingMap.get(fieldNameOrderSearch);
                    system.debug('updOrderSearchFromUserAccountId-fieldInQuery:'+fieldInQuery);
                    orderSearch.put(fieldNameOrderSearch, ExtractFieldValues(u, fieldInQuery));
                }
            }
        }

        system.debug('ordersSearch to update from user : '+orderSearchToUpdateList);
        update orderSearchToUpdateList;

    }

    public static void insertOrderSearchFromOrderLine(ICX_Order_Search_Listener__mdt osl, List<String> recordIds) {
        Map<String, String> mappingMap= new Map<String, String>();

        // Construct the SOQL query
        String selectClause='';
        String objectName, fieldName, fieldNameTarget, relatedPath;
        for (ICX_Order_Search_Field__mdt osf: osl.ICX_Order_Search_Fields__r) {

            OrderSearchFieldWrapper osfw = new OrderSearchFieldWrapper(osf);

            objectName      = osfw.getSourceObject();
            fieldName       = osfw.getSourceField();
            fieldNameTarget = osfw.getTargetField();
            relatedPath     = (osfw.getRelationshipInListenedObject()!=null?osfw.getRelationshipInListenedObject()+'.':'');

            mappingMap.put(fieldNameTarget, relatedPath+fieldName);
            selectClause = (selectClause?.length()==0?'':selectClause+', ') + relatedPath+fieldName;
        }
        System.debug('selectClause:' + selectClause);
        System.debug('mappingMap:' + mappingMap);

        //List<String> recordIds = new List<String>(changeEvent.header.recordIds);

        // String query = 'SELECT ' + selectClause + 'FROM OrderLine__c'+ 'WHERE id in'
        List<OrderLine__c> orderLineList = Database.query('SELECT ' + selectClause + ' FROM OrderLine__c '+ 'WHERE Id in :recordIds');

        Order_Search__c orderSearch;
        List<Order_Search__c> orderSearchToCreateList = new List<Order_Search__c>();
        
        System.debug('orderLineList: '+orderLineList);

        String fieldInQuery;
        for(OrderLine__c orderLine: orderLineList) {
            orderSearch = new Order_Search__c();
            for(String fieldNameOrderSearch: mappingMap.keySet()) {
                fieldInQuery = mappingMap.get(fieldNameOrderSearch);
                //system.debug(fieldNameOrderSearch + ' = ' + ExtractFieldValues(orderLine, fieldInQuery));
                orderSearch.put(fieldNameOrderSearch, ExtractFieldValues(orderLine, fieldInQuery));
            }
            //system.debug('orderSearch to insert : '+orderSearch);
            orderSearchToCreateList.add(orderSearch);
        }
        system.debug('ordersSearch to insert : '+orderSearchToCreateList);

        Database.SaveResult[] srList = Database.insert(orderSearchToCreateList, false);

        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred. / '+err.getStatusCode() + ': ' + err.getMessage()+ '/ fields that affected this error: ' + err.getFields());                    
                }
            }
        }
    }
    

    //
    public static void onChangeEvent(List<ICX_ChangeEventWrapper> changeEventList) {
        // Map of (Field+new Value) by Record Id 
        //Map<Id, List<Map<String, Object>>>
        //Map<List<String>, Map<String, Object>> recordsToUpdate = new Map<List<String>, Map<String, Object>>();

        List<Order_Search__c> orderSearchToUpdateList = new List<Order_Search__c>();

        List<ICX_Order_Search_Listener__mdt> oslAllList = [SELECT Object_To_Listen__r.QualifiedAPIName,
                                                                    Operation_Type__c,
                                                                    Apex_Method_to_Execute__c,
                                                                    Execution_Order__c,
                                                                    (SELECT Id, 
                                                                            ICX_Object_Field__r.Source_Object__r.QualifiedAPIName, 
                                                                            ICX_Object_Field__r.Source_Field__r.QualifiedAPIName,
                                                                            ICX_Object_Field__r.Source_Object_Not_managed__c, 
                                                                            ICX_Object_Field__r.Source_Field_Not_managed__c,
                                                                            ICX_Object_Field_Target__r.Source_Object__r.QualifiedAPIName, 
                                                                            ICX_Object_Field_Target__r.Source_Field__r.QualifiedAPIName,
                                                                            ICX_Object_Field_Target__r.Source_Object_Not_managed__c, 
                                                                            ICX_Object_Field_Target__r.Source_Field_Not_managed__c,
                                                                            Relationship_in_listened_Object__c
                                                                    FROM ICX_Order_Search_Fields__r)
                                                            FROM ICX_Order_Search_Listener__mdt                                                           
                                                            ORDER BY Execution_Order__c ASC];


        // For each changeEvent
        for(ICX_ChangeEventWrapper changeEvent: changeEventList) {
            // We check if "changed fields" are listened
            system.debug('onChangeEvent - ' + changeEvent.header.entityName + ' - ' + changeEvent.header.changeType + ' : ' + changeEvent.header.changedfields);

            // 1. Retrieve ordersearchListener__mdt
            // ICX_Object_Field__r.Source_Object__r.QualifiedAPIName, *
            // ICX_Object_Field__r.Source_Field__r.QualifiedAPIName

            List<ICX_Order_Search_Listener__mdt> oslList =  new List<ICX_Order_Search_Listener__mdt>();

            for (ICX_Order_Search_Listener__mdt osl : oslAllList) {
                if ( (osl.Object_To_Listen__r.QualifiedAPIName == changeEvent.header.entityName) 
                    && (osl.Operation_Type__c == changeEvent.header.changeType) ) {
                        oslList.add(osl);
                    }
            }                                                           
             

            // // 2. IF it exists at least 1 listener on this object and this operation
            // ICX_Order_Search_Listener__mdt osl;
            // if (oslList.size() == 1) {
            //     osl = oslList.get(0);
            // }
            // else {
            //     // todo
            // }

            for(ICX_Order_Search_Listener__mdt osl: oslList) {

                if(osl.Apex_Method_to_Execute__c == 'insertOrderSearchFromOrderLine') {
                    insertOrderSearchFromOrderLine(osl, new List<String>(changeEvent.header.recordIds));
                }
                else {

                    // Get OrderSearch__c records to be updated
                    List<Order_Search__c> orderSearchList = getOrderSearchByOrder(changeEvent.header.entityName, changeEvent.header.recordIds);

                    if (osl.Apex_Method_to_Execute__c == 'updOrderSearchFromUserAccountId') {
                        updOrderSearchFromUserAccountId(orderSearchList, osl, changeEvent.header.recordIds);
                    }
                    else if (osl.Apex_Method_to_Execute__c == 'genericUpdate') {

                        // Todo a loop if we implement a notion of "execution order" (v2) in case where multiple apex method should be executed                 

                        Map<ICX_Order_Search_Field__mdt, Object> fieldValueToUpdateMap = new Map<ICX_Order_Search_Field__mdt, Object>();

                        // Loop over Fields listened
                        for (ICX_Order_Search_Field__mdt osf: osl.ICX_Order_Search_Fields__r) {
                            // 
                            String fieldName = osf.ICX_Object_Field__r.Source_Field__r.QualifiedAPIName;
                            Object fieldValue = changeEvent.getChangedFieldsValues(osf.ICX_Object_Field__r.Source_Field__r.QualifiedAPIName);

                            if(changeEvent.header.changedfields.contains(fieldName)) {
                                //system.debug('onChangeEvent - ' + fieldName + ' modified ');
                                //system.debug('onChangeEvent - ' + fieldValue + ' new value ');
                                //system.debug('onChangeEvent - ' + osl.Apex_Method_to_Execute__c + ' to execute ');
                                
                                fieldValueToUpdateMap.put(osf, fieldValue);                 
                            }
                        }

                        System.debug('fieldValueToUpdateMap'+fieldValueToUpdateMap);
                        System.debug('fieldValueToUpdateMap.size()'+fieldValueToUpdateMap.size());

                        // IF at least 1 field need to be updated
                        if (fieldValueToUpdateMap.size() > 0) {
                            
                            // Set values
                            system.debug('before - orderSearchList: '+orderSearchList);
                            for(Order_Search__c orderSearch: orderSearchList) {
                                for(ICX_Order_Search_Field__mdt orderSearchField: fieldValueToUpdateMap.keySet()) {
                                    orderSearch.put(orderSearchField.ICX_Object_Field_Target__r.Source_Field__r.QualifiedAPIName, fieldValueToUpdateMap.get(orderSearchField) );
                                }
                            }
                            system.debug('after - orderSearchList: '+orderSearchList);
                            orderSearchToUpdateList.addAll(orderSearchList);
                        }
                    }
                    else {
                        System.debug('ICX_OrderSearch_Helper - Apex Method To Execute unknow or missing : '+osl.Apex_Method_to_Execute__c);
                    }
                }
            }
        }

        update orderSearchToUpdateList;
    }

    public class OrderSearchFieldWrapper {
        private ICX_Order_Search_Field__mdt record;

        OrderSearchFieldWrapper(ICX_Order_Search_Field__mdt record) {
            this.record = record;
        }

        // objectName      = osf.ICX_Object_Field__r.Source_Object__r.QualifiedAPIName;
        // fieldName       = osf.ICX_Object_Field__r.Source_Field__r.QualifiedAPIName;
        // fieldNameTarget = osf.ICX_Object_Field_Target__r.Source_Field__r.QualifiedAPIName;
        // relatedPath     = osf.Relationship_in_listened_Object__c;

        public String getSourceField() {
            String sourceField;
            if (this.record.ICX_Object_Field__r.Source_Field_Not_managed__c != null)
                sourceField =  this.record.ICX_Object_Field__r.Source_Field_Not_managed__c;
            else sourceField = this.record.ICX_Object_Field__r.Source_Field__r.QualifiedAPIName;
            
            return sourceField;
        }

        
        public String getSourceObject() {            
            String sourceObject;
            if (this.record.ICX_Object_Field__r.Source_Field_Not_managed__c != null)
                sourceObject =  this.record.ICX_Object_Field__r.Source_Object_Not_managed__c;
            else sourceObject = this.record.ICX_Object_Field__r.Source_Object__r.QualifiedAPIName;
            
            return sourceObject;
        }

        public String getTargetField() {
            String sourceField;
            if (this.record.ICX_Object_Field_Target__r.Source_Field_Not_managed__c != null)
                sourceField =  this.record.ICX_Object_Field_Target__r.Source_Field_Not_managed__c;
            else sourceField = this.record.ICX_Object_Field_Target__r.Source_Field__r.QualifiedAPIName;
            
            return sourceField;
        }

        
        public String getTargetObject() {            
            String sourceObject;
            if (this.record.ICX_Object_Field_Target__r.Source_Field_Not_managed__c != null)
                sourceObject =  this.record.ICX_Object_Field_Target__r.Source_Object_Not_managed__c;
            else sourceObject = this.record.ICX_Object_Field_Target__r.Source_Object__r.QualifiedAPIName;
            
            return sourceObject;
        }

        
        public String getRelationShipInListenedObject() {
            return this.record.Relationship_in_listened_Object__c;
        }
    }

    public static Object ExtractFieldValues(sObject record, string fieldAPIName){
        Object fvalue=null;
        sObject sb = record;
        if(fieldAPIName.contains('.')){
            List<string> splitedFields = fieldAPIName.split('\\.');
            try{
                for(integer i=0;i<splitedFields.size()-1;i++){
                    sb=sb.getSobject(splitedFields[i]);   
                }
                fvalue = sb.get(splitedFields[splitedFields.size()-1]);
            }catch(exception ex){
               //system.debug('******exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
               fvalue=null;
            }
            
        }else if(sb.get(fieldAPIName)!=null){
            fvalue = sb.get(fieldAPIName);
        }
        return fvalue;
    }
}