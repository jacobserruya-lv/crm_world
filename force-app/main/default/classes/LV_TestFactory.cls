/** @Description
* Test factory class for all Louis Vuitton apps
*
**/
public with sharing class LV_TestFactory {


	// Create a user
    public static User createUser( String lName, String uName, String alias, Id profileId )
    {

        uName= '' + UserInfo.getOrganizationId() + System.now().millisecond() + uName;
        return( new User(
            username = uName,
            email = uName,
            alias = alias,
            profileId = profileId,
            emailEncodingKey = 'UTF-8',
            firstName = 'John',
            lastName = lName,
            localeSIDKey = 'en_US',
            languageLocaleKey = 'en_US',
            timezoneSIDKey = 'America/Los_Angeles'
        ));
    }

	// Create a client
    public static Account createAccount()
    {  
        Account a = new Account();
        a.LastName = 'Europe' + String.valueOf(System.now());
        a.FirstName='Louis';
        a.Salutation = 'Ms';
        a.Segmentation__pc='VIC';
        a.PrimaryAddressLine1__pc='Adresse ligne 1';
        a.PrimaryAddressLine2__pc='Adresse ligne 2';
        a.PrimaryAddressLine3__pc ='Adresse ligne 3';
        a.PrimaryCity__pc='Paris';
        a.PersonEmail='louis.vuittontest@lv.com';
        a.PrimaryZipCode__pc='75000';
        a.PrimaryCountry__pc='France';
        a.PassportNumber__pc='ABC12345';


        return a;
    }
	// Create a store
	public static Store__c createStore(String name, String storeType, String storeCode, String country, String curr,
										String status)
	{
		Store__c st = new Store__c(Name = name,
								   StoreType__c = storeType, 
								   StoreCountry__c = country,
								   Currency__c = curr,
								   RetailStoreId__c = storeCode,
								   Status__c = status
		);

		return st;
	}

	// create a product catalog
	public static ProductCatalogue__c createProductCatalog(String name, String skuCode, Integer approvalTime, 
															Integer manufTime, Integer distribTime, String productGroup)
	{
		ProductCatalogue__c pc = new ProductCatalogue__c(Name = name, 
														 SKU__c = skuCode,
														 LeadTimeApproval__c = approvalTime,
														 LeadTimeManufacturing__c = manufTime,
														 LeadTimeDistribution__c = distribTime,
														 ProductGroup__c = productGroup);
		return pc;
	}

	// create a product referential
	public static ProductReferential__c createProductReferential(String name, String skuCode)
	{
		ProductReferential__c pr = new ProductReferential__c(Name = name,
															 SKUCode__c	= skuCode);
		return pr;
	}

	// create an order
	public static Opportunity createOrder(String orderName, String orderStatus, ID productID, Id storeId, id clientId,
											String orderType, String productCategory, string appSource)
	{
		Date closeDate = System.today().adddays(100);
		Opportunity opp = new Opportunity(Name = orderName,
											StageName = orderStatus,
											ApplicationSource__c = appSource,
											SPO_BaseSKURefmodelSKU__c = productID, // for SPO only
											AccountId = clientId, // for non display order
											SPO_Store__c = storeId,
											SPO_OrderType__c = orderType, // for SPO only
											SPO_ProductCategory__c = productCategory, // for SPO only
											CloseDate = closeDate
										);
		return opp;
	}

	// create a firm order
	public static SPO_FirmOrder__c createFirmOrder(Id orderID, Integer lineNumber, id pCatalogId )
	{

		SPO_FirmOrder__c fo = new SPO_FirmOrder__c(SPO_BriefName__c = orderID,
													LineNumber__c = lineNumber,
													ProductCatalogue__c = pCatalogId // for PERSO and e-CO
												  );
		return fo;
	}

	// Create a lead time
	public static MIY_LeadTime__c createLeadTime(String country, String pGroup, Integer exoDistribTime, 
													Integer nonExoDistribTime)
	{
		MIY_LeadTime__c lt = new MIY_LeadTime__c(Country__c = country,
													Product_Group__c = pGroup,
													Exotic_Distribution_Lead_Time_in_days__c = exoDistribTime,
													Non_Exotic_Distribution_LT_in_days__c = nonExoDistribTime);
		return lt;
	}

	public static MIY_Workshop__c createWorkshop(String creationType, String Exotic, String OrderType, String ProductCategory,
												 Integer ProductionTime,  String workshop, String source)
	{
		MIY_Workshop__c ws =  new MIY_Workshop__c(Creation_Type__c = creationType,
															Exotic__c = Exotic,
															Order_Type__c = OrderType,
															Product_Category__c = ProductCategory,
				                                            Production_Time_In_Days__c = ProductionTime,
															Workshop__c = workshop,
															Source__c = source);
		return ws;
	}
}