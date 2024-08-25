public with sharing class Wrapper_ProductCatalog {
    @AuraEnabled public String id {set; get;}
    @AuraEnabled public String name {set; get;}
    @AuraEnabled public String description {set; get;}
    @AuraEnabled public String detailedDescription {set; get;}
    @AuraEnabled public Decimal heightCm {set; get;}
    @AuraEnabled public Decimal widthCm {set; get;}
    @AuraEnabled public String sku {set; get;}
    @AuraEnabled public String macroColorName {set; get;}
    @AuraEnabled public Decimal lengthCm {set; get;}
    @AuraEnabled public Double price {set; get;}
    @AuraEnabled public String summaryCurrency {set; get;}
    @AuraEnabled public Decimal heightInch {set; get;}
    @AuraEnabled public Decimal widthInch {set; get;}
    @AuraEnabled public Decimal lengthInch {set; get;}
    @AuraEnabled public Boolean inCm {set; get;}
    @AuraEnabled public String productGroup {set; get;}
    @AuraEnabled public Boolean persoProduct {set; get;}
     @AuraEnabled public Boolean isPersoProduct {set; get;}
    @AuraEnabled public Boolean stockRequest {set; get;}
    @AuraEnabled public Boolean MiyCom {set; get;}
    @AuraEnabled public String status {set; get;}
    @AuraEnabled public String pdfUrl {set; get;}
    @AuraEnabled public Date pdfUrlDate {set; get;}
    @AuraEnabled public String defaultSku {set;get;}
    @AuraEnabled public String macroColorId {set;get;}
    @AuraEnabled public String size {set;get;}
    @AuraEnabled public String productSize {set;get;}
    @AuraEnabled public String materialTypeName {set;get;}
    @AuraEnabled public String MarketingColorName {set;get;}
    @AuraEnabled public String MarketingColorId {set;get;}
    @AuraEnabled public String AssociateMaterials {set; get;}

    @AuraEnabled public String AssociatedModelSize {set; get;}
    @AuraEnabled public String AssociateColors {set; get;}
    @AuraEnabled public String sizeId {set; get;}
    @AuraEnabled public String materialImg {set; get;}
    @AuraEnabled public String colorImg {set; get;}
    @AuraEnabled public String season  {set; get;}
    @AuraEnabled public String longSku  {set; get;}
    @AuraEnabled public String department  {set; get;}
    @AuraEnabled public String ShoeWidth  {set; get;}

    @AuraEnabled public String image1Url {set; get;}
    @AuraEnabled public String image2Url {set; get;}
    @AuraEnabled public String image3Url {set; get;}
    @AuraEnabled public String image4Url {set; get;}
    @AuraEnabled public String image5Url {set; get;}

    @AuraEnabled public String ModelMaterial {set; get;}
    @AuraEnabled public String Weaving {set; get;}
    @AuraEnabled public String Dyeingprinting {set; get;}
    @AuraEnabled public String Manufacturingfp {set; get;}
    @AuraEnabled public String Stiching {set; get;}
    @AuraEnabled public String Assembly {set; get;}
    @AuraEnabled public String Finition {set; get;}
    @AuraEnabled public Decimal Recycledfp {set; get;}
    @AuraEnabled public String Synth {set; get;}
    @AuraEnabled public String isRecyclable {set; get;}
    @AuraEnabled public Decimal Recyclabilityfp {set; get;}
    @AuraEnabled public String Dangeroussubstances {set; get;}
    @AuraEnabled public Decimal Preciousmetals {set; get;}
    @AuraEnabled public Decimal Rareearth {set; get;}
    
    @AuraEnabled public String OrderableEMEA {set; get;}
    @AuraEnabled public String OrderableSouthAsia {set; get;}
    @AuraEnabled public String OrderableNorthAsia  {set; get;}
    @AuraEnabled public String OrderableNorthAmerica {set; get;}
    @AuraEnabled public String OrderableMiddleEast {set; get;}
    @AuraEnabled public String OrderableJapan {set; get;}

    @AuraEnabled public Boolean engravingEnabled {set; get;}
    @AuraEnabled public String engravingType {set; get;}


    @AuraEnabled public Boolean CappedSku {set;get;}

    @AuraEnabled public String AssociateSkinMaterials {set; get;}
    @AuraEnabled public String SkinMaterial {set; get;}

    
    @AuraEnabled
    public static List<Wrapper_ProductCatalog> convertToProductCatalogWrappers(List<ProductCatalogue__c> productSObjs, Store__c defaultStore) {
        List<Wrapper_ProductCatalog> productWrappers = new List<Wrapper_ProductCatalog>();
        User currentUser = DAL_ProductCatalog.getUser();
        
        if(productSObjs != null && productSObjs.size() > 0) {
            for(ProductCatalogue__c productSobj : productSObjs) {
                system.debug('my obj : ' +productSobj );
                if(productSobj != null) {
                    productWrappers.add(convertToProductCatalogWrapper(productSobj, defaultStore));
                }
            }
        }
        return productWrappers;
    }
    
    @AuraEnabled
    public static List<ProductCatalogue__c> convertToProductCatalogSObjs(List<Wrapper_ProductCatalog> productObjs) {
        List<ProductCatalogue__c> productsSobjs = new List<ProductCatalogue__c>(); 
        
        if(productObjs != null && productObjs.size() > 0) {
            for(Wrapper_ProductCatalog productWrapper : productObjs) {
                if(productWrapper != null) {
                    productsSobjs.add(convertToProductCatalogSObj(productWrapper));
                }
            }
        }
        return productsSobjs;
    }
    
    @AuraEnabled
    public static ProductCatalogue__c convertToProductCatalogSObj(Wrapper_ProductCatalog productObj) {
        ProductCatalogue__c productSobj = new ProductCatalogue__c();
                
        
        
        return productSobj;
    }
    
    @AuraEnabled 
    public static Wrapper_ProductCatalog convertToProductCatalogWrapper(ProductCatalogue__c productSObj, Store__c defaultStore) {
        system.debug('convertToProductCatalogWrapper productSObj :  ' + productSObj);
        Wrapper_ProductCatalog productWrapper = new Wrapper_ProductCatalog();
        
        productWrapper.id = productSObj.Id;
        
        productWrapper.name = productSObj.Name;
        
        if (productSObj.SPO_Category__c == 'BELTS' && productSObj.ProductReferential__c != null)
             productWrapper.name = productSObj.ProductReferential__r.Name;
        else if ((productSObj.ProductGroup__c == 'Souliers' || productSObj.ProductGroup__c == 'Ready to wear') &&  productSObj.SizeName__c != '')
        	productWrapper.name +=' - '+ productSObj.SizeName__c;



        productWrapper.status = productSObj.ProductReferential__r.Status__c;

        system.debug('category ' + productSObj.Category__c);
        system.debug('category 2D ' + productSObj.SPO_Category__c);
        if (productSObj.IsPersoProduct__c == true && productSObj.StockRequest__c == false) {
            productWrapper.persoProduct = true;
        }

        productWrapper.MiyCom = productSObj.MiyCom__c? true : false;
        productWrapper.stockRequest = productSObj.StockRequest__c? true : false;
        productWrapper.description = productSObj.Description__c;
        productWrapper.detailedDescription = productSObj.DetailedDescription__c; 
        productWrapper.heightCm = productSObj.HeightCm__c;
        productWrapper.widthCm = productSObj.WidthCm__c;
        productWrapper.sku = productSObj.SKU__c;
        productWrapper.macroColorName = productSObj.MacroColorName__c;
        productWrapper.lengthCm = productSobj.lengthCm__c;
        productWrapper.heightInch = productSObj.HeightInch__c;
        productWrapper.widthInch = productSObj.WidthInch__c; 
        productWrapper.lengthInch = productSobj.LengthInch__c;
        productWrapper.productGroup = productSobj.ProductGroup__c;
        productWrapper.isPersoProduct = productSobj.IsPersoProduct__c;
        productWrapper.pdfUrl = productSobj.Pdf_Url__c;
        productWrapper.pdfUrlDate = productSobj.Pdf_Url_Date__c;
        productWrapper.defaultSku = productSobj.defaultSku__c;
        productWrapper.macroColorId = productSobj.MacroColorId__c;
        productWrapper.size = productSObj.SizeName__c;
        productWrapper.productSize = productSObj.en_E1_size__c;
        productWrapper.materialTypeName = productSObj.TypeName__c;
        productWrapper.MarketingColorName = productSObj.MarketingColorName__c;
        productWrapper.MarketingColorId = productSObj.MarketingColorId__c;
        productWrapper.AssociateMaterials = productSObj.AssociateMaterials__c;

        productWrapper.AssociateColors = productSObj.AssociateColors__c;
        productWrapper.AssociatedModelSize = productSObj.AssociatedModelSize__c;
        productWrapper.sizeId = productSObj.SizeId__c;
        productWrapper.materialImg = productSObj.material_image__c;
        productWrapper.colorImg = productSObj.color_image__c;
        productWrapper.season  = productSObj.Season__c ;
        productWrapper.department  = productSObj.ProductReferential__r.Departement__c ;
        productWrapper.ShoeWidth  = productSObj.ShoeWidth__c ;

        productWrapper.longSku  = productSObj.longSkuId__c ;
        
        productWrapper.image1Url = productSObj.Image1Url__c;
        productWrapper.image2Url = productSObj.Image2Url__c;
        productWrapper.image3Url = productSObj.Image3Url__c;
        productWrapper.image4Url = productSObj.Image4Url__c;
        productWrapper.image5Url = productSObj.Image5Url__c;
        
        productWrapper.ModelMaterial = productSObj.Model_material__c;
        productWrapper.Weaving = productSObj.Weaving__c;
        productWrapper.Dyeingprinting = productSObj.Dyeingprinting__c;
        productWrapper.Manufacturingfp = productSObj.Manufacturingfp__c;
        productWrapper.Stiching = productSObj.Stiching__c;
        productWrapper.Assembly = productSObj.Assembly__c;
        productWrapper.Finition = productSObj.Finition__c;
        productWrapper.Recycledfp = productSObj.Recycledfp__c;
        productWrapper.Synth = productSObj.Synth__c;
        productWrapper.Recyclabilityfp = productSObj.Recyclabilityfp__c;
        productWrapper.isRecyclable = productSObj.isRecyclable__c;
        productWrapper.Dangeroussubstances = productSObj.Dangeroussubstances__c;
        productWrapper.Preciousmetals = productSObj.Preciousmetals__c;
        productWrapper.Rareearth = productSObj.Rareearth__c;

        productWrapper.AssociateSkinMaterials = productSObj.AssociateSkinMaterials__c;
        productWrapper.SkinMaterial = (String)productSObj.get('SkinMaterialLabel');

        productWrapper.engravingEnabled = productSObj.engravingEnabled__c;
        productWrapper.engravingType = productSObj.engravingType__c;
        


       if(productSObj.ProductReferential__c != null){
           productWrapper.OrderableEMEA = productSObj.ProductReferential__r.OrderableEMEA__c;
           productWrapper.OrderableJapan = productSObj.ProductReferential__r.OrderableJapan__c;
           productWrapper.OrderableMiddleEast = productSObj.ProductReferential__r.OrderableMiddleEast__c;
           productWrapper.OrderableNorthAmerica = productSObj.ProductReferential__r.OrderableNorthAmerica__c;
           productWrapper.OrderableNorthAsia = productSObj.ProductReferential__r.OrderableNorthAsia__c;
           productWrapper.OrderableSouthAsia = productSObj.ProductReferential__r.OrderableSouthAsia__c;
       }

        productWrapper.CappedSku = productSObj.Capped_Hot_SKU__c;


        return productWrapper;
    }

    @AuraEnabled 
    public static Wrapper_ProductCatalog convertPRToProductCatalogWrapper(ProductReferential__c productSObj) {
        system.debug('productSObj ' + productSObj);
        Wrapper_ProductCatalog productWrapper = new Wrapper_ProductCatalog();
        
        productWrapper.id = productSObj.Id;
        
        productWrapper.name = productSObj.Name;
        
        /*if (productSObj.SPO_Category__c == 'BELTS' && productSObj.ProductReferential__c != null)
             productWrapper.name = productSObj.ProductReferential__r.Name;
        else if ((productSObj.ProductGroup__c == 'Souliers' || productSObj.ProductGroup__c == 'Ready to wear') &&  productSObj.SizeName__c != '')
        	productWrapper.name +=' - '+ productSObj.SizeName__c;*/



        productWrapper.status = productSObj.Status__c;

        /*system.debug('category ' + productSObj.Category__c);
        system.debug('category 2D ' + productSObj.SPO_Category__c);
        if (productSObj.IsPersoProduct__c == true && productSObj.StockRequest__c == false) {
            productWrapper.persoProduct = true;
        }*/

        //productWrapper.MiyCom = productSObj.MiyCom__c? true : false;
        //productWrapper.stockRequest = productSObj.StockRequest__c? true : false;
        productWrapper.description = productSObj.Description__c;
      //productWrapper.detailedDescription = productSObj.DetailedDescription__c; 
        productWrapper.heightCm = productSObj.Height__c;
        productWrapper.widthCm = productSObj.Witdth__c;
        productWrapper.sku = productSObj.SKUCode__c;
        productWrapper.macroColorName = productSObj.MacroColor__c;
        productWrapper.lengthCm = productSobj.Length__c;
        /*productWrapper.heightInch = productSObj.HeightInch__c;
        productWrapper.widthInch = productSObj.WidthInch__c;
        productWrapper.lengthInch = productSobj.LengthInch__c;*/
        productWrapper.productGroup = productSobj.Group__c;
        //productWrapper.persoProduct = productSobj.IsPersoProduct__c;*/

        
        productWrapper.image1Url = productSObj.SPO_ImageLink1FrontView__c;
        productWrapper.image2Url = productSObj.SPO_ImageLink2SideView__c;
        productWrapper.image3Url = productSObj.SPO_ImageLink3OtherView__c;
        productWrapper.image4Url = productSObj.SPO_ImageLink4InteriorView__c	;
        productWrapper.image5Url = productSObj.SPO_ImageLink5OtherView2__c	;

       
        productWrapper.OrderableEMEA = productSObj.OrderableEMEA__c;
        productWrapper.OrderableJapan = productSObj.OrderableJapan__c;
        productWrapper.OrderableMiddleEast = productSObj.OrderableMiddleEast__c;
        productWrapper.OrderableNorthAmerica = productSObj.OrderableNorthAmerica__c;
        productWrapper.OrderableNorthAsia = productSObj.OrderableNorthAsia__c;
        productWrapper.OrderableSouthAsia = productSObj.OrderableSouthAsia__c;
        

        
        return productWrapper;
    }

    public static List<Wrapper_ProductCatalog> convertToProductCatalogWrappers(list<Map<String, Object>> gastonObjs) {
        List<Wrapper_ProductCatalog> wrappers = new List<Wrapper_ProductCatalog>();
        for(Map<String, Object> gastonObj : gastonObjs){
            Wrapper_ProductCatalog productWrapper = new Wrapper_ProductCatalog();
            productWrapper.sku = (String) gastonObj.get('skuId');
            productWrapper.name = (String) gastonObj.get('en_E1_commercialName');
            productWrapper.image1Url = (String) gastonObj.get('en_E1_images_url');
            wrappers.add(productWrapper);
        }
        return wrappers;
    }

    public static Wrapper_ProductCatalog convertToProductCatalogWrapper(Map<String, Object> gastonObj) {
            Wrapper_ProductCatalog productWrapper = new Wrapper_ProductCatalog();
            productWrapper.sku = (String) gastonObj.get('skuId');
            productWrapper.name = (String) gastonObj.get('en_E1_commercialName');
            productWrapper.image1Url = (String) gastonObj.get('en_E1_images_url');
            return productWrapper;
    }
    
}