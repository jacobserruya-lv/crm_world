import { LightningElement, api, track } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';


/**
 * A presentation component to display a Product.
 */
export default class ICX_Order_Shipping_Tile_LWC extends LightningElement {
    kitIcon = imagesResource + '/images/orderPage/kitIcon.svg';
    itemIdIconSrc = imagesResource + `/images/orderPage/itemIcon.svg`
    parcelNumberIconSrc = imagesResource + `/images/orderPage/shippingIcon.svg`
    trackingNumberIconSrc = imagesResource + `/images/orderPage/trackingIcon.svg`

    /** Product and Order information to display */
    _orderShipping;
    /** Product image to display. */
    pictureUrl;
    @api
    get product() {
        return this._orderShipping;
    }
    set product(value) {
        console.log('orderShppingTile value : ', JSON.stringify(value));
        const imagePlaceholder = imagesResource + '/images/imgUndefinedLV.png';
        this._orderShipping = value;
        this.pictureUrl = value.productImage ? value.productImage : imagePlaceholder + '?wid=50&amp;hei=50';
        this.isKitProduct = value.isKit;
    }

    @api
    get isselectedproduct() {
        return this._isSelectedTile;
    }
    set isselectedproduct(isSelected) {
        if (isSelected) {
            this.tileClass = this.tileClass + ' is__selected';
        }
        else {
            this.tileClass = this.defaultTileClass;
        }
        this._isSelectedTile = isSelected;
    }


    // We manage dynamicly the CSS class
    defaultTileClass = 'slds-box tile__container';
    @track tileClass = this.defaultTileClass;

    // Allow parent component to select/unselect a specific Tile
    @api unSelectTile() {
        this.isselectedproduct = false;
    }
    @api selectTile() {
        this.isselectedproduct = true;
    }

    // On "Click"
    handleClick() {
        console.log('icx_orderShippingTile-handleClick(): ' + this._orderShipping);
        // dispatch event in order to refresh the component that display the product detail
        const selectedEvent = new CustomEvent('selected', {
            detail: this._orderShipping
        });
        this.dispatchEvent(selectedEvent);
    }

    // On "Mouse Over"
    handleMouseOver(event) {
        this.tileClass = this.tileClass + ' tile-mouse-over';
    }

    // On "Mouse Out"
    handleMouseOut(event) {
        this.tileClass = this.tileClass.replace(' tile-mouse-over', '');
    }

    // when component is loaded
    connectedCallback() {
        console.log('icx_orderShippingTile : connectedCallback()');

        //If this product is selected by default
        console.log('icx_orderShippingTile - connectedCallBack: ' + this.isselectedproduct);
        if (this.isselectedproduct) {
            // we simulate the "click" action
            this.handleClick();
        }
    }
}