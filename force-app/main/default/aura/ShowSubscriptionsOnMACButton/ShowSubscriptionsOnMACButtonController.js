({
    doInit: function (component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.showBillingAcc", false);//EDGE-205598
        //check the loggedin user profile
        if(component.get("v.loggedinUserProfilename")=='Assurance Service Agent'){
            component.set("v.assuranceProfileFlag", "true");
        }

        //fetch account+basket details
        helper.getAccountDetails(component, event, helper); 
        helper.isCancelationNBN(component, event, helper);
        //datatablr definition
              
        component.set('v.columns', helper.getColumnDefinitions());
        component.set('v.keyField', "SubscriptionID");
        component.set("v.showSpinner", false);
        //component.get('v.reason').set('v.reason', 'Requested by Customer');
        //component.set("v.reason", "Requested by Customer"); //EDGE-98386 - to set default value for picklist //DPG-4542(Commented)
         //helper.checkNgucPortOutPermission(component, event, helper); //EDGE-140734-Dheeraj Bhatt- restrict Lock/Unlock of a subscription for users other than Telstra Wholesale team users.
         helper.getMACDActionTypes(component, event, helper);  //EDGE-140756--Moved the picklist options to Custom Settings

		 helper.getReplacmentReson(component, event, helper); // EDGE-166431 Read Replacment Reason picklist values from custom settings Replacement Reason.

		if(component.get("v.isActivePOR")=='Active'){//EDGE-164004
			helper.getCSMDetails(component, event, helper);
		}        
    },
    // For count the selected checkboxes. 
    updateSelectedText: function (component, event, helper) {
        var dTable = component.find("subscriptionTable");
        var selectedRowsArray = dTable.getSelectedRows();
        var finalselection = [];var addId = [];	var marketoffer=[];	
        let selectedCWP = 0;
        let selectedCWPNBNs=0;
       
        for (var i = 0; i < selectedRowsArray.length; i++) {
            
            if (selectedRowsArray[i] != null) {
                if (selectedRowsArray[i].productDefinitionName.includes('Connected Workplace')) {
                    selectedCWP++;
                }
                //edge-77981 ac4 and EDGE-91763
                if (selectedRowsArray[i].accessType!=null && selectedRowsArray[i].accessType.includes('NBN Access')) {
                    selectedCWPNBNs++;
                }
                var disableRow = selectedRowsArray[i].disableRow;               
                if (disableRow == true) {
                    finalselection.push(selectedRowsArray[i].subscriptionNumber);
                    //delete selectedRowsArray[i]; 
                    //i--;
                } else {
                    addId.push(selectedRowsArray[i].SubscriptionID);
                    marketoffer.push(selectedRowsArray[i].MarketOffer);//EDGE-96386 -start
                    component.set("v.marketOffer",marketoffer);
                    if(selectedRowsArray[i].productDefinitionName.includes('DMCAT_ProductSpecification_000747'))
                    {
                     component.set("v.Subs",selectedRowsArray[i].subscriptionNumber);
                        
                    }  //EDGE-96386 -end
                     
                   // newMap.forEach((selectedRowsArray[i].subscriptionNumber,selectedRowsArray[i].MarketOffer)=>subMarketMap.set(selectedRowsArray[i].subscriptionNumber,selectedRowsArray[i].MarketOffer));
                    //subMarketMap.set(selectedRowsArray[i].subscriptionNumber,selectedRowsArray[i].MarketOffer);
                   // console.log('map-->'+subMarketMap);
                   
                }
              
                
            }
            
        }
        component.set("v.selectedCWPNBN", selectedCWPNBNs);//edge-77981 ac4
        component.set("v.selectedCWPCount", selectedCWP);
        component.set('v.selectedRowsCount', addId.length);
        component.set('v.selectedRows', addId);
        if (finalselection.length != 0) {
            helper.showCustomToast(component, "Only Active CWP subscription can be selected. Please select valid subscription.", "Selected subscription: " + JSON.stringify(finalselection[0]), "warning");
        }
        finalselection = [];
		helper.onResonSelectionHelper(component, event, helper) ;//EDGE-166431
        component.set('v.SelectedSubsID', addId);
    },
	 //<!--EDGE-166431 || start
    onResonSelection: function (component, event, helper){
		
        helper.onResonSelectionHelper(component, event, helper);
	},
	//<!--EDGE-166431 || End
    //To add selected records (modify)
    addSelected: function (component, event, helper) {
        // create var for store record id's for selected checkboxes  
        let subsIdList = [];
        subsIdList = component.get('v.SelectedSubsID');
        let tabledata = component.get('v.filteredData')
        let nonCwpList = component.get('v.nonCwpData');
        // add non CWP subs to MACD basket 
        subsIdList = subsIdList.concat(nonCwpList);
        /*
    	subsIdList.forEach(function(subsId){
                for(var i = 0; i < tabledata.length; i++){
                    if (tabledata[i].SubscriptionID === subsId) 
                        tabledata.splice(i, 1);
                }   
            });
        component.set("v.filteredData", tabledata);
        */
        var statusofIPNetworkandUCE = false;
        var locationofIPNetworkandUCE = component.get("v.locationofIPNetworkinbasket") && component.get("v.locationofUCEinbasket");
        if (component.get("v.statusofIPNetwork") == 'Active' || locationofIPNetworkandUCE == true) {
            helper.addSelectedHelper(component, event, subsIdList, 'Modify', true);
        } else {
            helper.showCustomToast(component,
                                   $A.get("$Label.c.Warning_IP_Network_In_Progress"), "Modify Subscriptions",
                                   "warning");
        }
        
    },
    /*
    //EDGE - 67863
	initiateSQCheck: function(component, event, helper) {
		let subsIdList = [];
        subsIdList = component.get('v.SelectedSubsID');
		//console.log('subsIdList',subsIdList);
		helper.initiateSQCheck(component, event, helper,subsIdList);
	},*/
    //To add selected records (cancel)
    cancelSelected: function (component, event, helper) {
        // create var for store record id's for selected checkboxes  
        let isNonCwpAdded = false;
        var isNBNCancellation=false;//EDGE-77981
        let subsIdList = [];
        subsIdList = component.get('v.SelectedSubsID');
        let tabledata = component.get('v.filteredData');
        let selectedCWPCount = component.get("v.selectedCWPCount");
        let totalNumberOfCwpRows = component.get('v.totalNumberOfCwpRows');
        let totalNumberOfActiveCWPRows = component.get("v.totalNumberOfActiveCwpRows");//EDGE-77981 ac4 start
        let selectedNBNs=component.get("v.selectedCWPNBN");
        
        if(totalNumberOfActiveCWPRows-selectedNBNs==1){
            isNBNCancellation=true;
        }
        //EDGE-77981 ac4 end
        //Implemented for EDGE-48946 for validation for cancel related scenarios
        var statusofIPNetworkandUCE = false;
        if (component.get("v.statusofIPNetwork") == 'Active') {
            statusofIPNetworkandUCE = true;
        }
        var locationofIPNetworkandUCE = component.get("v.locationofIPNetworkinbasket") 
        && component.get("v.locationofUCEinbasket");
        if (helper.validateSelection(component, event, subsIdList)) {
            let allCWPSelected = component.get("v.flagAllCWPForCancel");
            let noOfMobilityProducts = component.get("v.numberOfMobilityProducts");
            var proceedAfterAlert = component.get("v.proceedAfterAllCWPAlert");
            if (allCWPSelected == true && proceedAfterAlert == false && noOfMobilityProducts > 0) {
                component.set("v.allCWPSelected", true);
                helper.openAlertforAllCWP(component);
            } else {
                if (statusofIPNetworkandUCE == true) {
                    let nonCwpList = component.get('v.nonCwpData');
                    //Uncomment below code if UCE and IP Network are to be added only if
                    //CWP subscription are added in the basket
                    //if(selectedCWPCount > 0){....}
                    if (isNBNCancellation == true) {//EDGE-77981 ac4
                        let allCwpList=component.get("v.allCWPData");
                        subsIdList=allCwpList;
                        allCWPSelected = true; //Defect EDGE-98018
                    }
                    subsIdList = subsIdList.concat(nonCwpList);
                    
                    if (allCWPSelected == true) {
                        let mobilityList = component.get('v.mobilityData');
                        subsIdList = subsIdList.concat(mobilityList);
                    }
                    isNonCwpAdded = true;
                    helper.addSelectedHelper(component, event, subsIdList, 'Cancel', isNonCwpAdded);
                } else if (locationofIPNetworkandUCE == true) {
                    if (isNBNCancellation == true) {//Defect EDGE-98018
                        let allCwpList=component.get("v.allCWPData");
                        subsIdList=allCwpList;
                        allCWPSelected = true;
                    }
                    
                    if (allCWPSelected == true) {
                        let mobilityList = component.get('v.mobilityData');
                        subsIdList = subsIdList.concat(mobilityList);
                    }
                    isNonCwpAdded = true;
                    helper.addSelectedHelper(component, event, subsIdList, 'Cancel', isNonCwpAdded);
                } else {
                    helper.showCustomToast(component,
                                           $A.get("$Label.c.Warning_IP_Network_In_Progress"), "Cancel Subscriptions",
                                           "warning");
                }
            }
        } else {
            helper.showCustomToast(component,
                                   $A.get("$Label.c.Warning_1_Active_CWP"), "Cancel Subscriptions",
                                   "warning");
        }
    },
    onCancel: function (component, event, helper) {
        // Navigate back to the record view
        var accountId = component.get('v.accountId');
        
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({
            "recordId": accountId,
            "slideDevName": "detail",
            "isredirect": "true"
        });
        
        navigateEvent.fire();
        //helper.showCustomToast(component, "Something broke", "Error Title", "error");
    },
    onModify: function (component, event, helper) {
        // Navigate back to the record view
        var accountId = component.get('v.accountId');
        
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({
            "recordId": accountId,
            "slideDevName": "detail",
            "isredirect": "true"
        });
        
        navigateEvent.fire();
        //helper.showCustomToast(component, "Something broke", "Error Title", "error");
    },
    
    showSpinner: function (component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true);
    },
    
    hideSpinner: function (component, event, helper) {
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    updateColumnSorting: function (component, event, helper) {
        component.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout(function () {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
            component.set('v.isLoading', false);
        }, 0);
    },
    filter: function (component, event, helper) {
        var data = component.get("v.data"),
            term = component.get("v.filter"),
            results = data,
            regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            results = data.filter(row => regex.test(row.subscriptionName) || 
                                  regex.test(row.siteAddress) || regex.test(row.subscriptionNumber) 
                                  || regex.test(row.status) || regex.test(row.ServiceId) 
                                  || regex.test(row.totalRC) || regex.test(row.totalOC) 
                                  || regex.test(row.createdBy) || regex.test(row.createdDate) || regex.test(row.billingAccount));
        } catch (e) {
            // invalid regex, use full list
        }
        //EDGE-205598 Added this logic to handle filter for CoBA
        if(component.get("v.actionTypeSelected") == 'Change of Billing Account'){
            var subids = [];
            results.forEach(function (record) {
                subids.push(record.SubscriptionID);
                });
                component.set("v.subids", subids);
                var a = component.get('c.handlePageChange');
                $A.enqueueAction(a);
        }
       // EDGE-205598 -- End

        component.set("v.filteredData", results);

        var data1 = component.get("v.filteredData")
        if (data1.length == 0) {
            component.set('v.NoSearchRecord', true);
        }
        if (data1.length != 0) {
            component.set('v.NoSearchRecord', false);
        }
    },
    
    handleCancelReasonUpdate: function (component, event, helper) {
        var redirect = event.getParam("redirect");
        helper.closeCancelModalWindow(component);
        if (redirect == true) {
            let basketId = component.get("v.basketId");
            helper.redirectToProductBasket(component, basketId);
        }
    },
    handleModifyReasonUpdate: function (component, event, helper) {
        var redirect = event.getParam("redirect");
        helper.closeModifyModalWindow(component);
        if (redirect == true) {
            let basketId = component.get("v.basketId");
            helper.redirectToProductBasket(component, basketId);
        }
    },
    handleAlertCancelAllCWP: function (component, event, helper) {
        var redirect = event.getParam("proceed");
        helper.closeAlertforAllCWP(component);
        if (redirect == false) {
            component.set("v.showAlertforAllCWP", false);
            component.set("v.proceedAfterAllCWPAlert", false);
        } else {
            var a = component.get("c.cancelSelected");
            component.set("v.proceedAfterAllCWPAlert", true);
            $A.enqueueAction(a);
        }
    },
    /* Part of EDGE-72920 Redirect to Basket Page or Account Page depending on where it was navigated.*/
    redirectToBasketOrAccount: function (component, event, helper) {
        var basketId = component.get('v.basketId');
        var accountId = component.get('v.acc.Id');
        if(basketId == '' || basketId == null){
            helper.redirectToAccountPage(component, accountId);
        }
        else{
            helper.redirectToProductBasket(component,basketId);
        }
    },
    //call on click of Finish button when action type is sim replacement
    handleFinishSimReplacement: function (component, event, helper) {
        // Navigate to sim replacement page
        if(component.get("v.selectedRowsCount")=="0"){
            helper.showCustomToast(component, "Please select atleast one subscription", "", "warning");
        }else{
            component.set("v.isSimReplacementSelected","true");
            helper.addSelectedSimReplacementHelper(component,event,component.get("v.SelectedSubsID"));           
        }    
    },
    ////Changes for EDGE-84486 ~ Still under developement
    handleNextChangeOfMobileNumber: function (component, event, helper) {
        // Navigate to sim replacement page
        //var accID = component.get("v.accountId");
        if(component.get("v.selectedRowsCount")=="0"){
            helper.showCustomToast(component, "Please select atleast one subscription", "", "warning");
        }else{
            component.set("v.changeinMobileselected","true");
            helper.addSelectedChangeInMobileNumberHelper(component, event);
        }
    },
    //called on click of finish
    handleChangeType: function (component, event, helper){
        var action = component.get("v.actionTypeSelected");
        if(action == 'Modify'){
            var funct = component.get("c.addSelected");
            $A.enqueueAction(funct);
        }
        else if(action == 'Cancellation'){
            var funct = component.get("c.cancelSelected");
            $A.enqueueAction(funct);
        }
            else if(action == 'Sim Replacement'){
                var funct = component.get("c.handleFinishSimReplacement");
                $A.enqueueAction(funct);
            }//Changes for EDGE-84486
                else if(action == 'Change Of Mobile Number'){                    
                    var funct= component.get("c.handleNextChangeOfMobileNumber");
                    $A.enqueueAction(funct);
                }
                    else if(action == 'Suspend')
                    {
                     //alert('in suspend');   
                     //alert(component.get("v.reason"));
                        var funct = component.get("c.handleSuspend");
                        $A.enqueueAction(funct);  
                        
                    }
                   else if(action == 'Resume')
                    {
                     //alert('in resume');   
                        var funct = component.get("c.handleSuspend");
                        $A.enqueueAction(funct);  
                        
                    }
         /* EDGE-205903 Sonalisa Verma Start */
        else if (action == 'Manage Fixed Numbers') {
            var funct = component.get("c.handleManageFixedNumber");
            $A.enqueueAction(funct);
        }
        /* EDGE-205903 Sonalisa Verma End */
        //EDGE-205598 - To handle change of Billing account
        else if(action == 'Change of Billing Account'){
            var funct = component.get("c.handleChangeOfBillingAccount");
            $A.enqueueAction(funct);   
        }
        //EDGE-205598 - End
    },
    /* EDGE-205903 Sonalisa Verma Start  and DIGI-35918 */
    handleManageFixedNumber: function(component, event, helper) {  
        if(component.get("v.selectedContact") == null){
            helper.showCustomToast(component, "Please select Modification Requestor with Role as Legal Lessee Or Full Authority", "", "warning");
        }
        else {
            var con = component.get("v.selectedContact");
            component.set("v.Contactid",con.ContactId);
            component.find('lwcNumberManagementMACD').openModal();   
        }
    },
    /* EDGE-205903 Sonalisa Verma End */
    // EDGE-205598 -  This method handles Validations for Requestor Field and switching to Billing account Page
    handleChangeOfBillingAccount: function (component, event, helper) {
        if(component.get("v.selectedRowsCount") == "0"){

      helper.showCustomToast(component, "Please select atleast one subscription", "", "warning");
    }

        if(component.get("v.selectedContact") == null){
            helper.showCustomToast(component, "Please select Modification Requestor with Role as Legal Lessee Or Full Authority", "", "warning");
        }
        var con = component.get("v.selectedContact");
        component.set("v.Contactid",con.ContactId);
        var existingSubIds = component.get("v.pageSubids");


    var finalSubids = [];
    if (component.get("v.SelectedSubsID") != null)
      finalSubids = component.get("v.SelectedSubsID");
    if (existingSubIds != null) {


        for (var i = 0; i < existingSubIds.length; i++) {
            var rec = existingSubIds[i];
            finalSubids.push(rec);
        }   

    }


        component.set("v.SelectedSubsID",finalSubids); 
        component.set("v.showBillingAcc", true);

    },
    // EDGE-205598 - This method redirects to MACD page from CoBA page
    handleBackButton : function (component, event, helper) {
        component.set("v.showBillingAcc", false);
        component.set("v.selectedRowsCount", 0);


    component.set("v.SelectedSubsID", null);
    component.set("v.pageSubids", null);

  },
  // EDGE-205598 - This method send data from CoBA page to Apex and to perform Case Creation Logic
  handlesubmitbtn: function (component, event, helper) {
    var accountid = component.get("v.accountId");
    var contactid = component.get("v.Contactid");
    var billingaccid = component.get("v.billAcc");
    var reason = component.get("v.cobaReason");

    var subids = component.get("v.submitSubids"); //EDGE -210200 - Update the new variable to be send to submit action

    var action = component.get("c.submitBillAcc");
    component.set("v.showSpinner", true);
    if (billingaccid == null) {
      helper.showCustomToast(component, "Please select Target Billing Account", "", "warning");
      component.set("v.showSpinner", false);
    } else {
      action.setParams({
        "accountId": accountid,
        "contactId": contactid,
        "targetBillAccId": billingaccid,
        "reason": reason,
        "lstSubscrptnIds": subids
      });
      action.setCallback(this, function (response) {
        component.set("v.showSpinner", false);
        var state = response.getState();
        if (state === "SUCCESS") {
          var res = response.getReturnValue();
          if (res.response == "success") {
            var caseRec = res.caseRec;
            var para = document.createElement('p');
            var text1 = document.createTextNode('Case ');
            para.appendChild(text1);
            var a = document.createElement('a');
            var link = document.createTextNode(caseRec.CaseNumber);
            a.appendChild(link);
            a.title = caseRec.CaseNumber;
            var href1 = "https://" + window.location.hostname + "/" + caseRec.Id;
            a.href = href1;
            para.appendChild(a);
            var text2 = document.createTextNode(' successfully submitted for Change of Billing Account');
            para.appendChild(text2);
            helper.showCustomToast(component, para.innerHTML, "Success!", "success");
            window.setTimeout(
              $A.getCallback(function () {
                var con = component.get("v.selectedContact");
                component.set("v.Contactid", con.ContactId);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": component.get("v.accountId"),
                  "slideDevName": "related"
                });
                navEvt.fire();
              }), 5000
            );

          } else {
            helper.showCustomToast(component, res.response, "Error!", "warning");


        }


        } else {
          helper.showCustomToast(component, "Please try again and in case the issue persist please contact your admin", "Error!", "error");

        }
      });
      $A.enqueueAction(action);
    }


  },
  // EDGE-205598 - This method get the billing account value from billingaccountchangecomp and assign it to variable
  handleBillAcc: function (component, event, helper) {
    var billAcc = event.getParam('billval');
    component.set("v.billAcc", billAcc);
    if (billAcc != null) {
      component.set("v.showSubmit", false);
    } else {
      component.set("v.showSubmit", true);
    }
  },
  // EDGE-205598 - This method captures the existing selected subids while we are moving to next pages
  handlePageChange: function (component, event, helper) {
    var existingSubIds = component.get("v.pageSubids");
    var finalSubids = [];
    if (component.get("v.SelectedSubsID") != null)
      finalSubids = component.get("v.SelectedSubsID");
    if (existingSubIds != null) {
      for (var i = 0; i < existingSubIds.length; i++) {
        var rec = existingSubIds[i];
        if (!finalSubids.includes(rec)) finalSubids.push(rec);
      }
    }

    component.set("v.SelectedSubsID", finalSubids);

  },
  //EDGE-205598 - This methods assingn the auto selected row in Pagination component to the variable
  handleAutoRowSelection: function (component, event, helper) {
    var selectedRows = event.getParam('finalSelectedIds');
    var finalSubids = [];
    if (selectedRows != null) {
      for (var i = 0; i < selectedRows.length; i++) {
        var rec = selectedRows[i];
        finalSubids.push(rec);
      }
    }
    component.set("v.submitSubids", finalSubids);
  },
  // EDGE-205598 - This methods assingn the selected row in Pagination component to the variable
  handlerowselection: function (component, event, helper) {
    console.log("event----");
    var selectedRows = event.getParam('selectedRows');
    var existingSubIds = component.get("v.pageSubids");
    var finalSubids = component.get("v.SelectedSubsID");
    var subids = [];

    for (var i = 0; i < selectedRows.length; i++) {
      var rec = selectedRows[i];
      subids.push(rec.SubscriptionID);
    }
    console.log("FinalSubsID--", JSON.stringify(finalSubids));
    console.log("existingSubIds--", existingSubIds);
    console.log("subids--", subids);
    var count;
    if (finalSubids != null)
      count = subids.length + finalSubids.length;
    else
      count = subids.length;
    component.set("v.selectedRowsCount", count);
    component.set("v.pageSubids", subids);
  },

// EDGE-205598 --- End----
    handleSuspend: function (component, event, helper) {
        // Navigate to sim replacement page
        //var accID = component.get("v.accountId");
       var actType=component.get("v.actionTypeSelected");
        //var res=component.get("v.reason");//DPG-4542(Commented)
        //var mktoffer=component.get("v.marketOffer"); DPG:4542, Commented
        var subs=component.get("v.Subs");
        var isReasonNullSuspend= false;//DPG-4543, Ila
        var isReasonNullResume = false;//DPG-4544, Krunal
        //DPG-4542(Start)
        var dTable = component.find("subscriptionTable");
        var restrictTidSubscription = false;
        var selectedRowsArray = dTable.getSelectedRows();
        var suspesionReasonNotExist = false;//DPG-4543, Ila
        var suspensionReasonNullSub = [];//DPG-4543, Ila
        var resumeReasonNullSub = [];//DPG-4543, Ila
        var arrayOfReasonSameSub = [];//DPG-4543, Ila
       	selectedRowsArray.forEach(sub => {
            if(sub.MarketOffer == 'DMCAT_Offer_000709' && sub.suspensionReason && sub.suspensionReason.toLowerCase()=='requested by customer'){
                restrictTidSubscription =true;
            }
            if(!sub.suspensionReasonCode){//DPG-4543, Ila
                isReasonNullSuspend = true;
                suspensionReasonNullSub.push(sub.subscriptionName);
            }
            if(!sub.resumeReasonCode){//DPG-4544, Krunal
                isReasonNullResume = true;
                resumeReasonNullSub.push(sub.subscriptionName);
            }
            if(sub.suspensionReasonSummary && sub.suspensionReasonSummary.includes(sub.suspensionReason)){//DPG-4543, Ila
                suspesionReasonNotExist = true;
                arrayOfReasonSameSub.push(sub.subscriptionName);
            }
            /*
            else if(!sub.suspensionReasonSummary && sub.oldSuspensionReason ==sub.suspensionReason){//DPG-4543, Ila (new change)
                suspesionReasonNotExist = true;
                arrayOfReasonSameSub.push(sub.subscriptionName);
            }*/
        });
        //DPG-4542(End)
        //alert(actType);
        //alert(subs);
        //alert(mktoffer);
        //DPG-4543 || DPG-4544, Ila || Krunal Start
        if(actType=='Suspend' && suspesionReasonNotExist){
            helper.showCustomToast(component, "Please select a different Suspension Reason for these subscriptions : ("+ arrayOfReasonSameSub+")", "", "warning");
        }
        else if(actType=='Suspend' && isReasonNullSuspend ){
            helper.showCustomToast(component, "Please select a valid/new Suspension Reason for these subscriptions : ("+suspensionReasonNullSub+")", "", "warning");
        
        }
        else if(actType=='Resume' && isReasonNullResume){
            helper.showCustomToast(component, "Please select a valid/new Resume Reason for these subscriptions : ("+resumeReasonNullSub+")", "", "warning");
        }//DPG-4543 || DPG-4544, Ila || Krunal End
        else{
        if(component.get("v.selectedRowsCount")=="0"){
            helper.showCustomToast(component, "Please select atleast one subscription", "", "warning");
        }//else if(actType=='Suspend' && res=='Requested by Customer' && mktoffer.includes('DMCAT_Offer_000709')){ // Restricting customer-initiated suspension for TID //DPG-4542(commented)
        else if(actType=='Suspend' && restrictTidSubscription){ // Restricting customer-initiated suspension for TID //DPG-4542(Added restrictTidSubscription)
            
           helper.showCustomToast(component, "Customer-requested suspension not permitted for "+subs , "", "warning");
            
        }
        else{
            
            helper.addSelectedSuspendResumeHelper (component, event);
        }
        }
    },
     
   
    
    //added to handle change on selection of action type
    handleActionTypeChange: function (component , event, helper) {
        component.set("v.showSpinner", true);      
        var basketId = component.get('v.basketId');
        var accountId = component.get('v.accountId');
        var actionTypeSelected=component.get('v.actionTypeSelected');
     //   alert(actionTypeSelected);
        //Added Billing Account check as part of Story EDGE-205597
        
        if(actionTypeSelected == 'Change Of Mobile Number'){
            component.set("v.searchPlaceHolder",'Search by Phone Number (starting with 614)');
        }
        else if(actionTypeSelected == 'Sim Replacement'){
            component.set("v.searchPlaceHolder",'Search by Phone Number (starting with 614) or Subscription Number');
        }
        else if(actionTypeSelected == 'Suspend' || actionTypeSelected == 'Resume'){
            component.set("v.searchPlaceHolder",'Search by Phone Number (starting with 614), Subscription Number, Site Location or Billing Account');
        }
        else if(actionTypeSelected == 'Change of Billing Account'){
            component.set("v.assuranceProfileFlag", false);
            component.set("v.cobaReason", "none");
            component.set("v.searchPlaceHolder",'Search by Subscription Name, Subscription Number or Billing Account');
        }
        else{
            component.set("v.searchPlaceHolder",'Search here...');
        }
        

        if(actionTypeSelected=='Sim Replacement' || actionTypeSelected == 'Change Of Mobile Number' || actionTypeSelected == 'Suspend' || actionTypeSelected == 'Resume' || actionTypeSelected == 'Modify' || actionTypeSelected == 'Change of Billing Account' || actionTypeSelected == 'Manage Fixed Numbers')
        {
            helper.pushColumnsInTable(component , event, helper,actionTypeSelected); //dpg-4542
            component.set("v.IsMobility", false);
				if(actionTypeSelected == 'Resume'){
                    
                     /*var cols=component.get("v.columns");
                     cols.push({label: 'Suspension Reason',//dpg-4542 Commented
                           fieldName: 'suspensionReason',
                           type: 'text',
                           sortable: true});
                     component.set("v.columns", cols);*///dpg-4542
				var action = component.get("c.getSuspendedSubscriptionViewForAssuranceAgent");
            action.setParams({
                "accountId": accountId
            });
			}else if(actionTypeSelected == 'Suspend' || actionTypeSelected == 'Modify' ){
                                       /* var cols=component.get("v.columns");
                     cols.push({
            label: 'SUBSCRIPTION NAME',
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
                       });
                     component.set("v.columns", cols);*/
				 var action = component.get("c.getSubscriptionViewForAssuranceAgent");
            action.setParams({
                "accountId": accountId
            });
		} else if(actionTypeSelected == 'Change of Billing Account') { //EDGE-205597: START
            component.set("v.filter","");
            var action = component.get("c.getFilteredSubscriptionsData");
            var inputMap = {
                'csord__Account__c': '=\'' + accountId + '\'',
                'csordtelcoa__Replacement_Subscription__c': '=null',
                'csordtelcoa__Product_Configuration__r.ConfigurationType1__c': '!=\'SolutionComponent\'',
                'MarketableOffer__r.CoBA_Enabled__c': '=true'
            };
            var fieldsList = ['Id','Name','csordtelcoa__Subscription_Number__c','customerFacingServiceId__c','MarketableOffer__r.Offer_ID__c','serviceMSISDN__c','Site__c','Site__r.Address__c',
                                'initialActivationDate__c','CreatedDate','csord__Status__c','csord__Total_Recurring_Charges__c',
                                'Billing_Account__r.name','CreatedBy.Name','csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name',
                                'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Eligible_For_Hardware_Refund__c',
                                'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Is_Hardware__c',
                                'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Refund_Duration__c',

          'Initial_Activation_DateTime__c'
        ];

            console.log('inputMap*** ' + inputMap);
            console.log('fieldsList*** ' + fieldsList);
            action.setParams({
                "inputMap": inputMap,
                "fieldsList":fieldsList,
                "actionType":actionTypeSelected
            }); //EDGE-205597: END
		} else {
                                    /* var cols=component.get("v.columns");
                     cols.push({
            label: 'SUBSCRIPTION NAME',
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
                       });
                     component.set("v.columns", cols);*/
				 var action = component.get("c.getActiveSuspendedSubscriptionViewForAssuranceAgent");
            action.setParams({
                "accountId": accountId,
                "actionTypeSelected": actionTypeSelected
            });			
			}
            action.setCallback(this, function (response) {
                var state = response.getState();
                var subids = [];
                component.set("v.showSpinner", false);
                if (state === "SUCCESS") {
                    var records = response.getReturnValue();
                    console.log("records---",records);
                    
                    if (records.length == 0) {
                        component.set("v.isListNotPresent", "true");
                        component.set("v.data", null);
                        component.set("v.filteredData", null);
                    } else {
                        records.forEach(function (record) {
                        subids.push(record.SubscriptionID);
                        var url='';
                   		url=JSON.stringify(window.location.href);
           				 console.log('url'+url);
                   		if(url.includes('/partners/')){
                      	  record.subscriptionNameLink = '/partners/' + record.SubscriptionID;
                       		if (record.SiteID != null) {
                                record.siteAddressLink = '/partners/' + record.SiteID;
                            }
                        }else{
                            record.subscriptionNameLink = '/' + record.SubscriptionID;
                            if (record.SiteID != null) {
                                record.siteAddressLink = '/' + record.SiteID;
                            }
                        }
                        });
                        component.set("v.data", records);
                        component.set("v.filteredData", records);
                        component.set("v.subids", subids);
                    } 
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    helper.showCustomToast(component, errors, "Initialization Error", "error");
                    //console.error(errors);
                }	
            });
            $A.enqueueAction(action);
        } 
        else
        {			
            if (basketId != null || basketId != "") 
            {
                var action = component.get("c.getACRId");
                action.setParams({
                    "basketId": basketId,
                });
                action.setCallback(this, function (response) {
                    var acr = response.getReturnValue();
                    component.set('v.selectedLookUpRecord', acr)
                });
                $A.enqueueAction(action);
            }
            // Invoke the service
            if (basketId == null || basketId == '') 
            {
                component.set("v.locationofUCEinbasket", false);
                component.set("v.locationofIPNetworkinbasket", false);
            } else 
            {
                var ifIPNetworkinbasket = component.get("c.ifProductPresent");
                ifIPNetworkinbasket.setParams({
                    "basketId": basketId,
                    "type": 'IP Network'
                });
                var iPNetworkisPresent = false;
                ifIPNetworkinbasket.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        iPNetworkisPresent = response.getReturnValue();
                        component.set("v.locationofIPNetworkinbasket", iPNetworkisPresent);
                        
                    }
                });
                $A.enqueueAction(ifIPNetworkinbasket);
                
                var ifUCEinbasket = component.get("c.ifProductPresent");
                ifUCEinbasket.setParams({
                    "basketId": basketId,
                    "type": 'Unified Communication'
                });
                var uCEisPresent = false;
                ifUCEinbasket.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        uCEisPresent = response.getReturnValue();
                        component.set("v.locationofUCEinbasket", uCEisPresent);
                    }
                });
                $A.enqueueAction(ifUCEinbasket);
                
                var CWPinbasket = component.get("c.noOfProductPresentUnderModify");
                CWPinbasket.setParams({
                    "basketId": basketId,
                    "type": 'Connected Workplace'
                });
                var cWPisPresent = 0;
                CWPinbasket.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        cWPisPresent = response.getReturnValue();
                        component.set("v.CwpRowsUnderModifyInBasket", cWPisPresent);
                    }
                });
                $A.enqueueAction(CWPinbasket);
            }
            var action =component.get("c.getSubscriptionView");	
            action.setParams({
                "basketId": basketId,
                "accountId": accountId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                component.set("v.showSpinner", false);
                if (state === "SUCCESS") {
                    var records = response.getReturnValue();
                    //alert(records);
                    if (records.length == 0) {
                        component.set("v.isListNotPresent", "true");
                    } else {
                        let nonCwpCount = 0;
                        let activeCwpCount = 0;
                        let mobilityCount = 0;
                        let nonCwpList = [];
                        let mobilityList = [];
                        let allCwpList = [];
                        records.forEach(function (record) {
                            if (record.isCWP == false) {
                                if (record.subscriptionName.includes("IP Network")) {
                                    
                                    if (record.status == 'Active') {
                                        component.set("v.statusofIPNetwork", record.status);
                                        component.set("v.ActiveIPNetwork", record.SubscriptionID);
                                    }
                                    nonCwpCount++;
                                    nonCwpList.push(record.SubscriptionID);
                                } else if (record.subscriptionName.includes("Unified Communication")) {
                                    
                                    if (record.status == 'Active') {
                                        component.set("v.statusofUCE", record.status);
                                        component.set("v.ActiveUCE", record.SubscriptionID);
                                    }
                                    nonCwpCount++;
                                    nonCwpList.push(record.SubscriptionID);
                                } else if (record.productDefinitionName.includes("Mobility")) {
                                    mobilityList.push(record.SubscriptionID);
                                    mobilityCount++;
                                }
                            } else if (record.subscriptionName.includes("Connected Workplace") && record.status == 'Active') {
                                allCwpList.push(record.SubscriptionID);//edge-77981 ac4
                                activeCwpCount++;
                            }
                        });
                        component.set("v.totalNumberOfActiveCwpRows", activeCwpCount);
                        component.set("v.totalNumberOfCwpRows", records.length - nonCwpCount - mobilityCount);
                        component.set("v.nonCwpData", nonCwpList);
                        component.set("v.mobilityData", mobilityList);
                        component.set("v.allCWPData", allCwpList);//edge 77981 ac4 
                        component.set("v.numberOfMobilityProducts", mobilityCount);
                    }
                    
                    records.forEach(function (record) {
                        var url='';
                   		url=JSON.stringify(window.location.href);
           				 console.log('url'+url);
                   		if(url.includes('/partners/')){
                      	  record.subscriptionNameLink = '/partners/' + record.SubscriptionID;
                       		if (record.SiteID != null) {
                                record.siteAddressLink = '/partners/' + record.SiteID;
                            }
                        }
                        else{
                            record.subscriptionNameLink = '/' + record.SubscriptionID;
                            if (record.SiteID != null) {
                                record.siteAddressLink = '/' + record.SiteID;
                            }
                        }
                    });
                    
                    component.set("v.data", records);
                    component.set("v.filteredData", records);
                    //component.set("v.wrapList",rows);
                    //component.find("box3").set("v.value", false);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    helper.showCustomToast(component, errors, "Initialization Error", "error");
                    //console.error(errors);
                }
            });	
            $A.enqueueAction(action);
        }
    },
    
    //EDGE 107130
     handleFixedNumDetails : function (component, event, helper) {
      var showreserve = event.getParam("openreservescrn"); 
      component.set("v.ShowReserveScrn",showreserve);
    },
    //EDGE-140733-Dheeraj Bhatt- Ability to lock/unlock NGUC subscription in SFDC/CS during number port out.
     onSubscriptionchange: function(component, event, helper){
       component.find("subscriptionLockUnlock").refreshSubscriptionList();
    },
	handleTnowCaseRefChange: function(component , event, helper) {
		var tNowCsRef=component.get('v.tNowCaseRef');
		var regExp = /(TNC\d\d\d\d\d\d\d\d\d)|(tnc\d\d\d\d\d\d\d\d\d)/;        
		if(tNowCsRef == '' || tNowCsRef == null || tNowCsRef == undefined){
			component.set("v.isTnowCaseRefValid", "false");
		}
		else if(tNowCsRef.match(regExp)) {
			component.set("v.isTnowCaseRefValid", "true");
		}
		else{
			component.set("v.isTnowCaseRefValid", "false");
		}		
	},
    handleRecordAction: function(component , event, helper) {//dpg4542start
        var picklistMap = event.getParam('row').suspensionReasonDescriptionCodeMap;
        var suspensionReasonSummary = event.getParam('row').suspensionReasonSummary;
        var selectedRowId = event.getParam('row').SubscriptionID;
        var actionName = event.getParam('action').name;
        if ( actionName == 'suspensionReasonSelection' ) {
            component.set("v.isModalOpen",true);
            component.set("v.popupHeading",'Suspension Reason');
            var OptionsMap = [];
            for(var key in picklistMap){
                OptionsMap.push({key: key, value: picklistMap[key]});
            }
            component.set("v.reasonMap",OptionsMap);
            component.set("v.selectedRowId",selectedRowId);

        }
        else if ( actionName == 'resumeReasonSelection' ) {
            component.set("v.isModalOpen",true);
            component.set("v.popupHeading",'Resume Reason');
            var OptionsMap = [];
            for(var key in picklistMap){
                if(suspensionReasonSummary && suspensionReasonSummary.includes(picklistMap[key])){
                    OptionsMap.push({key: key, value: picklistMap[key]});
                }
            }
            component.set("v.reasonMap",OptionsMap);
            component.set("v.selectedRowId",selectedRowId);
        }
    }, 
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        component.set("v.applyToAllConfig", false);
     },
    
     submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        component.set("v.isModalOpen", false);
        helper.stampReasonOnSubscription(component, event, helper);
     },
     handleReasonChange: function (component, event, helper) {
         var selPickListValue = event.getSource().get("v.value");
                console.log('******selPickListValue :'+selPickListValue );
      }//dpg4542end
})