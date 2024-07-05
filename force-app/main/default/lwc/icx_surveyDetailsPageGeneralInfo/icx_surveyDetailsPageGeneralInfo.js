import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { api, LightningElement, wire } from 'lwc';
import clientName from '@salesforce/schema/VO_Survey__c.ClientDreamID__r.Name';
import CAName from '@salesforce/schema/VO_Survey__c.CAName__c';
import CAScore from '@salesforce/schema/VO_Survey__c.CAScore__c';
import GlobalScore from '@salesforce/schema/VO_Survey__c.GlobalScore__c';
import Segmentation from '@salesforce/schema/VO_Survey__c.ClientDreamID__r.Segmentation__c';
import FeedbackID from '@salesforce/schema/VO_Survey__c.FeedbackID__c';
import { getGuidId } from 'c/utils';


export default class Icx_surveyDetailsPageGeneralInfo extends LightningElement {

    @api sfRecordId;
    @api tags;
    @api rootCauses;
    @api actionTaken;
    @api feedbackStatus;
    @api completedDate;
    survey = [];
    dataReformated = [];
    details = [];
    isLoading = true;


    get getGuidId() {
        return getGuidId();
    }

    @wire(getRecord, { recordId: "$sfRecordId", fields: [CAName, clientName, CAScore, GlobalScore, Segmentation, FeedbackID] })
    wireGetRecord({ error, data }) {
        if (data) {
            // this.survey.caName = getFieldValue(data, CAName);
            this.survey.ClientName = getFieldValue(data, clientName);
            this.survey.caScore = getFieldValue(data, CAScore);
            this.survey.globalScore = getFieldValue(data, GlobalScore);
            this.survey.segmentation = getFieldValue(data, Segmentation);
            this.survey.feedbackID = getFieldValue(data, FeedbackID);
            this.formateData(this.survey);

        } else if (error) {
            console.error(error);
            console.error(error.body.message);
            this.isLoading = false;
        }
    }

    formateData(data) {
        /////////////////////////////////   REMOVE CA SCORE AND LIST VIEW 'My Team Digital Feedback' FOR V1    ////////////////////////////////////

        this.dataReformated = [
            {
                details: [
                    // { label: 'CA Score', value: data.caScore ? data.caScore : '-' },
                    { label: 'Satisfaction Score', value: data.globalScore ? data.globalScore : '-' },
                    { label: '', value: '' }
                ]
            },
            {
                details: [
                    { label: 'Client Name', value: data.ClientName ? data.ClientName : '-' },
                    // { label: 'Assigned CA', value: data.caName  ? data.caName : '-'},
                    { label: 'Segmentation', value: data.segmentation ? data.segmentation : '-' },

                ]
            },
            {
                details: [
                    { label: 'Feedback Date', value: this.completedDate ? this.completedDate : '-' },
                    { label: 'Feedback ID', value: data.feedbackID ? data.feedbackID : '-' },
                ]
            },
            {
                details: [
                    { label: 'Feedback Status', value: this.feedbackStatus ? this.feedbackStatus : '-' },
                    { label: 'Root Cause', value: this.rootCauses ? this.rootCauses : '-' },
                    { label: 'Action Token', value: this.actionTaken ? this.actionTaken : '-' },
                ]
            },
            {
                details: [
                    { label: 'Tags & Sentiments', value: this.tags ? this.tags : '-' },
                ]
            },
            {
                details: [
                    { label: 'Call Nature', value: this.callNature ? this.callNature : '-' },
                    { label: 'Call Category', value: this.callCategory ? this.callCategory : '-' },
                ]
            }

        ]

        this.isLoading = false;
    }
}