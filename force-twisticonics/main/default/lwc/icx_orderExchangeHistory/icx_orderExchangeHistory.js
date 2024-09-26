import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { publish, subscribe, MessageContext } from 'lightning/messageService';
import ORDER_REFRESH_MESSAGE from '@salesforce/messageChannel/OrderRefresh__c';
import getProductDetails from '@salesforce/apex/Account_OrderDetailsControllerLC.getOrderDetailsTwistV2';

import defaultTemplate from './icx_orderExchangeHistory.html';
import templateInOrderExchange from './icx_orderExchangeHistoryInOrderExchange.html';

export default class Icx_orderExchangeHistory extends NavigationMixin(LightningElement) {
    @api orderid; // Salesforce ID    
    @api orderdetailsapi;

    @track isLoading = true;

    isRecordId = true;

    @track exchangeRecords = [];
    @track hasExchangeRecords;

    /** Load context for Lightning Messaging Service */
    @wire(MessageContext) messageContext;

    /** Subscription for Order Refresh Lightning message */
    refreshOrderSubscription;

    // getProductDetails({orderId: this.recordId, isRecordId: this.isRecordId})
    // .then(result => {
    //         this.orderDetails = result;
    //         console.log('JGU getProductDetails : '+JSON.stringify(result));
    //         this.error = undefined;
    //     })
    //     .catch(error => {
    //         console.log('catch error.message: ' + JSON.stringify(error));
    //         console.log('catch error.message: ' + error.body.message);
    //         this.error = error;
    //         this.orderDetails = undefined;
    //     });

    // Allow to manage dynamicly the height
    get commentHeight() {
        // // if no records
        // if(this.records.length==0){//set the minimum height
        //     return 'height:1rem;';
        // }
        // // if more than 2 records
        // else if(this.records.length>2){//set the max height
        //         return 'height:12rem;';
        // }
        // // in other cases
        // return '';//don't set any height (height will be dynamic)
        return 'height:2rem;';
    }

    render() {
        return this.orderdetailsapi.isExchange ? templateInOrderExchange : defaultTemplate;
    }

    onRefresh() {
        this.getExchangeDetails(this.orderdetailsapi);
    }

    setData(dataRecords) {
        console.log('icx_orderExchangeHistory: setData(dataRecords):' + dataRecords);
        this.exchangeRecords = JSON.parse(dataRecords);
        this.hasExchangeRecords = (this.exchangeRecords.length > 0);
    }

    // Retrieve exchange Shipping Group
    async getExchangeDetails(orderdetailsapi) {
        this.isLoading = true;

        console.log('icx_orderExchangeHistory: getExchangeDetails : ' + orderdetailsapi);
        const sgDetailsBySgIdp = new Map();
        const sgInPromise = new Set();
        //map1.set('ShippingId', 'orderDetails');

        const promiseList = [];

        // get the list of SG in current order
        orderdetailsapi.order_lines.forEach(sg => {
            sgDetailsBySgIdp.set(sg.request_id, sg);
            console.log('icx_orderExchangeHistory: sgDetailsBySgIdp: ' + sg.request_id);
        });

        if (orderdetailsapi.isExchange) {
            // We have to retrieve the orderId of the initial order

            orderdetailsapi.order_lines.forEach(sg => {

                // For Each linked SG
                sg.linked_shipping_groups.forEach(lsg => {
                    if (lsg.fulfilment_type == 'RETURN') {
                        // If the linked SG is not one of the current Order => it is the initial SG of the Exchange 
                        if (!sgDetailsBySgIdp.get(lsg.request_id) && !sgInPromise.has(lsg.request_id)) {

                            console.log('icx_orderExchangeHistory: getProductDetails({orderId: ' + lsg.request_id + ', isRecordId: false})');
                            // We retrieve the detail of the linked SG
                            promiseList.push(new Promise((resolve, reject) => getProductDetails({ orderId: lsg.request_id, isRecordId: false }).then(result => {
                                resolve(result);
                            })
                                .catch(error => {
                                    reject(error);
                                })
                            ));
                            sgInPromise.add(lsg.request_id);
                        }
                    }
                })

            });

            Promise.all(promiseList).then((values) => {
                let exchangeRecords = [];
                let orderDisplayed = [];

                values.forEach(orderDetails => {
                    let exchangeRecord = new Map();

                    if (!orderDisplayed.includes(orderDetails.order_id)) {
                        exchangeRecord.set('OrderSFId', orderDetails.order_SF_Id);
                        exchangeRecord.set('OrderId', orderDetails.order_id);
                        exchangeRecords.push(Object.fromEntries(exchangeRecord));
                        orderDisplayed.push(orderDetails.order_id);
                    }
                });

                this.isLoading = false;
                this.setData(JSON.stringify(exchangeRecords));
            });

        }
        else {
            // For each Return SG we check if it exists an Exchange Order
            orderdetailsapi.order_lines.forEach(sg => {
                // If the SG is a RETRUN
                if (sg.isReturn) {
                    // For Each linked SG
                    sg.linked_shipping_groups.forEach(lsg => {
                        // If the linked SG is not one of the current Order => it is an Exchange 
                        if (!sgDetailsBySgIdp.get(lsg.request_id) && !sgInPromise.has(lsg.request_id)) {
                            console.log('icx_orderExchangeHistory: getProductDetails({orderId: ' + lsg.request_id + ', isRecordId: false})');
                            sgInPromise.add(lsg.request_id);
                            // We retrieve the detail of the linked SG
                            promiseList.push(new Promise((resolve, reject) => getProductDetails({ orderId: lsg.request_id, isRecordId: false }).then(result => {
                                resolve(result);
                            })
                                .catch(error => {
                                    reject(error);
                                })
                            ));
                        }

                    })
                }
            });

            Promise.all(promiseList).then((values) => {
                console.log('icx_orderExchangeHistory: inside Promise.All');
                console.log(values);
                console.log('icx_orderExchangeHistory: inside Promise.All =>' + JSON.stringify(values));

                // let exchangeRecord;
                let orderExcByOrderId = new Map();
                // Map<Order_Exchange, List<SG_Exchange>)>
                let listOfSgExcByOrderExch = new Map();

                let exchangeRecords = [];

                // map1.set('a', 1);

                // 1 - Construct a Map<Shipping.requestId, orderDetails>
                values.forEach(orderDetails => {
                    if (!orderExcByOrderId.has(orderDetails.order_id)) {
                        orderExcByOrderId.set(orderDetails.order_id, orderDetails);
                        listOfSgExcByOrderExch.set(orderDetails.order_id, { "sgList": [], "sgExchList": [] });
                    }

                    (orderDetails.order_lines).forEach(shipping => {
                        console.log('icx_orderExchangeHistory: listOfSgExcByOrderExch.get(orderDetails.order_id).sgExchList.push :' + shipping.request_id);
                        listOfSgExcByOrderExch.get(orderDetails.order_id).sgExchList.push(shipping);

                        (shipping.linked_shipping_groups).forEach(linkedSG => {
                            if (sgDetailsBySgIdp.has(linkedSG.request_id)) {
                                console.log('icx_orderExchangeHistory: listOfSgExcByOrderExch.get(orderDetails.order_id).sgList.push :' + linkedSG.request_id);
                                listOfSgExcByOrderExch.get(orderDetails.order_id).sgList.push(sgDetailsBySgIdp.get(linkedSG.request_id));
                            }
                        });
                    });
                });

                console.log('icx_orderExchangeHistory: this.exchangeRecords :' + this.exchangeRecords);
                console.log('icx_orderExchangeHistory: listOfSgExcByOrderExchs :' + JSON.stringify(listOfSgExcByOrderExch));


                listOfSgExcByOrderExch.forEach(function (value, key) {
                    console.log('icx_orderExchangeHistory: listOfSgExcByOrderExch.forEach:key' + key);
                    console.log('icx_orderExchangeHistory: listOfSgExcByOrderExch.forEach:value' + value);
                    let orderDetails = orderExcByOrderId.get(key);

                    let exchangeRecord = new Map();
                    let carriageReturn = '\n';

                    let sgListDisplayed = [];

                    (listOfSgExcByOrderExch.get(key).sgList).forEach(shipping => {
                        let shippingNumberOld = '';
                        let shippingQtyOld = '';

                        if (!sgListDisplayed.includes(shipping.request_id)) {
                            if (exchangeRecord.has('shippingNumber')) {
                                shippingNumberOld = exchangeRecord.get('shippingNumber') + carriageReturn;
                                shippingQtyOld = exchangeRecord.get('shippingQty') + carriageReturn;
                            }

                            exchangeRecord.set('shippingNumber', shippingNumberOld + shipping.productName);
                            exchangeRecord.set('shippingQty', shippingQtyOld + shipping.qty);

                            sgListDisplayed.push(shipping.request_id);
                        }
                    });

                    exchangeRecord.set('OrderId', orderDetails.order_id);
                    exchangeRecord.set('OrderSFId', orderDetails.order_SF_Id);
                    (listOfSgExcByOrderExch.get(key).sgExchList).forEach(shipping => {
                        let shippingExchQtyOld = '';
                        let shippingExchPriceOld = '';
                        let shippingExchProductNameOld = '';

                        if (exchangeRecord.has('shippingExchQty')) {
                            shippingExchQtyOld = exchangeRecord.get('shippingExchQty') + carriageReturn;
                            shippingExchPriceOld = exchangeRecord.get('shippingExchPrice') + carriageReturn;
                            shippingExchProductNameOld = exchangeRecord.get('shippingExchProductName') + carriageReturn;
                        }

                        exchangeRecord.set('shippingExchQty', shippingExchQtyOld + shipping.qty);
                        exchangeRecord.set('shippingExchPrice', shippingExchPriceOld + shipping.initialPrice);
                        exchangeRecord.set('shippingExchProductName', shippingExchProductNameOld + shipping.productName);
                    });

                    exchangeRecord.set('Date', orderDetails.createdDate);
                    exchangeRecord.set('Owner', orderDetails.ca.Name);
                    exchangeRecord.set('OrderStatus', orderDetails.orderStatusIconics);

                    exchangeRecords.push(Object.fromEntries(exchangeRecord));

                    console.log('icx_orderExchangeHistory: Object.fromEntries(exchangeRecord):' + JSON.stringify(exchangeRecords));
                }
                )

                // let exchangeRecord = new Map();

                // exchangeRecord.set('shippingNumber', '1234567\n9876543');
                // exchangeRecord.set('shippingQty', '1\n1');

                // //exchangeRecords.push(exchangeRecord);
                // exchangeRecords.push(Object.fromEntries(exchangeRecord));

                this.isLoading = false;

                //this.setData([{'shippingNumber':'123465','shippingQty':'10' }]);
                // exchangeRecords.push({'shippingNumber':'123465','shippingQty':'10' });
                //this.exchangeRecords = exchangeRecords;
                this.setData(JSON.stringify(exchangeRecords));
                // return exchangeRecords;
            });
        }

    }

    // init lifecycle hook known as connectedCallback
    connectedCallback() {
        // Subscribe to ProductSelected message
        this.refreshOrderSubscription = subscribe(
            this.messageContext,
            ORDER_REFRESH_MESSAGE,
            (message) => this.onRefresh()
        );

        this.getExchangeDetails(this.orderdetailsapi);
    }

    handleOpenRecord(event) {
        // console.log(event);
        // console.log(JSON.parse(JSON.stringify(event.currentTarget.dataset)));
        // console.log(event.currentTarget.dataset.recordId);
        // console.log(event.target.dataset.recordId);

        // Stop the event's default behavior (don't follow the HREF link) and prevent click bubbling up in the DOM...
        event.preventDefault();
        event.stopPropagation();
        // Navigate as requested...
        // console.log('handleOpenRecord:'+event.currentTarget.dataset);

        this.navigateToRecordPage(event.currentTarget.dataset.recordId);
    }

    navigateToRecordPage(navigateToId) {
        // console.log('Try to open ID: '+navigateToId);
        // Navigate to the Order home page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: navigateToId,
                actionName: 'view',
            },
        });
    }
}