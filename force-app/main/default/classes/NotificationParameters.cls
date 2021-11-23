/*********************************************************************************************************************************
*Class Name      :   NotificationParameters
Test Class : OrderNotificationEventHandlerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Prajakta             22/2/2020               EDGE-115932
2.           Prajakta Patil        21/04/2020         Billing Notification Fix
*********************************************************************************************************************************
*/
 
public class NotificationParameters {
  @InvocableVariable
  public String orderItemId;
  @InvocableVariable
  public String notificationAttributes;
  @InvocableVariable
  public String eventType;
  @InvocableVariable
  public String orderItemDetails;
  @InvocableVariable
  public String sourceSystem;
  @InvocableVariable
  public String errorDetails;
  @InvocableVariable
  public String externalOrderId;
  @InvocableVariable
  public Integer orderItemVersion;
  @InvocableVariable
  public String eventTimestamp;
  @InvocableVariable
  public String msCorrelationId;
  @InvocableVariable
  public Integer sequence;
  @InvocableVariable
  public String notificationId;
  @InvocableVariable
  public Integer externalOrderVersion;
  @InvocableVariable
  public String subscriptionDetails;
  
  @InvocableVariable
  public ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttributes ;
  
  public static void testdata(){
      
  }       
  
}