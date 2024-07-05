/*	 * @author Keman WU
* @date creation 29/10/2021
* @description Iconics Account trigger Handler
*/
public with sharing class ICX_Account_TriggerHandler {
    
    private static boolean run = true;
    private static final String ISDEFAULT = 'ISDEFAULT';    
   
    public static boolean runOnce() {
        if (run) {
            run = false;
            return true;
        } 
        else {
            return run;
        }
    }
    public static void beforeInsert(List<Account> newAccountList, Map<id, Account> newAccountMap) {
        Map <String,CountryMapping__mdt>  MapCountryCallingCodeCountry = new Map <String,CountryMapping__mdt> ();
        Map <String,String>  MapCountryNationalCodeFix = new Map <String,String> ();
        Map <String,String>  MapCountryNationalCode = new Map <String,String> ();
        Map<String,String> MapGenderCode = new Map<String,String>();
        MapGenderCode.put('Male','M');
        MapGenderCode.put('Female','F');
        MapGenderCode.put('Netural','N');
        MapGenderCode.put('Other','O');
        // GenderCode.put('Unkown','U');
        List<CountryMapping__mdt> lstCountryMapping = [select id, Picklist__c,Case__c, Calling_Code__c,Nationality__c,CountryName__c,Iso2Code__c,Iso3Code__c from CountryMapping__mdt ];
        for(CountryMapping__mdt cm : lstCountryMapping){
            if(cm.Calling_Code__c != null)
            MapCountryCallingCodeCountry.put('+'+Integer.valueOf(cm.Calling_Code__c), cm);
        }
        for(CountryMapping__mdt nc : lstCountryMapping)
        {
            if(nc.Nationality__c != null)
            {
    
                MapCountryNationalCode.put(String.valueOf(nc.Nationality__c).tolowercase(),nc.Iso3Code__c);
                if(nc.Picklist__c != null && String.isNotBlank(nc.Picklist__c)) MapCountryNationalCodeFix.put(String.valueOF(nc.Picklist__c).tolowercase(), nc.Iso3Code__c);
                else if(nc.Case__c != null && String.isNotBlank(nc.Case__c))  MapCountryNationalCodeFix.put(String.valueOF(nc.Case__c).tolowercase(), nc.Iso3Code__c);
            }
        }

        for(Account accountRecord : newAccountList){
            //PersonMobilePhone
            if(accountRecord.PersonMobilePhone != null){
                for(String key : MapCountryCallingCodeCountry.keySet()){
               if( accountRecord.PersonMobilePhone.contains(key))
               accountRecord.MobilePhoneCountryCode__pc = MapCountryCallingCodeCountry.get(key).Iso2Code__c;
}
            // accountRecord.PersonMobilePhone = UpdatePhoneNumber(accountRecord.PersonMobilePhone);
            }
            //PersonHomePhone
            if(accountRecord.PersonHomePhone != null){
                for(String key : MapCountryCallingCodeCountry.keySet()){
               if( accountRecord.PersonHomePhone.contains(key))
               accountRecord.HomePhoneCountrycode__pc = MapCountryCallingCodeCountry.get(key).Iso2Code__c;
}
            // accountRecord.PersonHomePhone = UpdatePhoneNumber(accountRecord.PersonHomePhone);

            }

             //WorkPhone
             if(accountRecord.Phone != null){
                for(String key : MapCountryCallingCodeCountry.keySet()){
                    if( accountRecord.Phone.contains(key))
                    accountRecord.WorkPhoneCountryCode__pc = MapCountryCallingCodeCountry.get(key).Iso2Code__c;
                 }
            // accountRecord.Phone = UpdatePhoneNumber(accountRecord.Phone);

            }   

           // NationalityCode
            if(accountRecord.Nationality__pc != null && accountRecord.Nationality__pc != 'NAT'){


                if(MapCountryNationalCode.containsKey(accountRecord.Nationality__pc.tolowercase())){
                    accountRecord.NationalityCountryCode__pc = MapCountryNationalCode.get(accountRecord.Nationality__pc.tolowercase());
                }
                else if(MapCountryNationalCodeFix.containsKey( accountRecord.Nationality__pc.tolowercase())){
                   
                    accountRecord.NationalityCountryCode__pc= MapCountryNationalCodeFix.get(accountRecord.Nationality__pc.tolowercase());
                    
                }
                else {
                    accountRecord.NationalityCountryCode__pc = null;
                }
                /*
                accountRecord.NationalityCountryCode__pc = null;
        
                for(String key : MapCountryNationalCode.keySet()){
                    if(key.equals(accountRecord.Nationality__pc))
                    {
                        accountRecord.NationalityCountryCode__pc = MapCountryNationalCode.get(accountRecord.Nationality__pc);
                    }
                }*/
            } else {
                accountRecord.NationalityCountryCode__pc = '777';
            }
           
                

            //GenderCode
            if(accountRecord.Gender__pc != null)
            { 
                if(MapGenderCode.containsKey(accountRecord.Gender__pc)) accountRecord.GenderCode__pc = MapGenderCode.get(accountRecord.Gender__pc);

            }

                //PersonBirthdate
                if(accountRecord.PersonBirthdate!= null) 
                {
                    accountRecord.BirthdateDay__pc = String.valueOf(accountRecord.PersonBirthdate.Day());
                    accountRecord.BirthdateMonth__pc =String.valueOf(accountRecord.PersonBirthdate.Month());
                    accountRecord.BirthdateYear__pc =String.valueOf(accountRecord.PersonBirthdate.Year());
                }
           
            
            //TopologyCode
            if(accountRecord.Typology__pc == null)
            {
               accountRecord.Typology__pc = 'Prospects';
               accountRecord.TypologyCode__pc = '7';
            }


                 
        }
    }
    
    public static void beforeUpdate(List<Account> newAccountList, Map<id, Account> newAccountMap,List<Account> oldAccountList, Map<id, Account> oldAccountMap) {
        Map <String,CountryMapping__mdt>  MapCountryCallingCodeCountry = new Map <String,CountryMapping__mdt> ();
        Map <String,String>  MapCountryNationalCode = new Map <String,String> ();
        Map <String,String>  MapCountryNationalCodeFix = new Map <String,String> ();
        Map<String,String> MapGenderCode = new Map<String,String>();
        MapGenderCode.put('Male','M');
        MapGenderCode.put('Female','F');
        MapGenderCode.put('Netural','N');
        MapGenderCode.put('Other','O');
        // GenderCode.put('Unkown','U');
        List<CountryMapping__mdt> lstCountryMapping = [select id, Picklist__c,Case__c,Calling_Code__c,Nationality__c,CountryName__c,Iso2Code__c,Iso3Code__c from CountryMapping__mdt ];
        for(CountryMapping__mdt cm : lstCountryMapping){
            if(cm.Calling_Code__c != null)
            MapCountryCallingCodeCountry.put('+'+Integer.valueOf(cm.Calling_Code__c), cm);
        }
        for(CountryMapping__mdt nc : lstCountryMapping)
        {
            if(nc.Nationality__c != null)
            {
                MapCountryNationalCode.put(String.valueOf(nc.Nationality__c.toLowerCase()),nc.Iso3Code__c);
                if(nc.Picklist__c != null && String.isNotBlank(nc.Picklist__c)) MapCountryNationalCodeFix.put(String.valueOF(nc.Picklist__c).tolowercase(), nc.Iso3Code__c);
                else if(nc.Case__c != null && String.isNotBlank(nc.Case__c))  MapCountryNationalCodeFix.put(String.valueOF(nc.Case__c).tolowercase(), nc.Iso3Code__c);
            }
        }
        
        
        for(Account accountRecord : newAccountList){
            //PersonMobilePhone
            if(accountRecord.PersonMobilePhone != null && (accountRecord.MobilePhoneCountryCode__pc == null || accountRecord.PersonMobilePhone != oldAccountMap.get(accountRecord.id).PersonMobilePhone)){
                for(String key : MapCountryCallingCodeCountry.keySet()){                   
               if( accountRecord.PersonMobilePhone.contains(key))
               accountRecord.MobilePhoneCountryCode__pc = MapCountryCallingCodeCountry.get(key).Iso2Code__c;
                }
           // accountRecord.PersonMobilePhone = UpdatePhoneNumber(accountRecord.PersonMobilePhone);

            }

            
            //PersonHomePhone
            if(accountRecord.PersonHomePhone != null && (accountRecord.HomePhoneCountrycode__pc == null || accountRecord.PersonHomePhone != oldAccountMap.get(accountRecord.id).PersonHomePhone)){
                for(String key : MapCountryCallingCodeCountry.keySet()){
               if( accountRecord.PersonHomePhone.contains(key))
               accountRecord.HomePhoneCountrycode__pc = MapCountryCallingCodeCountry.get(key).Iso2Code__c;
            }
                //  accountRecord.PersonHomePhone = UpdatePhoneNumber(accountRecord.PersonHomePhone);
            }

              //WorkPhone
              if(accountRecord.Phone != null && (accountRecord.WorkPhoneCountryCode__pc == null || accountRecord.Phone != oldAccountMap.get(accountRecord.id).Phone)){
                for(String key : MapCountryCallingCodeCountry.keySet()){
                    if( accountRecord.Phone.contains(key))
                    accountRecord.WorkPhoneCountryCode__pc = MapCountryCallingCodeCountry.get(key).Iso2Code__c;
                 }                
                 // accountRecord.Phone = UpdatePhoneNumber(accountRecord.Phone);

            }  

            //NationalityCode
            if( oldAccountMap.get(accountRecord.id).Nationality__pc != accountRecord.Nationality__pc){
            
            if (accountRecord.Nationality__pc != null) {
                // accountRecord.NationalityCountryCode__pc = null;

        
                if( MapCountryNationalCode.containsKey(accountRecord.Nationality__pc.toLowerCase()) ) accountRecord.NationalityCountryCode__pc = MapCountryNationalCode.get(accountRecord.Nationality__pc.toLowerCase());
                else if( MapCountryNationalCodeFix.containsKey(accountRecord.Nationality__pc.toLowerCase()) ) accountRecord.NationalityCountryCode__pc = MapCountryNationalCodeFix.get(accountRecord.Nationality__pc.toLowerCase());
                else accountRecord.NationalityCountryCode__pc = null;


                /*for(String key : MapCountryNationalCode.keySet()){
                    if(key.equals(accountRecord.Nationality__pc) )
                    {
                        
                        accountRecord.NationalityCountryCode__pc = MapCountryNationalCode.get(key);
                    }
                }*/
            }else accountRecord.NationalityCountryCode__pc = '777';

        }
            
            //GenderCode
            if(accountRecord.Gender__pc != null && oldAccountMap.get(accountRecord.id).Gender__pc != accountRecord.Gender__pc )
            { 
                if(MapGenderCode.containsKey(accountRecord.Gender__pc)) accountRecord.GenderCode__pc = MapGenderCode.get(accountRecord.Gender__pc);
            }

               //PersonBirthdate
               if(accountRecord.PersonBirthdate!= null && oldAccountMap.get(accountRecord.id).PersonBirthdate != accountRecord.PersonBirthdate) 
               {
                    accountRecord.BirthdateDay__pc = String.valueOf(accountRecord.PersonBirthdate.Day());
                   accountRecord.BirthdateMonth__pc =String.valueOf(accountRecord.PersonBirthdate.Month());
                   accountRecord.BirthdateYear__pc =String.valueOf(accountRecord.PersonBirthdate.Year());
                }

            if(accountRecord.Typology__pc == null &&  oldAccountMap.get(accountRecord.id).Typology__pc != accountRecord.Typology__pc )
            {
               accountRecord.Typology__pc = 'Prospect';
               accountRecord.TypologyCode__pc = '7';
            }

            
            
        
        //newsletter to false
        if(accountRecord.Can_Be_Contacted_By_Email__pc!= oldAccountMap.get(accountRecord.id).Can_Be_Contacted_By_Email__pc && accountRecord.Can_Be_Contacted_By_Email__pc==false && accountRecord.Newsletter__c!=false)
        {

            accountRecord.Newsletter__c=false;
            accountRecord.Unsubscribe__pc=true;
            accountRecord.UnsubscribeDate__pc = Date.today();

        }
        }                       
    }
    

    // naomi 15/05/2022 
    // workflows : Account - Home Phone - CTI Format / Account - Mobile Phone - CTI Format / Account - Work Phone - CTI Format 
    // replace '%2B' by '+' in phone number received by B+S
    // temporary solution --> with Genesys we shoudln't need this function anymore. However, B+S will still be actived for China at the end of 2022
    public static String UpdatePhoneNumber(String currentPhone)
    {
        if(currentPhone.startsWith('%2B'))
        {
            currentPhone = '+'+currentPhone.right(currentPhone.length()-3);
        } 
        else if(currentPhone.startsWith('000')) 
        {
            currentPhone = '+'+currentPhone.right(currentPhone.length()-3);
        }
        else if(currentPhone.startsWith('00')) 
            {
                currentPhone = '+'+currentPhone.right(currentPhone.length()-2);

            }
           return currentPhone;
    }
    
    }