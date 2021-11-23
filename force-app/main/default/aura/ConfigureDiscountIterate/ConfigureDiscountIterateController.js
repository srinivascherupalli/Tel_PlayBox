({
    addRows : function(component, event, helper) 
    {
        var CommercialProduct=component.get("v.CommercialProduct");
        CommercialProduct.push(event.getParam("CommercialProduct"));
        component.set("v.CommercialProduct",CommercialProduct);
        console.log('length---',CommercialProduct.length);
        component.set("v.noOfPlanSection",CommercialProduct.length);
        console.log('CommercialProduct==>'+JSON.stringify(component.get("v.CommercialProduct")));       
    },
    passPlanValueToChild  : function(component, event, helper) 
    {
        console.log('numberOfPlanSect---');
        var planSelected = event.getParam("planSelected");
        console.log('planSelected iter--',planSelected);
        component.set("v.planSelected",planSelected);
    },
     /********Added by Badri***********| EDGE:119320 | Section: To Delete Number of plans added | START |***********************/ 
    deletePlanSect : function(component, event, helper) 
    {
        debugger;
        console.log('numberOfPlanSect---');
        //var numberOfPlanSect = event.getParam("noOfPlanSect");
        var numberOfPlanSect = event.getParam("noOfPlanSect");
        var CommercialProduct=component.get("v.CommercialProduct");
        var updatedCommercialProduct=[]; 
        for(var index=0; index<CommercialProduct.length; index++){
            if(index!=numberOfPlanSect){
	            updatedCommercialProduct.push(CommercialProduct[index]);
            }
        }
        CommercialProduct = updatedCommercialProduct;
        component.set("v.CommercialProduct",CommercialProduct);
/*        if(CommercialProduct.length > 1){
            CommercialProduct.pop();
            component.set("v.CommercialProduct",CommercialProduct);
        }*/
        console.log('length-del--',CommercialProduct.length);
        console.log('numberOfPlanSect---',numberOfPlanSect);
    },
    
  /*********************| EDGE:119320 | Section: To Delete Number of plans added | END |***********************/
    doInit: function(component, event, helper) 
    {
        var planSect=[];
        planSect.push(1);
        component.set("v.planTypeSections",planSect);
        component.set("v.noOfPlanSection",1);
        console.log('Inside iterate',component.get("v.PlanTypeData"));
        console.log('Inside iterate',component.get("v.hardwareOpt"));
        console.log('Inside iterate SelectedProduct',component.get("v.SelectedProduct"));
        console.log('Inside iterate OfferType',component.get("v.OfferType"));
    },
    
    callConfigureDiscount : function(component, event, helper){
        console.log('inside callConfigureDiscount');
        var childComp = component.find('ConfigureDiscountId');
        childComp.callConfigDis();
    }
    
    
    
    
})