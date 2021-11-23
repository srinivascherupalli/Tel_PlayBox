/****************************************************************************
@Author: Maq
@CreateDate: 08/11/2018.
@Description: ContractJunctionTrigger trigger to handle delete event.
@TestCoverageClass: ContractJunctionTriggerHandlerTest
@ChangeLog: v1 - Created
********************************************************************************/
public with sharing class ContractJunctionTriggerHandler {
    ContractJunctionTriggerHelper conJunHelper;
    
    //Consturctor for initialization of variables
    public ContractJunctionTriggerHandler(){
        System.debug('In ContractJunctionTriggerHandler----->>>>>');
        conJunHelper = new ContractJunctionTriggerHelper(); 
    }
    
    public void onBeforeDelete(List<ContractJunction__c> newList,Map<Id,ContractJunction__c> newFCRMap, List<ContractJunction__c> oldList,Map<Id,ContractJunction__c> oldFCRMap){
        conJunHelper.FCRRecordRelatedToContract(newList,newFCRMap, oldList, oldFCRMap);
    }
/* ****************************************************************************
 * Author : Manoj Kumar : EDGE-81053
 * Date : 26 July 2019
 * Description : Handler method on after update trigger Scenario
 * Parameters : New List,New Map,Old List,Old Map 
 * *****************************************************************************/
     public void onAfterUpdate(List<ContractJunction__c> newList,Map<Id,ContractJunction__c> newMap, List<ContractJunction__c> oldList,Map<Id,ContractJunction__c> oldMap){
           
         //EDGE-190304
         conJunHelper.createFlexiOneFund(newList,oldMap); 
         conJunHelper.sendNotifyOrCISEmailService(newList,oldMap); //EDGE-207342 Added Changes
    }    
    
    /* ****************************************************************************
 * Author : Rahul Asarma : EDGE-207342
 * Date : 26 April 2021
 * Description : Handler method on after insert trigger Scenario
 * Parameters : New List,New Map 
 * *****************************************************************************/
     public void onAfterInsert(List<ContractJunction__c> newList,Map<Id,ContractJunction__c> newMap){
           
         conJunHelper.sendNotifyOrCISEmailService(newList,null); 
    }    
    
}