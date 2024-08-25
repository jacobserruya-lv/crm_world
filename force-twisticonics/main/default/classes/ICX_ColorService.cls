public with sharing class ICX_ColorService {
    public static String getColorNameFromHexCode(String hexCode) { 
        List<ICX_Color__mdt> colorList = [Select Id, MasterLabel, hex_code__c FROM ICX_Color__mdt WHERE hex_code__c = :hexCode];

        if (colorList.size() > 0) {
            return colorList.get(0).MasterLabel;
        }
        else return hexCode;
    }
}