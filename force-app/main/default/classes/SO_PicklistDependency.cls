public with sharing class SO_PicklistDependency {
	/**
	 * Static part
	 */
	public static Map<string, Picklist_Dependency__c> picklistDependencyByName; 
	public static Map<string, Picklist_Dependency__c> picklistDependencyByOppCat; 
	public static Map<string, Picklist_Dependency__c> picklistDependencyByPRORCat; 

	public static final String OPP_ACCESSORY;
	public static final String PROR_ACCESSORY;
	public static final String OPP_REC_TYPE_NAME_ACCESSORY;

	public static final String OPP_LEATHER_GOOD;
	public static final String PROR_LEATHER_GOOD;
	public static final String OPP_REC_TYPE_NAME_LEATHER_GOOD;

	public static final String OPP_WATCH;
	public static final String PROR_WATCH;
	public static final String OPP_REC_TYPE_NAME_WATCH;

	private static final Boolean isInitialized;

	static {

		if(true != isInitialized) {
			picklistDependencyByName = Picklist_Dependency__c.getAll();

			picklistDependencyByOppCat = new Map<String, Picklist_Dependency__c>();
			picklistDependencyByPRORCat = new Map<String, Picklist_Dependency__c>();

			for(Picklist_Dependency__c oneDep : picklistDependencyByName.values()) {

				picklistDependencyByOppCat.put(oneDep.Opportunity_Category__c, oneDep);
				picklistDependencyByPRORCat.put(oneDep.Referential_Category__c, oneDep);
			}

			//accessory
			Picklist_Dependency__c accessory = picklistDependencyByName.get('Accessory');

			OPP_ACCESSORY 				= accessory.Opportunity_Category__c;
			PROR_ACCESSORY 				= accessory.Referential_Category__c;
			OPP_REC_TYPE_NAME_ACCESSORY = accessory.Opportunity_Record_Type__c;

			//Leather good
			Picklist_Dependency__c leather_good = picklistDependencyByName.get('Leather good');

			OPP_LEATHER_GOOD 				= leather_good.Opportunity_Category__c;
			PROR_LEATHER_GOOD 				= leather_good.Referential_Category__c;
			OPP_REC_TYPE_NAME_LEATHER_GOOD  = leather_good.Opportunity_Record_Type__c;

			//Watch
			Picklist_Dependency__c watch = picklistDependencyByName.get('Watch');

			OPP_WATCH 				= watch.Opportunity_Category__c;
			PROR_WATCH 				= watch.Referential_Category__c;
			OPP_REC_TYPE_NAME_WATCH = watch.Opportunity_Record_Type__c;

			isInitialized = true;
		}

		System.debug('isInitialized >> ' + isInitialized);
	}

	public static String retOppRecordTypeByProdCat(String prodCategory) {

		return picklistDependencyByOppCat.get(prodCategory).Opportunity_Record_Type__c;

	}

	/**
	 * None static part
	 */

	public SO_PicklistDependency(ApexPages.StandardController stdController) {

	}

	public SO_PicklistDependency getPickListDependencyHandler() { return this; }

	public String oppAccessory 				{ get{ return OPP_ACCESSORY;  } }
	public String prorAccessory 			{ get{ return PROR_ACCESSORY; } }
	public String oppRecTypeNameAccessory 	{ get{ return OPP_REC_TYPE_NAME_ACCESSORY; } }

	public String oppLeatherGood 			{ get{ return OPP_LEATHER_GOOD; } }
	public String prorLeatherGood 			{ get{ return PROR_LEATHER_GOOD; } }
	public String oppRecTypeNameLeatherGood { get{ return OPP_REC_TYPE_NAME_LEATHER_GOOD; } }

	public String oppWatch 					{ get{ return OPP_WATCH; } }
	public String prorWatch 				{ get{ return PROR_WATCH; } }
	public String oppRecTypeNameWatch 		{ get{ return OPP_REC_TYPE_NAME_WATCH; } }


	//Order Type Field in Opportunity
	public static final String ORDER_TYPE_SPO_MTO  		 = 'SPO/MTO';
	public static final String ORDER_TYPE_SPECIAL_ORDER  = 'Creation (Hardsided & Soft)';//previos 'Creation', 'Special order (Harsided & soft)', previos 'Creation'
	public static final String ORDER_TYPE_MTO_ON_CATALOG = 'MTO on Catalog (Hardsided)';	 //previos 'Hardsided out of MyPerso'	

	public String orderTypeSpoMto 		 { get { return SO_PicklistDependency.ORDER_TYPE_SPO_MTO; } } 
	public String orderTypeSpecialOrder  { get { return SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER; } }  //previos 'Creation'
	public String orderTypeMtoOnCatalog  { get { return SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG; } } //previos 'Hardsided out of MyPerso'
}