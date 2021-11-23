({
	 doInit: function(component, event, helper) {
      
  },
    
    generateNotif: function(component, event, helper){
        var ordNumber =  component.get("v.OrderNumber");
        var actType = component.get("v.TypeSelected");
        var subStage;
        if(actType==='In Progress' || actType==='Complete')
        {
            //alert('in if');
            subStage=null;
            
        }else
        {
            subStage=actType;
            actType='In Progress'
           
        }
        //alert('SubStage'+subStage);
        //alert('actType'+actType);
        //alert('ordNumber'+ordNumber);
          var action = component.get("c.ParsePayload");
          action.setParams({
          orderNumber : ordNumber,
          status : actType,
          subStageName : subStage
    });
          action.setCallback(this, function(response) {
         //alert(JSON.stringify(response));
     	  var state = response.getState();
          var notifs = JSON.stringify(response.getReturnValue());
             //alert(notifs);
              //alert(state);
              var toastEvent = $A.get("e.force:showToast");
             
           //   var toastEvent = $A.get("e.force:showToast");
           
                    console.log( "result: \n" + JSON.stringify(response.getReturnValue(), null, 2) + "\n" );
              if (state === "SUCCESS"){
                   toastEvent.setParams({
                    title : 'Success',
                    message: 'Notifications created successfully'+notifs,
                    duration:' 12000',
                    key: 'info_alt',
                    type: 'Success',
                    mode: 'dismissible'
                    });
                    toastEvent.fire();
    				
              }else
              {
                  
    				toastEvent.setParams({
                        title : 'Error',
                       message:'Unable to create notifications',
                      messageTemplate:  'Error'+notifs,
                      key: 'info_alt',
                        duration:' 8000',
                     type: 'Error',
                      mode: 'dismissible'
                
  					  });
              toastEvent.fire();
              }
        
    });
    $A.enqueueAction(action);
        
    }
})