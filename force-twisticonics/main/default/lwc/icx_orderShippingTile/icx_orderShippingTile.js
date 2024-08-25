import { LightningElement, api, track } from 'lwc';

/**
 * A presentation component to display a Product.
 */
export default class ICX_Order_Shipping_Tile_LWC extends LightningElement {

    /** Product and Order information to display */
    _orderShipping;
    /** Product image to display. */
    pictureUrl;
    @api
    get product() {
        return this._orderShipping;
    }
    set product(value) {
        // console.log('JGU-product: '+JSON.stringify(value));
        this._orderShipping = value;
        this.pictureUrl = value.productImage + '?wid=50&amp;hei=50';
    }

    @api 
    get isselectedproduct() {
        return this._isSelectedTile;
    }
    set isselectedproduct(isSelected) {
        if (isSelected) {
            this.tileClass = this.tileClass + ' slds-theme_shade';
        }
        else {
            this.tileClass = this.defaultTileClass;     
        } 
        this._isSelectedTile = isSelected;
    }   
    
        
    // We manage dynamicly the CSS class
    defaultTileClass = 'slds-box';
    @track tileClass = this.defaultTileClass;
    
    // Allow parent component to select/unselect a specific Tile
    @api unSelectTile(){
        this.isselectedproduct = false;
    }
    @api selectTile(){
        this.isselectedproduct = true;
    }
    
    // On "Click"
    handleClick() {
        console.log('xxx-icx_orderShippingTile');  
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
        this.tileClass = this.tileClass.replace(' tile-mouse-over','');
    }
    
    // when component is loaded
    connectedCallback(){
        console.log('xxx-icx_orderShippingTile : connectedCallback()');
        //If this product is selected by default
        // console.log('JGU-Tile | connectedCallBack: '+this.isselectedproduct);
        if (this.isselectedproduct) {
            // we simulate the "click" action
            this.handleClick();
        }
    } 
}