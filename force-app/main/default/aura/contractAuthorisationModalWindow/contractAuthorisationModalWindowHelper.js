({  
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        component.set("v.showSpinner",true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
       // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.OppId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });
         // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                component.set("v.showSpinner",false);
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    component.set("v.showSpinner",false);
                     component.set("v.showLoadingSpinner", false);
                    this.returnURLToBasket(component, event);
                }
                // handel the response errors        
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    submitAndCloseHelper: function(component, event,isPreauthorisation) {
        let NotesValue=component.find("NotesId").get("v.value");
        let isPreAuth= isPreauthorisation; 
        let bskId=component.get("v.basketId");
        let OppId=component.get("v.OppId");
        let contentDocId=component.get("v.contentDocId");
        let file=component.find("fileId").get("v.files");
        var action = component.get("c.submitPreAuthAndNotes");  
        action.setParams({  
            "isPreAuth":isPreAuth,
            "NotesValue":NotesValue,
            "bskId":bskId,
            "OppId":OppId,
            "contentDocId":contentDocId
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
				component.set("v.errorMsg", 'Customer Pre-Authorisation was updated.');
                component.set("v.toastClass", 'slds-theme_success');
                component.set("v.toastIcon", 'success');
                this.showError(component, event);
                component.set("v.showSpinner",false);
                let file=component.find("fileId").get("v.files");
                if ( file!=null && component.find("fileId").get("v.files").length > 0) {
                    this.uploadHelper(component, event);
                } else{
                    this.returnURLToBasket(component, event);
                    component.set("v.showSpinner",false);
                }
             } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.set("v.errorMsg", 'Customer Pre-Authorisation could not be saved. Please try again.');
                        component.set("v.toastClass", 'slds-theme_error');
                        component.set("v.toastIcon", 'warning');
                        helper.showError(component, event);
                         component.set("v.showSpinner",false);
                        
                    }
                }
             }  
        });  
        $A.enqueueAction(action); 
    },
    returnURLToBasket: function(component, event, helper) {
        let bskId=component.get("v.basketId");
        let profileName=component.get("v.profileName");
        let returnURL ='';
        //EDGE-164560
        if(profileName==="PRM Community User - Australia" || profileName==="PRM Admin - Australia"){
            returnURL ="/partners/s/product-basket/"+bskId.trim();
        }else{
            returnURL = "/lightning/r/cscfga__Product_Basket__c/"+bskId.trim()+"/view";
        }
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": returnURL,
            "slideDevName": "ContractAuthorizationComponents"
        });
        navEvt.fire();
    },
    showError  : function(component, event) {
        var toggleText = component.find("errorMsgId");
        $A.util.removeClass(toggleText,'toggle');
        window.setTimeout(
            $A.getCallback(function() {
                $A.util.addClass(component.find("errorMsgId"),'toggle'); 
            }), 6000
        );
    }, 
})