//Created by: Balink 2018
// Description: Wrapper Containes the restuns valus of WS ATG  for use in "Prodct Varaition" Component

public class Wrapper_ProductVariation {

    @AuraEnabled public List<Wrapper_MapProductData> Size {set;get;}	
    @AuraEnabled public List<Wrapper_MapProductData> Material {set;get;}
    @AuraEnabled Public List<Wrapper_MapProductData> Color {set;get;}
    @AuraEnabled Public List<Wrapper_MapProductData> RelatedSku {set;get;}
    @AuraEnabled Public List<Wrapper_MapProductData> FamilySku {set;get;}
    @AuraEnabled Public Wrapper_selectedProduct SelectedProduct {set;get;}
    @AuraEnabled Public Set<String> VariantSKU {set;get;}
    @AuraEnabled public Double price {set; get;}
    @AuraEnabled public String currencyCoin {set; get;}


    
    
    public Wrapper_ProductVariation() {
        Size = null;
        Material = null;
        Color = null;
        RelatedSku = null;
        VariantSKU=null;
        FamilySku=null;
        currencyCoin=null;
        price=-1;
    }
}