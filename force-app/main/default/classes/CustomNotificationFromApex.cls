public class CustomNotificationFromApex {
	public static String sendNotifications(CustomNotificationType notificationType,
        Opportunity opp, String titleString, String messageBody) {
        String message = '';
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        obj.setNotificationTypeId(notificationType.Id);
        obj.setTargetId(opp.Id);
        obj.setTitle(titleString);
        obj.setBody(messageBody);
        try {
            obj.send(new Set<String>{opp.Proposal_Requested_User__c});
        }
        catch (Exception e) {
            message = 'Problem sending notification: ' + e.getMessage();
        }
        return message;
    }
    
    public static void sendNotificationsToBasketUser(CustomNotificationType notificationType,
        cscfga__Product_Basket__c prdBasket, String titleString, String messageBody) {
        String message = '';
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        obj.setNotificationTypeId(notificationType.Id);
        obj.setTargetId(prdBasket.Id);
        obj.setTitle(titleString);
        obj.setBody(messageBody);
        try {
            obj.send(new Set<String>{prdBasket.CreatedById});
        }
        catch (Exception e) {
            message = 'The retireve service call has been completed for the basket: ' + e.getMessage();
        }
        //return message;
       }
}