public with sharing class CT_CSVParseController {
    public class CustomException extends Exception {}

    @AuraEnabled
    public static String readCSVFile(Id idContentDocument) {
        String result;
        if (idContentDocument != null) {
            // getting File Data based on document id 
            List<ContentVersion> objVersionList = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];

            if (objVersionList.size() > 0) {
                ContentVersion objVersion = objVersionList[0];
                result = objVersion.VersionData.toString();
            }
        }

        return result;   
    }
    
    @AuraEnabled
    public static List<String> getEmptyOwnersIds(string zoneType, String zone, List<String> caIdsList) {
        List<String> ownersIds = new List<String>();
        String zoneParameter;
        String baseQuery = 'SELECT Id FROM User WHERE IsActive = TRUE AND Id NOT IN :caIdsList';
    
        if (String.isNotBlank(zoneType)) {
            switch on zoneType {
                when 'store'{
                  zoneParameter = 'DefaultStore__c';
                }
                when 'level3' {
                  zoneParameter = 'MGMT_ZONE_SUB_LEVEL3__c';
                }
                when 'level2' {
                  zoneParameter = 'MGMT_ZONE_SUB_LEVEL2__c';
                }
                when 'level1' {
                  zoneParameter = 'MGMT_ZONE_SUB_LEVEL1__c';
                }
                when 'level' {
                  zoneParameter = 'MANAGEMENT_ZONE_LEVEL__c';
                }
            }

            baseQuery += ' AND ' + zoneParameter + ' = :zone ';
        }

        List<User> caList = Database.query(baseQuery);
        System.debug('caList.size(): ' + caList.size());
        for (User u : caList) {
            ownersIds.add(u.Id);
        }

        return ownersIds;
    }
    
    @AuraEnabled
    public static Id createReassignCL(List<String> clientIdsList, String caId) {
        try {
            List<Account> accList = [SELECT PersonContactId, OwnerId FROM Account WHERE Id in :clientIdsList];
            
            if (accList.size() == 0) {
                throw new CustomException('There was a problem finding the clients');
            } else {
                List<String> contactIdsList = new List<String>();
                for (Account acc : accList) {
                    acc.OwnerId = caId;
                    contactIdsList.add(acc.PersonContactId);
                }
                
                CT_UpdateClientsQueue updateClientsQueue = new CT_UpdateClientsQueue(accList);
                Id jobId = System.enqueueJob(updateClientsQueue);

                String name = 'Reattach Clients-' + caId + '-' + System.now().format();
                CLI_CliList__c reattachCl = new CLI_CliList__c(
                    Name = name,
                    Active__c = true,
                    ExpirationDate__c = date.today().addYears(1),
                    Description__c = name,
                    Is_visible_by_CA__c = false,
                    Show_In_Icon__c = false,
                    Type__c = 'Reassign',
                    TECH_IsReassignedClients__c = true,
                    OwnerId = caId,
                    IsMasterClientList__c = false
                );
        
                List<CLI_CliList__c> clForBatch = new List<CLI_CliList__c>{reattachCl};
                Map<Id, List<Id>> contactByCa = new Map<Id, List<Id>> {
                    caId => contactIdsList
                };
                CT_CreateClientListBatch CLBatch = new CT_CreateClientListBatch(clForBatch, contactByCa);
                Database.executeBatch(CLBatch);

                return jobId;
            }
        } catch(Exception e) {
            System.debug(e);
            throw e;
        }
    }
    
    @AuraEnabled
    public static Id createCLwithMembers(
        string name,
        Date expirationDate,
        string description,
        List<String> dreamIdsList,
        List<String> caListFilter,
        String otherParams
    ) {
        Id jobId;
        String message;

        try {
            List<CLI_CliList__c> clsToCreate = new List<CLI_CliList__c>();
            Map<Id, List<Id>> membersByCaId = new Map<Id, List<Id>>();

            Map<String, String> parseParams = (Map<String, String>) JSON.deserialize(otherParams, Map<String, String>.class);
            string type = parseParams.get('type');
            Boolean shouldCLBeVisibleToCa = type == 'exclusive' ? false : true;
            Boolean showInIcon = parseParams.get('showInIcon') == 'true' ? true : false;
            string topology = parseParams.get('topology');
            string offerCode = parseParams.get('offerCode');
            string zoneType = parseParams.get('zoneType');
            string zone = parseParams.get('zone');
            Boolean createEmpty = parseParams.get('createEmpty') == 'true' ? true : false;
            List<String> phoneCountries = parseParams.containsKey('phoneCountries') ? ((String) parseParams.get('phoneCountries')).split(',') : new List<String>();
            String regularQuery = 'SELECT Id,OwnerId FROM Contact WHERE Account.DREAMID__c in :dreamIdsList';
            String exlusiveQuery = regularQuery + ' AND ((Email != NULL AND PrimaryCountry__c NOT IN :phoneCountries)' + 
                                                  ' OR (PrimaryCountry__c IN :phoneCountries AND (Account.PersonMobilePhone != NULL)))';
            String contactQuery = parseParams.get('contactableClients') == 'true' ? exlusiveQuery : RegularQuery;
            List<Contact> conList = Database.query(contactQuery);
            
            System.debug('conList: ' + conList);
            
            if (type == 'exclusive' && conList.size() == 0) {
                throw new CustomException('Failed to create Exclusive client list, no contactable clients found!');
            } else {
                Map<String, List<String>> caMap = new Map<String, List<String>>();
                for (Contact c : conList) {
                    List<String> conGroup = new List<String>();
                    if (caMap.containsKey(c.OwnerId)) {
                        conGroup = caMap.get(c.OwnerId);
                        caMap.remove(c.OwnerId);
                    }
                    conGroup.add(c.Id);
                    caMap.put(c.OwnerId, conGroup);
                }

                List<String> caIdsList = new List<String>(caMap.keySet());

                if (createEmpty) {
                    List<String> emptyOwners = caListFilter.size() > 0 ? caListFilter : getEmptyOwnersIds(zoneType, zone, caIdsList);
                    if (emptyOwners != null && emptyOwners.size() > 0) {
                        caIdsList.addAll(emptyOwners);
                    }
                }
                    
                Id masterClId = getMasterClId(
                    name,
                    expirationDate,
                    description,
                    shouldCLBeVisibleToCa,
                    topology,
                    type,
                    offerCode,
                    showInIcon
                );

                System.debug('caIdsList: ' + caIdsList);
                for (ID ca : caIdsList) {
                    List<String> idList = caMap.get(ca) != null ? caMap.get(ca) : new List<String>();
                    membersByCaId.put(ca, idList);
                    
                    CLI_CliList__c clToReturn = new CLI_CliList__c(
                        Name = name,
                        Active__c = true,
                        ExpirationDate__c = expirationDate,
                        Description__c = description,
                        Is_visible_by_CA__c = shouldCLBeVisibleToCa,
                        Typology__c = topology,
                        Type__c = type,
                        Offer_Code__c = offerCode,
                        Show_In_Icon__c = showInIcon,
                        TECH_LaunchAddMembersBatch__c = false,
                        TECH_CreatedFromTCLScreen__c = true,
                        OwnerId = ca,
                        IsMasterClientList__c = false,
                        Master_Client_List__c = masterClId
                    );         
                    clsToCreate.add(clToReturn);  
                }    
    
                CT_CreateClientListBatch CLBatch = new CT_CreateClientListBatch(clsToCreate, membersByCaId);
                jobId = Database.executeBatch(CLBatch, 200);
                return jobId;
            }
        } catch(Exception e) {
            System.debug('Failed to create Client List: ' + e);
            throw e;
        }
    }

    private static Id getMasterClId(
        String name,
        Date expirationDate,
        String description,
        Boolean shouldCLBeVisibleToCa,
        String topology,
        String type,
        String offerCode,
        Boolean showInIcon
    ) {
        if (type == 'exclusive') {
            System.debug('Looking for an exisiting MasterClientList');
            List<CLI_CliList__c> existMasterCl = [SELECT Id FROM CLI_CliList__c WHERE Typology__c = :topology AND Offer_Code__c = :offerCode AND ExpirationDate__c = :expirationDate AND IsMasterClientList__c = TRUE LIMIT 1];
            if (existMasterCl.size() > 0) {
                System.debug('Exist MasterClientList found: ' + existMasterCl[0]);
                return existMasterCl[0].Id;
            }
        } 

        CLI_CliList__c masterClientList = new CLI_CliList__c(
            Name = name,
            Active__c = true,
            ExpirationDate__c = expirationDate,
            Description__c = description,
            Is_visible_by_CA__c = shouldCLBeVisibleToCa,
            Typology__c = topology,
            Type__c = type,
            Offer_Code__c = offerCode,
            Show_In_Icon__c = showInIcon,
            TECH_LaunchAddMembersBatch__c = false,
            TECH_CreatedFromTCLScreen__c = true,
            IsMasterClientList__c = true
        ); 
        System.debug('A new MasterClientList created');
        insert masterClientList;
        return masterClientList.Id;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isAllFromOneStore(list<String> dreamIds) {
        String storeId;   
        String caStore;
        Boolean isAllFromOneStore = true;
        List<Account> allClientsStores = [SELECT Store__pr.Id, Owner.DefaultStore__c FROM Account WHERE DREAMID__c IN :dreamIds AND Store__pr.Id != null LIMIT 1];

        if (allClientsStores.size() == 0) {
            allClientsStores = [SELECT Store__pr.Id, Owner.DefaultStore__c FROM Account WHERE DREAMID__c IN :dreamIds AND Owner.DefaultStore__c != null LIMIT 1];
        }

        if (allClientsStores.size() > 0) {
            storeId = allClientsStores[0].Store__pr.Id;
            caStore = allClientsStores[0].Owner.DefaultStore__c;
            Integer countOfStores = 0;

            if (storeId != null && storeId != '') {
                countOfStores = [SELECT COUNT() FROM Account WHERE DREAMID__c IN :dreamIds AND Store__pr.Id != :storeId AND Store__pr.Id != null];
                if (countOfStores > 0) {
                    List<Account> nullsList = [SELECT Id ,Name ,Store__pr.Id FROM Account WHERE DREAMID__c IN :dreamIds AND Store__pr.Id != :storeId AND Store__pr.Id != null];
                }
                
            } else {
                countOfStores = [SELECT COUNT() FROM Account WHERE DREAMID__c IN :dreamIds AND Store__pr.RetailStoreId__c != :caStore AND Store__pr.RetailStoreId__c != null];
            }

            if (countOfStores > 0) {
                isAllFromOneStore = false;
            }
        }

        return isAllFromOneStore;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isAllClientsWithStore(list<String> dreamIds) {
        Integer clientsCount = [SELECT COUNT() FROM Account WHERE DREAMID__c IN :dreamIds AND Store__pr.Id = null AND Owner.DefaultStore__c = null LIMIT 1];
        if (clientsCount > 0) {
            return false;
        } else {
            return true;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getClientsMissingStore(list<String> dreamIds) {
        return [
            SELECT Id, DREAMID__c
            FROM Account
            WHERE DREAMID__c IN :dreamIds 
                AND Store__pr.Id = null
                AND Owner.DefaultStore__c = null
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<CT_ProductCategories__c> getProductCategoriesList() {
        return [SELECT Name, API_Name__c FROM CT_ProductCategories__c WHERE Active__c = TRUE];
    }
}