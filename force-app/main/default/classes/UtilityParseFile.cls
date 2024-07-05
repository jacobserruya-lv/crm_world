public with sharing class UtilityParseFile {

    public static sObject CsvParserToSObject (List<String> fieldHeaders,List<String> inputvalues,String  objName){
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
        Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
        sObject sObj = objType.newSObject();
         for(Integer j=1; j < fieldHeaders.size(); j++){
            String field = fieldHeaders[j];
            String value = (j >= inputvalues.size()) ? '' : inputvalues[j].trim(); // When the last value (field) in the row is empty
            system.debug(value);
            if(String.isNotBlank(value)){
                Schema.DisplayType fieldType = fieldsMap.get(field).getDescribe().getType();
                if(fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.PERCENT || fieldType == Schema.DisplayType.CURRENCY)
                    sObj.put(field, parseDecimal(value));
                else if(fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.TEXTAREA ||fieldType == Schema.DisplayType.PICKLIST)
                    sObj.put(field, value);
                else if(fieldType == Schema.DisplayType.INTEGER)
                    sObj.put(field, Integer.valueOf(value));
                else if(fieldType == Schema.DisplayType.ID || fieldType == Schema.DisplayType.REFERENCE)
                    sObj.put(field, Id.valueOf(value));
                else if(fieldType == Schema.DisplayType.DATE)
                    sObj.put(field, Date.parse(value));
                else if(fieldType == Schema.DisplayType.DATETIME)
                    sObj.put(field, DateTime.parse(value));
                else if(fieldType == Schema.DisplayType.BOOLEAN)
                    sObj.put(field, Boolean.valueOf(value));
                else 
                    throw new ParseException('fieldType not resolved');
            } 
        }
        return sObj;
    }

    public static Decimal parseDecimal(String str){
        Decimal val = null;
        if(String.isNotBlank(str)){
            String temp = str.replaceAll('[\\.\\,\\s]', ''); 
            // strip out dots, commas and whitespace characters (some countries use space as thousands separator)
            // we don't use simple "leave only digits" because we could have minus sign in front or scientific notation like 1e4
            val = Decimal.valueOf(temp);
            List<String> pieces = str.split('[\\.\\,]');
            if(pieces.size() > 1){
                Integer fractionpartSize = pieces[pieces.size()-1].length();
                val /= Math.pow(10,fractionpartSize);
            }
        }
        return val;
    }


    public class ParseException extends Exception{}
}