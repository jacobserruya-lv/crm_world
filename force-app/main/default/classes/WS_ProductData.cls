//Created by: Balink 2018
//Description: ATG webservice for varaitions

public class WS_ProductData {

    //call ws ATG
    public static Wrapper_ProductVariation getProductData(String sku, String DigitalStore) {
        try {
            //Custom setting that hold parameters for the request
            //String DigitalStoreApiLink = (String)Catalogue_Settings__c.getInstance(System.Label.WSCatalogueTECHUserId).get(DigitalStore+'__c');
            
           // System.debug('DigitalStoreApiLink' + DigitalStoreApiLink);
            Catalogue_Settings__c CS = Catalogue_Settings__c.getInstance(System.Label.WSCatalogueTECHUserId);
            Http httpProtocol = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('callout:WS_Product_Data_'+DigitalStore);
            
            //httpRequest.setEndpoint(DigitalStoreApiLink);
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(120000);
            httpRequest.setHeader('Accept','application/json');
            httpRequest.setHeader('Content-Type','application/json');
            
            String UserAgent = CS.User_Agent__c;
            system.debug('UserAgent ' +UserAgent);
            if(UserAgent!= null) {
            	httpRequest.setHeader('User-Agent',UserAgent);
            }
            /*String PrpUsername = CS.WS_ATG_Username__c;
            String PrpPass = CS.WS_ATG_Password__c;
            if(PrpUsername != null && PrpPass != null) {
                String authorizationHeader =
                        'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(PrpUsername + ':' + PrpPass));
                System.debug('Auth ' + authorizationHeader);

                httpRequest.setHeader('Authorization', authorizationHeader);
            }*/
            
            system.debug('sending sku : ' + sku);
            
            httpRequest.setBody('{"skuIds": ["'+sku+'"],"chapters":["general","details","commerce","variances","hierarchy","modelVariation","crossSell","personalization"]}');
            HttpResponse httpResponse = null;
            system.debug('sending varaition start ' + DateTime.now());
            httpResponse = httpProtocol.send(httpRequest);   
            System.debug('httpResponse ' + httpResponse);  
            
            system.debug(httpResponse.getBody());
            system.debug('sending variation end ' + DateTime.now());
            Wrapper_ProductVariation Variation = getVariationData(httpResponse.getBody());
            system.debug('sending variation map ' + DateTime.now());
            return Variation;
        }
        catch(Exception e) {
                Ctrl_ProductCatalog.log('WS_ProductData', e);
                return null;
        }

    }   

    //parse return answer from ws
    public static Wrapper_ProductVariation getVariationData(String jsonVariation) {
        jsonVariation.replace('"currency":', '"currency_price":');
        ProductDataJsonToApex productVariationParse =  ProductDataJsonToApex.parse(jsonVariation);
        
        system.debug('productVariationParse.content ' + productVariationParse.content);
        Wrapper_ProductVariation productVariationW = new Wrapper_ProductVariation();
        Wrapper_selectedProduct selectedProduct = new Wrapper_selectedProduct();
       
        List<Wrapper_MapProductData> sizeVaraitions = new List<Wrapper_MapProductData>();
        List<Wrapper_MapProductData> materialVaraitions = new List<Wrapper_MapProductData>();
        List<Wrapper_MapProductData> colorVaraitions = new List<Wrapper_MapProductData>();
        List<Wrapper_MapProductData> mayLike = new List<Wrapper_MapProductData>();
        List<Wrapper_MapProductData> family = new List<Wrapper_MapProductData>();
        
        Set<String> variantSKU = new Set<String>();
        
        if (productVariationParse.content != null){
            
            for(ProductDataJsonToApex.Content data:productVariationParse.content) {
                
                
                //Closed for now, so we could get answer from service
                if (data.status == 'NOT_FOUND') {
                    return null;
                }

                String productName = data.name;
                
                ProductDataJsonToApex.Detail detail = data.detail;
                if(detail != null ) {
                    selectedProduct.LongDescription = detail.longDescription;
                    selectedProduct.DimensionsUnit = detail.dimensionsUnit;
                    selectedProduct.Height = detail.height != null ? Decimal.valueOf(detail.height) : 0;
                    selectedProduct.Width = detail.width != null ? Decimal.valueOf(detail.width) : 0;
                    selectedProduct.Length = detail.length != null ? Decimal.valueOf(detail.length) : 0;
                }
                selectedProduct.Name = productName;
                String productMaterial, productColor;
                ProductDataJsonToApex.General general = data.general;

                selectedProduct.Description = general.description;

                Wrapper_MapProductData materialData = new Wrapper_MapProductData();
                materialData.Sku = data.skuId;
                ProductDataJsonToApex.Material material = general.material;
                if(material != null) {
                    productMaterial = material.value;
                    materialData.Value = material.icon;
                }
                materialData.ValueName = productMaterial;
                selectedProduct.MaterialData = materialData;

                Wrapper_MapProductData colorData = new Wrapper_MapProductData();
                colorData.Sku = data.skuId;
                ProductDataJsonToApex.Material marketingColor = general.marketingColor;
                if (marketingColor != null) {
                    productColor = marketingColor.value;
                    colorData.Value = marketingColor.icon;
                }
                colorData.ValueName = productColor;
                selectedProduct.ColorData = colorData;


                String productSize = null;
                if(general.size != null) {
                    ProductDataJsonToApex.Material size = general.size;
                    productSize = size.value;
                }
                if (productSize == null) {
                    productSize = productName;
                }

                Wrapper_MapProductData sizeData = new Wrapper_MapProductData();
                sizeData.Sku = data.skuId;
                sizeData.ValueName = productSize;
                selectedProduct.SizeData = sizeData;

                List<ProductDataJsonToApex.ModelVariation> modelVariations = data.modelVariation;
                if(modelVariations != null) {
                    for(ProductDataJsonToApex.ModelVariation modelVariation:modelVariations){
                        ProductDataJsonToApex.Material variationMaterial = modelVariation.material;
                        ProductDataJsonToApex.Material variationSize = modelVariation.modelSize;
                        if (variationMaterial.value != productMaterial) {
                            Wrapper_MapProductData wrapperMap = new Wrapper_MapProductData();
                            wrapperMap.Sku = modelVariation.skuId;
                            wrapperMap.Value = variationMaterial.icon;
                            wrapperMap.ValueName = variationMaterial.value;
                            materialVaraitions.add(wrapperMap);
                            variantSKU.add(modelVariation.skuId);
                        }
                        
                        if (variationSize.value != productSize) {                     
							Wrapper_MapProductData wrapperMap = new Wrapper_MapProductData();
                            wrapperMap.sku = modelVariation.skuId;
                            wrapperMap.value = variationSize.value;
                            sizeVaraitions.add(wrapperMap);
                            variantSKU.add(modelVariation.skuId);
                        }
                    }
                }
                
                List<ProductDataJsonToApex.Variances> variances = data.variances;

                if(variances != null) {
                    for(ProductDataJsonToApex.Variances variance:variances){
                        ProductDataJsonToApex.Material variationColor = variance.marketingColor;
                        ProductDataJsonToApex.Material variationSize = variance.size;
                        if (variationColor != null  && variationSize != null) {
                            if (variationColor.value == productColor) {
                                Wrapper_MapProductData wrapperMap = new Wrapper_MapProductData();
                                wrapperMap.Sku = variance.skuId;
                                wrapperMap.Value = variationSize.value;
                                sizeVaraitions.add(wrapperMap);
                                variantSKU.add(variance.skuId);
                            }
                            else if (variationSize.value == productSize) {
                                Wrapper_MapProductData wrapperMap = new Wrapper_MapProductData();
                                wrapperMap.Sku = variance.skuId;
                                wrapperMap.Value = variationColor.icon;
                                wrapperMap.ValueName = variationColor.value;
                                colorVaraitions.add(wrapperMap);
                                variantSKU.add(variance.skuId);
                            }
                        }
                        else if (variationColor != null) {
                        	Wrapper_MapProductData wrapperMap = new Wrapper_MapProductData();
                            wrapperMap.Sku = variance.skuId;
                            wrapperMap.Value = variationColor.icon;
                            wrapperMap.ValueName = variationColor.value;
                            colorVaraitions.add(wrapperMap);  
                            variantSKU.add(variance.skuId);
                        }
                        else if (variationSize != null) {
                            Wrapper_MapProductData wrapperMap = new Wrapper_MapProductData();
                            wrapperMap.Sku = variance.skuId;
                            wrapperMap.Value = variationSize.value;
                            sizeVaraitions.add(wrapperMap);
                            variantSKU.add(variance.skuId);
                        }
                    }
                }
                
                ProductDataJsonToApex.CrossSell crossSell = data.CrossSell;
                if(crossSell != null) {
               		List<ProductDataJsonToApex.RelatedSku> familySku = crossSell.familySku; 
                    if(familySku != null) {
                        for(ProductDataJsonToApex.RelatedSku fSku : familySku) {
                            Wrapper_MapProductData wrapperMap = new Wrapper_MapProductData();
                            wrapperMap.Sku = fSku.skuId;
                            wrapperMap.Value = fSku.mainMediaUrl;
                            family.add(wrapperMap);
                        }
                    }
                    List<ProductDataJsonToApex.RelatedSku> relatedSku = crossSell.relatedSku; 
                    if(relatedSku != null) {
                        for(ProductDataJsonToApex.RelatedSku rSku : relatedSku) {
                            Wrapper_MapProductData wrapperMap = new Wrapper_MapProductData();
                            wrapperMap.Sku = rSku.skuId;
                            wrapperMap.Value = rSku.mainMediaUrl;
                            mayLike.add(wrapperMap);
                        }
                    }
                }
                ProductDataJsonToApex.Commerce commerce = data.Commerce;
                if(commerce != null) {
                    productVariationW.price = commerce.price;
                    productVariationW.currencyCoin = commerce.currency_price;
                }
            }
            if(!sizeVaraitions.isEmpty())
            	productVariationW.Size = sizeVaraitions;
            if(!materialVaraitions.isEmpty())
            	productVariationW.Material = materialVaraitions;
            if(!colorVaraitions.isEmpty())
            	productVariationW.Color = colorVaraitions; 
            if(!mayLike.isEmpty())
            	productVariationW.RelatedSku = mayLike;
            if(!family.isEmpty())
            	productVariationW.FamilySku = family;
            if(!variantSKU.isEmpty())
                productVariationW.VariantSKU = variantSKU;
            productVariationW.selectedProduct = selectedProduct;
            
            system.debug('productVariationW '+ productVariationW);
            return productVariationW;
        }
        else{
        	return null;
        }
    }
}