import { api, LightningElement } from 'lwc';
import { getGuidId } from 'c/utils';


export default class Icx_surveyDetailsFeedbackSection extends LightningElement {

    @api forms;
    isLoading = true;

    connectedCallback() {
        console.log('forms: ', JSON.stringify(this.forms))
        this.isLoading = false;
    }

    get getGuidId() {
        return getGuidId();
    }
}