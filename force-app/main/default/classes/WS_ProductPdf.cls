public class WS_ProductPdf {

    
	public static String getProductPdfFile(String Sku) {
		try { 

            String urlParams = 'sku='+Sku;
            Http httpProtocol = new Http();
			HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(
            String.format('callout:ProductCatalogProductPdf/{0}?{1}',
                        new String[]{'api', urlParams})
            );
            httpRequest.setMethod('GET');
			httpRequest.setTimeout(120000);
			httpRequest.setHeader('Encoding', 'UTF-8');
			httpRequest.setHeader('Accept', 'application/json');
			httpRequest.setHeader('Content-Type', 'application/json');
			HttpResponse httpResponse = null;
			httpResponse = httpProtocol.send(httpRequest);
            String Link = getPdfLink(httpResponse.getBody());
			return Link;

        }catch (Exception e) {
			Ctrl_ProductCatalog.log('WS_ProductPdf', e);
			return '';
		}
    }

	public static String getPdfLink(String JsonFile) {
		List<ProductFicheArguToApex> ListFiles = ProductFicheArguToApex.parse(JsonFile);
		//system.debug('productPdf ' + ListFiles);
		for(ProductFicheArguToApex file:ListFiles){
			if(file.assets != null){
                for (ProductFicheArguToApex.Assets  assets:file.assets){
                   if((assets.path).endsWith('pdf')){
                       return assets.path;
                    }
                }
            }
		}
		return '';


	}


}