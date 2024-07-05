global class ICX_GenesysExtensionPoint implements 
    purecloud.CTIExtension.SaveLog,
    purecloud.CTIExtension.ScreenPop
{
    public String onScreenPop(String data) {
        Map<String, Object> dataToReturn = new Map<String, Object>{'defaultScreenPop'=>false};
        return JSON.serialize(dataToReturn);
    }
    
    public String onSaveLog(String data) { 
        String interId, recordId = null;
        Id taskId = null;       
        try{          
            String transformedData = ICX_GenesysData.replace(data);
            System.debug('@@@ transformed data '+ transformedData);
            ICX_GenesysData dataObj = (ICX_GenesysData)JSON.deserialize(transformedData, ICX_GenesysData.class);  
            ICX_GenesysData.Interaction inter = dataObj.interaction;
        
            if(inter.phone != null || inter.callbackNumbers != null){ // Is a call or Web CallBack Not email or message
                // Do not use inter.ani == 'Internal' for not exclude outbound call to customers 
                if(inter.isInternal){ // this condition include monitoring ON Agent Side (not client -external-side)
                    taskId = null;
                } 
                else if (inter.isConnected && !inter.isDisconnected){   
                    taskId = ICX_GenesysTaskStore.createTask(dataObj);
                }
                else if(inter.isDisconnected && !inter.isConnected && inter.dispositionDurationSeconds == null){
                    taskId = ICX_GenesysTaskStore.updateTaskDuration(dataObj);
                }
            }
            // for logs
            interId = inter.id;
            recordId = inter.attributes != null && inter.attributes.get('sf_urlpop') != null ? inter.attributes.get('sf_urlpop') : taskId;
        }
        catch(Exception e){
            taskId = null; // Prevent returning a false Id when record creation is rollbacked
            new Logs.ERROR('ICX_GenesysExtensionPoint', 'APEX Code', e);
        }
        finally {
            // DML transaction need to be AFTER clienteling callout
            if(ICX_GenesysSettings__c.getOrgDefaults().LogEnabled__c){
                log(data, interId, recordId);
            }
        }
        return taskId;
    }   

	/**
	 * Log Json obj received from Genesys
	 */
    @TestVisible
    private static void log(String data, String interId, String recordId){
        Map<String, Object> logMap = new Map<String, Object>{
            'apexClass' => 'ICX_GenesysExtensionPoint',
            'application' => 'ICONICS',
            'category' => 'APEX CODE',
            'message' => data,
            'recordId' => recordId,
            'details' => interId        
        };
        Logs log = new Logs(logMap);
    }
}