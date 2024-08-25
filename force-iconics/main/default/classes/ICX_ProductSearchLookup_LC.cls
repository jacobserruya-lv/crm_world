/**
 * ICONiCS - Product Search Lookup based on the LookupSearchResult class
 * Based on https://github.com/pozil/sfdc-ui-lookup/blob/master/src-sample/main/default/classes/SampleLookupController.cls
**/
public with sharing class ICX_ProductSearchLookup_LC {

    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(cacheable=true)
    public static List<ICX_ProductLookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
            ProductCatalogue__c (Id, Name, SKU__c, Image1Url__c, ProductGroup__c WHERE id NOT IN :selectedIds)
            //Opportunity (Id, Name, StageName WHERE id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS];
        
        // Prepare results
        List<ICX_ProductLookupSearchResult> results = buildLookupSearchList((List<ProductCatalogue__c>) searchResults[0], null, null);
        return results;
    }

    @AuraEnabled
    public static List<List<ICX_ProductLookupSearchResult>> searchAllRecords(String recordId) {
        List<List<ICX_ProductLookupSearchResult>> result = new List<List<ICX_ProductLookupSearchResult>>();

        List<ICX_ProductLookupSearchResult> knownProductResults = searchRecord(recordId);
        List<ICX_ProductLookupSearchResult> unknownProductResults = searchUnknownProduct(recordId);

        result.add(knownProductResults);
        result.add(unknownProductResults);
        //result.add(new List<ICX_ProductLookupSearchResult>());
        return result;
    }

    @AuraEnabled
    public static List<ICX_ProductLookupSearchResult> searchRecord(String recordId) {
        List<ICX_ProductLookupSearchResult> results = new List<ICX_ProductLookupSearchResult>();

        System.debug('recordId=' + recordId);
        if (String.isNotBlank(recordId)) {
            String recordIdResult;
            try {
                //Id recordId18 = Id.valueOf(recordId);
                // convert 15 digits to 18 digits (as ICX_ProductEnquired__c.RelatedTo__c is not a lookup as Task can't be a lookup)
                Id recordId18 = recordId;
                recordIdResult = recordId18;
                System.debug('recordId18=' + recordId18);
                // if we get here, it's a valid ID and the sID field is an 18 character one
            } catch (Exception e){
                // if it goes here, it's not an ID. Do something if you need to.
                System.debug('Record Id error ' + recordId);
                // Record id can be a Flow id (from New button on Case Listview or Account detail page)
                recordIdResult = recordId;
            }
            System.debug('recordIdResult ' + recordIdResult);

            // get all products for the recordId
            Set<Id> productIdSet = new Set<Id>();
            Map<Id, ICX_ProductEnquired__c> prodEnqByIdMap = new Map<Id, ICX_ProductEnquired__c>(); 
            //for (ICX_ProductEnquired__c prodEnq : [SELECT Product__c, Request__c, Request__r.CaseNumber, ParentRelatedTo__c, Store__c, Store_ClientAdvisor__c, ProductUnitPrice__c, ProductCurrency__c, ClientContactPreference__c, ClientDesiredDate__c, RequestType__c, Nature__c, Category__c, Domaine__c, Comment__c, CreateRequest__c, HotSku__c, ProductCollection__c FROM ICX_ProductEnquired__c WHERE RelatedTo__c = :recordId18 AND Product__c != '' ORDER BY LastModifiedDate ASC]) {
            for (ICX_ProductEnquired__c prodEnq : [SELECT Id, Product__c, Request__c, Request__r.CaseNumber, ParentRelatedTo__c, Store__c, Store_ClientAdvisor__c, ProductUnitPrice__c, ProductCurrency__c, ClientContactPreference__c, ClientDesiredDate__c, RequestType__c, Comment__c, CreateRequest__c, HotSku__c, ProductCollection__c, Email__c, Phone__c, Follow_up_By_Call__c, Follow_up_By_Email__c FROM ICX_ProductEnquired__c WHERE RelatedTo__c = :recordIdResult AND Product__c != '' ORDER BY LastModifiedDate ASC]) {
            //    if (String.isNotBlank(prodEnq.Product__c)) {
                    productIdSet.add(prodEnq.Product__c);
                    prodEnqByIdMap.put(prodEnq.Product__c, prodEnq);
            //    }
            }
            
            // for a call, the CSC advisor can create a Case with a copy of the products of the call (new Product Enquired records). 
            // We want to know in the call, if any product of the call was used to create a Case (and display the Case Number in the product Lightning Component)
//            for (ICX_ProductEnquired__c prodEnq : [SELECT Product__c, Request__c, Request__r.CaseNumber, ParentRelatedTo__c, Store__c, Store_ClientAdvisor__c, ProductUnitPrice__c, ProductCurrency__c, ClientContactPreference__c, ClientDesiredDate__c, RequestType__c, Nature__c, Category__c, Domaine__c, Comment__c, CreateRequest__c, HotSku__c, ProductCollection__c FROM ICX_ProductEnquired__c WHERE ParentRelatedTo__c = :recordId18 AND Product__c != '' ORDER BY LastModifiedDate ASC]) {
            for (ICX_ProductEnquired__c prodEnq : [SELECT Id, Product__c, Request__c, Request__r.CaseNumber, ParentRelatedTo__c, Store__c, Store_ClientAdvisor__c, ProductUnitPrice__c, ProductCurrency__c, ClientContactPreference__c, ClientDesiredDate__c, RequestType__c, Comment__c, CreateRequest__c, HotSku__c, ProductCollection__c,Email__c, Phone__c, Follow_up_By_Call__c, Follow_up_By_Email__c FROM ICX_ProductEnquired__c WHERE ParentRelatedTo__c = :recordIdResult AND Product__c != '' ORDER BY LastModifiedDate ASC]) {
                //if (String.isNotBlank(prodEnq.Product__c)) {
                // if the product from the parent exists, switch to this record to display the Request in the component
                if (String.isNotBlank(prodEnq.ParentRelatedTo__c) && prodEnqByIdMap.get(prodEnq.Product__c) != null) {
                    prodEnqByIdMap.put(prodEnq.Product__c, prodEnq);
                }
            }
            List<ProductCatalogue__c> prodList = [SELECT Id, Name, SKU__c, Image1Url__c, ProductGroup__c FROM ProductCatalogue__c WHERE Id IN :productIdSet];
          //  List<ICX_ProductEnquired__c> prodList = [SELECT Id, (SELECT Id, Name, SKU__c, Image1Url__c FROM Product__c) FROM ICX_ProductEnquired__c WHERE RelatedTo__c = :recordId];
            //List<ProductCatalogue__c> prodList = [SELECT Id, Name, SKU__c, Image1Url__c FROM ProductCatalogue__c WHERE Id IN (SELECT RelatedTo__c FROM ICX_ProductEnquired__c WHERE RelatedTo__c = :recordId)];

            results = buildLookupSearchList(prodList, prodEnqByIdMap, recordIdResult);
        }
        return results;
    }

    // Get all unknown products for the current record id 
    @AuraEnabled
    public static List<ICX_ProductLookupSearchResult> searchUnknownProduct(String recordId) {
        List<ICX_ProductLookupSearchResult> results = new List<ICX_ProductLookupSearchResult>();

        if (String.isNotBlank(recordId)) {
            String recordIdResult;
            try {
                //Id recordId18 = Id.valueOf(recordId);
                // convert 15 digits to 18 digits (as ICX_ProductEnquired__c.RelatedTo__c is not a lookup as Task can't be a lookup)
                Id recordId18 = recordId;
                recordIdResult = recordId18;
                System.debug('recordId18=' + recordId18);
                // if we get here, it's a valid ID and the sID field is an 18 character one
            } catch (Exception e){
                // if it goes here, it's not an ID. Do something if you need to.
                System.debug('Record Id error ' + recordId);
                // Record id can be a Flow id (from New button on Case Listview or Account detail page)
                recordIdResult = recordId;
            }
            System.debug('recordIdResult ' + recordIdResult);


            Map<Id, ICX_ProductEnquired__c> unknownMap =  new Map<Id, ICX_ProductEnquired__c>([SELECT Id, Product__c, Request__c, Request__r.CaseNumber, ParentRelatedTo__c, Store__c, Store_ClientAdvisor__c, ProductUnitPrice__c, ProductCurrency__c, ClientContactPreference__c, ClientDesiredDate__c, Product_Unknown__c, ProductCategory__c, ProductCollection__c, ProductGender__c, Comment__c, RequestType__c, CreateRequest__c, Email__c, Phone__c, Follow_up_By_Call__c, Follow_up_By_Email__c
                                                   FROM ICX_ProductEnquired__c WHERE RelatedTo__c = :recordIdResult AND Product__c = '' ORDER BY CreatedDate ASC]);
            /*for (ICX_ProductEnquired__c prodEnq : [SELECT Id, Product__c, Request__c, Request__r.CaseNumber, ParentRelatedTo__c, Store__c, Store_ClientAdvisor__c, ProductUnitPrice__c, ProductCurrency__c, ClientContactPreference__c, ClientDesiredDate__c, Product_Unknown__c, ProductCategory__c, ProductCollection__c, ProductGender__c, Comment__c, RequestType__c, CreateRequest__c 
                                                   FROM ICX_ProductEnquired__c WHERE (RelatedTo__c = :recordId18 OR ParentRelatedTo__c = :recordId18) AND Product__c = '' ORDER BY CreatedDate ASC]) {
                //if (String.isNotBlank(prodEnq.Comment__c)) {
                    
                    ICX_ProductLookupSearchResult lookupItem = buildLookupSearch(prodEnq);
                    results.add(lookupItem);

                //}
            }*/

            // Check if we can group Unknown products (one selected for a call and one for the New Request based on a call record)
            Map<Id, ICX_ProductEnquired__c> productToRemoveMap = new Map<Id, ICX_ProductEnquired__c>();
            for (ICX_ProductEnquired__c prodEnq : [SELECT Id, Product__c, Request__c, Request__r.CaseNumber, ParentRelatedTo__c, Store__c, Store_ClientAdvisor__c, ProductUnitPrice__c, ProductCurrency__c, ClientContactPreference__c, ClientDesiredDate__c, Product_Unknown__c, ProductCategory__c, ProductCollection__c, ProductGender__c, Comment__c, RequestType__c, CreateRequest__c, Email__c, Phone__c, Follow_up_By_Call__c, Follow_up_By_Email__c 
                                                   FROM ICX_ProductEnquired__c WHERE ParentRelatedTo__c = :recordIdResult AND Product__c = '' ORDER BY CreatedDate ASC]) {
                Boolean toRemove = false;
                for (ICX_ProductEnquired__c unknown : unknownMap.values()) {
                    if (unknown != null 
                            && (String.isNotBlank(prodEnq.Product_Unknown__c) && prodEnq.Product_Unknown__c.equals(unknown.Product_Unknown__c))
                            && (String.isNotBlank(prodEnq.ProductGender__c) && prodEnq.ProductGender__c.equals(unknown.ProductGender__c))
                            && (String.isNotBlank(prodEnq.ProductCategory__c) && prodEnq.ProductCategory__c.equals(unknown.ProductCategory__c))
                            && (String.isNotBlank(prodEnq.ProductCollection__c) && prodEnq.ProductCollection__c.equals(unknown.ProductCollection__c))
                       ) {
                           productToRemoveMap.put(unknown.Id, unknown);
                           toRemove = true;
                           break;
                        }
                }
                System.debug('toRemove/prodEnq=' + toRemove + '/' + prodEnq);
                if (toRemove) {
                    unknownMap.put(prodEnq.Id, prodEnq);
                }
            }
            
            for (Id removeId : productToRemoveMap.keySet()) {
                unknownMap.remove(removeId);
            }

            for (ICX_ProductEnquired__c prodEnq : unknownMap.values()) {
                ICX_ProductLookupSearchResult lookupItem = buildLookupSearch(prodEnq);
                results.add(lookupItem);
            }
        }
        System.debug('searchUnknownProduct=' + results);
        return results;
    }

    private static List<ICX_ProductLookupSearchResult> buildLookupSearchList(List<ProductCatalogue__c> products, Map<Id, ICX_ProductEnquired__c> prodEnqByProductIdMap, String recordId) {
        List<ICX_ProductLookupSearchResult> results = new List<ICX_ProductLookupSearchResult>();

        if (products != null) {
            System.debug('prodEnqByProductIdMap=' + prodEnqByProductIdMap);
            ICX_ProductLookupSearchResult lookupItem;
            for (ProductCatalogue__c product : products) {
                ICX_ProductEnquired__c prodEnq = (prodEnqByProductIdMap != null? prodEnqByProductIdMap.get(product.Id) : null);
                
                lookupItem = new ICX_ProductLookupSearchResult(
                    product.Id, 
                    'ProductCatalogue__c', 
                    String.isNotBlank(product.Image1Url__c) ? product.Image1Url__c : 'custom:custom55',
                    String.isNotBlank(product.Image1Url__c) ? true : false,
                    product.Name, 
                    product.SKU__c + (String.isNotBlank(product.ProductGroup__c) ? ' • ' + product.ProductGroup__c : ''),
                    (prodEnq != null && String.isNotEmpty(recordId) && !recordId.equals(prodEnq.Request__c) ? prodEnq.Request__c : null),
                    (prodEnq != null && String.isNotEmpty(recordId) && !recordId.equals(prodEnq.Request__c) ? prodEnq.Request__r.CaseNumber : ''),
                    prodEnq
                );
                results.add(lookupItem);
            }
        }
        System.debug('buildLookupSearchList > result=' + results);
        return results;
    }

    private static ICX_ProductLookupSearchResult buildLookupSearch(ICX_ProductEnquired__c qualification) {
        System.debug('buildLookupSearch>qualification=' + qualification);
        ICX_ProductLookupSearchResult lookupItem = new ICX_ProductLookupSearchResult(
            (qualification != null ? qualification.Id : ''), 
            '', 
            null,
            false,
            (qualification != null && String.isBlank(qualification.Product__c) ? qualification.Product_Unknown__c : ''), 
        	(String.isNotBlank(qualification.ProductCategory__c) ? qualification.ProductCategory__c + ' • ' : '')
             	+ (String.isNotBlank(qualification.ProductGender__c) ? qualification.ProductGender__c + ' • ' : '') 
             	+ (String.isNotBlank(qualification.ProductCollection__c) ? qualification.ProductCollection__c : ''),
            //false, // (qualification != null && String.isBlank(qualification.Request__c) ? qualification.Comment__c : '') 
            (qualification != null ? qualification.Request__c : null),
            (qualification != null ? qualification.Request__r.CaseNumber : ''),
            qualification
        );
        return lookupItem;
    }

    @AuraEnabled
    public static ICX_ProductLookupSearchResult addProduct(Id productId, String recordId, Boolean isRelatedToParent/*) { */ , String comment) {
        System.debug('addProduct>productId=' + productId + ' / recordId=' + recordId + ' / isRelatedToParent=' + isRelatedToParent + ' / comment=' + comment);
        ICX_ProductEnquired__c prodEnq;

        if (!Schema.sObjectType.ICX_ProductEnquired__c.isCreateable()) {
            return null;
        }

        if (String.isNotBlank(recordId)) {// add Unknown product} && String.isNotBlank(productId)) {

            prodEnq = new ICX_ProductEnquired__c();
            prodEnq.Product__c = productId;
            prodEnq.RelatedTo__c = (isRelatedToParent ? null : recordId); // for new call
            prodEnq.ParentRelatedTo__c = (isRelatedToParent ? recordId : null); // for New Request, the record is not related to a Task but to a new Request not yet created
            prodEnq.Comment__c = (String.isNotBlank(comment) && comment.length() > 255 ? comment.substring(0, 254) : comment);//(isRelatedToParent ? null : comment);
            System.debug('comment=' + prodEnq.Comment__c);
            // for Product on demand (with or without product), set by default the store of the current user
            if (Schema.sObjectType.User.isAccessible()) {
                User usr = [SELECT id, DefaultStore__c FROM User WHERE Id = :UserInfo.getUserId()];
                if (String.isNotBlank(usr.DefaultStore__c)) {
                    prodEnq.Store__c= [SELECT id FROM Store__c WHERE RetailStoreId__c  = :usr.DefaultStore__c].id;
                }
            }

            Id recId;
            try {
                recId = Id.valueOf(recordId);
                if (String.isNotBlank(recId)) {
                    String objectType = recId.getSObjectType().getDescribe().getName();
                    prodEnq.Request__c = ('Case'.equalsIgnoreCase(objectType) ? recId : null);
                }
            } catch (Exception e) {
                System.debug('thrown standard DML exception '+e);

            }

            insert prodEnq;

            if (!isRelatedToParent) {
                updateProductField(productId, recId, 'ADD', comment);
            }
            //return buildLookupSearch(prodEnq);
        }
        return buildLookupSearch(prodEnq);
    }

    // Update the Product field for Case, Task others systems (ICON Mobile, Dream)
    // As the Case, Task were mono-product
    private static void updateProductField(Id productId, String recordId, String action, String unknownComment) {

        if (String.isNotBlank(recordId)) {

            String objectType;
            Id recId;
            try {
                recId = Id.valueOf(recordId);
                if (String.isNotBlank(recId)) {
                    objectType = recId.getSObjectType().getDescribe().getName();
                }
            } catch (Exception e) {
                System.debug('thrown standard DML exception '+e);
            }

            System.debug('objectType/recordId=' + objectType + '/' + recordId);
            if ('Case'.equalsIgnoreCase(objectType)) {
                Case cas = [SELECT Id, Product_Sku__c, Product_Sku_unknown__c FROM Case WHERE Id = :recordId];

                // for Client Request (ICON Mobile), the SKU must be set
                Id newProductId = getNewProductValue(cas.Product_Sku__c, productId, action, recordId);
                cas.Product_Sku__c = newProductId;

                String newComment = getNewUnknownValue(cas.Product_Sku_unknown__c, unknownComment, action, recordId, productId);
                cas.Product_Sku_unknown__c = newComment;

                update cas;

            } else if ('Task'.equalsIgnoreCase(objectType)) {
                Task task = [SELECT Id, Product_Sku__c, Product_Sku_unknown__c FROM Task WHERE Id = :recordId];

                // for Client Request (ICON Mobile), the SKU must be set
                Id newProductId = getNewProductValue(task.Product_Sku__c, productId, action, recordId);
                task.Product_Sku__c = newProductId;

                String newComment = getNewUnknownValue(task.Product_Sku_unknown__c, unknownComment, action, recordId, productId);
                task.Product_Sku_unknown__c = newComment;

                update task;
            }
        }
    }

    private static Id getNewProductValue(Id currentProductIdObject, Id productId, String action, Id recordId) {
        System.debug('getNewProductValue > currentProductIdObject/productId/action/recordId=' + currentProductIdObject + '/' + productId + '/' + action + '/' + recordId);

        Id productValue;
        if ('ADD'.equals(action)) {
            // update the product field if no value was set before
            if (String.isBlank(currentProductIdObject) && String.isNotBlank(productId)) {
                productValue = productId;
            } else {
                // Keep the current product
                productValue = currentProductIdObject;
            }
        } else if ('REMOVE'.equals(action)) {
            // replace the existing product field with another
            if (String.isNotBlank(productId) && productId.equals(currentProductIdObject)) {
                // get the next product of the record if existing
                List<ICX_ProductEnquired__c> prodList = [SELECT Product__c FROM ICX_ProductEnquired__c WHERE RelatedTo__c = :recordId AND (Product__c != :productId AND Product__c != '') ORDER BY CreatedDate ASC];
                productValue = (prodList.isEmpty() ? null : prodList[0].Product__c);
            } else {
                // Keep the current product
                productValue = currentProductIdObject;
            }
        }
        System.debug('getProductValue > productValue=' + productValue);
        return productValue;
    }
/*
    @AuraEnabled
    public static ICX_ProductLookupSearchResult addUnknownProduct(String comment, Id recordId) {
        System.debug('addUnknownProduct: ' + comment);
        ICX_ProductEnquired__c prodEnq;

        if (String.isNotBlank(recordId) && String.isNotBlank(comment)) {

            prodEnq = new ICX_ProductEnquired__c();
            prodEnq.Comment__c = comment;
            prodEnq.RelatedTo__c = recordId;

            String objectType = recordId.getSObjectType().getDescribe().getName();
            if ('Case'.equalsIgnoreCase(objectType)) {
                prodEnq.Request__c = recordId;
            }
            
            insert prodEnq;
            // TODO check if (!isRelatedToParent) ???
            updateProductField(null, recordId, 'ADD', comment);
        }
        return buildLookupSearch(prodEnq);
    }
*/
    /*// Used with known product
    @AuraEnabled
    public static void removeProduct(Id productId, Id recordId) {
        System.debug('removeProduct productId>' + productId + ', recordId=' + recordId);

        if (String.isNotBlank(recordId) && String.isNotBlank(productId)) {
            delete [SELECT Id FROM ICX_ProductEnquired__c WHERE RelatedTo__c = :recordId AND Product__c = :productId];
            updateProductField(productId, recordId, 'REMOVE', null);
        }
    }*/

    // Used for Unknown product
    @AuraEnabled
    public static void removeProductEnquired(Id recordId, Boolean isRelatedToParent) {
        System.debug('removeProductEnquired > recordId/isRelatedToParent=' + recordId + '/' + isRelatedToParent);

        if (String.isNotBlank(recordId)) {
            if (!isRelatedToParent) {
                List<ICX_ProductEnquired__c> prodList = [SELECT Id, Product_Unknown__c, RelatedTo__c, Product__c FROM ICX_ProductEnquired__c WHERE Id = :recordId];
                if (!prodList.isEmpty()) {
                    updateProductField(prodList[0].Product__c, prodList[0].RelatedTo__c, 'REMOVE', prodList[0].Product_Unknown__c);//Comment__c);
                    delete prodList[0];
                }
            } else {
                // For New Request, 2 ways: products to clone from Task (to not delete) or products added manually in New Request with ParentRelatedTo__c filled (to delete)
                // Delete products manually added
                delete [SELECT Id, Product_Unknown__c, RelatedTo__c FROM ICX_ProductEnquired__c WHERE Id = :recordId and ParentRelatedTo__c != null];
            }
        }
    }

    // get new comment to update Case, Task... with Product_SKU_Unknown__c field
    private static String getNewUnknownValue(String currentCommentObject, String comment, String action, Id recordId, Id productId) {
        String commentValue;
        System.debug('getNewUnknownValue > productId>' + productId + ' > comment/currentCommentObject=' + comment + '/' + currentCommentObject);
        if ('ADD'.equals(action)) {
            if (String.isNotBlank(productId)) { // No comment in Unknown Product field if an existing product is set
                commentValue = null;
            } else if (String.isBlank(currentCommentObject) && String.isNotBlank(comment)) { // update the product field if no value was set before
                commentValue = comment;
            } else {
                // Keep the current product
                commentValue = currentCommentObject;
            }
        } else if ('REMOVE'.equals(action)) {
            // replace the existing product field with another
            if (String.isNotBlank(comment) && comment.equals(currentCommentObject)) {
                // get the next unknown product of the record if existing
                //List<ICX_ProductEnquired__c> prodList = [SELECT Comment__c FROM ICX_ProductEnquired__c WHERE RelatedTo__c = :recordId AND Product__c = null AND Comment__c != :comment ORDER BY CreatedDate ASC];
                List<ICX_ProductEnquired__c> prodList = [SELECT Product_Unknown__c FROM ICX_ProductEnquired__c WHERE RelatedTo__c = :recordId AND Product__c = null AND Product_Unknown__c != :comment ORDER BY CreatedDate ASC];
                commentValue = (prodList.isEmpty() ? null : prodList[0].Product_Unknown__c);
            } else {
                // Keep the current product
                commentValue = currentCommentObject;
            }
        }
        System.debug('getNewUnknownValue > commentValue=' + commentValue);
        return commentValue;
    }

    /*@AuraEnabled
    public static void updateUnknownProduct(Id recordId, String comment) {
        System.debug('updateUnknownProduct');

        if (String.isNotBlank(recordId) && String.isNotBlank(comment)) {
            ICX_ProductEnquired__c enqProd = new ICX_ProductEnquired__c();
            enqProd.id = recordId;
            enqProd.Comment__c = comment;
            update enqProd;
        }
    }*/

    @AuraEnabled
    public static void saveAll(String productListJson) {
        System.debug('productListJson=' + productListJson);
        Type idArrType = Type.forName('List<ICX_ProductLookupSearchResult>');
        List<ICX_ProductLookupSearchResult> lookupResultList = (List<ICX_ProductLookupSearchResult>) JSON.deserialize(productListJson, idArrType);

        if (lookupResultList != null) {
            List<ICX_ProductEnquired__c> prodList = new List<ICX_ProductEnquired__c>();
            for (ICX_ProductLookupSearchResult lookupResult : lookupResultList) {
                System.debug('lookupResult=' + lookupResult);
                prodList.add(lookupResult.getQualification());
            }
            System.debug('saveAll>prodList=' + prodList);
            if (!prodList.isEmpty() && Schema.sObjectType.ICX_ProductEnquired__c.isUpdateable() && Schema.sObjectType.ICX_ProductEnquired__c.isCreateable()) {
                //update prodList;
                upsert prodList; // create if New Request or update if existing records
            }
            //update productList;
        }
    }
    
    @AuraEnabled
    public static List<Store__c> getOpenStores() {
        // get all the open stores including the RetailStoreId for Request To Store screen  (choose CA according the selected store)
        List<Store__c> searchResults = [SELECT Id, RetailStoreId__c FROM Store__c WHERE Status__c ='Open' AND StoreType__c = 'Store'];
        return searchResults;
    }
    @AuraEnabled
    public static Store__c getDCSstore() {
        //Get Distant Care Service store according User's profil and store
        Id userId = UserInfo.getUserId();
        User currentUser = [Select Profile.Name,DefaultStore__c from User where Id =:userId limit 1];
           if(currentUser.Profile.Name == 'ICONiCS_Care_Expert'){
       return [SELECT Id, RetailStoreId__c FROM Store__c WHERE RetailStoreId__c =:currentUser.DefaultStore__c limit 1];
           }else {
        return null;
       }
    }
    @AuraEnabled(cacheable=true)
    public static  Map<string, string> getAccountByEmail(Id accountId, String email){
        Account client = [select id,name, Date_Identity__pc from Account where id=:accountId limit 1];
        if(client.Date_Identity__pc == null){
            List<User> identityUsers = [SELECT id, AccountId, account.name FROM User WHERE Email =: email and Is_Identity_User__c = true and AccountId != null];
            if(!identityUsers.isEmpty())
                return new Map<string, string> {'id'=>identityUsers[0].AccountId, 'name'=> identityUsers[0].account.name};
            else
                return new Map<string, string>();//there isnt any existing MY LV user with the same email
        }
        else{
           return new Map<string, string> {'id'=>client.Id, 'name'=> client.name};
       }
    }

    @AuraEnabled(cacheable=true)
    public static String getUserZone(){
        Id userId = UserInfo.getUserId();
        User currentUser = [select MANAGEMENT_ZONE_LEVEL__c from User where id=:userId];
        String userCountry = currentUser.MANAGEMENT_ZONE_LEVEL__c;
        return userCountry;
    }
 
}