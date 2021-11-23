({
    doInit : function(component, event, helper) {
        var recId=component.get('v.recordId');
        if(recId == undefined){
            var url = window.location.href;
            var sURL;
            console.log('url', url);
            if(url.indexOf('recordId=') > -1){
            sURL = url.substring(url.indexOf('recordId=')+9, url.indexOf('recordId=')+27);
            }
            else{
                sURL = url.substring(url.indexOf('Case/')+5, url.indexOf('Case/')+23);
            }
            recId = sURL;
            component.set('v.visibility', false);
        }
       
        console.log('*recId*', recId);
       
        var action = component.get("c.getChildHierarchy");
        action.setParams({ recordId : recId });
       console.log('*recId*', recId);
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                component.set('v.title','Child Cases ('+resultData.length+')');
                console.log('resultData');
                console.log(resultData);
                if(resultData!=''){
                    component.set('v.isShowChild', true);
                }
                
                component.set('v.gridData', resultData);
                 //cm.set('v.isLoading',false);
            }
        });
        $A.enqueueAction(action);
        
       // var isVisible = component.get('v.visibility');
    },
    handleClick: function(component, event, helper) {

        var recId= component.get('v.recordId');
        
        var title= component.get('v.title');
      
        
         component.find("navService").navigate({
            type: "standard__component",
            attributes: {
                componentName: "c__soc_ChildCaseProductRow"

            },
            state: {
               	recordId: component.get('v.recordId'),
                visibility: false
            }
        });
    }
    
})