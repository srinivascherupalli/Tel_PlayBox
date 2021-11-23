({
   init : function(cmp, event, helper) {
      // Figure out which buttons to display
      //alert('1');

      console.log('****init firstScreen boolean***'+cmp.get("v.firstScreen"));
       // figure out which button to display on screen
      var availableActions = cmp.get('v.availableActions');
		console.log('availableActions.length*****'+availableActions.length);
       console.log('availableActions.length*****'+availableActions[0]);
       if(availableActions.length == 1 && availableActions[0] == "NEXT"){
           console.log('Available actions length is 1***');
           cmp.set("v.firstScreen",true);
       }
       else{
           console.log('Available actions length is NOT 1***');
           cmp.set("v.firstScreen", false);
       }
       //var availableActions = cmp.get('v.availableActions');

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

      /*
       
       */

   },
   // get screen source Id to figure out which action wsa called     
   onButtonPressed: function(cmp, event, helper) {
      // Figure out which action was called

      //cmp.set("v.firstScreen",false);
      console.log('****onButtonPressed firstScreen boolean***'+cmp.get("v.firstScreen"));

      var actionClicked = event.getSource().getLocalId();
      
      // Fire that action
      var navigate = cmp.get('v.navigateFlow');
      navigate(actionClicked);
   }
})