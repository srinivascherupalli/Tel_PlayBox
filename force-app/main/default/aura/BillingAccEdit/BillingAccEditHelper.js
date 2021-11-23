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
                    component.set("v.Message", 'No Result Found.');
                } else {
                    //component.set("v.Message", 'Search Result...');
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
                    component.set("v.Message1", 'No Result Found.');
                } else {
                    //component.set("v.Message1", 'Search Result...');
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
                //component.set("v.AccountName", name.Account__r.Name);
                component.set("v.AccountId", name.Account__r.Id); //INC000097036870 fix
                component.set("v.AccountDefault", name);
                component.set("v.billingaccoldstatus", name.Status__c);//EDGE-147511
                component.set("v.selectedRecordAddress", name.Billing_Address__r);
                component.set("v.selectedcontact", name.Billing_Account_Owner__r);
                component.set("v.existingContact",name.Billing_Account_Owner__r);
                component.set("v.SelectedConBilling",name.Billing_Account_Owner__r);
                component.set("v.disableStatus",name.Written_Off__c);
                component.set("v.checkRetention",name.Retention__c);
                component.set("v.billcycleDay",name.BillCycleday__c);
                
                console.log("v.SelectedConBilling",JSON.stringify(component.get("v.SelectedConBilling")));
                console.log("name: ",name);
                component.set("v.checkAddressContact", name.Include_related_Customer_Account_Contact__c);
                this.handleDisplayFields(component,event); //EDGE-147506
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
                
                
                this.fetchAccConRel(component,event);
                //Removing this as part of EDGE=147537
                /*if(name.Status__c != 'Errorr' ){
                    this.billingAccountDetails(component);
                }*/
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
        console.log('account__v>>>'+account__v);
        console.log('contact__v>>>'+contact__v);
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
                console.log('accConRel>>>>');
                console.log(accConRel);
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
            component.set("v.loadingSpinner", false);
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
                            messageTemplate: 'Mode is pester, duration is 5sec and Message is overrriden',
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
        var action = component.get("c.fetchBillingAccount");
        // set param to method  
        action.setParams({
            'acct': getInputkeyWord,
            'secondaryConList': secondaryConList,
            'isAllCon':isAllCon
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found.');
                } else {
                    //component.set("v.Message", 'Search Result...');
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
                    component.set("v.Message1", 'No Result Found.');
                } else {
                    //component.set("v.Message1", 'Search Result...');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecordsAdd", storeResponse);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },// EDGE-147511
    getStatusValue : function(component,helper,event) {
        // call the apex class method 
        
        var action = component.get("c.findPicklistOptions");
        // set param to method  
        action.setParams({
            'objAPIName': 'Billing_Account__c',
            'fieldAPIname':'Status__c'
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse>>>');
                console.log(storeResponse);
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                
                // set searchResult list with return value from server.
                component.set("v.options", storeResponse);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    }, // EDGE-147511
    validStatus : function (component, event, helper,isSaved){
        console.log('Inside validStatus>>>' + component.get("v.billingaccoldstatus"));
        var data = component.get('v.AccountDefault');
        if(component.get("v.billingaccoldstatus") == 'Final' && data.Status__c != component.get("v.billingaccoldstatus")){
            console.log('Calling this ');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Billing Account status cannot be changed for finalised accounts',
                key: 'info_alt',
                type: 'error'                
            });
            toastEvent.fire();
            component.set("v.loadingSpinner", false);
            return;
        }
        if(component.get("v.billingaccoldstatus")!='Final' && component.get("v.billingaccoldstatus") != 'Pending Finalisation' && data.Status__c == 'Final'){
            console.log('Inside if>>>');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Billing status needs to be Pending Finalisation before updating to Final',
                key: 'info_alt',
                type: 'error'                
            });
            toastEvent.fire();
            component.set("v.loadingSpinner", false);
            return;
        }
        if(component.get("v.billingaccoldstatus") == 'Pending Finalisation' 
           && (data.Status__c != 'Final' && data.Status__c != 'Pending Finalisation')){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Please choose valid status',
                key: 'info_alt',
                type: 'error'                
            });
            toastEvent.fire();
            component.set("v.loadingSpinner", false);
            return;
        } 
        var billingwriteoff = component.get("v.writeOff");
        if(!component.get("v.writeOffEdit")){
            billingwriteoff=false;
        }
        if(billingwriteoff && data.Status__c != 'Final'){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Written off request can be submitted only for finalized billing accounts',
                key: 'info_alt',
                type: 'error'                
            });
            toastEvent.fire();
            component.set("v.loadingSpinner", false);
            return;
        }
        if(isSaved){
            helper.saveRecord(component,event,helper);
            
        }
    },//EDGE-147511
    validAccount : function (component,event,helper,isSaved){
        console.log('Inside validAccount');
        var data = component.get("v.AccountDefault");
        console.log(JSON.stringify(data));
        console.log(data);
        if(data.Status__c == 'Final'){
            var action = component.get("c.isCheckForFinal");
            action.setParams({
                "billingaccId": data.Id
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resp = response.getReturnValue(); 
                    console.log('resp>>>>>>'+resp);
                    if(resp == false){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Warning Message',
                            message:'To update the Billing account to the final state, cancel or change the Billing Account of the below list of active / Inflight subscriptions under the Billing account',
                            key: 'info_alt',
                            type: 'warning'                
                        });
                        toastEvent.fire();
                        component.set("v.loadingSpinner", false);
                        return;
                    }else{
                        helper.isActiveBasket(component,event,helper,isSaved);
                        //helper.validStatus(component, event, helper,isSaved); 
                    }
                }
            });        
            $A.enqueueAction(action);
        }
        
    },
	//EDGE-200254
    validateBAccount : function (component,event,helper,isSaved){
        console.log('Inside validateBAccount');
        var data = component.get("v.AccountDefault");
        console.log(JSON.stringify(data));
        console.log(data);
        if(data.Status__c == 'Final'){
            component.set('v.macdSubColumns', [
            {label: 'Subscription Name', fieldName: 'Name', type: 'text'},
                {label: 'Subscription Number', fieldName: 'csordtelcoa__Subscription_Number__c', type: 'text'},
                {label: 'Status', fieldName: 'csord__Status__c', type: 'text'}
            ]);
            var action = component.get("c.isCheckForFinalise");
            action.setParams({
                "billingaccId": data.Id
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resp = response.getReturnValue(); 
                    console.log('resp>>>>>>1'+resp);
                    if(resp.length == 0){
                        console.log('validatecheck raj');
						helper.validStatus(component, event, helper, isSaved);
                        
                    }else if(resp.length > 0){
                        
                        console.log(resp+'resp');
                        component.set("v.macdSubsList",resp);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Warning Message',
                            message:'To update the Billing account to the final state, cancel or change the Billing Account of the below list of active / Inflight subscriptions under the Billing account',
                            key: 'info_alt',
                            type: 'warning'                  
                        });
                        toastEvent.fire(); 
                        component.set("v.hideMACDSubs",false);
                        component.set("v.loadingSpinner", false);
                        component.set("v.isOpen",true);
                        return;
                    }
                }
            });        
            $A.enqueueAction(action);
        }        
    },    
    saveRecord: function (component,event,helper){
        console.log('Inside saveRecord');
        var flag = false;
        for(var cmp in component.find("dyna")){
            console.log('Inside loop');
            if(cmp=='get'){
                var json = JSON.parse(JSON.stringify(component.find("dyna").get("v.selectedRecordContactInstance")));
                if(json!= null && json.Contact != null && json.Contact.Email==null){
                    flag=true;
                }
                console.log('cmp>>>'+cmp);
                console.log('Inside 449');
                break;
            }
            else{
                var json = JSON.parse(JSON.stringify(component.find("dyna")[cmp].get("v.selectedRecordContactInstance")));
                if(json != null && json.Contact != null && json.Contact.Email==null){
                    flag=true;
                    console.log('Inside 456');
                    break;
                }
            }
        }
        var contactList =[];
        for(var cmp in component.find("dyna") ){
            console.log('cmp>>>'+cmp);
            if(cmp=='get'){
                
                contactList.push(component.find("dyna").get("v.selectedRecordContactInstance"));
                console.log('Inside 465');
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
        
        
        var billNumber = component.get("v.AccountDefault.Billing_Account_Number__c");
        console.log("selectedRecordContact: ",component.get("v.selectedRecordContact[0].Contact.Id"));
        var selectedRecordCon = component.get("v.selectedRecordContact.Contact.Id");
       if(selectedRecordCon!=null)
        {
            var billingAccOwner = component.get("v.selectedRecordContact.Contact.Id");
            var verifyEmail = component.get("v.selectedRecordContact.Contact.Email");
            console.log("selectedRecordContact1",billingAccOwner); 
        }
        else
        {
            var billingAccOwner = component.get("v.selectedRecordContact[0].Contact.Id");
            var verifyEmail = component.get("v.selectedRecordContact[0].Contact.Email");
            console.log("selectedRecordContact2",billingAccOwner); 
        }
        var temp=component.get("v.selectedRecordContact");
        var billingAddName = component.get("v.selectedRecordAddress.Id");
        // var verifyEmail = component.get("v.selectedRecordContact.Contact.Email");
        var billingstatus = component.get("v.AccountDefault.Status__c");
       if($A.util.isEmpty(billNumber) || $A.util.isUndefined(billNumber)){
            //alert('Billing account number is Required');
            component.set("v.loadingSpinner",false);
            return;
        }
        if(($A.util.isEmpty(billingAddName) || $A.util.isUndefined(billingAddName))&&($A.util.isEmpty(billingAccOwner) || $A.util.isUndefined(billingAccOwner))){
            //alert('billing Account Owner is Required');
            $A.util.addClass(component.find('ba'), 'slds-has-error');
            component.find('ba').set("v.errors", [{message: "Billing Address is required"}]);
            $A.util.addClass(component.find('bao'), 'slds-has-error');
            component.find('bao').set("v.errors", [{message: "Billing Account owner is required"}]);
            component.set("v.loadingSpinner",false);
            return;
        }
        if($A.util.isEmpty(billingAccOwner) || $A.util.isUndefined(billingAccOwner)){
            //alert('billing Account Owner is Required');
            $A.util.addClass(component.find('bao'), 'slds-has-error');
            component.find('bao').set("v.errors", [{message: "Billing Account owner is required"}]);
            component.set("v.loadingSpinner",false);
            return;
        }
        if($A.util.isEmpty(billingAddName) || $A.util.isUndefined(billingAddName)){
            //alert('billing Account Owner is Required');
            $A.util.addClass(component.find('ba'), 'slds-has-error');
            component.find('ba').set("v.errors", [{message: "Billing Address is required"}]);
            component.set("v.loadingSpinner",false);
            return;
        }
        
        var toggleVar = component.get("v.toggle");
        if(toggleVar){
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
                component.set("v.loadingSpinner",false);
                return;
            } 
        }
        
        //editDialog
        var allConAdd = component.get("v.checkAddressContact");
        var checkRetension = component.get("v.checkRetention");
        var billcycleDate = component.get("v.billcycleDay");//DIGI-2055
        var action = component.get("c.saveEditedRecords");
        action.setParams({
            "billNumber": billNumber,
            "billingAccOwner": billingAccOwner,
            "billingAdd": billingAddName,
            "contactList": contactList,
            "allConAdd": allConAdd,
            "billingstatus":billingstatus, //EDGE-147511
            "checkRetension": checkRetension,
            "billcycleDate": billcycleDate  //DIGI-2055
            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("selectedContact: ",JSON.stringify(response));
            console.log("state: ",state);
            
            //alert(JSON.stringify(response.getError()));
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                // alert("Reditrerct"+resp);
                /*     var urlEvent = $A.get("e.force:navigateToURL");
                
                urlEvent.setParams({
                    "url": "/one/one.app?source=aloha#/sObject/"+resp+"/view"
                });
                urlEvent.fire(); */
                component.set("v.loadingSpinner", false);
                
            }else{
                alert('info_alt'+info_alt);
                var resp = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:resp,
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                    
                });
                toastEvent.fire();
                component.set("v.loadingSpinner", false);
            }
        });
        
        $A.enqueueAction(action);
    },
    handleDisplayFields : function (component,event){
        var data = component.get("v.AccountDefault");
        console.log('data',JSON.stringify(data));
        var action = component.get("c.handleDisplay");
        //EDGE-151581,158385 Kalashree Borgaonkar. Parameters updated, since Written Off and Predebt flags are to be removed
        action.setParams({
            "isEdit": true
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
    //EDGE-153317:To check if any active baskets are associated with billing account
    isActiveBasket: function (component,event,helper,isSaved){
        console.log('Inside isActiveBasket');
        var data = component.get("v.AccountDefault");
        console.log(JSON.stringify(data));
        console.log(data);
        if(data.Status__c == 'Final'){
            var action = component.get("c.fetchActiveBaskets");
            action.setParams({
                "billingaccId": data.Id
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resp = response.getReturnValue(); 
                    console.log('resp>>>>>>'+resp);
                    if(resp.length>0){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error Message',
                            message:'Active baskets found. Status cannot be progressed to Final',
                            key: 'info_alt',
                            type: 'error'                
                        });
                        toastEvent.fire();
                        component.set("v.loadingSpinner", false);
                        return;
                    }else{
                        //helper.saveRecord(component,event,helper);
                        helper.validStatus(component, event, helper,isSaved); 
                        
                    }
                }
            });        
            $A.enqueueAction(action);
        }
        
    },
    /****************************************************************************
EDGE        - 170964
Method      - checkNotificationPreference
Description - Check Notification Preference exist for Primary Billing Contact
Author      - Dheeraj Bhatt
******************************************************************************/
    checkNotificationPreference:function (component, event, helper){
        if( component.get("v.newContact.Id") != null && component.get("v.existingContact.Id") != component.get("v.newContact.Id")){
            var action = component.get("c.checkNotificationPreferenceForExistingPrimaryContact");
            action.setParams({
                "contactId":component.get("v.existingContact.Id")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.isNotificationPreferenceExist",response.getReturnValue());
                    component.set("v.isNotificationPreferenceScreen",true);
                    if(component.get("v.isNotificationPreferenceExist")==false && component.get("v.isNotificationPreferenceScreen")==true){
                        component.set("v.isClose",true);
                        component.set("v.isSuccess",true); 
                    }
                }
                else if (state==="ERROR") {
                    var errorMsg = action.getError()[0].message;
                    this.showToast('error','Error!',errorMsg);
                }
            })
            $A.enqueueAction(action);
        }
        else {
            component.set("v.isNotificationPreferenceScreen",true);
            component.set("v.isSuccess",true);
            component.set("v.isClose",true);
        }
    },
    /****************************************************************************
EDGE        - 170964
Method      - changeNotificationPreference
Description - Change Notification Preference to new primary Billing Contact
Author      - Dheeraj Bhatt
******************************************************************************/
    changeNotificationPreference:function (component, event, helper){
        var action = component.get("c.changeNotificationPreferenceToNewPrimaryContact");
        action.setParams({
            "existingContactId":component.get("v.existingContact.Id"),
            "newContactId":component.get("v.newContact.Id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isNotificationPreferenceScreen",true);
                component.set("v.isNotificationPreferenceExist",false);
                component.set("v.isClose",true);
                component.set("v.isSuccess",true); 
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                this.showToast('error','Error!',errorMsg);
            }
        })
        $A.enqueueAction(action);
    },
    /****************************************************************************
EDGE        - 170964
Method      - showToast
Description - to show toast error message on exception scenerio
Author      - Dheeraj Bhatt
******************************************************************************/
    showToast : function(type,title,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },
    checkFiledpermission : function(component,helper,event){
        var action = component.get("c.checkFieldpermission");
        action.setParams({
            'mode': 'Edit'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.checkuserAccess",response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errorMsg = action.getError()[0].message;
                alert(errorMsg);
            }
        })
        $A.enqueueAction(action);
    },
    //added for EDGE EDGE-217496
    checkPorActive : function(component,helper,event){
        			debugger;
        var accountId = component.get("v.recordId");
    	var action = component.get("c.checkActivePOR");
    				 action.setParams({
                         "accountIdss": accountId
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
                        		message:'Only Partner of Record can Edit billing accounts',
                        		messageTemplate: 'Mode is error ,duration is 5sec and Message is overrriden',
                        		key: 'info_alt',
                        		type: 'info',
                           		mode: 'error'
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
    },
    
    isPartner : function(component,helper,event){
        var action = component.get("c.isPartner");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.partner",response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errorMsg = action.getError()[0].message;
                alert(errorMsg);
            }
        })
        $A.enqueueAction(action);
    
    
    },
    getBillCycleDays: function(component, event) {
         
        console.log('Get bill cycle days')
         var action = component.get("c.showBillCycleDays");
         action.setCallback(this, function(response) {
             var state = response.getState();
             if (state === "SUCCESS") {
                 var options = response.getReturnValue();
                 console.log('options',options);
                 
                      component.set("v.billingCycleDays", options);
                //console.log('selectedValue',component.get("v.selectedValue"));
                
                 
             }
         });
         $A.enqueueAction(action);
         },
     
     billdayAccess: function(component,event){
          
        console.log('Get bill cycle days')
         var action = component.get("c.billcycleAcc");
         action.setCallback(this, function(response) {
             var state = response.getState();
             
             if (state === "SUCCESS") {
                 component.set("v.BillcycleAccess",response.getReturnValue());
                 
             }
         });
         $A.enqueueAction(action);
         }
         
    
})