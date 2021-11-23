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
                component.set("v.loadingSpinner",false);  
                //this.handleDisplayFields(component,event); //EDGE-147506
                
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
    },
    
    handleDisplayFields : function (component,event){
        var data = component.get("v.AccountDefault");
        console.log('data',JSON.stringify(data));
        var action = component.get("c.handleDisplay");
        //EDGE-151581,158385 Kalashree Borgaonkar. Parameters updated
        action.setParams({
            "isEdit": false
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue(); 
                component.set("v.handleDisplay",resp);
                console.log("resp handleDisplay: ", component.get("v.handleDisplay"));
            }
        });        
        $A.enqueueAction(action);
        },
    
    //EDGE:131005 Retrieve Bill cycle days on UI
      getBillCycleDays: function(component, event) {;
       console.log('Get bill cycle days')
        var action = component.get("c.showBillCycleDays");
       
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = response.getReturnValue();
                console.log('options',options);
                
                     component.set("v.billingCycleDays", options);
               console.log('selectedValue',component.get("v.selectedValue"));
               
                
            }
        });
        $A.enqueueAction(action);
    },
    /*--added For EDGE-198145 */
    checkFieldpermission : function(component,helper,event){
        var action = component.get("c.checkFieldpermission");
        			action.setParams({
            							'mode': 'Create'
          							 });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    console.log("status "+response.getReturnValue());
                    component.set("v.checkuserAccess",response.getReturnValue());
                }
                else if (state === "ERROR") {
                    var errorMsg = action.getError()[0].message;
                    alert(errorMsg);
                }
            })
            $A.enqueueAction(action);
    },
     /*-- EDGE-198145 ended --*/
 //added for EDGE EDGE-217496
    checkPorActive : function(component,helper,event){
        			debugger;
        var accountId = component.get("v.recordId");
    	var action = component.get("c.checkstatus");
    				 action.setParams({
                         "accountIds": accountId
          							 });
        	 console.log(accountId);
        
			action.setCallback(this, function(response) {
                //alert("From server: " + response.getReturnValue());
                var state = response.getState();
                    console.log("status "+status);
                if (state === "SUCCESS") {  
                    var status =response.getReturnValue();
                    console.log("status "+status);
                    console.log("state" +state);
                   	if(status){
                        	var toastEvent = $A.get("e.force:showToast");
                             	toastEvent.setParams({
    							title : 'Error Message',
                        		message:'Only Partner of Record can create billing accounts',
                        		messageTemplate: 'Mode is error ,duration is 5sec and Message is overrriden',
                        		key: 'info_alt',
                        		type: 'error',
                           		mode: 'dismissible'
                                });
                        	$A.get("e.force:closeQuickAction").fire();
    						toastEvent.fire();
                    	}
                    
               	 
                	else if (state === "ERROR") {
                    		var errorMsg = action.getError()[0].message;
                    	alert(errorMsg);
                }
                }
            
			
    	})
        $A.enqueueAction(action);
    }
    
    })