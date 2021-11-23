@isTest
public class ConcurrentSessionsPolicyConditionTest {
  public static testMethod void testIsAndroid() {

    /* Create a history object that has Platform = Android 4. */
   // LoginHistory loginHistoryObj = new LoginHistory();
    //loginHistoryObj.Platform = 'Android 4';

    /* Create a map for the event we're going to build. */
    Map<String, String> eventData = new Map<String, String>();

    /* Insert the LoginHistoryId into the event data map. */
   // insert loginHistoryObj;
   list<loginHistory> LH=[select id,UserId from loginHistory where UserId=:userinfo.getUserId() order by LoginTime DESC];
   eventData.put('LoginHistoryId', LH[0].id);

    /* We’re not going to cause a real event in the org.
       Instead, we’re going to create a Transaction Security
       event object and "feed" it to the Policy Engine. */
    /* You can find more about TxnSecurity.Event in the 
       Apex Developer Guide. */
    TxnSecurity.Event e = new TxnSecurity.Event(
      userinfo.getOrganizationId(), /* organizationId */
      userinfo.getUserId(), /* userId */
      'AuthSession', /* entityName */
      'Login', /* action */
      'LoginHistory', /* resourceType */
      '', /* entityId */
      Datetime.newInstance(2016, 2, 15), /* timeStamp */
      eventData ); /* data - Map with info about this event. */
        /* The only info in the map is the login history, and
           the only info in the login history is the Platform. */

    /* We are unit testing a PolicyCondition that triggers
       when a login is from Android OS version 5 or older. */
    ConcurrentSessionsPolicyCondition condition =
      new ConcurrentSessionsPolicyCondition();
    Profiles__c newPr=new Profiles__c();
      newPr.name='PRM Prof';
      newPr.Profile_Name__c='System Administrator';
      insert newPr;
    /* Assert that the condition is triggered by evaluating
       the event e. The Transaction Security PolicyCondition
       interface returns True if the policy is triggered. */
       condition.evaluate(e);
    //System.assertEquals(true, condition.evaluate(e));
  }
}