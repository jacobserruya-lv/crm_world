import { LightningElement, api, track } from 'lwc';
import createMyLvUserAndRedirect from '@salesforce/apex/TWIST_Account_Confirmation.createMyLvUserAndRedirect';
import { sendEvent } from 'c/twistUtils';
export default class TwistAccountConfirmation extends LightningElement {

    @api twistLogo
    @api language
    @api textToDisplay
    @api activationCode
    @api accountCreationForm
    @api queryParams
    @api autodata;
    @api socialParams

    @track error = ""

    connectedCallback(){
        this.initComponent()
    }

    async initComponent(){
        try{
            const response = await createMyLvUserAndRedirect({
                activationCode: this.activationCode,
                identifier: this.accountCreationForm["email"],
                formData: this.accountCreationForm,
                queryParams: JSON.parse(this.queryParams),
                socialParams:  this.socialParams

            });
            sendEvent.call(this, { // Tagging Plan: lines 34 & 35
                actionId: response.success ? "account_creation_succeeded" : "account_creation_failed",
                categoryGa: "mylv",
                actionGa: "create_an_account",
                labelGa: response.success ? "account_creation_succeeded" : "account_creation_failed"
            });
            if (!response.success) {
                this.error = response.form
                //this.accountCreationForm.form
                //updateFormErrors(this.accountCreationForm.form, response);
                return;
            }
            location.href = response.redirectUrl;
        }
        catch (error) {
            console.log('error', error);
        }
    }
}