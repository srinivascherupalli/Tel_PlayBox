({
    getGBBScaleHelper : function(component, event){
       
        var dprId = component.get("v.DPRId");
        var tabId = component.get("v.TabId");

        console.log('dprId::'+dprId);
        console.log('tabId::'+tabId);
        //Call Apex controller method to get values for GBB Scale from DPR Offer
        var action = component.get("c.getDPROfferLevelDetails");
        action.setParams({dprOfferId: dprId, offerName: tabId}); //pass dpr id //pass Product Family Name
        action.setCallback(this, function(response) {
          
            var state = response.getState();
            if (state === "SUCCESS") {
                var offer = response.getReturnValue();
                if(offer !== null){
                    component.set("v.DPROfferList",offer);
                    //------------------------------GBBScale start small-------------------------
                    console.log("Inside graph creation<><> ");
                    var el = component.find('GBBScale1').getElement();
                var ctx = el.getContext('2d');
                //To clear the canvas on consecutive calls
                ctx.clearRect(0,0,el.width,el.height);
                //DPR Values assignment
                var offerPrice = offer.ActualOfferPrice__c;
                var T1 = offer.PoorMinimalValue__c;
                var T2 = offer.MinimalMarginalValue__c;
                var T3 = offer.MarginalGoodValue__c;
                var T4 = offer.GoodBetterValue__c;
                var T5 = offer.BetterBestValue__c;
                var T6 = offer.BestMaxValue__c;
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
                 component.set("v.showSpinner",false);
                //Text footer ends
                //-------------------------------GBBScale end-----------------------------
                //component.set("v.showSpinner",false);
                if(offer != null && offer.ActualOfferPrice__c == null){
                   component.set("v.GBBScale", false);
                }
               
            }
        }
            else {
                console.log("Failed with state: " + state);
                component.set("v.GBBScale", false);
               component.set("v.showSpinner",false);
            }
        })//action.setcallback end
        $A.enqueueAction(action);   
    }
})