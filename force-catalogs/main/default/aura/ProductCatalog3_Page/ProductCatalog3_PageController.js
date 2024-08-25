({
  init: function (component, event, helper) {
    //console.group(component.getType() + '.init');

    component.set("v.currentProduct", []);
    component.set("v.recentlyViewed", []);
    helper.initData(component, event, helper);

    var sku = component.get("v.pageReference").state.c__sku;
    if (sku != null && sku != "") {
      component.set("v.currentProduct", []);
      component.set("v.productsMap", []);

      component.set("v.searchTermParameter", sku);
      console.log("sku", sku);


      // debugger;
    }
    /*var id = component.get('v.pageReference').state.c__id;
        if(id == null && component.get('v.pageReference').state.fragment != null) {
            id = component.get('v.pageReference').state.fragment.split('-')[0];
        }
        
        component.set('v.recordId', id);*/

    helper.getStoreHierarchy(component, helper, function () {
      helper.getCurrentUser(component, event, helper);
    });


    // Verify the user permission set
    helper.getPersonalizeButtonPermission(component, event, helper);

    //console.groupEnd();
  },

  getCustomizeCommand: function (component, event) {

    component.set("v.isNotDisplayStaticPage", !component.get("v.isNotDisplayStaticPage"));

  },

  updateFavoriteList: function (component, event, helper) {
    //if(event.getParam('src') == 'displayFavorites'){
    event.stopPropagation();
    var myFarorites = [];
    var favs = event.getParam("myFavorites");
    if (favs != "") {
      myFarorites = event.getParam("myFavorites").split(",");
    }
    component.set("v.myFavorites", myFarorites);

    // }
  },

  handleLocationChange: function (component, event, helper) {
    // console.group(component.getType() + '.handleLocationChange');
    var loc = event.getParam("token");
    var id = loc.split("-")[0];
    component.set("v.recordId", id);
    // console.groupEnd();
  },

  // handleRecordChange: function (component, event) {
  //   var id = event.getParam("value");
  //   var productsMap = component.get("v.productsMap") || {};
  //   //console.log('productsMap', productsMap[id]);
  //   if (productsMap[id]) component.set("v.currentProduct", productsMap[id]);
  //   else {
  //     console.log("search for productId");
  //   }
  // },

  updateStoreList: function (cmp, event, helper) {
    cmp.set("v.selectedStores", event.getParam("selectedStores"));
    cmp.set("v.selectedZone", event.getParam("selectedZone"));
    var warehouse = event.getParam("selectedWarehouses");
    //console.log('update list store warehouse', warehouse );
    cmp.set("v.selectedWarehouses", warehouse);
    cmp.set("v.userStores", event.getParam("userStores"));
    var digitalStore = event.getParam("digitalStore");
    cmp.set("v.digitalStore", digitalStore);
  },
  handleSidebarBtnClick: function (component, event) {
    component.set("v.sidebarType", event.getSource().get("v.name"));
    component.set("v.sidebarOpen", true);
  },

  updateSelectedStores: function (cmp, event, helper) {
    //console.group('--ProductCatalogListController.updateSelectedStores--');
    var selectedStores = event.getParam("selectedStores");
    var selectedWarehouses = event.getParam("selectedWarehouses");
    //console.log('selectedWarehouses', selectedWarehouses);
    var selectedZone = event.getParam("selectedZone");
    //console.log('update digitalStore', digitalStore);
    cmp.set("v.selectedStores", selectedStores);
    cmp.set("v.selectedWarehouses", selectedWarehouses);
    cmp.set("v.selectedZone", selectedZone);
    var selectedCountriesEvent = event.getParam("selectedCountries");
    cmp.set("v.selectedCountries", selectedCountriesEvent);
    var selectedPhysicalStoresEvent = event.getParam("selectedPhysicalStores");
    cmp.set("v.selectedPhysicalStores", selectedPhysicalStoresEvent);
  },

  updateProduct: function (component, event, helper) {
    var product = event.getParam("product");
    var isSearchProduct = event.getParam("fromWhere") ? false : true;
    //var productsMap;
    // productsMap[product.id].push(product);
    component.set("v.currentProduct", product);
    component.set("v.isSearchProduct", isSearchProduct);
    //component.set('v.recordId', product.id);
    //component.set('v.productsMap', productsMap);
  },

  updateDigitalStore: function (cmp, event, helper) {
    var digitalStore = event.getParam("digitalStore");
    cmp.set("v.digitalStore", digitalStore);
  },

  updateRecentlyViewed: function (cmp, event, helper) {
    var recentlyViewed = cmp.get("v.recentlyViewed");
    var product = cmp.get("v.currentProduct");

    if (product.sku) {
      for (var i = 0; i < recentlyViewed.length; i++) {
        if (recentlyViewed[i].sku == product.sku) {
          recentlyViewed.splice(i, 1);
        }
      }
      recentlyViewed.push(product);
      cmp.set("v.recentlyViewed", recentlyViewed);
    }
  },
  removeData: function (cmp, event, helper) {
    cmp.set("v.currentProduct", {});
    cmp.set("v.productsMap", []);
  },

  loadAnalytics: function (component, event, helper) {
    (function (i, s, o, g, r, a, m) {
      i["GoogleAnalyticsObject"] = r;
      (i[r] =
        i[r] ||
        function () {
          (i[r].q = i[r].q || []).push(arguments);
        }),
        (i[r].l = 1 * new Date());
      (a = s.createElement(o)), (m = s.getElementsByTagName(o)[0]);
      a.async = 1;
      a.src = g;
      m.parentNode.insertBefore(a, m);
    })(window, document, "script", "//www.google-analytics.com/analytics.js", "ga");

    ga("create", "UA-135880969-28", "auto");
    ga("send", "pageview");
  },

  onDataReady: function (component, event, helper) {
    var listSkus = event.getParam('listSkus');
    console.log({ listSkus })
    component.set('v.productsSkusSearch', listSkus);
  }
});