({
    /*addDigitalLabel : function(cmp, event, helper) {
        var product = cmp.get('v.product');
        var productsStock = cmp.get('v.productsStock');
        var productsPrices = cmp.get('v.productsPrices');

        //console.log('my item stock', productsStock );
        var prices;
        if(productsPrices){
            prices = productsPrices[product.sku];
        }
        var stock;
        var digitalLabels = false;
        var storePrice = false;


        if(productsStock) {
            stock = productsStock[product.sku];
            if(stock) {
                //stock = stock.sort(function(x, y) { return x.isDigital == y.isDigital ? 0 : x.isDigital ? -1 : 1 });
                for(var i = 0; i < stock.length; i++) {
                    if(stock[i].isDigital) {
                        cmp.set('v.online', stock[i].online);
                        cmp.set('v.csc', stock[i].csc);
                        digitalLabels = true;


                        //break;
                    }else{
                        if(prices) {
                            if (prices[stock[i].store.countryCode]) {
                                product.price = prices[stock[i].store.countryCode].price;
                                product.summaryCurrency = prices[stock[i].store.countryCode].currencyCoin;
                                product.currencyCode = stock[i].store.currencyCoin;
                            }
                        }
                    }
                    if (storePrice && digitalLabels){
                        break;
                    }
                }
            }
            cmp.set('v.product', product);
        }
        else{
            cmp.set('v.online', false);
            cmp.set('v.csc', false);
            product.price = '-1';
            product.summaryCurrency = '';
            product.currencyCode = '';
            cmp.set('v.product', product);
        }
    },*/
    /*addPrices : function(cmp, event, helper) {
        //var product = cmp.get('v.product');
        //var productsPrices = cmp.get('v.productsPrices');

        //console.log('my item stock', productsStock );
        /*var price;
        if(productsPrices) {
            price = productsStock[product.sku];
            if(price) {
                price = stock.sort(function(x, y) { return x.isDigital == y.isDigital ? 0 : x.isDigital ? -1 : 1 });
                for(var i = 0; i < stock.length; i++) {
                    if(stock[i].isDigital) {
                        cmp.set('v.online', stock[i].online);
                        cmp.set('v.csc', stock[i].csc);
                        //product.price = stock[i].price;
                        product.summaryCurrency = stock[i].currencyCoin;
                        product.currencyCode = stock[i].store.currencyCoin;
                        cmp.set('v.product', product);
                        break;
                    }
                }
            }
        }
        else{

            product.price = '-1';
            product.summaryCurrency = '';
            product.currencyCode = '';
            cmp.set('v.product', product);
        }
    },*/

    manageFavorites: function(cmp,event,helper) {
        var product = cmp.get('v.product');
        var action = cmp.get('c.updateFavorites');
        action.setParams({
            'Sku': product.sku
        });
        action.setCallback(this, function (result) {
            var state = result.getState();

            if (state === 'SUCCESS') {
                cmp.set('v.myFavorites', result.getReturnValue());
                helper.isInFavorites(cmp,event,helper);
                var myEvent = $A.get('e.c:ProductCatalogUpdateFavoriteListEvent');
                myEvent.setParams({
                    'myFavorites': result.getReturnValue().join(','),
                    'src': 'listItem'
                });
                myEvent.fire();
            }
            else if (state === 'ERROR') {
                helper.handleError(result);
            }
            else {
                console.error('Unknown error');
            }
        });
        $A.enqueueAction(action);

    },

    handleError: function (reponse) {
        var errors = reponse.getError();
        if (errors && errors[0] && errors[0].message) {
            console.error('Error Message: ' + errors[0].message);
        }
    },

    isInFavorites: function(cmp,event,helper) {
        var myFavorites = cmp.get('v.myFavorites');
        var product = cmp.get('v.product');
        if(myFavorites.includes(product.sku)){
            cmp.set('v.isFavorite', true);
        }
        else
        {
            cmp.set('v.isFavorite', false);
        }
    },

    getFiche: function(cmp, event, helper){
        var product = cmp.get('v.product');
        var Difference_In_Days;
        if(product.pdfUrlDate){
            var pdfDate = new Date(product.pdfUrlDate);
           var currentdate = new Date();
            var today = new Date(currentdate.getFullYear()+'-'
                                 + (currentdate.getMonth()+1)  + "-"
                                 + currentdate.getDate() );
            var Difference_In_Time = today.getTime() - pdfDate.getTime(); 
            Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24); 
        }

        if((product.pdfUrl || product.pdfUrlDate) && Difference_In_Days < 30) {
           cmp.set('v.pdfLink', product.pdfUrl);
        }
        else {
            var action = cmp.get('c.getPDF');
        
            action.setParams({
                'sku': product.sku,
            });
            action.setCallback(this, function(result) { 
                var state = result.getState();
                if(state === 'SUCCESS'){
                    var Link = result.getReturnValue();
                    //cmp.set('v.isStoreFilterExpanded', resultSettings.isOpen__c);
                    if(Link != '') {
                        cmp.set('v.pdfLink', Link);
                    }
                }
                else if(state === 'ERROR'){
                    helper.handleError(result);
                } 
                else {
                    console.error('Unknown error');
                }
            });
            $A.enqueueAction(action);   
        }

    }
})