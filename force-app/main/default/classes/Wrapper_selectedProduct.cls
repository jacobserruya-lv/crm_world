// Created by Balink 2017
// Description: Wrapper containes product Data that comes from WS ATG

public class Wrapper_selectedProduct {

   	@AuraEnabled Public String Description {set;get;}
    @AuraEnabled Public String LongDescription {set;get;}
    @AuraEnabled Public String DimensionsUnit {set;get;}
    @AuraEnabled Public Decimal Height {set;get;}
    @AuraEnabled Public Decimal Width {set;get;}
    @AuraEnabled Public Decimal Length {set;get;}
    @AuraEnabled Public Wrapper_MapProductData ColorData {set;get;}
    @AuraEnabled Public Wrapper_MapProductData MaterialData {set;get;}
    @AuraEnabled Public Wrapper_MapProductData SizeData {set;get;}
    @AuraEnabled Public String  Name {set;get;}
    
}