({
    navigateTo: function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },
    searchHelper : function(component,event,getInputkeyWord,getInputkeyWord1,isAllCon) {
		var secondaryConList = component.get("v.contactListSec");
      // call the apex class method 
     var action = component.get("c.fetchAccount");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'acct': getInputkeyWord1,
			'secondaryConList': secondaryConList,
            'isAllCon' : isAllCon
            
           });
      // set a callBack    
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();       
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", 'Search Result...');
                }
                
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecordscon", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    
    searchHelperAdd : function(component,event,getInputkeyWord,getInputkeyWord1,isAllCon) {
      // call the apex class method 
     var action = component.get("c.fetchAdd");
      // set param to method  
        action.setParams({
            'SearchKeyWordAdd': getInputkeyWord,
            'acct': getInputkeyWord1,
            'isAllCon': isAllCon
           });
      // set a callBack    
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();       
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message1", 'No Result Found...');
                } else {
                    component.set("v.Message1", 'Search Result...');
                }
                
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecordsAddnew", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    
        searchAccount : function(component,event,getInputkeyWord1) {
	  	var action = component.get("c.fetchAccountDefault");
        // set param to method 
        action.setParams({
          	'id' : getInputkeyWord1
          });
      // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", 'Search Result...');
                }
                
                // set searchResult list with return value from server.
                
                var name= JSON.parse(storeResponse);
                component.set("v.AccountDefault", name);
                var AccId=JSON.stringify(component.get("v.AccountDefault").Id).substring(1,JSON.stringify(component.get("v.AccountDefault").Id).length-1);
                component.set("v.AccountId",AccId);
                var accName=JSON.stringify(component.get("v.AccountDefault").Name).substring(1,JSON.stringify(component.get("v.AccountDefault").Name).length-1);
                //var str=JSON.stringify(component.get("v.AccountDefault").Name).substring(1,JSON.stringify(component.get("v.AccountDefault").Name).length-1)+" "+JSON.stringify(component.get("v.AccountDefault").CIDN__c).substring(1,JSON.stringify(component.get("v.AccountDefault").CIDN__c).length-1);
				//var cidn=JSON.stringify(component.get("v.AccountDefault").CIDN__c).substring(1,JSON.stringify(component.get("v.AccountDefault").CIDN__c).length-1);
                component.set("v.AccountName",accName);
                
        }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    
    createObjectData: function(component, event) {

        var RowItemList = component.get("v.contactList");
        RowItemList.push({
            'sobjectType': 'AccountContactRelation',
            'ContactId': ''
        });
        // set the updated list to attribute (contactList) again    
           
        component.set("v.contactList", RowItemList);
        
          //      alert(JSON.stringify(component.get("v.contactList")));
        
    },
    searchHelperBilling : function(component,event,getInputkeyWord,isAllCon) {
	  // call the apex class method
	  var secondaryConList = component.get("v.contactListSec");
	  var action = component.get("c.fetchBillingAccount");
      // set param to method  
        action.setParams({
            'acct': getInputkeyWord,
			'secondaryConList': secondaryConList,
            'isAllCon' : isAllCon
          });
      // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", 'Search Result...');
                }
                
                // set searchResult list with return value from server.
               
                component.set("v.listOfSearchRecordscon", storeResponse);
                
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
      searchHelperAddress : function(component,event,getInputkeyWord,isAllCon) {
	  // call the apex class method 
     
     var action = component.get("c.fetchBillingAddress");
      // set param to method  
        action.setParams({
            'acct': getInputkeyWord,
            'isAllCon': isAllCon
          });
      // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message1", 'No Result Found...');
                } else {
                    component.set("v.Message1", 'Search Result...');
                }
                
                // set searchResult list with return value from server.
               var compdata =[];
               var count =0;
                 // alert(storeResponse);
			   for(var comp in storeResponse){
                  
				  compdata.push(storeResponse[comp]);
                   count++;
                   if(count ==10){
                       break; 
                   }
                      
				}
                
                component.set("v.listOfSearchRecordsAdd", storeResponse);
                 component.set("v.listOfSearchRecordsAddnew", compdata);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
    
})