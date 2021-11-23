/*
 * History of Modifications : 
 * 1. 9-April-2020  :   Ritika Jaiswal  : P2OB - 26 : checkValidateContactRole is made public to execute the validation-check in test-class
 * */
public class OpportunityTriggernewhandler {
    
    private OpportunityTriggernewHelper OpportunityTriggernewHelperObj = null;
    //Ritika Jaiswal    : P2OB - 26 - Made testVisible for test method in OpportunityTriggerTest
    @TestVisible private static Boolean checkValidateContactRole = true;
    
    public OpportunityTriggernewhandler(){
        OpportunityTriggernewHelperObj = new OpportunityTriggernewHelper();
    }

    /*
    public void OnAfterInsert(Opportunity[] newOpportunities){
        System.debug('OnAfterInsert : ' + newOpportunities);
        OpportunityTriggernewHelperObj.errormsg(newOpportunities);
    }
    
    public void OnBeforeUpdate(Opportunity[] newOpportunities){
        System.debug('OnBeforeUpdate : ' + newOpportunities);
        OpportunityTriggernewHelperObj.errormsg(newOpportunities);
    }
*/

    public void OnAfterInsert(Opportunity[] newOpportunities){
        System.debug('OnAfterInsert : ' + newOpportunities);
    }

    public void onBeforeInsert(Opportunity[] newOpportunities){
        	OpportunityTriggernewHelperObj.updatePORStatus(newOpportunities,null);//EDGE-151595
    }
    
    public void OnBeforeUpdate(Map<Id,Opportunity> newMapOpps,Map<Id,Opportunity> oldMapOpps,Opportunity[] newOpportunities){
        OpportunityTriggernewHelperObj.updatePORStatus(newOpportunities,oldMapOpps);//EDGE-151595
        if(runOnceValidateContactRole()){

            OpportunityTriggernewHelperObj.updatePORStatus(newOpportunities,oldMapOpps);//EDGE-151595

            OpportunityTriggernewHelperObj.validateContactrole(newMapOpps,oldMapOpps,newOpportunities);
        }
    }
    
     public static Boolean runOnceValidateContactRole(){
        if(checkValidateContactRole){
            checkValidateContactRole = false;
            return true;
        }
        else
            return checkValidateContactRole;
    }    
}