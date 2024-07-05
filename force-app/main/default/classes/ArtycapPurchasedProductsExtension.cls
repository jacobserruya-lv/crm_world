global class ArtycapPurchasedProductsExtension {
    
    // Current and chosen currency
    global String currentCurrency {get; set;}
    global String chosenCurrency {get; set;}
    // Constants string values
    global static final String eur = 'eur';
    global static final String usd = 'usd';
    global static final String yen = 'yen';
    global static final String yuan ='yuan';
    // Boolean flags
    global Boolean isEUR {get; set;}
    global Boolean isUSD {get; set;}
    global Boolean isJPY {get; set;}
    global Boolean isRMB {get; set;}
    
    // Updates flags relative to current currency
    global void updateCurrency (){
        currentCurrency = chosenCurrency;
        isEUR = currentCurrency.equals(eur);
        isUSD = currentCurrency.equals(usd);
        isJPY = currentCurrency.equals(yen);
        isRMB = currentCurrency.equals(yuan);
    }
    
    // Actions
    global void chooseUSD(){
        chosenCurrency = usd;
        updateCurrency();
    }
    
    global void chooseEUR(){
        chosenCurrency = eur;
        updateCurrency();
    }
    
    global void chooseJPY(){
        chosenCurrency = yen;
        updateCurrency();
    }
    
    global void chooseRMB(){
        chosenCurrency = yuan;
        updateCurrency();
    }
    
    // Constructor
    global ArtycapPurchasedProductsExtension (Artycap_ClientDetails_VFC con){
		// Initialize with user's default currency        
        chosenCurrency = Artycap_ClientDetails_VFC.getDefaultUserCurrency();
        updateCurrency();
    }
}