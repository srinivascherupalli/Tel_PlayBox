/*********************************************************************
    EDGE        : 119320,114435,114434
    Component   : Configure Discount
    Description : Configure Discount based on Selected Offer
    Author      : T Badri Narayan Subudhi
    Last Modified by : Rishabh Dhamu
    **********************************************************************/

({
    getAddOnValues : function(component,event) {
        debugger;
        var selectOfferType=component.get("v.OfferType");
        var planType=component.get("v.DPROfferLineItemWrapper.PlanType");
        var plan=component.get("v.DPROfferLineItemWrapper.Qplan");
        var keyToGetAddOnValues=selectOfferType+planType+plan;
        var addOnValues=component.get("v.mapOfAddOn")[keyToGetAddOnValues];
        var SelectedaddonVal=component.get("v.DPROfferLineItemWrapper.AddOn");
        component.set("v.addOnPicklistValues",addOnValues);
        component.set("v.showDiscountSection",true); 
         var PlanSet = new Set(["Global","Global BYO","National BYO","National","Professional","Executive"]);    
         var Plan=component.get("v.DPROfferLineItemWrapper.Qplan");
        if(addOnValues!=undefined){
            component.set("v.DPROfferLineItemWrapper.addOnCount",addOnValues.length);
            component.set("v.showDiscountSection",true); 
            if(addOnValues.length>0){
                component.set("v.showAddOn",true);
            }else{
                component.set("v.showAddOn",false);
            }
            if (SelectedaddonVal != null && SelectedaddonVal != ''){
                component.set("v.DPROfferLineItemWrapper.AddOn",SelectedaddonVal);
                component.set("v.ShowSelectAddOn",true);
            } else{

                if(PlanSet.has(Plan) && addOnValues.length == 1){
                    component.set("v.ShowSelectAddOn",false);
                    component.set("v.DPROfferLineItemWrapper.AddOn",addOnValues[0].value);
                   }
                else if(addOnValues.length == 1){
                    component.set("v.ShowSelectAddOn",true);
                    component.set("v.DPROfferLineItemWrapper.AddOn",'Select Add On');
                }
                                 
                else if(addOnValues.length > 1){
                    component.set("v.ShowSelectAddOn",true);
                    component.set("v.DPROfferLineItemWrapper.AddOn",'Select Add On');
                }else{
                    component.set("v.ShowSelectAddOn",false);
                }
            } 
        }
    },
    
    getDiscountSectData : function(component,event,helper) {
        debugger;
        var action = component.get("c.getDiscountData");
        action.setParams ({selectedProduct : component.get("v.SelectedProduct"),
                           offerType : component.get("v.OfferType"),
                           plan:component.get("v.DPROfferLineItemWrapper.Qplan"),
                           planType:component.get("v.DPROfferLineItemWrapper.PlanType"),
                           getcommitteddata:component.get("v.Selectedcommitteddata")
                          });
        action.setCallback (this, function(response) {
            debugger;
            var PlanType =component.get("v.DPROfferLineItemWrapper.PlanType");
            var Plan =component.get("v.DPROfferLineItemWrapper.Qplan");
            var ActivationSIo =component.get("v.DPROfferLineItemWrapper.ActivatedSIOs");
            var RecontractingSIo =component.get("v.DPROfferLineItemWrapper.RecontractingSIOs");
            var IDDCallPackDiscount=component.get("v.DPROfferLineItemWrapper.IDDCallPackDiscount");
            var MMCDiscount=component.get("v.DPROfferLineItemWrapper.MMCDiscount");
            var ActivationCreditMonths =component.get("v.DPROfferLineItemWrapper.ActivationCreditsMonthsDiscount");
            var RecontractingCreditsMonthsDiscount =component.get("v.DPROfferLineItemWrapper.RecontractingCreditsMonthsDiscount");
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.discountValues",response.getReturnValue());
                var discountSectData=response.getReturnValue();
                if(discountSectData.length > 0){
                    component.set("v.showDiscountFields",true);
                }
                else{
                    component.set("v.showDiscountFields",false);
                }
                var setDiscountVal=new Set();
                var discountData=component.get("v.discountValues");
                var discountArray=[];
                
                var picklistFields=[];
                for(var i = 0; i < discountData.length; i++){
                    setDiscountVal.add(discountData[i].cspmb__Discount_Level__r.Name);
                }
                for(var i = 0; i < discountData.length; i++){
                    if(discountData[i].cspmb__Discount_Level__r.Name == 'MRO Bonus Credit'){
                        component.set("v.idToFetchMROAmt",discountData[i].cspmb__Discount_Level__c);
                        this.fetchMROBonusCredit(component, event);
                    }
                    if(discountData[i].cspmb__Discount_Level__r.Name == 'MMC Discount'){
                        component.set("v.MMCId",discountData[i].cspmb__Discount_Level__c);
                        component.set("v.showMMCField",true);
                        var MMCDKey=PlanType+Plan+'MMC Discount';
                        var disVal=component.get("v.mapOfMinMaxDiscountValues")[MMCDKey];
                        var MinVal = parseFloat(disVal.MinVal);
                        var MaxVal = parseFloat(disVal.MaxVal);
                        component.set("v.MMCMin",MinVal);
                        component.set("v.MMCMax",MaxVal);
                        component.set("v.helpTxtMMC",("Enter a whole number from "+MinVal+" to "+MaxVal+",MMC Discount is GST Inclusive"));
                    }
                    if(discountData[i].cspmb__Discount_Level__r.Name == 'Recontracting Credits Months Discount'){
                        component.set("v.ReconId",discountData[i].cspmb__Discount_Level__c);
                        component.set("v.showReconField",true);
                        
                        var RCMKey=PlanType+Plan+'Recontracting Credits Months Discount';
                        var disVal=component.get("v.mapOfMinMaxDiscountValues")[RCMKey];
                        var MinVal = parseFloat(disVal.MinVal);
                        var MaxVal = parseFloat(disVal.MaxVal);
                        component.set("v.ReconMin",MinVal);
                        component.set("v.ReconMax",MaxVal);
                        component.set("v.helpTxtRecon",("Enter Credit Months discount from "+MinVal+" to "+MaxVal));
                    } 
                    
                    
                    if(discountData[i].cspmb__Discount_Level__r.Name == 'Activation Credits Months Discount'){
                        component.set("v.ActivId",discountData[i].cspmb__Discount_Level__c);
                        component.set("v.showActivField",true);
                        var ACMKey=PlanType+Plan+'Activation Credits Months Discount';
                        var disVal=component.get("v.mapOfMinMaxDiscountValues")[ACMKey];
                        var MinVal = parseFloat(disVal.MinVal);
                        var MaxVal = parseFloat(disVal.MaxVal);
                        component.set("v.ActivationMin",MinVal);
                        component.set("v.ActivationMax",MaxVal);
                        component.set("v.helpTxtActiv",("Enter Credit Months discount from "+MinVal+" to "+MaxVal));   
                    }
                    
                    if(discountData[i].cspmb__Discount_Level__r.Name == 'IDD Call Pack Discount'){
                        component.set("v.IDDId",discountData[i].cspmb__Discount_Level__c);
                        component.set("v.showIDDCPDiscount",true);
                        debugger;
                        var IDDKey=PlanType+Plan+'IDD Call Pack Discount';
                        var disVal=component.get("v.mapOfMinMaxDiscountValues")[IDDKey];
                        var MinVal = parseFloat(disVal.MinVal);
                        var MaxVal = parseFloat(disVal.MaxVal);
                        component.set("v.IDDMin",MinVal);
                        component.set("v.IDDMax",MaxVal);
                        component.set("v.helpTxtIDD",("Enter Percent discount from "+MinVal+" to "+MaxVal));
                    }
                    if(discountData[i].cspmb__Discount_Level__r.Name =='Mobile Workspace Discount 1' || discountData[i].cspmb__Discount_Level__r.Name  == 'Mobile Workspace Discount 2' || discountData[i].cspmb__Discount_Level__r.Name == 'Mobile Workspace Discount 3' || discountData[i].cspmb__Discount_Level__r.Name == 'National BYO Discount'){
                        picklistFields.push(discountData[i].cspmb__Discount_Level__r.Name);
                        component.set("v.showPicklistField",true);
                    }
                }
                component.set("v.picklistFieldarray",picklistFields);
                
                
                //logic to show MRO values after edit & view 
                var mro=component.get("v.DPROfferLineItemWrapper.MRO");
                var mode = component.get("v.Mode");
                var View = component.get("v.View");
                var plan=component.get("v.DPROfferLineItemWrapper.Qplan");
                if(!plan.includes("BYO") || plan != 'Basic'){
                    if(mode || View){
                        if(mro){
                            component.set("v.showMRO",true);
                            component.set("v.mroVal",true);
                            component.set("v.mroCheckboxInput",mro);
                        }
                    }
                }
            }
            else if (state === "INCOMPLETE") {
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
    
    fetchMROBonusCredit : function(component,event) {
        var action = component.get("c.fetchMroBonCredAmt");
        action.setParams ({discLevId : component.get("v.idToFetchMROAmt") });
        action.setCallback (this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.DPROfferLineItemWrapper.MROBonusCredit",response.getReturnValue());
            } 
            else if (state === "INCOMPLETE") { }
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
    
    //EDGE-118371: helper method to render plan level gbb when offer level gbb is rendered
    getGBBScaleHelper : function(component, event){
        var planId = component.get("v.DPROfferLineItemWrapper.PlanId");
        //Call Apex controller method to get values for GBB Scale from DPR Plan
        var action = component.get("c.getDPRPlanDetails");
        action.setParams({planId: planId}); //pass plan id list
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.GBBScaleSmallShow",true);
                var plan = response.getReturnValue();
                if(plan !== null){
                    component.set("v.DPRPlan",plan);
                    //------------------------------GBBScale start small-------------------------
                    var el = component.find('GBBScaleSmall').getElement();
                    var ctx = el.getContext('2d');
                    //To clear the canvas on consecutive calls
                    ctx.clearRect(0,0,el.width,el.height);
                    //DPR Values assignment
                    var offerPrice = plan.ActualOfferPrice__c;
                    var T1 = plan.PoorMinimalValue__c;
                    var T2 = plan.MinimalMarginalValue__c;
                    var T3 = plan.MarginalGoodValue__c;
                    var T4 = plan.GoodBetterValue__c;
                    var T5 = plan.BetterBestValue__c;
                    var T6 = plan.BestMaxValue__c;
                    
                    var Total = T6 - T1;
                    //Red
                    var r1 = 0;
                    var r2 = 12;
                    var r3 = (((T2-T1)/Total)*300);//variable red length
                    var r4 = 20;
                    //Orange
                    var o1 = r3;
                    var o2 = 12;
                    var o3 = (((T3-T2)/Total)*300);//variable orange length
                    var o4 = 20;
                    //Yellow
                    var y1 = r3+o3;
                    var y2 = 12;
                    var y3 = (((T4-T3)/Total)*300);//variable yellow length
                    var y4 = 20;
                    //Green
                    var g1 = r3+o3+y3;
                    var g2 = 12;
                    var g3 = (((T5-T4)/Total)*300);//variable green length
                    var g4 = 20;
                    //Pigment green
                    var p1 = r3+o3+y3+g3;
                    var p2 = 12;
                    var p3 = (((T6-T5)/Total)*300);//variable pigment green length
                    var p4 = 20;
                    //Black pointer
                    var b1,b2,b3,b4;
                    
                    if(offerPrice <= T1){
                        b1 = 0;
                        b2 = 12;
                        b3 = 3;
                        b4 = 20;
                    }
                    
                    if(offerPrice >= T6){
                        b1 = 297;
                        b2 = 12;
                        b3 = 3;
                        b4 = 20;    
                    }
                    
                    if(offerPrice > T1 && offerPrice < T6){
                        b1 = (((offerPrice-T1)/Total)*300);
                        console.log('b1 '+b1);
                        b2 = 12;
                        b3 = 3;
                        b4 = 20;     
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
                    
                    //-------------------------------GBBScale end small-----------------------------
                    if(plan != null && plan.ActualOfferPrice__c == null){
                        component.set("v.GBBScaleSmallShow", false);
                    }
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        })//action.setcallback end
        $A.enqueueAction(action);    
    },
    
    //EDGE-118624: i button pop up
    getGBBReportDetails : function(component, event){
        var planId = component.get("v.DPROfferLineItemWrapper.PlanId");
        var action = component.get("c.fetchGBBReportDetails");
        action.setParams ({planId : planId});
        action.setCallback (this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.DprGBBReportDetails", response.getReturnValue());
                //Added by Rishabh
                var list = component.get("v.DPRPlan");
                //------------------------------GBBScale i button start-------------------------
                var el = component.find('GBBScaleSmallInfo').getElement();
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
                var r2 = 12;
                var r3 = (((T2-T1)/Total)*500);//variable red length
                var r4 = 20;
                //Orange
                var o1 = r3;
                var o2 = 12;
                var o3 = (((T3-T2)/Total)*500);//variable orange length
                var o4 = 20;
                //Yellow
                var y1 = r3+o3;
                var y2 = 12;
                var y3 = (((T4-T3)/Total)*500);//variable yellow length
                var y4 = 20;
                //Green
                var g1 = r3+o3+y3;
                var g2 = 12;
                var g3 = (((T5-T4)/Total)*500);//variable green length
                var g4 = 20;
                //Pigment green
                var p1 = r3+o3+y3+g3;
                var p2 = 12;
                var p3 = (((T6-T5)/Total)*500);//variable pigment green length
                var p4 = 20;
                //Black pointer
                var b1,b2,b3,b4;
                
                if(offerPrice <= T1){
                    b1 = 0;
                    b2 = 12;
                    b3 = 3;
                    b4 = 20;
                    //Text header starts
                    ctx.font = "10px Sans-Serif";
                    ctx.fillText("Offer $"+OPD+"k", b1, 10);
                    //Text header stops
                }
                
                if(offerPrice >= T6){
                    b1 = 497;
                    b2 = 12;
                    b3 = 3;
                    b4 = 20;
                    //Text header starts
                    ctx.font = "10px Sans-Serif";
                    ctx.fillText("Offer $"+OPD+"k", b1-55, 10);
                    //Text header stops
                }
                
                if(offerPrice > T1 && offerPrice < T6){
                    b1 = (((offerPrice-T1)/Total)*500);
                    console.log('b1 '+b1);
                    b2 = 12;
                    b3 = 3;
                    b4 = 20;
                    if(b1 <= 445){                
                        //Text header starts
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("Offer $"+OPD+"k", b1, 10);
                        //Text header stops
                    }
                    if(b1 > 445){                
                        //Text header starts
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("Offer $"+OPD+"k", 442, 10);
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
                    ctx.moveTo(o1, 32);
                    ctx.lineTo(o1-2, 37);
                    ctx.lineTo(o1+2, 37);
                    ctx.closePath();
                    ctx.fillStyle = "#000502";
                    ctx.fill();
                }
                //triangle 2
                if(o3!==0 && y1<499){
                    console.log('o3 '+o3);
                    console.log('y1 '+y1);
                    ctx.beginPath();
                    ctx.moveTo(y1, 32);
                    ctx.lineTo(y1-2, 37);
                    ctx.lineTo(y1+2, 37);
                    ctx.closePath();
                    ctx.fillStyle = "#000502";
                    ctx.fill();
                }
                //triangle 3
                if(y3!==0 && g1<499){
                    console.log('y3 '+y3);
                    console.log('g1 '+g1);
                    ctx.beginPath();
                    ctx.moveTo(g1, 32);
                    ctx.lineTo(g1-2, 37);
                    ctx.lineTo(g1+2, 37);
                    ctx.closePath();
                    ctx.fillStyle = "#000502";
                    ctx.fill();
                }
                //triangle 4
                if(g3!==0 && p1<499){
                    console.log('g3 '+g3);
                    console.log('p1 '+p1);
                    ctx.beginPath();
                    ctx.moveTo(p1, 32);
                    ctx.lineTo(p1-2, 37);
                    ctx.lineTo(p1+2, 37);
                    ctx.closePath();
                    ctx.fillStyle = "#000502";
                    ctx.fill();
                }
                //upfacing triangle footer end
                
                //Text footer starts
                //Text 1
                if(r3!==0 && o1<499){
                    ctx.font = "10px Sans-Serif";
                    ctx.fillText("$"+D2+"k", o1, 47);
                }
                //Text 2
                if(o3!==0 && y1<499){
                    if(o3 > 40){
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("$"+D3+"k", y1, 47);
                    }
                    if(o3 < 40){
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("$"+D3+"k", y1, 57);
                    }
                }
                //Text 3
                if(y3!==0 && g1<499){
                    if(y3 > 40){
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("$"+D4+"k", g1, 47);
                    }
                    if(o3 > 40 && y3 < 40){
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("$"+D4+"k", g1, 57);
                    }
                    if(o3 < 40 && y3 < 40){
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("$"+D4+"k", g1, 67);
                    }
                }
                //Text 4
                if(g3!==0 && p1<499){
                    if(g3 > 40){
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("$"+D5+"k", p1, 47);
                    }
                    if(y3 > 40 && g3 < 40){
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("$"+D5+"k", p1, 57);
                    }
                    if(o3 > 40 && y3 < 40 && g3 < 40){
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("$"+D5+"k", p1, 67);
                    }
                    if(o3 < 40 && y3 < 40 && g3 < 40){
                        ctx.font = "10px Sans-Serif";
                        ctx.fillText("$"+D5+"k", p1, 77);
                    }
                }
                //Text footer ends
                
                //-------------------------------GBBScale i button end-----------------------------
            } else if (state === "INCOMPLETE") {
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
    //EDGE-145558: Invoke apex controller to get IDD charge
     getDataPlanCharge : function(component, event, helper) {

         var DirectDial;
         if (component.get("v.directDial") != '' && component.get("v.directDial")!= undefined )
         {
         DirectDial= component.get("v.directDial");
         }
         else{
         DirectDial= component.find('addon').get('v.value');
         }
        var PlanData = component.find('Qplan').get('v.value');
        console.log('--->DirectDial',DirectDial);
        console.log('--->PlanData',PlanData);
        var action=component.get("c.fetchAddonDataCharge");
         action.setParams({"directDialValue": DirectDial,"planDataValue":PlanData});
        // define the callback and check the status ,
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){

                var resultCharge=response.getReturnValue();
               // component.set("v.dataPlanCharge",result);
                 component.set("v.dataCharge",resultCharge);

                if(resultCharge==0 && component.get("v.directDial") != '')
                {
                component.set("v.addonselected",true);
                component.set("v.dataPlanCharge",resultCharge);
                console.log(JSON.stringify(resultCharge)+'testing--->if');
                component.set("v.ShowSelectAddOn",false);
                 }
                else if(resultCharge>0 && (component.get("v.directDial") == '' || component.get("v.directDial")== undefined))
                {
                component.set("v.dataPlanCharge",resultCharge);
                console.log(JSON.stringify(resultCharge)+'testing--->else');
                component.set("v.addonselected",false);
                }
              
            }
        });
        $A.enqueueAction(action);
	}
    


})