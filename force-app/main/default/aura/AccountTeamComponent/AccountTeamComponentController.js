/*******************************************************************
Created By          :   Sravanthi
Created Date        :   26-August-2021
Story               :   TEAM SFO Sprint 21.12 DIGI-8926
Desc                :   This fetches account id from page reference.           
***********************************************************************/
({
    doinit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var accid = myPageRef.state.c__AccountId;
        if(accid)
        component.set("v.AccountId",accid);

    },
    onPageReferenceChange : function(component,event,helper){
        $A.get('e.force:refreshView').fire();
    }
})