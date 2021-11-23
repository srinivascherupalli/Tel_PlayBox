({
    getOppRecord : function(component, event, helper) {        	
        var action=component.get("c.getOppRecData");
        console.log('--- rec id'+component.get("v.recordId"));
        action.setParams({"opportunityId":component.get("v.recordId")
                         });
        var p = helper.executeAction(component, action);
        
        // use the promise to do something 
        p.then($A.getCallback(function(result){
            console.log('--- opportunity result '+JSON.stringify(result))
            component.set("v.OppRec",result);
        })).catch($A.getCallback(function(error){
            // Something went wrong
            alert('An error occurred : ' + error.message);
        }));
        //$A.get('e.force:refreshView').fire();
    },
    
    getuserdetail: function(component, event, helper) {
        
        var action = component.get("c.fetchUser");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
            }
        });
        
        //var pageParam= new Object();
        //pageParam.pageObjectID=component.get("v.userInfo.id");
        //pageParam.userid=v.userInfo.id;
        //if (v.userInfo.id ==v.recordId.ownerid  ) {
        //   helper.showToast('SUCCESS', 'Success', 'Successfully ');
        
        //   Console.log(v.userInfo.id);
        
        //}
        
        $A.enqueueAction(action);
        
    },
    
    createEventSync: function(component, event, helper){
        var selectedMenu = event.detail.menuItem.get("v.value");
        var feedback=null;
        switch(selectedMenu) {
            case "Open":
                var action = component.get("c.createOppRecEventSync");
                action.setParams({"opportunityId":component.get("v.recordId")});
                // DIGI: 6614 Team Hawaii (Tirth)
                // Opportunity Owner and Account Owner check is removed
                var p = helper.eventCreate(component, action);
                p.then($A.getCallback(function(result){
                    console.log('--- Event result '+JSON.stringify(result))
                    
                    //Your request is now in queue. This may not occur for up to XX minutes.
                    helper.showToast('', 'Success', $A.get("$Label.c.sharepoint_sync_success_message"));
                    //$A.get('e.force:refreshView').fire();
                    
                })).catch($A.getCallback(function(error){
                    // Something went wrong
                    //alert('An error occurred : ' + error.message);
                    helper.showToast('ERROR', 'error', $A.get("$Label.c.sharepoint_sync_Exception_message"));
                }));
                break;
                
                case "RequestSharepointAccess":
                    var action = component.get("c.createOppRequestAccess");
                action.setParams({"opportunityId":component.get("v.recordId")});
                if(component.get("v.userInfo").Id==component.get("v.OppRec").OwnerId || component.get("v.userInfo").Id==component.get("v.OppRec").Account.OwnerId || component.get("v.userInfo").Id!==component.get("v.OppRec").OwnerId || component.get("v.userInfo").Id!==component.get("v.OppRec").Account.OwnerId){
                    var p = helper.eventCreate(component, action);
                    p.then($A.getCallback(function(result){
                        console.log('Into RequestSharePointAccess');
                        console.log('--- Event result '+JSON.stringify(result))
                       
                        //Your request is now in queue. This may not occur for up to XX minutes.
                        helper.showToast('', 'Success', $A.get("$Label.c.sharepoint_sync_success_message"));
                        //$A.get('e.force:refreshView').fire();
                        
                    })).catch($A.getCallback(function(error){
                        // Something went wrong
                        //alert('An error occurred : ' + error.message);
                        helper.showToast('ERROR', 'error', $A.get("$Label.c.sharepoint_sync_Exception_message"));
                    }));                    
                }
                else{
                    helper.showToast('', 'error', 'System Error: Your request has failed. Please try again later and log '+ feedback +' if the problem persists.');                    
                	//$A.get('e.force:refreshView').fire();
                }
                break;
                    
        }
        
    },
    getrefresh :function(component, event, helper){
        $A.get('e.force:refreshView').fire();
    }
    
})