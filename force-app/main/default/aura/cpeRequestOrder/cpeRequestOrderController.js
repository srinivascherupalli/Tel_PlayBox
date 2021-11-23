({
	init : function(component, event, helper) {
        component.set('v.isOnLoad',true);
        component.set('v.showFieldsScreen',false);
        component.set('v.showConfirmScreen',false);
        component.set('v.showSpinner', true);
        component.set('v.quoteColumns', [
            {label: 'Accept Quote', fieldName: 'cpe_Accept_Quote__c', type: 'checkbox', cellAttributes: { alignment: 'left' }},
            {label: 'Quote Number', fieldName: 'cpe_External_System_Quote_Number__c', type: 'text', cellAttributes: { alignment: 'right' }},
            {label: 'Requote Details', fieldName: 'cpe_Requote_Details__c', type: 'text'}
        ]);
        
        var action = component.get("c.fetchQuoteDetails");
        action.setParams({caseId : component.get('v.caseId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.showSpinner', false);
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var responseWrapper = response.getReturnValue();
                component.set("v.quoteDeatils", responseWrapper.quoteDeatils);
                component.set("v.quoteQueueId", responseWrapper.quoteQueueId);
                component.set("v.noOfCaseDocuments", responseWrapper.noOfCaseDocuments);
                
                var selectedRowsIds = [];
                var noOfSelectedRowsIds = [];
                var count = 0;
                for (var i = 0; i < responseWrapper.quoteDeatils.length; i++) {
                    if(responseWrapper.quoteDeatils[i].cpe_Accept_Quote__c){
                        selectedRowsIds[count] = responseWrapper.quoteDeatils[i].Id;
                        noOfSelectedRowsIds= responseWrapper.quoteDeatils;
                        count++;
                    }

                }
                component.set("v.noOfCLISelected",noOfSelectedRowsIds);
                component.set("v.quoteLineItems", responseWrapper.quoteDeatils)

                var caseRecord = component.get("v.caseRecord");
                if(caseRecord['cpe_Billing_Requirements__c'] == 'Billed by Others')
                    component.set('v.showBilledOtherDetails', true);   
                if(caseRecord['cpe_NonStandard_Margin__c'] != '' && caseRecord['cpe_NonStandard_Margin__c'] != 'No, standard pricing applies')
                    component.set('v.showMarginDetails', true);  
                if(caseRecord['cpe_Request_Inclusion__c'] == 'Inflight Project Variation')
                    component.set('v.showVariationDetails', true);
                if(caseRecord.salesup_Site_Contact__c != '' && caseRecord.Contact )
                    component.set('v.selectedRecord',caseRecord.Contact)
                else
                    component.set('v.selectedRecord',{'Id': '', 'Name': ''})
                component.set('v.selectedRecordId',caseRecord.salesup_Site_Contact__c);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title" : "Error!",            
                            "message": errors[0].message,
                            "type": "error",
                            "duration":" 4000"
                        });
                        toastEvent.fire();
                    }
                } 
            }
        });
        component.set("v.noOfSite", component.get("v.caseRecord.salesup_No_of_sites_or_services__c"));
        component.set("v.shippingOutisde", component.get("v.caseRecord.cpe_Is_Shipping_Outside_Of_Australia__c"));
        component.set('v.showFileUploadMsg', helper.showFileUploadMsg(component, event, helper));
        if (component.get("v.caseRecord.cpe_Is_Shipping_Outside_Of_Australia__c") === "Yes") {
            component.set('v.showIsComplaintDefense', true);
        } else {
            component.set('v.showIsComplaintDefense', false);
        }
        $A.enqueueAction(action);
    },
    
    handleRowAction : function(component, event, helper){
        var selRows = event.getParam('selectedRows');
        component.set("v.noOfCLISelected",selRows);
    },
    
    closeModel : function(component, event, helper){
        component.set('v.isOpenModal', false);
        component.set('v.showFieldsScreen',false);   
        component.set('v.showConfirmScreen',false);
        component.set('v.isOnLoad',false);   
        
    } ,

    handleLoad: function(component, event, helper){        
        component.set('v.showSpinner', false);
        var record = event.getParam("recordUi");
    } ,

    handleError: function (component, event, helper) {
        component.set('v.showSpinner', false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": event.getParams().detail,
            "type": "error",
            "duration":" 4000"
        });
        toastEvent.fire();
    },

    handleSuccess: function (component, event, helper) {
        console.log('Record Edit Success')
         
    }, 

    handleOnSubmit: function(component, event, helper){
        event.preventDefault();       
        var fields = event.getParam("fields");        
        
        var caseRecord = component.get('v.caseRecord');
        fields["srvsup_Categories__c"] = 'Ordering Hardware & Services';
        fields["salesup_Work_Required__c"] = 'HW&S Ordering';
        fields["Status"] = 'New';
        fields["cpe_Order_Status__c"] = 'New';
        if(component.get('v.noOfCLISelected').length == 1){
            var noOfCLISelected= component.get('v.noOfCLISelected');
            var quoteLineItems= component.get("v.quoteLineItems");
            if(quoteLineItems[0].Id === noOfCLISelected[0].Id){
                fields["cpe_Quote_Status__c"] = 'Accepted by Customer';
            }else{
                fields["cpe_Quote_Status__c"] = 'Iteration Accepted by Customer';
            }
        }else if(component.get('v.noOfCLISelected').length > 1){
            fields["cpe_Quote_Status__c"] = 'Iteration Accepted by Customer';
        }
        fields["OwnerId"] = component.get('v.quoteQueueId');
        fields["salesup_Site_Contact__c"] = component.get('v.selectedRecordId');
        component.find("caseUpdateFormSup").submit(fields);  
        helper.attachDocument(component, event, helper) ;  
        component.set('v.showSpinner', false);
        component.set('v.showFieldsScreen',false);
        component.set('v.showConfirmScreen', true);        
    } ,

    saveCaseDetails: function(component, event, helper){
        var buttonClick = event.getSource().getLocalId();
        component.set('v.showSpinner', true);
        if(buttonClick === 'onLoadButton'){
            var quoteDetails = component.get('v.quoteDeatils');
            var checkQuote = component.find("checkContact"); 
            var noOfSelectedRowsIds = [];
            var quoteCount = 0;
            
            if(checkQuote.length){
                for(var i=0; i<checkQuote.length; i++){
                    var isCheked = checkQuote[i].get("v.value");
                    var textId = checkQuote[i].get("v.text");
                    if(isCheked){
                        for(var quote=0; quote<quoteDetails.length; quote++){
                            if(quoteDetails[quote].Id == textId) {
                                noOfSelectedRowsIds[quoteCount] = (quoteDetails[quote]);
                                quoteCount++;
                                break;
                            }
                        }
                    }
                }
            }else{
                var isCheked = checkQuote.get("v.value");
                var textId = checkQuote.get("v.text");
                if(isCheked){
                    for(var quote=0; quote<quoteDetails.length; i++){
                        if(quoteDetails[quote].Id == textId) {
                            noOfSelectedRowsIds[quoteCount] = (quoteDetails[quote]);
                            quoteCount++;
                            break;
                        }
                    }
                }
            }
            component.set('v.noOfCLISelected', noOfSelectedRowsIds);
            helper.acceptQuotes(component, event, helper);
        }else if(buttonClick === 'onFieldScreen'){            
            
            var isRequiredError = false;
            if(component.find('billingId') != null && (component.find('billingId').get('v.value') == ''
              										|| component.find('billingId').get('v.value') == null)){                
                isRequiredError = true;
            }
            
            if(component.find('billingId') != null && component.find('billingId').get('v.value') == 'Billed by Others' && component.find('billedById') != null
                                && ( component.find('billedById').get('v.value') == ''  || component.find('billedById').get('v.value') == null)){    
                isRequiredError = true; 
            }  
            
            if(component.find('FlexcabId') != null && (component.find('FlexcabId').get('v.value') == ''
                                                      || component.find('FlexcabId').get('v.value') == null)){                
                isRequiredError = true;
            }

            if(component.find('noOFSiteId') != null && (component.find('noOFSiteId').get('v.value') == ''
              										|| component.find('noOFSiteId').get('v.value') == null)){                
                isRequiredError = true;
            }

            if(component.find('PIAddressbId') != null && (component.find('PIAddressbId').get('v.value') == '' 
              										 || component.find('PIAddressbId').get('v.value') == null)){                
                isRequiredError = true;
            }
            
            if(component.get("v.selectedRecordId") == null){ 
                isRequiredError = true;
            }
            
            var noOfCaseDocuments = component.get("v.noOfCaseDocuments");
            var uploadedFilesLength =component.get("v.uploadedFilesLength");
            if(noOfCaseDocuments == 0 && uploadedFilesLength ==0){
                isRequiredError = true;
            }

            if(isRequiredError){
                component.set('v.showSpinner', false);
                var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                            "title": "Error!",
                            "message": 'Please provide all required values',
                            "type": "error",
                            "duration":" 4000"
                });
                toastEvent.fire();
            } else {          
            	document.getElementById("recordFormBtn").click();
            }
        } 
    },

    saveCaseDetailsForm: function(component, event, helper){ 
        component.find("caseUpdateFormSup").submit();    
    },

    handleBillingReqChange : function(component, event, helper) {        
        var billingReq = event.getParam("value");
        if( billingReq == 'Billed by Others')
            component.set('v.showBilledOtherDetails', true);
        else
            component.set('v.showBilledOtherDetails', false);

    },
    
    handleShippingAusChange : function(component, event, helper) {        
        var isShippingOutside = event.getParam("value");
        component.set('v.shippingOutisde', isShippingOutside);
        if( isShippingOutside === 'Yes') {
        	component.set('v.showIsComplaintDefense', true);
        } else {
        	component.set('v.showIsComplaintDefense', false);
        }
		if (component.get('v.noOfSite') > 1 || isShippingOutside === 'Yes') {
        	component.set('v.showFileUploadMsg', true);
        } else {
            component.set('v.showFileUploadMsg', false);
        }
    },
    
    handleNoOfSite : function(component, event, helper) {        
        var numberOfSite = event.getParam("value");
        component.set('v.noOfSite', parseInt(numberOfSite, 10));
        if (parseInt(numberOfSite, 10) > 1 || component.get('v.shippingOutisde') === 'Yes') {
            component.set('v.showFileUploadMsg', true);
        } else {
            component.set('v.showFileUploadMsg', false);
        }
    },

    handleNonStdMrgChange : function(component, event, helper) {        
        var stdMargin = event.getParam("value");
        if(stdMargin != '' && stdMargin != 'No, standard pricing applies')
            component.set('v.showMarginDetails', true);
        else
            component.set('v.showMarginDetails', false);
    },

    handleRequestInclChange : function(component, event, helper) {        
        var reqInclusion = event.getParam("value");
        if(reqInclusion == 'Inflight Project Variation')
            component.set('v.showVariationDetails', true);
        else
            component.set('v.showVariationDetails', false);
    },    
    
    handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        //alert("Files uploaded : " + uploadedFiles.length);
        component.set('v.uploadedFilesLength', +uploadedFiles.length);
    }
})