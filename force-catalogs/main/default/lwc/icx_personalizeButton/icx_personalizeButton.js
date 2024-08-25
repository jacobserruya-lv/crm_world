import { LightningElement, api, track } from 'lwc';
import iconResource from '@salesforce/resourceUrl/iconics';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generateTokenEncrypted from '@salesforce/apex/Ctrl_ProductCatalog.generateTokenEncrypted'
import getTreekitBaseUrl from '@salesforce/apex/Ctrl_ProductCatalog.getTreekitBaseUrl'


export default class Icx_personalizeButton extends LightningElement {
    appName = 'catalogdesktop';
    lng = 'EN';

    @track message;
    @track isStaticPage;

    @api isFromProductDetailPage;
    @api productName;
    @api productSKU;
    @api physicalStoresSelected;
    @api countrySelected;
    @track openIFrame = false;
    @track baseUrl;
    @track tokenURL;
    clientUrl;
    @track height = '100%';
    @track referrerPolicy = 'no-referrer';
    @track sandbox = 'allow-same-origin allow-scripts allow-popups allow-forms';
    @track url;
    @track width = '100%';

    @track timeStamp;

    async handleClientUrl() {
        window.addEventListener('message', event => {
            if (event.data.eventName === 'ShareClientUrlAlpha') {
                this.clientUrl = event.data.eventData.clientUrl;
                console.log('Received custom event:', this.clientUrl);
                this.copyTextToClipboard(this.clientUrl);
            }
        });
    }


    copyTextToClipboard(text) {
        const hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("value", text);
        document.body.appendChild(hiddenInput);
        hiddenInput.select();
        document.execCommand("copy");
        document.body.removeChild(hiddenInput);
    };


    getTimeStamp() {
        return Math.floor(Date.now() / 1000);

    }

    get personalizeIcon() {
        return iconResource + '/images/customiazbleButtonIcon.svg'
    }


    handleCancel() {
        this.openCloseIFrame()
    }


    verifyDetails() {

        if (this.physicalStoresSelected.length < 1) {
            let evt = new ShowToastEvent({
                title: 'Application Error',
                message: 'You need to choose a store first',
                variant: 'Error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        else if (this.countrySelected.length > 1) {
            let evt = new ShowToastEvent({
                title: 'Application Error',
                message: 'Please choose one country only',
                variant: 'Error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        else {
            this.generateURL();
        }

    }

    async generateURL() {
        this.timeStamp = this.getTimeStamp().toString();

        await this.generateToken(this.appName, this.timeStamp);
        await this.getTreekitBaseUrl();

        // const storeSelected = typeof (this.physicalStoresSelected) === 'string' ? this.physicalStoresSelected : this.physicalStoresSelected[0];
        console.log('display the this.physicalStoresSelected ', this.physicalStoresSelected);

        // this.url = `${this.baseUrl}?lng=EN&productName=${this.productName.replaceAll(' ', '%20')}&sku=${this.productSKU}&country=${this.countrySelected[0].replaceAll(' ', '%20')}&storeCode=${storeSelected}&appName=${this.appName}&timestamp=${this.timeStamp}&token=${this.tokenURL}`;
        this.url = `${this.baseUrl}?lng=EN&productName=${this.productName.replaceAll(' ', '%20')}&sku=${this.productSKU}&country=${this.countrySelected[0].replaceAll(' ', '%20')}&storeCode=${this.physicalStoresSelected}&appName=${this.appName}&timestamp=${this.timeStamp}&token=${this.tokenURL}`;

        console.log('display the dynamic url', this.url);

        this.openCloseIFrame();
    }

    getTreekitBaseUrl() {
        return getTreekitBaseUrl()
            .then((result) => {
                this.baseUrl = result;
            })
            .catch((error) => {
                console.error('error during get baseUrl', error);
            });
    }

    openCloseIFrame() {
        this.openIFrame = !this.openIFrame;
        this.handleClientUrl();
    }


    generateToken(appName, timeStamp) {

        const dataToEncrypt = appName + ',' + timeStamp;
        return generateTokenEncrypted({ dataToEncrypt: dataToEncrypt })
            .then((result) => {
                this.tokenURL = result;

            })
            .catch((error) => {
                console.error('error during get token', error);
            });

    }

}