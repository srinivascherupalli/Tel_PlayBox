({
    doInit: function (cmp, event, helper) {
        var resultMsg = JSON.parse( sessionStorage.getItem( 'pageTransfersites'));
        
        console.log("resultMsg",resultMsg);
        
        if(resultMsg != null  && cmp.get("v.recordId") == null){
            console.log(" resultMsg.state.c__recordId", resultMsg.state.c__recordId);
            console.log("c__ViewAllRec",resultMsg.state.c__ViewAllRec);
            console.log("c__conIconName",resultMsg.state.c__conIconName);
            cmp.set("v.recordId", resultMsg.state.c__recordId);
            cmp.set("v.ViewAllRec", resultMsg.state.c__ViewAllRec);
            cmp.set("v.conIconName", resultMsg.state.c__conIconName);
        }
        
        var viewAllvar1 = cmp.get("v.ViewAllRec");
        console.log("viewAllvar1",viewAllvar1);
        helper.fetchSites(cmp, event, helper);
    },
    createNewSite : function(component, event, helper) {
        //  var createSiteflg = component.get("v.canCreateSite");
             component.set("v.isOpen", true)
    },
     doCloseOperation : function(component, event, helper) {
        helper.doCloseOperation(component, event, helper);
       
    },
    searchAddressOpen : function (component, event, helper) {       
        helper.searchAddressOpen(component, event, helper); 
    },
    handleBubbling : function (component, event, helper) {       
        helper.handleBubbling(component, event, helper); 
    },
    searchedCompletedAction : function (component, event, helper) {       
        helper.searchedCompletedAction(component, event, helper); 
    },
    getSiteName : function (component, event, helper) {       
        helper.getSiteName(component, event, helper); 
    },
    
    saveSite : function (component, event, helper) {
      
        helper.saveSite(component, event, helper); 
        
        
    },
        //This function is to redirect to view all records functionality ,recalls the same lightning component.
    navigateToMyComponent: function (cmp, event, helper) {
       var baseurl = window.location.href;
        console.log('baseurl',baseurl);
        if (baseurl.includes('partners.enterprise.telstra.com.au') || (baseurl.includes('/partners/s'))) {  
            var navService = cmp.find("navService");
            var pageReference = {  
                "type": "comm__namedPage",
                "attributes": {
                    "pageName": "siteviewall"    
                },    
                "state": {
                    "c__ViewAllRec": "false",
                    "c__conIconName": "" ,
                    "c__recordId":cmp.get("v.recordId")
                }
            };
            /*
             "objectApiName": "Account",
            
            var pageReference={
                "type": "standard__recordRelationshipPage",
                "attributes": {
                    "recordId": cmp.get("v.recordId"),
                    "objectApiName": "Account",
                    "relationshipApiName": "cscrm__Sites__r",
                     "actionName": "view"
                }
            };
            */
            console.log('pageReference',pageReference);
            sessionStorage.removeItem('pageTransfer');
            sessionStorage.setItem('pageTransfersites', JSON.stringify(pageReference));
            navService.navigate(pageReference);   
        }else
        // Added by Purushottam : EDGE-151592  End
        {
            var evt = $A.get("e.force:navigateToComponent");
        	evt.setParams({
            componentDef: "c:customSiterelatedList",
            componentAttributes: {
                ViewAllRec: "false",
                conIconName: "",
                recordId: cmp.get("v.recordId")

            }
        });
        evt.fire();
        }
    }   
})