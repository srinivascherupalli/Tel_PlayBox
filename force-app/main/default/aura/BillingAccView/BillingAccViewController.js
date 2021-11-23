({
	doInit : function(component, event, helper) {
	       var getInputkeyWord1 = component.get("v.recordId");
           helper.searchAccount(component,event,getInputkeyWord1);
           component.find("forceRecord").getNewRecord(
            "Billing_Account__c", null,false,
            $A.getCallback(function() {
                var rec = component.get("v.billingRecord");
                var error = component.get("v.recordError");
                if (error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
            })
            
        );
},
    saveRecord : function(component, event, helper) {
        //alert("Saved");
         var forclose1 = component.find("lookup-348");
        		 $A.util.addClass(forclose1, 'slds-hide');
                 $A.util.removeClass(forclose1, 'slds-is-open');
        var forclosemore = component.find("lookuptest");
        		 $A.util.addClass(forclosemore, 'slds-hide');
                 $A.util.removeClass(forclosemore, 'slds-is-open');
        var forclose2 = component.find("lookup-3481");
        		 $A.util.addClass(forclose2, 'slds-hide');
                 $A.util.removeClass(forclose2, 'slds-is-open');
        var forcloseAdd = component.find("lookuptest1");
        		 $A.util.addClass(forcloseAdd, 'slds-hide');
                 $A.util.removeClass(forcloseAdd, 'slds-is-open');
         
                        
       // var payTerm = component.get("v.value");
        var billNumber = component.get("v.AccountDefault.Billing_Account_Number__c");
       // var billCycle = component.find('billCycle').get("v.value");
       // var customerAccName = component.get("v.AccountName");
		var billingAccOwner = component.get("v.selectedRecordContact.ContactId");
        var billingAddName = component.get("v.selectedRecordAddress.Id");
      //  var status = component.find('status').get("v.value");
        
        //alert(billingAccOwner + " "+ billNumber + " "+ billingAddName);
        if($A.util.isEmpty(billNumber) || $A.util.isUndefined(billNumber)){
            alert('Billing account number is Required');
            return;
         }/*
         if($A.util.isEmpty(customerAccName)){
            alert(component.find('cac'));
            $A.util.addClass(component.find('cac'), 'slds-has-error');
            component.find('cac').set("v.errors", [{message: "Customer Account Number is required"}]);
            return;
         }*/
        if(($A.util.isEmpty(billingAddName) || $A.util.isUndefined(billingAddName))&&($A.util.isEmpty(billingAccOwner) || $A.util.isUndefined(billingAccOwner))){
            //alert('billing Account Owner is Required');
            $A.util.addClass(component.find('ba'), 'slds-has-error');
            component.find('ba').set("v.errors", [{message: "Billing Address is required"}]);
            $A.util.addClass(component.find('bao'), 'slds-has-error');
            component.find('bao').set("v.errors", [{message: "Billing Account owner is required"}]);
            return;
         }
         if($A.util.isEmpty(billingAccOwner) || $A.util.isUndefined(billingAccOwner)){
            //alert('billing Account Owner is Required');
            $A.util.addClass(component.find('bao'), 'slds-has-error');
            component.find('bao').set("v.errors", [{message: "Billing Account owner is required"}]);
            return;
         }
       if($A.util.isEmpty(billingAddName) || $A.util.isUndefined(billingAddName)){
            //alert('billing Account Owner is Required');
            $A.util.addClass(component.find('ba'), 'slds-has-error');
            component.find('ba').set("v.errors", [{message: "Billing Address is required"}]);
            return;
         }
        //editDialog
        
        var action = component.get("c.saveEditedRecords");
        action.setParams({
            "billNumber": billNumber,
            "billingAccOwner": billingAccOwner,
            "billingAdd": billingAddName
          });
        
		action.setCallback(this, function(response) {
            var state = response.getState();
            
            //alert(state);
            //alert(JSON.stringify(response.getError()));
            if (state === "SUCCESS") {
               // alert("Reditrerct");
                var resp = response.getReturnValue();
                var urlEvent = $A.get("e.force:navigateToURL");
                
                urlEvent.setParams({
                    "url": "/lightning/r/"+resp+"/view"
                });
                urlEvent.fire();
             
            }
        });
       	
        $A.enqueueAction(action);

   },
    
    keyPressController : function(component, event, helper) {
        var getInputkeyWord = component.get("v.SearchKeyWord");
        var getInputkeyWord1 = component.get("v.AccountId");
        if(getInputkeyWord!=null){
            if( getInputkeyWord.length > 0 || getInputkeyWord==''){
                 //var lookUpTarget = component.find("Test");
                  $A.util.addClass(lookUpTarget, 'slds-lookup__menu');
                  var forOpen = component.find("searchRes");
                  $A.util.addClass(forOpen, 'slds-is-open');
                  $A.util.removeClass(forOpen, 'slds-is-close');
                
                helper.searchHelper(component,event,getInputkeyWord,getInputkeyWord1);
            }else{
                //to remove lookup dialog 
                  var lookUpTarget = component.find("Test");
                  $A.util.removeClass(lookUpTarget, 'slds-lookup__menu');
                  component.set("v.listOfSearchRecords", null);
                  component.set("v.Message", null);
                
            }
         }
        else{  
            component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
         var getAccountValue = component.get("v.selectedRecord");
        
	},
    
    keyPressController1 : function(component, event, helper) {
       var getInputkeyWord = component.get("v.SearchKeyWordAdd");
       var getInputkeyWord1 = component.get("v.AccountId");
       if(getInputkeyWord!=null){
            if( getInputkeyWord.length > 0 || getInputkeyWord==''){
                 //var lookUpTarget = component.find("Test");
                  $A.util.addClass(lookUpTarget, 'slds-lookup__menu');
                  var forOpen = component.find("searchRes");
                  $A.util.addClass(forOpen, 'slds-is-open');
                  $A.util.removeClass(forOpen, 'slds-is-close');
                helper.searchHelperAdd(component,event,getInputkeyWord,getInputkeyWord1);
            }else{
                //to remove lookup dialog 
                  var lookUpTarget = component.find("Test");
                  $A.util.removeClass(lookUpTarget, 'slds-lookup__menu');
                  component.set("v.listOfSearchRecords", null);
                  component.set("v.Message1", null);
            }
         }
        else{  
            component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
         var getAccountValue = component.get("v.selectedRecord");
        
	},
    
   keyPressControllerBilling : function(component, event, helper) {
       var forclosemore = component.find("lookuptest");
        		 $A.util.addClass(forclosemore, 'slds-is-open');
                 $A.util.removeClass(forclosemore, 'slds-hide');
       var forclose1 = component.find("lookup-348");
        		 $A.util.addClass(forclose1, 'slds-is-open');
                 $A.util.removeClass(forclose1, 'slds-hide');
        var getInputkeyWord = component.get("v.AccountId");
        
       
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
       if(getInputkeyWord!= null){
            
               var forOpen = component.find("searchRes2");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
               helper.searchHelperBilling(component,event,getInputkeyWord);
           	   
         }  
          else{  
                 component.set("v.listOfSearchRecordscon", null ); 
                 var forclose = component.find("searchRes2");
                 $A.util.addClass(forclose, 'slds-is-close');
                 $A.util.removeClass(forclose, 'slds-is-open');
             }
         var getAccountValue = component.get("v.selectedRecord");
       if(getAccountValue == null || getAccountValue == ''){
           var forhide = component.find("icon");
           $A.util.addClass(forhide, 'slds-hide');
           $A.util.removeClass(forhide, 'slds-show');
       }
       
    },
    
    keyPressControllerAddress : function(component, event, helper) {
        var forcloseAdd = component.find("lookuptest1");
        		 $A.util.addClass(forcloseAdd, 'slds-is-open');
                 $A.util.removeClass(forcloseAdd, 'slds-hide');
       var forclose2 = component.find("lookup-3481");
        		 $A.util.addClass(forclose2, 'slds-is-open');
                 $A.util.removeClass(forclose2, 'slds-hide');
        var getInputkeyWord = component.get("v.AccountId");
        
       
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
       if(getInputkeyWord!= null){
            
               var forOpen = component.find("searchRes3");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
               helper.searchHelperAddress(component,event,getInputkeyWord);
           
        }  
          else{  
                 component.set("v.listOfSearchRecordsAdd", null ); 
                 var forclose = component.find("searchRes3");
                 $A.util.addClass(forclose, 'slds-is-close');
                 $A.util.removeClass(forclose, 'slds-is-open');
             }
         var getAccountValue = component.get("v.selectedRecord");
         if(getAccountValue == null || getAccountValue == ''){
           var forhide = component.find("iconAdd");
           $A.util.addClass(forhide, 'slds-hide');
           $A.util.removeClass(forhide, 'slds-show');
       }
        
    },
    
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
      
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord",null);
         var a= component.get('c.clear1');
         $A.enqueueAction(a);
        
    },
    
    clear1 :function(component,event,heplper){
         var pillTarget2 = component.find("lookup-pill2");
         var lookUpTarget2 = component.find("lookupField2");
         $A.util.addClass(pillTarget2, 'slds-hide');
         $A.util.removeClass(pillTarget2, 'slds-show');
        var forhide = component.find("icon");
           $A.util.addClass(forhide, 'slds-show');
           $A.util.removeClass(forhide, 'slds-hide');
         component.set("v.SearchKeyWord", "");
        
       	 $A.util.addClass(lookUpTarget2, 'slds-show');
         $A.util.removeClass(lookUpTarget2, 'slds-hide');
        
         component.set("v.listOfSearchRecordscon", null );
         component.set("v.selectedRecordContact", null );
		 var b= component.get('c.clear2');
         $A.enqueueAction(b);
         
          },
    
    
    clear2 :function(component,event,heplper){
         var pillTarget3 = component.find("lookup-pill3");
         var lookUpTarget3 = component.find("lookupField3");
         $A.util.addClass(pillTarget3, 'slds-hide');
         $A.util.removeClass(pillTarget3, 'slds-show');
        var forhide = component.find("iconAdd");
           $A.util.addClass(forhide, 'slds-show');
           $A.util.removeClass(forhide, 'slds-hide');
         component.set("v.SearchKeyWordAdd", "");
        
         $A.util.addClass(lookUpTarget3, 'slds-show');
         $A.util.removeClass(lookUpTarget3, 'slds-hide');
         component.set("v.listOfSearchRecordsAdd", null );
        component.set("v.selectedRecordAddress", null );
       },
    
    cancelDialog: function(component, event, helper) {
    	var getId = component.get("v.URLId");
        var homeEvt = $A.get("e.force:navigateToURL");
        homeEvt.setParams({
            "url": "/"+getId+""
        });
        
	homeEvt.fire();
        
},
    goBack :function(component,event,heplper){
          component.set("v.URLId",component.get("v.AccountId"));
      	 var getId = component.get("v.URLId");
         var homeEvt = $A.get("e.force:navigateToURL");
        homeEvt.setParams({
            "url": "/"+getId+""
        });
        
	homeEvt.fire();

       },
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
     
    // get the selected Account record from the COMPONENT event 
    
       var selectedAccountGetFromEvent = event.getParam("accountByEvent");
	   component.set("v.selectedRecord" , selectedAccountGetFromEvent);
       
       
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
      
        
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
      
	},
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent1 : function(component, event, helper) {
 
     
    // get the selected Account record from the COMPONETN event 	 
       var selectedContactGetFromEvent = event.getParam("contactByEvent");
	   
	   component.set("v.selectedRecordContact" , selectedContactGetFromEvent); 
       
        var forclose = component.find("lookup-pill2");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
      
        
        var forclose = component.find("searchRes2"
                                      );
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField2");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
      
	},
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent2 : function(component, event, helper) {
     
    // get the selected Account record from the COMPONETN event 	 
       var selectedAddressGetFromEvent = event.getParam("addressByEvent");
	 // alert("Event Called" + selectedAddressGetFromEvent);	 
	   component.set("v.selectedRecordAddress" , selectedAddressGetFromEvent); 
       
        var forclose = component.find("lookup-pill3");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
      
        
        var forclose = component.find("searchRes3"
                                      );
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField3");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
      
	}
   
})