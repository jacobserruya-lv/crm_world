global with sharing class BL_ICON_RecentlyViewed extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
     
    global Object executeGET(){
       String objectName = (getPathParameter('objectName') != null ? getPathParameter('objectName') : null);
        switch on objectName {
           when 'clients' {
               return new BL_WS_Response(BL_ICON_RecentlyViewed_Helper.getRecentlyViewedClient());
            }
           when 'look-shares' {
               return new BL_WS_Response(BL_ICON_RecentlyViewed_Helper.getRecentlyViewedLookShare());
           }
           when 'purchase-products'{
                return new BL_WS_Response(BL_ICON_RecentlyViewed_Helper.getRecentlyViewedPurchaseProduct());
           }
           when 'care-services'{
               return new BL_WS_Response(BL_ICON_RecentlyViewed_Helper.getRecentlyViewedCareService());
             }
            when 'events'{
                return new BL_WS_Response(BL_ICON_RecentlyViewed_Helper.getRecentlyViewedEvents());
            }
            when else {
                return new BL_WS_Response(BL_ICON_RecentlyViewed_Helper.getRecentlyViewedAll());
            }
        }
    }
}