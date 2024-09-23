global with sharing class CT_UpdateClientsQueue implements Queueable {
    List<SObject> accountsToUpdate = new List<SObject>();

    public CT_UpdateClientsQueue(List<SObject> accList) {
        accountsToUpdate = accList;
    }

    global void execute(QueueableContext context) {
        update accountsToUpdate;
    }
}