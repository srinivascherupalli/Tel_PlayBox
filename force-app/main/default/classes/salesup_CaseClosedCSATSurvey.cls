/*
* Created By: Sandeep Soni
* Story Number: P2OB:931
* Description: This class will be call from Send Case Closed CSAT Survey(Process builder) for sending survey invitation.
*/
public Without Sharing class salesup_CaseClosedCSATSurvey {
    
    /*
    * Method Name: invokeSurveyFlows
    * Created By: Sandeep Soni 
    * Story Number: P2OB:931
    * Description: This method will be call from Send Case Closed CSAT Survey(Process builder) and it will call to visual
    *  flow(Create Case Closed Survey Invitation)
    */
    @invocableMethod
    public static void invokeSurveyFlows(List<Case> lstCase){
        String objectId,surveyName,surveyParentObjName,surveyType;
        if(lstCase!=null && lstCase.size()>0 && lstCase.get(0)!=null){
            objectId = lstCase.get(0).Id;
            surveyName = Label.Salesup_SurveyName;//'Sales Support Case Closed CSAT Survey';
            surveyParentObjName= 'Case';
            surveyType = Label.Salesup_surveyType;//'Sales Support Case Closed CSAT Survey';
            invokeCloseSurveyInvitationFlow(objectId,surveyName,surveyParentObjName,surveyType);
        }
        
    }
    /*
    * Method Name: invokeCloseSurveyInvitationFlow
    * Created By: Sandeep Soni 
    * Story Number: P2OB:931
    * Description: This method will to visual
    *  flow(Create Case Closed Survey Invitation)
    */
    @Future
    public static void invokeCloseSurveyInvitationFlow(String objectId, String surveyName, String surveyParentObjName, String surveyType){
        // Call the Flow
        System.debug('objectId'+objectId);
         System.debug('SurveyName'+surveyName);
         System.debug('surveyType'+surveyType);
        Map<String, Object> params = new Map<String, Object>();
        params.put('ObjectId', objectId);
        params.put('SurveyName', surveyName);
        params.put('SurveyParentObjectName', surveyParentObjName);
        params.put('SurveyType', surveyType);
        Flow.Interview.Create_Case_Closed_Survey_Invitation calcFlow = new Flow.Interview.Create_Case_Closed_Survey_Invitation(params);
        if ( !Test.isRunningTest() ){
            calcFlow.start(); 
        }
    }
}