public with sharing class TWIST_RedirectTo_CTRL {

    public Pagereference redirect() {
        String partialURL = Apexpages.CurrentPage().getParameters().get('partialURL');
        System.debug('>>> partialUrl = ' + partialURL);
        return TWIST_Utils.buildPageReference(
            EncodingUtil.urlDecode(partialURL, 'UTF-8'),
            System.currentPageReference().getParameters());
    }

}