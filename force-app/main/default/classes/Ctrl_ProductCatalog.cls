/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 01-13-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   01-13-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
 **/
// Created By: Balink 2017
// Description: Controller for Catalog Desktop Application

public with sharing class Ctrl_ProductCatalog {


  public static final Integer RECORDS_LIMIT = 2000;
  public static final String DIGITAL_STORE_CODES = (Catalogue_Settings__c.getInstance(
      System.Label.WSCatalogueTECHUserId
    ))
    .Digital_Stores__c;
  public static final String UNWANTED_STORE_CODES = (Catalogue_Settings__c.getInstance(
      System.Label.WSCatalogueTECHUserId
    ))
    .UnwantedStores__c;
  // public static final String DIGITAL_STORE_CODES_FOR_ATG_PRICE = (Catalogue_Settings__c.getInstance(
  //     System.Label.WSCatalogueTECHUserId
  //   ))
  //   .Digital_Store_List_Other_Price__c;


  @AuraEnabled
  public static ProductCatalogPageResult getProductsCatalogFiltered(List<string> listSkus) {
      System.debug('getProductsCatalog listSkus : ' + listSkus);

      ProductCatalogPageResult pageResult = new ProductCatalogPageResult();
      pageResult.products = new List<Wrapper_ProductCatalog>();

      
      if(listSkus.size() > 0) {
        pageResult.products = Wrapper_ProductCatalog.convertToProductCatalogWrappers(
          DAL_ProductCatalog.getProductsCatalogBySkus(listSkus),
          null
          );
          pageResult.total = (pageResult.products).size();

      } else {
        pageResult.total = 0;
        pageResult.products = null;
      } 

      System.debug('getProductsCatalog pageResult.products : ' + pageResult.products);
      System.debug('getProductsCatalog pageResult.total : ' + pageResult.total);

      return pageResult;
    
  }


  //Search product Catalog
  //   @AuraEnabled
  //   public static ProductCatalogPageResult getAllProductCatalogs(
  //     String searchKey,
  //     Decimal pageSize,
  //     Decimal pageNumber,
  //     List<String> stores,
  //     Boolean isProductsSF
  //   ) {
  //     //system.debug('start searching');
  //     ProductCatalogPageResult pageResult = new ProductCatalogPageResult();
  //     pageResult.products = new List<Wrapper_ProductCatalog>();
  //     List<ProductCatalogue__c> allProducts = new List<ProductCatalogue__c>();
  //     List<Wrapper_ProductCatalog> allProductsGaston = new List<Wrapper_ProductCatalog>();

  //     //calc current offset by the page size and number
  //     Integer pSize = (Integer) pageSize;
  //     Integer offset = ((Integer) pageNumber - 1) * pSize;

  //     Store__c defaultStore = null;
  //     User currentUser = DAL_ProductCatalog.getUser();

  //     Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();

  //     /*defaultStore = (String.isNotEmpty(lastDigitalStore.StoreRetailId__c)) ?
  //            DAL_ProductCatalog.getStoreByCode(lastDigitalStore.StoreRetailId__c) :
  //            DAL_ProductCatalog.getStoreByCode(currentUser.DefaultStore__c);*/

  //     defaultStore = (String.isNotEmpty(lastDigitalStore.StoreRetailId__c))
  //       ? DAL_ProductCatalog.getStoreByCode(lastDigitalStore.StoreRetailId__c)
  //       : null;

  //     pageResult.pageSize = pSize;
  //     pageResult.page = (Integer) pageNumber;

  //     //allProducts = DAL_ProductCatalog.getAllProductCatalogs(searchKey);
  //     system.debug(searchKey);
  //     system.debug(defaultStore);
  //     system.debug(isProductsSF);
  //     system.debug(pSize);

  //     allProductsGaston = DAL_ProductCatalog.gastonSearch(
  //       searchKey,
  //       isProductsSF || pageResult.page > 1
  //     );

  //     System.debug('AAAAAA allProductsGaston ' + allProductsGaston);

  //     //pageResult.total = allProducts.size();
  //     pageResult.total = allProductsGaston.size();
  //     // if(String.isEmpty(searchKey) || searchKey.length() < 2) {
  //     //     pageResult.products = Wrapper_ProductCatalog.convertToProductCatalogWrappers(DAL_ProductCatalog.getProductCatalogs(offset, pSize), defaultStore);
  //     // }
  //     // else {

  //     if (allProductsGaston.size() < pSize * (pageNumber - 1)) {
  //       pageResult.page = 1;
  //       offset = 0;
  //     }

  //     pageResult.products = (List<Wrapper_ProductCatalog>) slice(
  //       allProductsGaston,
  //       offset,
  //       offset + pSize
  //     );

  //     // for(Integer i = offset; (i < offset + pSize) && (i < allProductsGaston.size()); i++) {
  //     //     pageResult.products.add(Wrapper_ProductCatalog.convertToProductCatalogWrapper(allProductsGaston[i], defaultStore));         }
  //     // }
  //     //system.debug('end serching returning results');
  //     return pageResult;
  //   }

  // public static List<Object> slice(List<Object> input, Integer ge, Integer l) {
  //   List<Object> output = input.clone();
  //   for (Integer i = 0; i < ge; i++)
  //     output.remove(0);
  //   Integer elements = l - ge;
  //   while (output.size() > elements)
  //     output.remove(elements);
  //   return output;
  // }



  ///////////////////////////CHECK IF NO IMPACT TO PUT IT IN COMMENT///////////////////////
  @AuraEnabled
  public static List<Wrapper_ProductCatalog> getProductsBySkus(List<String> skus) {
    try {
      return sortProductsBySkus(
        Wrapper_ProductCatalog.convertToProductCatalogWrappers(
          DAL_ProductCatalog.getProductsCatalogBySkus(skus),
          null
        ),
        skus
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static List<Wrapper_ProductCatalog> sortProductsBySkus(
    List<Wrapper_ProductCatalog> wrappers,
    List<String> skus
  ) {
    Map<String, Wrapper_ProductCatalog> wrapperMap = new Map<String, Wrapper_ProductCatalog>();
    List<Wrapper_ProductCatalog> wrapperList = new List<Wrapper_ProductCatalog>();
    for (Wrapper_ProductCatalog wrapper : wrappers) {
      wrapperMap.put(wrapper.sku, wrapper);
    }

    for (String s : skus) {
      if (wrapperMap.get(s) != null) {
        wrapperList.add(wrapperMap.get(s));
      }
    }
    return wrapperList;
  }

  //Store change of digital store in custom setting
  @AuraEnabled
  public static UserStores updateDigitalStore(String digitalStore) {
    try {
      Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();
      Last_Digital_Store__c digitalStoreToUpdate = null;
      User currentUser = DAL_ProductCatalog.getUser();
      if (
        /*String.isNotEmpty(digitalStore) && */ digitalStore != lastDigitalStore.StoreRetailId__c
      ) {
        digitalStoreToUpdate = new Last_Digital_Store__c(
          StoreRetailId__c = digitalStore,
          SetupOwnerId = currentUser.Id
        );

        if (lastDigitalStore.Id != null) {
          digitalStoreToUpdate.Id = lastDigitalStore.Id;
        }
      }
      system.debug('digitalStoreToUpdate ' + digitalStoreToUpdate);
      if (digitalStoreToUpdate != null) {
        upsert digitalStoreToUpdate;
      }
      UserStores userStores = new UserStores();
      //userStores.defaultStore = currentUser.DefaultStore__c;
      userStores.defaultStore = currentUser.My_Stores_Lists__c;
      userStores.lastDigitalStore = digitalStoreToUpdate.StoreRetailId__c;

      return userStores;
    } catch (Exception e) {
      log('updateDigitalStore', e);
      return null;
    }
  }

  //Get digitalStore from custom setting
  @AuraEnabled
  public static List<Wrapper_ProductCatalogStore> getDigitalStores() {
    List<String> digitalStoreCodes = getCodesForDgitalStores(DIGITAL_STORE_CODES);
    return Wrapper_ProductCatalogStore.convertToStoreWrappers(
      DAL_ProductCatalog.getStoresByCodes(digitalStoreCodes)
    );
  }
  // @AuraEnabled
  // public static List<String> getDigitalStoresAtgPrice() {
  //   system.debug('digitsl codes' + DIGITAL_STORE_CODES_FOR_ATG_PRICE);
  //   List<String> digitalStoreCodesAtgPrice = DIGITAL_STORE_CODES_FOR_ATG_PRICE.split(',');
  //   return digitalStoreCodesAtgPrice;
  // }
  @AuraEnabled
  public static Wrapper_ProductCatalog getProductCatalogById(
    String productId,
    List<String> selectedStores
  ) {
    User currentUser = DAL_ProductCatalog.getUser();
    List<Store__c> currentStores = DAL_ProductCatalog.getStoresByNames(selectedStores);
    //Store__c defaultStore = DAL_ProductCatalog.getStoreByCode(currentUser.DefaultStore__c);

    Map<String, Store__c> storeMapByCode = new Map<String, Store__c>();

    for (Store__c store : currentStores) {
      if (String.isNotEmpty(store.RetailStoreId__c)) {
        storeMapByCode.put(store.RetailStoreId__c, store);
      }
    }

    ProductCatalogue__c product = DAL_ProductCatalog.getProductCatalogById(productId);
    List<Wrapper_ProductCatalog> wrapperProducts = Wrapper_ProductCatalog.convertToProductCatalogWrappers(
      new List<ProductCatalogue__c>{ product },
      null
    );

    for (Store__c store : currentStores) {
      if (String.isNotEmpty(store.Currency__c)) {
        wrapperProducts[0].summaryCurrency = getCurrencySymbolFromIso(store.Currency__c);
        break;
      }
    }
    return wrapperProducts[0];
  }

  public static String getCurrencySymbolFromIso(String Iso) {
    String currencySymbol = ('USD' == Iso
      ? '$'
      : ('CAD' == Iso
          ? '$'
          : ('EUR' == Iso
              ? '€'
              : ('GBP' == Iso
                  ? '£'
                  : ('JPY' == Iso
                      ? '¥'
                      : ('KRW' == Iso
                          ? '₩'
                          : ('CNY' == Iso
                              ? '元'
                              : ('THB' == Iso
                                  ? '฿'
                                  : ('VND' == Iso ? '₫' : ('RMB' == Iso ? '¥' : Iso))))))))));
    return currencySymbol;
  }

  /*@AuraEnabled
    public static List<Wrapper_ProductStoreAvailability> getProductAvailabilitiesByProductId(String productId, List<String> selectedStoresNames) {
        Decimal numOfStoresRequested = selectedStoresNames.size();
        User currentUser = DAL_ProductCatalog.getUser();
        
        Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();
        Store__c defaultStore = (String.isNotEmpty(lastDigitalStore.StoreRetailId__c)) ? 
            DAL_ProductCatalog.getStoreByCode(lastDigitalStore.StoreRetailId__c) :
            DAL_ProductCatalog.getStoreByCode(currentUser.DefaultStore__c);
        
        ProductCatalogue__c selectedProduct = DAL_ProductCatalog.getProductCatalogById(productId);
        for(Integer i = 0; i < selectedStoresNames.size(); i++) {
            if(selectedStoresNames[i] == defaultStore.RetailStoreId__c) {
                selectedStoresNames.remove(i);
            }
        }
        
        List<Store__c> selectedStores = DAL_ProductCatalog.getStoresByCodes(selectedStoresNames); 
        
        selectedStores.add(defaultStore);
        
        if(selectedStores != null && selectedStores.size() == 2 && selectedStores[0].StoreLocation__c != null) {
            List<Store__c> nearbyStores = DAL_ProductCatalog.getNearbyStoresByStoreLocation(selectedStores[0].StoreLocation__c.getLatitude(),selectedStores[0].StoreLocation__c.getLongitude(), 30, selectedStores[0].RetailStoreId__c);
            if(nearbyStores != null) {
                selectedStores.addAll(nearbyStores);
            }
        }
        
        Map<String, List<Wrapper_ProductStoreAvailability>> productAvailabilityMap = WS_ProductStockAvailability.getProductsStoreAvailabilities(selectedStores, new List<ProductCatalogue__c>{selectedProduct}, defaultStore);
        return (productAvailabilityMap != null && productAvailabilityMap.values().size() > 0) ? productAvailabilityMap.values()[0] : null;
    }
    */

  //Store Hierarchy
  /*@AuraEnabled
    public static Map<String, Map<String, List<String>>> getUserLocationPickListValues(List<String> fieldNames) {
        try {
            Map<String, Map<String, List<String>>> mapValuesToFields = new Map<String, Map<String, List<String>>>();

            Map<String, List<String>> managementZoneLevel =
                    DependentPicklistBitset.GetDependentOptions('User', fieldNames[0], fieldNames[1]);
            Map<String, List<String>> zoneLevel1 =
                    DependentPicklistBitset.GetDependentOptions('User', fieldNames[1], fieldNames[2]);
            Map<String, List<String>> zoneLevel2 =
                    DependentPicklistBitset.GetDependentOptions('User', fieldNames[2], fieldNames[3]);
            Map<String, List<String>> zoneLevel3 =
                    DependentPicklistBitset.GetDependentOptions('User', fieldNames[3], fieldNames[4]);

            system.debug('zoneLevel3 ' + zoneLevel3);
            Map<String, List<String>> newZoneLevel3 = new Map<String, List<String>>();

            Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();

            Map<String, List<String>> userStores = new Map<String, List<String>>();
            userStores.put(Json.serialize(getUserDefaultStoreCode()), new List<String>());
            mapValuesToFields.put('userStores', userStores);

            /*if(String.isNotEmpty(lastDigitalStore.StoreRetailId__c)) {
                Map<String, List<String>> lastDigitalStoreMap = new Map<String, List<String>>();
                lastDigitalStoreMap.put(lastDigitalStore.StoreRetailId__c, new List<String>());
                mapValuesToFields.put('LastDigitalStore', lastDigitalStoreMap);
            }*/

  /*//List<String> digitalStoreCodes = new List<String>();
            //digitalStoreCodes.addAll(DIGITAL_STORE_CODES);
            List<String> digitalStoreCodes = getCodesForDgitalStores(DIGITAL_STORE_CODES);
            List<Store__c> digitalStores = DAL_ProductCatalog.getStoresByCodes(digitalStoreCodes);
            List<String> unwantedStores = getCodesForDgitalStores(UNWANTED_STORE_CODES);

            Map<String, List<String>> digitalStoresMap = new Map<String, List<String>>();
            digitalStoresMap.put('DigitalStores', new List<String>());

            for (Store__c store : digitalStores) {
                digitalStoresMap.get('DigitalStores').add(store.Name + ' - ' + store.RetailStoreId__c);
            }

            for (String storeLevelName : zoneLevel3.keySet()) {

                List<String> Stores = zoneLevel3.get(storeLevelName);
                Integer i = 0;
                while (i < Stores.size()) {
                    Boolean flag = false;
                    for (String store : unwantedStores) {
                        if (store ==
                                Stores[i].substring(Stores[i].length() - 3, Stores[i].length())) {
                            Stores.remove(i);
                            flag = true;
                            break;
                        }
                    }
                    if(!flag){
                        for (Store__c store : digitalStores) {
                            if (store.RetailStoreId__c ==
                                    Stores[i].substring(Stores[i].length() - 3, Stores[i].length())) {
                                Stores.remove(i);
                                flag = true;
                                break;
                            }
                        }
                    }

                    if (!flag)
                        i++;
                }

                newZoneLevel3.put(storeLevelName, Stores);
            }

            mapValuesToFields.put(fieldNames[0], managementZoneLevel);
            mapValuesToFields.put(fieldNames[1], zoneLevel1);
            mapValuesToFields.put(fieldNames[2], zoneLevel2);
            //mapValuesToFields.put(fieldNames[3], zoneLevel3);
            mapValuesToFields.put(fieldNames[3], newZoneLevel3);
            mapValuesToFields.put('DigitalStores', digitalStoresMap);

            //mapValuesToFields.put('LastDigitalStore', Last_Digital_Store__c.getInstance());

            return mapValuesToFields;
        } catch (Exception e) {
            SO_UTIL.log('getUserLocationPickListValues', e);
            return null;
        }
    }*/

  @AuraEnabled(cacheable=true)
  public static Map<String, Map<String, List<String>>> getUserStoreHierarchy() {
    Map<String, Map<String, List<String>>> mapValuesToFields = new Map<String, Map<String, List<String>>>();

    List<Store__c> storeHierarchy = DAL_ProductCatalog.getActiveStores();
    Map<String, List<String>> zoneLevel = new Map<String, List<String>>();
    Map<String, List<String>> countriesStores = new Map<String, List<String>>();
    Map<String, List<String>> warehousesStores = new Map<String, List<String>>();
    Set<String> countriesRegion = new Set<String>();

    Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();

    Map<String, List<String>> userStores = new Map<String, List<String>>();
    UserStores us = getUserDefaultStoreCode();
    userStores.put(Json.serialize(us), new List<String>());

    List<String> defaultStoreCodes = new List<String>();
    if (us.defaultStore != null) {
      defaultStoreCodes = us.defaultStore.split(';');
    }
    system.debug('defaultStoreCodes ' + defaultStoreCodes);
    Set<String> countries = new Set<String>();
    Set<String> mgmtZones = new Set<String>();
    Set<String> stores = new Set<String>();
    for (Store__c s : [
      SELECT Id, StoreCountry__c, MANAGEMENT_ZONE_LEVEL_TECH__c, RetailStoreId__c, Name
      FROM Store__c
      WHERE RetailStoreId__c IN :defaultStoreCodes
    ]) {
      countries.add(s.StoreCountry__c);
      mgmtZones.add(s.MANAGEMENT_ZONE_LEVEL_TECH__c);
      //stores.add(s.Name + ' - ' + s.RetailStoreId__c);
      stores.add(s.RetailStoreId__c);
    }
    userStores.put('countries', new List<String>(countries));
    userStores.put('mgmtZones', new List<String>(mgmtZones));
    userStores.put('stores', new List<String>(stores));

    mapValuesToFields.put('userStores', userStores);

    List<String> digitalStoreCodes = getCodesForDgitalStores(DIGITAL_STORE_CODES);
    List<Store__c> digitalStores = DAL_ProductCatalog.getStoresByCodes(digitalStoreCodes);
    List<String> unwantedStores = getCodesForDgitalStores(UNWANTED_STORE_CODES);

    Map<String, List<String>> digitalStoresMap = new Map<String, List<String>>();
    digitalStoresMap.put('DigitalStores', new List<String>());

    for (Store__c store : digitalStores) {
      digitalStoresMap.get('DigitalStores').add(store.Name + ' - ' + store.RetailStoreId__c);
    }

    for (Store__c store : storeHierarchy) {
      Boolean flag = false;
      for (String unwantedStore : unwantedStores) {
        if (unwantedStore == store.RetailStoreId__c) {
          flag = true;
          break;
        }
      }

      if (!flag) {
        for (Store__c digitalStore : digitalStores) {
          if (digitalStore.RetailStoreId__c == store.RetailStoreId__c) {
            flag = true;
            break;
          }
        }
      }
      if (!flag) {
        if (!countriesStores.containsKey(store.StoreCountry__c)) {
          countriesStores.put(store.StoreCountry__c, new List<String>());
          if (!zoneLevel.containsKey(store.MANAGEMENT_ZONE_LEVEL_TECH__c)) {
            zoneLevel.put(store.MANAGEMENT_ZONE_LEVEL_TECH__c, new List<String>());
          }
          zoneLevel.get(store.MANAGEMENT_ZONE_LEVEL_TECH__c).add(store.StoreCountry__c);
        }
        countriesStores.get(store.StoreCountry__c).add(store.Name + ' - ' + store.RetailStoreId__c);
        if (!warehousesStores.containsKey(store.Store_Region__c)) {
          warehousesStores.put(store.Store_Region__c, new List<String>());
          warehousesStores.get(store.Store_Region__c).add(store.RetailStoreId__c);
        } else {
          Set<String> storesWH = new Set<String>(warehousesStores.get(store.Store_Region__c));
          if (!storesWH.contains(store.RetailStoreId__c)) {
            warehousesStores.get(store.Store_Region__c).add(store.RetailStoreId__c);
          }
        }
      }
    }

    mapValuesToFields.put('zone', zoneLevel);
    mapValuesToFields.put('countries', countriesStores);
    mapValuesToFields.put('Warehouse', warehousesStores);
    mapValuesToFields.put('DigitalStores', digitalStoresMap);
    return mapValuesToFields;
  }

  //Get user store (phisical & digital)
  @AuraEnabled
  public static UserStores getUserDefaultStoreCode() {
    User currentUser = DAL_ProductCatalog.getUser();
    Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();
    UserStores userStores = new UserStores();
    userStores.defaultStore = currentUser.My_Stores_Lists__c;
    system.debug('Display default stores list =>>>>>>>>>'+ userStores.defaultStore);
    userStores.lastDigitalStore = lastDigitalStore.StoreRetailId__c;
    system.debug('Display default stores 2 list =>>>>>>>>>'+ userStores);
    return userStores;
  }

  @AuraEnabled
  public static ProductSettings__c getProductSettings() {
    return ProductSettings__c.getInstance();
  }

  @AuraEnabled
  public static User getUser() {
    return DAL_ProductCatalog.getUser();
  }

  public class ProductCatalogPageResult {
    @AuraEnabled
    public Integer pageSize { get; set; }
    @AuraEnabled
    public Integer page { get; set; }
    @AuraEnabled
    public Integer total { get; set; }
    @AuraEnabled
    public List<Wrapper_ProductCatalog> products { get; set; }

    public ProductCatalogPageResult() {
    }
  }

  public class UserStores {
    @AuraEnabled
    public String defaultStore { get; set; }
    @AuraEnabled
    public String lastDigitalStore { get; set; }
  }

  public static void log(String functionName, Exception e) {
    System.debug(
      '**************************************** ' +
        functionName +
        ' ****************************************\nExpection: ****************************************\n' +
        e +
        '\n****************************************\nStack Trace: ****************************************\n' +
        e.getStackTraceString()
    );
  }

  //call WS RMS (availabilities & stock)
  @AuraEnabled(cacheable=true)
  public static Map<String, List<Wrapper_ProductStoreAvailability>> getProductsAvailabilitiesByProductId(
    List<String> products,
    List<String> stores
  ) {
    Map<String, Wrapper_ProductStoreAvailability> productsStoresAvailabilities = new Map<String, Wrapper_ProductStoreAvailability>();
    Decimal numOfStoresRequested = stores.size();
    User currentUser = DAL_ProductCatalog.getUser();
    List<ProductCatalogue__c> selectedProduct = new List<ProductCatalogue__c>();

    Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();
    /*Store__c defaultStore = (String.isNotEmpty(lastDigitalStore.StoreRetailId__c)) ?
                                DAL_ProductCatalog.getStoreByCode(lastDigitalStore.StoreRetailId__c) :
                                DAL_ProductCatalog.getStoreByCode(currentUser.DefaultStore__c);*/

    Store__c defaultStore = (String.isNotEmpty(lastDigitalStore.StoreRetailId__c))
      ? DAL_ProductCatalog.getStoreByCode(lastDigitalStore.StoreRetailId__c)
      : null;

    if (defaultStore != null) {
      for (Integer i = 0; i < stores.size(); i++) {
        if (stores[i] == defaultStore.RetailStoreId__c) {
          stores.remove(i);
        }
      }
    }

    List<Store__c> selectedStores = DAL_ProductCatalog.getStoresByCodes(stores);

    selectedStores.add(defaultStore);

    if (
      selectedStores != null &&
      selectedStores.size() == 2 &&
      selectedStores[0].StoreLocation__c != null
    ) {
      List<Store__c> nearbyStores = DAL_ProductCatalog.getNearbyStoresByStoreLocation(
        selectedStores[0].StoreLocation__c.getLatitude(),
        selectedStores[0].StoreLocation__c.getLongitude(),
        30,
        selectedStores[0].RetailStoreId__c
      );
      if (nearbyStores != null) {
        selectedStores.addAll(nearbyStores);
      }
    }

    selectedProduct = DAL_ProductCatalog.getProductsCatalogBySkus(products);

    /*Map<String, List<Wrapper_ProductStoreAvailability>> productAvailabilityMap =
                WS_ProductStockAvailability.getProductsStoreAvailabilities(selectedStores, selectedProduct,
                        defaultStore);*/
    Map<String, List<Wrapper_ProductStoreAvailability>> productAvailabilityMap = WS_ProductsStock.getProductsStoreAvailabilities(
      selectedStores,
      selectedProduct,
      defaultStore
    );
    return productAvailabilityMap;
  }

  //call sap product prices
  @AuraEnabled(cacheable=true)
  public static Map<String, Map<String, Map<String, Wrapper_ProductPrice>>> getProductsPricesByProductId(
    List<String> products,
    List<String> stores
  ) {
    system.debug('my products are: ' + products);
    Decimal numOfStoresRequested = stores.size();
    User currentUser = DAL_ProductCatalog.getUser();
    List<ProductCatalogue__c> selectedProduct = new List<ProductCatalogue__c>();

    Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();
    /*Store__c defaultStore = (String.isNotEmpty(lastDigitalStore.StoreRetailId__c)) ?
                                DAL_ProductCatalog.getStoreByCode(lastDigitalStore.StoreRetailId__c) :
                                DAL_ProductCatalog.getStoreByCode(currentUser.DefaultStore__c);*/

    Store__c defaultStore = (String.isNotEmpty(lastDigitalStore.StoreRetailId__c))
      ? DAL_ProductCatalog.getStoreByCode(lastDigitalStore.StoreRetailId__c)
      : null;

    if (defaultStore != null) {
      for (Integer i = 0; i < stores.size(); i++) {
        if (stores[i] == defaultStore.RetailStoreId__c) {
          stores.remove(i);
        }
      }
    }

    List<Store__c> selectedStores = DAL_ProductCatalog.getStoresByCodes(stores);

    selectedStores.add(defaultStore);

    if (
      selectedStores != null &&
      selectedStores.size() == 2 &&
      selectedStores[0].StoreLocation__c != null
    ) {
      List<Store__c> nearbyStores = DAL_ProductCatalog.getNearbyStoresByStoreLocation(
        selectedStores[0].StoreLocation__c.getLatitude(),
        selectedStores[0].StoreLocation__c.getLongitude(),
        30,
        selectedStores[0].RetailStoreId__c
      );
      if (nearbyStores != null) {
        selectedStores.addAll(nearbyStores);
      }
    }

    selectedProduct = DAL_ProductCatalog.getProductsCatalogBySkus(products);

    Map<String, Map<String, Map<String, Wrapper_ProductPrice>>> productPrices = WS_ProductPrice.getProductsCountryPrice(
      selectedStores,
      selectedProduct,
      defaultStore
    );
    return productPrices;
  }

  public static List<String> getCodesForDgitalStores(String codes) {
    List<String> listCodes = new List<String>();
    if (codes != null) {
      for (String code : codes.split(',')) {
        listCodes.add(code.trim());
      }
    }
    return listCodes;
  }

  //call WS ATG (availabilities & stock)
//   @AuraEnabled(cacheable=true)
//   public static Wrapper_ProductVariation getProductVariantData(String sku, String digitalStore) {
//     //Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();
//     system.debug('sending variations');

//     Store__c userDigitalStore = [SELECT Id, Name, RetailStoreId__c, StoreCountry__c, Store_CountryCode__c
//                                  FROM Store__c
//                                  WHERE RetailStoreId__c =: digitalStore limit 1];
    
//     system.debug(' userDigitalStore : ' + userDigitalStore);                            
//     system.debug(' userDigitalStore.StoreCountry__c : ' + userDigitalStore.StoreCountry__c); 
    
//     String dispatchCountry = userDigitalStore.Store_CountryCode__c;
                                     
//     CountryLanguage__c countryLang = [SELECT Country__c, Country__r.Name,  ATG_Locale__c, Salesforce_Locale__c
//                                       FROM CountryLanguage__c  
//                                       WHERE Country__r.Name =: userDigitalStore.StoreCountry__c limit 1];

//     system.debug(' countryLang : ' + countryLang);                            
//     system.debug(' countryLang.ATG_Locale__c : ' + countryLang.ATG_Locale__c);                            
                                                                   
//     String storeLang = countryLang.ATG_Locale__c;

//     Wrapper_ProductVariation variations = WS_ProductData.getProductData(sku, dispatchCountry, storeLang);
//     system.debug('getProductVariantData variations : ' + variations);
//     return variations;

// }


  //update state of store Hierarchy (open / close)
  @AuraEnabled
  public static Store_Hierarchy_State__c updateStoreHierarchyState(Boolean state) {
    try {
      User currentUser = DAL_ProductCatalog.getUser();

      Store_Hierarchy_State__c storeState = DAL_ProductCatalog.getStoreHierarchyState();
      Store_Hierarchy_State__c storeHierarchyState = null;
      storeHierarchyState = new Store_Hierarchy_State__c(
        isOpen__c = state,
        SetupOwnerId = currentUser.Id
      );
      if (storeState.Id != null) {
        storeHierarchyState.Id = storeState.Id;
      }
      if (storeHierarchyState != null) {
        upsert storeHierarchyState;
      }
      return storeHierarchyState;
    } catch (Exception e) {
      log('updateStoreHierarchyState', e);
      return null;
    }
  }

  //get state of store Hierarchy (open / close)
  @AuraEnabled
  public static Store_Hierarchy_State__c getStoreHierarchyState() {
    try {
      Store_Hierarchy_State__c storeState = DAL_ProductCatalog.getStoreHierarchyState();
      return storeState;
    } catch (Exception e) {
      log('getStoreHierarchyState', e);
      return null;
    }
  }

  @AuraEnabled
  public static String AddStoreToMyList(List<String> storesCode) {
    Decimal maxStoresForSearch = (Catalogue_Settings__c.getInstance(
        System.Label.WSCatalogueTECHUserId
      ))
      .Max_stores_for_search__c;
    Integer maxStores = maxStoresForSearch.intValue();
    User us = DAL_ProductCatalog.getUser();

    //system.debug('storeCode' + storesCode);
    List<String> defaultStoreCodes = new List<String>();
    if (us.My_Stores_Lists__c != null) {
      defaultStoreCodes = us.My_Stores_Lists__c.split(';');
    }
    Set<String> myStores = new Set<String>(defaultStoreCodes);

    system.debug('myStores ' + myStores);
    if (storesCode.size() == 0) {
      String myStoreList;
      us.My_Stores_Lists__c = '';
      update us;
      return myStoreList;
    } else if (storesCode.size() == 1) {
      String storeCode = storesCode[0]
        .substring(storesCode[0].length() - 3, storesCode[0].length());
      system.debug('name' + storeCode);
      Boolean flag = false;
      for (Integer i = 0; i < defaultStoreCodes.size(); i++) {
        if (defaultStoreCodes[i] == storeCode) {
          defaultStoreCodes.remove(i);
          flag = true;
          break;
        }
      }
      if (!flag && defaultStoreCodes.size() < maxStores) {
        defaultStoreCodes.add(storeCode);
      }
      String myStoreList = String.join(defaultStoreCodes, ';');
      us.My_Stores_Lists__c = String.join(defaultStoreCodes, ';');
      update us;
      return myStoreList;
    } else {
      for (String storeCode : storesCode) {
        String code = storeCode.substring(storeCode.length() - 3, storeCode.length());
        if (myStores.size() < maxStores) {
          myStores.add(code);
        } else {
          break;
        }
      }
      List<String> myNewStoresList = new List<String>(myStores);
      String myStoreList = String.join(myNewStoresList, ';');
      us.My_Stores_Lists__c = String.join(myNewStoresList, ';');
      update us;
      return myStoreList;
    }
  }

  @AuraEnabled
  public static String AddStoreToMyPersonalList(List<String> storesCode) {
    Decimal maxStoresForSearch = (Catalogue_Settings__c.getInstance(
        System.Label.WSCatalogueTECHUserId
      ))
      .Max_stores_for_search__c;
    Integer maxStores = maxStoresForSearch.intValue();
    User us = DAL_ProductCatalog.getUser();

    if (storesCode.size() == 0) {
      String myStoreList;
      us.My_Stores_Lists__c = '';
      update us;
      return myStoreList;
    } else if (storesCode.size() == 1) {
      String storeCode = storesCode[0]
        .substring(storesCode[0].length() - 3, storesCode[0].length());
      system.debug('name' + storeCode);

      String myStoreList = storeCode;
      us.My_Stores_Lists__c = storeCode;
      update us;
      return myStoreList;
    } else {
      List<String> myStores = new List<String>();
      for (String storeCode : storesCode) {
        String code = storeCode.substring(storeCode.length() - 3, storeCode.length());
        if (myStores.size() < maxStores) {
          myStores.add(code);
        } else {
          break;
        }
      }
      //List<String> myNewStoresList = new List<String>(myStores);
      String myStoreList = String.join(myStores, ';');
      us.My_Stores_Lists__c = String.join(myStores, ';');
      update us;
      return myStoreList;
    }
  }

  //Search product Catalog Recently Published
  @AuraEnabled
  public static ProductCatalogPageResult getRecentlyPublished() {
    Decimal numOfProducts = (Catalogue_Settings__c.getInstance(System.Label.WSCatalogueTECHUserId))
      .Number_Of_New_Porducts__c;
    Integer productsNum = numOfProducts.intValue();
    ProductCatalogPageResult pageResult = new ProductCatalogPageResult();
    pageResult.products = new List<Wrapper_ProductCatalog>();
    List<ProductCatalogue__c> allProducts = new List<ProductCatalogue__c>();

    pageResult.products = Wrapper_ProductCatalog.convertToProductCatalogWrappers(
      DAL_ProductCatalog.getRecentlyPublishedProducts(productsNum),
      null
    );

    return pageResult;
    //}else{
    //  return null;
    //}
  }

  @AuraEnabled
  public static List<String> GetUserFavorites() {
    User currentUser = DAL_ProductCatalog.getUser();
    List<String> favorites = new List<String>();
    if (currentUser.My_Favorites__c != null)
      favorites = currentUser.My_Favorites__c.split(',');
    return favorites;
  }

  @AuraEnabled
  public static Map<String, List<String>> getInitData() {
    // List<String> digitalStoreCodesAtgPrice = getDigitalStoresAtgPrice();
    List<String> favorites = GetUserFavorites();
    Map<String, List<String>> initData = new Map<String, List<String>>();
    // initData.put('digitalStoreCodesAtgPrice', new List<String>(digitalStoreCodesAtgPrice));
    initData.put('MyFavorites', new List<String>(favorites));
    return initData;
  }

  @AuraEnabled
  public static List<String> updateFavorites(String Sku) {
    system.debug('Sku' + Sku);
    User currentUser = DAL_ProductCatalog.getUser();
    system.debug('current user' + currentUser);
    List<String> favorites = new List<String>();
    if (currentUser.My_Favorites__c != null) {
      favorites = currentUser.My_Favorites__c.split(',');
    }
    if (favorites.size() > 0) {
      if (favorites.indexOf(Sku) > -1) {
        favorites.remove(favorites.indexOf(Sku));
      } else {
        favorites.add(0, Sku);
      }
    } else {
      favorites.add(Sku);
    }

    currentUser.My_Favorites__c = String.join(favorites, ',');
    update currentUser;
    system.debug('favorites ' + favorites);
    return favorites;
  }

  @AuraEnabled(cacheable=true)
  public static ProductCatalogPageResult getFavoriteProducts(String Favorites) {
    system.debug('Favorites ' + Favorites);
    ProductCatalogPageResult pageResult = new ProductCatalogPageResult();
    pageResult.products = new List<Wrapper_ProductCatalog>();
    system.debug('before User');
    List<String> FavoritesSku = new List<String>();
    if (Favorites != null) {
      FavoritesSku = Favorites.split(',');
    } else {
      User currentUser = DAL_ProductCatalog.getUser();
      System.debug('afterUser ' + currentUser);
      if (currentUser.My_Favorites__c != null) {
        FavoritesSku = currentUser.My_Favorites__c.split(',');
      }
    }
    User currentUser = DAL_ProductCatalog.getUser();
    System.debug('afterUser ' + currentUser);

    if (currentUser.My_Favorites__c != null)
      FavoritesSku = currentUser.My_Favorites__c.split(',');

    List<ProductCatalogue__c> allProducts = new List<ProductCatalogue__c>();

    if (currentUser.My_Favorites__c != null) {
      pageResult.products = Wrapper_ProductCatalog.convertToProductCatalogWrappers(
        DAL_ProductCatalog.getProductsCatalogBySkus(FavoritesSku),
        null
      );
    }

    system.debug('page result ' + pageResult);
    return pageResult;
  }

  @AuraEnabled
  public static Boolean clearMyFavorites() {
    User currentUser = DAL_ProductCatalog.getUser();
    currentUser.My_Favorites__c = null;
    update currentUser;
    return true;
  }

  //Search product Referential
  @AuraEnabled(cacheable=true)
  public static ProductCatalogPageResult getReferentialProduct(
    String searchKey,
    Decimal pageSize,
    Decimal pageNumber,
    List<String> stores
  ) {
    system.debug('searchig referential');
    ProductCatalogPageResult pageResult = new ProductCatalogPageResult();
    pageResult.products = new List<Wrapper_ProductCatalog>();
    List<ProductReferential__c> allPR = new List<ProductReferential__c>();

    //calc current offset by the page size and number
    Integer pSize = (Integer) pageSize;
    Integer offset = ((Integer) pageNumber - 1) * pSize;

    Store__c defaultStore = null;
    User currentUser = DAL_ProductCatalog.getUser();

    Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();

    defaultStore = (String.isNotEmpty(lastDigitalStore.StoreRetailId__c))
      ? DAL_ProductCatalog.getStoreByCode(lastDigitalStore.StoreRetailId__c)
      : null;

    pageResult.pageSize = pSize;
    pageResult.page = (Integer) pageNumber;

    allPR = DAL_ProductCatalog.getAllProductReferential(searchKey);
    pageResult.total = allPR.size();

    if (allPR.size() < pSize * (pageNumber - 1)) {
      pageResult.page = 1;
      offset = 0;
    }
    for (Integer i = offset; (i < offset + pSize) && (i < allPR.size()); i++) {
      pageResult.products.add(Wrapper_ProductCatalog.convertPRToProductCatalogWrapper(allPR[i]));
    }

    system.debug('page result ' + pageResult);
    return pageResult;
  }

  @AuraEnabled(cacheable=true)
  public static Boolean getRegionStock(String zoneName, String warehouseName, Id productId) {
    system.debug('zoneName ' + zoneName);
    system.debug('warehousName ' + warehouseName);
    system.debug('productId ' + productId);

    return DAL_ProductCatalog.haveStockInRegion(zoneName, warehouseName, productId);
    //return true;
  }

  @AuraEnabled /*(cacheable=true)*/
  public static String getPDF(String sku) {
    String pdf = WS_ProductPdf.getProductPdfFile(sku);
    DAL_ProductCatalog.updateProductPdf(sku, pdf);
    return pdf;
    /*String jsonPdfLink = JSON.serialize(pdfLink);
     return jsonPdfLink;*/
  }

  @AuraEnabled(cacheable=true)
  //public static Map<String , List<Wrapper_ProductCatalog>> getVariationsProducts(Wrapper_ProductCatalog product) {
  public static Map<String, List<Wrapper_ProductCatalog>> getVariationsProducts(String productS) {
    //system.debug('searching variations');
    Wrapper_ProductCatalog product = new Wrapper_ProductCatalog();
    product = (Wrapper_ProductCatalog) Json.deserialize(productS, Wrapper_ProductCatalog.class);
    system.debug('getVariationsProducts product' + product);
    Map<String, List<Wrapper_ProductCatalog>> variations = new Map<String, List<Wrapper_ProductCatalog>>();
    //Sizes
    if (
      product.productGroup == 'Souliers' ||
      product.productGroup == 'Ready to wear' ||
      product.productGroup == 'Accessoires' ||
      product.productGroup == 'Jewelry'
    ) {
      //variations.put('psizeProduct', new List<Wrapper_ProductCatalog>());
      List<ProductCatalogue__c> productsSize = new List<ProductCatalogue__c>();
      String Order = 'ASC';
      String OrderBy = 'SKU__c';
      String Condition = '';
      if (product.department == 'Belts' || product.department == 'Bracelet') {
        Order = 'DESC';
      }
      if (product.productGroup == 'Souliers') {
        OrderBy = 'en_E1_size__c';
        Condition = 'AND ShoeWidth__c = \'' + string.escapeSingleQuotes(product.ShoeWidth) + '\'';
      }
      productsSize = DAL_ProductCatalog.getSizes(
        product.defaultSku,
        product.MarketingColorId,
        Order,
        OrderBy,
        Condition
      );
      List<Wrapper_ProductCatalog> psize = new List<Wrapper_ProductCatalog>();
      if (productsSize.size() > 1) {
        for (ProductCatalogue__c p : productsSize) {
          psize.add(Wrapper_ProductCatalog.convertToProductCatalogWrapper(p, null));
        }
        //system.debug('psize' + psize);
      }
      variations.put('sizeProduct', psize);
    } else {
      List<Wrapper_ProductCatalog> psize = new List<Wrapper_ProductCatalog>();
      //variations.put('psizeProduct', new List<Wrapper_ProductCatalog>());
      List<ProductCatalogue__c> productsSize = new List<ProductCatalogue__c>();
      String assSize = '';
      if (product.AssociatedModelSize != null) {
        assSize = product.AssociatedModelSize;
        if (assSize.startsWith('[')) {
          assSize = assSize.substringAfter('[');
        }
        if (assSize.endsWith(']')) {
          assSize = assSize.substringBefore(']');
        }
      }
      //system.debug('assSize '+assSize);
      if (assSize != '') {
        productsSize = DAL_ProductCatalog.getOtherVariations(assSize);
        for (ProductCatalogue__c p : productsSize) {
          psize.add(Wrapper_ProductCatalog.convertToProductCatalogWrapper(p, null));
        }
      }
      //system.debug('psize' + psize);
      variations.put('sizeProduct', psize);
    }

    Set<Wrapper_ProductCatalog> pvariations = new Set<Wrapper_ProductCatalog>();
    List<String> listSkusVariations = new List<String>();

    //Materials
    List<ProductCatalogue__c> productsMaterials = new List<ProductCatalogue__c>();
    productsMaterials = DAL_ProductCatalog.getOtherVariations(product.AssociateMaterials);
    //Set<Wrapper_ProductCatalog> pmaterials = new List<Wrapper_ProductCatalog>();
    String colorVariations;
    String assColors;
    for (ProductCatalogue__c pm : productsMaterials) {
      if (pm.AssociateColors__c != null) {
        assColors = pm.AssociateColors__c;
        if (assColors.startsWith('[')) {
          assColors = assColors.substringAfter('[');
        }
        if (assColors.endsWith(']')) {
          assColors = assColors.substringBefore(']');
        }
        colorVariations = colorVariations + ',' + assColors;
      }
      if (!listSkusVariations.contains(pm.SKU__c)) {
        Wrapper_ProductCatalog wpc = Wrapper_ProductCatalog.convertToProductCatalogWrapper(
          pm,
          null
        );
        listSkusVariations.add(pm.SKU__c);
        pvariations.add(wpc);
      }
    }

    //SkinMaterials
    List<ProductCatalogue__c> productsSkinMaterials = new List<ProductCatalogue__c>();

    productsSkinMaterials = DAL_ProductCatalog.getSkinVariations(product.AssociateSkinMaterials);
    System.debug('getVariationsProducts productsSkinMaterials : ' + productsSkinMaterials);
    for (ProductCatalogue__c psm : productsSkinMaterials) {
      if (psm.AssociateColors__c != null) {
        assColors = psm.AssociateColors__c;
        if (assColors.startsWith('[')) {
          assColors = assColors.substringAfter('[');
        }
        if (assColors.endsWith(']')) {
          assColors = assColors.substringBefore(']');
        }
        colorVariations = colorVariations + ',' + assColors;
      }

      if (!listSkusVariations.contains(psm.SKU__c)) {
        Wrapper_ProductCatalog wpc = Wrapper_ProductCatalog.convertToProductCatalogWrapper(
          psm,
          null
        );
        listSkusVariations.add(psm.SKU__c);
        pvariations.add(wpc);
      }
    }

    //Colors
    List<ProductCatalogue__c> productColors = new List<ProductCatalogue__c>();
    String colorsTosearch = product.AssociateColors;
    if (String.isNotBlank(colorsTosearch)) {
      if (colorsTosearch.startsWith('[')) {
        colorsTosearch = colorsTosearch.substringAfter('[');
      }
      if (colorsTosearch.endsWith(']')) {
        colorsTosearch = colorsTosearch.substringBefore(']');
      }
      if (colorVariations != null) {
        colorsTosearch = colorVariations + ',' + colorsTosearch;
      }
      productColors = DAL_ProductCatalog.getColorVariations(colorsTosearch, product.sizeId);
      for (ProductCatalogue__c pc : productColors) {
        if (!listSkusVariations.contains(pc.SKU__c)) {
          Wrapper_ProductCatalog wpc = Wrapper_ProductCatalog.convertToProductCatalogWrapper(
            pc,
            null
          );
          listSkusVariations.add(pc.SKU__c);
          pvariations.add(wpc);
        }
      }
    }

    //System.debug('getVariationsProducts listSkusVariations: ' + listSkusVariations);

    List<Wrapper_ProductCatalog> listWrappersVariations = new List<Wrapper_ProductCatalog>(
      pvariations
    );

    // system.debug('getVariationsProduct listWrappersVariations : ' + listWrappersVariations);
    // system.debug('getVariationsProduct listWrappersVariations length : ' + listWrappersVariations.size());
    variations.put('variations', listWrappersVariations);
    return variations;
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, String> getOrderableStatus(String product, String selectedStores) {
    try {
      /*String username = 'pp_silvergate';
            String password = 'CroustiDemainLaPienses';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);*/

      // Object productObj = JSON.deserializeUntyped(product);

      Map<String, Object> productObj = (Map<String, Object>) JSON.deserializeUntyped(product);
      List<String> selectedStoresObj = (List<String>) System.JSON.deserialize(
        selectedStores,
        List<String>.class
      );

      System.debug('***************--------------------************');
      System.debug(JSON.deserializeUntyped(selectedStores));
      System.debug(selectedStoresObj);
      System.debug(selectedStoresObj[0]);
      System.debug('productObj: ' + productObj);
      System.debug('***************--------------------************');

      Set<String> countries = new Set<String>();
      Map<String, String> fullCountriesName = new Map<String, String>();
      Map<String, String> storeCodeForCountry = new Map<String, String>();
      // Set<String> stores = new Set<String>();
      for (Store__c s : [
        SELECT
          Id,
          StoreCountry__c,
          Store_CountryCode__c,
          MANAGEMENT_ZONE_LEVEL_TECH__c,
          RetailStoreId__c,
          Name,
          StoreType__c,
          Status__c,
          isXstore__c
        FROM Store__c
        WHERE RetailStoreId__c IN :selectedStoresObj
      ]) {
        if (s != null && s.StoreCountry__c != null && s.Status__c == 'Open') {
          if (s.StoreType__c != 'CSC') {
            System.debug(s);
            countries.add(s.Store_CountryCode__c);
            if (
              storeCodeForCountry.get(s.Store_CountryCode__c) == null &&
              s.RetailStoreId__c != null &&
              s.isXstore__c == true
            ) {
              storeCodeForCountry.put(s.Store_CountryCode__c, s.RetailStoreId__c);
            }
            fullCountriesName.put(s.Store_CountryCode__c, s.StoreCountry__c);
          }
        }
        //stores.add(s.RetailStoreId__c);
      }

      String results = '';
      Map<String, String> resultsMap = new Map<String, String>();
      for (String country : countries) {
        if (!productObj.isEmpty()) {
          if (storeCodeForCountry.containskey(country)) {
            String firstStoreForThisCountry = storeCodeForCountry.get(country);

            String reqBody =
              '{ "channel": "CSC", "requesting_system": "CATALOGUE_DESKTOP", "items": [{ "item_id": "' +
              (String) productObj.get('sku') +
              '", "qty": 1 }], "requesting_location": "' +
              firstStoreForThisCountry +
              '" }';

            Catalogue_Settings__c CS = Catalogue_Settings__c.getInstance(
              System.Label.WSCatalogueTECHUserId
            );

            String authorizationHeader =
              'Basic ' +
              EncodingUtil.base64Encode(
                Blob.valueOf(CS.Username_WS_Stock__c + ':' + CS.Password_WS_Stock__c)
              );
            //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFCatalogUser:SFCatalogUserLV2017*'));
            System.debug('Auth ' + authorizationHeader);

            HTTP_Utils request = new HTTP_Utils()
              .post(Label.KBRW_URL)
              //.post(Label. KBRW_URL 'https://lv-api-prp.vuitton.biz:11930/ws/KBRW_stocksAPI/1.0/api/stocks/v1/atp/')
              .header('Content-Type', 'application/json')
              .header('Encoding', 'UTF-8')
              .header('Accept', 'application/json')
              .header('Authorization', authorizationHeader)
              //.header('Authorization', 'Basic Y2F0YWxvZ3VldXNlcjpTRkNhdGFsb2dVc2VyTFYyMDE3Kg==')
              .body(reqBody)
              .timeout(120000)
              .call();

            Map<String, Object> response = request.getBodyResponse();

            // // If the request is successful, parse the JSON response.
            System.debug('/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/');
            System.debug(reqBody);
            System.debug(request.getBodyResponse());
            System.debug(response.get('items'));
            System.debug('/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/');

            List<Object> entriesArray = (List<Object>) response.get('items');
            System.debug(entriesArray);

            for (Object inidividualEntries : entriesArray) {
              Map<String, Object> ind = (Map<String, Object>) inidividualEntries;
              String isAvailable = (String) ind.get('available_to_order');
              Object leadTimeObj = ind.get('distribution_leadtime');
              Object pickupLocation = ind.get('pickup_location');

              Map<String, Object> leadTimeMap = (Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(leadTimeObj)
              );

              System.debug('getOrderableStatus leadTimeMap : ' + leadTimeMap);
              System.debug('getOrderableStatus entriesArray : ' + entriesArray);
              System.debug('getOrderableStatus ind : ' + ind);
              System.debug(
                'getOrderableStatus availableToOrder : ' + ind.get('available_to_order')
              );

              if (country != null && isAvailable != null) {
                //results += fullCountriesName.get(country) + ':' + country + ':' + isAvailable +  ':' + leadTimeMap.get('min') +  ':' + leadTimeMap.get('max') + ';';
                resultsMap.put(
                  fullCountriesName.get(country),
                  fullCountriesName.get(country) +
                    ':' +
                    country +
                    ':' +
                    isAvailable +
                    ':' +
                    leadTimeMap.get('min') +
                    ':' +
                    leadTimeMap.get('max') +
                    ';'
                );
              }

              List<Object> pickupLocationList = (List<Object>) pickupLocation;
              System.debug('getOrderableStatus pickupLocationList : ' + pickupLocationList);

              Integer counter = 1;
              for (Object pl : pickupLocationList) {
                Map<String, Object> plObj = (Map<String, Object>) pl;
                Map<String, Object> storeObj = (Map<String, Object>) plObj.get('store');
                resultsMap.put(
                  country + '_qty%' + counter,
                  storeObj.get('name') + ':' + plObj.get('qty') + ':' + storeObj.get('rms_id') + ';'
                );
                System.debug('getOrderableStatus resultsMap : ' + resultsMap);
                counter++;
              }
            }

            // if(request.statusCode() == 200){
            //  results.put((String)country, (String)(response.get('items')[0]));
            // }
          } else {
            String isAvailable = 'No Data';
            resultsMap.put(
              fullCountriesName.get(country),
              fullCountriesName.get(country) +
                ':' +
                country +
                ':' +
                isAvailable +
                ':' +
                null +
                ':' +
                null +
                ';'
            );
          }
        }
      }

      System.debug('getOrderableStatus resultMap : ' + JSON.serialize(resultsMap));
      return resultsMap;
    } catch (Exception e) {
      System.debug(e.getMessage());
      return null;
    } /*finally {
            return newProductAvailabilitiesMap;
        }*/
  }

  // FOR NEW KBRW AND ATG API
  // @AuraEnabled(cacheable=true)
  // public static Map<String, String> getCscAndEcoStatus(String itemId, String location){

  //    Map<String, String> countryStock = new Map<String, String>();

  //        ICX_CatalogATGResponse ATGResponse = ICX_WS_Catalog.getStockFromATGService(itemId, location);

  //        if(ATGResponse.LVResponse.data.storeList != null) {

  //            List<Store__c> listCountryName = [SELECT StoreCountry__c  FROM Store__c WHERE RetailStoreId__c = :location];
  //            String countryName = String.valueOf(listCountryName[0].StoreCountry__c);

  //            Catalogue_Settings__c digitalsStoresNoKbrw = Catalogue_Settings__c.getOrgDefaults();
  //            List<String> listDigitalStores = digitalsStoresNoKbrw?.DigitalsStoresNoKBRW__c?.split(',');

  //            if(listDigitalStores.contains(location)) {
  //                if(ATGResponse.LVResponse.data.storeList.get(0).itemList?.get(0).bucketList?.get(0).totalQuantity == '1') {
  //                    countryStock = mapCountryCSCOrderable('Available', 'Available', countryName, 'Orderable', '', '');
  //                }
  //                else if(ATGResponse.LVResponse.data.storeList.get(0).itemList?.get(0).bucketList?.get(0).totalQuantity == '0') {
  //                    countryStock = mapCountryCSCOrderable('Unavailable', 'Unavailable', countryName, 'Not Orderable', '', '');
  //                } else  countryStock = mapCountryCSCOrderable('No Data', 'No Data', countryName, 'No Data', '', '');

  //            } else {

  //                ICX_CatalogStockResponse resCSC = ICX_WS_Catalog.getStockRequest(ICX_WS_Catalog.Channel.CSC, itemId, location);
  //                ICX_CatalogStockResponse resECO = ICX_WS_Catalog.getStockRequest(ICX_WS_Catalog.Channel.ECO, itemId, location);

  //                String responseCSC = resCSC.items.get(0).available_to_order;
  //                String responseEco = resECO.items.get(0).available_to_order == 'Y' ? 'Available' : resECO.items.get(0).available_to_order == 'N' ?  'Unavailable' : 'No Data';

  //                if(responseCSC == 'Y') {
  //                    String ecoStatus = responseEco;
  //                    String cscStatus = 'Available';
  //                    String statusStore = 'Orderable';
  //                    String minLeadTime = String.valueOf(resCSC.items.get(0).distribution_leadtime.min);
  //                    String maxLeadTime = String.valueOf(resCSC.items.get(0).distribution_leadtime.max);
  //                    countryStock = mapCountryCSCOrderable(ecoStatus, cscStatus, countryName, statusStore, minLeadTime, maxLeadTime);
  //                } else if(responseCSC == 'N') {
  //                    String ecoStatus = responseEco;
  //                    String cscStatus = 'Unavailable';
  //                    String statusStore = 'Not Orderable';
  //                    countryStock = mapCountryCSCOrderable(ecoStatus, cscStatus, countryName, statusStore, '', '');
  //                } else {
  //                    countryStock = mapCountryCSCOrderable('No Data', 'No Data', countryName, 'No Data', '', '');
  //                }
  //            }

  //        } else {
  //            countryStock = mapCountryCSCOrderable('No Data', 'No Data', '', '', '', '');
  //        }

  //    return countryStock;

  // }

  // public static Map<String, String> mapCountryCSCOrderable(String EcoStatus, String CscStatus, String countryName, String status, String minLead, String maxLead){
  //    Map<String, String> countryStock = new Map<String, String> {
  //        'ECO' => EcoStatus,
  //        'CSC' => CscStatus,
  //        'countryName' => countryName,
  //        'status' => status,
  //        'minLead' => minLead,
  //        'maxLead' => maxLead
  //    };
  //    return countryStock;
  // }

  // // @AuraEnabled(cacheable=true)
  // // public static List<Map<String, String>> getCountryCscStatus(String itemId, List<String> storeList){

  // //     Map<String, String> storeCSCCountryMap = new Map<String, String>();
  // //     List<Map<String, String>> statusList = new List<Map<String, String>>();
  // //     Map<String, String> countryStock = new Map<String, String>();

  // //     List<Store__c> storeCSCList = [SELECT  StoreCountry__c,  ecomStore__c
  // //                                     FROM Store__c
  // //                                     WHERE RetailStoreId__c IN :storeList];

  // //     for(Store__c CSCStore :storeCSCList) {
  // //         if(CSCStore.ecomStore__c != null) {
  // //             storeCSCCountryMap.put(CSCStore.StoreCountry__c, CSCStore.ecomStore__c);
  // //         }else if(!storeCSCCountryMap.containsKey(CSCStore.StoreCountry__c)) {
  // //             storeCSCCountryMap.put(CSCStore.StoreCountry__c, null);
  // //         }

  // //         System.debug('storeCSCCountryMap : '+ storeCSCCountryMap);
  // //     }

  // //     for(string CSCStore :storeCSCCountryMap.keySet()) {
  // //         if(storeCSCCountryMap.get(CSCStore) != null){

  // //             ICX_CatalogStockResponse res = ICX_WS_Catalog.getStockRequest(ICX_WS_Catalog.Channel.CSC, itemId, storeCSCCountryMap.get(CSCStore));
  // //             String statusStore = res.items.get(0).available_to_order == 'Y' ? 'Orderable' : res.items.get(0).available_to_order == 'N' ? 'Not Orderable' : 'No Data';
  // //             String minLeadTime = String.valueOf(res.items.get(0).distribution_leadtime.min);
  // //             String maxLeadTime = String.valueOf(res.items.get(0).distribution_leadtime.max);
  // //             countryStock = mapCountryCSCOrderable(CSCStore, statusStore, minLeadTime, maxLeadTime);
  // //             statusList.add(countryStock);
  // //          }
  // //          else {
  // //             countryStock = mapCountryCSCOrderable(CSCStore, 'Not Orderable', 'No Data', 'No Data');
  // //             statusList.add(countryStock);
  // //          }

  // //     }
  // //     system.debug('statusList' + statusList);
  // //     return statusList;

  // // }

  @AuraEnabled(cacheable=true)
  public static boolean environmentalSectionCountryFilter(List<String> lstStoreCodes) {
    Boolean showEnvironmentalSection = false;
    List<Store__c> lstStore = DAL_ProductCatalog.getStoresByCodes(lstStoreCodes);
    for (Store__c myStore : lstStore) {
      if (myStore.StoreCountry__c == 'FRANCE' || myStore.StoreCountry__c == 'MONACO')
        showEnvironmentalSection = true;
    }
    return showEnvironmentalSection;
  }

  @AuraEnabled(cacheable=true)
  public static String getTreekitBaseUrl() {
    return  Catalogue_Settings__c.getOrgDefaults().treekitBaseUrl__c;

  }
  

  @AuraEnabled(cacheable=true)
  public static List<ICX_CustomizableProducts__mdt> getCustomizableProdMDT()
  {
      List<ICX_CustomizableProducts__mdt> customProductMDT = DAL_ProductCatalog.getPersonalizedProducts();
      system.debug('Show results right here' + customProductMDT);
      return customProductMDT;
  }
    
    
    @AuraEnabled(cacheable=true)
    public static String generateTokenEncrypted(String dataToEncrypt)
    {
        String privateKey = Catalogue_Settings__c.getOrgDefaults().treekitPrivateKey__c;
        Blob key = Blob.valueOf(privateKey);
        Blob data = Blob.valueOf(dataToEncrypt);
        
        Blob hmacSHA256 = generateHmacSHA256(data, key);
        String hashInBase64 = EncodingUtil.base64Encode(hmacSHA256);
        system.debug('Webview alpha token '+ hashInBase64.replace('/', '_'));
        return hashInBase64.replace('/', '_');
    }
    
  public static Blob generateHmacSHA256(Blob data, Blob key) {

        Blob output = null;
        try {
            String algorithmName = 'HmacSHA256';
            Blob hmacData = Crypto.generateMac(algorithmName, data, key);
            output = hmacData;
        } catch (Exception e) {
            // Handle exceptions here
        }
        return output;
    }

@AuraEnabled
  public static Boolean hasCustomPermission(){
    return FeatureManagement.checkPermission('ICX_AlphaWebview');
  }
    
}