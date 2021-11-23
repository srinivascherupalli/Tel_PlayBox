({
	doInit : function(component, event, helper) {
        helper.getCommunityUrl(component,event);//EDGE-218031 : vivek
		helper.init(component, event, helper);
	},
   
 //START EDGE-198374 - Feedback Case Creation 
    createSupportCase: function (component, event, helper) {
        component.set("v.loadingSpinner", true);
        var basketIdVal = component.get("v.basketId"); 
        var cidnNumberVal = component.get("v.cidn"); 
        var transactionIdVal = component.get("v.transitionId"); 
        var fnnListVal = component.get("v.fnnsList"); 
       
        var action = component.get("c.createFeedbackCase"); 
        action.setParams({"basketId": basketIdVal,
                          "cidnNumber": cidnNumberVal,
                          "transactionId": transactionIdVal, 
                          "fnnList": JSON.stringify(fnnListVal)});
        action.setCallback(this, function (response) {
            var state = response.getState();
          
            if (state === "SUCCESS") {
                var caseRec = response.getReturnValue();
               
                component.set("v.caseId",caseRec.Id);
                component.set("v.CaseNumber",caseRec.CaseNumber);
                component.set("v.isCaseCreated",true);  
                component.set("v.isModalOpen", true);                
                component.set("v.loadingSpinner", false);
            }
            else if (state === "ERROR") {             
               component.set("v.loadingSpinner", false);              
            }
        });
        $A.enqueueAction(action);
    },
    handleClick : function(component, event, helper) {
       
		var recordId = component.get("v.caseId");
        console.log('caseRec Id@@' + recordId);
        var communityUrl = component.get('v.CommunityUrl');
        if(communityUrl == null || communityUrl == ''){
            window.open('/' + recordId,'_blank');       
        } 
         else{
            window.open(communityUrl+'s/case/'+ recordId,'_blank');
        } 
    },
    closeModel: function(component, event, helper) {      
      component.set("v.isModalOpen", false);
    },
    //END EDGE-198374
    
    /* EDGE-195766 Starts here */
    getServices : function (component, event, helper) {      
        component.set("v.loadingFixedSpinner", true);        
       	//helper.updateProdBasketToCheckEligibility(component, event, helper);
        helper.getServicesHelper(component, event);	        
    },
    
    refreshLoader : function (component, event, helper) {
        component.set("v.showRing", true);
        component.set("v.loadingFixedSpinner", true);
        var callFrom = component.get("v.selectedTab");
        console.log('@V@ callFrom ', callFrom);
        
        if(callFrom == 'Mobile'){
            console.log('Inside Mobile');
            var actionMobile = component.get("c.getEligibilityStatusMobile");
            actionMobile.setParams({
                basketId: component.get("v.basketId")
            });
            actionMobile.setCallback(this, function(response) {
                var data = response.getReturnValue();
                component.set("v.ProdBasket", response.getReturnValue());
                var productBasket = component.get("v.ProdBasket");
                console.log('@V@ Return Value from MobileTramas::' +data);
            });
            $A.enqueueAction(actionMobile);
        }
        
        else{
            console.log('Inside Nguc');
            var action = component.get("c.getEligibityStatus");
            action.setParams({
                basketId: component.get("v.basketId")
            });
            action.setCallback(this, function(response) {
                var data = response.getReturnValue();
                if (response.getState() == "SUCCESS" && data != null) {
                    var statusMap = Object.entries(data);
                    component.set("v.value", data[1]);
                    component.set("v.valuemax", data[0]);
                    var productBasket = component.get("v.ProdBasket");
                }
                if (data[0] == data[1]) {
                    
                }
                else {
                    component.set("v.showProgressRing", true);
                }
            });
            $A.enqueueAction(action);
        }
        
        helper.refreshAction(component,event,helper); 
    },
    /* EDGE-195766 Ends here */
    /* EDGE-203927 */
	transitionRowSelection: function (component, event, helper){
        helper.handlerTransRowSelected(component, event, helper);
    },
     //203932-Dheeraj Bhatt-Refresh Transition Screen on Assignment or un-Assignment of number from PC
    handleRefreshTransitionTableEvt: function (component, event, helper){
        helper.handleRefreshTransitionTableEvt(component, event, helper);
    }
    
})