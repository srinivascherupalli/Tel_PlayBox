/*********************************************************************
    EDGE        : 119320,114435,114434
    Component   : Configure Discount
    Description : Configure Discount based on Selected Offer
    Author      : T Badri Narayan Subudhi
    Last Modified by :Aditya for:EDGE-128406: Update Deal Management UI to restrict MRO checkbox
    **********************************************************************/
({
    doInit:function(component, event, helper){
        debugger;
        var selectOfferType=component.get("v.OfferType");
        var PlanTypeValues=component.get("v.mapOfPlanTypeVsOffer")[selectOfferType];
        component.set("v.PlanTypeData",PlanTypeValues);
        
        var pln=component.get("v.DPROfferLineItemWrapper.PlanType");
        var addon=component.get("v.DPROfferLineItemWrapper.AddOn");
        var Qpln=component.get("v.DPROfferLineItemWrapper.Qplan");
        var mro=component.get("v.DPROfferLineItemWrapper.MRO");
        var view= component.get("v.View");
        
        if(Qpln != null && Qpln != ''){
            component.set("v.showDiscountSection",true);
            var selectOfferType=component.get("v.OfferType");  
            var selectPlanType=component.get("v.DPROfferLineItemWrapper.PlanType");  
            var selectPlan=component.get("v.DPROfferLineItemWrapper.Qplan");  
            var keyToGetPlans=selectOfferType+selectPlanType;
            var keyToGetAddOnValues=selectOfferType+selectPlanType+selectPlan;
            var PlanValues=component.get("v.mapOfcmdPlanVsPtype")[keyToGetPlans];
            component.set("v.Plan",PlanValues); 
            helper.getAddOnValues(component,event);
            helper.getDiscountSectData(component,event);

      		//Osaka loading IDD charge every time page is loaded.
      		helper.getDataPlanCharge(component, event, helper);
      
            if(mro == true){
                component.set("v.mroVal",true);
                component.set("v.showMRO",true);
                component.set("v.mroCheckboxInput",true);
                //Aditya for:EDGE-128406
                component.set("v.mroCheckBoxHide",true);
            }
            	//Aditya for:EDGE-128406
            else{
                var plan=component.get("v.DPROfferLineItemWrapper.Qplan");
                if(plan.includes("BYO") || plan == 'Basic'){
                component.set("v.showMRO",true);
                component.set("v.mroCheckBoxHide",true);
                    
                }
                }
        }
        if(Qpln == ''){
            component.set("v.DPROfferLineItemWrapper.PlanType",'Select Plan Type');
            component.set("v.DPROfferLineItemWrapper.Qplan",'Select Plan');
        } 
    },
    
    ActivationSio : function(component, event, helper){
        var appEvent = component.getEvent("SaveButtonEnableDisable"); 
        appEvent.fire();
    },
    
    AddNewRow : function(component, event, helper){
        debugger;
        //fire the AddNewRowEvt Lightning Event 
        component.getEvent("AddRowEvt").fire();    
    },
    
    handleSectionToggle: function (component, event) {
        var openSections = event.getParam('openSections');
    },
    
    removeRow : function(component, event, helper){
        debugger;
        //fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
        var PlanId=component.get("v.DPROfferLineItemWrapper.PlanId");
        var DPROfferId=component.get("v.DPROfferLineItemWrapper.DPROfferId");
        if(PlanId!=''){
            var action = component.get("c.delePlansAndDiscount");
            action.setParams ({PlanId :PlanId,DPROfferId :DPROfferId});
            action.setCallback (this, function(response) {
                var state = response.getState();
                var response =response.getReturnValue();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message:'Records Deleted Successfully.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'Success',
                        mode: 'dismissible'
                    });
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
            });
            $A.enqueueAction(action);
        }    
        component.getEvent("DeleteRowEvt").setParams(
            {"indexVar" : component.get("v.rowIndex") }).fire();
    }, 
    
    selectedPlanType : function(component, event, helper) {
        debugger;
        component.set("v.DPROfferLineItemWrapper.Qplan",'Select Plan');
        component.set("v.DPROfferLineItemWrapper.ActivatedSIOs", null);
        component.set("v.DPROfferLineItemWrapper.RecontractingSIOs",null);
        component.set("v.mroCheckboxInput",false);
        component.set("v.ActivationSIo",false);
        component.set("v.ActivationSIo",true);
        component.set("v.showAddOn",false);
        component.set("v.DPROfferLineItemWrapper.AddOn",null);
        component.set("v.showDiscountSection",true);
        component.set("v.showIDDCPDiscount",false);
        component.set("v.DPROfferLineItemWrapper.IDDCallPackDiscount",null);
        component.set("v.showMMCField",false);
        component.set("v.DPROfferLineItemWrapper.MMCDiscount",null);
        component.set("v.showActivField",false);
        component.set("v.DPROfferLineItemWrapper.ActivationCreditsMonthsDiscount",null);
        component.set("v.showReconField",false);
        component.set("v.DPROfferLineItemWrapper.RecontractingCreditsMonthsDiscount",null);
        component.set("v.DPROfferLineItemWrapper.MobileWorkspaceDiscount2",null);
        component.set("v.DPROfferLineItemWrapper.MobileWorkspaceDiscount1",null);
        component.set("v.DPROfferLineItemWrapper.MobileWorkspaceDiscount3",null);
        component.set("v.DPROfferLineItemWrapper.NationalBYODiscount",null);
        var appEvent = component.getEvent("SaveButtonEnableDisable"); 
        appEvent.fire();
        
        
        var selectOfferType=component.get("v.OfferType");
        var selectPlanType=component.get("v.DPROfferLineItemWrapper.PlanType");
        var selectPlan=component.get("v.DPROfferLineItemWrapper.Qplan");
        var keyToGetPlans=selectOfferType+selectPlanType;
        var PlanValues=component.get("v.mapOfcmdPlanVsPtype")[keyToGetPlans];
        component.set("v.Plan",PlanValues);
    },
    
    selectedPlan : function(component, event, helper){
       //EDGE-145558: reset the field values
        component.set("v.dataPlanCharge",null);
        component.set("v.addonselected",true);
       //fire event to check dublicate plan & Plan Type
        var cmpEvent = component.getEvent("handlelDublicatEvent");
        cmpEvent.fire();
        var appEvent = component.getEvent("SaveButtonEnableDisable"); 
        appEvent.fire();
        component.set("v.DPROfferLineItemWrapper.ActivatedSIOs", null);
        component.set("v.DPROfferLineItemWrapper.RecontractingSIOs",null);
        component.set("v.mroCheckboxInput",false);
        component.set("v.ActivationSIo",false);
        component.set("v.ActivationSIo",true);
        component.set("v.showAddOn",false);
        component.set("v.DPROfferLineItemWrapper.AddOn",null);
        component.set("v.showDiscountSection",true);
        component.set("v.showIDDCPDiscount",false);
        component.set("v.DPROfferLineItemWrapper.IDDCallPackDiscount",null);
        component.set("v.showMMCField",false);
        component.set("v.DPROfferLineItemWrapper.MMCDiscount",null);
        component.set("v.showActivField",false);
        component.set("v.DPROfferLineItemWrapper.MROVal",false);
        component.set("v.DPROfferLineItemWrapper.ActivationCreditsMonthsDiscount",null);
        component.set("v.showReconField",false);
        component.set("v.DPROfferLineItemWrapper.RecontractingCreditsMonthsDiscount",null);
        component.set("v.DPROfferLineItemWrapper.MobileWorkspaceDiscount2",null);
        component.set("v.DPROfferLineItemWrapper.MobileWorkspaceDiscount1",null);
        component.set("v.DPROfferLineItemWrapper.MobileWorkspaceDiscount3",null);
        component.set("v.DPROfferLineItemWrapper.NationalBYODiscount",null);
        var planType=component.get("v.DPROfferLineItemWrapper.PlanType");
        var plan=component.get("v.DPROfferLineItemWrapper.Qplan");
        //Aditya for:EDGE-128406: Update Deal Management UI to restrict MRO checkbox
        component.set("v.showMRO",true);
        component.set("v.mroCheckBoxHide",true);
        if(plan.includes("BYO") || plan == 'Basic'){
            component.set("v.mroVal",false);
        	component.set("v.mroCheckboxInput",false);
            component.set("v.DPROfferLineItemWrapper.MRO",false);
          }//Aditya for:EDGE-128406: Update Deal Management UI to restrict MRO checkbox
          else{
            component.set("v.mroCheckboxInput",true);
            component.set("v.mroVal",true); 
            component.set("v.DPROfferLineItemWrapper.MRO",true); 
              
             
          }
       if(component.get("v.OfferType") =="Committed Data" && component.get("v.SelectedPlanType") =="Data"){
            component.set("v.showaddondetailes",true); 
        }
        var action = component.get("c.fetchMMC");
        action.setParams ({planType :planType,plan :plan});
        action.setCallback (this, function(response) {
            var state = response.getState();
            var mmcval =response.getReturnValue()[0].cspmb__Recurring_Charge__c;
            if (state === "SUCCESS") {
                component.set("v.DPROfferLineItemWrapper.MMC",mmcval);
                helper.getAddOnValues(component,event);
                helper.getDiscountSectData(component,event);
            } 
            else if (state === "INCOMPLETE"){}
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
        });
        $A.enqueueAction(action);
         //EDGE-145558: set IDD charge to zero for set of plans
     
         
        var selectOfferType=component.get("v.OfferType");
        var PlanType=component.get("v.DPROfferLineItemWrapper.PlanType");
        var Plan=component.get("v.DPROfferLineItemWrapper.Qplan");
        var keyToGetAddOnValues=selectOfferType+planType+plan;
        var addOnValues=component.get("v.mapOfAddOn")[keyToGetAddOnValues]; 
         var PlanSet = new Set(["Global","Global BYO","National BYO","National","Professional","Executive"]);
            if (PlanType == "Voice and Data" && (PlanSet.has(Plan)))
            {
               component.set("v.dataPlanCharge",0);
            }

            else if (PlanType == "Voice and Data" && !(PlanSet.has(Plan)) &&  addOnValues.length == 1)
            {
            var addon=JSON.stringify(addOnValues[0]);
            var DirectDial=addon.replace(/(^"|"$)/g, '');
            component.set("v.directDial",DirectDial);
            helper.getDataPlanCharge(component, event, helper);
            
               }

    },
    
    onCheck: function(cmp, evt) {
        var checkCmp = cmp.get("v.mroCheckboxInput");
        cmp.set("v.DPROfferLineItemWrapper.MRO",checkCmp);
        if(checkCmp === true){
            cmp.set("v.mroVal",true);
        }else{
            cmp.set("v.mroVal",false);
        }
    },
    selectedAddOnType : function(component, event, helper) {
         //EDGE-145558: invoke helper method to get IDD charge-->

         component.set("v.directDial",'');
         helper.getDataPlanCharge(component, event, helper);
         
    }, 
    
    activationCreditmnths : function(component, event, helper){
        var appEvent = component.getEvent("SaveButtonEnableDisable"); 
        appEvent.fire();
        var activationCreditmnths = component.get("v.DPROfferLineItemWrapper.ActivationCreditsMonthsDiscount");
        if(activationCreditmnths != '' && activationCreditmnths != null && activationCreditmnths != undefined){
            component.set("v.valueInActivationField",true);
        }
    },
    recontractingCreditmnths : function(component, event, helper){
        var appEvent = component.getEvent("SaveButtonEnableDisable"); 
        appEvent.fire();
        var recontractingCreditmnths = component.get("v.DPROfferLineItemWrapper.RecontractingCreditsMonthsDiscount");
        if(recontractingCreditmnths != '' && recontractingCreditmnths != null && recontractingCreditmnths != undefined){
            component.set("v.valueInRecontractField",true);
        }  
    },
    
    //EDGE-118371: actionHandler to call helper method to render plan level gbb when offer level gbb is rendered
    handlePlanLevelGbbRender: function(component, event, helper) {
        var isShowHide = event.getParam("showHideScale");
        component.set("v.GBBScalePlanLevel",isShowHide);
        if(isShowHide){
            helper.getGBBScaleHelper(component, event); 
        }else{
            component.set("v.GBBScaleSmallShow",false);
        }
    },
    
    //EDGE-118624: i button pop up
    openGbbScale : function(component, event, helper){ 
        component.set("v.showScale",true);
        helper.getGBBReportDetails(component,event);
    },
    
    //EDGE-118624: i button pop up close function
    closeModal : function(component, event, helper){
        component.set("v.showScale",false);
    },
    
    //EDGE:136961: Added to display MMC Excl. GST field on change of MMC discount value
    MMCDiscount : function(component, event, helper){
        var appEvent = component.getEvent("SaveButtonEnableDisable"); 
        appEvent.fire();
        
        var MMCVal = component.get("v.DPROfferLineItemWrapper.MMCDiscount");
        var MMCValEXGSt = MMCVal/1.1;
        var roundoff = Math.round((MMCValEXGSt + 0.00001) * 100) / 100
        component.set("v.DPROfferLineItemWrapper.MMCDiscountExGST",roundoff);
     }
   
    
})