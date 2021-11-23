({
	doInit : function(component, event, helper) {
        helper.getAttachedArticles(component);
    }  ,
    
    openUrl : function(component, event , helper) {
        var navEvt = $A.get("e.force.navigateToURL");
        var knowId =cmp.get("v.art.Id");
        navEvt.setParams({
            "url" : '/article/' + article.Id + '/' + article.UrlName 
        });
        navEvt.fire();
    }
    
})