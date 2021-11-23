({
    doInit : function(component, event, helper) {
       helper.getIndustryVerticalpicklist(component,event);
       helper.getpicklistvalues(component,event,'Partner_categories__c');
       helper.getpicklistvalues(component,event,'Source_Info_Telstra_Channel_Partner_prog__c');
       helper.getpicklistvalues(component,event,'Annual_Revenue__c');
}, 
 handleABNValidation : function(component, event, helper) {
        helper.validateABN(component,event);  
},   
    
     displaytooltip : function(component, event, helper) { 
         console.log('showtoltip')
         component.set('v.showtooltip',true)
}, 
     hidetooltip : function(component, event, helper) {   
                  console.log('hidetoltip')

         component.set('v.showtooltip',false)
}, 
    //Added by Hawaii for P2OB-8478
    checkCompanySize : function(component, event, helper){
        var size = component.get('v.leadRec.Company_Size__c');
        helper.checkCompanyValidation(component, event, size);
    }
})