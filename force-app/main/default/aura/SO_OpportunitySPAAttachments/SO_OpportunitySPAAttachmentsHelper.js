({ 	//MAX_FILE_SIZE: 4 500 000,
	//CHUNK_SIZE: 450 000,
	
	initSessionID : function(component){

		var	action = component.get("c.getSessionId");

		action.setCallback(this, function(result){
			var state = result.getState();
			if (state === 'SUCCESS'){
				var sessionID = result.getReturnValue();
				component.set("v.sessionID", sessionID);
				console.log("sessionID -> " + sessionID);

				var client = new forcetk.Client();
				sessionID = component.get("v.sessionID");
				client.query("SELECT Name FROM Oppotunity LIMIT 100", function(response){
					console.log(response.records[0].Name);
				});

			} else {
				console.log("failed getting session ID");
			}

		});

		$A.enqueueAction(action);

	},

	getFiles : function(component, category, opp) {
		var action = component.get("c.getFiles");
		action.setParams({
			"opp": opp
		});

		action.setCallback(this, function(result){
			var state = result.getState();

			if (state === "SUCCESS"){
				var files = result.getReturnValue();
				console.log("files -> " + files.length);
				// component.set("v.filesList", files);
				return files
			} else {
				var errors = action.getError();
				if (errors[0] && errors[0].message)
				console.log("Something broke -> " + errors[0].message);
			}
		});
		$A.enqueueAction(action);
	},

	saveFiles : function(component, files){
		// var client = new forcetk.Client();
		// var sessionID = component.get("v.sessionID");
		// console.log("sessionID -> " + sessionID);
		// client.setSessionToken(sessionID);

		// console.log(client);
        var totalFileSize = 0;
        var file = "";
		for (var i=0; i<files.length; i++){
			file = files[i];
            totalFileSize += file.size;
            var toastParams = {};
            if(totalFileSize / 1048576 <= 1){/*block the file when the total is over 1mb, 1 byte = 1,048,576 mb */
                var self = this;
                self.saveFile(component, file);
            } else {/*if the file is greater than 1mb, block the saving*/

                 console.log('toastEvent -->', toastEvent);
                    toastParams = {
                        "type":"error",
                        "title": "Your files' size is greater than 1MB",
                        "message": "Please choose  smaller files"
                    };

            var toastEvent = $A.get("e.force:showToast");
                if (toastEvent){
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                } else {
                    console.log("toastEvent not found");
                    var customToast = $A.get("e.c:SO_CustomToastEvent");
                    console.log("using custom toast");
                    customToast.setParams(toastParams);
                    console.log(customToast);
                    customToast.fire();
                } 
            }
        	
		}
        
        console.log("totalFileSize in SPA Attachment :" + totalFileSize / 1048576 + "MB"); /* total file size is shown as byte in dev console.
        and 1 byte = 1048576 MB */

        /* var toastParams = {};
        if((totalFileSize / 1048576 ) > 25) {

            console.log('toastEvent -->', toastEvent);
                    toastParams = {
                        "type":"error",
                        "title": "Your files' size is greater than 25MB",
                        "message": "Please choose  smaller files"
                    };

            var toastEvent = $A.get("e.force:showToast");
                if (toastEvent){
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                } else {
                    console.log("toastEvent not found");
                    var customToast = $A.get("e.c:SO_CustomToastEvent");
                    console.log("using custom toast");
                    customToast.setParams(toastParams);
                    console.log(customToast);
                    customToast.fire();
            } 
        } else
        {
            var self = this;
            self.saveFile(component,file);
        } */
	},

	/*saveFile2 : function (component, file, client){
		client.createBlob('ContentVersion', {
              Origin: 'C', // 'H' for Chatter File, 'C' for Content Document
              PathOnClient: file.name
          }, file.name, 'VersionData', file, function(response){
              console.log(response);
              $("#message").html("Chatter File created: <a target=\"_blank\" href=\"/" + response.id + "\">Take a look!</a>");
          }, function(request, status, response){
              $("#message").html("Error: " + status);
          });
	},*/

	saveFile : function (component, file){

		console.log("file -> " + file.name + " (size -> " + file.size + "KB" +")");

        /* var fileNameInKb = file.size / 1024; //  1 byte = 1024 KB 
        
        var toastParams = {};
        if(fileNameInKb >= 1024) {// 1 kb = 1024 mb, so we block the file when it is greater than 1MB
            
            console.log('toastEvent -->', toastEvent);
                    toastParams = {
                        "type":"error",
                        "title": "Your file size is greater than 1Mb",
                        "message": "Please choose a smaller file"
                    };

            var toastEvent = $A.get("e.force:showToast");
                if (toastEvent){
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                } else {
                    console.log("toastEvent not found");
                    var customToast = $A.get("e.c:SO_CustomToastEvent");
                    console.log("using custom toast");
                    customToast.setParams(toastParams);
                    console.log(customToast);
                    customToast.fire();
            } 

         return;
        } */
        

		var fr = new FileReader();
        
       	fr.onload = function() {
       		console.log("loaded");
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
 
            fileContents = fileContents.substring(dataStart);

            var action = component.get("c.getNewFile");
            action.setCallback(this, function(result){
            	var state = result.getState();

            	if (state === "SUCCESS"){	     
            		console.log("success");       	
            		var fileContent = result.getReturnValue();	
		        	fileContent.fileName = file.name;
		        	fileContent.base64Data = encodeURIComponent(fileContents);
                    var byteLength = parseInt((fileContent.base64Data).replace(/=/g,"").length * 0.75);
                    console.log(fileContent.fileName +""+ " base64Data in SPA Attachment :" + byteLength);
		        	fileContent.contentType = file.type;
		        	//fileContent.contentDocumentId = file.id;
		        	console.log("file", file);

		        	var filesList = component.get("v.files");
		        	filesList.push (fileContent);

		        	component.set("v.files", filesList);
            	} else {
            		console.log ("error");
            	}
            });

            $A.enqueueAction(action);
    	    // self.upload(component, file, fileContents);
        };
 
        fr.readAsDataURL(file);

        /*  
        //var fileInput = component.find("file").getElement();
    	//var file = fileInput.files[0];
   
        //if (file.size > this.MAX_FILE_SIZE) {
            //alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    		  //'Selected file size: ' + file.size);
    	    //return;
       // }
        
        var fr = new FileReader();

        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
        
    	    self.upload(component, file, fileContents);
        };

        fr.readAsDataURL(file);*/
    
	},

	upload : function(component, file, fileContents){

        var action = component.get("c.saveTheFile"); 
 
        action.setParams({
            oppId: component.get("v.opp.Id"),
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents), 
            contentType: file.type
        });
 
        action.setCallback(this, function(a) {
            var attachId = a.getReturnValue();
            console.log("attachId -> " + attachId);
        });
        
        $A.enqueueAction(action); 

        /*var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);
		
        // start with the initial chunk
        this.uploadChunk(component, file, fileContents, fromPos, toPos, ''); */  
        fr.onload = $A.getCallback(function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
       
    	    self.upload(component, file, fileContents);
        });
        $A.enqueueAction(action);
    },

    /*uploadChunk : function(component, file, fileContents, fromPos, toPos, attachId) {
        var action = component.get("c.saveTheChunk"); 
        var chunk = fileContents.substring(fromPos, toPos);

        action.setParams({
            parentId: component.get("v.opp.Id"),
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            fileId: attachId
        });
       
        var self = this;
        action.setCallback(this, function(a) {
            attachId = a.getReturnValue();
            
            fromPos = toPos;
            toPos = Math.min(fileContents.length, fromPos + self.CHUNK_SIZE);    
            if (fromPos < toPos) {
            	self.uploadChunk(component, file, fileContents, fromPos, toPos, attachId);  
            }
        });
            
        $A.run(function() {
            $A.enqueueAction(action); 
        });
    },*/

        
    
    deleteFile : function(component, index){
        console.log("------Index Helper:");
        console.log(index);
    	var filesList = component.get("v.files");
        
    	filesList.splice(index, 1);
        //var compvalue = component.find("fileinput").set("v.value",null);    
          
        component.set("v.files", filesList);
        
        
    }
    
    
    
    
    
})