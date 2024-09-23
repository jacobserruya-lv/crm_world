import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import updateCampaignSku from '@salesforce/apex/ICX_CampaignGeneralInformationController.updateCampaignCatalogItem'


export default class Icx_addSkuModal extends LightningModal {
    @api campaignId
    @track pageSize = 5;
    @track pageIndex = 0;

    @track productSKUList = [];
    @track productSKU;


    handleProductSKUList(event) {
        this.productSKUList = JSON.parse(event.detail);
    }

    handleAddSku() {
        if (this.productSKUList.length > 0) {
            updateCampaignSku({ campaignId: this.campaignId, productSKUList: this.productSKUList })
                .then((result) => {
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Campaign updated !",
                        variant: "success",
                    });
                    document.dispatchEvent(evt);
                    setTimeout(this.reloadPage, 1000);
                })
                .catch((error) => {
                    console.log("Display the error", error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'There is an error during the update: ' + JSON.stringify(error),
                        variant: 'error',
                    });
                    document.dispatchEvent(evt);
                });
            this.close('okay');
        } else {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please press enter to add the sku, then press Add  ',
                variant: 'error',
            });
            document.dispatchEvent(evt);
        }

    }

    reloadPage() {
        return location.reload(true)
    }

}