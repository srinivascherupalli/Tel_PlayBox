({
    doInit : function(component, event, helper){
        //var pageReference = component.get("v.pageReference");
        console.log('pageReference = '+component.get("v.recordId"));
        helper.fetchDetails(component, event, helper);
        
    },
    handleClick:function(component, event, helper){
        
        
        if(component.get("v.recordId") != null){
            component.set("v.spinner", true);
            helper.fetchDetails(component, event, helper);
            
            var action = component.get("c.changeAgreementRecordStatus");
            
            action.setParams({ conJunId : component.get("v.recordId")});
            
            action.setCallback(this, function(response) {
               // alert(response.getState());
                var state = response.getState();
                if(state === "SUCCESS")
                {
                     component.set("v.spinner", false);
                    if(response.getReturnValue() == 'Success'){
                        component.set("v.errorMsg", 'Success');
                        helper.showError(component, event, helper,'Success','Record is Succesfully Updated');                            
                    }
                    else{
                        component.set("v.errorMsg", 'Something went Wrong');
                        helper.showError(component, event, helper,'Error','Something went Wrong. Please try again later');
                    }
                    
                }else{
                    component.set("v.spinner", false);
                    component.set("v.errorMsg", 'Something went Wrong');
                    helper.showError(component, event, helper,'Error','Something went Wrong. Please try again later');
                }
               /* var returnURL ='';                            
                returnURL = "/lightning/r/ContractJunction__c/"+component.get("v.recordId")+"/view"; 
                console.log('returnURL = '+returnURL);
                var navEvt = $A.get("e.force:navigateToSObject");                           
                navEvt.setParams({
                    "recordId": component.get("v.recordId"),
                    "slideDevName": "detail"
                });
                navEvt.fire();*/
                location.reload()
                
            });
            $A.enqueueAction(action);
        }
    }
})