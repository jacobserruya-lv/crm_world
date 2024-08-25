global class BatchCollectionWallForClubMembers implements Database.Batchable<sObject>, Database.Stateful {
    List<Club_MemberShip__c> clubMemberShipList = new List<Club_MemberShip__c>();
    Boolean isCheckForReturnsProducts;
    Integer lastDaysNum;

    global BatchCollectionWallForClubMembers(Boolean isCheckForReturns, Integer lastDays) {
        System.debug('cons isCheckForReturns:' + isCheckForReturns);
        System.debug('cons lastDays:' + lastDays);

        isCheckForReturnsProducts = isCheckForReturns;
        lastDaysNum = lastDays;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('start isCheckForReturns:' + isCheckForReturnsProducts);
        System.debug('start lastDays:' + lastDaysNum);

        LV_Club_Setting__mdt setting = [
            SELECT
                id,
                label,
                skusProductCatalogueFiltered__c,
                skusProductReferentialsFiltered__c,
                statusClubFilteredList__c,
                clubNameFilter__c
            FROM LV_Club_Setting__mdt
            WHERE DeveloperName = 'Sneakers'
            LIMIT 1
        ];

        List<ProductReferential__c> productReferentialList = getProductReferential(
            setting.skusProductReferentialsFiltered__c.split(',')
        );

        List<ProductCatalogue__c> productCatalogList = getProductCatalog(
            setting.skusProductCatalogueFiltered__c.split(',')
        );

        clubMemberShipList = getClubMemberShip(
            lastDaysNum,
            setting.statusClubFilteredList__c.split(','),
            setting.clubNameFilter__c
        );

        Set<String> membersDreamIds = new Set<String>();
        for (Club_MemberShip__c member : clubMemberShipList) {
            membersDreamIds.add(member.dreamId__c);
        }
        
        Set<String> filteredSkus = productReferentialSkus(productReferentialList);
        filteredSkus.addAll(productCatalogSkus(productCatalogList));

        String query = 'SELECT Id, RMSSKUCode__c, Client__c, Client__r.DREAMID__c, quantity__c ' +
                       'FROM PPR_PurchProduct__c ' +
                       'WHERE Client__r.DREAMID__c IN :membersDreamIds ' +
                       'AND RMSSKUCode__c IN :filteredSkus ' +
                       'AND Client__r.DREAMID__c != Null';

        if (isCheckForReturnsProducts) {
            query += ' AND Quantity__c < 0';
        } else {
            query += ' AND Quantity__c > 0';
        }

        if (Test.isRunningTest()) {
            query += ' ORDER BY CreatedDate DESC LIMIT 1';
        } else {
            query += ' ORDER BY Client__c DESC';
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<PPR_PurchProduct__c> purchProducts){
        System.debug('purchProducts: ' + purchProducts.size());

        if (isCheckForReturnsProducts) {
            removeCollectionWallesForClubMembers(purchProducts);  
        } else {
            createCollectionWallesForClubMembers(purchProducts, clubMemberShipList);  
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Finish');
        if (!isCheckForReturnsProducts) {
            BatchCollectionWallForClubMembers cwMembers = new BatchCollectionWallForClubMembers(true, lastDaysNum);
            Database.executeBatch(cwMembers, 200);   
        }
    }

    private static void createCollectionWallesForClubMembers(
        List<PPR_PurchProduct__c> newTransactionList,
        List<Club_MemberShip__c> clubMemberShipList
    ) {
        System.debug('createCollectionWallesForClubMembers: ' + newTransactionList.size());

        System.debug('createCollectionWallesForClubMembers: ' + clubMemberShipList);
        Set<String> skuList = new Set<String>();
        Set<Id> clientIdList = new Set<Id>();

        for (PPR_PurchProduct__c pprp : newTransactionList) {            
            skuList.add(pprp.RMSSKUCode__c);
            clientIdList.add(pprp.Client__c);
        }
    
        Map<Id, Id> clubMemberIdByClientId = new Map<Id, Id>();
        for (Club_MemberShip__c member : clubMemberShipList) {
            clubMemberIdByClientId.put(member.clientId__c, member.Id);
        }

        List<Club_Collection_Wall__c> ccwListToCreate = new List<Club_Collection_Wall__c>();
    
        for (PPR_PurchProduct__c pprp : newTransactionList) {
            Id clubMemberId = clubMemberIdByClientId.get(pprp.Client__c);

            if (clubMemberId != null) {
              Club_Collection_Wall__c ccw = new Club_Collection_Wall__c();
              ccw.clubMemberId__c = clubMemberId;
              ccw.Collection_Wall_Sku__c = pprp.id;
              ccw.uniqueKey__c = pprp.Client__r.DREAMID__c + '_' + pprp.Id;
              ccwListToCreate.add(ccw);
            } 
        }
    
        System.debug('ccwListToCreate: ' + ccwListToCreate);
        if (!ccwListToCreate.isEmpty()) {
            Database.insert(ccwListToCreate, false);
        }
    }    

    private static void removeCollectionWallesForClubMembers(List<PPR_PurchProduct__c> newTransactionList) {
        System.debug('removeCollectionWallesForClubMembers: ' + newTransactionList.size());
        Set<String> skuList = new Set<String>();
        Set<Id> clientIdList = new Set<Id>();

        for (PPR_PurchProduct__c pprp : newTransactionList) {            
            skuList.add(pprp.RMSSKUCode__c);
            clientIdList.add(pprp.Client__c);
        }

        List<Club_Collection_Wall__c> existCWs = [
            SELECT Id, Collection_Wall_Sku__r.RMSSKUCode__c, Collection_Wall_Sku__r.PurchaseDateTime__c, clubMemberId__r.clientId__c
            FROM Club_Collection_Wall__c
            WHERE Collection_Wall_Sku__r.RMSSKUCode__c IN :skuList
            AND clubMemberId__r.clientId__c IN :clientIdList
            ORDER BY Collection_Wall_Sku__r.PurchaseDateTime__c
            DESC
        ];
    
        Map<String, List<Club_Collection_Wall__c>> cwBySku = new Map<String, List<Club_Collection_Wall__c>>();
        for (Club_Collection_Wall__c cw : existCWs) {
            String uniqueKey = cw.Collection_Wall_Sku__r.RMSSKUCode__c + cw.clubMemberId__r.clientId__c;
            List<Club_Collection_Wall__c> wallesPerClientAndSku = new List<Club_Collection_Wall__c>();
            
            if (cwBySku.containsKey(uniqueKey)) {
                wallesPerClientAndSku = cwBySku.get(uniqueKey);
            }

            wallesPerClientAndSku.add(cw);
            cwBySku.put(uniqueKey, wallesPerClientAndSku);
        }

        List<Club_Collection_Wall__c> ccwListToDelete = new List<Club_Collection_Wall__c>();

        for (PPR_PurchProduct__c pprp : newTransactionList) {
            String uniqueKey = pprp.RMSSKUCode__c + pprp.Client__c;

            if (cwBySku.containsKey(uniqueKey) && cwBySku.get(uniqueKey).size() > 0) {
                ccwListToDelete.add(cwBySku.get(uniqueKey)[0]);
                cwBySku.get(uniqueKey).remove(0);
            }
        }
        
        System.debug('ccwListToDelete: ' + ccwListToDelete);
        if (!ccwListToDelete.isEmpty()) {
            Map<Id, Club_Collection_Wall__c> ccwMapToDelete = new Map<Id, Club_Collection_Wall__c>();
            ccwMapToDelete.putAll(ccwListToDelete);
            Database.delete(ccwMapToDelete.values(), false);
        }
    } 

    private static List<ProductReferential__c> getProductReferential(
        String[] nameFilteredList
    ) {
        return [
        SELECT Id, SKUCode__c
        FROM ProductReferential__c
        WHERE
            Activity__c = 'SHOES'
            AND Family__c = 'SNEAKER'
            AND Name LIKE :nameFilteredList
        ];
    }

    private static List<ProductCatalogue__c> getProductCatalog(
        String[] skuFilteredList
    ) {
        return [
            SELECT Id, SKU__c
            FROM ProductCatalogue__c
            WHERE longSkuId__c LIKE :skuFilteredList
        ];
    }

    private static List<Club_MemberShip__c> getClubMemberShip(
        Integer lastDaysNum,
        String[] statusFilteredList,
        String clubName
    ) {
        return Database.query(
            'SELECT id, dreamId__c, clientId__c ' +
            'FROM Club_MemberShip__c ' +
            'WHERE CreatedDate = LAST_N_DAYS:' + lastDaysNum + ' ' +   
            'AND Club_and_Seasons__r.Name = :clubName ' +
            'AND clubStatus__c NOT IN :statusFilteredList '
        );
    }

    private static Set<String> productCatalogSkus(
        List<ProductCatalogue__c> productCatalogList
    ) {
        Set<String> skus = new Set<String>();
        for (ProductCatalogue__c pc : productCatalogList) {
            skus.add(pc.SKU__c);
        }
        return skus;
    }

    private static Set<String> productReferentialSkus(
        List<ProductReferential__c> productReferentialList
    ) {
        Set<String> skus = new Set<String>();
        for (ProductReferential__c pr : productReferentialList) {
            skus.add(pr.SKUCode__c);
        }
        return skus;
    }
}