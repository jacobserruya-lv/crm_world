({  
     
    //Open File onclick event  
    OpenFile :function(component,event,helper){  
      var rec_id = event.currentTarget.id;  
      $A.get('e.lightning:openFiles').fire({ //Lightning Openfiles event  
        recordIds: [rec_id] //file id  
      });  
    },  
    UploadFinished : function(component, event, helper) {  
        var uploadedFiles = event.getParam("files"); 
        var files= component.get("v.allFiles");  
        for(var i = 0; i < uploadedFiles.length; i++){
            files.push({
              name: uploadedFiles[i].name,
              documentId :uploadedFiles[i].documentId
            });
        }
        component.set("v.allFiles",files);  
        console.log(component.get("v.allFiles"));

        var toastEvent = $A.get("e.force:showToast");  
        toastEvent.setParams({  
            "title": "Success!",  
            "message": "File  Uploaded successfully.", 
            "type" : "Success"
        });  
        toastEvent.fire();  
      
    }, 
    handleClick: function(component, event, helper) {
      var fileToDelete = event.getSource().get("v.value");
      var allfiles = component.get("v.allFiles");
      var index = allfiles.findIndex(v => v.documentId  === fileToDelete);
      allfiles.splice(index, 1)
      if(allfiles.length == 0){
        component.set("v.allFiles",[]);  
      }
      else{
        component.set("v.allFiles",allfiles);  

      }
      var action = component.get("c.deleteAttachments");
      action.setParams({
        attachId : fileToDelete
      });
      action.setCallback(this, function(response){
        var state = response.getState();
        if(state === "SUCCESS"){
            console.log("remoove");
          }
      });
      $A.enqueueAction(action); 
    },

    
    
  })