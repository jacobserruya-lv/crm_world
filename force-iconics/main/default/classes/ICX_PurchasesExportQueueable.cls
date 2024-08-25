public with sharing class ICX_PurchasesExportQueueable implements Queueable, Database.AllowsCallouts {
    private String dreamId;
    private String exportRecordId;


    public ICX_PurchasesExportQueueable(String dreamId, String exportRecordId) {
 		this.dreamId = dreamId;
        this.exportRecordId = exportRecordId;

    }

    public void execute(QueueableContext context) {
        ICX_PurchasesExport.actionsForExportPurchases(this.dreamId, this.exportRecordId); 
    }

}