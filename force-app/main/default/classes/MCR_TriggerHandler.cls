/********************************************************************************
* Class Name  : MCR_TriggerHandler
* Description : This class is the Handler Class to call other helper methods to execute the necessary logic.
* Created By  : Adityen Krishnan
* Change Log  : 18 October 2021 - Created

v1.0   18/Oct/2021  Adityen Krishnan      created as part of DIGI-25048
********************************************************************************/

public with sharing class MCR_TriggerHandler extends SYS_TriggerHandler{

    // Class variables to capture trigger context variables.
    private Map<Id, Migration_Change_Request__c> newMCRMap;
    private Map<Id, Migration_Change_Request__c> oldMCRMap;
    private List<Migration_Change_Request__c> newMCRList;
    private List<Migration_Change_Request__c> oldMCRList;


    /***************************************************************************************
    * Method Name - MCR_TriggerHandler
    * Description - Constructor method to initialise the necessary trigger context variables
    ****************************************************************************************/
    public MCR_TriggerHandler() {
        this.setHandlerName('MCR_TriggerHandler');
        this.newMCRMap = (Map<Id, Migration_Change_Request__c>) Trigger.newMap;
        this.oldMCRMap = (Map<Id, Migration_Change_Request__c>) Trigger.oldMap;
        this.newMCRList = Trigger.new;
        this.oldMCRList = Trigger.old;
    }

    /***************************************************************************************
    * Method Name - afterUpdate
    * Description - This method is used to call the after update operation on record.
    ****************************************************************************************/

    public override void afterUpdate() {
        List<Migration_Change_Request__c> newMCRListFiltered = new List<Migration_Change_Request__c>();
        System.debug('after Update----->');
        if(!newMCRList.isEmpty()) {
            for(Migration_Change_Request__c mcrObject:newMCRList){
                if(mcrObject.migration_status__c == 'Basket ready for submission'){
                    newMCRListFiltered.add(mcrObject);
                }
            }
            if(!newMCRListFiltered.isEmpty()) {
                SendChownSubRequestToBDS obj_SendChownSubRequestToBDS = new SendChownSubRequestToBDS();
                obj_SendChownSubRequestToBDS.createBDSRequest(newMCRListFiltered);
            }
        }
    }

}