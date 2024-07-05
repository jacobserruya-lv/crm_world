/**
     * Controller of the VO_Template 
     * @createdBy   Menashe Yamin ,  8/26/2015         
     */

public class VO_Template {
	Public String helpLink {get;set;}

	public VO_Template(){
		this.helpLink = initHelpLink();
	}


	/**
	 * [return the link to the help in the header from custom setting.]
	 * @scenario	[take from the custom setting VO_Config__c the header_help_link value]
	 * @result	[As the seem as the description ]
 	 * @createdBy  	Menash Yamin 10.09.15         
 	 * @lastModifiedBy 	Menash Yamin 10.09.15
	 */
	private String initHelpLink(){
		String ans = '#';
		if (VO_Config__c.getValues('header_help_link').Value__c !=null)
		{
			ans = String.valueof(VO_Config__c.getValues('header_help_link').Value__c);
		}
		return ans;
	}
}