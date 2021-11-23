({
    doInit : function(component, event, helper){
            console.log('Inside doinit');
              helper.getColumnDefinitions(component);
            helper.doinit(component, event, helper);
        }, 
       navigateToMyComponent : function(component, event, helper) {
           var listofNums=component.get("v.listOfNumber");
           var evt = $A.get("e.force:navigateToComponent");
           evt.setParams({
               componentDef : "c:RelatedListOfNumberOnSubscription",
               componentAttributes: {
                   isViewAll:true,
                   recordId:component.get("v.recordId")
               }
           });
           evt.fire();
       },
      
    searchKeyNumber  : function(component, event, helper){
          var searchKey =component.find("searchKey").get("v.value");
          var listofphone = [];
          var listOfNumber =  component.get("v.listofSearch");     
         if(searchKey && searchKey.length >= 3)  {
           for(var num of listOfNumber){
               if(num.Service_Number__c.indexOf(searchKey) > -1 && num.Mobile__c == 'Fixed' && num.Mobile__c != '') {
                   listofphone.push(num);  
              }
           }
         }else {
             listofphone = component.get("v.listofSearch");
         } 
           component.set("v.listOfNumber",listofphone); 
       } 
   })