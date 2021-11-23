({
    doInit : function(component, event, helper) {
        
        //buiding a page reference for the component where we need to navigate
        var baseurl = window.location.href;

		var isValidUser= true;
        if (baseurl.includes('partners.enterprise.telstra.com.au') || (baseurl.includes('/partners/s'))) { 
            if(component.get("v.sObjectName")=="Account"){
            var action = component.get("c.checkActivePOR");
            action.setParams({ accountId : component.get("v.recordId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('Partner Edit Notifications, ',state);
                if (state === "SUCCESS") {
                    console.log('response: ',response.getReturnValue());
                    isValidUser=response.getReturnValue();
                }
            });
            $A.enqueueAction(action);
            }
         setTimeout( $A.getCallback(function(){
            if(isValidUser){

            var navService = component.find("navService");
            var pageReference = {  
                "type": "comm__namedPage",
                "attributes": {
                    "pageName": "edit-notifications"    
                },    
                "state": {
                   c__recordId: component.get("v.recordId"),
                   c__objectName : component.get("v.sObjectName")
                }
            };

            sessionStorage.removeItem('pageTransfer');
            sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference));
            navService.navigate(pageReference);
 
            }else{
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Notifications preference from account can only be edited by Partner of Record',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                } 
             let quickActionClose = $A.get("e.force:closeQuickAction");
                quickActionClose.fire();
             }),1000);
             /*setTimeout(()=>{
                let quickActionClose = $A.get("e.force:closeQuickAction");
                quickActionClose.fire();
             },1000); */

        }else
        {
            var pageReference = {
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'Edit_Notifications',
                },
                state: { 
                    c__recordId: component.get("v.recordId"),
                    c__objectName : component.get("v.sObjectName")
                }
            };
            //navigate to component
            var navService = component.find("navService");
            //navigate function navigates to page reference
            navService.navigate(pageReference);
        }
    }
})