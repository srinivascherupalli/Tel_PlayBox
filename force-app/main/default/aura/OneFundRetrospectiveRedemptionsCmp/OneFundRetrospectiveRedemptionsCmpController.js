({
    /*
* DEVELOPER : Hari/Vamshi/Tejes
* TEAM: Napier
* DESCRIPTION : This is controller for OneFundRetrospectiveRedemption Component  
* EDGE-117021, EDGE-116922, EDGE-124053, EDGE-116083, EDGE-124045, EDGE-124896, EDGE-135560,EDGE-175751
*/
    doInit: function(cmp, event, helper) {     
        var action = cmp.get('c.getcaseDetatils');
        var rId = cmp.get("v.recordId");
        action.setParams({ "caseRecord":rId });       
        action.setCallback(this,function(response){            
            var state = response.getState();
            if(state === "SUCCESS"){
                
                //console.log('CASE+++>'+JSON.stringify(response.getReturnValue()));
                cmp.set("v.caseDetails",response.getReturnValue());
                cmp.set("v.curAccountId",response.getReturnValue().AccountId);
                cmp.set("v.attachmentdata",response.getReturnValue().Attachment_Count__c);
                if(response.getReturnValue().Attachment_Count__c === undefined || response.getReturnValue().Attachment_Count__c === 0 ){
                    cmp.set("v.attachmentCheck",true);
                }
                console.log('attch::',+ cmp.get("v.attachmentCheck"));
                cmp.set('v.queriedLineItemsSaved', response.getReturnValue().Queried_Line_Items__r);
                if(response.getReturnValue().Status === 'Closed'){
                    cmp.set("v.checkCasestatus",false);
                }else if(response.getReturnValue().Status === 'Initiate Redemption'){
                    cmp.set("v.checkNext",false);
                    helper.savedQueriedLIneItems(cmp);
                    cmp.set("v.checkCasestatus",true);
                    cmp.set("v.qlisave",true);
                    var rId = cmp.get("v.recordId");
                    var action2 = cmp.get('c.GetAvailableOneFundBalance');
                    action2.setParams({
                        "AccountId":cmp.get("v.curAccountId")
                    });
                    action2.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state == "SUCCESS") {
                            var OneFundBalance = response.getReturnValue();
                            cmp.set("v.AvailableOneFundBalance", OneFundBalance);
                            cmp.set("v.SuccessOneFundBalance", true);
                            cmp.set("v.submitOneFundBalance",true);
                        }
                    });
                    $A.enqueueAction(action2);                    
                }else if(cmp.get("v.queriedLineItemsSaved") != null && cmp.get("v.queriedLineItemsSaved") != '' && cmp.get("v.queriedLineItemsSaved") != undefined){
                    cmp.set("v.checkNext",false);
                    helper.savedQueriedLIneItems(cmp);
                    cmp.set("v.checkCasestatus",true);
                    cmp.set("v.qlisave",false);
                    var rId = cmp.get("v.recordId");
                    var action2 = cmp.get('c.GetAvailableOneFundBalance');
                    action2.setParams({
                        "AccountId":cmp.get("v.curAccountId")
                    });
                    action2.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state == "SUCCESS") {
                            var OneFundBalance = response.getReturnValue();
                            cmp.set("v.oneFundBalance",true);
                            cmp.set("v.AvailableOneFundBalance", OneFundBalance);
                            cmp.set("v.SuccessOneFundBalance", true);
                            cmp.set("v.submitOneFundBalance",true);
                        }
                    });
                    $A.enqueueAction(action2);  
                    
                }else{
                    cmp.set("v.checkCasestatus",true);
                }
                cmp.set('v.loaded1', true);
                cmp.set('v.loaded3', true);
            }
        });  
        
        
        $A.enqueueAction(action);     
    },
    
        // Method Written for displaying invoice data on click of search Button
    //EDGE-116222
    invoicesearch: function(component, event, helper){
        component.set("v.ErrorCheck",false);
        var invoiceno=component.find("invoicenumber").get("v.value");
        var invnoint = parseInt(invoiceno);
        if(invoiceno.length !=13 || isNaN(invoiceno) || invnoint<1)
        {
            component.set('v.columns',null);
            component.set('v.data',null);
            component.set('v.showtable',false);
            component.set('v.formatCheck',true);
            return;
        }
        else{
            component.set('v.loaded', false);
            component.set('v.formatCheck',false);
            component.set("v.ErrorCheck",false);
            console.log('Hello');
            component.set('v.columns', [
                {label: 'Invoice line item', fieldName: 'invoiceLineNumber', type: 'number', cellAttributes: { alignment: 'left' }},
                {label: 'Offer name', fieldName: 'offername', type: 'text' },
                {label: 'Service type', fieldName: 'servicetype', type: 'text'},
                {label: 'Charge (Including GST)', fieldName: 'chargeIncludingGST', type: 'currency', cellAttributes: { alignment: 'left' }},
                //EDGE-175751
                {label: 'Charge (Excluding GST)', fieldName: 'chargeExcludingGST', type: 'currency', cellAttributes: { alignment: 'left' }},
                {label: 'Charge Type', fieldName: 'chargeType', type: 'text'},
                {label: 'Eligible Redemption Amount(Excluding GST)', fieldName: 'EligibleRedemptionAmount', type: 'currency', cellAttributes: { alignment: 'left' }}               
            ]);
            var invNumber = component.find("invoicenumber").get("v.value");
            var rId = component.get("v.recordId");
            console.log('invoicenumber'+ invNumber+rId);
            var action = component.get('c.callAria');
            console.log('billingaccountnumber'+ component.get("v.caseDetails").Billing_Account__r.Billing_Account_Number__c);
            action.setParams({
                "invnumber1":invNumber,
                "customerAccountNumber":component.get("v.caseDetails").Billing_Account__r.Billing_Account_Number__c
            });
            action.setCallback(this, function(response){
                console.log('state::',+state)
                var state = response.getState();
                if(state === 'SUCCESS'|| state === 'DRAFT'){
                    console.log('success response::',+response.getReturnValue());
                    component.set('v.loaded', true);
                    var responseValue = response.getReturnValue();
                    var errorResponse = JSON.parse(JSON.stringify(responseValue));
                    console.log('errorResponse[0].errorKey'+errorResponse[0].errorKey);
                    if(errorResponse[0].errorKey !== 'undefined') {
                        if(errorResponse[0].errorKey == "invoice.data.not.found"){
                            console.log('errorResponse[0].errorKey====>'+errorResponse[0].errorKey);
                            component.set("v.ErrorCheck",true);
                            component.set('v.columns',null);
                            component.set('v.data',null);
                            component.set('v.showtable',false);                            
                        }
                    }
                    if(errorResponse[0].errorKey === '') {                        
                        component.set('v.showtable',true);
                        component.set("v.dataInitiateRedemption",responseValue);
                        component.set('v.data', responseValue);
                    }
                } else if(state === 'ERROR'){ 
                    console.log('error response::',+response.getReturnValue());
                    var errormsg =response.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:'Server is not responding. Please try after some time',
                        messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();                   
                }              
            });
            $A.enqueueAction(action);   
        }        
    }, 
    // Method Written for displaying data on click of Initiate Redemption Button
    //EDGE-124045
    InitiateRedemption: function(component, event, helper){
        component.set("v.checkNext",false);
        var invNumber = component.find("invoicenumber").get("v.value");
        component.set('v.columns', [            
            {label: 'Invoice line item', fieldName: 'invoiceLineNumber', type: 'number', cellAttributes: { alignment: 'left' }},
            {label: 'Offer name', fieldName: 'offername', type: 'text'},
            {label: 'Service type', fieldName: 'servicetype', type: 'text'},
            {label: 'Charge (Including GST)', fieldName: 'chargeIncludingGST', type: 'currency', cellAttributes: { alignment: 'left' }},
			//EDGE-175751
            {label: 'Charge (Excluding GST)', fieldName: 'chargeExcludingGST', type: 'currency', cellAttributes: { alignment: 'left' }},
            {label: 'Charge Type', fieldName: 'chargeType', type: 'text'},
            {label: 'Eligible Redemption Amount(Excluding GST)', fieldName: 'EligibleRedemptionAmount', type: 'currency', cellAttributes: { alignment: 'left' }},
            {label: 'Eligible for Redemption', fieldName: 'Flag', type: 'text'},
            {label: 'Redemption Amount', fieldName: 'nullredemptionamt', type: 'currency',editable:true}
        ]);
        var InitiateRedemptiondata= component.get("v.dataInitiateRedemption");
        component.set('v.data',InitiateRedemptiondata );
        var rId = component.get("v.recordId");
        var action2 = component.get('c.GetAvailableOneFundBalance');
        action2.setParams({
            "AccountId":component.get("v.caseDetails").AccountId
        });          
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                component.set("v.oneFundBalance",true);
                var OneFundBalance = response.getReturnValue();
                component.set("v.AvailableOneFundBalance", OneFundBalance);
            }
        });
        console.log(JSON.stringify(component.get("v.caseDetails")));
        var action3 = component.get("c.insertInvoices");
        action3.setParams({
            "invoices":JSON.stringify(InitiateRedemptiondata),
            "caseRecord":component.get("v.caseDetails")
        });
        action3.setCallback(this, function(response) {
            var state = response.getState();
            var Message = JSON.stringify(response);
        });
        $A.enqueueAction(action2);
        $A.enqueueAction(action3);
    },
    // Event used on edit of the Redemption Amount
    //EDGE-124045
    handleEditEdition  : function(cmp , event ,helper){
        var draftValues = cmp.get(`v.draftValues`);//event.getParam('draftValues');
        var editValues = event.getParam('editvalues');
        let editedValues = cmp.get(`v.editvalues`);
        console.log('draft'+editValues);
        console.log('edit'+draftValues);
    },
    // Method triggered on save button after entering the Redemption Amount
    //EDGE-124045    
    saveChanges: function(cmp, event, draftValues) {
        var errors = cmp.get("v.errors");
        if(errors.rows!=undefined && errors.rows!=null ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'The inline errors need to be fixed before saving the data',
                messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        else if(errors.rows==undefined && errors.rows==null ){
            var avlbalance = cmp.get("v.AvailableOneFundBalance");
            var atomicChanges = [];//cmp.get('v.atomicChanges');
            atomicChanges= event.getParam('draftValues');
            var totalredemptionamt = 0; 
            for(var j=0; j<atomicChanges.length;j++){
                if(atomicChanges[j].nullredemptionamt){
                    console.log('totalredemptionamt' +atomicChanges[j]);
                    totalredemptionamt  = totalredemptionamt + parseFloat(atomicChanges[j].nullredemptionamt) ;
                }
            }
            if(totalredemptionamt > avlbalance || totalredemptionamt === 0 ){
                if(totalredemptionamt === 0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:'Please enter the Redemption Amount,it cannot be blank',
                        messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();                    
                }else if(totalredemptionamt > avlbalance){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:'Total redemption amount entered(sum of all redeem amounts) against highlighted invoice line item exceeds the "Available Onefund balance". Please re- enter and click on save again',
                        messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            }else{
                var InitiateRedemptiondata1= cmp.get("v.dataInitiateRedemption");
                var atomicChanges2 = [];//cmp.get('v.atomicChanges');
                atomicChanges2= event.getParam('draftValues');
                cmp.set("v.draftValues2",atomicChanges2);
                var Redemptions= JSON.stringify(atomicChanges2);
                console.log('Redemptions====>'+Redemptions);
                var action;
                if(!atomicChanges2[0].id.includes("000000")){
                    var rId = cmp.get("v.recordId");
                    action = cmp.get("c.insertQueriedLineItems");
                    action.setParams({   
                        "invoices":JSON.stringify(InitiateRedemptiondata1),
                        "redemptions": Redemptions,
                        "caseid":rId
                    });                    
                }else{
                    Redemptions = Redemptions.replace(/nullredemptionamt/g, 'Redemption_Amount__c');
                    Redemptions = Redemptions.replace(/id/g, 'Id');
                    console.log('Redemptions  : '+Redemptions);                    
                    action = cmp.get("c.updateQueriedLineItems");
                    action.setParams({
                        "redemptions": Redemptions,
                    }); 
                    
                }
               
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === 'SUCCESS'|| state === 'DRAFT'){
                        cmp.set("v.savecheck",false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success!',
                            message:'The records has been saved successfully.',
                            duration:'1000',
                            type: 'success',
                        });
                        toastEvent.fire();
                    }
                    else if(state === 'ERROR'){
                        debugger;
                        var errors = response.getError();
                        if (errors){
                            if (errors[0] && errors[0].message){
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }                        
                        var errormsg =response.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error Message',
                            message:'Changes are not saved please contact Admin',
                            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();                        
                    }
                        else{
                            var errormsg =response.getReturnValue();
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error Message',
                                message:'Case is Closed, you cannot make any changes',
                                messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });                           
                        }
                });
                $A.enqueueAction(action);             
            }
        }
    },
    //added cancel functionality on inline edit
    //added by Vamshi
    cancel :function(cmp){
        cmp.set("v.errors", []);
    },
    // Method triggered on submit button after entering the Redemption Amount and saving it
    //EDGE-124045 ,EDGE-116083 , EDGE-135560 
    submit :function(cmp,event,draftValues){
        /*var attchmtcount = cmp.get("v.attachmentdata");
        console.log('attchmtcount',+attchmtcount);
        var atccheck = cmp.get("v.attachmentCheck");
        var self = this;
        var errors = cmp.get("v.errors");
        var savechk = cmp.get("v.savecheck");
        console.log('savechk:: ',+savechk);*/
        var rId = cmp.get("v.recordId");
        
        debugger;
        var action2 = cmp.get("c.getcaseDetatils");
        action2.setParams({
            "caseRecord":rId
        }); 
        action2.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            var res=response.getReturnValue();
            if(state === 'SUCCESS'){
                cmp.set("v.attachmentdata",response.getReturnValue().Attachment_Count__c);
               	//var qlicount = response.getReturnValue().Queried_Line_Items__r.length;
               	var qlidata = response.getReturnValue().Queried_Line_Items__r;
               	var qlicount = 0;
                var attchmtcount = cmp.get("v.attachmentdata");
                console.log('attchmtcount',+attchmtcount);
                var atccheck = cmp.get("v.attachmentCheck");
                var self = this;
                var errors = cmp.get("v.errors");
                var savechk = cmp.get("v.savecheck");
                console.log('savechk:: ',+savechk);
                
                //if(savechk === true){
                if(qlidata == undefined){    
                    if(errors.rows!=undefined && errors.rows!=null){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error Message',
                            message:'Please save the records before submitting for approval',
                            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    else if(errors.rows==undefined && errors.rows==null){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error Message',
                            message:'Please save the records before submitting for approval',
                            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    } 
                }else if(cmp.get("v.attachmentdata") == '0' || cmp.get("v.attachmentdata") == undefined){
                    console.log(cmp.get("v.attachmentdata"));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:'Please attach customer consent to proceed with Redemption Request',
                        messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }else{
                    cmp.set("v.disabledSave",true);
                    var rId = cmp.get("v.recordId");
                    var InitiateRedemptiondata1= cmp.get("v.dataInitiateRedemption");
                    var atomic=cmp.get("v.draftValues2");
                    var Redemptions2= JSON.stringify(atomic);
                    var action = cmp.get("c.getQueriedLineItems");
                    action.setParams({
                        "invoices":JSON.stringify(InitiateRedemptiondata1),
                        "redemptions": Redemptions2
                    });          
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state == "SUCCESS") {
                            cmp.set("v.queriedLineItems",true);
                            cmp.set("v.QueriedLineItemsList", response.getReturnValue());
                            cmp.set('v.columns', [
                                {label: 'Invoice line item', fieldName: 'invoiceLineNumber', type: 'number', cellAttributes: { alignment: 'left' }},
                                {label: 'Offer name', fieldName: 'offername', type: 'text'},
                                {label: 'Service type', fieldName: 'servicetype', type: 'text'},
                                {label: 'Charge (Including GST)', fieldName: 'chargeIncludingGST', type: 'currency', cellAttributes: { alignment: 'left' }},
                                //EDGE-175751
                                {label: 'Charge (Excluding GST)', fieldName: 'chargeExcludingGST', type: 'currency', cellAttributes: { alignment: 'left' }},
                				{label: 'Charge Type', fieldName: 'chargeType', type: 'text'},
                                {label: 'Eligible Redemption Amount(Excluding GST)', fieldName: 'EligibleRedemptionAmount', type: 'currency', cellAttributes: { alignment: 'left' }},
                                {label: 'Redemption Amount', fieldName: 'nullredemptionamt', type: 'currency', cellAttributes: { alignment: 'left' }}                      
                            ]);
                            cmp.set("v.data",response.getReturnValue());
                        }
                    });            
                    var action1 = cmp.get('c.updatecasestatus');
                    action1.setParams({ "caserec":cmp.get("v.caseDetails") });             
                    action1.setCallback(this,function(response){                
                        var state = response.getState();
                        if(state === "SUCCESS"){
                            console.log('state');                    
                            $A.get('e.force:refreshView').fire();                    
                        }
                    });                   
                    $A.enqueueAction(action);
                    $A.enqueueAction(action1);            
                    cmp.set("v.disabledDataTable",false);
                    
                    
                }
                
            }
        });
        $A.enqueueAction(action2);
        
        
        //console.log('v.attachmentdata'+v.attachmentdata);
        
        
        
    },
    isRefreshed: function(component, event, helper) {
        location.reload();
    },
    // Method triggered on Edit the cell and for entering the Redemption Amount
    //EDGE-124045  
    handleEditCell :function(cmp , event ,helper){
        cmp.set("v.savecheck",true) ; 
        console.log('handleEditCell function called');
        var saveLocalStorage = cmp.get('v.saveLocalStorage');
        var atomicChange = event.getParam('draftValues');
        var mainData = cmp.get('v.data');
        console.log('saveLocalStorage : '+saveLocalStorage);
        console.log('atomicChange : '+JSON.stringify(atomicChange));
        console.log('mainData : '+JSON.stringify(mainData));
        var atomicChanges = [];//cmp.get('v.atomicChanges');
        atomicChanges.push(atomicChange);
        cmp.set('v.changeIndex', atomicChanges.length);
        var draftValues = helper.getBuildedDraftValues(atomicChanges, atomicChanges.length);
        console.log('draftValues : '+JSON.stringify(draftValues));
        localStorage.setItem('demo-draft-values', JSON.stringify(atomicChanges));
        console.log('printing draftValues : ' +JSON.stringify(draftValues));
        console.log(' Data.chargeExcludingGST ' +JSON.stringify(mainData[0].EligibleRedemptionAmount)+' atomicCHange.nullredemptionamt   '+JSON.stringify(draftValues[0].nullredemptionamt));
        var index = draftValues[0].id;
        var num = index;
        var mainKey;
        var dataMap = {};
        if(!index.includes("000000")){            
            mainKey = num-1;
        }else{
            /*var num1 = index.split("row-")[1];
            console.log('num1 : '+num1);
            num = parseInt(num1) + 1;*/
            dataMap = mainData.reduce(function(map, obj) {
                map[obj.id] = obj;
                return map;
            }, {});
            mainKey = index; 
            console.log('result1 :  -------++'+JSON.stringify(dataMap));
        }
        console.log('mainData[mainKey] '+JSON.stringify(mainData[mainKey]));
        console.log('mainKey : '+mainKey);
        if((mainData[mainKey] !=null && mainData[mainKey].EligibleRedemptionAmount >= draftValues[0].nullredemptionamt)|| (dataMap[mainKey] != null && dataMap[mainKey].EligibleRedemptionAmount >= draftValues[0].nullredemptionamt) ){
            var errorTemp = cmp.get('v.errors');
            if(errorTemp.rows != undefined || errorTemp.rows != null ){
                console.log('errorTemp created : ' +errorTemp);
                console.log('errorTemp.rows 1'+JSON.stringify(errorTemp.rows));
                delete errorTemp.rows[num];
                console.log('errorTemp.rows 2'+JSON.stringify(errorTemp.rows));
                console.log('errorTemp.rows 2'+JSON.stringify(errorTemp.rows));
                console.log('errorTemp created 2: ' +JSON.stringify(errorTemp));
                console.log('errorTemp created 2: ' +JSON.stringify(errorTemp));
                if(JSON.stringify(errorTemp.rows) === null || JSON.stringify(errorTemp.rows) ==='{}'){
                    console.log('inside the rows null or empty');
                    errorTemp = '[]';
                }
                cmp.set("v.errors", errorTemp);
            }
        }
        if((mainData[mainKey] !=null && mainData[mainKey].EligibleRedemptionAmount < draftValues[0].nullredemptionamt) || (dataMap[mainKey] != null && dataMap[mainKey].EligibleRedemptionAmount < draftValues[0].nullredemptionamt)){
            var msg = 'Redemption amount entered against an highlighted invoice line item exceeds the "eligibility Redemption amount". Please re-enter the amount and click on save again';
            var errors = cmp.get("v.errors");
            console.log('errors created : ' +JSON.stringify(errors));
            if(errors.rows==undefined || errors.rows==null ){
                errors = { rows: { }, table: {} }
            } 
            console.log('errors created 2 : ' +JSON.stringify(errors));
            errors.rows[num] = { title: 'We found an error.', 
                                messages: [msg],
                                fieldNames: ['EligibleRedemptionAmount', 'nullredemptionamt']};
            errors.table.title = "Your entry cannot be saved.";
            errors.table.messages = "Fix the above highlighted errors and try again.";
            console.log('errors created 3 : ' +JSON.stringify(errors));
            cmp.set("v.errors", errors);
        }
        if(0 > draftValues[0].nullredemptionamt){
            var msg = 'Redemption Amount cannot be negative. Please re-enter the amount and click on save again';
            var errors = cmp.get("v.errors");
            console.log('errors created : ' +JSON.stringify(errors));
            if(errors.rows==undefined || errors.rows==null ){
                errors = { rows: { }, table: {} }
            } 
            console.log('errors created 2 : ' +JSON.stringify(errors));
            errors.rows[num] = { title: 'We found an error.', 
                                messages: [msg],
                                fieldNames: ['EligibleRedemptionAmount', 'nullredemptionamt']};
            errors.table.title = "Your entry cannot be saved.";
            errors.table.messages = "Fix the above highlighted errors and try again.";
            console.log('errors created 3 : ' +JSON.stringify(errors));
            cmp.set("v.errors", errors);
        }
    }
})