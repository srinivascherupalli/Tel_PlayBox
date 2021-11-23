/*************************************************************************************************
Name : InflightProcessHelper
TestClass:InflightProcessHelperTest
===============================================================================================================================
Sr.No.      Developer Name      Date            Story Description
1.          Gokul               02-Feb-2021     EDGE-192945
2.      Gokul        17-Feb-2021    EDGE-203212
3.          Pooja               17-Feb-2021     EDGE-201199:Inflight Basket Chatter Notification framework
===============================================================================================================================
***************************************************************************************************/    
public with sharing class InflightProcessHelper {
    
    @testVisible //EDGE-192945
    public void performInflightDiscard(cscfga__Product_Basket__c basketRecord){
        opportunity opp;
        list<csord__Order__c> ordList = new list<csord__Order__c>();
        date priorClosedDate;
        if(basketRecord.cscfga__Opportunity__c != null){
            opp = [select id,StageName,No_of_reopened_requests__c,Reopened_reason__c,CloseDate from opportunity where id =:basketRecord.cscfga__Opportunity__c]; 
            opp.StageName = 'Closed Won';
            priorClosedDate = opp.CloseDate;
            opp.No_of_reopened_requests__c = opp.No_of_reopened_requests__c - 1;
            if(opp.No_of_reopened_requests__c == 0)
                opp.Reopened_reason__c = '';
            else
                opp.Reopened_reason__c = 'Amend';
            //Start--EDGE-203212
            for(csord__Order__c ord : [select id,csordtelcoa__Participating_in_Inflight_Change__c  from csord__Order__c where csordtelcoa__Opportunity__c =:basketRecord.cscfga__Opportunity__c order by createddate desc limit 1]){
                ord.csordtelcoa__Participating_in_Inflight_Change__c  = false;  
                ordList.add(ord);
            }//EDGE-203212 - End
        }
        if(opp != null){
            update opp;
            opp.Closedate = priorClosedDate;
            update opp;
        }
        //EDGE-203212
        if(ordList != null)
            update ordList;
    }
    
    /********************************************************************************************************************************************
    * Method Name:  updateOpportunityDetails
    * Description:  To post chatter feed with @-mentions and supports formatted text messages.
                    This method is created as part of EDGE-201199. 
                    [Developer Note: Logic to post chatter feed is called within FOR loop. Assumption: Might hit the governor limit. 
                    Framework is built on top of potential identified technical debt. Method should be invoked considering limits.]
    ********************************************************************************************************************************************/    
    public static void inflightSubmitChatterNotification(List<ChatterFeedWrapper> lstFeedWrapper) {
        try {
            if(lstFeedWrapper.size() > 0) {
                for(ChatterFeedWrapper feed : lstFeedWrapper) {
                    ConnectApiHelper.postFeedItemWithMentions(feed.communityId,feed.subjectId,feed.textWithMentions);
                }
            }
        } catch (Exception e) {
            System.debug('InflightProcessHelper:Exception while posting chatter feed ' + e.getLineNumber() + ' ' + e.getMessage());
            Logger2 logger = Logger2.getlogger('InflightProcessHelper');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception while posting chatter feed', e.getLineNumber() + ' ' + e.getMessage(), false, false);
            logger.exitLogger();
        }
    }

    public class ChatterFeedWrapper {
        public String communityId;
        public String subjectId;
        public String textWithMentions;

        public ChatterFeedWrapper(String comId, String userId, String message) {
            this.communityId        =   comId;
            this.subjectId          =   userId;
            this.textWithMentions   =   message;
        }
    }

}