({
    
    doInit: function(component,event,helper) {
        let bskId=component.get("v.basketId");
        let OppId=component.get("v.OppId");
        var action = component.get("c.onLoadCmp");  
        action.setParams({  
            "bskId":bskId,
            "OppId":OppId
        });      
        action.setCallback(this,function(response){  
             var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();  
                //EDGE-164560
                component.set("v.profileName",result.profileName);
                let isPreAuth=result.isPreAuth;
                component.set("v.contentDocId",result.contentDocId);
               //EDGE-165471 component.set("v.uploadedContentDocsId",result.uploadedContentDocsId);
                if(isPreAuth){
                    component.set("v.isSubmitDisable",false);
                    component.set("v.isPreauthorisation",true);
                }else{
                    component.set("v.isSubmitDisable",true);
                }
                component.find("NotesId").set("v.value",result.preAuthComments);
            }else if (state === "ERROR") {
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
    handleChange: function (component, event) {
        let preauthorisation=component.get("v.isPreauthorisation");
        if(preauthorisation){
            component.set("v.isSubmitDisable",false);
            component.set("v.isPreauthorisation",true);
        }else{
            component.set("v.isSubmitDisable",true);
        }
    },
    cancelModel: function(component, event, helper) {
        helper.returnURLToBasket(component, event);  
    },
    
    submitAndClose: function(component, event, helper) {
        component.set("v.showSpinner",true);
        let isPreauthorisation=component.get("v.isPreauthorisation");
        if(isPreauthorisation){
            helper.submitAndCloseHelper(component, event,isPreauthorisation);
        }else{
            component.set("v.errorMsg", 'Pre-Authorisation is Mandatory');
            component.set("v.toastClass", 'slds-theme_warning');
            component.set("v.toastIcon", 'warning');
            helper.showError(component, event);
        }
    },
    
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            var fileNameDiv = component.find('fileNameId');
            $A.util.removeClass(fileNameDiv, 'slds-text-color_error');
        }
        component.set("v.fileName", fileName);
        if (component.find("fileId").get("v.files").length > 0) {
            component.set("v.errorMsg", 'Upload Successful');
            component.set("v.toastClass", 'slds-theme_success');
            component.set("v.toastIcon", 'success');
            helper.showError(component, event, helper);
        } else {
            component.set("v.errorMsg", 'Please Select a Valid File');
            component.set("v.toastClass", 'slds-theme_warning');
            component.set("v.toastIcon", 'warning');
            helper.showError(component, event);
        }
    },
    
    toggle : function(component, event, helper) {
        var toggleText = component.find("errorMsgId");
        $A.util.toggleClass(toggleText, "toggle");
    },
})