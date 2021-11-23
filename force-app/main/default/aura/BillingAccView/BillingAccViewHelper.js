({
    navigateTo: function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },
    searchHelper : function(component,event,getInputkeyWord,getInputkeyWord1) {
      // call the apex class method 
     var action = component.get("c.fetchAccount");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'acct': getInputkeyWord1
            
            
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
    
    searchHelperAdd : function(component,event,getInputkeyWord,getInputkeyWord1) {
      // call the apex class method 
     var action = component.get("c.fetchAdd");
      // set param to method  
        action.setParams({
            'SearchKeyWordAdd': getInputkeyWord,
            'acct': getInputkeyWord1
             
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
                component.set("v.listOfSearchRecordsAdd", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    
        searchAccount : function(component,event,getInputkeyWord1) {
	  	var action = component.get("c.fetchban");
        // set param to method 
        action.setParams({
          	'id' : getInputkeyWord1
          });
      // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
             
                var name= JSON.parse(storeResponse);
               // alert(storeResponse);
                component.set("v.AccountName", name.Account__r.Name);
                component.set("v.AccountId", name.Account__r.Id);
                component.set("v.AccountDefault", name);
                component.set("v.selectedRecordAddress", name.Billing_Address__r);
                
               
   				
                var searchCompleteEvent = component.getEvent("oSelectedAddressEvent");

                searchCompleteEvent.setParams({
                    addressByEvent: component.get("v.selectedRecordAddress")
                }).fire();
    			
               var forhide = component.find("icon");
               $A.util.addClass(forhide, 'slds-hide');
               $A.util.removeClass(forhide, 'slds-show');
                var forhideAdd = component.find("iconAdd");
               $A.util.addClass(forhideAdd, 'slds-hide');
               $A.util.removeClass(forhideAdd, 'slds-show');    
                
								                
                this.fetchAccConRel(component);
                
                var conEvent = component.getEvent("oSelectedContactEvent");
				
                conEvent.setParams({
                    contactByEvent: component.get("v.selectedRecordContact")
                }).fire();
               // this.fetchAccConRel(component);
               
               if(name.Status__c != 'Error' ){
                    this.billingAccountDetails(component);
               }
          }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
 },
    fetchAccConRel: function(component){
       var ban=component.get("v.AccountDefault");

        var account__v= ban.Account__c;
        var contact__v= ban.Billing_Account_Owner__c;
         var action = component.get("c.fetchAccountContactRelObj");
        action.setParams({
            'accountv': account__v,
            'contactv': contact__v
            
          });
        action.setCallback(this, function(response) {
          var state = response.getState();
           
            
         //alert(state);
            if (state === "SUCCESS") {
                var accConRel = JSON.parse(response.getReturnValue());
            
                if(accConRel!=null)
                	{
                        component.set("v.selectedRecordContact", accConRel);
                    }
            }
        }); 
             
        $A.enqueueAction(action);  
    },
    billingAccountDetails: function(component){
      
         var ban=component.get("v.AccountDefault");

        var bann= ban.Billing_Account_Number__c;
         var action = component.get("c.fetchBillingAccountNumberFromBDS");
        action.setParams({
            'ban': bann
          });
        action.setCallback(this, function(response) {
          var state = response.getState();
           
            if (state === "SUCCESS") {
                var orderNumber = JSON.parse(response.getReturnValue());
               // alert(JSON.stringify(orderNumber));
                    if(orderNumber != null){
                if((orderNumber.code != 201 && orderNumber.code != 200) && orderNumber.message != "Success"){
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:orderNumber.errors[0].message,
                        messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                        key: 'info_alt',
                        type: 'error'
                       
                    });
        		toastEvent.fire();
                return;
              // $A.util.removeClass(forhide, 'slds-show');
                }
                     }
                if(orderNumber!=null)
                	{
                        component.set("v.BillingAcc", orderNumber.billingAccount);
                    }
            }
        }); 
             
        $A.enqueueAction(action);  
    },
    
   
    searchHelperBilling : function(component,event,getInputkeyWord) {
	  // call the apex class method
	  var action = component.get("c.fetchBillingAccount");
      // set param to method  
        action.setParams({
            'acct': getInputkeyWord
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
      searchHelperAddress : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     
     var action = component.get("c.fetchBillingAddress");
      // set param to method  
        action.setParams({
            'acct': getInputkeyWord
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
               
                component.set("v.listOfSearchRecordsAdd", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	}
})