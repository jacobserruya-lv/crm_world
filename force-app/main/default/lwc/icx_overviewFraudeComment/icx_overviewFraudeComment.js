import { LightningElement, track, api, wire } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';
import UsrId from '@salesforce/user/Id';
import UsrProfileName from '@salesforce/schema/User.Profile.Name';
import { getRecord } from 'lightning/uiRecordApi';



export default class Icx_overviewFraudeComment extends LightningElement {


    @track tableDataTwistComment = [];
    @api sfRecordId;
    @track isAuthorized = false;
    @track commentCount = 0;
    objectName = 'Fraud_Comment__c';
    condition = 'WHERE Client__c = :accountId';


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
        this.formatHeadersTable();
    }

    @wire(getRecord, { recordId: UsrId, fields: [UsrProfileName] })
    wireuser({ error, data }) {
        if (data) {
            const userProfile = data.fields.Profile.displayValue;
            if (userProfile.includes('ICONiCS_Back_Office') || userProfile.includes('System Admin')) this.isAuthorized = true;
        } else if (error) {
            console.error(error);
        }
    }


    formatHeadersTable() {
        this.tableDataTwistComment = {
            title: {
                type: 'text',
                label: 'Comment',
                iconSrc: imagesResource + `/images/comment.svg`,
                isWithIcon: true,
                hasLength: true,
                titleClass: 'title-bold',
                length: this.recordsListlength,
                recordId: this.sfRecordId,
                isHeader: true,
            }
        }

    }

}