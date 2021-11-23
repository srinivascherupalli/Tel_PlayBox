({
	doInit : function(component, event, helper) {
        console.log('Init');
	       var getInputkeyWord1 = component.get("v.recordId");
           helper.setPartner(component,event);
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
        
         var actionLabels = component.get("c.getLabels");
         actionLabels.setCallback(this, function(response) {
            var state = response.getState();
            //alert(response.getReturnValue());
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.labels", response.getReturnValue());
            }
            else{
                console.log("Failed with state: " + state);
            }
        });
        var actionCreatedBy = component.get("c.getCreatedBy");
        var actionModifiedBy = component.get("c.getModifiedBy");
         actionCreatedBy.setParams({
            'recordId' : getInputkeyWord1
    	});
        
        actionModifiedBy.setParams({
            'recordId' : getInputkeyWord1
    	});
        
         // Add callback behavior for when response is received
    	actionCreatedBy.setCallback(this, function(response) {
        	var state = response.getState();
        	if (component.isValid() && state === "SUCCESS") {
                setTimeout(function(){
              // alert(JSON.stringify(component.get("v.AccountDefault")));
                var rawDate2 = component.get("v.AccountDefault.CreatedDate");
              //  alert(rawDate2);
                var formattedDate2 = $A.localizationService.formatDate(rawDate2, "dd/MM/yyyy HH:mm ");
                component.set("v.CreatedDate", formattedDate2);
               // alert(formattedDate2);
				component.set("v.CreatedBy", response.getReturnValue());
                    
                    
                },1000);
                
        	}
        	else {
            	console.log("Failed with state: " + state);
        	}
    	});
        
        // Add callback behavior for when response is received
    	actionModifiedBy.setCallback(this, function(response) {
        	var state = response.getState();
        	if (component.isValid() && state === "SUCCESS") {
                setTimeout(function(){
                var rawDate1 = component.get("v.AccountDefault.LastModifiedDate");
                var formattedDate1 = $A.localizationService.formatDate(rawDate1, "dd/MM/yyyy HH:mm ");
                component.set("v.ModifiedDate", formattedDate1);
      			component.set("v.ModifiedBy", response.getReturnValue());
                },1000);
               
        	}
        	else {
            	console.log("Failed with state: " + state);
        	}
    	});
        
       
        $A.enqueueAction(actionLabels);
        $A.enqueueAction(actionCreatedBy);
        $A.enqueueAction(actionModifiedBy);
        
        
         console.log('Init completed');
        
},
    
    // function for create new object Row in Contact List 
    addNewRow: function(component, event, helper) {
        var flag = false;
        for(var cmp in component.find("dyna")){
            if(cmp=='get'){
                  var json = JSON.parse(JSON.stringify(component.find("dyna").get("v.selectedRecordContactInstance")));
        	 		if(json ==null || json.ContactId==""){
                 		flag=true;
             		}
                  break;
              }
            else{
            var json = JSON.parse(JSON.stringify(component.find("dyna")[cmp].get("v.selectedRecordContactInstance")));
        	 if(json ==null || json.ContactId==""){
                 flag=true;
                 break;
             }
            }
            }
   	 if(flag==true){
         var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                        title : 'Error Message',
                        message:'Fill the empty row before adding new row!!',
                        messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                        key: 'info_alt',
                        type: 'info',
                           mode: 'dismissible'
                       
                    });
        		toastEvent.fire();
     }else{
        	helper.createObjectData(component, event);
		}
        
    },
    
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) { 
        var index = event.getParam("indexVar");
        // component.set("v.contactList", "[]");
        var AllRowsList = [];
        for(var cmp in component.find("dyna") ){
            	if(cmp != index ){
                AllRowsList.push(component.find("dyna")[cmp].get("v.selectedRecordContactInstance"));    
            	}  	 
		  	}
        //AllRowsList.splice(index, 1);
        component.set("v.contactList", AllRowsList); 
        for(var com in component.find("dyna") ){
            if(typeof JSON.stringify(component.find("dyna")[com].get("v.selectedRecordContactInstance")) !="undefined"){
             var json = JSON.parse(JSON.stringify(component.find("dyna")[com].get("v.selectedRecordContactInstance")));
             if(json!=null && json.ContactId!=""){
                	component.find("dyna")[com].set("v.testShowHide","true");
		  	}
         }
        }

    },
    
    appEventCallParent: function(component, event, helper) {
    	var isAllCon = component.get("v.checkAddressContact");
        var selectedContactList =[];
		  for(var cmp in component.find("dyna") ){
                if(cmp=='get'){
                  selectedContactList.push(component.find("dyna").get("v.selectedRecordContactInstance"));
                  break;
              }
              else{
			  	  selectedContactList.push(component.find("dyna")[cmp].get("v.selectedRecordContactInstance"));
              }
		  	}
		  	
    	var appEventSelectedContactListEvt = $A.get("e.c:AppEventSelectedContactList");
    	appEventSelectedContactListEvt.setParams({"selectedContactlistbyEvent" : selectedContactList,
                                                  "isAllCon": isAllCon});
    	appEventSelectedContactListEvt.fire();

    },
    allAddressAndContact : function(component, event, helper){
      var forclosemore = component.find("lookuptest");
        		 $A.util.addClass(forclosemore, 'slds-is-open');
                 $A.util.removeClass(forclosemore, 'slds-hide');
       var forclose1 = component.find("lookup-348");
        		 $A.util.addClass(forclose1, 'slds-is-open');
                 $A.util.removeClass(forclose1, 'slds-hide');
        var getInputkeyWord = component.get("v.AccountId");
		
		var selectedContactList =[];
		  for(var cmp in component.find("dyna") ){
                if(cmp=='get'){
                  selectedContactList.push(component.find("dyna").get("v.selectedRecordContactInstance"));
                  break;
              }
              else{
			  	  selectedContactList.push(component.find("dyna")[cmp].get("v.selectedRecordContactInstance"));
              }
		  	}
			
		component.set("v.contactListSec", selectedContactList ); 
        var isAllCon = component.get("v.checkAddressContact");
        var primaryContact = component.get("v.primaryContact");
      // alert(isAllCon);
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
       if(getInputkeyWord!= null){
            /*
               var forOpen = component.find("searchRes2");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');*/
               helper.searchHelperBilling(component,event,getInputkeyWord,isAllCon);
           	   
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
        
        //Get Address
        
        var forcloseAdd = component.find("lookuptest1");
        		 $A.util.addClass(forcloseAdd, 'slds-is-open');
                 $A.util.removeClass(forcloseAdd, 'slds-hide');
       var forclose2 = component.find("lookup-3481");
        		 $A.util.addClass(forclose2, 'slds-is-open');
                 $A.util.removeClass(forclose2, 'slds-hide');
        var getInputkeyWord = component.get("v.AccountId");
        
		var isAllCon = component.get("v.checkAddressContact"); 
        var selectedContactGetFromEvent = component.get("v.primaryContact");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
       if(getInputkeyWord!= null){
            /*
               var forOpen = component.find("searchRes3");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');*/
               helper.searchHelperAddress(component,event,getInputkeyWord,isAllCon);
           
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
          var appEvent = $A.get("e.c:AppEvent");
            appEvent.setParams({ "primaryContactbyEvent" : selectedContactGetFromEvent,
                                "isAllCon": isAllCon});
            //appEvent.setParams({ "primaryContactbyEvent" : selectedContactGetFromEvent });
            appEvent.fire();
        
     },
    saveRecord : function(component, event, helper) {
        var contactList =[];
		  for(var cmp in component.find("dyna") ){
              if(cmp=='get'){
                  contactList.push(component.find("dyna").get("v.selectedRecordContactInstance"));
                  break;
              }
              else{
			  contactList.push(component.find("dyna")[cmp].get("v.selectedRecordContactInstance"));
              }
		  	}
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
        var verifyEmail = component.get("v.selectedRecordContact.Contact.Email");
        
      //  var status = component.find('status').get("v.value");
        
        if($A.util.isEmpty(billNumber) || $A.util.isUndefined(billNumber)){
            alert('Billing account number is Required');
            return;
        }
         
         if(($A.util.isEmpty(verifyEmail) || $A.util.isUndefined(verifyEmail))){
            /*$A.util.addClass(component.find('bao'), 'slds-has-error');
            component.find('bao').set("v.errors", [{message: "Billing Account owner must have Email address"}]);
            return;*/
           
           var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                        title : 'Error Message',
                        message:'Email Address is Required for Billing Contact',
                        messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                        key: 'info_alt',
                        type: 'info',
                           mode: 'dismissible'
                       
                    });
        		toastEvent.fire();
            return;
        }
        if(($A.util.isEmpty(billingAddName) || $A.util.isUndefined(billingAddName))&&($A.util.isEmpty(billingAccOwner) || $A.util.isUndefined(billingAccOwner))){
            //alert('billing Account Owner is Required');
            $A.util.addClass(component.find('addressBox'), 'slds-has-error');
            component.find('addressBox').set("v.errors", [{message: "Billing Address is required"}]);
            $A.util.addClass(component.find('contactBox'), 'slds-has-error');
            component.find('contactBox').set("v.errors", [{message: "Billing Account owner is required"}]);
            return;
         }
         if($A.util.isEmpty(billingAccOwner) || $A.util.isUndefined(billingAccOwner)){
            //alert('billing Account Owner is Required');
            $A.util.addClass(component.find('contactBox'), 'slds-has-error');
            component.find('contactBox').set("v.errors", [{message: "Billing Account owner is required"}]);
            return;
         }
        
       if($A.util.isEmpty(billingAddName) || $A.util.isUndefined(billingAddName)){
            //alert('billing Account Owner is Required');
            $A.util.addClass(component.find('addressBox'), 'slds-has-error');
            component.find('addressBox').set("v.errors", [{message: "Billing Address is required"}]);
            return;
         }
        //editDialog
        var allConAdd = component.get("v.checkAddressContact");
        var action = component.get("c.saveEditedRecordsFromView");
        action.setParams({
            "billNumber": billNumber,
            "billingAccOwner": billingAccOwner,
            "billingAdd": billingAddName,
            "contactList": contactList,
            "allConAdd": allConAdd
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
                    "url": "/one/one.app?source=aloha#/sObject/"+resp+"/view"
                });
                urlEvent.fire();
             
            }
        });
       	
        $A.enqueueAction(action);

   },
    DeleteEventHandlerEvent : function(component, event, helper){
        var contt = event.getParam("contactByEventDelete");
        component.set("v.selectedRecordContactInstance" , contt);
        
    },
   keyPressController : function(component, event, helper) {
        var selectedContactList =[];
		  for(var cmp in component.find("dyna") ){
                if(cmp=='get'){
                  selectedContactList.push(component.find("dyna").get("v.selectedRecordContactInstance"));
                  break;
              }
              else{
			  	  selectedContactList.push(component.find("dyna")[cmp].get("v.selectedRecordContactInstance"));
              }
		  	}
			
		component.set("v.contactListSec", selectedContactList ); 
        var getInputkeyWord = component.get("v.selectedRecordContact.Contact.Name");
        var getInputkeyWord1 = component.get("v.AccountId");
         var isAllCon = component.get("v.checkAddressContact");
        if(getInputkeyWord!=null){
            if( getInputkeyWord.length > 0 || getInputkeyWord==''){
                 //var lookUpTarget = component.find("Test");
                  $A.util.addClass(lookUpTarget, 'slds-lookup__menu');
                  var forOpen = component.find("searchRes");
                  $A.util.addClass(forOpen, 'slds-is-open');
                  $A.util.removeClass(forOpen, 'slds-is-close');
                
                helper.searchHelper(component,event,getInputkeyWord,getInputkeyWord1,isAllCon);
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
       var getInputkeyWord = component.get("v.selectedRecordAddress.Name");
       //alert("getInputkeyWord"+getInputkeyWord);
       var getInputkeyWord1 = component.get("v.AccountId");
        var isAllCon = component.get("v.checkAddressContact");
       if(getInputkeyWord!=null){
            if( getInputkeyWord.length > 0 || getInputkeyWord==''){
                 //var lookUpTarget = component.find("Test");
                  $A.util.addClass(lookUpTarget, 'slds-lookup__menu');
                  var forOpen = component.find("searchRes");
                  $A.util.addClass(forOpen, 'slds-is-open');
                  $A.util.removeClass(forOpen, 'slds-is-close');
                helper.searchHelperAdd(component,event,getInputkeyWord,getInputkeyWord1,isAllCon);
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
       
       var lookUpTargetcon = component.find("contactBoxicon");
            $A.util.addClass(lookUpTargetcon, 'slds-show');
            $A.util.removeClass(lookUpTargetcon, 'slds-hide');
       
        var getInputkeyWord = component.get("v.AccountId");
        var selectedContactList =[];
		  for(var cmp in component.find("dyna") ){
                if(cmp=='get'){
                  selectedContactList.push(component.find("dyna").get("v.selectedRecordContactInstance"));
                  break;
              }
              else{
			  	  selectedContactList.push(component.find("dyna")[cmp].get("v.selectedRecordContactInstance"));
              }
		  	}
			
		component.set("v.contactListSec", selectedContactList ); 
        var isAllCon = component.get("v.checkAddressContact");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
       if(getInputkeyWord!= null){
            
               var forOpen = component.find("searchRes2");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
               helper.searchHelperBilling(component,event,getInputkeyWord,isAllCon);
           	   
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
        
       var lookUpTarget = component.find("addressBoxicon");
            $A.util.addClass(lookUpTarget, 'slds-show');
            $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        var getInputkeyWord = component.get("v.AccountId");
        var isAllCon = component.get("v.checkAddressContact");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
       if(getInputkeyWord!= null){
            
               var forOpen = component.find("searchRes3");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
               helper.searchHelperAddress(component,event,getInputkeyWord,isAllCon);
           
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
      
         component.set("v.selectedRecordContact.Contact.Name",null);
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
         component.set("v.selectedRecordContact.Contact.Name", "");
        
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
         component.set("v.selectedRecordAddress.Name", "");
        
         $A.util.addClass(lookUpTarget3, 'slds-show');
         $A.util.removeClass(lookUpTarget3, 'slds-hide');
         component.set("v.listOfSearchRecordsAdd", null );
        component.set("v.selectedRecordAddress", null );
       },
    
    cancelDialog: function(component, event, helper) {
    	window.location.href = window.location.href;
        var hideBox = component.find("contactBox");
        $A.util.addClass(hideBox, 'borderDisable');
        
        var addressIcon = component.find("addressBoxicon");
         $A.util.addClass(addressIcon, 'slds-hide');
         $A.util.removeClass(addressIcon, 'slds-show');
        
        var show = component.find("showThis");
        	$A.util.addClass(show, 'slds-hide');
            $A.util.removeClass(show, 'slds-show');
        
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
        var isAllCon = component.get("v.checkAddressContact");
       if(selectedContactGetFromEvent != null){ 
            var appEvent = $A.get("e.c:AppEvent");
            component.set("v.primaryContact",selectedContactGetFromEvent);
            appEvent.setParams({ "primaryContactbyEvent" : selectedContactGetFromEvent,
                                "isAllCon": isAllCon});
            //appEvent.setParams({ "primaryContactbyEvent" : selectedContactGetFromEvent });
            appEvent.fire();
            /*if(selectedContactGetFromEvent.Contact.Email == null){
                var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                        title : 'Error Message',
                        message:'Email Address is Required for Billing Contact',
                        messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                        key: 'info_alt',
                        type: 'info',
                           mode: 'dismissible'
                       
                    });
        		toastEvent.fire();
            var forclose = component.find("lookup-pill2");
           $A.util.addClass(forclose, 'slds-hide');
           $A.util.removeClass(forclose, 'slds-show');
                
          var forclose = component.find("searchRes2");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
           var lookUpTarget = component.find("lookupField2");
            $A.util.addClass(lookUpTarget, 'slds-show');
            $A.util.removeClass(lookUpTarget, 'slds-hide');  
  
            }else{*/
		component.set("v.selectedRecordContact" , selectedContactGetFromEvent);
        component.set("v.SelectedConBilling" , selectedContactGetFromEvent);
        //component.find("dyna").set("v.selectedContact",selectedContactGetFromEvent);
        var forclose = component.find("lookup-pill2");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
      
        
        var forclose = component.find("searchRes2");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField2");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show'); 
            }
       
	  
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
      
	},
	
	changeEditLayoutAddress : function(component, event, helper) {
        //component.set("v.selectedRecordAddress.Name", "");
        var temp=component.find("addressDefault");
		$A.util.addClass(temp, 'slds-hide');
        $A.util.removeClass(temp, 'slds-show');
		
		var tempAdd=component.find("addressShow");
		$A.util.addClass(tempAdd, 'slds-show');
        $A.util.removeClass(tempAdd, 'slds-hide');
		},
		
	changeEditLayoutContact: function(component, event, helper) {
        var temp1=component.find("contactDefault");
		$A.util.addClass(temp1, 'slds-hide');
        $A.util.removeClass(temp1, 'slds-show');
		
		var tempCon=component.find("contactShow");
		$A.util.addClass(tempCon, 'slds-show');
        $A.util.removeClass(tempCon, 'slds-hide');
		},
	
    changeEditLayout : function(component, event, helper) {
        //component.set("v.selectedRecordAddress.Name", "");
		var temp1=component.find("contactDefault");
		$A.util.addClass(temp1, 'slds-hide');
        $A.util.removeClass(temp1, 'slds-show');
		
		var tempCon=component.find("contactShow");
		$A.util.addClass(tempCon, 'slds-show');
        $A.util.removeClass(tempCon, 'slds-hide');
		
        var temp=component.find("addressDefault");
		$A.util.addClass(temp, 'slds-hide');
        $A.util.removeClass(temp, 'slds-show');
		
		var tempAdd=component.find("addressShow");
		$A.util.addClass(tempAdd, 'slds-show');
        $A.util.removeClass(tempAdd, 'slds-hide');
		
		component.find("addressBox").set("v.disabled",false);
        //component.find("contactBox").set("v.disabled",false);
        var inputAddr = component.find("addressBox")
       		var lookUpTarget = component.find("addressBoxicon");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        
        	$A.util.addClass(inputAddr, 'addBorder');
        	$A.util.removeClass(inputAddr, 'borderDisable');
        
        	var show = component.find("showThis");
        	$A.util.addClass(show, 'slds-show');
            $A.util.removeClass(show, 'slds-hide');
       
    },
    
    changeEditLayoutCon : function(component, event, helper) {
       //component.set("v.selectedRecordContact.Contact.Name","");
       component.find("contactBox").set("v.disabled",false);
        var inputCon = component.find("contactBox")
       		var lookUpTargetcon = component.find("contactBoxicon");
            $A.util.addClass(lookUpTargetcon, 'slds-hide');
            $A.util.removeClass(lookUpTargetcon, 'slds-show');
        	//document.getElementById('{!$Component.addressBox}').onclick();
        	
        	$A.util.addClass(inputCon, 'addBorder');
        	$A.util.removeClass(inputCon, 'borderDisable');
        
      var show = component.find("showThis");
        	$A.util.addClass(show, 'slds-show');
            $A.util.removeClass(show, 'slds-hide');
      var showFlag = component.find("showFlag");
        	$A.util.addClass(showFlag, 'slds-show');
            $A.util.removeClass(showFlag, 'slds-hide');
       
    },
    
    changeEditLayoutCon : function(component, event, helper) {
       //component.set("v.selectedRecordContact.Contact.Name","");
	   var temp1=component.find("contactDefault");
		$A.util.addClass(temp1, 'slds-hide');
        $A.util.removeClass(temp1, 'slds-show');
		
		var tempCon=component.find("contactShow");
		$A.util.addClass(tempCon, 'slds-show');
        $A.util.removeClass(tempCon, 'slds-hide');
		
		var temp=component.find("addressDefault");
		$A.util.addClass(temp, 'slds-hide');
        $A.util.removeClass(temp, 'slds-show');
		
		var tempAdd=component.find("addressShow");
		$A.util.addClass(tempAdd, 'slds-show');
        $A.util.removeClass(tempAdd, 'slds-hide');
		
        component.find("contactBox").set("v.disabled",false);
        component.find("addressBox").set("v.disabled",false);
        var inputCon = component.find("contactBox")
       		var lookUpTargetcon = component.find("contactBoxicon");
            $A.util.addClass(lookUpTargetcon, 'slds-hide');
            $A.util.removeClass(lookUpTargetcon, 'slds-show');
        	//document.getElementById('{!$Component.addressBox}').onclick();
        	
        	$A.util.addClass(inputCon, 'addBorder');
        	$A.util.removeClass(inputCon, 'borderDisable');
        
     
      var showFlag = component.find("showFlag");
        	$A.util.addClass(showFlag, 'slds-show');
            $A.util.removeClass(showFlag, 'slds-hide');
		
		var inputAddr = component.find("addressBox")
       		var lookUpTarget = component.find("addressBoxicon");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        
        	$A.util.addClass(inputAddr, 'addBorder');
        	$A.util.removeClass(inputAddr, 'borderDisable');
        
        	var show = component.find("showThis");
        	$A.util.addClass(show, 'slds-show');
            $A.util.removeClass(show, 'slds-hide');
    },
    
    removeDropDown : function(component, event, helper){
        var hideOwner = component.find("lookup-348");
        $A.util.addClass(hideOwner, 'slds-hide');
        $A.util.removeClass(hideOwner, 'slds-show');
        
        var hideAdd = component.find("lookup-3481");
        $A.util.addClass(hideAdd, 'slds-hide');
        $A.util.removeClass(hideAdd, 'slds-show');
        
    }
   
})