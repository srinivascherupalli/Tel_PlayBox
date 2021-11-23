({
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    /* Common toast message */
    showToastHelper: function(component,event,message,type) {
        var message = {
            'displayMsg':message,
            'type' : type
        }
        var vfOrigin = $A.get("$Label.c.FAPostURL");
        window.postMessage(message, vfOrigin);
        window.close();
    },
    faStatusCheck : function(component, event, helper){
        var frameRecId = component.get("v.FrameId");
        var frameRecord = component.get("c.retrieveFrameRecord");
        frameRecord.setParams({FrameId:frameRecId});
        frameRecord.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responsenewFrame =response.getReturnValue();
                if((responsenewFrame.csconta__Status__c == 'Approved') || (responsenewFrame.csconta__Status__c == 'Sent for Approval')){
                    component.set("v.isStatusCheck",true);
                }
                if(responsenewFrame.csconta__Status__c != 'Draft'){//DIGI-5162
                    component.set("v.enableGetDealBtn", true);
                }
            }
        });
        $A.enqueueAction(frameRecord);
    },
    UpdateOfferLine: function(component, event){
        
        var planNDiscountList = component.get("v.DealListItems");
        
        component.set("v.showSpinner",true);
        var action = component.get("c.UpdateDPROfferLine");
        action.setParams({lineWrapList:planNDiscountList});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responsenew =response.getReturnValue();
                console.log("responsenew after save <><> "+responsenew);
                component.set("v.showSpinner",false);
                component.set("v.enableSaveButton",true);
                component.set("v.enableGetDealButton",false);
                
                var message = {
                    'displayMsg':'Successfully Update Offer Line Item Record',
                    'type' : 'SUCCESS'
                }
                var vfOrigin = $A.get("$Label.c.FAPostURL");
                window.postMessage(message, vfOrigin);
                event.preventDefault();
            }else if (state === "INCOMPLETE"){}
                else if (state === "ERROR"){
                    var errors = response.getError();
                    if (errors){
                        if (errors[0] && errors[0].message){
                            console.log("Error message: " + errors[0].message);
                            var message = {
                                'displayMsg':'errors[0].message',
                                'type' : 'ERROR'
                            }
                            var vfOrigin = $A.get("$Label.c.FAPostURL");
                            window.postMessage(message, vfOrigin);
                            window.close();
                        }
                    } else {
                        console.log("Unknown error");
                        var message = {
                            'displayMsg':'Unknown error',
                            'type' : 'ERROR'
                        }
                        var vfOrigin = $A.get("$Label.c.FAPostURL");
                        window.postMessage(message, vfOrigin);
                        window.close();
                    }
                }
        }); 
        $A.enqueueAction(action);
    },
    //------START of EDGE-185052 by Abhishek from Osaka Team ------//
    updateFA : function(component,event){
        var frameRecordId = component.get("v.FrameId");
        var actionNew = component.get("c.updatDPR");
        actionNew.setParams({frameId:frameRecordId});
        actionNew.setCallback(this, function(response) {
            var state = response.getState();
            console.log("Oppty Type <> "+response.getState());
            if (state === "SUCCESS") {
                var responsenew =response.getReturnValue();
                console.log("isMigration value"+JSON.stringify(responsenew));
                console.log("Before");
                //debugger;
                var message = {
                    'displayMsg':'Agreement Status set to Scored.',
                    'type' : 'SUCCESS'
                }
                window.postMessage(message,"*");
                console.log("After");
            }
        });
        $A.enqueueAction(actionNew);
    },
    //------END of EDGE-185052 by Abhishek from Osaka Team ------//
    //Method to get unique generated correlation Id
     getDealScoreFromPREHelperNew: function(component,event) {
        // debugger;
        //Call Apex controller method to generate and get Correlation ID
        var action2 = component.get("c.getDPRCorrelationID");  
        action2.setCallback(this, function(response) {
          //  debugger;
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
    //To send request to get deal score from PRE
    getDealScoreFromPREHelper: function(component,event) {
        debugger;
        console.log('makePRECallout <><helper>');
         var makePRECallout = component.get("c.getDealScoreFromPREServer");
        makePRECallout.setParams ({DPRId : component.get("v.DPRId"),
                                   correlationId : component.get("v.CorrelationId")});
        // Create a callback that is executed after the server-side makePRECallout returns
        makePRECallout.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            console.log('Response State '+state);
           if (state === "SUCCESS") {
                var response = response.getReturnValue();
               component.set("v.GBBScale", true);
               component.set("v.enableGetDealBtn", true);
              if(response[0] != ''){
                  //component.set("v.GBBErrorComp" , true);
                   // component.set("v.ErrorMsg" , response[1]);
                 }
                else{
                    component.set("v.GBBErrorComp" , true);
                    component.set("v.ErrorMsg" , 'An error occurred: ' + response[1] + ' Please try the action again. If there is still an issue, please contact support.');
                    component.set("v.enableGetDealBtn", false);
                }
            }else if (state === "INCOMPLETE") {
                //DIGI-2098
                component.set("v.ErrorMsg" , 'An error occurred. Please try the action again. If there is still an issue, please contact support.');
                component.set("v.GBBErrorComp" , true);
                component.set("v.enableGetDealBtn", false);
                component.set("v.showSpinner",false);
            }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //DIGI-2098
                            console.log("Error message: " + errors[0].message);
                            component.set("v.ErrorMsg" , 'An error occurred. Please try the action again. If there is still an issue, please contact support.');
                			component.set("v.GBBErrorComp" , true);
                            component.set("v.enableGetDealBtn", false);
                            component.set("v.showSpinner",false);
                		 }
                    } else {
                        //DIGI-2098
                       component.set("v.ErrorMsg" , 'An error occurred. Please try the action again. If there is still an issue, please contact support.');
                		component.set("v.GBBErrorComp" , true);
                        component.set("v.enableGetDealBtn", false);
                        component.set("v.showSpinner",false);
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
        console.log('GBBScale <1> '+component.get("v.GBBScale"));
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
    
    //To get final Delegaion Outcome button color, value and delegation outcome table
    getFinDelOutcome : function(component,event) {
        var dprId = component.get("v.DPRId");//take the DPR id here
        var colour;	//button colour
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

    // START - EDGE-219478 EDGE-219744 Napier Team- Shivaprasad
    //To get final Delegaion Outcome button color, value for DPR Offer
    getDPRFinDelOutcome : function(component,event) {
        var dprId = component.get("v.DPRId");//take the DPR id here
        var colour;	//button colour
        //Call Apex controller method to get Delegation Outcome button colour
        //and Final Delegation Outcome display value 
        var action1 = component.get("c.getDPROfferFinalDelegationOutcome");
        action1.setParams({
            dprID: dprId
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var responseJSONArray = component.get("v.dprLineItems");
                var responseList = response.getReturnValue();
                //var newArrayFinOutcome = [];
              
                for (var key in responseList) {
                    for (var i=0; i < responseJSONArray.length; i++){
                        if (responseList[key].productFamily == responseJSONArray[i].key){
                            responseJSONArray[i].DPRFinalDelegationOutcome = responseList[key];
                        }
                    }
                    
                } 
                console.log('responseJSONArray::'+responseJSONArray);
                component.set("v.dprLineItems", responseJSONArray);
            }
            else {
                console.log("Failed with state: " + state);
            }
        })//action1.setcallback end
        $A.enqueueAction(action1);
           
        //Call Apex controller method to get the Delegation Outcome Pop up Table values List
        var action2 = component.get("c.getDPRDelegationOutcomeTable");
        action2.setParams({
            dprID: dprId
        });        
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseListMap = response.getReturnValue();
                console.log('Delegation Outcome MAP::'+responseListMap);
              var responseJSONArray = component.get("v.dprLineItems");        
                for (var key in responseListMap) {
                    for (var i=0; i < responseJSONArray.length; i++){
                        if (key == responseJSONArray[i].key){
                            responseJSONArray[i].DPRDelegationOutcomeTableItems = responseListMap[key];
                        }
                    }
                    
                } 
                console.log('responseJSONArray::'+responseJSONArray);
                console.log("responseJSONArray <> "+JSON.stringify(responseJSONArray));
   
                component.set("v.dprLineItems", responseJSONArray);
            }
            else {
                console.log("Failed with state: " + state);
            }
        })
        $A.enqueueAction(action2);
    }
     // END - EDGE-219478 EDGE-219744 Napier Team- Shivaprasad
})