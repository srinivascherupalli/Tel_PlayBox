/****************************************************************************
@Name       :   Funnel Scorecard
@Author     :   Pallavi/Amar(Team SFO)
@CreateDate :   11/11/2020
@Description:   Sprint 20.15 ; P2OB-7883, 
                This component is used on Opportunity (Standard & Custom Record Types) 
                to create Bluesheet record and to calculate/update Scorecard on Blue sheet and show it on Dashboard (developer by Einstein) 
                on opportunity flexipages.
                Sprint 21.03 ; P2OB-12665(Bug)
                Made changes to refresh/Hide Funnel Score card Component When Opportunity is closed Lost/Won,Cancelled.
                And also when there is not Blule Sheet Record
*****************************************************************************/
// Below method gets questions need to be displayed from server side controller and displays .
({	
    getCriteria: function(component) {
        component.set('v.IsSpinner', true);
        var action = component.get('c.getCriteria');
        action.setParams({
            'blueSheetId' : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            component.set('v.criteria', response.getReturnValue());
            component.set('v.IsSpinner', false);
        });
        $A.enqueueAction(action);
    },
    //Moved code from controller to helper as part of Funnel score full launch P2OB-12665(Bug) Sprint 21.03
    callDoInitHelper: function(component) {
        var filterString = component.get("v.filterString");
        filterString = filterString.replace('#OppId#', component.get("v.recordId"));
        component.set("v.filterString",filterString);   
        console.warn('Value of filterstring is'+filterString);
        this.BSRecordCheck(component);
    },
    // Below method Saves the responses(only Yes) and caluculates Score card(happens in server side conteoller) and refreshes total page . 
    saveCriteria: function(component, selectedResponses) {
        var action = component.get('c.saveCriteria');
        action.setParams({
            'selectedResponses' : selectedResponses
        });
        
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS'){
                console.log("Success Response");
                window.location.reload()
                component.set("v.isOpen", false);
                
            }else{
                console.log("FailureResponse");
            }   
        });
        $A.enqueueAction(action);
    },
    // Below method is used to show create score button when there is no blue sheet record associated on opportunity and also when opty is not closed Won/closed Lost/Cancelled.
    BSRecordCheck: function(component){
        var action = component.get('c.bsRecordCheck');
        action.setParams({
            'oppId' : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            component.set('v.bsRecordNotExist', response.getReturnValue());
            //Modified as part of P2OB-11273.Starts Here
            var OpportunityStageName = component.get("v.OpportunityRecord.StageName");
            if((OpportunityStageName !=$A.get("$Label.c.Opp_Stage_ClosedWon"))&&(OpportunityStageName !=$A.get("$Label.c.Opp_Stage_ClosedLost"))&&(OpportunityStageName !=$A.get("$Label.c.Opp_Stage_Cancelled"))&&response.getReturnValue()){
                component.set('v.createBlueSheetCheck', true);
                component.set('v.editBluesheetCheck', false);
                component.set('v.showComponent', true); //Added as part of Funnel score full launch P2OB-12665(Bug) Sprint 21.03
            }else if((OpportunityStageName !=$A.get("$Label.c.Opp_Stage_ClosedWon"))&&(OpportunityStageName !=$A.get("$Label.c.Opp_Stage_ClosedLost"))&&(OpportunityStageName !=$A.get("$Label.c.Opp_Stage_Cancelled"))&& !(response.getReturnValue())){                
                component.set('v.createBlueSheetCheck', false);
                component.set('v.editBluesheetCheck', true);
                //Added as part of Funnel score full launch P2OB-12665(Bug) Sprint 21.03 to refresh component when opty id closed won/lost/cancelled. Starts here.
                component.set('v.showComponent', true); 
            }else if(((OpportunityStageName ==$A.get("$Label.c.Opp_Stage_ClosedWon")) || (OpportunityStageName ==$A.get("$Label.c.Opp_Stage_ClosedLost")) || (OpportunityStageName ==$A.get("$Label.c.Opp_Stage_Cancelled")))&& !(response.getReturnValue())){
                component.set('v.createBlueSheetCheck', false);
                component.set('v.editBluesheetCheck', false);
                component.set('v.showComponent', true); 
            }else{
                component.set('v.showComponent', false); 
            }
        });
        //changes ends here made as part of Funnel score full launch P2OB-12665(Bug) Sprint 21.03.
        $A.enqueueAction(action);
    },
    
    closeModal: function(component) {
       $A.get("e.force:closeQuickAction").fire();
    }
    
})