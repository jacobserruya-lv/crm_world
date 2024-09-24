global with sharing class BL_IWA_Products extends BL_WS_Request implements BL_WS_Interfaces.DispatchablePOST {

    global Object executePOST(){
        Map<String,Object> record = (Map<String,Object>) getRequestRecord();
        
        Object skus = record.get('skus');
        List<String> relatedSkus = (List<String>) JSON.deserialize(JSON.serialize(skus), List<String>.class);
        List<ProductCatalogue__c> catalogueProducts = WRDB_CreateAsset_Controller.getProductsBySkus(relatedSkus);

        return getProductCatalogMap(catalogueProducts);
    }

    public static Object getProductCatalogMap(List<ProductCatalogue__c> catalogueProducts ){
        Map<String,Map<String, String>> productsMap = new Map<String,Map<String, String>>();

        for (ProductCatalogue__c p : catalogueProducts) {
            Map<String,String> product = new Map<String,String> {
                'name' => p.Name,
                'contentUrl' => String.isNotBlank(p.Image1Url__c) ? p.Image1Url__c : 'https://www.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louisvuitton--' + p.SKU__c + '_PM2_Front%20view.png',
                'sku' => p.SKU__c
            };

            productsMap.put(p.SKU__c, product);
        }

        return productsMap;
    }

}