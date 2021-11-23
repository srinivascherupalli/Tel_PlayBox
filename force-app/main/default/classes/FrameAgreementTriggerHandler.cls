/********************************************************************************************************************************************
* ModifiedBy        ModifiedDate     Edge          Description
* Parmanand Shete   16/07/2021       DIGI-724      Created new Class and Method

************************************************************************************************************************************************/
public class FrameAgreementTriggerHandler
{    
    public static Map<Id,opportunity> relatedOpportunityMap;
    public static void doInit(List<csconta__Frame_Agreement__c> newList){
        if(relatedOpportunityMap == null){
            set<Id> opptyIdSet = new set<Id>();
            for(csconta__Frame_Agreement__c fa : newList){
                if(fa.Opportunity__c!=null){
                    opptyIdSet.add(fa.Opportunity__c);
                }
            }
            relatedOpportunityMap = new Map<Id,opportunity>([select id, Name,owner.Name, Partner_Account__c from opportunity where id IN:opptyIdSet]);
        }
    }
    public static void afterUpdateHandler(List<csconta__Frame_Agreement__c> newList,Map<Id,csconta__Frame_Agreement__c> oldMap){
        FrameAgreementTriggerHelper.sendChatterNotificationOnReject(newList,oldMap);
    }
}