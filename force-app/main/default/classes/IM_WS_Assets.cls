/*
CreatedDate: March 2018
Company: Balink
Author: Jeremy Martiano
Description: Interface Web Sevice to Download Assets
*/

@RestResource(urlMapping='/Assets/*')
global with sharing class IM_WS_Assets {
   
   // global  class customException extends Exception {}

    /*=================================================================================================================*/
    @HttpGet
    global static void get() {

        RestRequest req = RestContext.request;
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        string response;

        try{
            if(service == ''){
                response = JSON.serialize(getAssets());
            }
            res.responseBody = Blob.valueOf(response);
            //UtilsLogs.addLog('ICON', 'IM_WS_Assets', JSON.serialize(req.params),  JSON.serialize(req), response, '');
            new Logs.DEBUG('IM_WS_Assets','API',response);
        }
        catch(Exception ex){
            string error = ex.getMessage() + '\n\n' + ex.getLineNumber();
            res.responseBody = Blob.valueOf(JSON.serialize(error));
            res.statusCode = 400;
            //UtilsLogs.addLog('ICON', 'IM_WS_Assets', JSON.serialize(req.params),  JSON.serialize(req),'', error);
            new Logs.ERROR('IM_WS_Assets','API',error);
        }
    }

    /*=================================================================================================================*/
    global static List<AssetWrapper> getAssets(){
    	List<AssetWrapper> assets = new List<AssetWrapper>();
    	List<IconSetting__mdt> iconSettings = [
            Select Text__c
             FROM IconSetting__mdt 
             WHERE MasterLabel ='ICONAssetsLibraryName'
         ];

         if(iconSettings.size()>0){
         	String libraryName = iconSettings[0].Text__c;
         	List<ContentWorkspace> librairies = [SELECT Id FROM ContentWorkspace WHERE Name = :libraryName];
            system.debug(librairies);
			if(librairies.size()>0){
				List<ContentDocument> docs = [
                    SELECT Id, Title, FileExtension, LatestPublishedVersionId, CreatedDate 
                    FROM ContentDocument 
                    WHERE ParentId = : librairies[0].Id
                    ORDER BY CreatedDate desc
                ];
		    	system.debug(docs);
		    	for(ContentDocument doc: docs){
		    		AssetWrapper asset = new AssetWrapper(doc.LatestPublishedVersionId, doc.Title,doc.FileExtension, doc.CreatedDate);
		    		assets.add(asset);
		    	}
                system.debug(assets);
			}

         }
        // throw new customException('TEST MESSAGE');
        
    	return assets;
    } 

    /*=================================================================================================================*/
global  class AssetWrapper {
	    public String Id {get; set;}  
	    public String Name {get; set;}
	    public String Type {get; set;}  
	    public Datetime CreatedDate {get; set;}

	    public AssetWrapper(String id, String name,String extType, DateTime createdDate){
            this.Id = id;
            this.Name = name;
            this.Type = extType;
            this.CreatedDate = createdDate;

        } 
	}

}