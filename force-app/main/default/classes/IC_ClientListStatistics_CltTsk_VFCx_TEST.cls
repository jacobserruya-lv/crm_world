@isTest
private class IC_ClientListStatistics_CltTsk_VFCx_TEST {

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
        ApexPages.currentPage().getParameters().put('UserId',UserInfo.getUserId());
        IC_ClientListStatistics_ClientTask_VFCx ctrl = new IC_ClientListStatistics_ClientTask_VFCx();
    }
}