/*********************************************************************
    EDGE        : 115087
    Component   : OneFundAccrualTransactions
    Description : Custom buttons on OneFund Balance pop-up
    Author      : Hari
    **********************************************************************/

/******************** EDGE:115087 | START |***********************/

({
   init : function(cmp, event, helper) {
      // Figure out which buttons to display
      var availableActions = cmp.get('v.availableActions');
      for (var i = 0; i < availableActions.length; i++) {
         if (availableActions[i] == "PAUSE") {
            cmp.set("v.canPause", true);
         } else if (availableActions[i] == "BACK") {
            cmp.set("v.canBack", true);
         } else if (availableActions[i] == "NEXT") {
            cmp.set("v.canNext", true);
         } else if (availableActions[i] == "FINISH") {
            cmp.set("v.canFinish", true);
         }
      } 
       //EDGE-190307 start
       var profile = cmp.get('v.ProfileName');
       if(profile=="PRM Admin - Australia" || profile=="PRM Community User - Australia"){
           cmp.set("v.isCommunityUser",false);
       }
       
       //EDGE-190307 end
   },
        
   onButtonPressed: function(cmp, event, helper) {
      // Figure out which action was called
      var actionClicked = event.getSource().getLocalId();
      // Fire that action
      var navigate = cmp.get('v.navigateFlow');
      navigate(actionClicked);
   },
     navigate : function(component, event, helper) {
        var nagigateLightning = component.find('navigate');
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Account',
                   actionName: 'view',
                recordId : component.get("v.recordId"),
            }
        };
        nagigateLightning.navigate(pageReference);
    }
})

/******************** EDGE:115087 | END |***********************/