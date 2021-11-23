({
    doInit : function(component, event, helper) { 
        var processedRecordVar = 0;
        var batchSize = helper.calculateRecordBatch(component, event, helper);
        var action = component.get("c.userInfoPRM");
        component.set("v.basketName", component.get("v.basketName").replace("BT", "CN"));
            
        action.setCallback(this, function(response) {
            
            var state = response.getState();  
            if(component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.set("v.isDisable", response.getReturnValue());
                }
            }
            else if(state === "ERROR"){
                component.set("v.errorMsg", 'Something went wrong.');
                helper.showError(component, event, helper);
            }
        });
        $A.enqueueAction(action);
        
        // EDGE-34646, EDGE-66515 :  Default contract recipient as Order requestor for Modify and Cancel orders
        var actionOnload = component.get("c.OnloadCustomerContractSignatory");
        actionOnload.setParams({
            "AccountId": component.get('v.AccountId'),
            "OppId": component.get('v.OppId'),
            "cancelOrderVar": component.get('v.cancelOrderVar'),
        });
        actionOnload.setCallback(this, function(response) {
            var state = response.getState();  
            if(component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()){
                    //   alert(JSON.stringify(response.getReturnValue()) +'______'+response.getState());
                    component.set("v.contractIdSelected", response.getReturnValue().split("!@@!@@!")[0]);
                    component.set("v.ContactName", response.getReturnValue().split("!@@!@@!")[1]);
                }
            }
            else if(state === "ERROR"){
                component.set("v.errorMsg", 'Something went wrong.');
                helper.showError(component, event, helper);
            }
        });
        $A.enqueueAction(actionOnload);
        
        /*---- PRM URL Redirection -----*/
        var actionOrgDetails = component.get("c.organizationInfo");
        actionOrgDetails.setCallback(this, function(response) {
            var state = response.getState();  
            //  alert(JSON.stringify(response.getReturnValue()) +'______'+response.getState());
            if(component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.set("v.OrgDetails", response.getReturnValue());
                }
            }
            else if(state === "ERROR"){
                component.set("v.errorMsg", 'Something went wrong.');
                helper.showError(component, event, helper);
            }
        });
        $A.enqueueAction(actionOrgDetails);
        
        
        
        
        
                        
		
        var famId = component.get('v.famID');
		if(famId != '' && famId != null){
			component.set("v.SQDisableFlag", true);
			var resolveSATypeDealJurney = component.get("c.resolveSATypeDealJurney");
			resolveSATypeDealJurney.setParams({
				"famId" : famId
			});
			resolveSATypeDealJurney.setCallback(this,function(response){
				var state = response.getState();
				component.set("v.SQDisableFlag", false);
				if(component.isValid() && state == "SUCCESS"){
					component.set("v.AgreementDecisionDealJurney", response.getReturnValue());
				}else if(state === "ERROR"){
                    component.set("v.errorMsg", 'Something went wrong.');
                    helper.showError(component, event, helper);
				}
			});
			$A.enqueueAction(resolveSATypeDealJurney);
		}
        
     /**
      * DIGI-16609
      * Order first Journey/Contract Signatory: As a Sales or Partner user I want to check an active 
      * contract (Dig BSA) at the RC Hierarchy level 
      * */
        debugger;
        var basketId=component.get('v.basketId');
        if(basketId!="" && basketId!=null){
            var opp=component.get('v.OppId');
            var resolveSATypeOnInit = component.get("c.resolveSATypeOnInit");
            resolveSATypeOnInit.setParams({
                "basketId":basketId,
                "oppId":opp
            });
            resolveSATypeOnInit.setCallback(this, function(response) {
                debugger;
                var state = response.getState();  
                if(component.isValid() && state === "SUCCESS") {
                    var res=response.getReturnValue();
                    component.set("v.AgreementDecision", response.getReturnValue());
                    var agreementDecisionObj=response.getReturnValue();
                    if (agreementDecisionObj.DigBSARelatedAccount != null && 
                        agreementDecisionObj.parentSAAgreement != null && 
                        agreementDecisionObj.sourceType === 'Digital' && 
                        //agreementDecisionObj.parentSAAgreement.Apttus__Status_Category__c === 'Business Services' && 
                        agreementDecisionObj.variationRequired === true){
                        component.set("v.isDigBsaPSVarApplicableForRA",true);
                        component.set("v.RelatedAccountId",agreementDecisionObj.DigBSARelatedAccount);
                        
                    }
                }
                else if(state === "ERROR"){
                    component.set("v.errorMsg", 'Something went wrong.');
                    helper.showError(component, event, helper);
                }
            });
            $A.enqueueAction(resolveSATypeOnInit);
        }
        
        
        /* EDGE-76151 : Site SQ web callout : START */
        var accountIdBsk= component.get('v.AccountId');
        var actionSiteSQ = component.get("c.siteSQWebCallout");
        actionSiteSQ.setParams({
            "basketId": component.get('v.basketId'),
            "recordCount": 100,
            "batchSize": batchSize,
            "offSetValue" : 0,
            "stringErrorIds" : '',
            "AccountId" : accountIdBsk,
        });
        actionSiteSQ.setCallback(this, function(response) {
            var state = response.getState(); 
            component.set("v.processedRecord", 1);
            if(component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()){
                    var parsedResponse = JSON.parse(response.getReturnValue());
                    processedRecordVar = processedRecordVar + parsedResponse.processedRecordCount;
                    // component.set("v.siteSQCompleted", false);
                    if(parsedResponse.updateCount != false)
                        component.set("v.processedRecord", processedRecordVar);
                    //Calling 2nd time -----
                    console.log(JSON.stringify(response.getReturnValue()) +'______'+response.getState());
                    var actionSiteSQ2 = component.get("c.siteSQWebCallout");
                    actionSiteSQ2.setParams({
                        "basketId": component.get('v.basketId'),
                        "recordCount": 100,
                        "batchSize": batchSize,
                        "offSetValue" : parsedResponse.offSetValue,
                        "stringErrorIds" : parsedResponse.stringErrorIds,
                        "AccountId" : accountIdBsk,
                    });
                    actionSiteSQ2.setCallback(this, function(response2) {
                        var state2 = response2.getState();  
                        if(component.isValid() && state2 === "SUCCESS") {
                            if(response2.getReturnValue()){
                                var parsedResponse2 = JSON.parse(response2.getReturnValue());
                                processedRecordVar = processedRecordVar + parsedResponse2.processedRecordCount;
                                //  alert(JSON.stringify(response2.getReturnValue()) +'______'+response2.getState());
                                if(parsedResponse2.updateCount != false)
                                    component.set("v.processedRecord", processedRecordVar);
                                //  component.set("v.siteSQCompleted", false);
                                //  component.set("v.siteSQCompletedSuccess", true);
                                //Calling 3nd time -----
                                var actionSiteSQ3 = component.get("c.siteSQWebCallout");
                                actionSiteSQ3.setParams({
                                    "basketId": component.get('v.basketId'),
                                    "recordCount": 100,
                                    "batchSize": batchSize,
                                    "offSetValue" : parsedResponse2.offSetValue,
                                    "stringErrorIds" : parsedResponse2.stringErrorIds,
                                    "AccountId" : accountIdBsk,
                                });
                                actionSiteSQ3.setCallback(this, function(response3) {
                                    var state3 = response3.getState();  
                                    if(component.isValid() && state3 === "SUCCESS") {
                                        if(response3.getReturnValue()){
                                            var parsedResponse3 = JSON.parse(response3.getReturnValue());
                                            processedRecordVar = processedRecordVar + parsedResponse3.processedRecordCount;
                                            //   alert(JSON.stringify(response3.getReturnValue()) +'______'+response3.getState());
                                            if(parsedResponse3.updateCount != false)
                                                component.set("v.processedRecord", processedRecordVar);
                                            //  component.set("v.siteSQCompleted", false);
                                            //  component.set("v.siteSQCompletedSuccess", true);
                                            //Calling 4nd time -----
                                            var actionSiteSQ4 = component.get("c.siteSQWebCallout");
                                            actionSiteSQ4.setParams({
                                                "basketId": component.get('v.basketId'),
                                                "recordCount": 100,
                                                "batchSize": batchSize,
                                                "offSetValue" : parsedResponse3.offSetValue,
                                                "stringErrorIds" : parsedResponse3.stringErrorIds,
                                                "AccountId" : accountIdBsk,
                                            });
                                            actionSiteSQ4.setCallback(this, function(response4) {
                                                var state4 = response4.getState();  
                                                if(component.isValid() && state4 === "SUCCESS") {
                                                    if(response4.getReturnValue()){
                                                        var parsedResponse4 = JSON.parse(response4.getReturnValue());
                                                        processedRecordVar = processedRecordVar + parsedResponse4.processedRecordCount;
                                                        //   alert(JSON.stringify(response4.getReturnValue()) +'______'+response4.getState());
                                                        if(parsedResponse4.updateCount != false)
                                                            component.set("v.processedRecord", processedRecordVar);
                                                        //  component.set("v.siteSQCompleted", false);
                                                        //  component.set("v.siteSQCompletedSuccess", true);
                                                        //Calling 5nd time -----
                                                        var actionSiteSQ5 = component.get("c.siteSQWebCallout");
                                                        console.log()
                                                        actionSiteSQ5.setParams({
                                                            "basketId": component.get('v.basketId'),
                                                            "recordCount": 100,
                                                            "batchSize": batchSize,
                                                            "offSetValue" : parsedResponse4.offSetValue,
                                                            "stringErrorIds" : parsedResponse4.stringErrorIds,
                                                            "AccountId" : accountIdBsk,
                                                        });
                                                        actionSiteSQ5.setCallback(this, function(response5) {
                                                            var state5 = response5.getState();  
                                                            if(component.isValid() && state5 === "SUCCESS") {
                                                                if(response5.getReturnValue()){
                                                                    //  alert(JSON.stringify(response5.getReturnValue()) +'______'+JSON.parse(response5.getReturnValue()).showError);
                                                                    var parsedResponse5 = JSON.parse(response5.getReturnValue());
                                                                    processedRecordVar = processedRecordVar + parsedResponse5.processedRecordCount;
                                                                    if(parsedResponse5.showError == true){
                                                                        component.set("v.processedRecord", parseInt(component.get("v.adboreIdCount")));
                                                                        component.set("v.siteSQCompleted", false);
                                                                        component.set("v.siteSQCompletedSuccess", false);
                                                                        var famID = component.get('v.famID');
                                                                        if(famID!=null){
                                                                            component.set("v.SQDisableFlag", false); 
                                                                            
                                                                        }else{
                                                                            component.set("v.SQDisableFlag", true);
                                                                        }
                                                                        component.set("v.siteSQCompletedError", true);
                                                                        
                                                                        var actionSiteSQError = component.get("c.UpdateRelatedDataForSQSite");
                                                                        actionSiteSQError.setParams({
                                                                            "basketId": component.get('v.basketId'),
                                                                            "stringErrorIds" : parsedResponse4.stringErrorIds,
                                                                        });
                                                                        actionSiteSQError.setCallback(this, function(responseError) {
                                                                            var stateError = responseError.getState();  
                                                                            if(component.isValid() && stateError === "SUCCESS") {
                                                                                component.set("v.siteSQCompleted", false);
                                                                            }
                                                                            else if(stateError === "ERROR"){
                                                                                component.set("v.errorMsg", 'Something went wrong.');
                                                                                helper.showError(component, event, helper);
                                                                            }
                                                                        });
                                                                        $A.enqueueAction(actionSiteSQError);
                                                                        
                                                                    }
                                                                    else{
                                                                        component.set("v.processedRecord", parseInt(component.get("v.adboreIdCount")));
                                                                        component.set("v.siteSQCompleted", false);
                                                                        component.set("v.siteSQCompletedSuccess", true);
                                                                        component.set("v.SQDisableFlag", false);
                                                                        component.set("v.siteSQCompletedError", false);
                                                                        
                                                                    }
                                                                    
                                                                }
                                                            }
                                                            else if(state5 === "ERROR"){
                                                                component.set("v.errorMsg", 'Something went wrong.');
                                                                helper.showError(component, event, helper);
                                                            }
                                                        });
                                                        $A.enqueueAction(actionSiteSQ5);
                                                        //Calling 5nd time -----
                                                        
                                                    }
                                                }
                                                else if(state4 === "ERROR"){
                                                    component.set("v.errorMsg", 'Something went wrong.');
                                                    helper.showError(component, event, helper);
                                                }
                                            });
                                            $A.enqueueAction(actionSiteSQ4);
                                            //Calling 4nd time -----
                                            
                                        }
                                    }
                                    else if(state3 === "ERROR"){
                                        component.set("v.errorMsg", 'Something went wrong.');
                                        helper.showError(component, event, helper);
                                    }
                                });
                                $A.enqueueAction(actionSiteSQ3);
                                //Calling 3nd time -----
                                
                            }
                        }
                        else if(state2 === "ERROR"){
                            component.set("v.errorMsg", 'Something went wrong.');
                            helper.showError(component, event, helper);
                        }
                    });
                    $A.enqueueAction(actionSiteSQ2);
                    //Calling 2nd time -----
                    
                }
            }
            else if(state === "ERROR"){
                component.set("v.errorMsg", 'Something went wrong.');
                helper.showError(component, event, helper);
            }
        });
        $A.enqueueAction(actionSiteSQ);
        
        /* EDGE-76151 : Site SQ web callout : END */
         //console.log('after Inside init');
       

                
    },
   //Added as part of EDGE-198027 to pass basket Id
   checkAsyncJob : function(component, event, helper){
          	//var jobId = component.get("v.syncJobId");
       		var syncJobStatus = component.get("c.toCheckSyncJobCompletion");
         	syncJobStatus.setParams({
                "basketId" : component.get("v.basketId"),
                "jobId":component.get("v.syncJobId")
            });
            syncJobStatus.setCallback(this, function(response) {
                if (response.getState()==="SUCCESS") {
                    var responseVal	=	response.getReturnValue();
                    status = responseVal['jobStatus'];
                    console.log('responseVal ==> '+responseVal);
                    if(responseVal['jobId'] != '' || responseVal['jobId'] != undefined){
                        component.set("v.syncJobId",responseVal['jobId']);
                    }
                    if(status === "Failed" || status === "Aborted"){
                        var errorFieldId = '';
                        component.set("v.loadingSpinner", false);
                        component.set("v.errorMsg", "Basket Sync Failed. Please try again!!!");
                        helper.showError(component, event, helper);
                        helper.showErrorEvent(component, event, helper, '', "Basket Sync Failed. Please try again!!!");

                    
                    }else if (status === undefined || status === ""){//195270 - Added condition to check for blank
                        clearInterval(refreshId);
                    
                    }else{
                        var refreshId = setInterval(function() {
                        	this.checkAsyncJob(component, event, helper);
                        }, 5000);

                    }
                }else if(state === "ERROR"){
                    var errors = response.getError();
                    console.log('errors ==> '+errors[0].message);
                    if(errors[0].message =='User do not have permission to perform this operation'){
                        component.set("v.errorMsg", 'Contract document generation has failed. You might not have appropriate access. Please raise a contract support case to generate the contract document.');
                        
                    }
                    else{
                        component.set("v.errorMsg", 'Cannot create Contract for this Basket');
                        
                    }
                    helper.showError(component, event, helper);
                }
			});
 			$A.enqueueAction(syncJobStatus);
    },
    handleSaveClick : function(component, event, helper) {
        
    //EDGE-190520 FAM Contract Initiation 
		
    	var famID = component.get('v.famID');
      	component.set("v.loadingSpinner", true);
        var selectedAccOwner = component.get('v.AccountOwnerId');
        var selectedContract = component.get('v.contractIdSelected');
        var basketId = component.get('v.basketId');
        
        var isErrorText = '';
        
        isErrorText = helper.validateSelectedRecord(component, event, helper, selectedAccOwner, selectedContract, basketId);
        // alert(isErrorText);
        if(isErrorText.trim() == "validated-true"){
            if (famID!= null && !famID.isBlank && famID != undefined && famID != ""){
                var action1 = component.get("c.createRecordFA"); 
				var agreementDecision = component.get('v.AgreementDecisionDealJurney');
                action1.setParams({
                    "famID": famID,
                    "signer2": selectedContract,
                    "signer3": selectedAccOwner,
					"agreementDecision":agreementDecision
                });
                console.log("###createRecordFA createRecordFA called" , famID , selectedContract , selectedAccOwner );               
                action1.setCallback(this, function(response) {
                    console.log(response.getState());
                    var state = response.getState();               
                    component.set("v.loadingSpinner", false);
                    var isCaseCreated=false;  //Added as a part of DIGI-22178 Start 
                    //EDGE-190520 FAM Contract Initiation
                    if(component.isValid() && state === "SUCCESS") {              
                        if(response.getReturnValue()){
                            //Added as a part of DIGI-434 Start  
                            if(response.getReturnValue() === 'Agreement has been created.'){
                                component.set("v.errorMsg", response.getReturnValue());
                                component.set("v.toastClass", 'slds-theme_success');
                                component.set("v.toastIcon", 'success');
                                helper.showError(component, event, helper);
                            }else{
                                /*Added this else part as a part of DIGI-434*/
                                component.set("v.errorMsg", response.getReturnValue());
                                isCaseCreated=true;  //Added as a part of DIGI-22178 Start 
                                helper.showErrorCaseCreation(component, event, helper);
                            }
                             //Added as a part of DIGI-434 END
                			var returnURL ='';
                            if(!isCaseCreated){   //DIGI-22178 Added this condition to handle the redirection stop when the case is created. started
                                if(component.get("v.isDisable") == true){
                                    if(component.get("v.OrgDetails") == 'Sandbox')
                                        //returnURL = "/partners/s/csconta__Frame_Agreement__c/"+famID +"/view";
                                        returnURL = "/partners/s/detail/"+famID;
                                    
                                    else{
                                        //returnURL = "/s/csconta__Frame_Agreement__c/"+famID+"/view";    
                                        returnURL = "/s/detail/"+famID;
                                    }
                                }
                                else{
                                    returnURL = "/lightning/r/csconta__Frame_Agreement__c/"+famID+"/view";
                                }  
                                window.open(returnURL);                                                        
                            } //End DIGI-22178
                             component.set("v.SQDisableFlag", true);
                        }
                    }
                    else if(state === "ERROR"){
                        //  EDGE-173035 exception handling
                        var errors = response.getError();
                        console.log('errors ==> '+errors[0].message);
                        if(errors[0].message =='User do not have permission to perform this operation'){
                            component.set("v.errorMsg", 'Contract document generation has failed. You might not have appropriate access. Please raise a contract support case to generate the contract document.');
                            
                        }
                        else{
                            component.set("v.errorMsg", 'Cannot create Contract for this Basket');
                            
                        }
                        helper.showError(component, event, helper);
                        component.set("v.SQDisableFlag", false);
                    }
                });
                $A.enqueueAction(action1);
            }
            else{
                     //start else here
             this.checkAsyncJob(component, event, helper);
                var isDigBsaPSVarApplicableForRA=component.get('v.isDigBsaPSVarApplicableForRA'); 
                var decision=component.get('v.AgreementDecision');
            var action = component.get("c.createRecord");
            action.setParams({
                "basketId": basketId,
                "signer2": selectedContract,
                "signer3": selectedAccOwner,
                "isDigBsaPSVarApplicableForRA":isDigBsaPSVarApplicableForRA ,
                "decision":decision
            });
            
            action.setCallback(this, function(response) {
                console.log(response.getState());
                //  alert(JSON.stringify(response.getReturnValue()) +'______'+response.getState());
                var state = response.getState();
                //  alert(response.getState()+response.getReturnValue()+response);
                
               component.set("v.loadingSpinner", false);
               
                // start EDGE-76402 Give validation error if no email address is there with contract signatory contact
                //var checkEmailAddress=response.getReturnValue().toString().toLowerCase();
               
               /* if(checkEmailAddress==='add valid email address for contract signatory'){
                    
                    component.set("v.errorMsg", 'Please add email address to contact prior to proceeding with contract generation');
                    helper.showError(component, event, helper);
                }*/
               //  end EDGE-76402 
               //  EDGE-173035 exception handling
                 if(component.isValid() && state === "SUCCESS") {
                    
                        var checkEmailAddress=response.getReturnValue().toString().toLowerCase();
                      if(checkEmailAddress==='add valid email address for contract signatory'){
                    
                    component.set("v.errorMsg", 'Please add email address to contact prior to proceeding with contract generation');
                    helper.showError(component, event, helper);
                    }	
                     //added condition for mix basket and price schedule different 
                     else if(response.getReturnValue() == 'Error Mix Basket'){
                     component.set("v.errorMsg", 'Mix Basket is not valid. Contact System Administrator');
                    helper.showError(component, event, helper);
                     }
                     //EDGE-219001 Start
                     else if(response.getReturnValue().split("!@@!@@!")[0] == 'AgreementError'){
                     component.set("v.errorMsg", response.getReturnValue().split("!@@!@@!")[1]+'. Please check Exception Logs for more details');
                     helper.showErrorCaseCreation(component, event, helper);
                     }
                     //DIGI-434 start
                     else if(response.getReturnValue().split("!@@!@@!")[0] == 'caseCreation'){
                     component.set("v.errorMsg", response.getReturnValue().split("!@@!@@!")[1]);
                     helper.showErrorCaseCreation(component, event, helper);
                     }
                     // DIGI-434 End
                     else if(response.getReturnValue() == 'Opty Error'){
                     component.set("v.errorMsg", 'Opportunity Contract type should be set to BSA or DSA inorder to generate a Contract');
                    helper.showErrorCaseCreation(component, event, helper);
                     }
                      //EDGE-219001 End
                    else if(response.getReturnValue() == 'Price Shcedule is not present'){
                     component.set("v.errorMsg", 'This is not a valid basket. Contact System Administrator');
                    helper.showError(component, event, helper);
                     }
                     //
                    else if(response.getReturnValue()){
                        component.set("v.errorMsg", 'Contract record created successfully.');
                        component.set("v.toastClass", 'slds-theme_success');
                        component.set("v.toastIcon", 'success');
                        
                        /*--  Update Basket stage  --*/
                        var actionBasket = component.get("c.updateBasketStage");
                        actionBasket.setParams({
                            "basketId": basketId,
                            "contractId": response.getReturnValue(),
                        });
                        $A.enqueueAction(actionBasket);
                        /*--  Update Basket stage  --*/  
                        helper.showError(component, event, helper);
                        
                        //--------------------------------
                        
                        var returnURL ='';
                        if(component.get("v.isDisable") == true){
                            if(component.get("v.OrgDetails") == 'Sandbox')
                                returnURL = "/partners/s/contractjunction/"+response.getReturnValue().trim()+"/view";
                            else{
                                returnURL = "/s/contractjunction/"+response.getReturnValue().trim()+"/view";    
                            }
                        }
                        else{
                            returnURL = "/lightning/r/ContractJunction__c/"+response.getReturnValue().trim()+"/view";
                        }
                       
                       // var vfurl = this.calldocusignurl(component, event, helper);
                        var navEvt = $A.get("e.force:navigateToSObject");
                        // var navEvt = $A.get("e.force:navigateToURL");
                        navEvt.setParams({
                            "recordId": returnURL,
                            "slideDevName": "ContractSignatoriesComponent"
                        });
                        navEvt.fire();
                       /* $A.get("e.force:navigateToURL").setParams({ 
                            "url": "/lightning/r/ContractJunction__c/"+response.getReturnValue().trim()+"/view",
                            "callingComponent" : "ContractSignatoriesComponent"
                        }).fire(); */
                        //--------------------------------
                        
                        //  window.open('/lightning/r/ContractJunction__c/'+response.getReturnValue().trim()+'/view');
                    }
                }
                    else if(state === "ERROR"){
                        //  EDGE-173035 exception handling
                        var errors = response.getError();
                        console.log('errors ==> '+errors[0].message);
                        if(errors[0].message =='User do not have permission to perform this operation'){
                             component.set("v.errorMsg", 'Contract document generation has failed. You might not have appropriate access. Please raise a contract support case to generate the contract document.');
                       
                        }
                        else{
                             component.set("v.errorMsg", 'Cannot create Contract for this Basket');                       
                        }
                        helper.showError(component, event, helper);
                    }
            });
            $A.enqueueAction(action);
            //End else here
            }       
           
            
        }
        else{
            // alert('#####>'+isErrorText);
            var errorString = '';
            var errorFieldId = '';
            if(isErrorText.includes("AccOwner")){
                errorString = "Please select Telstra Counter Signatory"; 
                errorFieldId = "TelstraCountersignatory";
            }
            else if(isErrorText.includes("Contact")){
                errorString = "Please select Customer Contact Signatory"; 
                errorFieldId = "CustomerContactSignatory";
            }
                else if(isErrorText.includes("Basket")){
                    errorString = "Invalid Basket";  
                }
                    else {
                        errorString = "Error!";                   
                    }
            component.set("v.loadingSpinner", false);
            component.set("v.errorMsg", errorString);
            helper.showError(component, event, helper);
            helper.showErrorEvent(component, event, helper, errorFieldId, errorString);
        }
},


    validateSelectedRecord : function(component, event, helper, selectedAccOwner, selectedContract, basketId) {
        //  alert('aid --> '+selectedAccOwner+'---cid --> '+selectedContract+'---bid --> '+basketId);
        //EDGE-190520 FAM Contract Initiation 
        var famID = component.get('v.famID');       
        if(selectedAccOwner.trim() == "" || selectedAccOwner == null || typeof selectedAccOwner === 'undefined'){
            return 'Error - AccOwner';
        }
        if(selectedContract.trim() == "" || selectedContract == null || typeof selectedContract === 'undefined'){
            return 'Error - Contact';
        }
        if(famID ==null || typeof famID === 'undefined' || famID ==""){
            if(basketId.trim() == "" || basketId == null || typeof basketId === 'undefined'){
                return 'Error - Basket';
            }
        }       
        return 'validated-true';
    },
    handleLookupSelectEvent : function (component, event, helper) {
        var selectedRecordId = event.getParam("recordId");
        var selectedrecordName = event.getParam("recordName");
        if(selectedrecordName == '--$$NotValidEmailId$$--' && selectedRecordId == ''){
            var errorString = 'Please ensure and add an email address';
            component.set("v.errorMsg", 'Please ensure and add an email address');
            helper.showError(component, event, helper);
            helper.showErrorEvent(component, event, helper, 'CustomerContactSignatory', errorString);
        }
    },
    toggle : function(component, event, helper) {
        var toggleText = component.find("errorMsgId");
        $A.util.toggleClass(toggleText, "toggle");
    },
    showError  : function(component, event, helper) {
        var toggleText = component.find("errorMsgId");
        $A.util.removeClass(toggleText,'toggle');
        window.setTimeout(
            $A.getCallback(function() {
                $A.util.addClass(component.find("errorMsgId"),'toggle'); 
            }), 5000
        );
    },
    //DIGI-434 Started
    showErrorCaseCreation  : function(component, event, helper) {
        var toggleText = component.find("errorMsgId");
        $A.util.removeClass(toggleText,'toggle');
         $A.getCallback(function() {
                $A.util.addClass(component.find("errorMsgId"),'toggle'); 
            });
        /*window.setTimeout(
            $A.getCallback(function() {
                $A.util.addClass(component.find("errorMsgId"),'toggle'); 
            }), 5000
        );*/
    },//DIGI-434 End
    showErrorEvent  : function(component, event, helper, fieldId, ErrMsg) {
        if(fieldId !='' && ErrMsg != ''){
            var appEvent = $A.get("e.c:showErrorContractSign");
            appEvent.setParams({
                "showError": true,
                "fieldId": fieldId,
                "ErrorMsg": ErrMsg
            });
            appEvent.fire();
        }
    },
    calculateRecordBatch : function(component, event, helper) {
        var famID = component.get('v.famID');
        var totalRecord = 0;
        if(famID==null)
            totalRecord = parseInt(component.get("v.adboreIdCount"));
        var TempBatchSize = Math.floor(totalRecord/5);
        var extraRecordRemaining  = totalRecord % 5;
        var batchSize = 0;
        if(extraRecordRemaining > 0)
            batchSize = TempBatchSize + 1;
        else
            batchSize = TempBatchSize;
        //  alert('#####--> '+batchSize);
        return batchSize;
    },

    //Added by Gautam Kumar as part of DIGI-11211
    insertTransactionLogs : function(component, event, helper){

        let accountId = component.get('v.AccountId');
        let basketId = component.get('v.basketId');
        let oppId = component.get('v.OppId');
        let famID = component.get('v.famID');
        let basketName = component.get('v.basketName');
        let type;
        
        //Frame Agreement type
        if(famID) type = 'FAM';
        //Contact Agreement type
        else if(!famID && basketId) type = 'CONTRACT';

        //call method to insert transactoin logs
        let insertLogAction = component.get("c.insertTransactionLogs");

        insertLogAction.setParams({
        oppId : oppId,
        basketId : basketId,
        accountId : accountId,
        basketName : basketName,
        famID : famID,
        type : type
        });
        insertLogAction.setCallback(this, function(response) {
        let state = response.getState();
        let res = response.getReturnValue();
        
        if(state === 'SUCCESS'){
            console.log('res value G*G after entry digi flow ', res);
            
        }
        else {
            
        }
        
        });
        $A.enqueueAction(insertLogAction); 
        
    

    }
    //End of DIGI-11211 added by Gautam Kumar
})