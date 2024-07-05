/**
* @group Clienteling 
* @since Juny 2020
* @description Test class for BL_Utils
*/

@isTest
public class BL_Utils_Test {
    
    @isTest
    static void testMethod1(){  
        List<String> stringList = new List<String>();
        Set<String> stringSet = new Set<String>();
        decimal dec = 4.5;
        integer i = 5;
        List<Sobject> items = new List<Sobject>();
        string item ='item';
        sObject sObj = Schema.getGlobalDescribe().get('Account').newSObject() ;
        Object obj = 'test';
        items.add(sObj);
        Test.startTest();
            BL_Utils.convertToString(stringList);
            BL_Utils.convertToString(stringSet);
            BL_Utils.round(dec,i);
            stringList.add('test');
            stringSet.add('test');
            BL_Utils.convertToString(stringSet);
            BL_Utils.toList(stringSet);
            BL_Utils.convertToString(stringList);
            BL_Utils.toSet(stringList);
            BL_Utils.orderList(items,'id','asc');
            BL_Utils.orderList(items,'id','desc');
            BL_Utils.createMapFromSObject(items,'id');
            BL_Utils.createMapFromSObject(items,'id','id');
            BL_Utils.getIdList(items,'id');
            BL_Utils.getCurrentOrgLimits();
            BL_Utils.logError('test');
            BL_Utils.toString(obj);
            BL_Utils.baseURL();
        Test.stopTest();
    }
    

}