({
    selectRecord : function(component, event, helper){      
        // get the selected record from list  
        var getSelectRecord = component.get("v.oRecord");
        // call the event   
        var compEvent = component.getEvent("oSelectedRecordEvent");
        // set the Selected sObject Record to the event attribute.  
        compEvent.setParams({"recordByEvent" : getSelectRecord });  
        // fire the event  
        compEvent.fire();
    },
    
    doInit: function(component, event, helper) {
        
        //get the field name
        var field = component.get('v.primaryField');
        var secondField = component.get('v.secondaryField');
       
        //set key for values lookup
        var key = 'v.oRecord.'+field;
        var primaryresult = component.get(key);
        var secondarykey = 'v.oRecord.'+secondField;
        var secondaryresult = component.get(secondarykey);
        
        //set the value to and attribute to be used in your component
        component.set('v.primaryResult', primaryresult);
        component.set('v.secondaryResult', secondaryresult);
        
    }
})