({
    doInit : function(component, event, helper) {
        console.log('Inside do Init>>>');
        component.set("v.loadingSpinner", true);
        helper.checkFiledpermission(component,helper,event);//EDGE-200950
        helper.getStatusValue(component,helper,event);
        helper.checkPorActive(component, event,helper);
        helper.isPartner(component, event,helper);
        helper.getBillCycleDays(component,event);
        helper.billdayAccess(component,event);
        
        
        //Toggle
        var action = component.get("c.featureToggle");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                //alert(storeResponse);
                component.set("v.toggle", storeResponse);
                //component.set("v.loadingSpinner", false);
            }
            
        });
        // enqueue the Action  
        //Toggle
        
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
        $A.enqueueAction(action);
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
        var getId = component.get("v.recordId")
        var homeEvt = $A.get("e.force:navigateToURL");
        //alert(getId);
        homeEvt.setParams({
            "url": "/one/one.app?source=aloha#/sObject/"+getId+"/view"
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
        console.log('v.contactList: ',component.get("v.contactList"));
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
        component.set("v.loadingSpinner", true);
        var data = component.get("v.AccountDefault");
        console.log(JSON.stringify(data));
      
        //helper.validStatus(component, event, helper,false);
        if(data.Status__c == 'Final'){
            helper.validateBAccount(component, event, helper,true);//EDGE-200254 changed to validateBAccount
        }else{
            helper.validStatus(component, event, helper,true);            
        }
        //EDGE-170964-Check Notification Preference on click of Next Button
        helper.checkNotificationPreference(component, event, helper);
        
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
        // alert('selectedContactList'+SearchKeyWord);
        component.set("v.contactListSec", selectedContactList ); 
        var getInputkeyWord = component.get("v.SearchKeyWord");
        var getInputkeyWord1 = component.get("v.AccountId");
        var isAllCon = component.get("v.checkAddressContact");
        //$('#lookup-3481').hide(); // Commented to fix the issue Bhargava: EDGE-155322
        
        if(getInputkeyWord!=null){
            if( getInputkeyWord.length > 0 || getInputkeyWord==''){
                $A.util.addClass(lookUpTarget, 'slds-lookup__menu');
                var forOpen = component.find("searchRes2");
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
        //var a= component.get('c.clear1');
        //$A.enqueueAction(a);
        
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
            /* if(selectedContactGetFromEvent.Contact.Email == null){
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
            // const objcon=JSON.parse(selectedContactGetFromEvent);
            //const objcon1=objcon.Contact;
            
            console.log("selectedContactGetFromEvent11: ",JSON.stringify(selectedContactGetFromEvent));
            //console.log("objcon1: ",objcon);
            component.set("v.selectedRecordContact" , selectedContactGetFromEvent);
            //  alert('selectedRecordContact11223'+selectedContactGetFromEvent);
            component.set("v.SelectedConBilling" , selectedContactGetFromEvent);
            component.set("v.newContact",selectedContactGetFromEvent.Contact);
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
    validStatusChange : function (component, event, helper){
        helper.validStatus(component, event, helper,false);
    },
    //EDGE-170964-Dheeraj Bhatt-Change Notification Preference to New Primary Billing Contact on Click of Confirm button.
    onConfirm: function (component, event, helper){
        helper.changeNotificationPreference(component, event, helper);
    },
    //EDGE-170964-Dheeraj Bhatt- Close ModalPopup On click of close buttuon and navigate to Billing account view page.
    closeDialog :function (component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/one/one.app?source=aloha#/sObject/"+component.get("v.recordId")+"/view"
        });
        urlEvent.fire();
    }
})