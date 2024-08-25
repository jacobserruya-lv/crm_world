public with sharing class CareServiceLineItem_TriggerHandler {
    public static void beforeInsert(List<CareServiceLineItem__c> newCareServiceLineItemList) {

        Set<Id> csList = new Set<Id>();
        List<String> codeList = new List<String>();
        String csLanguage;
        Map<Id, String> careService_Language_Map = new Map<Id, String>();
        Map<String, Map<String, Repair_Instruction_Tranlation__c>> code_lang_translation_map = new Map<String, Map<String, Repair_Instruction_Tranlation__c>>();

        for (CareServiceLineItem__c csItem : newCareServiceLineItemList) 
        {
            csList.add(csItem.careService__c);
            codeList.add(csItem.InstructionCode__c);
        }
        for(CareService__c cs: [select id, LanguageLocaleKey__c from CareService__c where id in:csList])
        {
            careService_Language_Map.put(cs.Id, cs.LanguageLocaleKey__c);
        }

        //initialize translation map
        for(Repair_Instruction_Tranlation__c t: [SELECT Instruction_Code__c, LanguageLocaleKey__c, Client_Translated_Instruction_Name__c,Translated_Instruction_Name__c FROM Repair_Instruction_Tranlation__c WHERE Instruction_Code__c IN: codeList AND LanguageLocaleKey__c IN:careService_Language_Map.values()]){
            if(!code_lang_translation_map.containsKey(t.Instruction_Code__c))
                code_lang_translation_map.put(t.Instruction_Code__c, new Map<String, Repair_Instruction_Tranlation__c>());
                code_lang_translation_map.get(t.Instruction_Code__c).put(t.LanguageLocaleKey__c,t);
        }
        for (CareServiceLineItem__c csItem : newCareServiceLineItemList) 
        {
            csLanguage = careService_Language_Map.get(csItem.careService__c);
            if(csLanguage != null && code_lang_translation_map.containsKey(csItem.InstructionCode__c) && code_lang_translation_map.get(csItem.InstructionCode__c).containsKey(csLanguage)){
                if(code_lang_translation_map.get(csItem.InstructionCode__c).get(csLanguage).Client_Translated_Instruction_Name__c != null)
                csItem.Instruction_Name_ICONiCS__c = code_lang_translation_map.get(csItem.InstructionCode__c).get(csLanguage).Client_Translated_Instruction_Name__c;
                else if(code_lang_translation_map.get(csItem.InstructionCode__c).get(csLanguage).Translated_Instruction_Name__c != null)
                csItem.Instruction_Name_ICONiCS__c = code_lang_translation_map.get(csItem.InstructionCode__c).get(csLanguage).Translated_Instruction_Name__c;
            } else
            csItem.Instruction_Name_ICONiCS__c = csItem.Instruction_Name__c;
        }
    }

    public static void beforeUpdate(List<CareServiceLineItem__c> newCareServiceLineItemList,Map<id, CareServiceLineItem__c> newCareServiceLineItemMap,List<CareServiceLineItem__c> oldCareServiceLineItemList, Map<id, CareServiceLineItem__c> oldCareServiceLineItemMap) {

        Set<Id> csList = new Set<Id>();
        List<String> codeList = new List<String>();
        String csLanguage;
        Map<Id, String> careService_Language_Map = new Map<Id, String>();
        Map<String, Map<String, Repair_Instruction_Tranlation__c>> code_lang_translation_map = new Map<String, Map<String, Repair_Instruction_Tranlation__c>>();

        for (CareServiceLineItem__c csItem : newCareServiceLineItemList) 
        {
            csList.add(csItem.careService__c);
            codeList.add(csItem.InstructionCode__c);
        }
        for(CareService__c cs: [select id, LanguageLocaleKey__c from CareService__c where id in:csList])
        {
            careService_Language_Map.put(cs.Id, cs.LanguageLocaleKey__c);
        }

        //initialize translation map
        for(Repair_Instruction_Tranlation__c t: [SELECT Instruction_Code__c, LanguageLocaleKey__c, Client_Translated_Instruction_Name__c,Translated_Instruction_Name__c FROM Repair_Instruction_Tranlation__c WHERE Instruction_Code__c IN: codeList AND LanguageLocaleKey__c IN:careService_Language_Map.values()]){
            if(!code_lang_translation_map.containsKey(t.Instruction_Code__c))
                code_lang_translation_map.put(t.Instruction_Code__c, new Map<String, Repair_Instruction_Tranlation__c>());
                code_lang_translation_map.get(t.Instruction_Code__c).put(t.LanguageLocaleKey__c,t);
        }
        for (CareServiceLineItem__c csItem : newCareServiceLineItemList) 
        {
            csLanguage = careService_Language_Map.get(csItem.careService__c);
            if(csLanguage != null && code_lang_translation_map.containsKey(csItem.InstructionCode__c) && code_lang_translation_map.get(csItem.InstructionCode__c).containsKey(csLanguage)){
                if(code_lang_translation_map.get(csItem.InstructionCode__c).get(csLanguage).Client_Translated_Instruction_Name__c != null)
                csItem.Instruction_Name_ICONiCS__c = code_lang_translation_map.get(csItem.InstructionCode__c).get(csLanguage).Client_Translated_Instruction_Name__c;
                else if(code_lang_translation_map.get(csItem.InstructionCode__c).get(csLanguage).Translated_Instruction_Name__c != null)
                csItem.Instruction_Name_ICONiCS__c = code_lang_translation_map.get(csItem.InstructionCode__c).get(csLanguage).Translated_Instruction_Name__c;
            }else
            csItem.Instruction_Name_ICONiCS__c = csItem.Instruction_Name__c;
        }
    }

}