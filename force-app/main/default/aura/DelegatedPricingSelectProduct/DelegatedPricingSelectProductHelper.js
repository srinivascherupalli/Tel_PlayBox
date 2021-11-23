/*******************************************************************
    EDGE        : 114139, 114433
    Component   : DelegatedPricingSelectProduct & Hardware Options
    Description : Delegated Pricing select Product component.
    Author      : T Badri Narayan Subudhi
    **********************************************************************/
({
    /*EDGE:114434,114433,117701 Created Common function to fetch picklist values */
    getPickValues : function(component,event) {
        debugger;
        var selectedProduct=component.get("v.SelectedProduct");
        var actionPicklistvalues = component.get("c.fetchPickValues");
        actionPicklistvalues.setParams({selectedProduct:component.get("v.SelectedProduct")});
        actionPicklistvalues.setCallback(this, function(response) {
           var state = response.getState();
            if (state === "SUCCESS") {
                console.log('inside success');
                var res=response.getReturnValue();
                var mapOfOfferTypeVsProduct=res.mapOfOfferTypeVsProduct;
                component.set("v.mapOfOfferTypeVsProduct",mapOfOfferTypeVsProduct);
                var mapOfCmdPlanVsOffer=res.mapOfCmdPlanVsOffer;
                component.set("v.mapOfCmdPlanVsOffer",mapOfCmdPlanVsOffer);
                var mapOfPlanTypeVsOffer=res.mapOfPlanTypeVsOffer;
                component.set("v.mapOfPlanTypeVsOffer",mapOfPlanTypeVsOffer);
                var mapOfcmdPlanVsPtype=res.mapOfcmdPlanVsPtype;
                component.set("v.mapOfcmdPlanVsPtype",mapOfcmdPlanVsPtype);
                var mapOfAddOn=res.mapOfAddOn;
                component.set("v.mapOfAddOn",mapOfAddOn);
                
                
                //set offer type values
                var SelectedProduct=component.get("v.SelectedProduct");
                var OfferTypeValues=component.get("v.mapOfOfferTypeVsProduct")[SelectedProduct];
                component.set("v.OfferType", OfferTypeValues);
                component.set("v.SuccessLoading",true);
              }else if(state === "INCOMPLETE") {}
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });      
        $A.enqueueAction(actionPicklistvalues);
    },
    //get min max values for applicable discount
    getMinMaxDiscountValuesHelper: function(component,event){
        debugger;
        var action=  component.get("c.fetchMinMaxValuesForDiscounts"); 
        action.setCallback(this,function(response){ 
            debugger;
            var state=response.getState();  
            if(state==='SUCCESS'){
                var res=response.getReturnValue();
                component.set("v.mapOfMinMaxDiscountValues",res);
            }else if (state === "INCOMPLETE") {
            }else if (state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error message: " + errors[0].message);
                    }
                }else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
     /*EDGE:114434 Added to fetch product and store in a map */
    getMapOfMarketableOffers: function(component, event, helper) {
        var action=  component.get('c.getMapOf_M_O_Detailes'); 
        action.setCallback(this,function(response){ 
            var arrayToStoreMO=[];  // Declaring array to store values.
            var state=response.getState();  
            var res=response.getReturnValue();
            if(state==='SUCCESS'){
                component.set('v.mapOfMarketableOffer',res.getReturnValue());  // Storing response in map.
            }
            for(var key in res){     
                arrayToStoreMO.push(mapOfMarketableOffer[key]);   // Pushing keys in array
            }
            component.set('v.lstOfMarketableOffer',arrayToStoreMO); // Storing keys in list.
        });
        $A.enqueueAction(action);
    },
    /* EDGE:114435 : Added for fetching offer type values */
    checkOfferTypeValues : function(component,event) {
        debugger;
        console.log('call inside helper----');
        var action = component.get("c.fetchDPROffer");
        console.log('DPRId ###'+component.get("v.DPRId"));
        var product = component.get("v.SelectedProduct");
        var dprId = component.get("v.DPRId");
        action.setParams ({selectedProduct : component.get("v.SelectedProduct"),
                           DPRId : component.get("v.DPRId") });
        
        action.setCallback (this, function(response) {
            debugger;
            var state = response.getState();
          //  var offerTypeVal=[];
           if (state === "SUCCESS") {
                console.log('offer type---',response.getReturnValue());
                var listOffer=response.getReturnValue();
               // alert('offer type---',listOffer);
                if(listOffer.length > 0){
                    var isEditMode=component.get("v.Mode");
                    var isViewMode=component.get("v.View");
                    if(isEditMode || isViewMode){
                        component.set("v.dontAllowSameOfferToBeAddedTwice" , false);
                    }else{
                        component.set("v.dontAllowSameOfferToBeAddedTwice" , true);
                    }
                }
                
            } 
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
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
    
    /*EDGE:114434 Added to fetch product for whom delegated pricing is enabled */
    fetchMarketableOptions : function(component,event) {
        var markitableAction = component.get("c.getMarketableofferDetailes");
        // Create a callback that is executed after the server-side markitableAction returns
        markitableAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set("v.MarketableOffer",response.getReturnValue());
                 //fire a event here to trigger client-side notification that the server-side action is complete
            }
            else if (state === "INCOMPLETE") {
                toastEvent.setParams({
                    title : 'info',
                    message:'Delegated Pricing has not been enabled.Please Check With System Administrator',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });      
        // Optionally set storable, abortable, background flag here     
        // A client-side action could cause multiple events, which could trigger other events and other server-side action calls.
         $A.enqueueAction(markitableAction);
    },
    
    //EDGE:120087 - To send request to get deal score from PRE
    getDealScoreFromPREHelper: function(component,event) {
         var makePRECallout = component.get("c.getDealScoreFromPREServer");
        makePRECallout.setParams ({DPRId : component.get("v.DPRId"),
                                   correlationId : component.get("v.CorrelationId")});
        // Create a callback that is executed after the server-side makePRECallout returns
        makePRECallout.setCallback(this, function(response) {
            var state = response.getState();
           if (state === "SUCCESS") {
                var response = response.getReturnValue();
              if(response[0] != ''){
                 }
                else{
                    component.set("v.GBBErrorComp" , true);
                    component.set("v.ErrorMsg" , response[1]);
                }
            }else if (state === "INCOMPLETE") {
                component.set("v.ErrorMsg" , 'System error. The request was unsuccessful, please contact administrator');
                component.set("v.GBBErrorComp" , true);
            }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            component.set("v.ErrorMsg" , 'System error. The request was unsuccessful, please contact administrator');
                			component.set("v.GBBErrorComp" , true);
                		 }
                    } else {
                       component.set("v.ErrorMsg" , 'System error. The request was unsuccessful, please contact administrator');
                		component.set("v.GBBErrorComp" , true);
                	 }
                }
        }); 
        $A.enqueueAction(makePRECallout);
    },
    
    
    //EDGE-118371 - To get Gbb Scale values from DPR Offer
    getDPRGBBScaleValues : function(component,event) {
         //component.set("v.showSpinner",true);
         //Show GBB Scale
        component.set("v.GBBScale", true);
        var dprId = component.get("v.DPRId");
       var action = component.get("c.getDPROfferDetails");
        action.setParams({dprOfferId: dprId}); //pass dpr id
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var list = response.getReturnValue();
                component.set("v.GBBList", list);
                //------------------------------GBBScale start-------------------------
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
                // component.set("v.showSpinner",false);
                //Text footer ends
                //-------------------------------GBBScale end-----------------------------
                component.set("v.showSpinner",false);
                if(list != null && list.ActualOfferPrice__c == null){
                   component.set("v.GBBScale", false);
                }
            }
            else {
                console.log("Failed with state: " + state);
                component.set("v.GBBScale", false);
               component.set("v.showSpinner",false);
            }
        })
        $A.enqueueAction(action);
        
    },
    
    //EDGE-114439 - To get final Delegaion Outcome button color, value and delegation outcome table
    getFinDelOutcome : function(component,event) {
         var dprId = component.get("v.DPRId");//take the DPR id here
       var colour;//button colour
        //EDGE:114439
        //Call Apex controller method to get Delegation Outcome button colour
        //and Final Delegation Outcome display value 
        var action1 = component.get("c.getFinalDelegationOutcome");
        action1.setParams({
            dprID: dprId
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var list = response.getReturnValue();
               var fdo = list[0];
                colour = list[1];//button colour
                component.set("v.FinalDelegationOutcome", fdo);
                component.set("v.Colour", colour);
                if(fdo!=='null'){
                    component.set("v.DelegaionOutcomeButton", true);	
                }
                if(colour==='success'){
                    component.set("v.Green", true);
                    component.set("v.Table", false);
                }
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        })//action1.setcallback end
        $A.enqueueAction(action1);
        
        //Call Apex controller method to get the Delegation Outcome Pop up Table values List
        var action2 = component.get("c.getDelegationOutcomeTable");
        action2.setParams({
            dprID: dprId
        });        
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var list = response.getReturnValue();
                if(colour==='destructive'){
                    component.set("v.Table", true);
                    component.set("v.Green", false);
                    component.set("v.DelegationOutcomeList", list);
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        })
        $A.enqueueAction(action2);
    },
   /* EDGE:117703 Calling this function for creation of wrapper for committed data */  
   createObjectData: function(component, event) {
        debugger;
        //get the List from component and add(push) New Object to List  
        var RowItemList = component.get("v.lstDPROfferLineItemWrapper");
        RowItemList.push({
            'OfferType':'',
            'PlanId':'',
            'DPROfferId':'',
            'PlanType':'',
            'Qplan':'',
            'MMC':'',
            'ActivatedSIOs':'',
            'RecontractingSIOs':'',
            'MRO':false,
            'AddOn':'',
            'AddOnID':'',
            'IDDCallPackDiscount':'',
            'IDDCallPackDiscountID':'',
            'MobileWorkspaceDiscount1':'',
            'MobileWorkspaceDiscount1ID':'',
            'MobileWorkspaceDiscount3':'',
            'MobileWorkspaceDiscount3ID':'',
            'MobileWorkspaceDiscount2':'',
            'MobileWorkspaceDiscount2ID':'',
            'MMCDiscount':'',
            'MMCDiscountID':'',
            'MMCDiscountExGST':'',
            'ActivationCreditsMonthsDiscount':'',
            'ActivationCreditsMonthsDiscountID':'',
            'RecontractingCreditsMonthsDiscount':'',
            'RecontractingCMDiscountID':'',
            
            'MROBonusCredit':'',
            'MROBonusCreditID':'',
            'NationalBYODiscount':'',
            'NationalBYODiscountID':'',
            'GrossValue':'',
            'NetValue':'',
            'addOnCount':0
        });  
        component.set("v.lstDPROfferLineItemWrapper", RowItemList);
    },
  /* EDGE:117703 Calling this function for creation of wrapper for Fairplay data */  
  createObjectData2: function(component, event) {
        debugger;
        // get the List from component and add(push) New Object to List  
        var RowItemList = component.get("v.lstDPROfferLineItemWrapper2");
        RowItemList.push({
            'OfferType':'',
            'PlanId':'',
            'DPROfferId':'',
            'PlanType':'',
            'Qplan':'',
            'MMC':'',
            'ActivatedSIOs':'',
            'RecontractingSIOs':'',
            'MRO':false,
            'AddOn':'',
            'AddOnID':'',
            'IDDCallPackDiscount':'',
            'IDDCallPackDiscountID':'',
            'MobileWorkspaceDiscount1':'',
            'MobileWorkspaceDiscount1ID':'',
            'MobileWorkspaceDiscount3':'',
            'MobileWorkspaceDiscount3ID':'',
            'MobileWorkspaceDiscount2':'',
            'MobileWorkspaceDiscount2ID':'',
            'MMCDiscount':'',
            'MMCDiscountID':'',
            'MMCDiscountExGST':'',
            'ActivationCreditsMonthsDiscount':'',
            'ActivationCreditsMonthsDiscountID':'',
            'RecontractingCreditsMonthsDiscount':'',
            'RecontractingCMDiscountID':'',
            
            'MROBonusCredit':'',
            'MROBonusCreditID':'',
            'NationalBYODiscount':'',
            'NationalBYODiscountID':'',
            'GrossValue':'',
            'NetValue':'',
            'addOnCount':0
        });  
        component.set("v.lstDPROfferLineItemWrapper2", RowItemList);
    },
    
    //EDGE:120087 - Method to get unique generated correlation Id
     getDealScoreFromPREHelperNew: function(component,event) {
        //Call Apex controller method to generate and get Correlation ID
        var action2 = component.get("c.getDPRCorrelationID");  
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.CorrelationId",response.getReturnValue());
                this.getDealScoreFromPREHelper(component,event);
                component.set("v.showSpinner",false);
            }
            else {
               component.set("v.ErrorMsg" , 'System error. The request was unsuccessful, please contact administrator');
                component.set("v.GBBErrorComp" , true);
                component.set("v.showSpinner",false);
            }
        })
        $A.enqueueAction(action2);
        
    },
     /* EDGE:117703 Calling this function on click of save for committed data */ 
    upsertPlanAndDiscountHelper:function(component,event){
        debugger;
        component.set("v.showSpinner",true);
        var lstDPROfferLineItemWrapper=component.get("v.lstDPROfferLineItemWrapper");
        var stringOfLineItem = JSON.stringify(lstDPROfferLineItemWrapper);
        var SelectedProduct=component.get("v.SelectedProduct");
        var hardwareOpt=component.get("v.hardwareOpt");
        var SelectedOfferType='Committed Data';//component.get("v.SelectedOfferType");
        var Selectedcommitteddata=component.get("v.Selectedcommitteddata");
        var DPRId=component.get("v.DPRId");
        var marketableOfferId=component.get("v.marketableOfferId");
        var DprOfferId=component.get("v.DprOfferId");
        // Osaka
        var PlanData = component.find('DataPlanCharge').get('v.value');
        var action = component.get("c.upsertPlanAndDiscount");
        //console.log('----->PlanData_Zeeshan',PlanData);
        action.setParams({
            "listOfPlansAndDiscounts": stringOfLineItem,
            "selectedProduct":component.get("v.SelectedProduct"),
            "hardwareOption":component.get("v.hardwareOpt"),
            "offerType":SelectedOfferType,//component.get("v.SelectedOfferType"),
            "commitedDataPlan":component.get("v.Selectedcommitteddata"),
            "DPRId":component.get("v.DPRId"),
            "DprOfferId":component.get("v.DprOfferId")
        });
        // set call back 
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                var listOfPlansAndDiscounts= response.getReturnValue();
                component.set("v.lstDPROfferLineItemWrapper",listOfPlansAndDiscounts);
                var  message='Plans & Discounts are Succesfully save for offer Type:-Committed Data';
                this.showToastHelper(component,event,message,'success');
                component.set("v.enableGetDealButton",false);
                 component.set("v.showDiscountSection",true);
                component.set("v.enableSaveButton",true);
                 component.set("v.showSpinner",false);
            }else if (state === "ERROR") {
                component.set("v.showSpinner",false);
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
    /* EDGE:117703 Calling this function on click of save for Fairplay data */ 
    upsertPlanAndDiscountHelper2:function(component,event){
        component.set("v.showSpinner",true);
        debugger;
        var lstDPROfferLineItemWrapper2=component.get("v.lstDPROfferLineItemWrapper2");
        
        var stringOfLineItem2 = JSON.stringify(lstDPROfferLineItemWrapper2);
        var SelectedProduct=component.get("v.SelectedProduct");
        var hardwareOpt=component.get("v.hardwareOpt");
        var SelectedOfferType='FairPlay Data';//component.get("v.SelectedOfferType");
        var Selectedcommitteddata=component.get("v.Selectedcommitteddata");
        var DPRId=component.get("v.DPRId");
        var marketableOfferId=component.get("v.marketableOfferId");
        var DprOfferId=component.get("v.DprOfferId");
        var action = component.get("c.upsertPlanAndDiscount");
        action.setParams({
            "listOfPlansAndDiscounts": stringOfLineItem2,
            "selectedProduct":component.get("v.SelectedProduct"),
            "hardwareOption":component.get("v.hardwareOpt"),
            "offerType":SelectedOfferType,//component.get("v.SelectedOfferType"),
            "commitedDataPlan":component.get("v.Selectedcommitteddata"),
            "DPRId":component.get("v.DPRId"),
            "DprOfferId":component.get("v.DprOfferId")
        });
        //set call back
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                var listOfPlansAndDiscounts= response.getReturnValue();
                component.set("v.lstDPROfferLineItemWrapper2",listOfPlansAndDiscounts);
                var  message='Plans & Discounts are Succesfully save for offer Type:-FairPlay Data';
                this.showToastHelper(component,event,message,'success');
                component.set("v.enableGetDealButton",false);
                component.set("v.showDiscountSection",true);
                component.set("v.enableSaveButton",true);
                 component.set("v.showSpinner",false);
            }else if (state === "ERROR") {
                component.set("v.showSpinner",false);
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
    /*EDGE:122835 Created this function delete one entire offer on click of delete offer button*/ 
    deleteOfferHelper: function(component,event,LineItemWrapper) {
        debugger;
        var strLineItem = JSON.stringify(LineItemWrapper);
        var action = component.get("c.deleteOfferItems");  
        action.setParams({strLineItem:strLineItem});
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('responce'+response.getReturnValue());
                var selectedOffer=component.get("v.SelectedOfferType");
                if(selectedOffer=='Committed Data'){
                    component.set("v.lstDPROfferLineItemWrapper",[]);
                    component.set("v.CommittedDataPlan",false);
                    component.find("Committed").set("v.value",'');
                    
                }
                if(selectedOffer=='FairPlay Data'){
                    component.set("v.lstDPROfferLineItemWrapper2",[]);  
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
        })
        $A.enqueueAction(action);
    },
    /*EDGE:119320 : to check if duplicate plan value is selected or not */
     handelDublicatePlansHelper:function(component,event){
        debugger;
        var lstDPROfferLineItemWrapper=component.get("v.lstDPROfferLineItemWrapper");
        var lstDPROfferLineItemWrapper2=component.get("v.lstDPROfferLineItemWrapper2");
        
        if(lstDPROfferLineItemWrapper.length>0){
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
                            this.showToastHelper(component,event,message,'warning');
                            return ;
                        }
                    }
                }
            }
        }
        
        if(lstDPROfferLineItemWrapper2.length>0){
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
                            this.showToastHelper(component,event,message,'warning');
                            return ;
                        }
                    }
                }
            }
        }
    },
    /* Created common toast function to show toast messages */
    showToastHelper: function(component,event,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode:'sticky',
            message:message,
            type :type
        });
        toastEvent.fire();
    },
    /*EDGE:122835: Created to allow user to add offer & delete offer on click of buttons */
     ConfirmdeleteOfferHelper: function(component, event, helper){
                debugger;
                var selectedOffer=component.get("v.SelectedOfferType");
                if(selectedOffer!=''){
                    if(selectedOffer=='Committed Data'){
                        var lstDPROfferLineItemWrapper=component.get("v.lstDPROfferLineItemWrapper");
                        if(lstDPROfferLineItemWrapper.length>0){
                            this.deleteOfferHelper(component,event,lstDPROfferLineItemWrapper); 
                        }
                    }
                    if(selectedOffer=='FairPlay Data'){
                        var lstDPROfferLineItemWrapper2=component.get("v.lstDPROfferLineItemWrapper2");
                        if(lstDPROfferLineItemWrapper2.length>0){
                            this.deleteOfferHelper(component,event,lstDPROfferLineItemWrapper2);
                        }
                    }
                }else{
                    var  message='Please Select Offer Type to Add Or Delete Offer';
                    this.showToastHelper(component,event,message,'warning');
                }
            },
            
    /*EDGE: 117583 Created this function for edit screen */
    editScreenHelper:function(component,event){
        component.set("v.showSpinner",true);
        debugger;
        var DPROffer=component.get("v.DPROffer");
        var DPRId=component.get("v.DPRId");
        var action = component.get("c.getEditScreenWrapper");
        action.setParams({DPRId:DPRId,DPROfferId:DPROffer});
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                var res=response.getReturnValue();
                //set the value for product
                var product=res.product;
                component.set("v.SelectedProduct",product);
                //set DPR Id to avoide dublicate Offer From edit Screen
                var DPROfferId=res.DPROfferId;
                component.set("v.DprOfferId",DPROfferId);
                
                var selectProd=component.find("test").get("v.value");
                var selectProdId=component.find("test").get("v.value");
                component.set("v.SelectedProduct",product);
                component.set("v.SelectedProductId",selectProdId);
                 if(selectProd==''){
                    component.set("v.boolean", false);
                }
                else{
                    component.set("v.boolean", true); 
                }
                //set hardware option
                var hardwareOption=res.hardwareOption;
                component.find("hardware").set("v.value",hardwareOption);
                component.set("v.hardwareOptSelected",true);
                debugger;
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
                
                component.set("v.offerSelected",true);
                component.set("v.offerOptionSelected",true);
                
                var offerType=res.offerType;
                component.set("v.SelectedOfferType",offerType);
             
                var lstOfCDPlans=res.lstOfCDPlans;
                if(lstOfCDPlans.length>0){
                    component.set("v.SelectedOfferType",'Committed Data');
                    component.set("v.CommittedDataPlan",true);
                    var committedDataPlan=res.committedDataPlan;
                 //   component.find("Committed").set("v.value",committedDataPlan);
                    component.set("v.Selectedcommitteddata",committedDataPlan);
                    component.set("v.lstDPROfferLineItemWrapper",lstOfCDPlans);
                    var selectOfferType = component.get("v.SelectedOfferType");
                 var committedDataPlanValues=component.get("v.mapOfCmdPlanVsOffer")[selectOfferType];
                    component.set("v.getcommitteddata",committedDataPlanValues);
                  }
                var lstOfFDPlans=res.lstOfFDPlans;
                if(lstOfFDPlans.length>0){
                    component.set("v.lstDPROfferLineItemWrapper2",lstOfFDPlans);
                 }
               //get the GBB scale Data
                this.getDPRGBBScaleValues(component, event);
                this.getFinDelOutcome(component, event);
                //Firing Event to render plan level Gbb Scale start-----------
                var renderPlanGbbScaleEvent = $A.get("e.c:PLanLevelGbbRender");
                renderPlanGbbScaleEvent.setParams({
                                "showHideScale" :true });
                renderPlanGbbScaleEvent.fire();
                //Firing Event to render plan level Gbb Scale end--------------
                component.set("v.enableGetDealButton" , true);
               component.set("v.showSpinner",false);
            }
            else if (state === "INCOMPLETE") {}
                else if (state === "ERROR") {
                    component.set("v.showSpinner",false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
     //EDGE-145563 : Get committed data plan charge from  apex controller-->
     getDataPlanCharge : function(component, event, helper) {

        var action=component.get("c.fetchDataPlanCharge");
        action.setParams({"committedPlan":component.get("v.Selectedcommitteddata")});
        // define the callback and check the status ,
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                var result=response.getReturnValue();
                component.set("v.dataPlanCharge",result);
            }
        });
        $A.enqueueAction(action);
	}
    
    
    
    
})