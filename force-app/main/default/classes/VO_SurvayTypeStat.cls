/**
* @author menash.yamin@kerensen.com.devVoice
* @description 
* this object represent type of survay and all the statistics that we need about
* @createdBy  	Menash Yamin 20.09.15         
* @lastModifiedBy 	Menash Yamin 20.09.15
*
*/

public class VO_SurvayTypeStat { 
	public String title {Set;get;}

	public Integer total {Set;get;}
	public Integer tNew {Set;get;}
	public Integer tPending {Set;get;}
	public Integer tClosed {Set;get;}
	public Integer tNoAaction {Set;get;}

	public Integer delightedClients {Set;get;}
	public Integer dcNew {Set;get;}
	public Integer dcPending {Set;get;}

	public Integer promoterClients {Set;get;}
	public Integer pmNew {Set;get;}
	public Integer pmPending {Set;get;}



	public Integer recoveryAct {Set;get;}
	public Integer raNew {Set;get;}
	public Integer raPending {Set;get;}
	public Integer raPending7D {Set;get;}
	public Integer NPS {Set;get;}

	public String survayTypeUrl {Set;get;}
	public Boolean isPromoterClients {get;Set;} //recovery-false ; promoter client -true

	public Integer tDetractor {Set;get;}
	public Integer tPromotor {Set;get;}
	public Integer totalNmonth {Set;get;}
	public Integer tNDetractor {Set;get;}
	public Integer tNPromotor {Set;get;}

	public VO_SurvayTypeStat()
	{
            
    }

    public VO_SurvayTypeStat(String title)
	{
        this.title = title;
		this.survayTypeUrl = title.replace(' ', '_');
		this.promoterClients = 0;
		this.pmNew = 0;
		this.pmPending = 0;
		this.total = 0;
        this.tNew = 0;
        this.tPending = 0;
        this.tClosed = 0;
        this.tNoAaction = 0;
        this.dcNew = 0;
        this.dcPending = 0;
        this.raNew = 0;
        this.raPending = 0;
        this.raPending7D = 0;
        this.NPS = 0;
		this.delightedClients =0;
		this.recoveryAct = 0;
		this.isPromoterClients = false; 
		this.tDetractor = 0;
		this.tPromotor = 0;
		this.totalNmonth = 0;
		this.tNDetractor = 0;
		this.tNPromotor = 0;
    }

	/**
	 * [init the keys of the map by the metedate of the picklist field SurveyType__c of VO_Survey__c.]
	 * @scenario	[get all the values from this field and put them in the map as keys ]
	 * @result	[survayTypeStatMap that contain key -survay type ]
 	 * @createdBy  	Menash Yamin 10.09.15         
 	 * @lastModifiedBy 	Menash Yamin 20.09.15
	 */
	public static Map<String, VO_SurvayTypeStat> initSurvayTypeStatMap()
	{
		Map<String, VO_SurvayTypeStat> survayTypeStatMap = new Map <String, VO_SurvayTypeStat>();
		Schema.DescribeFieldResult fieldResult = VO_Survey__c.SurveyType__c.getDescribe();
		for( Schema.PicklistEntry f : fieldResult.getPicklistValues())
		{
			survayTypeStatMap.put(f.getValue(), new VO_SurvayTypeStat(f.getLabel()));
		}
		system.debug('fieldResult : :' + survayTypeStatMap);
		return survayTypeStatMap;
	}

	/**
	 * [init the keys of the map by the metedate of the picklist field SurveyType__c of VO_Survey__c that
	 * the user have permission]
	 * @scenario	[ ]
	 * @result	[survayTypeStatMap that contain key -survay type ]
 	 * @createdBy  	Menash Yamin 19.10.15         
 	 * @lastModifiedBy 	Menash Yamin 19.10.15 
	 */
	public static Map<String, VO_SurvayTypeStat> initSurvayTypeStatMap(List<String> permissionToSeeSurveyTypeList)
	{
		Map<String, VO_SurvayTypeStat> survayTypeStatMap = new Map <String, VO_SurvayTypeStat>();
		Schema.DescribeFieldResult fieldResult = VO_Survey__c.SurveyType__c.getDescribe();
		for( Schema.PicklistEntry f : fieldResult.getPicklistValues())
		{
			for(String permissionStr :permissionToSeeSurveyTypeList)
			{
				if(permissionStr.equals(f.getValue()))
				{	
					survayTypeStatMap.put(f.getValue(), new VO_SurvayTypeStat(f.getLabel()));
				}
			}

		}
		system.debug('fieldResult : :' + survayTypeStatMap);
		return survayTypeStatMap;
	}


	public static void updatesurvayTypeStatMapForLastNdays(Map<String, VO_SurvayTypeStat> survayTypeStatMap, List<AggregateResult> results)
	{
		VO_SurvayTypeStat currSurvayMapValue;
		for(AggregateResult ar :results)
		{
			if(survayTypeStatMap.containsKey(ar.get('SurveyType__c') +''))
			{  
				currSurvayMapValue = survayTypeStatMap.get(ar.get('SurveyType__c') +'');
				//Recovery Act +pending
				if((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R3').Value__c) 
					&& 
				   (ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R42').Value__c) )
				{
				   currSurvayMapValue.raPending7D += Integer.valueOf(ar.get('expr0'));
				}
			}
			currSurvayMapValue = null;
		}

	}
	
	private static void updaeTotalFieldsInSurvayMap(AggregateResult ar, VO_SurvayTypeStat currSurvayMapValue)
	{

		System.debug('ar : :' + ar);
		System.debug('currSurvayMapValue : :' + currSurvayMapValue);	
		//New
		if((ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC1R2').Value__c))
		{
			System.debug('expr0 : :' +ar.get('expr0'));
			currSurvayMapValue.tNew += Integer.valueOf(ar.get('expr0'));
		}

		//pending
		if((ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC1R3').Value__c))
		{
			currSurvayMapValue.TPending += Integer.valueOf(ar.get('expr0'));
		}

		//CLOSED
		if((ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC1R4').Value__c))
		{
			currSurvayMapValue.tClosed += Integer.valueOf(ar.get('expr0'));
		}
		//No Action
		if((ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC1R5').Value__c))
		{
			currSurvayMapValue.tNoAaction += Integer.valueOf(ar.get('expr0'));
		}
	}

	private static void updaeDelightedClientsFieldsInSurvayMap(AggregateResult ar, VO_SurvayTypeStat currSurvayMapValue)
	{
		//DELIGHTED CLIENTS + new
		if((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R1').Value__c) 
			&& (ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R21').Value__c) )
		{
        	currSurvayMapValue.dcNew += Integer.valueOf(ar.get('expr0'));
		}

		//DELIGHTED CLIENTS + pending
		if((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R1').Value__c) 
		&& 	(ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R22').Value__c) )
		{
			currSurvayMapValue.dcPending += Integer.valueOf(ar.get('expr0'));
		}

		//DELIGHTED CLIENTS - add due to new calc of types precentes in 24/11
		if((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R1').Value__c))
		{
			currSurvayMapValue.delightedClients += Integer.valueOf(ar.get('expr0'));
		}


	}

	private static void updaePromoterClientsFieldsInSurvayMap(AggregateResult ar, VO_SurvayTypeStat currSurvayMapValue)
	{
		System.debug('AR : '+ ar );
		System.debug('ar.get(Type__c)' + ar.get('Type__c'));
		System.debug('chartDisplayC2R1Promoter' + VO_Config__c.getValues('chartDisplayC2R1Promoter').Value__c);
		System.debug((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R1Promoter').Value__c));

		System.debug('ar.get(Status__c)' + ar.get('Status__c'));
		System.debug('vo chartDisplayC2R21' + VO_Config__c.getValues('chartDisplayC2R21').Value__c);
		System.debug((ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R21').Value__c));



		//Promoter Clients +new		
		if((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R1Promoter').Value__c)  
			&& (ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R21').Value__c))
		{
			System.debug('ADD TO NEW PROMOTER');
			currSurvayMapValue.pmNew += Integer.valueOf(ar.get('expr0'));
		}

		//Promoter Clients +pending
		if((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R1Promoter').Value__c) 
			&& (ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R22').Value__c))
		{
			System.debug('ADD TO PENDING PROMOTER');
			currSurvayMapValue.pmPending += Integer.valueOf(ar.get('expr0'));
		}
		//Promoter Clients - add due to new calc of types precentes in 24/11
		if((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R1Promoter').Value__c))
		{
			currSurvayMapValue.promoterClients += Integer.valueOf(ar.get('expr0'));
		}


	}

	private static void updaeRecoveryActFieldsInSurvayMap(AggregateResult ar, VO_SurvayTypeStat currSurvayMapValue)
	{
		System.debug('SFDC Type__c: ' + ar.get('Type__c') + '    ' + VO_Config__c.getValues('chartDisplayC2R3').Value__c);
		System.debug('SFDC Status__c: ' + ar.get('Status__c') + '    ' + VO_Config__c.getValues('chartDisplayC2R41').Value__c);
		System.debug('SFDC Status__c: ' + VO_Config__c.getValues('chartDisplayC2R42').Value__c + '    ' + VO_Config__c.getValues('chartDisplayC2R3').Value__c);
		System.debug('SFDC expr0: ' + ar.get('expr0') );
		//Recovery Act +New
		if((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R3').Value__c)
			&& 	(ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R41').Value__c))
		{
			currSurvayMapValue.raNew += Integer.valueOf(ar.get('expr0'));
		}

		//Recovery Act +pending
		if((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R3').Value__c) && 
			(ar.get('Status__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R42').Value__c) )
		{
			currSurvayMapValue.raPending += Integer.valueOf(ar.get('expr0'));
		}
		//Recovery Act -add due to new calc of types precentes in 24/11
		if((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R3').Value__c))
		{
			currSurvayMapValue.recoveryAct += Integer.valueOf(ar.get('expr0'));
		}

	}

	//private static void updateIfPromoterClient(AggregateResult ar, VO_SurvayTypeStat currSurvayMapValue)
	//{
	//	//NEED TO SHOW PROMOTER OR DELIGHTED
	//	System.debug('VO_Config__c chartDisplayC2R1Promoter' + VO_Config__c.getValues('chartDisplayC2R1Promoter').Value__c);
	//	System.debug('ar.get(Type__c)' + ar.get('Type__c')+'');
	//	if ((ar.get('Type__c')+'').equalsIgnoreCase(VO_Config__c.getValues('chartDisplayC2R1Promoter').Value__c))
	//	{
	//		currSurvayMapValue.isPromoterClients = true;
	//	}
	//}
	private static void updateAllTheTotals (Map<String, VO_SurvayTypeStat> survayTypeStatMap)
	{
		VO_SurvayTypeStat curr;
		for (String survayType :survayTypeStatMap.keySet())
		{
			curr = survayTypeStatMap.get(survayType);
			//MY 24.11.2015 : Comment due to new calc of types precentes in 24/11
			//curr.recoveryAct      = curr.raPending + curr.raNew ;
			//curr.delightedClients = curr.dcPending + curr.dcNew ;
			//curr.promoterClients  = curr.pmPending + curr.pmNew ;

			//End change MY 24.11.2015 
			curr.total            = curr.TNew + curr.TPending + curr.TClosed + curr.tNoAaction;
			System.debug('VO_Config__c chartDisplayC2R1Promoter' + VO_Config__c.getValues('chartDisplayPromoterSurType').Value__c);
			System.debug('curr.title :' + curr.title);
			System.debug(VO_Config__c.getValues('chartDisplayPromoterSurType').Value__c+'');

			if(curr.title != null)
			{
				if (curr.title.equalsIgnoreCase(VO_Config__c.getValues('chartDisplayPromoterSurType').Value__c+''))
				{
					curr.isPromoterClients = true;
				}
			}
		}

	}
	public static void updatesurvayTypeStatMap(Map<String, VO_SurvayTypeStat> survayTypeStatMap, List<AggregateResult> results)
	{
		System.debug('SFDC survayTypeStatMap: ' + survayTypeStatMap);
		System.debug('SFDC results: ' + results);
		VO_SurvayTypeStat currSurvayMapValue;
		for(AggregateResult ar :results)
		{
			System.debug('AR : '+ ar );
			System.debug('SFDC ar2: '+ ar.get('SurveyType__c') );
			if(survayTypeStatMap.containsKey(ar.get('SurveyType__c') +''))
			{   
				currSurvayMapValue = survayTypeStatMap.get(ar.get('SurveyType__c') +'');

				updaeTotalFieldsInSurvayMap(ar, currSurvayMapValue);
				updaeDelightedClientsFieldsInSurvayMap(ar, currSurvayMapValue);
				updaePromoterClientsFieldsInSurvayMap(ar, currSurvayMapValue);
				updaeRecoveryActFieldsInSurvayMap(ar, currSurvayMapValue);
				//updateIfPromoterClient(ar, currSurvayMapValue);

			}
			currSurvayMapValue = null;
		}
		updateAllTheTotals(survayTypeStatMap);
		System.debug('updatesurvayTypeStatMap: : ,' + survayTypeStatMap);
	}
}