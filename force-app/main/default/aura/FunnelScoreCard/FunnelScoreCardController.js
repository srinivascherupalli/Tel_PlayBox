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
({
    //This function calls BSRecordCheck from helper on Load
    //Moved code to helper(callDoInitHelper) as part of Funnel score full launch P2OB-12665(Bug) Sprint 21.03
    doInit: function(component, event, helper) {
          helper.callDoInitHelper(component);
    },
    
	openModel: function(component, event, helper) {      
      //This function calls getcriteria method to display list of questions
          helper.getCriteria(component);  
          component.set("v.isOpen", true);
          document.body.style.overflow = 'hidden';
    },
    
    //This function calls savecriteria method to save responses(yes only) of questions and calculate scorecard 
    doSave: function(component, event, helper) {
       
        var optionList = component.find("optionList");
        var selectedResponses = [];
        for(var i=0; i < optionList.length; i++){
            selectedResponses.push(optionList[i].get("v.name") + ':' + optionList[i].get("v.value"));    
        }
        console.log('selectedResponses : '+selectedResponses);
        
        helper.saveCriteria(component, selectedResponses);
		document.body.style.overflow = 'auto';
        
    },
   
   	doCancel: function(component, event, helper) {
        helper.closeModal(component);
    },
    
    closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
        document.body.style.overflow = 'auto';
   }
})