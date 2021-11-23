({
	doInit : function(component, event, helper) {
        var fnn = [];
        var action = component.get("c.initalizeInput");
        action.setCallback(this, function(response) {
            var detailtemp = {};
            detailtemp = {'sobjectType': 'Account','Name': '','Code':'','Reason':'','Indicator':''};
        	detailtemp.Name = response.getReturnValue();
            fnn.push(detailtemp);
            component.set("v.fnns", fnn);
            
        });
        $A.enqueueAction(action);
    }
    ,
    addFNN : function(component, event, helper){
        var fnn = component.get("v.fnns");
        var len = fnn.length;
        var newFNN = [];
        if(len<10){
        for (var i=0;i<len;i++){
            var detailtemp = {};
        	detailtemp = { 'sobjectType': 'Account','Name': '','Code':'','Reason':'','Indicator':''};
        	detailtemp.Name = fnn[i].Name;
            detailtemp.Code = fnn[i].Code;
            detailtemp.Reason = fnn[i].Reason;
            detailtemp.Indicator = fnn[i].Indicator;
            newFNN.push(detailtemp);        
        }
        newFNN.push({ 'sobjectType': 'Account','Name': '','Code':'','Reason':'','Indicator':''});
        component.set("v.fnns", newFNN);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
    		toastEvent.setParams({
        		"title": "Error!",
        		"message": "Maximum of 10 FNN number checked at a time"
    		});
    		toastEvent.fire();
        }
    }
    ,
    validateFNN : function (component,event,helper){
        helper.validateFNN(component);
    }
    ,
    validateFNNNumber: function(component, event, helper) {
       var fnns=component.get("v.fnns");
       var reg = /^\d$/;
       for(var i=0;i<fnns.length;i++){
           var fnnsValue=(fnns[i].Name.toString()).split("");
           var value="";
           for(var j=0;j<fnnsValue.length;j++){
               if(reg.test(fnnsValue[j])){
                    value=value+fnnsValue[j].toString();
        		}
        }
            fnns[i].Name=value;
        }
        component.set('v.fnns', fnns);
    }
    
    
})