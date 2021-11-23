({
    //EDGE-31363
    toggleClearButton : function(component) {
        //debugger;
        if(!$A.util.isEmpty(component.get("v.customerName")) 
           || !$A.util.isEmpty(component.get("v.abn"))
           || !$A.util.isEmpty(component.get("v.cidn"))
           || !$A.util.isEmpty(component.get("v.acn"))){
            component.find("btnClear").set("v.disabled","false");
        }else { component.find("btnClear").set("v.disabled","true"); }
    },
    
    //EDGE-31363
    clearFilterCriteria : function(component) {
        component.set("v.customerName","");
        component.set("v.abn","");
        component.set("v.cidn","");
        component.set("v.acn","");
        component.find("btnClear").set("v.disabled","true");
        this.hideFilterCriteriaError(component); 
        component.set("v.customers", null);
        component.set("v.noCustomerFound",false);
    },
    
    //EDGE-31363
    isValueNumeric : function(component){
        var abn = component.get("v.abn");
        var acn = component.get("v.acn");
        var cidn = component.get("v.cidn");
        
        if((!$A.util.isEmpty(abn) && isNaN(abn))
           || (!$A.util.isEmpty(acn) && isNaN(acn)) 
           || (!$A.util.isEmpty(cidn) && isNaN(cidn))){
            this.showFilterCriteriaError(component,"Input Field Data Is Invalid.Please Provide Data In Proper Format.");
            return false;
        }else {
            this.hideFilterCriteriaError(component);
            return true;
        }
    },
    
    //EDGE-31363
    validateCustomerName: function(component){
        //debugger;
        var custName = component.find("custName");
        var customerName = component.get("v.customerName");
        var regExPattern =/[a-zA-Z]{3}[*]{1}/;
        
        
        if(!$A.util.isEmpty(customerName) && (customerName.includes("*") 
                                              || customerName.includes("!") 
                                              || customerName.includes("?")
                                              || customerName.includes("@")
                                              || customerName.includes("#")
                                              || customerName.includes(",")
                                              || customerName.includes(".")
                                              || customerName.includes(">")
                                              || customerName.includes("<")
                                              || customerName.includes("/")
                                              || customerName.includes("?")
                                              || customerName.includes("#")
                                              || customerName.includes("$")
                                              || customerName.includes("%")
                                              || customerName.includes("^")
                                              || customerName.includes("&")
                                              || customerName.includes("(")
                                              || customerName.includes(")")
                                              || customerName.includes("_")
                                              || customerName.includes("-")
                                              || customerName.includes("+")
                                              || customerName.includes("|")
                                              || customerName.includes("~")
                                              || customerName.includes("`")
                                              || customerName.includes("{")
                                              || customerName.includes("}")
                                              || customerName.includes("[")
                                              || customerName.includes("]")
                                              || customerName.includes("/")
                                              || customerName.includes("="))) {
            var countOfStr=0;
            var checkSpecialChar=false;
            if(customerName.includes("*")){
                for (var i=0; i<customerName.length; i += 1) {
                    if (customerName[i] === '*') {
                        countOfStr += 1;
                    }
                }
            }
            
            if(customerName.includes("!") 
               || customerName.includes("?")
               || customerName.includes("@")
               || customerName.includes("#")
               || customerName.includes(",")
               || customerName.includes(".")
               || customerName.includes(">")
               || customerName.includes("<")
               || customerName.includes("/")
               || customerName.includes("?")
               || customerName.includes("#")
               || customerName.includes("$")
               || customerName.includes("%")
               || customerName.includes("^")
               || customerName.includes("&")
               || customerName.includes("(")
               || customerName.includes(")")
               || customerName.includes("_")
               || customerName.includes("-")
               || customerName.includes("+")
               || customerName.includes("|")
               || customerName.includes("~")
               || customerName.includes("`")
               || customerName.includes("{")
               || customerName.includes("}")
               || customerName.includes("[")
               || customerName.includes("]")
               || customerName.includes("/")
               || customerName.includes("=")) {
                checkSpecialChar = true;
            }
            
            if(customerName.match(regExPattern) && countOfStr==1 && !checkSpecialChar){
                this.hideFilterCriteriaError(component);
            }
            else{ 
                this.showFilterCriteriaError(component,"Special characters are invalid search parameters. Update search parameters and try again, minimum of 3 preceding characters before * are required for wild card search. Please try again");                
            }
        }
        else{
            this.hideFilterCriteriaError(component);            
        }
    },
    
    //EDGE-31363
    searchCustomers: function(component, page, recordToDisply) {
        //debugger;
        if(this.isValueNumeric(component) && this.isSearchCrireriaProvided(component) && this.validateSearchFilterCombination(component)){
            // create a server side action. 
            var action = component.get("c.searchCustomer");
            var inputAbn = ($A.util.isUndefinedOrNull(component.get("v.abn")))?"":component.get("v.abn");
            var inputCustName = ($A.util.isUndefinedOrNull(component.get("v.customerName")))?"":component.get("v.customerName");
            var inputAcn = ($A.util.isUndefinedOrNull(component.get("v.acn")))?"":component.get("v.acn");
            var inputCidn = ($A.util.isUndefinedOrNull(component.get("v.cidn")))?"":component.get("v.cidn");        
            var criteria = '{"customerName" : "'+inputCustName +'","abn" : "'+ inputAbn+'","acn" : "'+ inputAcn+'","cidn" : "'+inputCidn+'"}';
            
            // set the parameters to method 
            action.setParams({
                "pageNumber": page,
                "recordToDisply": recordToDisply,
                "searchCriteria" : criteria
            });
            
            // set a call back   
            action.setCallback(this, function(response) {
                var state = response.getState();  
                component.set("v.isTCMconnected", true);
                if (state === "SUCCESS") 
                {
                    // store the response return value (wrapper class insatance)  
                    var result = response.getReturnValue();
                    console.log('result ---->' + JSON.stringify(result));
                    // set the component attributes value with wrapper class properties.   
                    if(result != null){
                    	if(!$A.util.isUndefinedOrNull(result.ErrorMessage)){
                    		var errorString =result.ErrorMessage;
                            console.log('Error condition true');
                            component.set("v.isTCMconnected", false);
                             var test =  component.get("v.isTCMconnected");
                            console.log('test::in error',test);
                            this.showToast(component,'Warning!',result.ErrorMessage,'Warning');
                            
                            
                    	}
                        /*else if($A.util.isUndefinedOrNull(result.lstCustomer) && !$A.util.isUndefinedOrNull(result.ErrorMessage)){
                            console.log('in if');
                            this.showToast(component,'Warning',$A.get("$Label.c.CUSTOMER_SEARCH_ERROR_TCMDOWN"),'error');
                            this.showFilterCriteriaError(component,result.ErrorMessage);
                        }*/else{
                            //debugger;
                            this.hideFilterCriteriaError(component);
                            component.set("v.customers", result.lstCustomer);
                            component.set("v.page", result.page);
                            component.set("v.total", result.total);
                            component.set("v.pages", Math.ceil(result.total / recordToDisply));    
                            component.set("v.isTCMSearchResults",result.isTCMSearchResults);
                            component.set("v.noCustomerFound",(result.lstCustomer.length == 0?true:false));
                            component.set("v.isTCMconnected", true);
                            if(result.isTCMSearchResults){
                                this.showSearchResultMessage(component,"The following Customer(s) are present in legacy systems and not in Phoenix. Please click on the \"Sync\" button to create a case to import the customer into Phoenix.");
                            }
                            else{
                                this.hideSearchResultMessage(component);
                            }
                        }
                    }
                }
                else if(state === "ERROR")
                {
                    this.showSearchResultMessage(component,response.getError()[0].message);
                }  
                component.set('v.resultloaded', !component.get('v.resultloaded'));
            });
            // enqueue the action 
            $A.enqueueAction(action);
        }
        else{
            component.set('v.resultloaded', !component.get('v.resultloaded')); 
        }
    },
    
    //EDGE-31363
    getCutomerDetailsURL : function(component,event){
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'view',
                recordId : event.target.id
            }
        };
        component.set("v.pageReference", pageReference);
        // Set the URL on the link or use the default if there's an error
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            component.set("v.navurl", url ? url : defaultUrl);
        }), $A.getCallback(function(error) {
            component.set("v.navurl", defaultUrl);
        }));
    },
    
    //EDGE-31363
    isSearchCrireriaProvided : function(component){
        var abn = component.get("v.abn");
        var acn = component.get("v.acn");
        var cidn = component.get("v.cidn");
        var custName = component.get("v.customerName");
        
        if($A.util.isEmpty(abn) && $A.util.isEmpty(acn) && $A.util.isEmpty(cidn) && $A.util.isEmpty(custName)){
            this.showFilterCriteriaError(component,"No Search Criteria Provided");
            return false;
        } else { return true;}
    },
    
    //EDGE-31363
    validateSearchFilterCombination : function(component){
        //debugger;
        var abn = component.get("v.abn");
        var acn = component.get("v.acn");
        var cidn = component.get("v.cidn");
        var custName = component.get("v.customerName");
        var isCriteriaCombinationValid = true;
        
        if(!$A.util.isEmpty(abn) && (!$A.util.isEmpty(acn) || !$A.util.isEmpty(cidn))){
            isCriteriaCombinationValid = false;
        }else if(!$A.util.isEmpty(acn) && !$A.util.isEmpty(cidn)){
            isCriteriaCombinationValid = false;
        }else if(!$A.util.isEmpty(cidn) && !$A.util.isEmpty(custName) ) {
            isCriteriaCombinationValid = false; 
        }
        
        if(!isCriteriaCombinationValid){
            this.showFilterCriteriaError(component,"Invalid search parameters, please provide a valid search combination");
        }else{
            this.hideFilterCriteriaError(component);
        }
        return isCriteriaCombinationValid;
    },
    
    //EDGE-31363
    showFilterCriteriaError : function(component, errorMsg){
        component.set("v.criteriaErrorMessage", errorMsg);
        $A.util.addClass(component.find("searchFilterMessage"), 'slds-show');
        $A.util.removeClass(component.find("searchFilterMessage"), 'slds-hide');
    },
    
    //EDGE-31363
    hideFilterCriteriaError : function(component){
        $A.util.addClass(component.find("searchFilterMessage"), 'slds-hide');
        $A.util.removeClass(component.find("searchFilterMessage"), 'slds-show');
        component.set("v.criteriaErrorMessage", '');
    },
    
    //EDGE-31363
    showSearchResultMessage : function(component, errorMsg){
        component.set("v.searchResultMessage", errorMsg);
        $A.util.addClass(component.find("searchResultsMessage"), 'slds-show');
        $A.util.removeClass(component.find("searchResultsMessage"), 'slds-hide');
    },
    
    //EDGE-31363
    hideSearchResultMessage : function(component){
        $A.util.addClass(component.find("searchResultsMessage"), 'slds-hide');
        $A.util.removeClass(component.find("searchResultsMessage"), 'slds-show');
        component.set("v.searchResultMessage", '');
    },
    
    //EDGE-31363
    handleCustomerSelectCheckboxButton : function(component, event) {
        //debugger;
        var allCheckboxInpputIds = component.find("inptCheckCust");
        var isAnyChecked = false;
        if(allCheckboxInpputIds.length != undefined){
            for (var i = 0; i < allCheckboxInpputIds.length ; i++) {
                if (allCheckboxInpputIds[i].get("v.checked") == true) {
                    isAnyChecked = true;
                }
            }
        } else if(event.getSource().get("v.checked")){
            isAnyChecked = true;
            component.set("v.singleRecordSelected",event.getSource().get("v.value"));
        }
        if(isAnyChecked){
            component.find("btnSync").set("v.disabled",false); 
        }else{
            component.find("btnSync").set("v.disabled",true);
        }
    },
    
    //EDGE-31363
    createCaseInSFDC : function(component, event){
        //debugger;
        var selectedCust = [];
        var allCheckboxInpputIds = component.find("inptCheckCust");
        if(allCheckboxInpputIds.length != undefined){
            for (var i = 0; i < allCheckboxInpputIds.length ; i++) {
                if (allCheckboxInpputIds[i].get("v.checked") == true) {
                    //alert("A Case with these details will be created : " + JSON.stringify(allRadioInpputIds[i].get("v.value")));
                    selectedCust.push(allCheckboxInpputIds[i].get("v.value"));
                    //alert("A Case with these details will be created : " + JSON.stringify(allCheckboxInpputIds[i].get("v.value")));
                }
            }
        } else if(!$A.util.isUndefinedOrNull(component.get("v.singleRecordSelected"))){
            selectedCust.push(component.get("v.singleRecordSelected"));
        }
        component.set("v.selectedCustomer", selectedCust);
        //alert("A Case with these details will be created : " + JSON.stringify(component.get("v.selectedCustomer")));
        
        if(selectedCust.length != undefined){
            var action = component.get('c.createCase');
            action.setParams({
                "strCustomer": JSON.stringify(component.get("v.selectedCustomer"))
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {     
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: response.getReturnValue(),
                        duration:'5000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'pester'
                    });
                    component.set('v.resultloaded', !component.get('v.resultloaded'));
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
     showToast : function(component, title ,msg,msgType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            type : msgType,
            duration : 5000,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    },
    createLead : function(component,event){
        debugger;
        var action = component.get("c.getLeadRecordTypeId");
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();                                     
            if (state === "SUCCESS") 
            {
                
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Lead",
                    "recordTypeId" : response.getReturnValue()
                });
                createRecordEvent.fire();
            }
        });  
        $A.enqueueAction(action);
    }
})