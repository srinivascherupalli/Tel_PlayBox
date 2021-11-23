({
    doInit : function(component, event, helper) {
        var partnerCategory = component.get("v.leadRec.Partner_categories__c");
        var partnerCategoryArray = partnerCategory.split(';');
        var partnerCategoryarr= [];
        for(var i =0; i<partnerCategoryArray.length; i++){
        partnerCategoryarr.push(partnerCategoryArray[i]);
        }
        component.set("v.partnerCategoryList",partnerCategoryarr);
        
        var sourceInfo = component.get("v.leadRec.Source_Info_Telstra_Channel_Partner_prog__c");
        var sourceInfoArray = sourceInfo.split(';');
        var sourceInfoarr= [];
        for(var i =0; i<sourceInfoArray.length; i++){
        sourceInfoarr.push(sourceInfoArray[i]);
        }
        component.set("v.sourceInfoList",sourceInfoarr);
        
        var customerType = component.get("v.leadRec.Customer_Segment__c");
        var customerTypeArray = customerType.split(';');
        var customerTypearr= [];
        for(var i =0; i<customerTypeArray.length; i++){
        customerTypearr.push(customerTypeArray[i]);
        }
        component.set("v.customerTypeList",customerTypearr);
    }
         
})