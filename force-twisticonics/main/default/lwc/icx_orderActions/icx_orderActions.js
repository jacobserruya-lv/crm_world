import { api, wire, track } from 'lwc';
import LightningModal from 'lightning/modal';

import getActionReasons from '@salesforce/apex/OrderActionReasonService.getByAction';
import actionReturn from '@salesforce/apex/Account_OrderDetailsControllerLC.sendActionReturn';
import sendAction from '@salesforce/apex/Account_OrderDetailsControllerLC.sendAction';
import getProductDetails from '@salesforce/apex/Account_OrderDetailsControllerLC.getOrderDetailsTwistV2';

// Action Exchange
import getUserLocal from '@salesforce/apex/ICX_TWIST_OOB.getUserLocal';
import { fetchOOB } from 'c/icx_oob_utils';

import getOOBInitCartEndpoint from '@salesforce/apex/ICX_TWIST_OOB.getOOBInitCartEndpoint';
import getRedirectionURL from '@salesforce/apex/ICX_TWIST_OOB.getRedirectionURL';
import getRedirectionEndpoint from '@salesforce/apex/ICX_TWIST_OOB.getRedirectionEndpoint';
import getCartTranslation from '@salesforce/apex/ICX_TWIST_OOB.getCartTranslation';


import insertTraceability from '@salesforce/apex/TraceabilityService.insertTraceability';

import downloadInvoice from '@salesforce/apex/ICX_DownloadInvoice.downloadInvoice';


import { getRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import RMS_ID_FIELD from '@salesforce/schema/User.RMS_ID__c';
import WWEMPLOYEENUMBER_FIELD from '@salesforce/schema/User.WWEmployeeNumber__c';
import LightningAlert from 'lightning/alert';



export default class Icx_orderActionsExchangeReturn extends LightningModal {
    @api orderid; // Order__c.orderNumber__c
    @api content;
    //@api orderdetailsapi; // List of shipping group
    //@api accountid;
    //@api dreamid;

    @api orderdetailsapi;
    @api products;

    @api orderaction; // [{ label: 'Exchange', value: 'exchange' }, { label: 'Return', value: 'return' }, ...]

    @api isoneproductonly = false; // if 'true', user can select only one product

    @track isLoading = false;

    @track userId = USER_ID;

    @track mapOfSgLinkedBySg = new Map();

    @track initialReturn = [];


    // init lifecycle hook known as connectedCallback
    connectedCallback() {
        //this.getExchangeDetails(this.orderdetailsapi);

        // In order to identify the SG in the order
        const sgDetailsBySgIdp = new Map();
        // In order to identify the SG, we need to retrieve the data
        const sgInPromise = new Set();
        // The list of calls tho execute
        const promiseList = [];

        // this.isLoading = true;

        // 0 - get the list of SG in current order
        this.orderdetailsapi.order_lines.forEach(sg => {
            sgDetailsBySgIdp.set(sg.request_id, sg);
            console.log('icx_orderExchangeHistory: sgDetailsBySgIdp: ' + sg.request_id);
        });


        // 1- Get SG exchange history
        // IF (orderAction == cancelReturn)
        if ((this.orderaction.value == "cancelReturn") || (this.orderaction.value == "cancelShipping")) {
            // if at least one product is linked to an exchange
            this.products.forEach(product => {
                if (product.order_type == 'EXCHANGE') {
                    // Retrieve the list of SG linked to this exchange
                    product.linked_shipping_groups.forEach(lsg => {
                        // If the linked SG is not one of the current Order => it is the initial SG of the Exchange 
                        if (!sgDetailsBySgIdp.get(lsg.request_id) && !sgInPromise.has(lsg.request_id)) {

                            if (!this.mapOfSgLinkedBySg.has(product.shippingNumber)) {
                                this.mapOfSgLinkedBySg.set(product.shippingNumber, new Map());
                                this.mapOfSgLinkedBySg.get(product.shippingNumber).set(lsg.request_id, new Map());
                            }
                            else if (!this.mapOfSgLinkedBySg.get(product.shippingNumber).has(lsg.request_id)) {
                                this.mapOfSgLinkedBySg.get(product.shippingNumber).set(lsg.request_id, new Map());
                            }

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
                    });
                }
            });
        }
        // THEN get details of SG of exchange => new attributes : shippingLinkedExchanged
        // IF (orderAction == cancel) AND (orderType = 'Exchange')
        // THEN get details of SG of order source => new attributes : shippingLinkedOriginals

        console.log('this.mapOfSgLinkedBySg :' + this.mapOfSgLinkedBySg);


        Promise.all(promiseList).then((values) => {
            console.log('icx_orderExchangeHistory: inside Promise.All');
            console.log(values);
            //console.log('icx_orderExchangeHistory: inside Promise.All =>'+JSON.stringify(values));

            const sgLinked = new Map();

            // 1 - Construct a Map<Shipping.requestId, order_line>
            values.forEach(orderDetails => {
                (orderDetails.order_lines).forEach(product => {
                    console.log('icx_orderExchangeHistory: sgLinked.set(' + product.request_id + '//' + product + ')')
                    sgLinked.set(product.request_id, product);
                });
            });

            console.log('icx_orderExchangeHistory: sgLinked :' + JSON.stringify(sgLinked.entries()));

            // Update the Map
            this.mapOfSgLinkedBySg.forEach((valueSg, keySg) => {
                this.mapOfSgLinkedBySg.get(keySg).forEach((valueSgLinked, keySgLinked) => {
                    console.log('icx_orderExchangeHistory: this.mapOfSgLinkedBySg :' + keySg + ' // ' + keySgLinked + ' / ' + JSON.stringify(valueSgLinked));
                    if (sgLinked.has(keySgLinked)) {
                        this.mapOfSgLinkedBySg.get(keySg).set(keySgLinked, sgLinked.get(keySgLinked));
                        if ((this.orderaction.value == "cancelShipping")) {
                            this.initialReturn.push(sgLinked.get(keySgLinked));
                        }
                    }
                    console.log('icx_orderExchangeHistory: this.mapOfSgLinkedBySg - 2 :' + JSON.stringify(this.mapOfSgLinkedBySg.get(keySg).entries()));
                });
            });



            this.isLoading = false;
            console.log('isLoading :' + this.isLoading);
            //this.setData(JSON.stringify(exchangeRecords));
        });
    }

    @wire(getRecord, {
        recordId: "$userId",
        fields: [NAME_FIELD, RMS_ID_FIELD, WWEMPLOYEENUMBER_FIELD]
    }) wireuser({ error, data }) {
        console.log('JGU-icx_orderHighlightPanel-@wire (getRecord User - data) : ' + JSON.stringify(data));
        // console.log('JGU-@wire (getRecord User - error) : '+JSON.stringify(error));
        if (error) {
            this.errorUser = error;
        } else if (data) {
            this.userName = data.fields.Name.value;
            this.wwemployeeid = data.fields.WWEmployeeNumber__c.value;
            if (data.fields.RMS_ID__c.value) this.userName = this.userName + ' - ' + data.fields.RMS_ID__c.value;
        }
    }

    @wire(getActionReasons, { action: '$orderaction.value' })
    wiredgetActionReasons({ error, data }) {
        let options = [];
        if (data) {
            for (let i = 0; i < data.length; i++) {
                let option = { label: data[i].MasterLabel, value: data[i].Reason_Code__c };
                options.push(option);
            }

        }
        else if (error) {

        }
        console.log('reasons:' + options);
        this.reasons = options;
    }

    reasons;

    message = 'Nothing to display';

    handleLoading() {
        this.isLoading = true;
        this.disableClose = true;
        setTimeout(() => {
            this.isLoading = false;
            this.disableClose = false;
            var bodyEvent = {
                status: 'Success',
                message: 'Message success'
            };
            this.close(bodyEvent);
        }, 5000);
    }

    handleCancel() {
        this.close('cancel');
    }

    async handleSave() {
        this.isLoading = true;
        this.disableClose = true;

        const tiles = this.template.querySelectorAll('c-icx_order-actions-shipping-tile');
        let isOk = false;
        let jsonProducts = [];

        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            element.reportValidity();
        });

        // Get 

        // For each products
        for (let i = 0; i < tiles.length; i++) {
            let jsonRecord;
            // if the product is selected
            if (tiles[i].isChecked) {
                isOk = ((tiles[i].reasons.length == 0) || (tiles[i].reasonSelected != 'none'));
                jsonRecord = { "product": tiles[i].product, "reasonSelected": tiles[i].reasonSelected }
                jsonProducts.push(jsonRecord);

                // if the product cancelled is related to other shipping
                if (this.mapOfSgLinkedBySg.has(tiles[i].product.shippingNumber)) {
                    this.mapOfSgLinkedBySg.get(tiles[i].product.shippingNumber).forEach(value => {
                        jsonRecord = { "product": value, "reasonSelected": tiles[i].reasonSelected };
                        jsonProducts.push(jsonRecord);
                    });
                }

            }
        }


        if (isOk) {
            console.log('JGU-before1:' + JSON.stringify(jsonProducts));

            var bodyToSend, response;
            var jsonResponse = [];

            // If "return"
            if (this.orderaction.value == 'return'
                || this.orderaction.value == 'declareNoShowCOD') {
                // For each product selected
                for (let i = 0; i < jsonProducts.length; i++) {

                    bodyToSend = {
                        requesting_system: 'ICONICS',
                        channel: "CSC",
                        order_type: "SALE",
                        employee_id: this.wwemployeeid,
                        requesting_location: jsonProducts[i].product.sourceStore?.RetailStoreId__c,
                        request_id_to_return: jsonProducts[i].product.request_id,
                        reason_code: jsonProducts[i].reasonSelected
                    }

                    // If no reason code selected then no need to send it
                    if (jsonProducts[i].reasonSelected == 'none') {
                        delete bodyToSend.reason_code;
                    }

                    console.log('JGU-bodyToSend:' + JSON.stringify(bodyToSend));
                    console.log('JGU-orderID:' + this.orderid);
                    console.log('JGU-orderaction:' + this.orderaction.value);

                    let orderNumber = this.orderid;
                    console.log('JGU-orderNumber2:' + orderNumber);

                    // await actionReturn({
                    //     body: bodyToSend,
                    //     orderNumber: this.orderid,
                    //     shippingId: jsonProducts[i].product?.reason.Id,
                    //     orderAction: this.orderaction.value
                    // })

                    await actionReturn({
                        orderType: 'SALE',
                        employeeId: this.wwemployeeid,
                        requestingLocation: jsonProducts[i].product.sourceStore?.RetailStoreId__c,
                        requestIdToReturn: jsonProducts[i].product.request_id,
                        reasonCode: jsonProducts[i].reasonSelected,
                        orderNumber: this.orderid,
                        shippingId: jsonProducts[i].product?.reason.Id,
                        orderAction: this.orderaction.value
                    })
                        .then(result => {
                            console.log('JGU-result OK: ' + JSON.stringify(result));
                            jsonResponse.push(result);
                        })
                        .catch(error => {
                            console.log('JGU-result Error: ' + JSON.stringify(error));
                            jsonResponse.push(error);
                        });
                }
            }


            //naomi 19/05 change cancel from fulfillement action to order action
            if (this.orderaction.value.includes('cancel')) {
                console.log(this.orderaction.value);
                for (let i = 0; i < jsonProducts.length; i++) {

                    // /!\ When the 'cancel' is asked by the client we have to send 'cancel_by_customer' instead of 'cancel'
                    let reasonSelectedAction = 'cancel';
                    if (jsonProducts[i].reasonSelected == 'Client Cancelled') {
                        reasonSelectedAction = 'cancel_by_customer';
                    }

                    console.log('Cancel: ' + jsonProducts[i].product?.request_id + ' / action: ' + reasonSelectedAction + ' / actionMessage: ' + jsonProducts[i].reasonSelected + ' / item_id: ' + jsonProducts[i].product?.item_id);

                    await sendAction({
                        orderId: jsonProducts[i].product?.request_id,
                        // sku: jsonProducts[i].product?.item_id,
                        actionMessage: jsonProducts[i].reasonSelected,
                        orderAction: reasonSelectedAction,
                        shippingId: jsonProducts[i].product?.reason.Id
                    })
                        .then(result => {

                            console.log('JGU-result: ' + result);
                            //this.getOrderDetailsApex();
                            // this.orderRefresh(jsonProducts[i].product?.item_id);
                            jsonResponse.push({ status: "success", message: result.message });

                            // this.template.querySelector('[data-id="cmb-reason"]').disabled = false;  
                            // this.template.querySelector('[data-id="cmb-reason"]').value = false;        
                            // this.template.querySelector('[data-id="btn-submit"]').disabled = true;
                        })
                        .catch(error => {
                            console.error(error);
                            jsonResponse.push(error);

                        });
                }
            }

            if (this.orderaction.value == 'exchange') {
                try {
                    // let sfAgentAccessToken;
                    // let endpoint;
                    // let userLocal;     
                    // let userIdentity;
                    let payload, calloutURI;
                    // let redirectionURL, localURL;

                    // *********************** //
                    // 1 - Retrieve ...        //
                    // *********************** //

                    //CSC-717
                    let cartTranslation = await getCartTranslation({ countryIso2Code: this.orderdetailsapi.ship_to.address.country })
                        .then(data => { return data; })
                        .catch(error => { console.log('There is an error occured during getCartTranslation: ' + error) });

                    let [redirectionURL, localURL, endpoint, userLocal] = await Promise.all([
                        getRedirectionURL(),
                        getRedirectionEndpoint({ landingPage: '/' + cartTranslation, countryIso2Code: this.orderdetailsapi.ship_to.address.country }),
                        getOOBInitCartEndpoint({ countryIso2Code: this.orderdetailsapi.ship_to.address.country }),
                        getUserLocal({ countryIso2Code: this.orderdetailsapi.ship_to.address.country })
                    ]).catch((error) => {
                        console.error('await Promise.all error : ' + error.message);
                        throw error;
                    });

                    console.log('getRedirectionURL : ' + redirectionURL);
                    console.log('getRedirectionEndpoint : ' + localURL);
                    console.log('getOOBInitCartEndpoint : ' + endpoint);

                    // ********************** //
                    // 2 - OOB initialization //
                    // ********************** //
                    console.log('this.orderdetailsapi.account.Id : ' + this.orderdetailsapi.account.Id);
                    console.log('this.orderdetailsapi.account.DREAMID__c : ' + this.orderdetailsapi.account.DREAMID__c);
                    await fetchOOB(this.orderdetailsapi.account.Id, this.orderdetailsapi.account.DREAMID__c, this.orderdetailsapi.ship_to.address.country).then(response => {
                        console.log('fetchOOB response : ' + JSON.stringify(response));
                        if (response.status == '200') {
                            console.log('fetchOOB - success');

                            calloutURI = endpoint.Endpoint__c + '/' + userLocal + '/exchange';
                            console.log('calloutURI:' + calloutURI);

                            let exchange_shippingGroups = [];
                            for (let i = 0; i < jsonProducts.length; i++) {
                                let jsonRecord = { "shipping_group_id": jsonProducts[i].product.request_id, "ReasonCode": jsonProducts[i].reasonSelected }
                                exchange_shippingGroups.push(jsonRecord);
                            }

                            payload =
                            {
                                "exchangeCart": {
                                    "exchange_orderId": this.orderid,
                                    "exchange_shippingGroups": exchange_shippingGroups
                                }
                            };

                            console.log('payload:' + payload);

                            let cartInitialization = fetch(calloutURI, {
                                method: "POST",
                                contentType: "application/json; charset=utf-8",
                                body: JSON.stringify(payload),

                                headers: {
                                    'Content-Type': 'application/json',
                                    'Accept-Language': '*',
                                    'client_id': endpoint.ClientId__c,
                                    'client_secret': endpoint.ClientSecret__c,

                                },
                                credentials: 'include'
                            }).then((response) => {
                                console.log('response of fetch oob init cart', response)// registered
                                if (response.status == 200) {
                                    for (let i = 0; i < jsonProducts.length; i++) {
                                        console.log('insert traceability');

                                        // get Reason Label 
                                        let reasonLabel;
                                        for (let j = 0; j < this.reasons.length; j++) {
                                            console.log('this.reasons[j].value : ' + this.reasons[j].value);
                                            console.log('jsonProducts[i].reasonSelected : ' + jsonProducts[i].reasonSelected);
                                            if (this.reasons[j].value == jsonProducts[i].reasonSelected) {
                                                console.log('this.reasons[j].label : ' + this.reasons[j].label);
                                                reasonLabel = this.reasons[j].label;
                                                break;
                                            }
                                        }
                                        console.log('reasonLabel : ' + reasonLabel);

                                        // Insert "exchange" action in "traceability" object
                                        insertTraceability({
                                            action: this.orderaction.value,
                                            reason: (reasonLabel ? reasonLabel : jsonProducts[i].reasonSelected),
                                            additionalInformation: null,
                                            orderNumber: this.orderid,
                                            shippingNumber: jsonProducts[i].request_id
                                        })
                                            .then((result) => {
                                                console.log('insert traceability - success : ', result);
                                            }).catch((error) => {
                                                console.error('insert traceability - error : ', error);
                                                throw new Error(error.message);
                                            });
                                    }

                                    console.log('oob init cart - OK');
                                    console.log('oob init cart - redirectionURL:' + redirectionURL);
                                    console.log('oob init cart - localURL:' + localURL);
                                    window.open(redirectionURL + "/" + localURL, "Order On Behalf");
                                    jsonResponse.push(JSON.parse('{"status":"success", "message":"The exchange preparation has been submitted successfully"}'));
                                }
                                else {
                                    console.log('oob init cart - An error occured, please try again later');
                                    throw new Error('An error occured, please try again later');
                                }
                            }).catch((error) => {
                                console.error('endpoint init cart error : ', error);
                                throw new Error(error.message);
                            });

                        }
                        else {
                            // display error message
                            console.log('oob init cart - An error occured, please try again later');
                            console.log('response.status :' + response.status);
                            throw new Error('An error occured, please try again later');
                        }
                    })
                        .catch((error) => {
                            console.error('fetchOOB error : ' + error);
                            throw new Error(error.message);
                        });

                }
                catch (e) {
                    console.log(e);
                    jsonResponse.push(JSON.parse('{"status":"error", "message":"' + e.message + '"}'));
                }
            }

            if (this.orderaction.value == 'downloadInvoice') {
                for (let i = 0; i < jsonProducts.length; i++) {

                    downloadInvoice({
                        dreamId: this.dreamid,
                        shippingId: jsonProducts[i].product.request_id
                    })
                        .then((result) => {
                            console.log('get duplicate invoice - success for shipping id ' + jsonProducts[i].product.request_id + ': ', result);

                            var link = document.createElement('a');
                            link.download = jsonProducts[i].product.request_id + "_DuplicateInvoice.pdf";
                            link.href = "data:application/pdf;base64," + result;
                            document.body.appendChild(link);
                            link.click();
                            document.body.removeChild(link);



                        }).catch((error) => {
                            console.error('get duplicate invoice - error for shipping id ' + jsonProducts[i].product.request_id + ': ', error);
                            LightningAlert.open({
                                message: error.body?.message ? typeof error.body?.message != 'string' && JSON.parse(error.body?.message).statusCode && JSON.parse(error.body?.message).errorMessage ? JSON.parse(error.body?.message).errorMessage + " \r\n Code Error : " + JSON.parse(error.body?.message).statusCode : error.body?.message : "An error occured",
                                theme: 'error', // a red theme intended for error states
                                label: 'Download Invoice Error for shipping ' + jsonProducts[i].product.request_id, // this is the header text
                            });
                            throw new Error(error.body.message);

                        });
                }
            }

            this.isLoading = false;
            this.disableClose = false;
            this.close(jsonResponse);
        }
        else {
            this.isLoading = false;
            this.disableClose = false;
        }
    }

    handleSelectAll(event) {
        const tiles = this.template.querySelectorAll('c-icx_order-actions-shipping-tile');

        for (let i = 0; i < tiles.length; i++) {
            tiles[i].setCheckedValue(event.target.checked);
        }
    }

    // handleOneProductOnly(event) {
    //     console.log('{handleOneProductOnly}-event.detail.event.target.checked:'+event.detail.event.target.checked);
    //     console.log('{handleOneProductOnly}-event.detail.event:'+event.detail.event);
    //     console.log('{handleOneProductOnly}-event.detail.event:'+JSON.stringify(event.detail.event));
    //     console.log('{handleOneProductOnly}-event.detail.product:'+event.detail.product);
    //     console.log('{handleOneProductOnly}-event.detail.product:'+JSON.stringify(event.detail.product));
    //     console.log('{handleOneProductOnly}-event.detail.product.shippingNumber:'+JSON.stringify(event.detail.product.shippingNumber));
    //     console.log('{handleOneProductOnly}-event.detail:'+event.detail);
    //     console.log('{handleOneProductOnly}-event.detail:'+JSON.stringify(event.detail));
    //     const tiles = this.template.querySelectorAll('c-icx_order-actions-shipping-tile');

    //     for (let i = 0; i < tiles.length; i++) {
    //         tiles[i].message = '';
    //         if (tiles[i].product.shippingNumber == event.detail.product.shippingNumber) {
    //             console.log('This is the one checked: '+tiles[i].product.shippingNumber);
    //             tiles[i].setMessage('Selected');
    //         }
    //         tiles[i].setCheckedValue(false);
    //     }
    // }

    handleProductSelected(event) {
        const tiles = this.template.querySelectorAll('c-icx_order-actions-shipping-tile');

        if (this.isoneproductonly) {
            console.log('{handleOneProductOnly}:' + event.detail.event.target.checked);
            console.log('{handleOneProductOnly}:' + event.detail.event);
            console.log('{handleOneProductOnly}:' + JSON.stringify(event.detail.event));
            //console.log('{handleOneProductOnly}:'+event.detail.product);
            //console.log('{handleOneProductOnly}:'+JSON.stringify(event.detail.product));
            console.log('{handleOneProductOnly}:' + JSON.stringify(event.detail.product.shippingNumber));
            //console.log('{handleOneProductOnly}:'+event.detail);
            //console.log('{handleOneProductOnly}:'+JSON.stringify(event.detail));

            for (let i = 0; i < tiles.length; i++) {
                tiles[i].setCheckedValue(false);
            }
        }

        if (this.orderaction.value == "exchange") {
            for (let i = 0; i < tiles.length; i++) {
                tiles[i].setMessage(null);
                if (tiles[i].product.shippingNumber == event.detail.product.shippingNumber && event.detail.event.target.checked) {
                    console.log('This is the one checked: ' + tiles[i].product.shippingNumber);
                    if (tiles[i].product.hasPersonalization) {
                        tiles[i].setMessage('You are exchanging a personalized order, click \'Save\' to proceed with the exchange');
                    }
                }
            }
        }

        if (this.orderaction.value == "cancelReturn") {
            for (let i = 0; i < tiles.length; i++) {
                tiles[i].setMessage(null);
                console.log('tiles[i].product.shippingNumber: ' + tiles[i].product.shippingNumber);
                console.log('event.detail.product.shippingNumber: ' + event.detail.product.shippingNumber);
                console.log('event.detail.event.target.checked: ' + event.detail.event.target.checked);
                if (tiles[i].product.shippingNumber == event.detail.product.shippingNumber && event.detail.event.target.checked) {
                    console.log('This is the one checked: ' + tiles[i].product.shippingNumber);
                    if (this.mapOfSgLinkedBySg.get(tiles[i].product.shippingNumber)) {
                        tiles[i].setMessage('You are canceling a return initiated for an exchange. Your are going to cancel the exchange too, click \'Save\' to proceed with the cancel');
                    }
                }
            }
        }

        if (this.orderaction.value == "cancelShipping") {
            for (let i = 0; i < tiles.length; i++) {
                tiles[i].setMessage(null);
                console.log('tiles[i].product.shippingNumber: ' + tiles[i].product.shippingNumber);
                console.log('event.detail.product.shippingNumber: ' + event.detail.product.shippingNumber);
                console.log('event.detail.event.target.checked: ' + event.detail.event.target.checked);
                if (tiles[i].product.shippingNumber == event.detail.product.shippingNumber && event.detail.event.target.checked) {
                    console.log('This is the one checked: ' + tiles[i].product.shippingNumber);
                    if (this.mapOfSgLinkedBySg.get(tiles[i].product.shippingNumber)) {
                        tiles[i].setMessage('Canceling this new order will automatically cancel the initial return request of the following product(s), click \'Save\' to proceed with the cancel');
                    }
                }
            }
        }
    }

}