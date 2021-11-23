({
    doInit : function(component, event, helper) {
        
        console.log("Get Deal Score Controller is Initialised"+component.get("v.FrameId"));
        var showGraphOnLine =false;
        var frameRecId = component.get("v.FrameId");
        component.set("v.showSpinner",true);
        var action = component.get("c.fetchOfferLineItem");
        action.setParams({FrameId:frameRecId});
        console.log("Action <><>"+action);
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log("Response from APex <> "+response.getState());
            if (state === "SUCCESS") {
                var responsenew =response.getReturnValue();
                console.log("Response from APex <> "+JSON.stringify(responsenew));
                if(responsenew.length >0){
                    component.set("v.DPRId",responsenew[0].Delegated_Pricing_Request);
                    component.set("v.DealListItems",responsenew);
                    //EDGE-21112..start
                    //EDGE-219478 EDGE-219744 Start - Shivaprasad
                    //var ProdFamily='';
                    // var rateCardline=[];
                    
                    
                   var responseJSONArray = [];
                   for (var i = 0; i < responsenew.length; i++) {
                       //ProdFamily=responsenew[i].productFamily;
                       //var RCline=responsenew[i].wrapperRateCardLineItem;
                       //START EDGE-219478 EDGE-219744 Napier Team - Shivaprasad
                       var isNew = false; var inserted = false;
                       for (var j = 0; j < responseJSONArray.length; j++){
                           
                           if(responseJSONArray[j].key == (responsenew[i].productFamily)){
                               inserted = true;   
                               isNew = false;
                               responseJSONArray[j].value.push(responsenew[i]);                                
                               for(var k=0; k < responsenew[i].wrapperRateCardLineItem.length; k++){
                               responseJSONArray[j].RateCardLineItems.push(responsenew[i].wrapperRateCardLineItem[k]);  
                               }
                           }
                           else if(!inserted){
                                   isNew = true;
                               }
                       }
                       if(responseJSONArray.length == 0 || isNew){
                           var rateCard = [];
                           for(var k=0; k < responsenew[i].wrapperRateCardLineItem.length; k++){
                               rateCard.push(responsenew[i].wrapperRateCardLineItem[k]);    
                           }
                           responseJSONArray.push({key: responsenew[i].productFamily, value: [responsenew[i]],RateCardLineItems: rateCard}); 
                       }
     
                       
                       //rateCardline.push(RCline);
                   }
                   
                   console.log("responseJSONArray <> "+JSON.stringify(responseJSONArray));
                   component.set("v.dprLineItems",responseJSONArray);
                   //component.set("v.RateCardLineItems",rateCardline);
                   //component.set("v.DPROffer",ProdFamily);
                   //END EDGE-219478 EDGE-219744 Napier Team- Shivaprasad
                    //EDGE-21112..end
                    
                    if(responsenew[0].finalDelegatedOutcome != '' && responsenew[0].finalDelegatedOutcome != undefined){
                        //var a = component.get('c.getDealScoreFromPRE');
                        //$A.enqueueAction(a);
                        showGraphOnLine =true;
                        console.log('showGraphOnLine<><11>'+showGraphOnLine);
                        //EDGE-219478 EDGE-219744 Napier Team- Shivaprasad
                        component.set("v.GBBScale",true);
                        //helper.getDPRGBBScaleValues(component, event, helper);
                        helper.getFinDelOutcome(component, event, helper);
                        helper.getDPRFinDelOutcome(component, event, helper);
						//EDGE-219478 EDGE-219744 Napier Team- Shivaprasad
                    }
                }
                component.set("v.showSpinner",false);
            }else if (state === "INCOMPLETE"){}
                else if (state === "ERROR"){
                    var errors = response.getError();
                    if (errors){
                        if (errors[0] && errors[0].message){
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            if(showGraphOnLine == true){
            console.log('showGraphOnLine<><> '+showGraphOnLine);
            component.set("v.showDealScore",true);
            //EDGE-219478 EDGE-219744 Napier Team-Start- Shivaprasad
            /*var renderPlanGbbScaleEvent = $A.get("e.c:PLanLevelGbbRender"); 
            renderPlanGbbScaleEvent.setParams({
                "showHideScale" :true });
            renderPlanGbbScaleEvent.fire(); */
            //EDGE-219478 EDGE-219744 Napier Team-End- Shivaprasad
        }
        }); 
        $A.enqueueAction(action);
        //------START of EDGE-185052 by Abhishek from Osaka Team ------//
        var actionNew = component.get("c.getOpptyType");
        actionNew.setParams({frameId:frameRecId});
        actionNew.setCallback(this, function(response) {
            var state = response.getState();
            console.log("Oppty Type <> "+response.getState());
            if (state === "SUCCESS") {
                var responsenew =response.getReturnValue();
                console.log("isMigrationBoh value"+JSON.stringify(responsenew));
              	component.set("v.isMigrationBoh",responsenew);
            }
        });
        $A.enqueueAction(actionNew);
        //------END of EDGE-185052 by Abhishek from Osaka Team ------//
        
        //EDGE-203942: changes by Manuga Amsterdam
        helper.faStatusCheck(component, event, helper);
    },
    //EDGE-118371: actionHandler to call helper method to render plan level gbb when offer level gbb is rendered
    getDealScoreFromPRE: function(component, event,helper){
       // debugger;
        //component.set("v.enableGetDealButton", true);
        
        /*var renderScale = $A.get("e.c:PLanLevelGbbRender");
        renderScale.setParams({
            "showHideScale" :true
        });
        renderScale.fire();*/
        
        helper.getDealScoreFromPREHelperNew(component, event, helper);
        
    },
    ActivationSio : function(component, event, helper){
        
        component.set("v.enableSaveButton",false);
        component.set("v.enableGetDealButton",true);
    },
    upsertplanAndDiscount : function(component, event, helper){
        var planNDiscountList = component.get("v.DealListItems");
        console.log('INside Upsert <><>');
        if(planNDiscountList.length >0){
            for(var i=0; i<planNDiscountList.length; i++){
                var ActivationSIo = planNDiscountList[i].activationSIO;
                var RecontractingSIo = planNDiscountList[i].recontractSIO;
                
                if(ActivationSIo!='' && ActivationSIo!=null){
                    if(ActivationSIo < 0 || ActivationSIo > 10000){
                        var  message="Kindly enter ActivationSIo value in the range of 1 to 10000";
                        helper.showToastHelper(component,event,message,'WARNING');
                        return ;
                    }
                    
                }
                if(RecontractingSIo!='' && RecontractingSIo!=null){
                    if(RecontractingSIo < 0 || RecontractingSIo > 10000){
                        var  message="Kindly enter RecontractingSIo value in the range of 1 to 10000";
                        helper.showToastHelper(component,event,message,'WARNING');
                        return ;
                    }
                }
                if ((ActivationSIo == '' && RecontractingSIo == '') || (ActivationSIo == null && RecontractingSIo == null) || (ActivationSIo == 'undefined' && RecontractingSIo == 'undefined') || (ActivationSIo == 0 && RecontractingSIo == 0)){
                    var  message='Please input Activation SIO or Re contracting SIO or both.';
                    helper.showToastHelper(component,event,message,'WARNING');
                    return ;
                }
            }
            helper.UpdateOfferLine(component, event);
        }
       //Start of EDGE-185052 By Abhishek from Osaka Team
        //Update the existing FA record with status=Scored and delegation outcome as 'Account Executive'
        if(component.get("v.isMigrationBoh") == true){
            helper.updateFA(component,event);
        }
        //End of EDGE-185052 By Abhishek from Osaka Team
    },
    PREResponse : function(component, event, helper){
     //  debugger;
        var PREresponse = event.getParams("payload");
        console.log("Response from PRE <1>:"+JSON.stringify(PREresponse));
        console.log("Corr ID From PRE <2>: "+JSON.stringify(PREresponse.payload.Correlation_ID__c));
        var correlationID = PREresponse.payload.Correlation_ID__c;
        var delPricingReq = PREresponse.payload.Delegated_Pricing_Request__c;
        var dprGBBReportDetail = PREresponse.payload.DPR_GBB_Report_Detail__c;
        var dprDelOutcome = PREresponse.payload.DPR_Delegation_Outcome__c;
        var dprOffer = PREresponse.payload.DPR_Offer__c;
        var dprOfferLineItem = PREresponse.payload.DPR_Offer_Line_Item__c;
        
        //Correlation Id
        var correId = component.get("v.CorrelationId");
        // If Event received fetch values from Required Object
        // && correlationID===correId
        if(PREresponse){
        // debugger;
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
                        //Start EDGE-219478 EDGE-219744 Napier Team- Shivaprasad
                       
                        component.set("v.GBBScale",true);
						component.set("v.showDealScore",true);
                        var renderOfferGbbScaleEvent = $A.get("e.c:OfferLevelGbbRender"); 
                        renderOfferGbbScaleEvent.setParams({
                            "showHideOfferScale" :true });
                        renderOfferGbbScaleEvent.fire();
                         //helper.getDPRGBBScaleValues(component, event, helper); 
                        helper.getFinDelOutcome(component, event, helper);
                      helper.getDPRFinDelOutcome(component, event, helper);
                      component.set("v.showSpinner",false);
                        //End EDGE-219478 EDGE-219744 Napier Team- Shivaprasad
                        //Firing Event to render plan level Gbb Scale start-----------
                        var renderPlanGbbScaleEvent = $A.get("e.c:PLanLevelGbbRender"); 
                        renderPlanGbbScaleEvent.setParams({
                            "showHideScale" :true });
                        renderPlanGbbScaleEvent.fire();
                        //Firing Event to render plan level Gbb Scale end--------------
                        component.set("v.enableGetDealButton" , true);
                        
                    }
                    else{
                        component.set("v.ErrorMsg" , 'An error occurred. Please try the action again. If there is still an issue, please contact support.');
                        component.set("v.GBBErrorComp" , true);
                        component.set("v.showSpinner",false);
                    }
                    
                }
                else {
                    component.set("v.ErrorMsg" , 'An error occurred. Please try the action again. If there is still an issue, please contact support.');
                    component.set("v.GBBErrorComp" , true);
                    component.set("v.showSpinner",false);
                }
            })//action3.setcallback end
            $A.enqueueAction(action3);
            
            
        }
    },
    OpenChildComponent : function(c, e, h) {
        c.set("v.DelegationOutcomeTable" , true);
    },
    
    //Added by Rishabh
    //EDGE:114439 - Method to Close Delegation Outcome Pop up table     
    CloseChildComponent : function(c, e, h) {
        c.set("v.DelegationOutcomeTable" , false);
    },
    // START - EDGE-219478 EDGE-219744 Napier Team- Shivaprasad
    OpenDPRChildComponent : function(c, e, h) {
        c.set("v.DPRDelegationOutcomeTable" , true);
    },
    CloseDPRChildComponent : function(c, e, h) {
        c.set("v.DPRDelegationOutcomeTable" , false);
    },
    //EDGE-219478 EDGE-219744 Napier Team- Shivaprasad - END
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
    }
    
    
})