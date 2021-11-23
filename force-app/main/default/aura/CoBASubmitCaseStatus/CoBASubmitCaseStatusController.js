({
    //The method is used to call the apex class CoBAProcessHelper to fetch the validation message while validating the case.
    //Based on the custom setting CoBA Utility Settings(ShowCoBAToastMessage) the toast message or modal UI is selected.
    doinIt : function(component, event, helper) {
        
        component.set("v.showSpinner",true);
        var recordIdList=component.get("v.recordId");
        var action = component.get("c.coBACaseResubmitMethod");
        action.setParams({
            "caseId" : recordIdList
        });
         action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue= response.getReturnValue();
             
            if (state === "SUCCESS") {
                if(returnValue['showToastMessage'] == 'false') {
                 component.set("v.showMessageOnModal",true);
                }else{
                    component.set("v.hideModal",true);
                }
                if(returnValue[component.get("v.recordId")].includes('Successfully')){
                    component.set("v.toastType",'Success');
                }
                 component.set("v.showSpinner",false);
                component.set("v.toastMessage",returnValue[component.get("v.recordId")]);
            }
             if(component.get("v.showMessageOnModal") == false) {
                  helper.showToastMessage(component.get("v.toastType"),component.get("v.toastMessage"));
             }
  
        });
        $A.enqueueAction(action);
    }
})