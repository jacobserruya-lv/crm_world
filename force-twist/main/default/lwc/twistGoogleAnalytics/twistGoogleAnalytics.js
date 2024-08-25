import { LightningElement, api } from 'lwc';

export default class TwistGoogleAnalytics extends LightningElement {
    
    eventType2AutodataMethod = {
        event: "sendEvent",
        pageView: "sendPageView"
    };

    @api isPageViewEventSent = false;
    @api autodata;
    
    /**
    * @param {Proxy} payload
    */
    @api sendEvent(payload) {
        this.sendGeneric(
            JSON.parse(JSON.stringify(payload)),
            this.eventType2AutodataMethod.event
        );
    }
    
    /**
    * @param {Object} payload
    */
    @api sendPageView(payload) {
        payload = payload || {};
        if (!this.isPageViewEventSent) {
            this.sendGeneric(
                Object.assign(JSON.parse(JSON.stringify(payload)), { event: "pageview" }),
                this.eventType2AutodataMethod.pageView
            );
            this.isPageViewEventSent = true;
        }
    }
    
    /**
    * @param {Object} payload
    * @param {String} method
    */
    sendGeneric(payload, method) {
        try {
            // console.log("sendGeneric", payload);
            this.autodata[method](payload);
        }
        catch(e) {
            console.error(e);
        }
    }

    renderedCallback() {
        this.dispatchEvent(new Event('twistgalwcrendered'));
    }
    
}