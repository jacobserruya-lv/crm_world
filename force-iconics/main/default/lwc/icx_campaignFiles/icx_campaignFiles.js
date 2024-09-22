import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class Icx_campaignFiles extends NavigationMixin(LightningElement) {
    @api contentVersionList;
    @api isDownloadAvailable;
    @api isDeleteAvailable;

    handleDownloadFile(event)
    {
        const downloadUrl = event.currentTarget.dataset.downloadUrl;
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: downloadUrl
                }
            }, false 
        );
    }

    handleDeleteFile(event)
    {
        console.log('delete nao event.currentTarget.dataset.contentVersionId', event.currentTarget.dataset.contentVersionId);
        try
        {

            this.dispatchEvent(new CustomEvent('deletefile', { detail: event.currentTarget.dataset.contentVersionId }));
        }
        catch(e)
        {
            console.error('nao event error', e);
        }

    }


}