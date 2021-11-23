({
	doInit : function(component, event, helper) {
        //setting recordId in doInt to ensure both Manual refresh and redirections are covered
        component.set('v.accRecordId',component.get("v.pageReference").state.c__accRecordId);
    },
    //Added below method to refresh the cache as we are using parent-child relation 
    //which is not working when user uses navigation and come backs
    onPageReferenceChanged: function(component,event,helper){
        $A.get('e.force:refreshView').fire();
        
	}
})