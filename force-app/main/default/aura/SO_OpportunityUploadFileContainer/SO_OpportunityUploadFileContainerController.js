({
    doInit : function(component, event, helper) {

        // component.set("v.files", []);

        //Send LC Host as parameter to VF page so VF page can send message to LC; make it all dynamic
        var action = component.get('c.getDummyProductDB');
        action.setCallback(this,function(response){
            var state = response.getState();
                if (state === "SUCCESS") {
                    var responseReturn = response.getReturnValue();
                    component.set("v.productId", responseReturn);
                    console.log("responseReturn", responseReturn);
                } else if (state === "INCOMPLETE") {
                    // do something
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
        $A.enqueueAction(action);  


        // var productId = component.get("v.productId");
		
        // component.set('v.lcHost', window.location.hostname);

        // var attachmentCategory = component.get("v.attachmentCategory");
        // var frameSrc = '/apex/SO_OpportunitySPAAttachmentVFP?id=' + productId + '&attachmentCategory=' + attachmentCategory + '&lcHost=' + component.get('v.lcHost');
        // console.log('frameSrc:' , frameSrc);
        // component.set('v.frameSrc', frameSrc);

        // // listen to file message from VFP
        // window.addEventListener("message", function(event) {

        //     console.log('event.data from VFP :', event.data);

        //     // Handle the message
        //     if(event.data.state == 'LOADED'){
        //         //Set vfHost which will be used later to send message
        //         component.set('v.vfHost', event.data.vfHost);
        //     }

        //     if(event.data.state == 'uploadFileSelected'){
        //         component.find('uploadFileButton').set('v.disabled', false);
        //         //component.set("v.file",)
        //     }

        //     if(event.data.state == 'fileUploadprocessed'){

        //         if (event.data.attachmentCategory != component.get("v.attachmentCategory")){
        //             console.log("returning");
        //             return;
        //         }

        //         var actionNewFile = component.get("c.getNewFile");
        //         actionNewFile.setCallback(this, function(response){
        //             var state = response.getState();

        //             if (state === "SUCCESS"){
        //                 var files = component.get("v.files");
        //                 var newFileContent = response.getReturnValue();
        //                 if(event.data.file != ""){
        //                     newFileContent.fileName = event.data.file;
        //                     newFileContent.fileId = event.data.fileId;
        //                 }

        //                 files.push(newFileContent);
        //                 component.set("v.files", files);
        //                 // console.log("file name sent from VFP and set on component :" + JSON.stringify(component.get("v.files")));
        //                 // var fileIdList = component.get("v.fileIds");
        //                 // if(event.data.file != ""){
        //                 //     fileIdList.push(event.data.fileId);
        //                 // }
        //                 // component.set("v.fileIds",fileIdList);
        //                 // console.log("file Ids set on component :" + JSON.stringify(component.get("v.fileIds")));
                        
        //                 // component.set("v.attachmentCategory", event.data.attachmentCategory);
        //                 console.log("attachmentCategory set on uploadFile:" + JSON.stringify(component.get("v.attachmentCategory")));
        //                 //Disable Upload button until file is selected again
        //                 component.find('uploadFileButton').set('v.disabled', true);

        //                 $A.createComponents([
        //                         ["markup://ui:message",{
        //                             "body" : "File uploaded successfully",//event.data.message,
        //                             "severity" : event.data.messageType,
        //                         }]
        //                     ],
        //                     function(components, status, errorMessage){
        //                         if (status === "SUCCESS") {
        //                             var message = components[0];
        //                             // set the body of the ui:message to be the ui:outputText
        //                             component.find('uiMessage').set("v.body", message);
        //                         }
        //                         else if (status === "INCOMPLETE") {
        //                             console.log("No response from server or client is offline.")
        //                             // Show offline error
        //                         }
        //                         else if (status === "ERROR") {
        //                             console.log("Error: " + errorMessage);
        //                             // Show error message
        //                         }
        //                     }
        //                 );

        //             } else {
        //                 console.log("oops");
        //             }
        //         });

        //         $A.enqueueAction(actionNewFile);
        //     }
        // }, false);
    },

    handleFilesChange: function(component, event, helper) {
        var file=  component.find("fileId").get("v.files");

        if(file.length < 0 ){
            
            alert('Please Select a File');
        }
        var fileUpload = file[0];
        console.log('fileUpload ' + fileUpload.size );
        if((fileUpload.size  / (1024 * 1024 )) > 5 ){

            alert($A.get("$Label.c.SPO_Upload_file_size_error_msg"));
        }
        component.set("v.document" ,fileUpload.name);
        component.find('uploadFileButton').set('v.disabled', false);


    },

    sendMessage: function(component, event, helper) {
        
        component.find('uploadFileButton').set('v.disabled', true);
        helper.UploadNewDocument(component, helper, event);
        //Clear UI message before trying for file upload again
       /* var productId = component.get("v.productId");
        component.find('uiMessage').set("v.body",[]);

        //Prepare message in the format required in VF page
        var message = {
            "uploadFile" : true,
            "productId" : productId
        } ;
        //Send message to VF
        helper.sendMessage(component, helper, message);*/
    },

    /*handleApplicationEvent : function(component,event){
    	var productEvt = event.getParams("product");
    	console.log("Opportunity SPA Event Params :" + JSON.stringify(productEvt));
    	var productId  = productEvt.product.Id;
    	console.log("product Id in Attachment VFP " + productId);
    	component.set("v.productId", productId);

        var frameSrc = '/apex/SO_OpportunitySPAAttachmentVFP?id=' + productId + '&lcHost=' + component.get('v.lcHost');
        console.log('frameSrc:' , frameSrc);
        component.set('v.frameSrc', frameSrc);
    }*/

    fireFileUploadEvent : function(component,event,helper){
        var fileUploadEvt = $A.get("e.c:SO_FileUploadEvent");
        fileUploadEvt.setParams({
            "fileName" : component.get("v.file")
        });
        fileUploadEvt.fire();
    }
})