({
    doInit : function(component, event, helper) {
       var numberOfSteps = component.get('v.numberOfSteps');
       var screenNumberList = [];
        
        for(let i=1; i<=numberOfSteps; i++){
            screenNumberList.push(i.toString());
        }
        component.set("v.screenNumberList", screenNumberList);
        
    }
       
})