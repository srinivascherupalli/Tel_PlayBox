({
    redirectTo: function(component, event, helper) {

        var opptyId = component.get("v.recordId"); // Opportunity Id
        var action = component.get("c.getValidOpportunity");
        var errormap = component.get("c.getValidOpportunity");

        action.setParams({
            "oppId": opptyId
        });
        //use meaningful variable name
        var p = helper.executeAction(component, action);
        p.then($A.getCallback(function(result) {
            //alert(result);
            console.log('result: ' + result);
            console.log(result);
            if (result.status == 'error') {
                component.set('v.showError', false);
                component.set('v.ErrorMap', result['message']);
                //alert(result['message']);
                console.log('ErrorMap: ');
                return;
            }
            
            else {
                var action1 = component.get("c.getPathPrefix"); // function on Apex class
                var Promise1 = helper.executeAction(component, action1);
                return Promise1;
            }
        })).then($A.getCallback(function(result) {
            if (null != result) {
                /*var pathPrefix = result.replace(/\/s$/, ''); // removing the /s
                var redirect_page = "/NewBasketRedirect_cp"; // custom VF page for the basket creation 

                window.location.href = pathPrefix + redirect_page +
                    "?opptyId=" + opptyId +
                    "&retURL=" + pathPrefix;*/
                    var pathPrefix = result.replace(/\/s$/, '');
                    var basketMap =JSON.stringify({"cscfga__Opportunity__c": opptyId});
                    helper.createbasket(component, event,basketMap,pathPrefix);
            }
        })).catch(
            $A.getCallback(function(error) {
                alert('An error occurred : ' + error.message);
            })
       
        );
    }
})