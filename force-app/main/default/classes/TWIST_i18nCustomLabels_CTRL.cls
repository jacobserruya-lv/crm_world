public with sharing class TWIST_i18nCustomLabels_CTRL {
    
    public List<String> customLabels {get; set;}

    public void init() {
        if(Test.isRunningTest()) {
            ApexPages.currentPage().getParameters().put('customLabels', 'label1,label2,label3');
        }
        customLabels = ApexPages.currentPage().getParameters().get('customLabels').split(',');
    }
}