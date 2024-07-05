({
	myAction : function(component, event, helper) {
		
	},

	getPrices: function(cmp) {
		var prices = cmp.get('v.selectedProductPrices');
		var price = [];
		var countryPrices = [];
		for(var i = 0; i < prices.length; i++){
			price['CountryCode']=prices[i]['R'].CountryCode;
			price['Country']=prices[i]['R'].Country;
			price['price']=prices[i]['R'].price;
			price['currencyCoin']=prices[i]['R'].currencyCoin ;	
			countryPrices.push(price);
			price = [];
			
		}
		cmp.set('v.countryPrices', countryPrices);

	}
})