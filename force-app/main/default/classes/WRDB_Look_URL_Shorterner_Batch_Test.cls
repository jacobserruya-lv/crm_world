@isTest
public class WRDB_Look_URL_Shorterner_Batch_Test {
    @isTest
    public static void WRDB_Look_URL_Shorterner_Batch_TEST() {
        createLook();
        WRDB_Look_URL_Shorterner_Batch bat = new WRDB_Look_URL_Shorterner_Batch();
        ID batchprocessid = Database.executeBatch(bat,10);
    }

    public static void createLook() {
        Look__c look = new Look__c(
            SKUs__c = 'M57952;1A8WW9;1A8QEM;Z1485W;1A8X1J;',
            SHORT_LV_URL_Sharing__c = 'https://look.louisvuitton.com/xUd0w',
            Picture_URL__c = 'https://www.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louisvuitton--M55224_PM2_Front view.jpg'
        );

        insert look;
    }
}