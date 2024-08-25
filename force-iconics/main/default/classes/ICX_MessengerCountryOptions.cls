public with sharing class ICX_MessengerCountryOptions {
    public class optionOutput {
        public optionOutput(Decimal i, List<String> opt){
            index = i;
            options = opt;
        }
        @InvocableVariable(required=true)
        public Decimal index;
        @InvocableVariable(required=true)
        public List<String> options;
      }
    @InvocableMethod(label='Country Options')
    public static List<optionOutput>  countryOptions(List<Decimal> index) {
        Decimal groupIndex;
        Decimal i = index != null && index[0] != null ? index[0] : 0;

        groupIndex = 4 * i;   
        List<optionOutput> output = new List<optionOutput>();
        List <String> options = new List<String>();
        for (Messenger_Configuration__mdt conf : [SELECT Label ,ISO3_Code__c , Messaging_Queue_Id__c ,Confirmation_Message__c, value__c FROM Messenger_Configuration__mdt WHERE value__c >:groupIndex ORDER BY value__c limit 4]) {
            options.add(conf.label); 
        }
        if(!options.contains('International'))//International is the default value, if contains international => there isnt more countries to display
            options.add('Another Country');

        output.add(new optionOutput(i+1, options));
       return output;
    }
}