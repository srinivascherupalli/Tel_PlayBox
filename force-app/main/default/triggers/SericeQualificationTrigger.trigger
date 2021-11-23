/********************************************************************/
// Name:    SericeQualificationTrigger
// Description: EDGE-84619 Service Qualification Trigger
// Author:  V Ravi Shankar
// Date Created:    17-May-2019
// Revision History:
/*********************************************************************/
trigger SericeQualificationTrigger on Service_Qualification__c (before insert,after insert, after update, before update) {
    if(trigger.isAfter && trigger.isInsert){
        ServiceQualTriggerHandler.resetLatestRecFlgSrvQual(Trigger.newMap);
    }
}