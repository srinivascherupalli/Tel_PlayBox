({
	doInit : function(component, event, helper) {
     	 component.set("v.loadingSpinner",true);
        var actionToggle = component.get("c.featureToggle");
        actionToggle.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                //alert(storeResponse);
                component.set("v.toggle", storeResponse);
            }
            
        });
        
        
        component.set("v.contactList",[]);
        helper.checkPorActive(component, event,helper);//added for EDGE EDGE-217496
        helper.createObjectData(component, event);
        var url='';
        
        url=JSON.stringify(window.location.href);
        //alert(url); 
        if (url.includes('partners.enterprise.telstra.com.au'))
                {
            var accountId = url.split("/")[5];
            }
        else
            {
            var accountId = url.split("/")[6];
            }   
        //var accountId = url.split("/")[6];
        if(accountId.includes('"'))
        {
            //alert('inside if'+accountId);
           accountId=accountId.replace('"','');
        }
       //alert(accountId);
       // var res = url.indexOf('Accountid=');
       // var accountId=url.substring(res+10,res+25);
        component.set("v.URLId",accountId);
        //helper.showSpinner(component);
        if(accountId.startsWith("001")){
            var getInputkeyWord1 = component.get("v.URLId");
            helper.checkFieldpermission(component,helper,event);//EDGE-198145
            helper.handleDisplayFields(component,event); //EDGE-147506
            helper.searchAccount(component,event,getInputkeyWord1);
              helper.getBillCycleDays(component,event);//EDGE-131004
        }
        $A.enqueueAction(actionToggle);
         var action = component.get("c.fetchBillingAccountNumber");
        action.setCallback(this, function(response) {
          var orderNumber = response.getReturnValue();
                var parsed = JSON.parse(orderNumber);
            var state = response.getState();
            var disableSave=false;
            var msg='An error occurred. \n';
            msg+='A new Billing Account could not be created at this time. \n Please try again or raise a case if the problem continues \n';
            
               //alert(state);
           //alert('HELLO before if');
            if (state === "SUCCESS") { 
          // alert('HELLO inside if'); 
          
                var results;
                if(parsed != null){
                results = JSON.stringify(parsed.billingAccountNumber);
                 component.set("v.selectedValue",parsed.preferredBillCycleId);//EDGE-131004
                }
	//alert('HELLO 1'+parsed.billingAccountNumber);
                if(results!=null || results!='')
                {
                      
                   // alert('HELLO results '+results);
                    //component.find("BillNumber").set("v.value",results);
                  component.set("v.BillingNumber",results);
                
                   
                }else
                {
                    disableSave=true;
                    component.set("v.DisableSave",disableSave);
                     var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
                        title : 'Error Message',
                       message:msg,
                      messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                      key: 'info_alt',
                     type: 'Error',
                      mode: 'dismissible'
                
  					  });
              toastEvent.fire();
                }
            }else
                {
                     disableSave=true;
                    component.set("v.DisableSave",disableSave);
                     var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
       					title : 'Error Message',
                       message:msg,
                      messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                      key: 'info_alt',
                     type: 'Error',
                      mode: 'dismissible'
  					  });
              toastEvent.fire();
                }
            
        }); 
        
        $A.enqueueAction(action);
        component.find("forceRecord").getNewRecord(
            "Billing_Account__c",
            null,
            false,
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
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecordsAdd", null );
        var forclose = component.find("searchRes3");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onblurcontact : function(component,event,helper){       
        component.set("v.listOfSearchRecordscon", null );
        var forclose = component.find("searchRes2");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    cancelDialog: function(component, event, helper) {
    	var getId = component.get("v.URLId");
        var homeEvt = $A.get("e.force:navigateToURL");
        homeEvt.setParams({
            "url": "/"+getId+""
        });
        
	homeEvt.fire();
        
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
    
    saveRecord : function(component, event, helper) {
        var flag = false;
        for(var cmp in component.find("dyna")){
            if(cmp=='get'){
                var json = JSON.parse(JSON.stringify(component.find("dyna").get("v.selectedRecordContactInstance")));
                if(json!=null  && json.Contact != null && json.Contact.Email==null){
                    flag=true;
                }
                break;
            }
            else{
                var json = JSON.parse(JSON.stringify(component.find("dyna")[cmp].get("v.selectedRecordContactInstance")));
                if(json!=null  && json.Contact != null && json.Contact.Email==null){
                    flag=true;
                    break;
                }
            }
        }
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
        
        var toggleVar = component.get("v.toggle");
        
        if(toggleVar && flag){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Email Address is Required for Other Billing Contact',
                messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                key: 'info_alt',
                type: 'info',
                mode: 'dismissible'
                
            });
            toastEvent.fire();
            return;
        } 
        
        
        
        var contactList =[];
        for(var cmp in component.find("dyna") ){
            if(cmp=='get'){
                var checkEmail=component.find("dyna").get("v.selectedRecordContactInstance.Contact.Email");
                contactList.push(component.find("dyna").get("v.selectedRecordContactInstance"));
                break;
            }
            else{
                var checkEmailMore=component.find("dyna")[cmp].get("v.selectedRecordContactInstance.Contact.Email");
                
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
        
        
       //var payTerm = component.find('payTerm').get("v.value");
        var billNumber = component.find('BillNumber').get("v.value");
        //var billCycle = component.find('billCycle').get("v.value");
        var customerAccName = component.get("v.AccountId");
        var billingAccOwner = component.get("v.selectedRecordContact");
        var billingAddName = component.get("v.selectedRecordAddress");
        var allConAdd = component.get("v.checkAddressContact");
        var verifyEmail = component.get("v.selectedRecordContact.Contact.Email");
        //var contactList = component.get("v.contactList");
        
        if($A.util.isEmpty(billNumber) || $A.util.isUndefined(billNumber)){
            alert('Billing account number is Required');
            return;
        }
        
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
        if(($A.util.isEmpty(verifyEmail) || $A.util.isUndefined(verifyEmail))){
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
        
        
        //editDialog
        component.set("v.loadingSpinner",true);  
        var preDebtFlag = component.get("v.AccountDefault.PreDebt__c");
        console.log('preDebtFlag: ',preDebtFlag);
        var billCycleDay = component.get("v.selectedValue");//EDGE-131005:Sending BillCycleday
         console.log('billCycleDay: ',billCycleDay);
        var action = component.get("c.saveRecs");
        var retentionFlag = component.get("v.checkRetention"); /*--added For EDGE-198145 */
        action.setParams({
            "billNumber": billNumber,
            "paymentterms": '30',
            "billCycleDay": billCycleDay,
            "custAccName": customerAccName,
            "billingAccOwner": billingAccOwner,
            "billingAdd": billingAddName,
            "contactList": contactList,
            "allConAdd" : allConAdd,
            "preDebtFlag" : preDebtFlag,
            "retentionFlag": retentionFlag /*--added For EDGE-198145 */
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set("v.contactList", []);
                var resp = response.getReturnValue();
                var stopRefresh = false;
                //alert(resp);
                setInterval($A.getCallback(function() {
                    if(!stopRefresh){
                        var status = component.get("c.BillingAccountStatus");
                        console.log('status :' ,status);
                status.setParams({
                    "id": resp
                });
                status.setCallback(this, function(response) {
                  var state1 = response.getState();
                    //alert(JSON.stringify(response.getError()));
            	  if (state1 === "SUCCESS") {  
                      var respstatus = response.getReturnValue();
                      if(respstatus == 'Created' || respstatus == 'Error' ){
                          component.set("v.loadingSpinner",false);  
                          stopRefresh = true;
                          var urlW='';
                          //EDGE-150505 : <Tech Story> Fix Security vulnerability class on BillingAccCreateController page
                          urlW=JSON.stringify(window.location.href).replace(/['']/g,"");
                          if(urlW.includes('partners')){                               
 						     location.reload(true);
      						  }else{
                          var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/"+component.get("v.URLId")+""
                });
                urlEvent.fire();
                      }
                  }
                  } });
                $A.enqueueAction(status);
                
                    }
                 
                }),5000);
                
                
                
            }
        });
        
        $A.enqueueAction(action);
        
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
    
    DeleteEventHandlerEvent : function(component, event, helper){
        var contt = event.getParam("contactByEventDelete");
        //alert("Calling from Event "+ contt);
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
        var getInputkeyWord = component.get("v.SearchKeyWord");
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
        var getInputkeyWord = component.get("v.SearchKeyWordAdd");
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
        //alert(isAllCon);
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
        component.set("v.SelectedConBilling", null );
        //var b= component.get('c.clear2');
        //$A.enqueueAction(b);
        
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
        var url='';
        url=JSON.stringify(window.location.href);
        if(url.includes('partners')){
        location.reload(true);
        }else{
        var getId = component.get("v.URLId");
        var homeEvt = $A.get("e.force:navigateToURL");
        homeEvt.setParams({
            "url": "/"+getId+""
        });
        
        homeEvt.fire();
        }
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
        //alert("selectedContactGetFromEvent "+selectedContactGetFromEvent);
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
    
    closeModal:function(component,event,helper){    
		var cmpTarget = component.find('Modalbox');
		var cmpBack = component.find('Modalbackdrop');
		$A.util.removeClass(cmpBack,'slds-backdrop--open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    	},
	openmodal:function(component,event,helper) {
		var cmpTarget = component.find('Modalbox');
		var cmpBack = component.find('Modalbackdrop');
		$A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.addClass(cmpBack, 'slds-backdrop--open'); 
	},
    
   handleOnClick : function(component, event, helper) {
    $A.util.toggleClass(component.find("divHelp"), 'slds-hide');
   },
   handleMouseLeave : function(component, event, helper) {
      $A.util.removeClass(component.find("divHelp"), 'slds-show');
    $A.util.addClass(component.find("divHelp"), 'slds-hide');
   },
   handleMouseEnter : function(component, event, helper) {
    $A.util.removeClass(component.find("divHelp"), 'slds-hide');
     $A.util.addClass(component.find("divHelp"), 'slds-show');
   },
})