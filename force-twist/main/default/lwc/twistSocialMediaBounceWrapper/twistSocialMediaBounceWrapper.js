import { LightningElement, api } from 'lwc';
import { sendEvent } from 'c/twistUtils';

export default class TwistSocialMediaBounceWrapper extends LightningElement {

    @api autodata;
    @api lwcAttributes;

    renderedCallback() {
        const lwcAttributes = JSON.parse(this.lwcAttributes);
        if (!lwcAttributes.hasOwnProperty('payloadForAutodata')) {
            console.error('Missing key "payloadForAutodata" in lwcAttributes Object');
            return;
        }
        if (lwcAttributes.payloadForAutodata) {
            sendEvent.call(this, lwcAttributes.payloadForAutodata);
        }
        if (!lwcAttributes.hasOwnProperty('redirectUrl')) {
            console.error('Missing key "redirectUrl" in lwcAttributes Object');
            return;
        }
        // console.log("> location.href", lwcAttributes.redirectUrl) // JSSI remove
        location.href = lwcAttributes.redirectUrl; // JSSI uncomment
    }

}