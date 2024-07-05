({  UploadNewDocument : function(component, helper, event){
    var fileInput = component.find("fileId").get("v.files");
    var file = fileInput[0];

    // get the first file using array index[0]  
    var fr = new FileReader();
    
    var self = this;
           fr.onload = $A.getCallback(function() {
         var fileContents = fr.result;
         var base64Mark = 'base64,';
         var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

         fileContents = fileContents.substring(dataStart);
    
        self.upload(component, file, fileContents);
    });

    fr.readAsDataURL(file);

},
upload: function(component, file, fileContents) {
    var action = component.get("c.createAttachment"); 

    action.setParams({
        parentId: component.get("v.productId"),
        fileName: file.name,
        base64Data: encodeURIComponent(fileContents), 
        contentType: file.type
    });

    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var files = component.get("v.files");
            var responseReturn = response.getReturnValue();
            console.log(responseReturn);
            var newFileContent={};

            newFileContent.fileName = component.get("v.document");
            newFileContent.fileId = responseReturn;

            
            files.push(newFileContent);
            component.set("v.files", files);
            component.set("v.document" ,'');

        } else if (state === "ERROR") {
            console.log("error");

        }
       
    });
        
    $A.enqueueAction(action); 
    
},

    sendMessage: function(component, helper, message){
        //Send message to VF
        message.origin = window.location.hostname;
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(message, component.get("v.vfHost"));

        // var action = component.get('c.uploadFile');
        // action.setParams({
        // 	"productId": message.productId
        // });
        
        // action.setCallback(this,function(response){
        //     var state = response.getState();
        //         if (state === "SUCCESS") {
        //             var responseReturn = response.getReturnValue();
        //             component.set("v.fileId", responseReturn);
        //             console.log("responseReturn", responseReturn);
        //         } else if (state === "INCOMPLETE") {
        //             // do something
        //         } else if (state === "ERROR") {
        //             var errors = response.getError();
        //             if (errors) {
        //                 if (errors[0] && errors[0].message) {
        //                     console.log("Error message: " + 
        //                                 errors[0].message);
        //                 }
        //             } else {
        //                 console.log("Unknown error");
        //             }
        //         }
        //     });
        // $A.enqueueAction(action);  
    },
})