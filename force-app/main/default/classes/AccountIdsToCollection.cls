public  class AccountIdsToCollection {
 
    @InvocableMethod(label='Account IDs to collection')
    public static List<Outputs> invokeThisMethod(List<Inputs> inputsList) {
         String myInput = inputsList[0].textIDs;
         List<String> myOutput = myInput.split(',');
        Outputs result = new Outputs();
           result.idCollection = myOutput;
         List<Outputs> results= new List<Outputs>();
    results.add(result);
   
        
        return results;
    }
    
    
    
    //output details which goes from apex to flow
    public class Outputs{
        
        @InvocableVariable
        public List<String> idCollection;
        
        
    }
    
    //input details that comes from flow to apex
    public class Inputs{
        
        @InvocableVariable
        public String textIDs;
        
    }
   
}