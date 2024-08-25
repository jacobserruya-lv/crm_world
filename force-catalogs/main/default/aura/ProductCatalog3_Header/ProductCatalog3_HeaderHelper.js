({

  /*filterChange: function(cmp, event, helper) {

        //event.stopImmediatePropagation();

       var event1 = $A.get('e.c:ProductCatalogGetAvailabilityEvent');
        event1.setParams({
          'product': null, 
            'productsStock': '',
        });
        event1.fire();
        
      var myEvent = $A.get('e.c:ProductCatalogFilterChangeEvent');
        //if(cmp.get('v.searchKey').length > 1) {
            myEvent.setParams({'searchKey': cmp.get('v.searchTerm')});
            var timer = cmp.get("v.timer");
            clearTimeout(timer);
            timer = setTimeout(function () {
                if(cmp.get('v.searchTerm').length > 1 || cmp.get('v.searchTerm').length == 0) {
                    //cmp.set('v.advenced', false);
                    myEvent.fire();
                }
                cmp.set('v.timer', null);
            }, 500);
            cmp.set("v.timer", timer);
       // }
    },*/


  handleError: function (reponse) {
    var errors = reponse.getError();
    if (errors && errors[0] && errors[0].message) {
      console.error('Error Message: ' + errors[0].message);
    }
  },

  toggleStoreFilterExpanded: function (cmp, event, helper) {
    cmp.set("v.isStoreFilterExpanding", true);
    var isExpanded = cmp.get("v.isStoreFilterExpanded");
    cmp.set("v.isStoreFilterExpanded", !isExpanded);

    /*var action = cmp.get('c.updateStoreHierarchyState');
        action.setParams({
            state: !isExpanded,
        });
        action.setCallback(this, function(result) { 
            
        });
        $A.enqueueAction(action);*/

    // reset classes after transition
    setTimeout(function () {
      cmp.set("v.isStoreFilterExpanding", false);
    }, 300);
  },

  sendData: function (component, listSkusResults) {
    var onDataReadyEvent = $A.get('e.c:ProductCatalogListSkusCallbackEvent');
    onDataReadyEvent.setParams({ "listSkus": listSkusResults });
    onDataReadyEvent.fire()
  }
});