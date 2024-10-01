import { LightningElement, api } from 'lwc';
import { sendPageView, sendEvent } from 'c/twistUtils';

export default class TestGoogleAnalytics extends LightningElement {
    
    @api autodata;
    @api page;
    @api queryParams;
    
    oQueryParams;
    
    connectedCallback() {
        this.oQueryParams = JSON.parse(JSON.stringify(this.queryParams));
    }
    
    handleClick() {
        this.sendAllPageViews();
        this.sendAllEvents();
    }
    
    sendAllPageViews() {
        const payload = { 'event': 'pageview' };
        sendPageView.call(this, Object.assign(payload, { pageRank: 'connexion_module' }));
        sendPageView.call(this, Object.assign(payload, { pageRank: 'accountCreation' }));
        sendPageView.call(this, Object.assign(payload, { pageRank: 'forgot-password' }));
        sendPageView.call(this, Object.assign(payload, { pageRank: 'reset-password' }));
    }
    
    sendAllEvents() {
        sendEvent.call(this, { // Tagging Plan: lines 31 & 32
            actionId: value ? 'tick_checkbox' : 'untick_checkbox',
            categoryGa: 'mylv',
            actionGa: value ? 'tick_checkbox' : 'tick_checkbox',
            contentId: 'newsletter_subscription',
            actionType: 'newsletter_subscription'
        });
        sendEvent.call(this, { // Tagging Plan: line 30
            actionId: 'i_already_have_an_account',
            categoryGa: 'mylv',
            actionGa: 'create_an_account',
            labelGa: 'i_already_have_an_account'
        });
        sendEvent.call(this, { // Tagging Plan: line 56
            actionId: 'account_creation_step_succeeded',
            categoryGa: 'mylv',
            actionGa: 'create_an_account',
            labelGa: 'account_creation_step_succeeded'
        });
        sendEvent.call(this, { // Tagging Plan: line 55
            actionId: 'account_creation_step_succeeded',
            categoryGa: 'mylv',
            actionGa: 'create_an_account',
            labelGa: 'account_creation_step_succeeded',
            errorId: this.getErrorFieldsList()
        });
        sendEvent.call(this, { // Tagging Plan: line 58
            actionId: 'resend_activation_code',
            categoryGa: 'mylv',
            actionGa: 'create_an_account_form_sf',
            labelGa: 'resend_activation_code'
        });
        sendEvent.call(this, { // Tagging Plan: line 33
            actionId: 'account_creation_request',
            categoryGa: 'mylv',
            actionGa: 'create_an_account',
            labelGa: 'account_creation_request'
        });
        sendEvent.call(this, { // Tagging Plan: line 54
            actionId: this.isPasswordShown ? 'show_password' : 'hide_password',
            categoryGa: 'mylv',
            actionGa: 'create_an_account_form_sf',
            labelGa: this.isPasswordShown ? 'show_password' : 'hide_password'
        });
        sendEvent.call(this, { // Tagging Plan: line 43
            actionId: 'email_not_valid',
            categoryGa: 'mylv',
            actionGa: 'create_an_account_form_sf',
            labelGa: 'email_not_valid'
        });
        sendEvent.call(this, { // Tagging Plan: line 44
            actionId: 'emails_dont_match',
            categoryGa: 'mylv',
            actionGa: 'create_an_account_form_sf',
            labelGa: 'emails_dont_match'
        });
        sendEvent.call(this, { // Tagging Plan: lines 34 & 35
            actionId: data.success ? 'account_creation_succeeded' : 'account_creation_failed',
            categoryGa: 'mylv',
            actionGa: 'create_an_account',
            labelGa: data.success ? 'account_creation_succeeded' : 'account_creation_failed'
        });
        sendEvent.call(this, { // Tagging Plan: line 59
            actionId: isValid ? 'account_creation_step_succeeded' : 'account_creation_failed',
            categoryGa: 'mylv',
            actionGa: 'create_an_account_form_sf',
            labelGa: isValid ? 'account_creation_step_succeeded' : 'account_creation_failed'
        });
        //Tagging Plan: line 27
        sendEvent.call(this, {
            actionId: 'create_new_account',
            categoryGa:'mylv',
            actionGa:'password_forgotten',
            labelGa:'create_new_account',
            actionPosition:'i_dont_have_an_account'
        });
        //Tagging Plan: line 23
        sendEvent.call(this, {
            actionId: 'cancel',
            categoryGa:'mylv',
            actionGa:'password_forgotten',
            labelGa:'cancel',
            actionPosition:'change_your_password'
        });
        //Tagging Plan: line 24
        sendEvent.call(this, {
            actionId: 'reset_password',
            categoryGa:'mylv',
            actionGa:'password_forgotten',
            labelGa:'reset_password',
            actionPosition:'change_your_password'
        });
        //Tagging Plan: line 25
        sendEvent.call(this, {
            event: 'resetPasswordFailure',
            actionId: 'email_not_found',
            categoryGa: 'mylv',
            actionGa: 'password_forgotten',
            labelGa: 'email_not_found',
            errorId: response + ' emailforgotPasswordForm_'//TODO ERROR ID
        });
        //Tagging Plan: line 26
        sendEvent.call(this, {
            event:'resetPasswordSuccess',
            actionId: 'email_sent',
            categoryGa:'mylv',
            actionGa:'password_forgotten',
            labelGa:'email_sent'
        });
        //Tagging Plan: line 11
        sendEvent.call(this, {
            actionId: 'create_new_account',
            actionGa:'create_new_account',
            categoryGa:'mylv',
            actionPosition:'i_dont_have_an_account'
        });
        //Tagging Plan: line 10
        sendEvent.call(this, {
            actionId: 'forgot_your_password',
            categoryGa:'mylv',
            actionGa:'forgot_your_password',
            actionPosition:'i_already_have_an_account'
        });
        //Tagging Plan: line 12
        sendEvent.call(this, {
            actionId: 'sign_in_intention',
            categoryGa:'mylv',
            actionGa:'i_already_have_an_account',
            labelGa : 'sign_in_intention',
            actionPosition:'i_already_have_an_account'
        });
        //Tagging Plan: line 13
        sendEvent.call(this, {
            event:'logInFailure',
            actionId: 'sign_in_failed',
            categoryGa:'mylv',
            actionGa:'connexion_module',
            labelGa:'sign_in_failed',
            actionPosition:'i_already_have_an_account'
        });
        //Tagging Plan: line 14
        sendEvent.call(this, {
            event:'logInSuccess',
            actionId: 'sign_in_succeeded',
            categoryGa:'mylv',
            actionGa:'connexion_module',
            labelGa:'sign_in_succeeded',
            actionPosition:'i_already_have_an_account'
        });
        // Tagging Plan: line 65
        sendEvent.call(this, {
            actionId: 'update_password',
            categoryGa:'mylv',
            actionGa:'update_password'
        });
    }
    
    
}