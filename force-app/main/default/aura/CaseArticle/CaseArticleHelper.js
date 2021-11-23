({
	getAttachedArticles: function(component) {
        var caseId = component.get("v.recordId");
        var urlPath = window.location.pathname;
        var baseUrl = urlPath.substring(0,urlPath.lastIndexOf("r"));        
        baseUrl = baseUrl + 'r/Knowledge__kav/';
        //alert('baseUrl: '+baseUrl);
        component.set("v.baseUrl", baseUrl);
        var action = component.get("c.getCaseArticles");
        action.setParams({
            "caseId": caseId});
        action.setCallback(this, function(a) {
            component.set("v.caseArticles", a.getReturnValue());
            if(a.getReturnValue() != null){
                component.set("v.articleCount", a.getReturnValue().length);
            }
         });
        $A.enqueueAction(action);
    }
 	 
})