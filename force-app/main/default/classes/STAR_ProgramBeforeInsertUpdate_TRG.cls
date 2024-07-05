public with sharing class STAR_ProgramBeforeInsertUpdate_TRG {

	public static void ProgamInsertOrUpdate (List<Program__c>  newValues)
	{
	   System.debug('### newValues :' +newValues.size());
       if (!IC_UTILS.empty (newValues)) 
       {				
	      for (Program__c p : newValues) 
	      {
			if(p.Cancelled__c==true)
			   p.Status__c='Cancelled';
	      }
					 
    	}   
	}
}