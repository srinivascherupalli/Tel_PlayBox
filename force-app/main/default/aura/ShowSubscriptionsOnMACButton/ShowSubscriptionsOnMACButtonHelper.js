({
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    closeModal: function (component, event) {
        $('.modal-header').find('.btn-wrapper').find('.btn').click();
    },
    
    //to show error box
    showToast: function (type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "key": "action:announcement",
            "message": message
        });
        toastEvent.fire();
    },
    //to fetch Account breadcrumbs
    getAccountDetails: function (component, event, helper) {
        var basketId = component.get('v.basketId');
        var accountId = component.get('v.accountId');
        
        var action = component.get("c.getAccountDetails");
        action.setParams({
            "basketId": basketId,
            "accountId": accountId
        });
        action.setCallback(this, function (response) {
            var acc = response.getReturnValue();
            component.set("v.acc", acc);
            var accObj = JSON.parse(JSON.stringify(acc));
            var objArray = accObj.Id;
            // var accid = objArray;
            component.set('v.accidVal',objArray);
            component.set('v.accountId',objArray); //DIGI-39101
            //EDGE-196441
            this.getURL(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    getURL : function(component, event, helper){
        var accid = '';
        //EDGE-176138 Start
        var url='';
        url=JSON.stringify(window.location.href);
        var accid=component.get('v.accountId');		
        if(accid == '' ||  accid == null || accid == 'undefined'){
            accid = component.get("v.accidVal");
        }
        if(url.includes('partners.enterprise.telstra.com.au')){  //PRM PROD URL
            component.set("v.AccountURL",'/'+accid); 
        }
        else if(url.includes('/partners/')){//PRM Sandbox URL
            component.set("v.AccountURL",'/partners/'+accid)
        }                  
            else{	//CRM URL				
                component.set("v.AccountURL",'/one/one.app?#/sObject/'+accid+'/view');
                component.set("v.AccountHomeURL",'/one/one.app?source=aloha#/sObject/Account/home');
            }
        //End-EDGE-176138
    },
    //EDGE - 77981
    isCancelationNBN: function (component, event, helper) {
        var basketId = component.get('v.basketId');
        var action = component.get("c.isCancelationNBN");
        action.setParams({
            "basketId": basketId,
        });
        action.setCallback(this, function (response) {
            var cancelNBN = response.getReturnValue();
            component.set("v.showOnlyCancelNBN", cancelNBN);
        });
        $A.enqueueAction(action);
    },
    /*
	//EDGE - 67863
	initiateSQCheck: function(component, event, helper,subsIdList){
		var basketId = component.get('v.basketId');
	    var accountId = component.get('v.accountId');    
		var action = component.get("c.initiateSQService"); 
		//console.log('subsIdListHelper',subsIdList); 
	    action.setParams({
	        "basketId": basketId,
	        "accountId": accountId,
	        "subsIdList": subsIdList
	    });
	     $A.enqueueAction(action);
	},*/
    addSelectedHelper: function (component, event, addRecordsIds, changeType, isNonCwpAdded) {
        component.set("v.showSpinner", true);
        var helper = this;
        //call apex class method
        var action = component.get('c.addRecords2');
        var basketId = component.get('v.basketId');
        var accountId = component.get('v.accountId');
        /*if(accountId==''){
        	accountId = component.get('v.acc.Id');
        }*/
        var accountName = component.get('v.acc.Name');
        // pass the all selected record's Id's and Basket Id to apex method
        action.setParams({
            //"lstRecordId": addRecordsIds,
            "subscriptionIdList": addRecordsIds,
            "basketId": basketId,
            "changeType": changeType,
            "accountId": accountId,
            "accountName": accountName
        });
        action.setCallback(this, function (response) {
            //show loading spinner
            helper.showSpinner(component);
            //store state of response
            var state = response.getState();
            component.set("v.showSpinner", false);
            if (state === "SUCCESS") {
                //hide the loading spinner
                helper.hideSpinner(component);
                // Navigate back to the record view
                var returnedBasketId = response.getReturnValue();
                //helper.closeModal(component, event);
                
                //var test = $A.get("$Label.c.MAC_Success"); 
                if (returnedBasketId != null) {
                    helper.hideSelection(component, addRecordsIds, changeType, isNonCwpAdded); //hide selected rows
                    helper.showCustomToast(component, "Subscription was sucessfully added", "Success", "success");
                    let redirect = false;
                    if (basketId != returnedBasketId) {
                        redirect = true; //redirect to product basket?
                    }
                    
                    if (changeType == 'Modify') {
                        helper.openModifyModalWindow(component, redirect, returnedBasketId);
                    } else if (changeType == 'Cancel') {
                        helper.openCancelModalWindow(component, redirect, returnedBasketId);
                    }
                } else {
                    component.set("v.type", 'error');
                    helper.showCustomToast(component, 'Error occured during ' + changeType + ' process.', "Adding Subcription Error", "error");
                }
            } else if (state === "ERROR") {
                
                component.set("v.type", 'error');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showCustomToast(component, errors[0].message, "Adding Subcription Error", "error");
                        //helper.showToast('error',$A.get("$Label.c.MAC_Error")+' '+errors[0].message);
                    }
                } else {
                    component.set("v.message", 'Request Failed!');
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    openCancelModalWindow: function (component, redirect, basketId) {
        component.set("v.basketId", basketId);
        component.set("v.redirectToBasket", redirect);
        component.set("v.showCancellationModal", true);
    },
    openModifyModalWindow: function (component, redirect, basketId) {
        component.set("v.basketId", basketId);
        component.set("v.redirectToBasket", redirect);
        component.set("v.showModifyModal", true);
    },
    closeCancelModalWindow: function (component) {
        component.set("v.showCancellationModal", false);
    },
    closeModifyModalWindow: function (component) {
        component.set("v.showModifyModal", false);
    },
    openAlertforAllCWP: function (component, event) {
        component.set("v.showAlertforAllCWP", true);
        var helper = this;
        
    },
    closeAlertforAllCWP: function (component) {
        component.set("v.showAlertforAllCWP", false);
    },
    
    redirectToProductBasket: function (component, basketId) {
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({
            "recordId": basketId,
            //"slideDevName": "detail",
            "isredirect": "true"
        });
        
        navigateEvent.fire();
    },
    
    /* Part of EDGE-72920 Redirect to Account Page */
    redirectToAccountPage: function (component, accountId) {
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({
            "recordId": accountId,
            "slideDevName": "detail",
            "isredirect": "true"
        });
        
        navigateEvent.fire();
    },
    
    hideSelection: function (component, subscriptionIdList, changeType, isNonCwpAdded) {
        //hide selected
        let tabledata = component.get('v.filteredData')
        
        subscriptionIdList.forEach(function (subsId) {
            for (var i = 0; i < tabledata.length; i++) {
                if (tabledata[i].SubscriptionID === subsId)
                    tabledata.splice(i, 1);
            }
        });
        component.set("v.filteredData", tabledata);
        //update cwpCount
        let cwpCount = 0;
        tabledata.forEach(function (record) {
            if (record.isCWP == true) {
                cwpCount++;
            }
            component.set("v.totalNumberOfCwpRows", cwpCount);
        });
        
        if (changeType == 'Modify') {
            let numberOfCwpRowsUnderModify = component.get("v.numberOfCwpRowsUnderModify");
            numberOfCwpRowsUnderModify = numberOfCwpRowsUnderModify + subscriptionIdList.length;
            
            if (isNonCwpAdded == true) {
                numberOfCwpRowsUnderModify = numberOfCwpRowsUnderModify - component.get('v.nonCwpData').length;
            }
            component.set("v.numberOfCwpRowsUnderModify", numberOfCwpRowsUnderModify);
        }
        
        if (isNonCwpAdded == true) component.set('v.nonCwpData', []);
    },
    
    validateSelection: function (component, event, selectedRecordList) {
        let totalNumberOfRows = component.get("v.totalNumberOfActiveCwpRows");
        let CwpRowsUnderModifyInBasket = component.get("v.CwpRowsUnderModifyInBasket");
        let selectedCWPItems = component.get("v.selectedCWPCount");
        let totalNumberOfActiveCWPRows = component.get("v.totalNumberOfActiveCwpRows");//edge-77981 ac4
        let selectedNBNs=component.get("v.selectedCWPNBN");//edge-77981 ac4
        totalNumberOfRows = totalNumberOfRows - selectedCWPItems + CwpRowsUnderModifyInBasket;
        if (totalNumberOfRows <= 0) {
            component.set("v.flagAllCWPForCancel", true);
            return true;
        } else if (totalNumberOfRows >= 2) {
            return true;
        } else if (totalNumberOfActiveCWPRows-selectedNBNs==1) {//edge-77981 ac4
            return true;
        }
        
        return false;
    },
    
    showCustomToast: function (cmp, message, title, type) {
        $A.createComponent(
            "c:customToast", {
                "type": type,
                "message": message,
                "title": title
            },
            function (customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("container");
                    
                    body.set("v.body", customComp);
                }
                /*else if(status === "INCOMPLETE"){
				    //console.log("no resonse");
				}
				else if(status === "ERROR"){
				    //console.log("error : " + error);
				}  */
            }
        );
    },
    getColumnDefinitions: function () {
        //var columnsWidths = this.getColumnWidths();
        //EGDGE-87725 UX Changes for changing order of showing fields
        var columns = [{
            label: 'Subscription Link',
            fieldName: 'subscriptionNameLink',
            type: 'url',
            sortable: true,
            typeAttributes: {
                label: {
                    fieldName: 'subscriptionName'
                },
                target: '_blank'
            }
        },
                       {
                           label: 'Subscription Number',
                           fieldName: 'subscriptionNumber',
                           type: 'text',
                           sortable: true
                       },
                       {
                           label: 'Site Address',
                           fieldName: 'siteAddressLink',
                           type: 'url',
                           sortable: true,
                           typeAttributes: {
                               label: {
                                   fieldName: 'siteAddress'
                               },
                               target: '_blank'
                           }
                       },
                       
                       {
                           label: 'Created Date',
                           fieldName: 'createdDate',
                           type: 'text',
                           sortable: true
                       },
                       {
                           label: 'Status',
                           fieldName: 'status',
                           type: 'text',
                           sortable: true
                       },
                       /*{
                           label: 'Suspension Reason',
                           fieldName: 'suspensionReason',
                           type: 'text',
                           sortable: true
                       },*/
                       {//edge-77981
                           label: 'Access Type',
                           fieldName: 'accessType',
                           type: 'text',
                           sortable: true
                       },
                       {
                           label: 'Service Id',
                           fieldName: 'ServiceId',
                           type: 'text',
                           sortable: true
                       },
                       {
                           label: 'Total Recurring Charges',
                           fieldName: 'totalRC',
                           type: 'text',
                           sortable: true
                       },
                       {
                           label: 'Billing Account',
                           fieldName: 'billingAccount',
                           type: 'text',
                           sortable: true
                       },
                       {
                           label: 'Created By',
                           fieldName: 'createdBy',
                           type: 'text',
                           sortable: true
                       }
                      ];
                       
                       /*if (columnsWidths.length === columns.length) {
		    return columns.map(function (col, index) {
		        return Object.assign(col, { initialWidth: columnsWidths[index] });
		    });
		}*/
                       return columns;
                       },
                       sortData: function (cmp, fieldName, sortDirection){
                       var data = cmp.get("v.filteredData");
                       var reverse = sortDirection !== 'asc';
                       
                       data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
            );
        cmp.set("v.filteredData", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function (x) {
                return primer(x[field])
            } :
        function (x) {
            return x[field]
        };
        
        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },
    //create component for sim replacement
    addSelectedSimReplacementHelper: function (component, event, addRecordsIds) {
        var actionTypeSelected='Sim Replacement';
        //console.log('filteredData'+filteredData);
        //console.log('selectedRows'+selectedRows);
        //EDGE-132715 Added tNowCaseRef
        //console.log('yaha aaya',component.get("v.Selectreason"));
        $A.createComponent(
            "c:SimReplacement", {
                "SelectedSubsID":addRecordsIds,
                "accountId":component.get("v.accountId"),
                "filteredData2":component.get("v.filteredData"),
                "selectedRows":component.get("v.selectedRows"),
                "selectedRowsCount":component.get("v.selectedRowsCount"),
                "tNowCaseRef":component.get("v.tNowCaseRef"),
                "actionTypeSelected":actionTypeSelected,
                "acc": component.get("v.acc"),
                "SelectReplacereason": component.get("v.Selectreason") //EDGE-166431 
            }, function (newcomponent) {
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);             
                }
            }
        );
    },
    //Changes for EDGE-84486    
    addSelectedChangeInMobileNumberHelper: function (component, event) {
        var accID = component.get("v.accountId");
        var evt = $A.get("e.c:NavigateToNumberChange");
        var changeInMob = 'Change of Mobile Number';
        var tNowRef = component.get("v.tNowCaseRef");//EDGE-132715
        evt.setParams({ "filteredData": component.get("v.filteredData"),
                       "accountId" : accID,
                       "selectedRecordSub" : component.get("v.selectedRows"),
                       "actTypeSelected" : changeInMob,
                       "tNowCaseRef" : tNowRef
                      });
        evt.fire();
    },
    
    addSelectedSuspendResumeHelper : function (component, event, subsId) {        
        var accID = component.get("v.accountId");
        var evt = $A.get("e.c:NavigateToSuspendComp");
        var tNowRef = component.get("v.tNowCaseRef");//EDGE-132715
        evt.setParams({ "filteredData": component.get("v.filteredData"),
                       "accountId" : accID,
                       "selectedRecordSub" : component.get("v.selectedRows"),
                       "actTypeSelected" : component.get("v.actionTypeSelected"),
                       //"reason" :component.get("v.reason"),//DPG-4542(Commented)
                       "tNowCaseRef" : tNowRef
                      });
        evt.fire();
    } ,
    /***********************************************************************************
 Method     -checkNgucPortOutPermission
 Description-EDGE-140734 restrict Lock/Unlock of a subscription for users other than Telstra Wholesale team users
 Author     -Dheeraj Bhatt
 **********************************************************************************/
    /* 
    //As we are reading picklist values from apex so moved this logic to apex class part of EDGE-140756
     checkNgucPortOutPermission : function (component, event, subsId) {    
       var action=component.get("c.getNgucPortOutPermission");
       action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.hasNgucPortOutPermission",response.getReturnValue());
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
            }
        });
        $A.enqueueAction(action);
    },*/
    /***********************************************************************************
 Method     -getMACDActionTypes
 Description-EDGE-140756--Moved the picklist options to Custom Settings
 Author     -RaviTeja K,Alexandria
 **********************************************************************************/
    getMACDActionTypes : function (component, event, subsId) {    
        console.log('isActivePOR'+component.get('v.isActivePOR'));
        var action=component.get("c.getMACDActionTypes");
        //alert(component.get('v.isActivePOR')+';'+component.get('v.accountId'));
        action.setParams({
            "isActivePOR" : component.get('v.isActivePOR'),//EDGE-151597
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                var OptionsMap = [];
                for(var key in result){
                    OptionsMap.push({key: key, value: result[key]});
                    //console.log('key'+key);
                    //console.log('result[key]'+result[key]);
                }
                component.set("v.MACD_ActionTypes", OptionsMap);
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
            }
        });
        $A.enqueueAction(action);
    },
    /***********************************************************************************
 Method     -getReplacmentReson
 Description- EDGE-166431 added reason on sim replacment
 Author     -Ankit Goswami
 **********************************************************************************/
    getReplacmentReson : function (component, event, subsId) {    
        var action=component.get("c.getReplacmentReson");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                var OptionsMap = [];
                for(var key in result){
                    OptionsMap.push({key: key, value: result[key]});
                    //console.log('key'+key);
                    //console.log('result[key]'+result[key]);
                }
                component.set("v.MACD_Reason", OptionsMap);
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
            }
        });
        $A.enqueueAction(action);
    },
    /***********************************************************************************
	 Method     -getCSMDetails
	 Description- EDGE-164004
	 Author     -Ravi Shankar
	**********************************************************************************/
    getCSMDetails : function (component, event, subsId) {    
        var action=component.get("c.getCSMPortalDetails");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();                
                if(result != null && result != '' && result != undefined){
                    var OptionsMap = result.split("|");
                    component.set("v.csmURL", OptionsMap[0]);
                    component.set("v.kaURL", OptionsMap[1]);
                }
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
            }
        });
        $A.enqueueAction(action);
    },	
    /***********************************************************************************
	 Method     -getCSMDetails
	 Description- EDGE-164004
	 Author     -Ravi Shankar
	**********************************************************************************/
    getCSMDetails : function (component, event, subsId) {    
        var action=component.get("c.getCSMPortalDetails");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();                
                if(result != null && result != '' && result != undefined){
                    var OptionsMap = result.split("|");
                    component.set("v.csmURL", OptionsMap[0]);
                    component.set("v.kaURL", OptionsMap[1]);
                }
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
            }
        });
        $A.enqueueAction(action);
    },
    
    /***********************************************************************************
 Method     -getReplacmentReson
 Description- EDGE-166431 Enabla and Disable Next button
 Author     -Ankit Goswami
 **********************************************************************************/
    
    onResonSelectionHelper: function (component, event, helper){
        
        if(component.get("v.actionTypeSelected") == 'Sim Replacement' && (component.get("v.Selectreason")=='' || component.get("v.selectedRowsCount")==0)){
            component.set("v.replacementReson", true);
        }else{
            component.set("v.replacementReson", false);
        }
        
    },
    //<!--EDGE-166431 || End

    pushColumnsInTable: function (component, event, helper,actionType){//dpg-4542 start
        var cols = component.get("v.columns");
        if(actionType=='Suspend'){
            if(cols[cols.length - 1].fieldName !='suspensionReasonSummary'){
                cols.push({
                    label: 'Select Reason',
                    type: "button",
                    typeAttributes: {
                        name: 'suspensionReasonSelection',
                        value: 'suspensionReasonSelection',
                        iconName: 'utility:search',
                        variant: 'base'
                    },
                        initialWidth: 50
                }, {
                    label: 'Suspension Reason', //dpg-4542
                    fieldName: 'suspensionReason',
                    type: 'text',
                    sortable: true
                }, {
                    label: 'Suspension Reason Summary', //dpg-4542
                    fieldName: 'suspensionReasonSummary',
                    type: 'text',
                    sortable: true
                });
                component.set("v.columns", cols);
            }
            else if(cols[cols.length - 2].fieldName == 'resumeReason'){
                var suspensionReasonBlock = [{
                    label: 'Select Reason',
                    type: "button",
                    typeAttributes: {
                        name: 'suspensionReasonSelection',
                        value: 'suspensionReasonSelection',
                        iconName: 'utility:search',
                        variant: 'base'
                    },
                    initialWidth: 50
                }, {
                    label: 'Suspension Reason', //dpg-4542
                    fieldName: 'suspensionReason',
                    type: 'text',
                    sortable: true
                }];
                cols.splice(-3,2,suspensionReasonBlock[0],suspensionReasonBlock[1]);
                component.set("v.columns", cols);
            }

        }
        else if(actionType=='Resume'){
            if(cols[cols.length - 1].fieldName !='suspensionReasonSummary'){
                cols.push({
                    label: 'Select Reason',
                    type: "button",
                    typeAttributes: {
                        name: 'resumeReasonSelection',
                        value: 'resumeReasonSelection',
                        iconName: 'utility:search',
                        variant: 'base'
                    },
                    initialWidth: 50
                }, {
                    label: 'Resume Reason', //dpg-4542
                    fieldName: 'resumeReason',
                    type: 'text',
                    sortable: true
                }, {
                    label: 'Suspension Reason Summary', //dpg-4542
                    fieldName: 'suspensionReasonSummary',
                    type: 'text',
                    sortable: true
                });
                component.set("v.columns", cols);
            }
            else if(cols[cols.length - 2].fieldName == 'suspensionReason'){
                var resumeReasonBlock = [{
                    label: 'Select Reason',
                    type: "button",
                    typeAttributes: {
                        name: 'resumeReasonSelection',
                        value: 'resumeReasonSelection',
                        iconName: 'utility:search',
                        variant: 'base'
                    },
                    initialWidth: 50
                }, {
                    label: 'Resume Reason', //dpg-4542
                    fieldName: 'resumeReason',
                    type: 'text',
                    sortable: true
                }];
                cols.splice(-3,2,resumeReasonBlock[0],resumeReasonBlock[1]);
                component.set("v.columns", cols);
            }
        }
        else{
            if(cols[cols.length - 1].fieldName =='suspensionReasonSummary'){
                cols.splice(-3,3);
                component.set("v.columns", cols);
                
            }
        }
    },
    stampReasonOnSubscription: function (component, event, helper){//dpg-4542
        var applyToAllConfig = component.get("v.applyToAllConfig");
        var selectedRowId = component.get("v.selectedRowId");
        var reasonType = component.get("v.popupHeading");
        var selectedReason = component.get("v.selectedReason");
        var dataTable = component.find("subscriptionTable");
        var selectedRowsArray = dataTable.getSelectedRows();
        var allSubArray = component.get("v.filteredData");
        if(selectedReason){
            if(applyToAllConfig && selectedRowId && Array.isArray(selectedRowsArray) && selectedRowsArray.length>0){
                var selectedSubArray = [];
                selectedRowsArray.forEach(function(sub) {
                    selectedSubArray.push(sub.SubscriptionID);
                });
                allSubArray.forEach(function(sub) {
                    if(selectedSubArray.includes(sub.SubscriptionID)){
                        if(sub.suspensionReasonDescriptionCodeMap[selectedReason]){
                            if(reasonType == "Suspension Reason"){
                                sub["suspensionReasonCode"] = selectedReason;
                                //sub["oldSuspensionReason"] = sub.suspensionReason;//newchange dpg4542
                                sub.suspensionReason = sub.suspensionReasonDescriptionCodeMap[selectedReason];
                            }
                            else if(reasonType == "Resume Reason"){
                                sub["resumeReasonCode"] = selectedReason;
                                sub["resumeReason"] = sub.suspensionReasonDescriptionCodeMap[selectedReason];   
                            }
                        }
                    }
                });
                component.set("v.filteredData",allSubArray);
                
            }
            else if(selectedRowId){
                allSubArray.every(sub => {
                    if(sub.SubscriptionID == selectedRowId && sub.suspensionReasonDescriptionCodeMap[selectedReason]){
                        if(reasonType == "Suspension Reason"){
                            //sub["oldSuspensionReason"] = sub.suspensionReason;//newchange dpg4542
                            sub.suspensionReason = sub.suspensionReasonDescriptionCodeMap[selectedReason];
                            sub["suspensionReasonCode"] = selectedReason;
                        }
                        else if(reasonType == "Resume Reason"){
                            sub["resumeReason"] = sub.suspensionReasonDescriptionCodeMap[selectedReason];
                            sub["resumeReasonCode"] = selectedReason;
                        }
                        return false;
                    }
                    return true;
                });
                component.set("v.filteredData",allSubArray);
            }
            component.set("v.applyToAllConfig", false);
            component.set("v.selectedReason","");
        }
    }//dpg-4542 end
})