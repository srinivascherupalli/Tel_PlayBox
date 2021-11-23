({
	getAccountRecord : function(component, event, helper) {
		//calling apex method.
        var action = component.get("c.getAccRecord");

        action.setParams({"AccountId":component.get("v.recordId")
                         });
        var p = helper.executeAction(component, action);
        
        // use the promise to do something 	
        p.then($A.getCallback(function(result){
            console.log('--- Account result '+JSON.stringify(result))
            component.set("v.accRec",result.acc);
            component.set("v.accUserInfo", result.users);
            

        })).catch($A.getCallback(function(error){
            // Something went wrong
            alert('An error occurred : ' + error.message);
        }));
       
    },
    
    
    createAccEventSync :function(component, event, helper){
        //var selectedMenu = event.detail.menuItem.get("v.value");
        var feedback=null;
		var selectedMenuItemValue = event.getParam("value");

        switch(selectedMenuItemValue){
            case "RequestSharePointSync":
                
                var action = component.get("c.createAccMemberSyncEvent");
                action.setParams({"AccountId":component.get("v.recordId")});
                
                if(component.get("v.accUserInfo").Id === component.get("v.accRec").OwnerId){

                    var p = helper.eventCreate(component, action);
                    p.then($A.getCallback(function(result){
                        console.log('--- Event result '+JSON.stringify(result))
                         helper.showToast('', 'Success', $A.get("$Label.c.sharepoint_sync_success_message"));
                        })).catch($A.getCallback(function(error){
                         helper.showToast('ERROR', 'error', $A.get("$Label.c.SharePointAccSystemErrorMsg"));
                    })); 
                }
                
                else if(component.get("v.accUserInfo").Id !== component.get("v.accRec").OwnerId){

					helper.showToast('', 'warning',$A.get("$Label.c.SharePointAccSynErrorMsg"));
                }
                else{
 
						helper.showToast('', 'error', 'System Error: Your request has failed. Please try again later and log '+ feedback +' if the problem persists.'); 
                    }
                break;
            case "RequestSharePointAccess":
                
                var action = component.get("c.createAccRequestAccess");
                action.setParams({"AccountId":component.get("v.recordId")});
                if((component.get("v.accUserInfo").Id === component.get("v.accRec").OwnerId) || component.get("v.accUserInfo").Id !== component.get("v.accRec").OwnerId){
                var p = helper.eventCreate(component, action);
                    p.then($A.getCallback(function(result){
                        console.log('Account Reqeust Access Value is '+JSON.stringify(result))
                         helper.showToast('', 'Success', $A.get("$Label.c.sharepoint_sync_success_message"));
                        })).catch($A.getCallback(function(error){
                         helper.showToast('ERROR', 'error', $A.get("$Label.c.SharePointAccSystemErrorMsg"));
                    })); 
                }
                else{
 
						helper.showToast('', 'error', 'System Error: Your request has failed. Please try again later and log '+ feedback +' if the problem persists.'); 
                    }
                break;
        }
    },
})