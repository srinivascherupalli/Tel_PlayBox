/********************************************************************************************************************************************
* ModifiedBy        ModifiedDate     Edge          Description
* Parmanand Shete   16/07/2021       DIGI-724      Created new Class and Method

************************************************************************************************************************************************/
public class FrameAgreementTriggerHelper
{    
    /*Parmanand Shete : DIGI-724
    Test class : FrameAgreementTriggerHandlerTest.testRejectFACase*/
    public static void sendChatterNotificationOnReject(List<csconta__Frame_Agreement__c> newList,Map<Id,csconta__Frame_Agreement__c> oldMap){
        for(csconta__Frame_Agreement__c fa : newList){
            csconta__Frame_Agreement__c oldFa = oldMap.get(fa.Id);
            opportunity opp = FrameAgreementTriggerHandler.relatedOpportunityMap.get(fa.Opportunity__c);
            if(fa.csconta__Status__c == 'Rejected' && fa.csconta__Status__c != oldFa.csconta__Status__c && fa.isPrimary__c && opp!=null && opp.Partner_Account__c!=null){
                String str = fa.id+'!Dear '+opp.owner.Name+', \nFrame Agreement# '+fa.Name+' has been rejected.\nPlease click the following link to go to the FA\n'+fa.FA_PRM_URL__c;
                list<string> strlist= new list<string>();
                strlist.add(str);
                ManageChatterPosts.PostChatterMessage(strlist); 
            }
        }
    }
}