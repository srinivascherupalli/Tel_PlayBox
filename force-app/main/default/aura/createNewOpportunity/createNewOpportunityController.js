/****************************************************************************
@Name       :   createNewOpportunity
@Author     :   Sri(Team SFO)
@CreateDate :   02/04/2021
@Description:   Sprint 21.02 ; P2OB-12195 && P2OB-12196 

@LastModified:  Sprint 21.03, P2OB-12586 :: Handled mobile and desktop's behaviour
				And invoking from Global action behaviour

*****************************************************************************/
({
    init : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");

        var device = $A.get("$Browser.formFactor");
        var accId  = null;
        
        if(sObjectName == "Opportunity"){
            component.set("v.isModalOpen", true);

            //This is to capture the accountid from where this component is invoked
            //For mobile app it won't support the pagereference
            if(device == 'DESKTOP'){

            var pageRef = component.get("v.pageReference");
            var state = pageRef.state; // state holds any query params
            var base64Context = state.inContextOfRef;
            
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));

                accId = addressableContext.attributes.recordId;
                component.set("v.relatedAccountId",accId);
                
                }

            var flow = component.find("flowDataModal");
            var flowInputs =[{
                name : "selaccountId",
                type : "String",
                value : accId
            }];

            if(accId != null){
	            //Desktop Opportunity Creation via Account -> Related opportunities -> New 
                flow.startFlow("New_Opportunity",flowInputs);
            }else{ 
                //Mobile's Opportunity Creation via Account -> Related opportunities -> New
                //Mobile's Opportunity Creation via Opportunities -> Recently Viewed -> New
                //Desktop's Opportunity Creation via Opportunities -> Recently Viewed -> New 
                flow.startFlow("New_Opportunity");
            }
        }else{
            //Opportunity Creation via Global quick action -> New Opportunity

            var flow = component.find("flowDataGlobalAction");
            flow.startFlow("New_Opportunity");
            
        }
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        var accId = component.get("v.relatedAccountId");
        if(accId == null){
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": "Opportunity"
            });
            homeEvent.fire();
        }else {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": accId,
              "slideDevName": "related"
            });
            navEvt.fire();
        }

        $A.get('e.force:refreshView').fire();
    },
    
    
})