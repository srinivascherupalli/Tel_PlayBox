({
   selectRecord : function(component, event, helper){      
    // get the selected record from list  
    // debugger;
      var getSelectRecord = component.get("v.oRecord");
      console.log(JSON.stringify(getSelectRecord));
       console.log('getSelectRecord');
        console.log(getSelectRecord);
    // call the event   
      var compEvent = component.getEvent("oSelectedRecordEvent");
    // set the Selected sObject Record to the event attribute.  
       compEvent.setParams({"recordByEvent" : getSelectRecord,"dataType":component.get("v.dataType"),"fieldName":component.get("v.fieldName")});  
    // fire the event  
         compEvent.fire();
    },
})