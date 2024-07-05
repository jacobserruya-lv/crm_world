/*
* Test Class of the JsonUtilities Class
* @createdBy   Ahlem AYARI
*/
@isTest
public class JsonUtilities_Test {
    
    @isTest
    public static void testGetValuesFromJson(){
        //Valid Json
        String validJson = '{"name": "Ahlem", "age": "30", "city": "Paris"}';
        Map<String, String> expectedMap = new Map<String,String>{
            'name' => 'Ahlem',
             'age' => '30',
             'city' => 'Paris'
        };
        Map<String,String> resultMap = JsonUtilities.getValuesFromJson(validJson);
        System.assertEquals(expectedMap, resultMap, 'Expected and actual maps should match');

		//Blank Json
        String blankJson ='';
        try{
            JsonUtilities.getValuesFromJson(blankJson);
            System.assert(false, 'Exception should be thrown for empty JSON input');
        }catch(JsonUtilities.JsonUtilException e){
            System.assertEquals('No field values were found in the Json String.',Label.ERROR_JSON_EMPTY, 'Exception Message should Match');
        }        
        //Empty Json
        String emptyJson ='{}';
        try{
            JsonUtilities.getValuesFromJson(emptyJson);
            System.assert(false, 'Exception should be thrown for empty JSON input');
        }catch(JsonUtilities.JsonUtilException e){
            System.assertEquals('No field values were found in the Json String.',Label.ERROR_JSON_EMPTY, 'Exception Message should Match');
        }
        
        //Invalid Json
        String invalidJson = '{"name": "Ahlem", "age": 30, "city": "Paris"}';
        try{
            JsonUtilities.getValuesFromJson(invalidJson);
            System.assert(false, 'Exception should be thrown for invalid JSON format');
        }catch(JsonUtilities.JsonUtilException e){
            System.assertEquals('The provided Json String was badly formatted.',Label.ERROR_JSON_BAD_FORMAT, 'Exception Message should Match');
        }
    }

}