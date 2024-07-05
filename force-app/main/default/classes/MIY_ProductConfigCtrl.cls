public class MIY_ProductConfigCtrl {
	public class MyException extends Exception {}

	public static List < ProductConfigurationDetail__c > getFluidDetails(String recipeId) {
		Map < String, Object > fluidData = MIY_ProductConfigCtrl.getFluidDataFromRecipeId(recipeId);
		List < ProductConfigurationDetail__c > parsedDetails = MIY_ProductConfigCtrl.parseFluidAttributes(fluidData, false);
		List < ProductConfigurationDetail__c > resultDetails = new List < ProductConfigurationDetail__c > ();

		/* Only keep non-null details */
		/* Check and create a configuration detail if the "detail.Sku__c" is null or if the "detail.hasDoesNotExist__c"is true  to track if the recipe Id is invalid */ 
		for (ProductConfigurationDetail__c detail: parsedDetails) {
			
			if (detail.Value__c != null || detail.Sku__c == 'empty') {
				resultDetails.add(detail);
			}
		}
		
		return resultDetails;
	}

	private static Map < String, Object > getFluidDataFromRecipeId(String recipeId) {
		ProductSettings__c config = ProductSettings__c.getInstance();
		String url = config.FluidApiUrl__c +
			recipeId +
			'?api-key=' + config.FluidApiKey__c +
			'&locale=' + config.FluidApiLocale__c +
			'&include=localized_configuration,extended_attributes';


		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setTimeout(60000); //sets maximum timeout
		req.setMethod('GET');
		// Send the request, and return a response
		Http h = new Http();
		HttpResponse res = h.send(req);
		String str = (String) res.getBody();
    
		 /*if(str.contains('"error"')&& ( str.contains('"not found on DynamoDB. Got Error: Bad request"') || str.contains('"conflict"'))){
			 					 throw new MyException('empty recipe ID ' + recipeId);
            }*/
		
		return (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());


	}
	public static List < ProductConfigurationDetail__c > parseFluidAttributes(Map < String, Object > attrs, Boolean isChinaURL) {
		/* Translated from JS on MIY app (helpers/fluid.js) - Daniel Tal-Or 2019-05-21 */
		Map < String, ProductConfigurationDetail__c > attributes = new Map < String, ProductConfigurationDetail__c > ();
		String sku;

		//NY MIY - 1615 & MIY-1644 by Avigail
		Map < String, Object > custom_attributes = (Map < String, Object > ) attrs.get('custom');
		Map < String, Object > jde_attributes = new Map < String, Object > ();
		Map < String, Object > macro_components_attributes = new Map < String, Object > ();
		List < Object > listSku = new List < Object > ();

		if (custom_attributes != null && !custom_attributes.isEmpty() ) {
			jde_attributes = (Map < String, Object > ) custom_attributes.get('jde');
			listSku = (List < Object > ) custom_attributes.get('skus');
			macro_components_attributes = (Map < String, Object > ) custom_attributes.get('macro_components');

		}

		Boolean doesNotExist = false;
		if (  jde_attributes != null && !jde_attributes.isEmpty()) {

			for (Object jde: jde_attributes.values()) {
				if (String.valueOf(jde) == 'DOES NOT EXIST' || String.valueOf(jde) == 'default') {
					doesNotExist = true;
                    
				}
			}
		}
		/* //MIY-2078 removed this check.
		if ( macro_components_attributes != null && !macro_components_attributes.isEmpty()) {

			for (Object mc: macro_components_attributes.values()) {
				if (String.valueOf(mc) == 'DOES NOT EXIST' || String.valueOf(mc) == 'default') {
					doesNotExist = true;
                    
				}
			}
		}*/
		
		if( listSku.contains('DOES NOT EXIST') || listSku.contains('default')){
			doesNotExist = true;
		}
        
		if (custom_attributes != null && !custom_attributes.isEmpty() && custom_attributes.containsKey('skus') &&  !listSku.contains('DOES NOT EXIST') && !listSku.contains('default')) {
			sku = String.valueOf(custom_attributes.get('skus'));
			sku.removeStart('(');
			sku.removeEnd(')');

		} else {
			sku = null;
		}
        
		//end  MIY - 1615 & MIY-1644
		
		if(attrs != null && !attrs.isEmpty() && !attrs.containsKey('error')){
		Map < String, Object > attrs_extended_attributes = (Map < String, Object > ) attrs.get('extended_attributes');
		for (String key: attrs_extended_attributes.keySet()) {
			Map < String, Object > curr = (Map < String, Object > ) attrs_extended_attributes.get(key);
			String attrVal;
			String attrValTxt;
			String attrKey = key;

			if (curr.containsKey('info') &&
				((Map < String, Object > ) curr.get('info')).containsKey('selectorType') &&
				((String)(((Map < String, Object > ) curr.get('info')).get('selectorType'))) != 'none' &&
				(
					(curr.get('value') instanceof Map < String, Object >
						&&
						((Map < String, Object > ) curr.get('value')).containsKey('info') &&
						(String)((Map < String, Object > )((Map < String, Object > ) curr.get('value')).get('info')).get('vendorId') != 'NONE') ||
					(curr.get('value') instanceof String && (String) curr.get('value') != 'false')
				)
			) {
				if (((String)(((Map < String, Object > ) curr.get('info')).get('selectorType'))) == 'swatch') {
					if (((Map < String, Object > ) curr.get('value')).containsKey('images') &&
						!((Map < String, Object > )(((Map < String, Object > ) curr.get('value')).get('images'))).isEmpty()) {
						if (key.containsIgnoreCase('sticker')) {
							/* ignore for now
							   if (!attributes['Stickers']) {
							    attributes['Stickers'] = [];
							   }
							 */
							attrVal = getFluidProductsUrl(isChinaURL) +
								'/p_' +
								(Integer)(((Map < String, Object > )(attrs.get('product')))).get('id') +
								'/' +
								((Map < String, Object > )(((Map < String, Object > ) curr.get('value')).get('images'))).get('url');
							attrValTxt = (String)(((Map < String, Object > )(curr.get('value'))).get('name'));
							attrKey = 'Stickers';
						} else {
							attrVal = getFluidProductsUrl(isChinaURL) +
								'/p_' +
								(Integer)(((Map < String, Object > )(attrs.get('product')))).get('id') +
								'/' +
								((Map < String, Object > )(((Map < String, Object > )(curr.get('value'))).get('images'))).get('url');
							attrValTxt = (String)(((Map < String, Object > )(curr.get('value'))).get('name'));
						}
					} else if (((Map < String, Object > ) curr.get('value')).containsKey('info') &&
						((Map < String, Object > )((Map < String, Object > ) curr.get('value')).get('info')).containsKey('color')) {
						attrVal = (String)((Map < String, Object > )((Map < String, Object > ) curr.get('value')).get('info')).get('color');
						attrValTxt = (String)(((Map < String, Object > )(curr.get('value'))).get('name'));
					}
				} else if (((String)(((Map < String, Object > ) curr.get('info')).get('selectorType'))) == 'text') {
					attrVal = (String)(((Map < String, Object > )(curr.get('value'))).get('extendedId'));
					attrValTxt = (String)(((Map < String, Object > )(curr.get('value'))).get('extendedId'));
				} else {
					attrVal = (String)(((Map < String, Object > )(curr.get('value'))).get('name'));
					attrValTxt = (String)(((Map < String, Object > )(curr.get('value'))).get('name'));
				}
			}


			attributes.put(key, new ProductConfigurationDetail__c(
				Name = ((String) curr.get('name')).abbreviate(80),
				Type__c = ((String)(((Map < String, Object > ) curr.get('info')).get('selectorType'))),
				Key__c = attrKey,
				Value__c = attrVal,
				Value_Text__c = attrValTxt,
				Sku__c = sku,
				hasDoesNotExist__c = doesNotExist
			));


			if (((String) curr.get('alias')).contains('initials_derived_color_') &&
				(
					(attrs_extended_attributes.containsKey('sticker_shape') &&
						((Map < String, Object > )((Map < String, Object > )(attrs_extended_attributes.get('sticker_shape')))).containsKey('info') &&
						(String)(((Map < String, Object > )(((Map < String, Object > )(((Map < String, Object > )((Map < String, Object > )(attrs_extended_attributes.get('sticker_shape')))).get('value'))).get('info'))).get('vendorId')) == 'INITIALS_ONLY') ||
					!attrs_extended_attributes.containsKey('sticker_shape'))
			) {
				attributes.put(key, new ProductConfigurationDetail__c(
					Name = ((String) curr.get('name')).abbreviate(80),
					Type__c = 'text',
					Key__c = key,
					Value__c = (String)(((Map < String, Object > )(((Map < String, Object > )(curr.get('value'))).get('info'))).get('color')),
					Value_Text__c = ((String)(((Map < String, Object > )(curr.get('value'))).get('name'))).abbreviate(255),
					Sku__c = sku,
					hasDoesNotExist__c = doesNotExist
				));
			}
		}
	}
	else if(attrs.containsKey('error')){
			attributes.put('empty', new ProductConfigurationDetail__c(
				Name = 'empty',
				Sku__c = 'empty'
			
			)); 
	}
		if (attributes.containsKey('initials_color_1_jde')) {
			attributes.remove('initials_color_1_jde');
		}
		if (attributes.containsKey('initials_color_2_jde')) {
			attributes.remove('initials_color_2_jde');
		}
		if (attributes.containsKey('initials_invert_colors_jde')) {
			attributes.remove('initials_invert_colors_jde');
		}
		if (attributes.containsKey('select_2_colors')) {
			attributes.remove('select_2_colors');
		}
		return attributes.values();



		//      //Regex to retrieve attribute alias index (Example: 1_strap_material)
		//      Pattern regexp = pattern.compile('^(\d)_{1}');
		//      Integer attrWithIndexCount = 0;

		/* Rest of JS file deemed irrelevant for now */


	}
	public static String getFluidRecipeUrl(Boolean isChinaURL) {
		return isChinaURL ?
			ProductSettings__c.getInstance().Fluid_Recipe_URL_China__c :
			ProductSettings__c.getInstance().FluidPictureUrl__c;
	}
	public static String getFluidProductsUrl(Boolean isChinaURL) {
		return isChinaURL ?
			ProductSettings__c.getInstance().Fluid_Products_URL_China__c :
			ProductSettings__c.getInstance().Fluid_Products_URL__c;
	}
}