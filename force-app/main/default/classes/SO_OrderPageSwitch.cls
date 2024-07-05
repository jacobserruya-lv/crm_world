/*
 * class SO_OrderPageSwitch
 */
global with sharing class SO_OrderPageSwitch {

    public Enum LogicalUserRoleEnum { Store, Production, Other }
    public Enum StepEnum { NextStep, EndStep }

    public static final String CREATION_IN_PROGRESS     = 'Creation in progress';
    public static final String PRODUCTION_IN_PROGRESS   = 'Production in progress';
    public static final String DISTRIBUTION_IN_PROGRESS = 'Distribution in progress';

    public static Set<String> stageWithoutOrder;
    public static Set<String> stageForOrder;

    public static Set<String> productionProfileNameSet;
    public static Set<String> storeProfileNameSet;
    public static Set<String> otherProfileNameSet;

    public static Set<String> statusPartTwo;
    public static Set<String> subStatusOne;
    public static Set<String> subStatusTwo;
    public static Set<String> subStatusThree;

    public static Map<String, Integer> firmOrderStatusForSort;
    public static Map<LogicalUserRoleEnum, String> stageOtherwise;
    public static Map<LogicalUserRoleEnum, String> stageAndOrderToPage;
    public static Map<LogicalUserRoleEnum, Map<String,String>>  stageToPage;
    public static Set<String> storeOtherStagesOfMakesReadOnly;
    public static Set<String> productionStagesOfMakesReadOnly;

    public static Set<String>           storePermissionSet;
    public static Map<String, String>   otherPermissionSetToCategory;
    public static Map<String, String>   productionPermissionSetToCategory;

    static {
        stageWithoutOrder = new Set<String>{ 
             'Brief in progress'              
            ,'Quotation in progress'            
            ,'Quotation submitted'           
            ,'Quotation rejected'        
            ,'Quotation accepted'      
            ,'Deposit sent'      
        };

        stageForOrder = new Set<String>{
             'Creation in progress'       
            ,'In progress'
            ,'Closed Won'
        };

        //profileNameSet = new Set<String> {
        //    'ICON_SA'
        //   ,'ICON_SA Animator'
        //   ,'ICON_SA Manager'
        //};

        productionProfileNameSet = new Set<String> {
            'SPO_Production'
        };

        storeProfileNameSet = new Set<String> {
            'ICON_SA'
        };

        otherProfileNameSet = new Set<String> {
            'SPO_Other'
        };

        statusPartTwo = new Set<String> {
             'Received in Store'
            ,'Sent to RMS'
            ,'Payment confirmed'
        };

        subStatusOne = new Set<String> {
            'Codification'
           ,'Technical data'
        };

        subStatusTwo = new Set<String> {
            'Quality control'
        };

        subStatusThree = new Set<String> {
            'Sent to central WH'
           ,'Sent to regional WH'
           ,'Sent to store' 
        };

        firmOrderStatusForSort = new Map<String, Integer> {
            'Payment confirmed'        => 0
            ,'Sent to RMS'              => 1
            ,'Received in store'        => 2
            ,'Distribution in progress' => 3
            ,'Production in progress'   => 4
            ,'Creation in progress'     => 5
            ,'Cancelled by production'  => 6
            ,'Cancelled by store'       => 7
            ,'Cancelled - Migrated in Xstore' => 8
            ,'Closed'                   => 9
        };

        stageOtherwise = new Map<LogicalUserRoleEnum, String> {

            LogicalUserRoleEnum.Store       => '/apex/SO_BriefOrder'//'/apex/SO_brieforder_store?tab=view6'
           ,LogicalUserRoleEnum.Production  => '/apex/SO_BriefOrder'
           ,LogicalUserRoleEnum.Other       => '/apex/SO_BriefOrder'//''
        };

        stageAndOrderToPage = new Map<LogicalUserRoleEnum, String> {

            LogicalUserRoleEnum.Store       => '/apex/SO_BriefOrder'//'/apex/SO_brieforder_store?tab=view6'
           ,LogicalUserRoleEnum.Production  => '/apex/SO_BriefOrder'//'/apex/SO_AsniereProduction'
           ,LogicalUserRoleEnum.Other       => '/apex/SO_BriefOrder'//''
        };

        storeOtherStagesOfMakesReadOnly = new Set<String>{
                                            'Quotation accepted',
                                            'Deposit sent',
                                            'Quotation in progress',
                                            'Quotation submitted',
                                            'Creation in progress',
                                            'In progress',
                                            'Payment confirmed',
                                            'Closed Won',
                                            'Cancelled by store',
                                            'Cancelled by Production',
                                            'Cancelled - Migrated in Xstore'};

        productionStagesOfMakesReadOnly = new Set<String>{
                                            'In progress',
                                            'Payment confirmed',
                                            'Closed Won',
                                            'Cancelled by store',
                                            'Cancelled by Production',
                                            'Cancelled - Migrated in Xstore'};

        //Brief in progress
        //Quotation in progress
        //Quotation submitted
        //Quotation rejected
        //Quotation accepted
        //Deposit sent
        //Creation in progress
        //In progress Open
        //Payment confirmed
        //Closed Won
        //Cancelled by store
        //Cancelled by Production

        stageToPage  = new Map<LogicalUserRoleEnum, Map<String,String>> {
            //Old mapping:
            //LogicalUserRoleEnum.Store => new Map<String,String> {
            //     'Brief in progress'      => '/apex/SO_brieforder_store'
            //    ,'Quotation in progress'  => '/apex/SO_QuotationRequested'
            //    ,'Quotation submitted'    => '/apex/SO_brieforder_store?tab=view3'
            //    ,'Quotation rejected'     => '/apex/SO_brieforder_store?tab=view4'
            //    ,'Quotation accepted'     => '/apex/SO_brieforder_store?tab=view5'
            //    ,'Deposit sent'           => '/apex/SO_brieforder_store?tab=view6'
            //},

            LogicalUserRoleEnum.Store => new Map<String,String> {
                 'Brief in progress'        => '/apex/SO_BriefOrder'
                ,'Quotation in progress'    => '/apex/SO_BriefOrder'
                ,'Quotation submitted'      => '/apex/SO_BriefOrder'
                ,'Quotation rejected'       => '/apex/SO_BriefOrder'
                ,'Quotation accepted'       => '/apex/SO_BriefOrder'
                ,'Deposit sent'             => '/apex/SO_BriefOrder'
                ,'Creation in progress'     => '/apex/SO_BriefOrder'      
                ,'In progress'              => '/apex/SO_BriefOrder' 
                ,'Payment confirmed'        => '/apex/SO_BriefOrder' 
                ,'Closed Won'               => '/apex/SO_BriefOrder' 
                ,'Cancelled by store'       => '/apex/SO_BriefOrder' 
                ,'Cancelled by Production'  => '/apex/SO_BriefOrder'
                , 'Cancelled - Migrated in Xstore' => '/apex/SO_BriefOrder'
            },

            //TODO change mapping after follow-up-production is done:
            
            LogicalUserRoleEnum.Production => new Map<String,String> {
                 'Brief in progress'        => '/apex/SO_BriefOrder'
                ,'Quotation in progress'    => '/apex/SO_BriefOrder'
                ,'Quotation submitted'      => '/apex/SO_BriefOrder'
                ,'Quotation rejected'       => '/apex/SO_BriefOrder'
                ,'Quotation accepted'       => '/apex/SO_BriefOrder'
                ,'Deposit sent'             => '/apex/SO_BriefOrder'
                ,'Creation in progress'     => '/apex/SO_BriefOrder'      
                ,'In progress'              => '/apex/SO_BriefOrder' 
                ,'Payment confirmed'        => '/apex/SO_BriefOrder' 
                ,'Closed Won'               => '/apex/SO_BriefOrder' 
                ,'Cancelled by store'       => '/apex/SO_BriefOrder' 
                ,'Cancelled by Production'  => '/apex/SO_BriefOrder'
                ,'Cancelled - Migrated in Xstore' => '/apex/SO_BriefOrder'
            },

            //OLD mapping:
            //LogicalUserRoleEnum.Production => new Map<String,String> {
            //     'Brief in progress'        => '/apex/SO_brieforder_store'
            //    ,'Quotation in progress'    => '/apex/SO_AsniereQuotation'
            //    ,'Quotation submitted'      => '/apex/SO_AsniereQuotation'
            //    ,'Quotation rejected'       => '/apex/SO_AsniereQuotation?tab=deny'
            //    ,'Quotation accepted'       => '/apex/SO_AsniereProduction'
            //    ,'Deposit sent'             => '/apex/SO_AsniereProduction'
            //    ,'Creation in progress'     => '/apex/SO_BriefOrder'      
            //    ,'In progress'              => '/apex/SO_BriefOrder' 
            //    ,'Payment confirmed'        => '/apex/SO_BriefOrder' 
            //    ,'Closed Won'               => '/apex/SO_BriefOrder' 
            //    ,'Cancelled by store'       => '/apex/SO_BriefOrder' 
            //    ,'Cancelled by Production'  => '/apex/SO_BriefOrder' 
            //},
            //todo: read only except all translation "comment" field + 3 checkbox validation
            //LogicalUserRoleEnum.Other => new Map<String,String> { 
            //     'Brief in progress'      => '/apex/SO_brieforder_store'
            //    ,'Quotation in progress'  => '/apex/SO_QuotationRequested'
            //    ,'Quotation submitted'    => '/apex/SO_brieforder_store?tab=view3'
            //    ,'Quotation rejected'     => '/apex/SO_brieforder_store?tab=view4'
            //    ,'Quotation accepted'     => '/apex/SO_brieforder_store?tab=view5'
            //    ,'Deposit sent'           => '/apex/SO_brieforder_store?tab=view6'
            //}
            
            LogicalUserRoleEnum.Other => new Map<String,String> { 
                 'Brief in progress'        => '/apex/SO_BriefOrder'
                ,'Quotation in progress'    => '/apex/SO_BriefOrder'
                ,'Quotation submitted'      => '/apex/SO_BriefOrder'
                ,'Quotation rejected'       => '/apex/SO_BriefOrder'
                ,'Quotation accepted'       => '/apex/SO_BriefOrder'
                ,'Deposit sent'             => '/apex/SO_BriefOrder'
                ,'Creation in progress'     => '/apex/SO_BriefOrder'      
                ,'In progress'              => '/apex/SO_BriefOrder' 
                ,'Payment confirmed'        => '/apex/SO_BriefOrder' 
                ,'Closed Won'               => '/apex/SO_BriefOrder' 
                ,'Cancelled by store'       => '/apex/SO_BriefOrder' 
                ,'Cancelled by Production'  => '/apex/SO_BriefOrder'
                ,'Cancelled - Migrated in Xstore' => '/apex/SO_BriefOrder'             
            }
        };

        productionPermissionSetToCategory = new Map<String, String> {
            'SPO_ProductionAccessory'   => SO_PicklistDependency.OPP_ACCESSORY
            , 'SPO_ProductionLG'        => SO_PicklistDependency.OPP_LEATHER_GOOD
            , 'SPO_ProductionWatch'     => SO_PicklistDependency.OPP_WATCH
        };

        storePermissionSet = new Set<String> {
            'SPO_Store'
        };

        otherPermissionSetToCategory = new Map<String, String> {
            //'SPO_Other'
          'SPO_OtherAcc'     => SO_PicklistDependency.OPP_ACCESSORY
         ,'SPO_OtherLG'      => SO_PicklistDependency.OPP_LEATHER_GOOD
         ,'SPO_OtherWatch'   => SO_PicklistDependency.OPP_WATCH
        };
    }
    
    public SO_OrderPageSwitch() {
    }


    public static Boolean isWithoutQuotation()
    {
        Opportunity opp = SO_Session.theCurrentBrief;
        return opp.SPO_ProductCategory__c == SO_PicklistDependency.OPP_LEATHER_GOOD 
                && opp.SPO_OrderType__c == SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG;
    }

    public static Boolean isReadonlyMode()
    {
        Boolean ans = null;
        Opportunity opp = SO_Session.theCurrentBrief;
        if (opp != null)
        {
            ans = false;
            SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
            SO_OrderPageSwitch.LogicalUserRoleEnum role = orderPageSwitch.sfoUserRoleByObject(opp); 
            String roleName = role.name();    // can be one of: [Store, Production, Other]
            if ( ( (roleName == 'Store' || roleName == 'Other') && storeOtherStagesOfMakesReadOnly.contains(opp.StageName))
                || ( roleName == 'Production' && productionStagesOfMakesReadOnly.contains(opp.StageName) ) )
            {
                //LogicalUserRoleEnum role = sfoUserRoleByObject(opp); 
                //role = role.name();    // can be one of: [Store, Production, Other]
                ans = true;
            }
        }

        return ans;

        //Opportunity opp = SO_Session.theCurrentBrief;
        //if (opp != null){
        //   if ( stagesOfMakesReadOnly.contains(opp.StageName) ){
        //        SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
        //        SO_OrderPageSwitch.LogicalUserRoleEnum role = orderPageSwitch.sfoUserRoleByObject(opp); 
        //        String roleName = role.name();    // can be one of: [Store, Production, Other]

        //        //LogicalUserRoleEnum role = sfoUserRoleByObject(opp); 
        //        //role = role.name();    // can be one of: [Store, Production, Other]
        //        if (roleName=='Store'||roleName=='Other'){
        //            return true;
        //        }else{
        //            return false;
        //        }
        //    }else{
        //        return false;
        //    } 
        //}else{
        //    return null;
        //}
        
    }

    public User currentUser   { 
        get {
            if(null == currentUser) {
                currentUser = retCurrentUser();
            }
            return currentUser;
        } 
        private set; 
    }

    public SPO_FirmOrder__c actualOrder { get; private set; }

    public LogicalUserRoleEnum sfoUserRole { 

        get {
            if(null == sfoUserRole) {
                /*
                if(currentUser.SPO_Production__c) {
                    sfoUserRole = LogicalUserRoleEnum.Production;
                }*/
                //If in Production Profile OR In Production PermissionSet then Production
                if(userIdByRoleTypeMap.get(LogicalUserRoleEnum.Production).contains(currentUser.Id) ||
                        productionProfileNameSet.contains(currentUser.Profile.Name)) {
                    sfoUserRole = LogicalUserRoleEnum.Production;
                }
                //If in Store Profile OR In Store PermissionSet then Production
                else if(userIdByRoleTypeMap.get(LogicalUserRoleEnum.Store).contains(currentUser.Id) || 
                        storeProfileNameSet.contains(currentUser.Profile.Name)) {
                    sfoUserRole = LogicalUserRoleEnum.Store;
                }
                //If in Other Profile OR In Other PermissionSet then Production
                else if(userIdByRoleTypeMap.get(LogicalUserRoleEnum.Other).contains(currentUser.Id) ||
                        otherProfileNameSet.contains(currentUser.Profile.Name)){
                    sfoUserRole = LogicalUserRoleEnum.Other;    
                }
            }
            return sfoUserRole;
        } 
        private set; 
    }

    public LogicalUserRoleEnum sfoUserRoleByObject(SObject obj) {

        if(LogicalUserRoleEnum.Other == sfoUserRole && (ID)obj.get('OwnerId') == UserInfo.getUserId()) {
            return LogicalUserRoleEnum.Store;
        }
        return sfoUserRole;
    } 

    public String sfoUserRoleName {
        get { 
            return sfoUserRole.name(); 
        }
    }

    public Map<ID,String> opportunityToPageLinkMap { 
        get {
            if(null == opportunityToPageLinkMap) {
                opportunityToPageLinkMap = new Map<ID,String>();
            }
            return opportunityToPageLinkMap;
        } 
        set; 
    }

    public Map<ID, String> buildTargetPageMap(List<Opportunity> targetList) {

        Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>(targetList);

        List<SPO_FirmOrder__c> firmOrderList = retOrderByOpp(oppMap.keySet());
        Map<ID, List<SPO_FirmOrder__c>> oppToOrderMap = new Map<ID, List<SPO_FirmOrder__c>>();

        for(SPO_FirmOrder__c oneOrder : firmOrderList) {

            List<SPO_FirmOrder__c> orderList = oppToOrderMap.get(oneOrder.SPO_BriefName__c);
            if(null == orderList) {
                orderList = new List<SPO_FirmOrder__c>();
            }
            orderList.add(oneOrder);
            oppToOrderMap.put(oneOrder.SPO_BriefName__c,orderList);
        }

        //System.debug('oppToOrderMap >> ' + oppToOrderMap);
        
        for(ID oppID : oppMap.keySet()) {

            Opportunity target = oppMap.get(oppID);
            //System.debug('1 >> Id >> ' + target.Id + ' target.StageName >> ' + target.StageName);
            if(stageForOrder.contains(target.StageName)) {
                //System.debug('>> 2');
                List<SPO_FirmOrder__c> oneOrderList = oppToOrderMap.get(oppID);
                
                if(SO_UTIL.isNotEmpty(oneOrderList)) {
                    //System.debug('>> 3');
                    actualOrder = retActualOrder(oneOrderList);
                    if(StepEnum.EndStep == isValid(actualOrder)) {
                        opportunityToPageLinkMap.put(oppID, stageAndOrderToPage.get(sfoUserRole));
                    }
                }
            }
            else if(stageWithoutOrder.contains(target.StageName)) {
                //System.debug('sfoUserRole >> ' + sfoUserRole);
                //System.debug('2 >> target.StageName >> ' + target.StageName);
                //System.debug('stageToPage.get(sfoUserRole) >> ' + stageToPage.get(sfoUserRole));

                String resultPageLink = stageToPage.get(sfoUserRole).get(target.StageName);
                //System.debug('>> 4.1 resultPageLink = ' + stageToPage.get(sfoUserRole));
                opportunityToPageLinkMap.put(oppID, resultPageLink);
            }
            
            if(!opportunityToPageLinkMap.containsKey(oppID))
            {
                //System.debug('>> 5');
                opportunityToPageLinkMap.put(oppID, stageOtherwise.get(sfoUserRole));   
            }
            
            
        }
        //System.debug('opportunityToPageLinkMap >> ' + opportunityToPageLinkMap);
        return opportunityToPageLinkMap;
    }

    public static SPO_FirmOrder__c retActualOrder(List<SPO_FirmOrder__c> firmOrderList) {

        List<SortedFirmOrder> sortedFirmOrderList = new List<SortedFirmOrder>();

        for(SPO_FirmOrder__c oneFirmOrder : firmOrderList) {
            sortedFirmOrderList.add(new SortedFirmOrder(oneFirmOrder));
        }

        sortedFirmOrderList.sort();

        return sortedFirmOrderList[0].target;
    }

    private static StepEnum isValid(SPO_FirmOrder__c order) {

        StepEnum resultStep;
        if(CREATION_IN_PROGRESS.equalsIgnoreCase(order.SPO_FirmOrderStatus__c)) {

            if(subStatusOne.contains(order.SPO_Substatus__c)) {
                resultStep = StepEnum.EndStep;
            }
        }
        else if(PRODUCTION_IN_PROGRESS.equalsIgnoreCase(order.SPO_FirmOrderStatus__c)) {

            if(subStatusTwo.contains(order.SPO_Substatus__c)) {
                resultStep = StepEnum.EndStep;
            }
        }
        else if(DISTRIBUTION_IN_PROGRESS.equalsIgnoreCase(order.SPO_FirmOrderStatus__c)) {

            if(subStatusThree.contains(order.SPO_Substatus__c)) {
                resultStep = StepEnum.EndStep;
            }
        }
        else if(statusPartTwo.contains(order.SPO_FirmOrderStatus__c)) {
            resultStep = StepEnum.EndStep;
        }

        return resultStep;
    }

    public static Map<ID, Set<String>> permissionByUserMap {

        get {
            if(null == permissionByUserMap) {
                permissionByUserMap = retPermissionByUserMap();
            }
            return permissionByUserMap;
        }

        private set;

    }

    public static Map<LogicalUserRoleEnum, Set<String>> userIdByRoleTypeMap {

        get {
            if(null == userIdByRoleTypeMap) {
                userIdByRoleTypeMap = retUserIdByRoleTypeMap();
            }
            return userIdByRoleTypeMap;
        }

        private set;

    }

    public static Map<LogicalUserRoleEnum, Set<String>> retUserIdByRoleTypeMap() {

        Map<LogicalUserRoleEnum, Set<String>> permissionMap = new Map<LogicalUserRoleEnum, Set<String>>
        {
            LogicalUserRoleEnum.Production => new Set<String>(),
            LogicalUserRoleEnum.Store => new Set<String>(),
            LogicalUserRoleEnum.Other => new Set<String>()
        };

        try
        {
            Set<String> permissionAllRolesSet = new Set<String>(productionPermissionSetToCategory.keySet());
            permissionAllRolesSet.addAll(storePermissionSet);
            permissionAllRolesSet.addAll(otherPermissionSetToCategory.keySet());

            List<PermissionSetAssignment> permissionByUserList = retPermissionByUser(permissionAllRolesSet, new Set<Id> { UserInfo.getUserId() });

            for(PermissionSetAssignment psa : permissionByUserList) 
            {
                Set<String> currentSet = new Set<String>();
                if(productionPermissionSetToCategory.containsKey(psa.PermissionSet.Name))
                {
                    currentSet = permissionMap.get(LogicalUserRoleEnum.Production);
                }
                else if(storePermissionSet.contains(psa.PermissionSet.Name))
                {
                    currentSet = permissionMap.get(LogicalUserRoleEnum.Store);
                }
                else if(otherPermissionSetToCategory.containsKey(psa.PermissionSet.Name))
                {
                    currentSet = permissionMap.get(LogicalUserRoleEnum.Other);
                }

                currentSet.add(psa.AssigneeId);
            }
        }
        catch(Exception ex)
        {
            SO_UTIL.addErrorMessage(ex);
        }

        return permissionMap;
    }

    public static Map<ID, Set<String>> retPermissionByUserMap() {

        Map<String, String> permRolesSetToCat = new Map<String, String>(productionPermissionSetToCategory);
        permRolesSetToCat.putAll(otherPermissionSetToCategory);

        List<PermissionSetAssignment> permissionByUserList = retPermissionByUser(permRolesSetToCat.keySet(), new Set<ID> { UserInfo.getUserId() });
        Map<ID, Set<String>> permissionMap = new Map<ID, Set<String>>();

        for(PermissionSetAssignment psa : permissionByUserList) {

            if(permRolesSetToCat.containsKey(psa.PermissionSet.Name))
            {
                String categoryName = permRolesSetToCat.get(psa.PermissionSet.Name);
                Set<String> catSet = permissionMap.get(psa.AssigneeId);
                if(null == catSet) {
                    catSet = new Set<String>();
                }
                catSet.add(categoryName);
                permissionMap.put(psa.AssigneeId, catSet);
            }

        }

        return permissionMap;

    }

    public static List<PermissionSetAssignment> retPermissionByUser(Set<String> permissionSetNames, Set<ID> userIDSet) {

        return
         [SELECT Id
                ,AssigneeId
                ,Assignee.Name
                ,PermissionSetId
                ,PermissionSet.Name 
            FROM PermissionSetAssignment 
           WHERE PermissionSet.Name IN : permissionSetNames
             AND AssigneeId IN : userIDSet];
    }
    
    public static List<SPO_FirmOrder__c> retOrderByOpp(Set<ID> oppIDSet) {
		return 
			[SELECT Id, Name
                  , SPO_BriefName__c 
                  , SPO_Substatus__c
                  , SPO_FirmOrderStatus__c
                  //, SPO_RevisedDeliveryDate__c
             	  //, SPO_FirmOrderNumber__c	
				  /*Opportunity*/
				  //, SPO_BriefName__r.SPO_Quantity__c
				  //, SPO_BriefName__r.SPO_ExportPrice__c
				  //, SPO_BriefName__r.SPO_UnitRetailPrice__c   
				  //, SPO_BriefName__r.TotalOpportunityQuantity 
				  //, SPO_BriefName__r.SPO_RemainingPriceToPay__c
			   FROM SPO_FirmOrder__c 
			  WHERE SPO_BriefName__c IN: oppIDSet
		      LIMIT 10000];
	}

    public static User retCurrentUser() {
        return 
            [SELECT Id, Name
                , ProfileId
                , Profile.Name 
                , LanguageLocaleKey
                , MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c, DefaultStore__c
               FROM User 
              WHERE Id =: UserInfo.getUserId()];
    }

    global class SortedFirmOrder implements Comparable {

        public final SPO_FirmOrder__c target;

        public SortedFirmOrder(SPO_FirmOrder__c firmOrder) {
            target = firmOrder;
        }

        global Integer compareTo(Object compareTo) {
            return (retOrderIndex(this) - retOrderIndex(compareTo)); 
        }

        private Integer retOrderIndex(Object order) {
            SortedFirmOrder sfOrder = (SortedFirmOrder)order;
            String firmOrderStatus = sfOrder.target.SPO_FirmOrderStatus__c;
            return String.isNotBlank(firmOrderStatus) ? firmOrderStatusForSort.get(firmOrderStatus) : -1;
        }

    }

}