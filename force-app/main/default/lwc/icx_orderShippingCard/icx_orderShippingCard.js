import { LightningElement, track, wire, api } from 'lwc';

// Lightning Message Service and a message channel
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, MessageContext } from 'lightning/messageService';
import PRODUCT_SELECTED_MESSAGE from '@salesforce/messageChannel/ProductSelected__c';

import { fetchOOB } from 'c/icx_oob_utils';
import getRedirectionURI from '@salesforce/apex/ICX_Api_LVPreparationOrder.getProductPerso';
import getRedirectionURL from '@salesforce/apex/ICX_TWIST_OOB.getRedirectionURL';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Icx_orderShippingCard extends NavigationMixin(LightningElement) {
    // Id of Product__c to display
    recordId;

    // Product fields displayed with specific format
    productName;
    productPictureUrl;

    @api orderdetailsapi;
    @track _orderShipping;

    // @track shipmentLinkLabel;
    // @track shipmentTrackingNumber;

    @track isShowShipment = true;
    @track hasShipment = false;
    @track hasShipmentReturn = false;

    //
    activeSections = ['DigitalOrderDetails'];

    // Status History
    columns = [
        {
            label: 'Date', fieldName: 'date_Z', type: 'date', typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                // hour12: true
            }
        },
        { label: 'Status', fieldName: 'status' },
        { label: 'Information', fieldName: 'locationName' }
    ];

    columnsTwist = [
        {
            label: 'Date', fieldName: 'date_Z', type: 'date', typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                // hour12: true
            }
        },
        { label: 'Details', fieldName: 'statusIconics', cellAttributes: { class: { fieldName: 'statusColor' } } },
        { label: 'Information', fieldName: 'messageIconics' },
        { label: 'OMS Status', fieldName: 'status' }
    ];

    defaultSortDirection = 'asc';
    sortedBy = 'Date';
    sortDirection = 'asc';
    data;

    get trackingNumber() {
        if (this.isShowShipment) {
            if (this._orderShipping?.shipment?.tracking_number != undefined) return this._orderShipping.shipment.tracking_number;
        }
        else {
            if (this._orderShipping?.shipmentReturn?.tracking_number != undefined) return this._orderShipping.shipmentReturn.tracking_number;
        }
        return '';
    }

    get trackingLink() {
        if (this.isShowShipment) {
            if (this._orderShipping?.shipment?.tracking_link != undefined) return this._orderShipping.shipment.tracking_link;
        }
        else {
            if (this._orderShipping?.shipmentReturn?.tracking_link != undefined) return this._orderShipping.shipmentReturn.tracking_link;
        }
        return '';
    }

    get carrierServiceDisplay() {

        let carrierName;
        let carrierService;


        if (this.isShowShipment) {
            console.log('this._orderShipping?.shipment?.carrier_name: ' + this._orderShipping?.shipment?.carrier_nameName);
            console.log('this._orderShipping?.shipment?.carrier_service: ' + this._orderShipping?.shipment?.carrier_service);
            if (this._orderShipping?.shipment?.carrier_name != undefined) carrierName = this._orderShipping?.shipment?.carrier_name;
            if (this._orderShipping?.shipment?.carrier_service != undefined) carrierService = this._orderShipping?.shipment?.carrier_service;
        }
        else {
            console.log('this._orderShipping?.shipmentReturn?.carrier_name: ' + this._orderShipping?.shipmentReturn?.carrier_nameName);
            console.log('this._orderShipping?.shipmentReturn?.carrier_service: ' + this._orderShipping?.shipmentReturn?.carrier_service);
            if (this._orderShipping?.shipmentReturn?.carrier_name != undefined) carrierName = this._orderShipping?.shipmentReturn?.carrier_name;
            if (this._orderShipping?.shipmentReturn?.carrier_service != undefined) carrierService = this._orderShipping?.shipmentReturn?.carrier_service;
        }

        console.log('carrierName: ' + carrierName);
        console.log('carrierService: ' + carrierService);

        if (carrierName != undefined && carrierService != undefined) {
            return carrierName + ' - ' + carrierService;
        }
        else if (carrierName != undefined && carrierService == undefined) {
            return carrierName;
        }
        else if (carrierName == undefined && carrierService != undefined) {
            return carrierService;
        }
        else {
            return '';
        }

    }

    get initialETA() {
        let initialEtaMin;
        let initialEtaMax;

        if (this.isShowShipment) {
            initialEtaMin = this._orderShipping?.shipment?.initial_estimated_delivery_date_min;
            initialEtaMax = this._orderShipping?.shipment?.initial_estimated_delivery_date_max;
        }
        else {
            initialEtaMin = this._orderShipping?.shipmentReturn?.initial_estimated_delivery_date_min;
            initialEtaMax = this._orderShipping?.shipmentReturn?.initial_estimated_delivery_date_max
        }

        if (initialEtaMin && initialEtaMax) {
            if (initialEtaMin == initialEtaMax) {
                return initialEtaMin;
            }
            else {
                return initialEtaMin + ' to ' + initialEtaMax;
            }
        }
        else if (initialEtaMin) {
            return initialEtaMin;
        }
        else if (initialEtaMax) {
            return initialEtaMax;
        }
        // else if (this._orderShipping?.eta) {
        //     return this._orderShipping.eta.min==this._orderShipping.eta.max ? this._orderShipping.eta.max: this._orderShipping.eta.min + ' to ' + this._orderShipping.eta.max ;
        // }
        else {
            return null;
        }
    }

    get revisedETA() {
        let revisedEtaMin;
        let revisedEtaMax;

        if (this.isShowShipment) {
            revisedEtaMin = this._orderShipping?.shipment?.estimated_delivery_date_min;
            revisedEtaMax = this._orderShipping?.shipment?.estimated_delivery_date_max;
        }
        else {
            revisedEtaMin = this._orderShipping?.shipmentReturn?.estimated_delivery_date_min;
            revisedEtaMax = this._orderShipping?.shipmentReturn?.estimated_delivery_date_max;
        }



        if (revisedEtaMin && revisedEtaMax) {
            if (revisedEtaMin == revisedEtaMax) {
                return revisedEtaMin;
            }
            else {
                return revisedEtaMin + ' to ' + revisedEtaMax;
            }
        }
        else if (revisedEtaMin) {
            return revisedEtaMin;
        }
        else if (revisedEtaMax) {
            return revisedEtaMax;
        }
        // else if (this._orderShipping?.revised_eta) {
        //         return this._orderShipping.revised_eta.min ==this._orderShipping.revised_eta.max ? this._orderShipping.revised_eta.max : this._orderShipping.revised_eta.min  + ' to ' + this._orderShipping.revised_eta.max ;
        // }
        else {
            return null;
        }
    }

    get scheduledDelivery() {
        let value;
        if (!this.isEmptyValue(this.revisedETA) || !this.isEmptyValue(this.initialETA)) {
            value = (!this.isEmptyValue(this.revisedETA) ? this.revisedETA : this.initialETA);
        }

        if (!this.isEmptyValue(this.deliveryTimeslot)) {
            value = (value ? value + " between " : "") + this.deliveryTimeslot;
        }

        return value;
    }

    isEmptyValue(value) {
        return (typeof value === 'undefined' || value === null || value === '')
    }


    get deliveryTimeslot() {
        if (this.isShowShipment) {
            if (this._orderShipping?.shipment?.delivery_timeslot != undefined) return this._orderShipping.shipment.delivery_timeslot;
        }
        else {
            if (this._orderShipping?.shipmentReturn?.delivery_timeslot != undefined) return this._orderShipping.shipmentReturn.delivery_timeslot;
        }
        return '';
    }

    get deliveryStatus() {
        if (this.isShowShipment) {
            if (this._orderShipping?.shipment?.delivery_status != undefined) return this._orderShipping.shipment.delivery_status;
        }
        else {
            if (this._orderShipping?.shipmentReturn?.delivery_status != undefined) return this._orderShipping.shipmentReturn.delivery_status;
        }
        return '';
    }

    get deliveryStatusDate() {
        if (this.isShowShipment) {
            if (this._orderShipping?.shipment?.delivery_status_date != undefined) return this._orderShipping.shipment.delivery_status_date;
        }
        else {
            if (this._orderShipping?.shipmentReturn?.delivery_status_date != undefined) return this._orderShipping.shipmentReturn.delivery_status_date;
        }
        return '';
    }


    // get trackingNumberDisplay() {
    //     let carrierName;
    //     let trackingNumber;

    //     console.log('this._orderShipping?.shipment?.carrier_name: '+this._orderShipping?.shipment?.carrier_nameName);
    //     console.log('this._orderShipping?.shipment?.tracking_number: '+this._orderShipping?.shipment?.tracking_number);

    //     if (this._orderShipping?.shipment?.carrier_name != undefined) carrierName = this._orderShipping?.shipment?.carrier_name;
    //     if (this._orderShipping?.shipment?.tracking_number != undefined) trackingNumber = this._orderShipping?.shipment?.tracking_number;

    //     console.log('carrierName: '+carrierName);
    //     console.log('trackingNumber: '+trackingNumber);

    //     console.log('carrierName: '+(carrierName != undefined));

    //     if (carrierName != undefined && trackingNumber != undefined) {
    //         return this._orderShipping.shipment.carrier_name+' - '+this._orderShipping.shipment.tracking_number;
    //     }
    //     else if (carrierName != undefined && trackingNumber == undefined) {
    //         return this._orderShipping.shipment.carrier_name;
    //     }
    //     else if (carrierName == undefined && trackingNumber != undefined) {
    //         return this._orderShipping.shipment.tracking_number;
    //     }
    //     else {
    //         return '';
    //     }
    // }

    // get returnTrackingNumberDisplay() {
    //     let carrierName;
    //     let trackingNumber;

    //     console.log('this._orderShipping?.shipmentReturn?.carrier_name: '+this._orderShipping?.shipmentReturn?.carrier_nameName);
    //     console.log('this._orderShipping?.shipmentReturn?.tracking_number: '+this._orderShipping?.shipmentReturn?.tracking_number);

    //     if (this._orderShipping?.shipmentReturn?.carrier_name != undefined) carrierName = this._orderShipping?.shipmentReturn?.carrier_name;
    //     if (this._orderShipping?.shipmentReturn?.tracking_number != undefined) trackingNumber = this._orderShipping?.shipmentReturn?.tracking_number;

    //     console.log('carrierName: '+carrierName);
    //     console.log('trackingNumber: '+trackingNumber);

    //     console.log('carrierName: '+(carrierName != undefined));

    //     if (carrierName != undefined && trackingNumber != undefined) {
    //         return this._orderShipping.shipmentReturn.carrier_name+' - '+this._orderShipping.shipmentReturn.tracking_number;
    //     }
    //     else if (carrierName != undefined && trackingNumber == undefined) {
    //         return this._orderShipping.shipmentReturn.carrier_name;
    //     }
    //     else if (carrierName == undefined && trackingNumber != undefined) {
    //         return this._orderShipping.shipmentReturn.tracking_number;
    //     }
    //     else {
    //         return '';
    //     }
    // }

    get hotStampingPersonalizationColorHex() {
        console.log('background-color:#' + this._orderShipping.hotStamping.personalization.display_colorCode);
        return 'display: inline-block;width: 12px;height: 14px;border: 1px solid black;background-color:#' + this._orderShipping.hotStamping.personalization.display_colorCode;
    }

    get engravingPersonalizationColorHex() {
        console.log('background-color:#' + this._orderShipping.engraving.personalization.display_colorCode);
        return 'display: inline-block;width: 12px;height: 14px;border: 1px solid black;background-color:#' + this._orderShipping.engraving.personalization.display_colorCode;
    }

    // Fulfillment Radio Group
    fulfillmentActionsValue = '';
    get fulfillmentActionsOptions() {
        return [
            { label: 'Serve in last', value: 'serveInLast' },
            { label: 'Serve in priority', value: 'serveInPriority' },
            { label: 'Cancel', value: 'cancelOrder' }
        ]
    }

    get priceAdjustementColor() {
        console.log('priceAdjustementColor // color:' + this._orderShipping.priceAdjustmentColor);
        return 'color:' + this._orderShipping.priceAdjustmentColor;
    }

    // Reason Combobox


    /** Load context for Lightning Messaging Service */
    @wire(MessageContext) messageContext;

    /** Subscription for ProductSelected Lightning message */
    productSelectionSubscription;

    connectedCallback() {
        // Subscribe to ProductSelected message
        this.productSelectionSubscription = subscribe(
            this.messageContext,
            PRODUCT_SELECTED_MESSAGE,
            (message) => this.handleProductSelected(message.orderShipping)
        );
        console.log(this.productSelectionSubscription)
    }

    handleRecordLoaded(event) {
        const { records } = event.detail;
        const recordData = records[this.recordId];
        this.productName = getFieldValue(recordData, NAME_FIELD);
        this.productPictureUrl = getFieldValue(recordData, PICTURE_URL_FIELD);
    }

    /**
     * Handler for when a product is selected. When `this.recordId` changes, the
     * lightning-record-view-form component will detect the change and provision new data.
     */
    handleProductSelected(product) {
        this._orderShipping = product;
        console.log({ product });
        this.data = [];
        this.data = Array.of();

        this._orderShipping.logs.forEach(element => {
            // JIRA-25378 : don't display log history without location
            // JIRA-26196 : don't display log where location = {} but display where location = null
            if (element.location == null || element.location?.rms_id != null) {
                this.data.push(element);
            }
        });
        this.data.reverse();

        console.log('this._orderShipping?.shipment : ' + JSON.stringify(this._orderShipping.shipment));
        console.log('this._orderShipping?.shipmentReturn : ' + JSON.stringify(this._orderShipping.shipmentReturn));


        console.log('this._orderShipping?.shipment.tracking_link : ' + JSON.stringify(this._orderShipping.shipment.tracking_link));

        this.hasShipment = false;
        this.hasShipmentReturn = false;
        if (this.isShowShipment == false) this.handleShipment();

        if (this._orderShipping?.shipment != null && !(JSON.stringify(this._orderShipping?.shipment) === '{}')) {
            this.hasShipment = true;
        }
        if (this._orderShipping?.shipmentReturn != null && !(JSON.stringify(this._orderShipping?.shipmentReturn) === '{}')) {
            this.hasShipmentReturn = true;
            this.isShowShipment = this.hasShipment; // if there is only a 'return shipment' and no 'shipment' for the shipping
        }

    }

    // In case there are many tracking linked to the order,
    // We allow to display the shipment tracking or return tracking
    handleShipment() {
        this.isShowShipment = !this.isShowShipment;
    }

    async handleViewOnline() {
        try {
            console.log('start viewOnline');
            console.log('start viewOnline - account.Id :' + this.orderdetailsapi?.account?.Id);
            console.log('start viewOnline - DREAMID__c :' + this.orderdetailsapi?.account?.DREAMID__c);

            // 1 - Retrieve the redirection uri
            // 2 - retrieve the environnement url
            let [redirectionURI, redirectionURL] = await Promise.all([
                getRedirectionURI({ shippingGroupRequestId: this._orderShipping.request_id, countryIso2Code: this.orderdetailsapi.ship_to.address.country }),
                getRedirectionURL()
            ]).catch((error) => {
                console.error('await Promise.all error : ' + JSON.stringify(error));
                throw error;
            });

            // 3 - OOB
            //fetchOOB(this._orderShipping.account.Id, this._orderShipping.account.DREAMID__c).then(() => {
            fetchOOB(this.orderdetailsapi?.account?.Id, this.orderdetailsapi?.account?.DREAMID__c, this.orderdetailsapi.ship_to.address.country).then(response => {
                console.log('fetchOOB response : ' + JSON.stringify(response));
                if (response.status == '200') {
                    // 4 - open the url in a new window
                    console.log(redirectionURL + redirectionURI);
                    window.open(redirectionURL + redirectionURI, "Personalization Details");
                    console.log('end viewOnline');
                }
                else {
                    // display error message
                }
            })
                .catch(error => {
                    console.log('fetchOOB error : ' + error);
                });
        }
        catch (error) {
            let evt = new ShowToastEvent({
                title: 'Error',
                message: 'The personalization detail is not available. Please try later.',
                variant: 'error',
                mode: 'pester'
            });
            this.dispatchEvent(evt);
        }

    }
}