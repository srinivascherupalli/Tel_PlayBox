({
    doInit : function(component, event, helper) {

       //EDGE-159320:defect fix
         component.set("v.billingACCid",component.get("v.recordId"));
         if ((window.location.href.includes("partners.enterprise.telstra.com.au") ||window.location.href.includes("partners"))&&window.location.href.includes("inContextOfRef") ) {
           var value = helper.getParameterByName(component , event, 'inContextOfRef');
         component.set('v.billingACCid',value);
               component.set('v.ViewAllRec',false);
        }

         component.set('v.columns', [
             {label: 'Product Basket Name', fieldName: 'linkName', type: 'url',typeAttributes: { label: { fieldName: 'Name' }, target:'_blank'}},
             {label: 'Description', fieldName: 'Description__c', type: 'text'},
             {label: 'Basket Stage', fieldName: 'csordtelcoa__Basket_Stage__c', type: 'text'}
        ]);
		helper.fetchActiveBaskets(component,event,helper);
	},
    //EDGE:153317:Opens the basket page on click of basket Name
    navigateToMyComponent : function(component, event, helper) {

        //EDGE-159320:defect fix for PRM
    var url = "";
        url = window.location.href;
        var communitySiteId = false;
        if (url.includes("partners.enterprise.telstra.com.au")) {
            communitySiteId = true;
        } else if (url.includes("partners")) {
            communitySiteId = true;
        }
         var billingaccId = component.get("v.recordId");
         if (communitySiteId){
            url = "/partners/s/relatedbaskets?inContextOfRef=" + billingaccId; 
              window.open(url,'_self');
        } 
        else{

    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        componentDef : "c:BillingAccountBaskets",
        componentAttributes: {

            ViewAllRec : "false",
            recordId : component.get("v.recordId")
        }   
    });
    evt.fire();
        }

}
})