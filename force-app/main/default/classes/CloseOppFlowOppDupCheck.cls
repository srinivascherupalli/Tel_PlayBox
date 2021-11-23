/* **********************************************************************************************************
Sprint        	- SFO Sprint 20.17, P2OB-11314.
Component     	- OpportunityDuplicateRuleCheck
Description	- Invoked from Close Opportunity Flow and Called OpportunityDuplicateRuleCheck
Author      	- Amar Chakka. 
************************************************************************************************************ */

public without sharing class CloseOppFlowOppDupCheck {

/* **********************************************************************************************************
Sprint        	- SFO Sprint 20.17, P2OB-11314.
Component     	- OpportunityDuplicateRuleCheck
Descriptionc	- Method Invoked from Opportunity Duplicate Rule LWC Component and CloseOppFlowOppDupCheck Class(CloseOpportunity Flow)
Author      	- Amar Chakka. 
************************************************************************************************************ */

	@InvocableMethod(label = 'Invoke Apex')
    public static list<FlowOutputs> invokeThisFromFlow(list<FlowInputs> flwip){
        list<FlowOutputs> lflowotps = new list<FlowOutputs>();
        try{
			for(FlowInputs str : flwip){   // start of for loop
			    	lflowotps.add(invokeLocalMethodWon(str));
			}
        }catch(Exception Ex){     // End of For Loop
			system.debug('Exception:::: CloseOppFlowOppDupCheck :::: invokeThisFromFlow Method'+ Ex.getMessage());
		}
    return lflowotps;
    }
    
/* **********************************************************************************************************
Sprint        	- SFO Sprint 20.17, P2OB-11314.
Component     	- OpportunityDuplicateRuleCheck
Description	    - Method which returns Opportunity Manger Info and checks the duplicate Opportunity by calling OpportunityDuplicateRuleCheck Class
Author      	- Amar Chakka. 
************************************************************************************************************ */

    
    public static FlowOutputs invokeLocalMethodWon(FlowInputs req){
        FlowOutputs flops = new FlowOutputs();
	    OpportunityDuplicateRuleCheck.OppInfo odrch = OpportunityDuplicateRuleCheck.dupOppCheck(req.oppId);
	    flops.oppDuplicateCheck = odrch.duplicateOpp;
        if(flops.oppDuplicateCheck){
			Opportunity opp = [SELECT Owner.ManagerId from Opportunity where Id =: req.oppId];
			flops.oppOwnerManager = opp.Owner.ManagerId;
        }
        return flops;
    }

/* **********************************************************************************************************
Sprint        	- SFO Sprint 20.17, P2OB-11314.
Component     	- OpportunityDuplicateRuleCheck
Description	    - Wrapper Class which accepts flow inputs 
Author      	- Amar Chakka. 
************************************************************************************************************ */    
    public class FlowInputs{
        @InvocableVariable
		public string oppId;
     }

/* **********************************************************************************************************
Sprint        	- SFO Sprint 20.17, P2OB-11314.
Component     	- OpportunityDuplicateRuleCheck
Description	    - Wrapper Class which sends flow outputs
Author      	- Amar Chakka. 
************************************************************************************************************ */        
    public class FlowOutputs{
        @InvocableVariable
	    public boolean oppDuplicateCheck; // Sprint 20.17 - SFO - P2OB - 11314. Variable to hold Opportunity Duplicate Check. 
	    @InvocableVariable
	    public string oppOwnerManager; // Sprint 20.17 - SFO - P2OB - 11314. Variable to hold Opportunity Manager Info.
     }
}