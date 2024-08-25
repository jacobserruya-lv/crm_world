public with sharing class BL_EMAIL_WS_RouterMapping extends BL_WS_RouteMapping {

    public override Map < String,String > routesMapping() {
        return new Map < String,String > {
           '/config' => 'BL_EMAIL_Config',
           '/templates' => 'BL_EMAIL_EmailTemplates',
           '/templates/{id}' => 'BL_EMAIL_EmailTemplates',
           '/quick-texts/{id}' => 'BL_EMAIL_QuickText',
           '/quick-texts' => 'BL_EMAIL_QuickText',
           '/contacts' => 'BL_EMAIL_Contacts',
           '/contacts/{id}' => 'BL_EMAIL_Contacts',
           '/send' => 'BL_EMAIL_Sender',
           '/files' =>  'BL_EMAIL_File'
        };
    }
}