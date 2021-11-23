/***************************************************************************************************************************************
* Class Name    :   ChatterUtilityClass
* Test Class    :   ChatterUtilityClassTest
Sl.No.  Developer Name      Date            Story Description
1.      Pooja Bhat          22/04/2021      EDGE-212439 - As a User, I should receive Chatter Notification if CoBA request fails/Errors
****************************************************************************************************************************************/
public with sharing class ChatterUtilityClass {
    
    //Added for exception handling
    private static String correlationId =   GuidUtil.NewGuid();
    private static String className     =   'ChatterUtilityClass';

    /*  
     * Wrapper Class: ChatterFeedWrapper  
     * Description  : Use this class to construct chatter feed.
    */
    public class ChatterFeedWrapper {
        public String communityId;
        public String subjectId;
        public String textWithMentions;

        public ChatterFeedWrapper(String comId, String userId, String message) {
            this.communityId        =   comId;
            this.subjectId          =   userId;
            this.textWithMentions   =   message;
        }
    }   //End of ChatterFeedWrapper

    /********************************************************************************************************************************************
    * Method Name:  chatterNotificationHelper
    * Description:  To post chatter feed with @-mentions and supports formatted text messages.
                    [Developer Note: Logic to post chatter feed is called within FOR loop. Assumption: Might hit the governor limit. 
                    Framework is built on top of potential identified technical debt. Method should be invoked considering limits.]
    ********************************************************************************************************************************************/    
    public static void chatterNotificationHelper(List<ChatterUtilityClass.ChatterFeedWrapper> lstFeedWrapper) {
        try {
            if(lstFeedWrapper !=null && !lstFeedWrapper.isEmpty()) {
                for(ChatterUtilityClass.ChatterFeedWrapper feed : lstFeedWrapper) {
                    ConnectApiHelper.postFeedItemWithMentions(feed.communityId,feed.subjectId,feed.textWithMentions);
                }
            }
        } catch (Exception e) {
            GenericUtilityClass.logException(className,'chatterNotificationHelper','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured while posting chatter feed',null);
        }
    }
    
}   //End of ChatterUtilityClass