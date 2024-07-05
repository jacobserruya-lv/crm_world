global with sharing class ICX_catalogSearch {
    

    @RemoteAction 
    global static MuleSoft_API_Callout__mdt getCredentialsForGaston(String input) {

    MuleSoft_API_Callout__mdt listCredentials = MuleSoft_API_Callout__mdt.getInstance('Catalog_GastonSearch');

        
    System.debug('getCredentialsForGaston listCredentials : ' + listCredentials);


    return listCredentials;
  }
}