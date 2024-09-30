import { LightningElement, api, track, wire } from 'lwc';

// Lightning Message Service and message channels
import { publish, subscribe, MessageContext } from 'lightning/messageService';
//import PRODUCTS_FILTERED_MESSAGE from '@salesforce/messageChannel/ProductsFiltered__c';
import PRODUCT_SELECTED_MESSAGE from '@salesforce/messageChannel/ProductSelected__c';

/**
 * Container component that loads and displays a list of "Order Shipping" records.
 */
export default class ICX_Order_Shipping_Tile_List_LWC extends LightningElement {
    /**
     * Current RecordId
    //  */
    // @api products;

    _isKit;
    // @api orderdetailsapi;
    selectedProductId;
    message = 'No product to display';
    _isFirst = true;
    @track productSelected;

    /** Load context for Lightning Messaging Service */
    @wire(MessageContext) messageContext;

    get isFirst() {
        if (this._isFirst) {
            this._isFirst = false;
            return true;
        }
        else {
            return false;
        }
    }

    get isKitProduct() {
        return this._isKit;
    }

    @api
    get orderdetailsapi() {
        return this._orderdetailsapi;
    }
    set orderdetailsapi(value) {
        this._orderdetailsapi = value;
        console.log('orderShippingTileList- selectTile() != null:' + this.selectedProductId);
        if (this.selectedProductId != null) {
            console.log('orderShippingTileList- selectTile():');
            var selectedProduct;
            value.order_lines.forEach(obj => {
                if (obj.reason.Id == this.selectedProductId) {
                    selectedProduct = obj;
                }
            })

            const tileSelected = this.template.querySelectorAll('c-icx_order-shipping-tile');

            for (let i = 0; i < tileSelected.length; i++) {
                console.log('orderShippingTileList- selectedProduct.id = ' + selectedProduct.id);
                console.log('orderShippingTileList- tileSelected[i].product.id = ' + tileSelected[i].product.id);

                if (selectedProduct.id == tileSelected[i].product.id) {
                    tileSelected[i].product = selectedProduct;
                }
            }

            // Published ProductSelected message
            publish(this.messageContext, PRODUCT_SELECTED_MESSAGE, {
                orderShipping: selectedProduct
            });
        }
    }


    // renderedCallback() {
    //     if (this.orderdetailsapi) {
    //         console.log('orderShippingTileList- selectTile() this.orderdetailsapi' + this.orderdetailsapi);
    //         console.log('orderShippingTileList- selectTile() != null:' + this.selectedProductId);
    //         console.log(this.orderdetailsapi.order_lines)

    //         if (this.selectedProductId) {
    //             console.log('orderShippingTileList- selectTile():');
    //             var selectedProduct;
    //             this.orderdetailsapi.order_lines.forEach(obj => {
    //                 if (obj.reason.Id == this.selectedProductId) {
    //                     selectedProduct = obj;
    //                 }
    //             })
    //             console.log('productSelected selectedProduct: ', JSON.stringify(selectedProduct))


    //             const tileSelected = this.template.querySelectorAll('c-icx_order-shipping-tile');

    //             for (let i = 0; i < tileSelected.length; i++) {
    //                 console.log('orderShippingTileList- selectedProduct.id = ' + selectedProduct.id);
    //                 console.log('orderShippingTileList- tileSelected[i].product.id = ' + tileSelected[i].product.id);

    //                 if (selectedProduct.id == tileSelected[i].product.id) {
    //                     tileSelected[i].product = selectedProduct;
    //                 }
    //             }

    //             // Published ProductSelected message
    //             publish(this.messageContext, PRODUCT_SELECTED_MESSAGE, {
    //                 orderShipping: selectedProduct
    //             });
    //         }

    //     }
    // }



    handleProductSelected(event) {
        const tileSelected = this.template.querySelectorAll('c-icx_order-shipping-tile');

        for (let i = 0; i < tileSelected.length; i++) {
            tileSelected[i].unSelectTile();
        }

        this.selectedProductId = event.detail.reason.Id;

        event.currentTarget.selectTile();

        this._isKit = event.detail.isKit;
        this.productSelected = event.detail;

        // Published ProductSelected message
        publish(this.messageContext, PRODUCT_SELECTED_MESSAGE, {
            orderShipping: event.detail
        });
    }
}