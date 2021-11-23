({
	init : function(component, event) {
        //call apex class method
        var action = component.get('c.checkUserCustomPermission');
        action.setCallback(this,function(response){
        //store state of response
        var state = response.getState();
            if (state === "SUCCESS") {
            var isTrue = response.getReturnValue();
                if(isTrue ){
                    //call Apex method
                    var fieldList = component.get('c.getCaseFieldList'); 
                    fieldList.setParams({
                        recordId : component.get('v.recordId'),
                        //P2OB-12617 : Provided additional parameters to apex methods
                        objectName : component.get('v.objectName'),
                        metaDataName : component.get('v.metaDataApiName'),
                        objectMetadataJson : component.get('v.objMetaFieldJson')
                    });
                    fieldList.setCallback(this,function(res) {
                    var state1 = res.getState(); // get the response state
                    if(state1 === "SUCCESS") {
                        var caseInfo = res.getReturnValue();
                        for ( var key in caseInfo ) {
                            if(key !== 'Default' && key !== 'System Information')
                                component.set('v.fields',caseInfo[key]);
                        }
                        var defaultValue = caseInfo['Default'];
                        component.set('v.CaseInformation',defaultValue);
                        var systemInfo = caseInfo['System Information'];
                            component.set('v.SystemInformation',systemInfo);
                        }
                    });
                    $A.enqueueAction(fieldList);
                    }
                }
        });
    	$A.enqueueAction(action);
    }
})