import { LightningElement, track, wire } from 'lwc';
import getrecordsListSize from '@salesforce/apex/ICX_Client360_SF.getrecordsListSize';
import imagesResource from '@salesforce/resourceUrl/iconics';
import UsrId from '@salesforce/user/Id';
import UsrRoleName from '@salesforce/schema/User.UserRole.DeveloperName';
import getSurveyListView from '@salesforce/apex/ICX_Client360_SF.getSurveyListView';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

export default class Icx_surveyPage extends NavigationMixin(LightningElement) {

    @track surveyData;
    @track tableData = [];
    @track headerContainer = [];
    @track userId;

    isManager = false;
    isDigital = false;
    isMySurveys = true;

    recordsListlength = 0;
    @track headerContainer = [];

    @track isLoading = true;
    @track isMoreSurveyRecords = true;
    isLoadingMoreSurveyRecords = false;

    pageSize = 50;
    @track pageIndex = 0;
    percentOnScroll = 95;

    imageSrc = imagesResource + `/images/client360/Survey/voiceIcon.svg`

    listViewTitle = [];
    listViewTitleSelected;

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

        this.getTableHeaders();

        this.tableData.hasHeaders = true;

        this.getSurveySF();
    }

    getTableHeaders() {
        this.tableData.headers = [
            { type: 'text', label: 'Feedback Date' },
            { type: 'text', label: 'Survey Name' },
            { type: 'text', label: 'Client Name' },
            // { type: 'text', label: 'Segmentation' },
            // { type: 'text', label: 'CA Score' },
            { type: 'text', label: 'Satisfaction Score', },
            { type: 'text', label: 'Status' },
        ]
        if (this.listViewTitleSelected == 'My Team Digital Feedback') {
            this.tableData.headers = this.tableData.headers.filter(el => el.label != 'CA Score');
            this.tableData.headers.push({ type: 'text', label: 'Advisor CS Role' })
        }
        else this.tableData.headers.push({ type: 'text', label: 'Advisor Name' })

    }

    selectInput() {

        this.listViewTitle = [
            { label: 'MyCSCFeedback', value: 'My CSC Feedback' },
            { label: 'MyTeamDigitalFeedback', value: 'My Team Digital Feedback' }];

        if (this.isManager) this.listViewTitle.splice(1, 0, { label: 'MyTeamCSCFeedback', value: 'My Team CSC Feedback' },);

        this.listViewTitleSelected = this.listViewTitle[0].value;

        this.getSurveySF();
    }

    @wire(getRecord, { recordId: UsrId, fields: [UsrRoleName] })
    wireuser({ error, data }) {
        if (data) {
            const userRole = data.fields.UserRole.value.fields.DeveloperName.value;
            if (userRole.includes('Manager')) this.isManager = true;
        } else if (error) {
            console.error(error);
        }

        this.selectInput();
    }


    getSurveySF() {
        if (this.isMoreSurveyRecords && !this.isLoadingMoreSurveyRecords) {

            this.isLoadingMoreSurveyRecords = true;

            getSurveyListView({ userId: UsrId, pageSize: this.pageSize, pageIndex: this.pageIndex, isManager: this.isManager, isDigital: this.isDigital, isMySurveys: this.isMySurveys })
                .then((result) => {
                    console.log('result on getSurveySF', JSON.stringify(result));
                    this.surveyData = result;

                    const newResults = this.handleResult(this.surveyData);

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
                        this.tableData.idList = this.surveyData.map(survey => survey.id);
                    }
                    else {
                        for (let i = 0; i < this.surveyData.length; i++) {
                            this.tableData.idList.push(this.surveyData[i].id);
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
                    if (this.isMoreSurveyRecords) this.pageIndex = parseInt(this.pageIndex) + parseInt(this.pageSize);
                    console.log('pageIndex new bis', this.pageIndex)
                })

        }
    }


    handleResult(result) {
        const newResults = result.map(survey => {
            return this.tableFormatted(survey)
        });
        console.log({ newResults })
        return newResults;
    }

    tableFormatted(survey) {
        /////////////////////////////////   REMOVE CA SCORE    ////////////////////////////////////

        if (this.listViewTitleSelected == 'My Team Digital Feedback') {
            return survey = [
                { value: survey.createdDate ? survey.createdDate : '-', type: 'text', label: 'Feedback Date' },
                { value: survey.surveyType ? this.getIconFortitle(survey.surveyType) : '-', type: 'text', label: 'Survey Name', isTextWithIcon: true },
                { value: survey.clientName ? survey.clientName : '-', type: 'text', label: 'Client Name' },
                // { value: survey.segmentation ? survey.segmentation : '-', type: 'text', label: 'Segmentation' },
                // {
                //     value: survey.CAScore ? this.getIconFortitle(survey.CAScore) : '-', type: 'text', label: 'CA Score', isTextWithIcon: survey.CAScore ? true : false
                // },
                { value: survey.globalScore ? survey.globalScore : '-', type: 'text', label: 'Satisfaction Score', isRating: survey.globalScore ? true : false },
                { value: survey.status ? survey.status : '-', type: 'text', label: 'Status' },
                { value: survey.advisorCSRole ? survey.advisorCSRole : survey.CAName ? survey.CAName : '-', type: 'text', label: survey.advisorCSRole ? 'Advisor CS Role' : 'CA Name' },
            ]
        } else {
            return survey = [
                { value: survey.createdDate ? survey.createdDate : '-', type: 'text', label: 'Feedback Date' },
                { value: survey.surveyType ? this.getIconFortitle(survey.surveyType) : '-', type: 'text', label: 'Survey Name', isTextWithIcon: true },
                { value: survey.clientName ? survey.clientName : '-', type: 'text', label: 'Client Name' },
                // { value: survey.segmentation ? survey.segmentation : '-', type: 'text', label: 'Segmentation' },
                // {
                //     value: survey.CAScore ? this.getIconFortitle(survey.CAScore) : '-', type: 'text', label: 'CA Score', isTextWithIcon: survey.CAScore ? true : false
                // },
                { value: survey.globalScore ? survey.globalScore : '-', type: 'text', label: 'Satisfaction Score', isRating: survey.globalScore ? true : false },
                { value: survey.status ? survey.status : '-', type: 'text', label: 'Status' },
                { value: survey.advisorCSRole ? survey.advisorCSRole : survey.CAName ? survey.CAName : '-', type: 'text', label: survey.advisorCSRole ? 'Advisor CS Role' : 'CA Name' },
            ]
        }


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


    handleListViewChanged(event) {
        this.isMoreSurveyRecords = true;
        this.listViewTitleSelected = event.target.value;

        this.getTableHeaders();

        switch (this.listViewTitleSelected) {
            case 'My CSC Feedback':
                this.isDigital = false;
                this.isMySurveys = true;
                this.isLoading = true;
                break;
            case 'My Team CSC Feedback':
                this.isDigital = false;
                this.isMySurveys = false;
                this.isLoading = true;
                break
            case 'My Team Digital Feedback':
                this.isDigital = true;
                this.isLoading = true;
                break
            default:
                break;
        }

        this.tableData.rows = [];
        this.tableData.idList = [];
        this.pageIndex = 0;

        this.getSurveySF();
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


}