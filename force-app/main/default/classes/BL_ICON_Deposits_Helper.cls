public with sharing class BL_ICON_Deposits_Helper {
    public static Object getAllMyClientDeposits(String clientId, BL_UserInfo me){
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_DEPOSIT)
                .condition('Client__c = \'' +clientId+ '\' AND CreatedById = \'' + me.basicInfos.Id +'\'')
                .executeQuery()
                .getResponseMappedObjects();
    }

    public static Object getDepositById(String depositId, BL_UserInfo me){
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_DEPOSIT)
                .condition('Id = \'' +depositId+ '\' AND CreatedById = \'' + me.basicInfos.Id +'\'')
                .executeQuery()
                .getMappedObject();
    }

    public static Object getMyClientDepositsByStatus(String clientId, String status, BL_UserInfo me){
        List<String> statusList = status.split(';');
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_DEPOSIT)
                .condition('Client__c = \'' +clientId+ '\' AND CreatedById = \'' + me.basicInfos.Id +'\' AND Status__c ' + BL_ICON_Utils.buildMultiChoiceFilterFromList(statusList))
                .executeQuery()
                .getResponseMappedObjects();
    }

    public static Object getMyDepositsByStatus(String status, BL_UserInfo me){
        List<String> statusList = status.split(';');
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_DEPOSIT)
                .condition('CreatedById = \'' + me.basicInfos.Id +'\' AND Status__c ' + BL_ICON_Utils.buildMultiChoiceFilterFromList(statusList))
                .executeQuery()
                .getResponseMappedObjects();
    }

    public static Object getAllMyDeposits( BL_UserInfo me){
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_DEPOSIT)
                .condition('CreatedById = \'' + me.basicInfos.Id +'\'' )
                .executeQuery()
                .getResponseMappedObjects();
    }

    public static Object insertDeposit(Map<String, Object> record) {
        if (record.get('status') == null){
            record.put('status', 'Open');
        }
        if(record.get('externalId') == null){
            record.put('externalId', (String)record.get('slit_code')+(String)record.get('slit_store') +(String)record.get('slit_terminator'));
        }
        if(record.get('return') != null && record.get('return') != ''){
            Map<String, Object> returnObj = (Map<String, Object>)record.get('return');
            String parentExternalId = (String)returnObj.get('slit_code')+(String)returnObj.get('slit_store') +(String)returnObj.get('slit_terminator');
            List<Deposit__c> parentDeposit = (List<Deposit__c>) new BL_EasyQuery()
                                                        .useCase(BL_ICON_Constants.USE_CASE_DEPOSIT)
                                                        .condition('External_Id__c = \''+parentExternalId+'\'')
                                                        .executeQuery()
                                                        .getSobjects();
            if(parentDeposit.size() > 0){
                record.put('original_deposit',parentDeposit[0].Id);
                parentDeposit[0].Status__c = 'Delivered';
                update parentDeposit[0];

                if(record.get('items') != null){
                    List<Object> items = (List<Object>)record.get('items');
                    Decimal totalAmount = 0;
                    for(Object item : items){
                        Map<String,Object> itemObj = (Map<String,Object>)item;
                        totalAmount += (Decimal) itemObj.get('amount');
                    }
                    record.put('total_amount',totalAmount);
                }
                update parentDeposit[0];
            } else {
                throw new BL_Exceptions.BL_Exception('PARENT_DEPOSIT_NOT_FOUND');
            }                                          

        }
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_DEPOSIT)
                .upsertWrappersWithChilds(new List<Object>{record}, Deposit__c.Fields.External_Id__c, null);

    }
}