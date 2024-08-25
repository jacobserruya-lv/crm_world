global with sharing class BL_IWA_Task  extends BL_WS_Request implements BL_WS_Interfaces.DispatchablePOST {

    global Object executePOST() {
        List<Object> records = getRequestRecords();
        return BL_ICON_Task_Helper.insertTasks(records);

    }
}