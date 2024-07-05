import { LightningElement, api } from 'lwc';
import reCaptchaHtml from '@salesforce/resourceUrl/reCaptcha_HTML';

export default class GoogleRecaptcha extends LightningElement {

    constructor() {
        super();
        window.addEventListener("message", e => this.handleListenToMessage(e)); // Add event listener for message posted from reCaptcha_HTML Static Resource
    }

    /**
     * @param {String} reCaptchaSiteKey
     */
    @api issueRecaptchaToken(reCaptchaSiteKey) {
        const iframeSrc = reCaptchaHtml + `?sitekey=${reCaptchaSiteKey}`;
        this.template.querySelector('iframe').src = iframeSrc;
    }

    handleListenToMessage(message) {
        if (typeof message.data == 'object' && message.data.hasOwnProperty('reCaptchaToken')) {
            if (!message.data.reCaptchaToken) {
                console.log('Error when loading reCAPTCHA: token has not been generated.');
            }
            else {
                console.log('Google reCAPTCHA is loaded.');
                this.dispatchEvent(new CustomEvent('getrecaptchatoken', { detail: message.data.reCaptchaToken }));
            }
        }
    }

}