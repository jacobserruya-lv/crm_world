@isTest
private class IC_ClientListStatistics_VFCx_TEST {

    static testMethod void myUnitTest() {
        
        CLI_CliList__c cli = IC_TestFactory.clientlistMembers();
        cli.Name = 'Test';
        cli.OwnerId = UserInfo.getUserId();
        insert cli;
        
        Account act = IC_testFactory.createAccount();
        act.OwnerId = UserInfo.getUserId();
        insert act;
        
        Contact ct = [Select Id From Contact WHERE accountId = :act.Id limit 1];
        
        CLM_CliListMember__c clm = new CLM_CliListMember__c(ClientList__c = cli.Id, Client__c = ct.Id);
        insert clm;
        
        Task tsk = IC_TestFactory.createTask();
        tsk.WhatId = act.Id;
        tsk.WhoId = ct.Id;
	    insert tsk;
        
        
        ApexPages.currentPage().getParameters().put('id',cli.Id);
        IC_ClientListStatistics_VFCx ctrl = new IC_ClientListStatistics_VFCx();
        ctrl.doAction();
        ApexPages.StandardSetController std = ctrl.con;
        List<IC_ClientListStatistics_VFCx.RecordData> rd = ctrl.getDatas();
        boolean bol = ctrl.hasNext;
        boolean bol1 = ctrl.hasPrevious;
        integer  int1 = ctrl.pageNumber;
        ctrl.first();
        ctrl.last();
        ctrl.previous();
        ctrl.next();
    }
}