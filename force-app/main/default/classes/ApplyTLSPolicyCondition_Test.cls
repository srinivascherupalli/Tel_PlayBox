@isTest
public class ApplyTLSPolicyCondition_Test {
  public static testMethod void testIsAndroid() {
        System.Test.startTest() ;
        LoginHistory loginHistoryObj = [ SELECT TlsProtocol,Platform FROM LoginHistory Limit 1];
        /* Create a map for the event we�re going to build. */
        Map<String, String> eventData = new Map<String, String>();
        eventData.put('LoginHistoryId', loginHistoryObj.Id);
        
        TxnSecurity.Event e = new TxnSecurity.Event(
            UserInfo.getOrganizationId(), /* organizationId */
            UserInfo.getUserId(), /* userId */
            'AuthSession', /* entityName */
            'Login', /* action */
            'LoginHistory', /* resourceType */
            'test', /* 01pR00000009D2H entityId */
            Datetime.newInstance(2018, 2, 15), /* timeStamp */
            eventData); /* data - Map with info about this event. */
        ApplyTLSPolicyCondition condition = new ApplyTLSPolicyCondition();
          condition.evaluate(e);    
          System.assert(eventData.size()>0); 
        System.Test.stopTest() ;
        
    }
}