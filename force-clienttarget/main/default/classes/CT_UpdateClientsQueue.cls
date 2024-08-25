global with sharing class CT_UpdateClientsQueue implements Queueable {
    List<Account> accountsToUpdate = new List<Account>();

    public CT_UpdateClientsQueue(List<Account> accList) {
        accountsToUpdate = accList;
    }

    global void execute(QueueableContext context) {
        update accountsToUpdate;
    }
}