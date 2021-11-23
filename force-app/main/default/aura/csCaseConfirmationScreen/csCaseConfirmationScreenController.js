({
	init : function(cmp, event, helper) {
        //get custom message from the custom label
        var msg = $A.get("{!$Label.c.csSuccessMessage}");
        var newLine = msg.split("<br/>");
       var x = cmp.get("v.caseRecordId");
         var linkCase = cmp.get("v.linkedCases");



         console.log('link case'+linkCase);
       cmp.set("v.successMsg1",newLine[1]);
         cmp.set("v.successMsg",newLine[0]);
        cmp.set("v.linkedCases",linkCase);
        console.log('::currentUser'+cmp.get("v.currentUser"));
        
        var action = cmp.get("c.returnBaseUrl");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('RETURNED BASE URL*****'+response.getReturnValue());
                
                cmp.set('v.communityBaseURL',response.getReturnValue()+'/s');
            }
        });
        $A.enqueueAction(action);
        
	},
    //redirect to parent account on click of Done button
    closeModal : function(cmp, event, helper) {


        var uType;
        console.log("###############");
        var action1 = cmp.get("c.returnUserInfo");
        action1.setCallback(this, function(response){
            var states = response.getState();
            if (states === "SUCCESS") {
                console.log('RETURNED BASE URL*****'+response.getReturnValue());
                uType = response.getReturnValue();


                console.log("#usertype "+ uType);
                if(uType == 'PowerPartner'){
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }else{



        var acc = cmp.get("v.accountId");
    var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": acc,
          "slideDevName": "detail"
        });
        navEvt.fire();
        cmp.set("v.showModal",false);



                    console.log("****Inside Else*****");
                }
            }
        });
        $A.enqueueAction(action1);
        
        
           
        //var dismissActionPanel = $A.get("e.force:closeQuickAction");
        //dismissActionPanel.fire();
       // $A.get("e.force:closeQuickAction").fire();
        



	},
    //Publish Event and pass case recordID along with Origin
    evtSub : function(cmp, event){
		var appEvent = $A.get("e.c:jprScreenNavigationEvent"); 
        appEvent.setParams({"CaseId" : cmp.get("v.caseRecordId"),"Origin" : "last"}); 
		appEvent.fire();
    }
})