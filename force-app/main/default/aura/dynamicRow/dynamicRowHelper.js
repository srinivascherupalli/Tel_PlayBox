({
    searchHelper: function(component, event, getInputkeyWord, getInputkeyWord1, isAllCon) {
        //alert(conId);
        var conId = component.get("v.selectedContact");
        if(conId == null){
                var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                        title : 'Error Message',
                        message:'Please Select A Primary Billing Account Owner',
                        messageTemplate: 'Mode is pester ,duration is 2sec and Message is overrriden',
                        key: 'info_alt',
                        type: 'info',
                           mode: 'dismissible'
                       
                    });
        		toastEvent.fire();
        }
        else{
        // call the apex class method 
        var secondaryConList = component.get("v.secondaryContactList");
        var action = component.get("c.fetchAccountSecondaryContact");
        // set param to method  
        if (conId != null) {
            action.setParams({
                'searchKeyWord': getInputkeyWord,
                'acct': getInputkeyWord1,
                'conID': conId.Id,
                'secondaryConList': secondaryConList,
                'isAllCon':isAllCon
            });
        } else {
            action.setParams({
                'searchKeyWord': getInputkeyWord,
                'acct': getInputkeyWord1,
                'conID': conId,
                'secondaryConList': secondaryConList,
                'isAllCon':isAllCon
            });
        }

        // set a callBack    

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                    setTimeout(function(){ 
                       			 //component.set("v.Message", null);

                                var forclose = component.find("lookup-348");
                                   $A.util.addClass(forclose, 'slds-hide');
                                   $A.util.removeClass(forclose, 'slds-show');
                                                        
                        		var forhide = component.find("lookuptest1");
                                   $A.util.addClass(forhide, 'slds-hide');
                                   $A.util.removeClass(forhide, 'slds-show');

                        
                    }, 200);
                     
                } else {
                    component.set("v.Message", 'Search Result...');
                }

                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecordscon", storeResponse);
            }

        });
        // enqueue the Action  
        $A.enqueueAction(action);
        }

    },

    searchHelperBilling: function(component, event, getInputkeyWord, isAllCon) {

        var conId = component.get("v.selectedContact");
        if(conId == null){
                var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                        title : 'Error Message',
                        message:'Please Select A Primary Billing Account Owner',
                        messageTemplate: 'Mode is pester ,duration is 2sec and Message is overrriden',
                        key: 'info_alt',
                        type: 'info',
                           mode: 'dismissible'
                       
                    });
        		toastEvent.fire();
        }
        else{
        var secondaryConList = component.get("v.secondaryContactList");
        var action = component.get("c.fetchSecondaryContact");
        // set param to method 
        if (conId != null) {
            action.setParams({
                'acct': getInputkeyWord,
                'conID': conId.Id,
                'secondaryConList': secondaryConList,
                'isAllCon': isAllCon
           });
        } else {
            action.setParams({
                'acct': getInputkeyWord,
                'conID': conId,
                'secondaryConList': secondaryConList,
                'isAllCon': isAllCon
            });
        }
            
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message",'No Result Found...');
                    
                    setTimeout(function(){ 
                       			 //component.set("v.Message", null);

                                var forclose = component.find("lookup-348");
                                   $A.util.addClass(forclose, 'slds-hide');
                                   $A.util.removeClass(forclose, 'slds-show');
                                                        
                        		var forhide = component.find("lookuptest1");
                                   $A.util.addClass(forhide, 'slds-hide');
                                   $A.util.removeClass(forhide, 'slds-show');
                        		
                 
                        
                    }, 200);
                     
                    
                } else {
                    component.set("v.Message", 'Search Result...');
                    
                }

                // set searchResult list with return value from server.

                component.set("v.listOfSearchRecordscon", storeResponse);

            }

        });
        // enqueue the Action  
        $A.enqueueAction(action);
        }

    }
})