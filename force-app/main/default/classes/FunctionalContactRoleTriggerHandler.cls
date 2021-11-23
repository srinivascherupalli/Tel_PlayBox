/****************************************************************************
@Author: Kunal Mannan
@CreateDate: 24/04/2018
@Description: FunctionalContactRoleTriggerHandler for Microservices.
@TestCoverageClass: FunctionalContactRoleTriggerTest
@ChangeLog: v1: Created
			v1.1: Modified as part of EDGE-25250 story by Nilesh Dethe
********************************************************************************/
public without sharing class FunctionalContactRoleTriggerHandler{
    
    //EDGE-25250:Variable Declaration
    FunctionalContactRoleTriggerHelper fcrHelper;

    //EDGE-25250:Consturctor for initialization of variables
    public FunctionalContactRoleTriggerHandler(){
        fcrHelper = new FunctionalContactRoleTriggerHelper();
    }
    //EDGE-25250(AC2): Added new parameter to the method "newMap"
    public void onAfterInsert(List<Functional_Contact_Role__c> newList,Map<Id,Functional_Contact_Role__c> newFCRMap){
        //EDGE-25250: Added method calls
        //EDGE-25250: This method needs to be call before calling below all validate* method.
        fcrHelper.seperateFCRPerRecordType(newFCRMap);
        fcrHelper.validateFCRSiteRole();
        fcrHelper.validateFCROrderBasketRole();
        fcrHelper.validateFCRSubcriptionRole();
        publishCreateEvents(newList,EventConstants.UPDATE_OPERATION);
    }
    
    public void onAfterUpdate(List<Functional_Contact_Role__c> newList){
        publishCreateEvents(newList,EventConstants.UPDATE_OPERATION);
    }
    
    private void publishCreateEvents(List<Functional_Contact_Role__c> newList,String event){
        //Dynamic Binding
        PublishEvents publishIntface=PublishEventsImpl.getInstance();
        publishIntface.createEventObject(newList,EventConstants.BUSINESS_ENTITY_CONTACT,event);
        publishIntface.createEvent();
    }
    //EDGE-25250 (AC1) - The method to handle before insert event of the trigger.
    public void onBeforeInsert(List<Functional_Contact_Role__c> lstNewFCR)
    {	
        fcrHelper.validateFCRBillingContact(lstNewFCR);
         //EDGE-41494 AC3 : Only one order with 'Order Primary Contact' can be added
        fcrHelper.validateOrderPrimaryContact(lstNewFCR);
        fcrHelper.validateFCRContract(lstNewFCR);
        
    }
}