({
	validateFNN : function(component) {
        var action3 = component.get("c.checkFNN");
        var fnns = component.get("v.fnns");
        var fnnList =[];
        for (var i=0;i<fnns.length;i++){
            fnnList.push(fnns[i].Name.toString());
        }
        action3.setParams({"fnnString" : JSON.stringify(fnnList)});
        console.log({"fnnString" : JSON.stringify(fnnList)});
        action3.setCallback(this,function(response){
            if(response.getReturnValue() != null){
            var valueMap = response.getReturnValue();
            	for (var i=0;i<fnns.length;i++){
                	fnns[i].Reason=valueMap[fnns[i].Name].reason;
                	fnns[i].Code=valueMap[fnns[i].Name].code;
                	fnns[i].Indicator=valueMap[fnns[i].Name].fnnPortabilityIndicator;
        		}
            }
            else{
                for (var i=0;i<fnns.length;i++){
                	fnns[i].Reason='';
                	fnns[i].Code='';
                	fnns[i].Indicator='';
                }
                var staticLabel = $A.get("$Label.c.FNN_Failure");
            	this.showToast(component, 'Failure', staticLabel);
            }
            component.set("v.fnns", fnns);
        });
        $A.enqueueAction(action3);
    }
    ,
    showToast : function(component, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration : 2500,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
	}
    
})