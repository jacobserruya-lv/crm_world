global with sharing class BL_SITE_UserInfo extends BL_UserInfo{

    global override Map<String,Object> extendInfos(){
        return new Map<String,Object>();
    }

    global override Map<String, String> userMergeFields() {
        return new Map<String, String>();
    }
}