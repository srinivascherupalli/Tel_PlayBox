/*******************************************************************
    EDGE        : 114139, 114433
    Component   : DelegatedPricingSelectProduct & Hardware Options
    Description : Delegated Pricing select Product component.
    Author      : T Badri Narayan Subudhi
    **********************************************************************/
({
    doInit : function(component, event, helper) { 
        component.set("v.enableGetDealButton",true);
        component.set("v.setValueInRecon",true);
        component.set("v.DPRId",component.get("v.DPRId"));
        helper.fetchMarketableOptions(component, event);
        //Added by Rishabh : Platform event listner error handler start
        // Get the empApi component
        const empApi = component.find('empApi');
        // Register error listener and pass in the error handler function
        empApi.onError($A.getCallback(error => {
            // Error can be any type of error (subscribe, unsubscribe...)
        }));
        //Added by Rishabh : Platform event listner error handler end 
        /*
         * #Manish:-Changes For Edit Screen
         * */
        debugger;
        var isEditMode=component.get("v.Mode");
        var isViewMode=component.get("v.View");
        var comPlan = component.get("v.Selectedcommitteddata");
        var selProduct = component.get("v.SelectedProduct");
        var selOffer = component.get("v.SelectedOfferType");
        if(selProduct == '' || selProduct == 'Select Product'){
            component.set("v.SelectedProduct",'Select Product');
        }
        if(selOffer == '' || selOffer == 'Select Offer Type'){
            component.set("v.SelectedOfferType",'Select Offer Type');
        }
        if(comPlan == '' || comPlan == 'Select committed data'){
            component.set("v.Selectedcommitteddata",'Select committed data');
        }
        if(isEditMode){
            helper.getMinMaxDiscountValuesHelper(component, event);
            helper.getPickValues(component, event);
            helper.editScreenHelper(component, event);
        }
        if(isViewMode){
            helper.getMinMaxDiscountValuesHelper(component, event);
            helper.getPickValues(component, event);
            helper.editScreenHelper(component, event);
        }
    },
    
    openGbbScale : function(component, event, helper){ 
        component.set("v.showScale",true);
    },
    /* EDGE 114433 : Added for displaying Hardware Option on select of product. */ 
    SelectProduct : function(component, event, helper) {
        var selectProd=component.find("test").get("v.value");
        var selectProdId=component.find("test").get("v.value");
        component.set("v.SelectedProduct",selectProd);
        component.set("v.SelectedProductId",selectProdId);
        component.set("v.enableSaveButton",false);
        helper.checkOfferTypeValues(component, event, helper); 
        helper.getPickValues(component, event);
        if(selectProd==''){
            component.set("v.boolean", false);
        }
        else{
            component.set("v.boolean", true); 
        }
    },
    /* EDGE:117701 : Fetching user selected committed data plan */
    Selectedcommitteddata:function(component, event, helper) {
        component.set("v.enableSaveButton",false);
        var Selectedcommitteddata=component.find("Committed").get("v.value");
        component.set("v.Selectedcommitteddata",Selectedcommitteddata);
        var committeddata=component.find("Committed");
    
       //EDGE-145563 : Call helper for committed data plan charge -->
        helper.getDataPlanCharge(component, event, helper);

    },
    /* EDGE 114433 : Fetching user selected hardware option & rendering next secton*/   
    selectedHardwareOpt : function(component, event, helper) {
        component.set("v.enableSaveButton",false);
        var hardwareOption=component.find("hardware").get("v.value");
        component.set("v.hardwareOpt",hardwareOption);
        if(hardwareOption !="" && hardwareOption != undefined && hardwareOption!="Select"){
            component.set("v.hardwareOptSelected",true);
        }
        else{
            component.set("v.hardwareOptSelected",false);
            component.set("v.offerSelected",false);
        } 
        
        var appEvent = $A.get("e.c:changeInHardwareOpt");
        appEvent.setParams({
            "hardwareOption" :hardwareOption });
        appEvent.fire();
    },
    /* Added to navigated back to home screen from detailed screen */
    navigateHome : function(component, event, helper) { 
        var dprId = component.get("v.DPRId");
        window.open('https://'+window.location.host+'/lightning/r/Delegated_Pricing_Request__c/'+dprId+'/view','_self');
    },
    
    pickfieldEvent : function(cmp, event,helper) {
        var pickfield=event.getParam("pickfield");
        cmp.set("v.pickfield", pickfield);
        helper.getDiscountVal(cmp, event,pickfield)
    },
    
    //Added by Rishabh   
    //EDGE:114439 - Method to Open Delegation Outcome Pop up table     
    OpenChildComponent : function(c, e, h) {
        c.set("v.DelegationOutcomeTable" , true);
    },
    
    //Added by Rishabh
    //EDGE:114439 - Method to Close Delegation Outcome Pop up table     
    CloseChildComponent : function(c, e, h) {
        c.set("v.DelegationOutcomeTable" , false);
    }, 
    
    //EDGE:120087 - Method to sendrequest and consume response from PRE
    getDealScoreFromPRE : function(component, event, helper) {
        component.set("v.showSpinner",true);
        //Added by Rishabh: Platform event listner for offer level gbb
        // Get the empApi component
        const empApi = component.find('empApi');
        // Get the channel from the input box
        const channel = '/event/Delegated_Pricing__e';
        // Replay option to get new events
        const replayId = -1;
        // Subscribe to an event start
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            //Read Event Data
            var correlationID = eventReceived.data.payload.Correlation_ID__c;
            var delPricingReq = eventReceived.data.payload.Delegated_Pricing_Request__c;
            var dprGBBReportDetail = eventReceived.data.payload.DPR_GBB_Report_Detail__c;
            var dprDelOutcome = eventReceived.data.payload.DPR_Delegation_Outcome__c;
            var dprOffer = eventReceived.data.payload.DPR_Offer__c;
            var dprOfferLineItem = eventReceived.data.payload.DPR_Offer_Line_Item__c;
            //Correlation Id
            var correId = component.get("v.CorrelationId");
            // If Event received fetch values from Required Object
            // && correlationID===correId
            if(eventReceived && correlationID===correId){
            component.set("v.showSpinner",true);
            var action3 = component.get("c.insertReceivedEventData");//call Megha's Method
            action3.setParams({DPRRecord: delPricingReq,
            DPROffer: dprOffer,
            DPROfferLineItem:dprOfferLineItem,
            DPRDelegationOutcome: dprDelOutcome,
            DPRGBBReportDetail: dprGBBReportDetail});//pass data received in event        
                         action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var response = response.getReturnValue();
                if(response === 'SUCCESS'){
                    helper.getDPRGBBScaleValues(component, event, helper);
                    helper.getFinDelOutcome(component, event, helper);
                    //Firing Event to render plan level Gbb Scale start-----------
                    var renderPlanGbbScaleEvent = $A.get("e.c:PLanLevelGbbRender"); 
                    renderPlanGbbScaleEvent.setParams({
                        "showHideScale" :true });
                    renderPlanGbbScaleEvent.fire();
                    //Firing Event to render plan level Gbb Scale end--------------
                    component.set("v.enableGetDealButton" , true);
                }
                else{
                    component.set("v.ErrorMsg" , 'System error. The request was unsuccessful, please contact administrator');
                    component.set("v.GBBErrorComp" , true);
                    component.set("v.showSpinner",false);
                }
                
            }
            else {
                component.set("v.ErrorMsg" , 'System error. The request was unsuccessful, please contact administrator');
                component.set("v.GBBErrorComp" , true);
                component.set("v.showSpinner",false);
            }
        })//action3.setcallback end
        $A.enqueueAction(action3);
        
        // Get the subscription that we saved when subscribing
        const subscription = component.get('v.subscription');
        //Unsubscribe from the event
        empApi.unsubscribe(subscription, $A.getCallback(unsubscribed => {
            // Confirm that we have unsubscribed from the event channel
            component.set('v.subscription', null);
        }));
        }
            else{
            component.set("v.ErrorMsg" , 'System error. The request was unsuccessful, please contact administrator');
            component.set("v.GBBErrorComp" , true);
            // Get the subscription that we saved when subscribing
            const subscription = component.get('v.subscription');
            //Unsubscribe from the event
            empApi.unsubscribe(subscription, $A.getCallback(unsubscribed => {
            // Confirm that we have unsubscribed from the event channel
            component.set('v.subscription', null);
        }));
        }
        }))
            
            //Subscribe to an event end
            .then(subscription => {
            // Confirm that we have subscribed to the event channel.
            // We haven't received an event yet.
            // Save subscription to unsubscribe later
            component.set('v.subscription', subscription);
        });   
            //Added by Rishabh: Platform event listner end
            
            //Added by Megha
            helper.getDealScoreFromPREHelperNew(component, event, helper);
            component.set("v.enableGetDealButton", true);
        },
            
            //Added by Megha
            // this function is automatic called by aura:waiting event  
           // showSpinner: function(component, event, helper) {
                // make Spinner attribute true for display loading spinner 
              //  component.set("v.Spinner", true); 
            //},
            
            // this function is automatic called by aura:doneWaiting event 
          //  hideSpinner : function(component,event,helper){
                // make Spinner attribute to false for hide loading spinner    
              //  component.set("v.Spinner", false);
           // },
            
            //Added by Rishabh
            //Method to Close GBB Error Pop up Component     
            CloseGBBErrorComponent : function(c, e, h) {
                c.set("v.GBBErrorComp" , false);
                c.set("v.enableGetDealButton",false);
                
            },
            closeNoMultipleOffer: function(c, e, h) {
                c.set("v.dontAllowSameOfferToBeAddedTwice", false);
                var dprId = c.get("v.DPRId");
                window.open('https://'+window.location.host+'/lightning/r/Delegated_Pricing_Request__c/'+dprId+'/view','_self');
                
            },
            
            /* EDGE:117703 Calling this function on click of save */ 
            upsertplanAndDiscount: function(component, event, helper) {
                component.set("v.showSpinner",true);
                component.set("v.GBBScale",false);
                component.set("v.DelegaionOutcomeButton",false);
                debugger;
                var lstDPROfferLineItemWrapper=component.get("v.lstDPROfferLineItemWrapper");
                var lstDPROfferLineItemWrapper2=component.get("v.lstDPROfferLineItemWrapper2");
                var stringOfLineItem = JSON.stringify(lstDPROfferLineItemWrapper);
                var stringOfLineItem2 = JSON.stringify(lstDPROfferLineItemWrapper2);
                if(lstDPROfferLineItemWrapper.length>0){
                    for (var i = 0; i < lstDPROfferLineItemWrapper.length; i++) {
                        var PlanType = lstDPROfferLineItemWrapper[i].PlanType;
                        var Plan = lstDPROfferLineItemWrapper[i].Qplan;
                        var ActivationSIo = lstDPROfferLineItemWrapper[i].ActivatedSIOs;
                        var RecontractingSIo = lstDPROfferLineItemWrapper[i].RecontractingSIOs;
                        
                        var IDDCallPackDiscount=lstDPROfferLineItemWrapper[i].IDDCallPackDiscount;
                        var MMCDiscount=lstDPROfferLineItemWrapper[i].MMCDiscount;
                        var ActivationCreditMonths = lstDPROfferLineItemWrapper[i].ActivationCreditsMonthsDiscount;
                        var RecontractingCreditsMonthsDiscount = lstDPROfferLineItemWrapper[i].RecontractingCreditsMonthsDiscount;
                        
                        var SelectPlan= "----Select Plan----";
                        var committedDataPlan = component.get("v.Selectedcommitteddata");
                        var offerType = component.get("v.SelectedOfferType");
                        if(offerType == 'Committed Data' && (committedDataPlan == null ||committedDataPlan == '' ||committedDataPlan == 'Select committed data')){
                            var  message='Kindly enter committed data plan for committed data offer type';
                            helper.showToastHelper(component,event,message,'warning');
                            return ;
                        }
                        if (Plan == '' || Plan == SelectPlan || Plan == null || Plan == 'undefined'){
                            var  message='Kindly enter Plan Type & Plan';
                            helper.showToastHelper(component,event,message,'warning');
                            return ;
                        }
                        if(ActivationSIo!='' && ActivationSIo!=null){
                            if(ActivationSIo < 0 || ActivationSIo > 10000){
                                var  message="Kindly enter ActivationSIo value in the range of 1 to 10000";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                            }
                            
                        }
                        if(RecontractingSIo!='' && RecontractingSIo!=null){
                            if(RecontractingSIo < 0 || RecontractingSIo > 10000){
                                var  message="Kindly enter RecontractingSIo value in the range of 1 to 10000";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                            }
                        }
                        
                        if ((ActivationSIo == '' && RecontractingSIo == '') || (ActivationSIo == null && RecontractingSIo == null) || (ActivationSIo == 'undefined' && RecontractingSIo == 'undefined') || (ActivationSIo == 0 && RecontractingSIo == 0)){
                            var  message='Please input Activation SIO or Re contracting SIO or both.';
                            helper.showToastHelper(component,event,message,'warning');
                            return ;
                        }
                        
                        if ((ActivationCreditMonths != ''&& ActivationCreditMonths != null && ActivationCreditMonths != 'undefined') && (ActivationSIo == '' || ActivationSIo == null || ActivationSIo == 'undefined')){    
                            var  message='Activation Credit Months discount can only be provided if Activation SIO is >0 for certain plan.';
                            helper.showToastHelper(component,event,message,'warning');
                            return ;
                        }
                        
                        if (( RecontractingCreditsMonthsDiscount != ''&& RecontractingCreditsMonthsDiscount != null && RecontractingCreditsMonthsDiscount != 'undefined') && (RecontractingSIo == '' || RecontractingSIo == null || RecontractingSIo == 'undefined' )){    
                            var  message='Recontracting Credit Months discount can only be provided if Recontractng SIO is >0 for certain plan.';
                            helper.showToastHelper(component,event,message,'warning');
                            return ;
                        }
                        
                        if(IDDCallPackDiscount!='' && IDDCallPackDiscount!=null){
                            debugger;
                            var IDDKey=PlanType+Plan+'IDD Call Pack Discount';
                            var disVal=component.get("v.mapOfMinMaxDiscountValues")[IDDKey];
                            var MinVal = parseFloat(disVal.MinVal);
                            var MaxVal = parseFloat(disVal.MaxVal);
                            if(IDDCallPackDiscount < MinVal || IDDCallPackDiscount > MaxVal){
                                var  message="Please enter a valid value. Refer Help text";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                                
                            }
                        }
                        
                        if(MMCDiscount!='' && MMCDiscount!=null){
                            debugger;
                            var MMCDKey=PlanType+Plan+'MMC Discount';
                            var disVal=component.get("v.mapOfMinMaxDiscountValues")[MMCDKey];
                            var MinVal = parseFloat(disVal.MinVal);
                            var MaxVal = parseFloat(disVal.MaxVal);
                            if(MMCDiscount < MinVal || MMCDiscount > MaxVal){
                                var  message="Please enter a valid value. Refer Help text";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                            }
                        }
                        
                        if(ActivationCreditMonths!='' && ActivationCreditMonths!=null){
                            var ACMKey=PlanType+Plan+'Activation Credits Months Discount';
                            var disVal=component.get("v.mapOfMinMaxDiscountValues")[ACMKey];
                            var MinVal = parseFloat(disVal.MinVal);
                            var MaxVal = parseFloat(disVal.MaxVal);
                            if(ActivationCreditMonths < MinVal || ActivationCreditMonths > MaxVal){
                                var  message="Please enter a valid value. Refer Help text";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                                
                            }
                        }
                        
                        if(RecontractingCreditsMonthsDiscount!='' && RecontractingCreditsMonthsDiscount!=null){
                            var RCMKey=PlanType+Plan+'Recontracting Credits Months Discount';
                            var disVal=component.get("v.mapOfMinMaxDiscountValues")[RCMKey];
                            var MinVal = parseFloat(disVal.MinVal);
                            var MaxVal = parseFloat(disVal.MaxVal);
                            if(RecontractingCreditsMonthsDiscount < MinVal || RecontractingCreditsMonthsDiscount > MaxVal){
                                var  message="Please enter a valid value. Refer Help text";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                            }
                        }
                    }
                    
                    
                    for (var i = 0; i < lstDPROfferLineItemWrapper.length; i++) {
                        var dublicateCount=0; 
                        var keyToStoreDublicates='Committed Data'+lstDPROfferLineItemWrapper[i].PlanType+lstDPROfferLineItemWrapper[i].Qplan;
                        if(keyToStoreDublicates!=''){
                            for (var j = 0; j < lstDPROfferLineItemWrapper.length; j++) {
                                var dublicateKey='Committed Data'+lstDPROfferLineItemWrapper[j].PlanType+lstDPROfferLineItemWrapper[j].Qplan;
                                if(keyToStoreDublicates==dublicateKey){
                                    dublicateCount++;
                                }
                                if(dublicateCount>1){
                                    var  message='Dublicate Plan Type & Plan for The Offer Type';
                                    helper.showToastHelper(component,event,message,'warning');
                                    return ;
                                }
                            }
                        }
                    }
                }
                
                //function to handel dublicate plan type & plans for the Offer Type
                if(lstDPROfferLineItemWrapper2.length>0){
                    for (var i = 0; i < lstDPROfferLineItemWrapper2.length; i++) {
                        var PlanType = lstDPROfferLineItemWrapper2[i].PlanType;
                        var Plan = lstDPROfferLineItemWrapper2[i].Qplan;
                        var ActivationSIo = lstDPROfferLineItemWrapper2[i].ActivatedSIOs;
                        var RecontractingSIo = lstDPROfferLineItemWrapper2[i].RecontractingSIOs;
                        
                        var IDDCallPackDiscount=lstDPROfferLineItemWrapper2[i].IDDCallPackDiscount;
                        var MMCDiscount=lstDPROfferLineItemWrapper2[i].MMCDiscount;
                        var ActivationCreditMonths = lstDPROfferLineItemWrapper2[i].ActivationCreditsMonthsDiscount;
                        var RecontractingCreditsMonthsDiscount = lstDPROfferLineItemWrapper2[i].RecontractingCreditsMonthsDiscount;
                        var SelectPlan= "----Select Plan----";
                        if (Plan == '' || Plan == SelectPlan || Plan == null || Plan == 'undefined'){
                            var  message='Kindly enter Plan Type & Plan';
                            helper.showToastHelper(component,event,message,'warning');
                            return ;
                        }
                        
                        if(ActivationSIo!='' && ActivationSIo!=null){
                            if(ActivationSIo < 0 || ActivationSIo > 10000){
                                var  message="Kindly enter ActivationSIo value in the range of 1 to 10000";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                            }
                            
                        }
                        
                        if(RecontractingSIo!='' && RecontractingSIo!=null){
                            if(RecontractingSIo < 0 || RecontractingSIo > 10000){
                                var  message="Kindly enter RecontractingSIo value in the range of 1 to 10000";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                            }
                        }
                        
                        if ((ActivationSIo == '' && RecontractingSIo == '') || (ActivationSIo == null && RecontractingSIo == null) || (ActivationSIo == 'undefined' && RecontractingSIo == 'undefined') || (ActivationSIo == 0 && RecontractingSIo == 0)){
                            var  message='Please input Activation SIO or Re contracting SIO or both.';
                            helper.showToastHelper(component,event,message,'warning');
                            return ;
                        }
                        if ((ActivationCreditMonths != ''&& ActivationCreditMonths != null && ActivationCreditMonths != 'undefined') && (ActivationSIo == '' || ActivationSIo == null || ActivationSIo == 'undefined')){   
                            var  message='Activation Credit Months discount can only be provided if Activation SIO is >0 for certain plan.';
                            helper.showToastHelper(component,event,message,'warning');
                            return ;
                        }
                        if (( RecontractingCreditsMonthsDiscount != ''&& RecontractingCreditsMonthsDiscount != null && RecontractingCreditsMonthsDiscount != 'undefined') && (RecontractingSIo == '' || RecontractingSIo == null || RecontractingSIo == 'undefined' )){    
                            var  message='Recontracting Credit Months discount can only be provided if Recontractng SIO is >0 for certain plan.';
                            helper.showToastHelper(component,event,message,'warning');
                            return ;
                        }
                        
                        if(IDDCallPackDiscount!='' && IDDCallPackDiscount!=null){
                            debugger;
                            var IDDKey=PlanType+Plan+'IDD Call Pack Discount';
                            var disVal=component.get("v.mapOfMinMaxDiscountValues")[IDDKey];
                            var MinVal = parseFloat(disVal.MinVal);
                            var MaxVal = parseFloat(disVal.MaxVal);
                            if(IDDCallPackDiscount < MinVal || IDDCallPackDiscount > MaxVal){
                                var  message="Please enter a valid value. Refer Help text";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                                
                            }
                        }
                        
                        if(MMCDiscount!='' && MMCDiscount!=null){
                            debugger;
                            var MMCDKey=PlanType+Plan+'MMC Discount';
                            var disVal=component.get("v.mapOfMinMaxDiscountValues")[MMCDKey];
                            var MinVal = parseFloat(disVal.MinVal);
                            var MaxVal = parseFloat(disVal.MaxVal);
                            if(MMCDiscount < MinVal || MMCDiscount > MaxVal){
                                var  message="Please enter a valid value. Refer Help text";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                            }
                        }
                        
                        if(ActivationCreditMonths!='' && ActivationCreditMonths!=null){
                            var ACMKey=PlanType+Plan+'Activation Credits Months Discount';
                            var disVal=component.get("v.mapOfMinMaxDiscountValues")[ACMKey];
                            var MinVal = parseFloat(disVal.MinVal);
                            var MaxVal = parseFloat(disVal.MaxVal);
                            if(ActivationCreditMonths < MinVal || ActivationCreditMonths > MaxVal){
                                var  message="Please enter a valid value. Refer Help text";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                                
                            }
                        }
                        
                        if(RecontractingCreditsMonthsDiscount!='' && RecontractingCreditsMonthsDiscount!=null){
                            var RCMKey=PlanType+Plan+'Recontracting Credits Months Discount';
                            var disVal=component.get("v.mapOfMinMaxDiscountValues")[RCMKey];
                            var MinVal = parseFloat(disVal.MinVal);
                            var MaxVal = parseFloat(disVal.MaxVal);
                            if(RecontractingCreditsMonthsDiscount < MinVal || RecontractingCreditsMonthsDiscount > MaxVal){
                                var  message="Please enter a valid value. Refer Help text";
                                helper.showToastHelper(component,event,message,'warning');
                                return ;
                            }
                        }
                        
                        
                        
                    }
                    
                    for (var i = 0; i < lstDPROfferLineItemWrapper2.length; i++) {
                        var dublicateCount=0;
                        var keyToStoreDublicates='FairPlay Data'+lstDPROfferLineItemWrapper2[i].PlanType+lstDPROfferLineItemWrapper2[i].Qplan;
                        if(keyToStoreDublicates!=''){
                            for (var j = 0; j < lstDPROfferLineItemWrapper2.length; j++) {
                                var dublicateKey='FairPlay Data'+lstDPROfferLineItemWrapper2[j].PlanType+lstDPROfferLineItemWrapper2[j].Qplan;
                                if(keyToStoreDublicates==dublicateKey){
                                    dublicateCount++;
                                }
                                if(dublicateCount>1){
                                    var  message='Dublicate Plan Type & Plan for The Offer Type';
                                    helper.showToastHelper(component,event,message,'warning');
                                    return ;
                                }
                            }
                        }
                    }
                } 
                var DPRId=component.get("v.DPRId");
                var DprOfferId=component.get("v.DprOfferId");
                var SelectedProduct=component.get("v.SelectedProduct");
                var hardwareOpt=component.get("v.hardwareOpt");
                var SelectedOfferType=component.get("v.SelectedOfferType");
                var Selectedcommitteddata=component.get("v.Selectedcommitteddata");
                if(SelectedOfferType=='Committed Data' && Selectedcommitteddata==''){
                    var  message='Kindly select Committed Data Plan for the Offer Type';
                    helper.showToastHelper(component,event,message,'warning');
                    return ;
                }
                var action = component.get("c.upsertDPROffer");
                action.setParams({
                    "DPRId":DPRId,
                    "DprOfferId":DprOfferId,
                    "selectedProduct":SelectedProduct,
                    "hardwareOption":hardwareOpt,
                    "offerType":SelectedOfferType,
                    "commitedDataPlan":Selectedcommitteddata
                });
                // set call back 
                action.setCallback(this, function(response) {
                    debugger;
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        var DprID= response.getReturnValue();
                        var dpr= component.get("v.DprOfferId");
                        if(dpr==""){
                            component.set("v.DprOfferId",DprID); 
                        }
                        var lstDPROfferLineItemWrapper=component.get("v.lstDPROfferLineItemWrapper");
                        var lstDPROfferLineItemWrapper2=component.get("v.lstDPROfferLineItemWrapper2");
                        var stringOfLineItem = JSON.stringify(lstDPROfferLineItemWrapper);
                        var stringOfLineItem2 = JSON.stringify(lstDPROfferLineItemWrapper2);
                        
                        
                        if(lstDPROfferLineItemWrapper.length>0){
                            helper.upsertPlanAndDiscountHelper(component, event);
                        }
                        if(lstDPROfferLineItemWrapper2.length>0){
                            helper.upsertPlanAndDiscountHelper2(component, event);
                        }
                        
                    }else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors){
                            if (errors[0] && errors[0].message){
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            },
            /*EDGE:117703 Created event action to enable/disable save button & get deal score button */ 
            SaveCHeck: function(component, event, helper) {
                component.set("v.enableSaveButton",false);
                component.set("v.enableGetDealButton",true);
            },
            
            /*EDGE:114434: Created event action to fire wrapper on new row creation */
            addNewRow: function(component, event, helper) {
                debugger;
                // call the comman "createObjectData" helper method for add new Object Row to List 
                var Id = event.getSource().getLocalId();
                if(Id=='CommittedDataIterateId'){
                    helper.createObjectData(component, event);
                }else if(Id=='FairplayDataIterateId'){
                    helper.createObjectData2(component, event);
                }
                
            },
            /*EDGE:114434: Created event action to delete entire row */
            removeDeletedRow: function(component, event, helper) {
                var index = event.getParam("indexVar");
                var Id = event.getSource().getLocalId();
                if(Id=='CommittedDataIterateId'){
                    var AllRowsList1 = component.get("v.lstDPROfferLineItemWrapper");
                    AllRowsList1.splice(index, 1);
                    component.set("v.lstDPROfferLineItemWrapper", AllRowsList1);
                    var lstDPROfferLineItemWrapper = component.get("v.lstDPROfferLineItemWrapper");
                    if(lstDPROfferLineItemWrapper.length==0){
                        component.set("v.CommittedDataPlan",false);
                        component.set("v.Selectedcommitteddata",'Select committed data');
                       // component.find("Committed").set("v.value",'');
                    }
                }else if(Id=='FairplayDataIterateId'){
                    var AllRowsList2 = component.get("v.lstDPROfferLineItemWrapper2");
                    AllRowsList2.splice(index, 1);
                    component.set("v.lstDPROfferLineItemWrapper2", AllRowsList2);
                }
                component.set("v.GBBScale",false);
                component.set("v.DelegaionOutcomeButton",false);
                //Firing Event to render plan level Gbb Scale start-----------
                var renderPlanGbbScaleEvent = $A.get("e.c:PLanLevelGbbRender"); 
                renderPlanGbbScaleEvent.setParams({
                    "showHideScale" :false });
                renderPlanGbbScaleEvent.fire();
                
            },
            
            /*EDGE:114435 & 117701 : Added to iterate child component on click of Add offer */ 
            AddOffer : function(component, event, helper) {
                debugger;
                helper.getMinMaxDiscountValuesHelper(component,event);
                
                var selectedOffer=component.find("offer").get("v.value");
                component.set("v.SelectedOfferType",selectedOffer);
                component.set("v.offerSelected",true);
                component.set("v.offerOptionSelected",true);
                
                if(selectedOffer!=''){
                    if(selectedOffer=='Committed Data'){
                        var selectOfferType=component.find("offer").get("v.value");
                        var committedDataPlanValues=component.get("v.mapOfCmdPlanVsOffer")[selectOfferType];
                        component.set("v.getcommitteddata" ,committedDataPlanValues);
                        component.set("v.CommittedDataPlan",true);
                    }
                    
                    if(selectedOffer=='Committed Data'){
                        var RowItemList = component.get("v.lstDPROfferLineItemWrapper");
                        if(RowItemList.length == 0){
                            helper.createObjectData(component, event);
                        }else{
                            var  message='Committed Offer Type has already been added, Please add new plan to progress.';
                            helper.showToastHelper(component,event,message,'warning');
                        }
                    }
                    
                    if(selectedOffer=='FairPlay Data'){
                        var RowItemList = component.get("v.lstDPROfferLineItemWrapper2");
                        if(RowItemList.length == 0){
                            helper.createObjectData2(component, event);
                        }else{
                            var  message='Fairplay Offer Type has already been added, Please add new plan to progress.';
                            helper.showToastHelper(component,event,message,'warning');
                        }
                    }
                }else{
                    var  message='Please Select Offer Type to Add Or Delete Offer';
                    helper.showToastHelper(component,event,message,'warning');
                }
            },
            /*EDGE:119320 : to check if duplicate plan value is selected or not */
            handelDublicatePlans:function(component, event, helper){
                debugger;
                helper.handelDublicatePlansHelper(component, event);
            },
            /*EDGE:122835: Created to allow user to add offer & delete offer on click of buttons */ 
            confirmDeleteOffer: function(component) {
                $A.createComponent("c:OverlayLibraryModal", {},
                                   function(content, status) {
                                       if (status === "SUCCESS") {
                                           var modalBody = content;
                                           component.find('overlayLib').showCustomModal({
                                               header: "Are you sure to delete this Plans?",
                                               body: modalBody, 
                                               showCloseButton: false,
                                               closeCallback: function(ovl) {
                                                   
                                               }
                                           }).then(function(overlay){
                                               
                                           });
                                       }
                                   });
            },
            /*EDGE:122835: Created to allow user to add offer & delete offer on click of confirm on modal */
            confirmDeleteOfferEvent : function(component, event, helper) {
                var message = event.getParam("message");
                if(message == 'Ok'){
                    // if the user clicked the OK button do your further Action here
                    helper.ConfirmdeleteOfferHelper(component, event);
                    component.set("v.GBBScale",false);
                    component.set("v.Selectedcommitteddata",'Select committed data');
                    component.set("v.DelegaionOutcomeButton",false);
                    //Firing Event to render plan level Gbb Scale start-----------
                    var renderPlanGbbScaleEvent = $A.get("e.c:PLanLevelGbbRender"); 
                    renderPlanGbbScaleEvent.setParams({
                        "showHideScale" :false });
                    renderPlanGbbScaleEvent.fire();
                }
                else if(message == 'Cancel'){
                    // if the user clicked the Cancel button do your further Action here for canceling
                    
                }
            },
            
            handleComponentEvent : function(component, event, helper){ 
                var localVar=component.find("callChild");
                for(var i=0; i<localVar.length; i++){
                    localVar[i].sampleMethod();
                }
            },
            
            //EDGE:130899 - Gbb Scale hover functionality
            hoverFunction : function(component, event, helper){
                var list = component.get("v.GBBList");
                if(list !== null){
                    //------------------------------GBBScale hover start-------------------------
                    var el = component.find('GBBScale').getElement();
                    var ctx = el.getContext('2d');
                    //To clear the canvas on consecutive calls
                    ctx.clearRect(0,0,el.width,el.height);
                    //DPR Values assignment
                    var offerPrice = list.ActualOfferPrice__c;
                    var T1 = list.PoorMinimalValue__c;
                    var T2 = list.MinimalMarginalValue__c;
                    var T3 = list.MarginalGoodValue__c;
                    var T4 = list.GoodBetterValue__c;
                    var T5 = list.BetterBestValue__c;
                    var T6 = list.BestMaxValue__c;
                    //Footer display values
                    var D2 = (T2/1000).toFixed(2);
                    var D3 = (T3/1000).toFixed(2);
                    var D4 = (T4/1000).toFixed(2);
                    var D5 = (T5/1000).toFixed(2);
                    var OPD = (offerPrice/1000).toFixed(2);
                    var Total = T6 - T1;
                    //Red
                    var r1 = 0;
                    var r2 = 32;
                    var r3 = (((T2-T1)/Total)*500);//variable red length
                    
                    var r4 = 20;
                    //Orange
                    var o1 = r3;
                    var o2 = 32;
                    var o3 = (((T3-T2)/Total)*500);//variable orange length
                    
                    var o4 = 20;
                    //Yellow
                    var y1 = r3+o3;
                    var y2 = 32;
                    var y3 = (((T4-T3)/Total)*500);//variable yellow length
                    
                    var y4 = 20;
                    //Green
                    var g1 = r3+o3+y3;
                    var g2 = 32;
                    var g3 = (((T5-T4)/Total)*500);//variable green length
                    
                    var g4 = 20;
                    //Pigment green
                    var p1 = r3+o3+y3+g3;
                    var p2 = 32;
                    var p3 = (((T6-T5)/Total)*500);//variable pigment green length
                    
                    var p4 = 20;
                    //Black pointer
                    var b1,b2,b3,b4;
                    
                    if(offerPrice <= T1){
                        b1 = 0;
                        b2 = 32;
                        b3 = 3;
                        b4 = 20;
                        //Text header starts
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("Offer $"+OPD+"k", b1, 30);
                        //Text header stops
                    }
                    
                    if(offerPrice >= T6){
                        b1 = 497;
                        b2 = 32;
                        b3 = 3;
                        b4 = 20;
                        //Text header starts
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("Offer $"+OPD+"k", b1-55, 30);
                        //Text header stops
                    }
                    
                    if(offerPrice > T1 && offerPrice < T6){
                        b1 = (((offerPrice-T1)/Total)*500);
                        console.log('b1 '+b1);
                        b2 = 32;
                        b3 = 3;
                        b4 = 20;
                        if(b1 <= 445){                
                            //Text header starts
                            ctx.font = "10px Sans-Serif";
                            ctx.fillText("Offer $"+OPD+"k", b1, 30);
                            //Text header stops
                        }
                        if(b1 > 445){                
                            //Text header starts
                            ctx.font = "10px Sans-Serif";
                            ctx.fillText("Offer $"+OPD+"k", 442, 30);
                            //Text header stops
                        }
                    }
                    
                    //coloured scale start
                    ctx.fillStyle = "#D90F02";//red
                    ctx.fillRect(r1, r2, r3, r4);
                    ctx.fillStyle = "#F7B112";//orange
                    ctx.fillRect(o1, o2, o3, o4);
                    ctx.fillStyle = "#F7E01E";//yellow
                    ctx.fillRect(y1, y2, y3, y4);
                    ctx.fillStyle = "#9BEE6C";//green
                    ctx.fillRect(g1, g2, g3, g4);
                    ctx.fillStyle = "#2DAB5B";//pigment green
                    ctx.fillRect(p1, p2, p3, p4);
                    ctx.fillStyle = "#000502";//black
                    ctx.fillRect(b1, b2, b3, b4);
                    //coloured scale end
                    
                    //upfacing triangle footer start
                    //triangle 1
                    if(r3!==0 && o1<499){
                        console.log('r3 '+r3);
                        console.log('o1 '+o1);
                        ctx.beginPath();
                        ctx.moveTo(o1, 52);
                        ctx.lineTo(o1-2, 57);
                        ctx.lineTo(o1+2, 57);
                        ctx.closePath();
                        ctx.fillStyle = "#000502";
                        ctx.fill();
                    }
                    //triangle 2
                    if(o3!==0 && y1<499){
                        console.log('o3 '+o3);
                        console.log('y1 '+y1);
                        ctx.beginPath();
                        ctx.moveTo(y1, 52);
                        ctx.lineTo(y1-2, 57);
                        ctx.lineTo(y1+2, 57);
                        ctx.closePath();
                        ctx.fillStyle = "#000502";
                        ctx.fill();
                    }
                    //triangle 3
                    if(y3!==0 && g1<499){
                        console.log('y3 '+y3);
                        console.log('g1 '+g1);
                        ctx.beginPath();
                        ctx.moveTo(g1, 52);
                        ctx.lineTo(g1-2, 57);
                        ctx.lineTo(g1+2, 57);
                        ctx.closePath();
                        ctx.fillStyle = "#000502";
                        ctx.fill();
                    }
                    //triangle 4
                    if(g3!==0 && p1<499){
                        console.log('g3 '+g3);
                        console.log('p1 '+p1);
                        ctx.beginPath();
                        ctx.moveTo(p1, 52);
                        ctx.lineTo(p1-2, 57);
                        ctx.lineTo(p1+2, 57);
                        ctx.closePath();
                        ctx.fillStyle = "#000502";
                        ctx.fill();
                    }
                    //upfacing triangle footer end
                    
                    //Text footer starts
                    //Text 1
                    if(r3!==0 && o1<499){
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("$"+D2+"k", o1, 67);
                    }
                    //Text 2
                    if(o3!==0 && y1<499){
                        if(o3 > 40){
                            ctx.font = "10px Sans-Serif";
                            ctx.fillText("$"+D3+"k", y1, 67);
                        }
                        if(o3 < 40){
                            ctx.font = "10px Sans-Serif";
                            ctx.fillText("$"+D3+"k", y1, 77);
                        }
                    }
                    //Text 3
                    if(y3!==0 && g1<499){
                        if(y3 > 40){
                            ctx.font = "10px Sans-Serif";
                            ctx.fillText("$"+D4+"k", g1, 67);
                        }
                        if(o3 > 40 && y3 < 40){
                            ctx.font = "10px Sans-Serif";
                            ctx.fillText("$"+D4+"k", g1, 77);
                        }
                        if(o3 < 40 && y3 < 40){
                            ctx.font = "10px Sans-Serif";
                            ctx.fillText("$"+D4+"k", g1, 87);
                        }
                    }
                    //Text 4
                    if(g3!==0 && p1<499){
                        if(g3 > 40){
                            ctx.font = "10px Sans-Serif";
                            ctx.fillText("$"+D5+"k", p1, 67);
                        }
                        if(y3 > 40 && g3 < 40){
                            ctx.font = "10px Sans-Serif";
                            ctx.fillText("$"+D5+"k", p1, 77);
                        }
                        if(o3 > 40 && y3 < 40 && g3 < 40){
                            ctx.font = "10px Sans-Serif";
                            ctx.fillText("$"+D5+"k", p1, 87);
                        }
                        if(o3 < 40 && y3 < 40 && g3 < 40){
                            ctx.font = "10px Sans-Serif";
                            ctx.fillText("$"+D5+"k", p1, 97);
                        }
                    }
                    //Text footer ends
                    
                    //-------------------------------GBBScale hover end----------------------------- 
                    //hover part start  
                    var BB = el.getBoundingClientRect();
                    var offsetX = BB.left;
                    var offsetY = BB.top;
                    
                    var posx = event.clientX - offsetX +1;
                    var posy = event.clientY - offsetY +1;  
                    console.log('X='+posx+' Y='+posy);
                    
                    if(posx>b1 && posx<b1+4 && posy>35 && posy<52){
                        //Red part hover
                        if(posx>0 && posx<r3 && posy>35 && posy<52){
                            ctx.font = "21px Sans-Serif";
                            ctx.fillText("Offer:"+"$"+OPD+"k"+", is Poor.", 155, 21);   
                        }
                        
                        //Orange part hover
                        if(posx>r3 && posx<y1 && posy>35 && posy<52){
                            ctx.font = "21px Sans-Serif";
                            ctx.fillText("Offer:"+"$"+OPD+"k"+", is Marginal.", 155, 21);
                            console.log('else');    
                        }
                        
                        //Yellow part hover
                        if(posx>y1 && posx<g1 && posy>35 && posy<52){
                            ctx.font = "21px Sans-Serif";
                            ctx.fillText("Offer:"+"$"+OPD+"k"+", is Good.", 155, 21);    
                        }
                        
                        //Green part hover
                        if(posx>g1 && posx<p1 && posy>35 && posy<52){
                            ctx.font = "21px Sans-Serif";
                            ctx.fillText("Offer:"+"$"+OPD+"k"+", is Better.", 155, 21);    
                        }
                        
                        //Dark Green part hover
                        if(posx>p1 && posx<500 && posy>35 && posy<52){
                            ctx.font = "21px Sans-Serif";
                            ctx.fillText("Offer:"+"$"+OPD+"k"+", is Best.", 155, 21);
                        }
                    }
                    else{
                        //Red part hover
                        if(posx>0 && posx<r3 && posy>35 && posy<52){
                            ctx.font = "21px Sans-Serif";
                            ctx.fillText("Poor", 0, 21);   
                        }
                        
                        //Orange part hover
                        if(posx>r3 && posx<y1 && posy>35 && posy<52){
                            if(r3>460){
                                ctx.font = "21px Sans-Serif";
                                ctx.fillText("Marginal", 460, 21);
                            }
                            else{
                                ctx.font = "21px Sans-Serif";
                                ctx.fillText("Marginal", r3, 21);
                            }
                        }
                        
                        //Yellow part hover
                        if(posx>y1 && posx<g1 && posy>35 && posy<52){
                            if(y1>460){
                                ctx.font = "21px Sans-Serif";
                                ctx.fillText("Good", 460, 21);
                            }
                            else{
                                ctx.font = "21px Sans-Serif";
                                ctx.fillText("Good", y1, 21);
                            }
                        }
                        
                        //Green part hover
                        if(posx>g1 && posx<p1 && posy>35 && posy<52){
                            if(g1>460){
                                ctx.font = "21px Sans-Serif";
                                ctx.fillText("Better", 460, 21);
                            }
                            else{
                                ctx.font = "21px Sans-Serif";
                                ctx.fillText("Better", g1, 21);
                            }
                        }
                        
                        //Dark Green part hover
                        if(posx>p1 && posx<500 && posy>35 && posy<52){
                            if(p1>460){
                                ctx.font = "21px Sans-Serif";
                                ctx.fillText("Best", 460, 21);
                            }
                            else{
                                ctx.font = "21px Sans-Serif";
                                ctx.fillText("Best", p1, 21);
                            }
                        }
                    }
                }
            },
        })