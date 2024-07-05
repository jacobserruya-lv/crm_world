import { api, LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import imagesResource from '@salesforce/resourceUrl/iconics';
import getStyling from '@salesforce/apex/ICX_Client360_SF.getStylingSF';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';
import getStylingLink from '@salesforce/apex/ICX_Client360_SF.getStylingLinkAzure';



export default class Icx_overviewStyling extends NavigationMixin(LightningElement) {

    isWithSubtitles = true;
    pageIndex = 0;
    pageSize = 3;
    @api sfRecordId;
    @track dreamId;
    objectName = 'Task';
    condition = 'WHERE LookId_IW__c != null AND IsWardrobing__c = true AND AccountId =  : accountId';
    recordsListlength;
    @track tableData = [];
    @track stylingProducts;
    @track isLoading = true;
    @track isLitleLoading = false;

    imagePlaceholder = imagesResource + '/images/imgUndefinedLV.png';
    iconSrc = imagesResource + '/images/client360/saGrey.svg';

    @wire(getrecordsListSize, { accountId: '$sfRecordId', objectName: '$objectName', condition: '$condition' })
    wiredListSize({ error, data }) {
        if (data) {
            this.recordsListlength = data;
        }
        else {
            this.recordsListlength = 0;
        }
        if (error) {
            console.error('error', error);
        }
    }


    @wire(getStyling, { accountId: '$sfRecordId', pageSize: '$pageSize', pageIndex: '$pageIndex' })
    wiredStyling({ error, data }) {
        this.tableData.title = {
            type: 'text',
            label: 'Styling',
            iconSrc: imagesResource + `/images/client360/wardrobingIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            hasLength: true,
            length: this.recordsListlength,
            titleClass: 'title-bold ',

        }

        if (data?.length) {
            this.stylingProducts = data;
            this.tableData.idList = data.map(style => style.Id);
        }

        if (error) {
            console.error(error);
        }

        this.isLoading = false;

    }

    async handleGetStyleLink(event) {
        this.selectedStyleId = event.currentTarget.dataset.id;
        console.log('this.selectedStyleId : ', this.selectedStyleId);
        console.log('this.sfRecordId : ', this.sfRecordId);
        this.isLitleLoading = true;
        try {
            const result = await getStylingLink({ wardrobingId: this.selectedStyleId, accountId: this.sfRecordId });
            console.log({ result })
            console.log(result.statusCode)
            if (result) {
                this.styleLink = result?.sharingUrl;
                if (this.styleLink) {
                    console.log(this.styleLink)
                    this[NavigationMixin.Navigate]({
                        type: "standard__webPage",
                        attributes: {
                            url: this.styleLink,
                        },
                    });
                } else {
                    const errorToast = new ShowToastEvent({
                        title: "Error",
                        message: result?.message ? result.message : 'An error occured',
                        varint: "error"
                    });
                    dispatchEvent(errorToast);
                }
            }
        } catch (error) {
            console.log({ error });
            const errorToast = new ShowToastEvent({
                title: "Error",
                message: error ? error : 'An error occured',
                varint: "error"
            });
            dispatchEvent(errorToast);
        } finally {
            this.isLitleLoading = false;
            this.styleLink = undefined;
        }
    }
}