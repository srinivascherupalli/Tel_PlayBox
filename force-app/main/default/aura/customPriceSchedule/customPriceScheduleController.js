({
    doInit : function(component, event, helper) {
        //Added by Ankit as a part of EDGE-123593 || Start
        component.set("v.changeFlag",false);       
        if(component.get('v.changeType') =='Modify'){
            component.set("v.changeTypeValue",true); 
        }//Added by Ankit as a part of EDGE-123593 || End
    	helper.getDiscountDetails(component,event);
    },//Added by Ankit as a part of EDGE-123593 || Start
     doClick : function(component, event, helper) {  
        component.set("v.changeFlag",true);
    	helper.getDiscountDetails(component,event);
    },//Added by Ankit as a part of EDGE-123593 || End
   
})