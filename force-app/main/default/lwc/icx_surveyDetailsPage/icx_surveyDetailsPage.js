import { api, LightningElement, wire } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import transactionID from '@salesforce/schema/VO_Survey__c.IDTransaction__c';
import clientDreamId from '@salesforce/schema/VO_Survey__c.ClientDreamID__r.DREAMID__c';
import getSurveyFormResult from "@salesforce/apex/ICX_SurveyForm.getSurveyFormResult";
import getVoiceLanguage from "@salesforce/apex/ICX_SurveyForm.getVoiceLanguageUser";



export default class Icx_surveyDetailsPage extends LightningElement {

    @api recordId;

    imageSrc = imagesResource + `/images/client360/Survey/voiceDetailsIcon.svg`;
    survey;
    clientDreamId;
    transactionId;
    completedDate;
    feedbackStatus;
    actionTaken;
    rootCauses;
    callNature;
    callCategory;
    forms;
    surveyName;
    tags;

    isLoading = true;


    @wire(getRecord, { recordId: "$recordId", fields: [clientDreamId, transactionID] })
    wireGetRecord({ error, data }) {
        if (data) {
            this.survey = data;
            this.clientDreamId = getFieldValue(this.survey, clientDreamId);
            this.transactionId = getFieldValue(this.survey, transactionID);
            console.log(this.clientDreamId, this.transactionId, this.recordId)
        } else if (error) {
            console.error(error)
            this.isLoading = false;
        }
    }

    connectedCallback() {
        this.init();
    }

    async init() {
        try {
            const response = await getSurveyFormResult({ recordId: this.recordId });
            const voiceLanguageUser = await getVoiceLanguage();
            console.log({ response });
            console.log({ voiceLanguageUser });

            if (response.message) {
                this.isLoading = false;
                console.error(response.message);
            }
            else {
                this.forms = response.answers.map(el => {
                    return el = {
                        label: voiceLanguageUser ? el.translations[voiceLanguageUser] : el.label,
                        value: el.value,
                        isRating: el.kind === 'rating'
                    }
                });
                this.tags = response.tags.length > 0 ? (response.tags[0].name + ' : Tag ' + response.tags[0].sentiment) : null;
                this.completedDate = response.completed_at?.split('T')[0];
                this.feedbackStatus = response.resolved == true ? 'Resolved' : 'Pending';
                this.actionTaken = response.action_taken.length > 0 ? response.action_taken[0].name : null;
                this.rootCauses = response.root_causes.length > 0 ? response.root_causes[0].name : null;
                this.segments = response['segments'];
                this.surveyName = this.segments['survey-name'];
                // this.transactionId = this.segments['transaction_id'];
                this.callNature = this.segments['category'];
                this.callCategory = this.segments['nature'];
            }

            this.isLoading = false;
        } catch (error) {
            this.isLoading = false;
            console.error(error);
        }

    }
}