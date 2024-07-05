import { LightningElement , api ,wire,track} from 'lwc';
import getDigitalOrderList from '@salesforce/apex/Account_DigitalOrderListControllerLWC.getDigitalOrder';
import { NavigationMixin } from 'lightning/navigation';

export default class Account_DigitalOrderList extends NavigationMixin(LightningElement) {

    @api recordId; 
    orderList ;
    visibleOrder;
    orderListSize = 0;
    @wire(getDigitalOrderList,{ accountId:'$recordId'})
    wiredOrders({error,data}){
      if(data){
        var storeList = data.listStore;

        var today = new Date().toLocaleString('en-us', { year: 'numeric', month: 'short', day: 'numeric' });
        var lastWeek = new Date();
        lastWeek.setDate( lastWeek.getDate() - 7 );
        var lastWeekDate = lastWeek.toLocaleString('en-us', { year: 'numeric', month: 'short', day: 'numeric' });

        let tempAllRecords = Object.assign([], data.listOrder);
        
        for (let j = 0; j < data.listOrder.length; j++) {
         
          let tempRec = Object.assign({}, tempAllRecords[j]); 
          var Orderdate = tempRec.OrderDate.split("-");
          var LastUpdate = tempRec.LastUpdate.split("-");

          let noStore = {Id:'',Name:tempRec.StoreCode,RetailStoreId__c:tempRec.StoreCode,StoreType__c:'N/A'};
          tempRec.StoreCode = (storeList[tempRec.StoreCode] ? storeList[tempRec.StoreCode] : noStore) ;
          tempRec.AccountId = this.recordId;
          tempRec.OrderDate = new Date(Orderdate[2], Orderdate[0] - 1, Orderdate[1]).toLocaleString('en-us', { year: 'numeric', month: 'short', day: 'numeric' });
          tempRec.LastUpdate = new Date(LastUpdate[2], LastUpdate[0] - 1, LastUpdate[1]).toLocaleString('en-us', { year: 'numeric', month: 'short', day: 'numeric' });
          tempRec.Perso = tempRec.MyPersoNumber != null ? '' : 'slds-hide';
          tempAllRecords[j] = tempRec;
        }
        var ords = tempAllRecords.filter( element => element.Status != 'NO_PENDING_ACTION' || 
                                                 (element.Status == 'NO_PENDING_ACTION' && 
                                                 new Date(element.LastUpdate) > new Date(lastWeekDate) && 
                                                 new Date(element.LastUpdate) <= new Date(today)));
        this.orderListSize = ords.length;
        this.orderList = ords.sort((a, b) => new Date(b.OrderDate) > new Date(a.OrderDate) ? 1 : -1) ;
      }
      if(error){
          console.error(error);
      }

    }
    get displayOrder() {
      return this.orderListSize > 0;
    }

    updateOrderHandler(event){
      this.visibleOrder=[...event.detail.records];
      console.log(event.detail.records);
    }

    showData(event){
      var shippingId = event.currentTarget.dataset.shipping;
      this.template.querySelector(`[data-id="${shippingId}"]`).className='';
    
    } 
    hideData(event){
      var shippingId = event.currentTarget.dataset.shipping;
      this.template.querySelector(`[data-id="${shippingId}"]`).className='slds-hide';;
    }
    openOrder(event){
      var orderNumber = event.currentTarget.dataset.order;
      var value = this.orderList.filter(item => item.OrderNumber == orderNumber ); 
      this.handleNavigate(orderNumber,value);
     
    }
   
    handleNavigate(orderNumber ,orders) {

      var ord = btoa(unescape(encodeURIComponent(JSON.stringify(orders))));

     this[NavigationMixin.Navigate]({
        type: "standard__component",
        attributes: {
            componentName: "c__NavigationAccount_DigitalOrderDetails",
            apiName: 'Name_of_tab'

        },
        state: {
          c__orderNumber:orderNumber,
          c__orders:ord,
          c__accountId: this.recordId,
        }
    });
    /*var compDefinition = {
        componentDef: "c:account_DigitalOrderDetails",
        attributes: {
            accountId: this.recordId,
            orderNumber: orderNumber,
            orders: orders
        }
      };
      // Base64 encode the compDefinition JS object
      var encodedCompDef = btoa(JSON.stringify(compDefinition));
      this[NavigationMixin.Navigate]({
          type: 'standard__webPage',
          attributes: {
              url: '/one/one.app#' + encodedCompDef,

          }
      });*/
  }

    

}