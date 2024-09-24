global with sharing class BL_IWA_files extends BL_WS_Request implements  BL_WS_Interfaces.DispatchablePOST {

    global Object executePOST(){
        Map<String,Object> record = (Map<String,Object>) getRequestRecord();
        Map<String,Object> records = new Map<String,Object> ();
        String method = (String) record.get('method');

        Object filesNames = record.get('filesNames');
        List<String> filesNamesList = (List<String>) JSON.deserialize(JSON.serialize(filesNames), List<String>.class);

        for(String name: filesNamesList) {
            records.put(name, WRDB_CreateAsset_Controller.createAkamaiHeaders(name, method));
        }
        return  records;
    }
}