/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-21-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class QueueableManualMergeAPI implements Queueable, Database.AllowsCallouts {
    private TECH_IntegrationManager__c IntegrationManager;
    private String jsonBody;

    public QueueableManualMergeAPI(TECH_IntegrationManager__c IntegrationManager, String jsonBody) {
        this.IntegrationManager = IntegrationManager;
        this.jsonBody = jsonBody;
    }

    public void execute(QueueableContext context) {
        ICX_WS_Manual_Merge.ManualMergeAPI(this.IntegrationManager, this.jsonBody);
    }
}