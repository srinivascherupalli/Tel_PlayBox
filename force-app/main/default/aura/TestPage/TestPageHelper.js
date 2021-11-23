({
    navigateTo: function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
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
    
    searchHelper : function(component,event,getInputkeyWord,getInputkeyWord1,isAllCon) {
		var secondaryConList = component.get("v.contactListSec");
      // call the apex class method 
     var action = component.get("c.fetchAccount");
        //alert(isAllCon);
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'acct': getInputkeyWord1,
			'secondaryConList': secondaryConList,
            'isAllCon': isAllCon
            
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
                component.set("v.listOfSearchRecordsAdd", storeResponse);
                //alert("storeResponse"+JSON.stringify(storeResponse));
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
             //  alert(storeResponse);
                if(name != undefined || name !=Null){
                component.set("v.AccountName", name.Account__r.Name);
                component.set("v.AccountNumber", name.Account__r.CIDN__c);
                component.set("v.AccountId", name.Account__r.Id);
                component.set("v.AccountDefault", name);
                component.set("v.selectedRecordAddress", name.Billing_Address__r);
                component.set("v.checkAddressContact", name.Include_related_Customer_Account_Contact__c)
                component.set("v.ContactIdee", name.Billing_Account_Owner__r.Id);
                component.set("v.AddressIdee",name.Billing_Address__r.Id);
                
                }
                
                var url='';
                url=JSON.stringify(window.location.href);
                
                if(url.includes('partners.enterprise.telstra.com.au') || url.includes('/partners/s/')){  //Added part of EDGE-167053 for managing navigation for partner users
                    var res = url.indexOf('/s/billing-account');
                    var ContactId=url.substring(1,res);                 
                    var ConURL = ContactId+'/'+component.get("v.ContactIdee");
                    component.set("v.ContactURLId",ConURL);
                    var AddURL = ContactId+'/'+component.get("v.AddressIdee");
                    component.set("v.AddressURLId",AddURL);
                    var AccURL = ContactId+'/'+component.get("v.AccountId");
                    component.set("v.AccountURLId",AccURL); 
                    
                    if(url.includes('partners.enterprise.telstra.com.au')){
                        component.set("v.PRMAppendURL",'/'); 
                        }
                    else if(url.includes('/partners/s/')){
                        component.set("v.PRMAppendURL",'/partners/')
                        }
                    
                    }
                 else
                    { 
                        var res = url.indexOf('Billing_Account__c');
                        var ContactId=url.substring(1,res);
                        var ConURL = ContactId+'Contact/'+component.get("v.ContactIdee")+'/view';
                        component.set("v.ContactURLId",ConURL);                        
                        var AddURL = ContactId+'Address/'+component.get("v.AddressIdee")+'/view';
                        component.set("v.AddressURLId",AddURL);                        
                        var AccURL = ContactId+'Account/'+component.get("v.AccountId")+'/view';
                        component.set("v.AccountURLId",AccURL);
                   }
                
                
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
    fetchAccConRel: function(component,event){

       var ban=component.get("v.AccountDefault");
        
         var bann= ban.Billing_Account_Number__c;
        var accountName = component.get("v.AccountId");
        
        var account__v= ban.Account__c;
        var contact__v= ban.Billing_Account_Owner__c;
         var action = component.get("c.fetchAccountContactRelObj");

        action.setParams({
            'accountv': account__v,
            'contactv': contact__v
            
          });
        
         //Multiple Contatcs
		  var actionForMulpleContacts = component.get("c.fetchOtherContactListForView");
		   actionForMulpleContacts.setParams({
		    'acct': accountName,
            'billNumber': bann
			
          });
        
		   actionForMulpleContacts.setCallback(this, function(response) {
          var state = response.getState();
            if (state === "SUCCESS") {
                var responseFromView = response.getReturnValue();

                if(responseFromView!=null && JSON.stringify(responseFromView)!="[]")
                	{
                        component.set("v.contactList", responseFromView);
                        for(var cmp in component.find("dyna") ){
                            //alert("cmp "+cmp);
                            if(cmp=='get'){
                                //alert("in if cmp "+cmp);
                                var json = JSON.parse(JSON.stringify(component.find("dyna").get("v.selectedRecordContactInstance")));
                                if(json!=null && json.ContactId!=""){
                                        component.find("dyna").set("v.testShowHide","true");
                                 }
                                break;
                            }else{
                                 //alert("in else cmp "+cmp);
                                if(typeof JSON.stringify(component.find("dyna")[cmp].get("v.selectedRecordContactInstance")) !="undefined"){
                                    var json = JSON.parse(JSON.stringify(component.find("dyna")[cmp].get("v.selectedRecordContactInstance")));
                                    if(json!=null && json.ContactId!=""){
                                        component.find("dyna")[cmp].set("v.testShowHide","true");
                                    }
                                }
                            }
                        }

                    }else{
                        this.createObjectData(component, event);
                    }
            }
			
        }); 
		
        
        action.setCallback(this, function(response) {
          var state = response.getState();          
            
         //alert(state);
            if (state === "SUCCESS") {
                var accConRel = JSON.parse(response.getReturnValue());

                if(accConRel!=null)
                	{

                        component.set("v.selectedRecordContact", accConRel);
                        
                        var appEvent = $A.get("e.c:AppEvent");
            			appEvent.setParams({ "primaryContactbyEvent" : component.get("v.selectedRecordContact") });
            			appEvent.fire();
                        
                        var conEvent = component.getEvent("oSelectedContactEvent");
                        
                		conEvent.setParams({
                    	contactByEvent: component.get("v.selectedRecordContact")
                		}).fire();
                        
                        
                    }
            }
            $A.enqueueAction(actionForMulpleContacts);
        }); 
                     
        $A.enqueueAction(action);  
    },
    
    billingAccountDetails: function(component){
         var ban=component.get("v.AccountDefault");

        var bann= ban.Billing_Account_Number__c;
        var accountName = component.get("v.AccountId");

         var action = component.get("c.fetchBillingAccountNumberFromBDS");
        action.setParams({
            'ban': bann
          });
		  		 
        action.setCallback(this, function(response) {
          var state = response.getState();
           
            if (state === "SUCCESS") {
                var orderNumber = JSON.parse(response.getReturnValue());
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
               var disableButton = component.find("savebtn");
               $A.util.addClass(disableButton, 'disabledbtn');
              // $A.util.removeClass(forhide, 'slds-show');
                } }
                if(orderNumber!=null)
                	{
                        component.set("v.BillingAcc", orderNumber.billingAccount);
                    }
            }
            
        }); 
             
        $A.enqueueAction(action);  
    },
    
   
    searchHelperBilling : function(component,event,getInputkeyWord,isAllCon) {
	  // call the apex class method
	  var secondaryConList = component.get("v.contactListSec");
      var billingAccountId = component.get("v.recordId");
      var action = component.get("c.fetchBillingAccountView");
      // set param to method  
        action.setParams({
            'acct': getInputkeyWord,
			'billingAccountId': billingAccountId,
            'isAllCon':isAllCon
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
            'isAllCon':isAllCon
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
    
    changeEditLayout : function(component, event, helper) {
        component.set("v.isEditPage", true);
        helper.removeDivider();
        helper.removeEditIcon();
    },
      setPartner : function(component,event) {
	  	var action = component.get("c.isPartner");
		action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(response.getReturnValue());
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.isPartner", response.getReturnValue());
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
  
        $A.enqueueAction(action);
  }
})