import { api, LightningElement, track } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';
import getSurvey from '@salesforce/apex/ICX_Client360_SF.getSurvey';
import { NavigationMixin } from 'lightning/navigation';


export default class Icx_surveyTab extends NavigationMixin(LightningElement) {

    @api recordId;

    @track tableData = [];
    @track headerContainer = [];
    recordsListlength = 0;
    pageSize = 50;
    @track pageIndex = 0;
    percentOnScroll = 95;
    @track isLoading = true;
    @track isMoreSurveyRecords = true;
    isLoadingMoreSurveyRecords = false;
    objectName = 'VO_Survey__c';
    condition = " WHERE ClientDreamID__c =: accountId";


    connectedCallback() {
        this.headerContainer.title = {
            type: 'text',
            label: 'Voice',
            iconSrc: imagesResource + `/images/client360/Survey/voiceIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            titleClass: 'title-bold title-navigation cursor-pointer',
            hasLength: true,
            length: this.recordsListlength,
        }

        this.tableData.headers = [
            { type: 'text', label: 'Feedback Date' },
            { type: 'text', label: 'Survey Name' },
            // { type: 'text', label: 'CA Score' },
            { type: 'text', label: 'Satisfaction Score', },
            { type: 'text', label: 'Status' }
        ]
        this.tableData.hasHeaders = true;

        getrecordsListSize({ accountId: this.recordId, objectName: this.objectName, condition: this.condition })
            .then(result => {
                this.recordsListlength = result;
                this.headerContainer.title.length = this.recordsListlength;

            })
            .catch(error => {
                console.error('Survey list size error', error);
            });

        this.getSurveySF();

    }

    getSurveySF() {
        if (this.isMoreSurveyRecords && !this.isLoadingMoreSurveyRecords) {

            this.isLoadingMoreSurveyRecords = true;

            getSurvey({ accountId: this.recordId, pageSize: this.pageSize, pageIndex: this.pageIndex })
                .then((result) => {
                    console.log('result on getSurveySF', JSON.stringify(result));

                    const newResults = this.handleResult(result);

                    if (!this.tableData.rows) {
                        if (newResults.length > 0) {
                            this.tableData.rows = newResults;
                        }
                    }
                    else {
                        for (let i = 0; i < newResults.length; i++) {
                            this.tableData.rows.push(newResults[i]);
                        }
                    }
                    if (!this.tableData.idList) {
                        this.tableData.idList = result.map(survey => survey.id);
                    }
                    else {
                        for (let i = 0; i < result.length; i++) {
                            this.tableData.idList.push(result[i].id);
                        }
                    }

                    if (result.length < this.pageSize) {
                        this.isMoreSurveyRecords = false;
                    }

                })
                .catch((error) => {
                    console.error('more survey records error', error);
                    ToastError(error, this);
                })
                .finally(() => {
                    this.isLoadingMoreSurveyRecords = false;
                    this.isLoading = false;
                    this.pageIndex = parseInt(this.pageIndex) + parseInt(this.pageSize);
                    console.log('pageIndex new bis', this.pageIndex)
                })
        }
    }

    handleResult(result) {
        const newResults = result.map(survey => {
            return survey = [
                { value: survey.createdDate ? survey.createdDate : '-', type: 'text', label: 'Feedback Date' },
                { value: survey.surveyType ? this.getIconFortitle(survey.surveyType) : '-', type: 'text', label: 'Survey Name', isTextWithIcon: true },
                // {
                //     value: survey.CAScore ? this.getIconFortitle(survey.CAScore) : '-', type: 'text', label: 'CA Score', isTextWithIcon: survey.CAScore ? true : false
                // },
                { value: survey.globalScore ? survey.globalScore : '-', type: 'text', label: 'Satisfaction Score', isRating: survey.globalScore ? true : false },
                { value: survey.status ? survey.status : '-', type: 'text', label: 'Status' },
            ]
        });
        return newResults;
    }

    getIconFortitle(text) {

        if (typeof (text) == 'number') {
            return {
                imgSrc: imagesResource + `/images/client360/Survey/yellowStar.svg`,
                text: text
            }
        } else {

            switch (text) {
                case 'CSC Post Contact':
                    return {
                        imgSrc: imagesResource + `/images/client360/Survey/CSCPostContact.svg`,
                        text: 'CSC Post Contact'
                    }
                case 'Online Post Payment':
                    return {
                        imgSrc: imagesResource + `/images/client360/Survey/OnlinePostPayment.svg`,
                        text: 'Online Post Payment'
                    }
                case 'Online Post Delivery':
                    return {
                        imgSrc: imagesResource + `/images/client360/Survey/OnlinePostDelivery.svg`,
                        text: 'Online Post Delivery'
                    }
                case 'Retail Post Purchase':
                    return {
                        imgSrc: imagesResource + `/images/client360/Survey/RetailPostPurchase.svg`,
                        text: 'Retail Post Purchase'
                    }
                case 'Retail Care Service':
                    return {
                        imgSrc: imagesResource + `/images/client360/Survey/CareServices.svg`,
                        text: 'Retail Care Service'
                    }

                default:
                    return {
                        imagSrc: null,
                        text: text
                    }
            }
        }

    }

    checkScroll(e) {
        const elementScrolled = this.template.querySelector(`[data-id="tableSurveyContainer"]`);
        const heightScrolled = elementScrolled.scrollHeight;
        const totalHeightOfElement = elementScrolled.clientHeight;
        const heightToCallApi = (this.percentOnScroll / 100) * totalHeightOfElement;

        if (heightScrolled >= heightToCallApi && this.isMoreSurveyRecords && !this.isLoadingMoreSurveyRecords) {
            this.getSurveySF()
        }
    }


    navigateToSurvey(event) {
        const surveyId = this.tableData.idList[event.detail];
        console.log({ surveyId })

        try {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: surveyId,
                    objectApiName: 'VO_Survey__c',
                    actionName: 'view'
                },
            });
        } catch (error) {
            console.error(error)
        }

    }
}