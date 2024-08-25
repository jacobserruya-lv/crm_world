function sendEvent(payload) {
    this.template.querySelector('c-twist-google-analytics').sendEvent(payload);
}

function sendPageView(payload) {
    this.template.querySelector('c-twist-google-analytics').sendPageView(payload);
}

function allowTriggerNewPageViewEvent() {
    this.template.querySelector('c-twist-google-analytics').isPageViewEventSent = false;
}

export {
    sendEvent,
    sendPageView,
    allowTriggerNewPageViewEvent
}