/********************************************************
Class Name : NotificationSimulationController
Test Class : NotificationSimulationControllerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Manish jha             10/04/2020       created

***************************************************************/

public with Sharing class  NotificationSimulationController {

    @AuraEnabled
    public static List < String > ParsePayload(String orderNumber, String status, String subStageName) {
        try {
            csord__Order__c order = [Select id from csord__Order__c where csord__Order_Number__c =: orderNumber];
            Map < Id, String > MOPayload = ManageOrderService.buildManageOrderPayload(new List < Id > {
                order.id
            });


            ManageOrderDataObject.ProductOrder orderDTO = new ManageOrderDataObject.ProductOrder();
            orderDTO = (ManageOrderDataObject.ProductOrder) JSON.deserialize(MOPayload.get(order.Id), ManageOrderDataObject.ProductOrder.class);
            System.debug('----' + orderDTO);
            List < Notification__c > notifRecords = new List < Notification__c > ();

            //String now = String.valueOf(System.now());

            List < Substage_Attributes__mdt > SubstageAttr = [Select label, Sub_Type__c, Attribute_Type__c from Substage_Attributes__mdt where Sub_Type__c =: subStageName];

            for (ManageOrderDataObject.OrderItemDataObject eachOI: orderDTO.orderItem) {
                Map < String, String > subStageNotifAttributes = new Map < String, String > ();
                Map < String, String > subStageOIAttributes = new Map < String, String > ();
                datetime myDateTime = datetime.now();
                String now = myDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
                Integer len = 10;

                List < ManageOrderNotificationUtil.NotificationAttributes > notifAttr = new List < ManageOrderNotificationUtil.NotificationAttributes > ();
                List < ManageOrderNotificationUtil.NotificationAttributes > OIAttr = new List < ManageOrderNotificationUtil.NotificationAttributes > ();
                If(subStageName != null && subStageName != '') {
                    ManageOrderNotificationUtil.NotificationAttributes notifAttrSubStage = new ManageOrderNotificationUtil.NotificationAttributes();
                    notifAttrSubStage.name = 'subStage';
                    notifAttrSubStage.value = substageName;
                    notifAttr.add(notifAttrSubStage);
                }
                for (Substage_Attributes__mdt eachAttr: SubstageAttr) {
                    ManageOrderNotificationUtil.NotificationAttributes notifAttrSubStage = new ManageOrderNotificationUtil.NotificationAttributes();

                    if (eachAttr.Attribute_Type__c == 'Notification' && eachAttr.label.contains('Date')) {
                        notifAttrSubStage = new ManageOrderNotificationUtil.NotificationAttributes();
                        notifAttrSubStage.name = eachAttr.Label;
                        notifAttrSubStage.value = now;
                        notifAttr.add(notifAttrSubStage);
                    } else if (substageName != null && eachAttr.Attribute_Type__c == 'Notification' && !eachAttr.label.contains('Date')) {
                        notifAttrSubStage = new ManageOrderNotificationUtil.NotificationAttributes();
                        Blob blobKey = crypto.generateAesKey(128);
                        String key = EncodingUtil.convertToHex(blobKey);
                        String pwd = key.substring(0, len);
                        notifAttrSubStage.name = eachAttr.Label;
                        notifAttrSubStage.value = pwd;
                        notifAttr.add(notifAttrSubStage);
                    } else if (eachAttr.Attribute_Type__c == 'OrderItem') {
                        notifAttrSubStage = new ManageOrderNotificationUtil.NotificationAttributes();
                        notifAttrSubStage.Name = eachAttr.Label;
                        Blob blobKey = crypto.generateAesKey(128);
                        String key = EncodingUtil.convertToHex(blobKey);
                        String pwd = key.substring(0, len);
                        notifAttrSubStage.value = pwd;
                        OIAttr.add(notifAttrSubStage);
                    }

                }
                ManageOrderNotificationUtil.NotificationAttributes forecastedDate = new ManageOrderNotificationUtil.NotificationAttributes();
                ManageOrderNotificationUtil.NotificationAttributes completionDate = new ManageOrderNotificationUtil.NotificationAttributes();
                ManageOrderNotificationUtil.NotificationAttributes ProductCompDate = new ManageOrderNotificationUtil.NotificationAttributes();
                forecastedDate.name = 'currentForecastedDeliveryDate';
                forecastedDate.value = now;
                completionDate.name = 'telstraCommittedDate';
                completionDate.value = now;
                ProductCompDate.name = 'productCompletionDate';
                ProductCompDate.value = now;
                notifAttr.add(forecastedDate);
                notifAttr.add(completionDate);
                notifAttr.add(ProductCompDate);
                Notification__c notif = new Notification__c();
                if (!String.isEmpty(subStageName))
                    notif.eventType__c = 'subStageNotification';
                else
                    notif.eventType__c = 'statusNotification';
                notif.eventTimestamp__c = String.ValueOf(System.now());
                notif.externalOrderId__c = orderNumber;
                notif.orderItemId__c = eachOI.Id;
                notif.orderItemVersion__c = 1;
                notif.sourceSystem__c = 'Fulfilment';


                notif.notificationAttributes__c = JSON.serialize(notifAttr);
                ManageOrderNotificationUtil.Product product = new ManageOrderNotificationUtil.Product();
                product.productId = eachOI.Id.substringAfterLast('|');
                product.status = status;
                product.attributes = new List < ManageOrderNotificationUtil.NotificationAttributes > ();
                System.debug('---' + OIAttr.size());
                if (OIAttr.size() > 0) {
                    product.attributes = OIAttr;
                }
                List < ManageOrderNotificationUtil.ChildProduct > childProductList = new List < ManageOrderNotificationUtil.ChildProduct > ();
                if(eachOI.Product != null && eachOI.Product.productRelationship != null){
                for (ManageOrderDataObject.ProductRelationshipDataObject child: eachOI.Product.productRelationship) {
                    ManageOrderNotificationUtil.ChildProduct childProds = new ManageOrderNotificationUtil.ChildProduct();
                    childProds.status = status;
                    childProds.productId = child.product.id;
                    childProds.attributes = new List < ManageOrderNotificationUtil.NotificationAttributes > ();
                    childProductList.add(childProds);
                }}
                product.childProduct = childProductList;
                notif.orderItemDetails__c = JSON.serialize(product);
                notifRecords.add(notif);
            }
            INSERT notifRecords;
            List < String > StringIds = new List < String > ();

            for (Notification__c notifr: notifRecords) {
                StringIds.add(notifr.Id);
            }
system.debug('StringIds'+StringIds);
            return StringIds;
        }
        Catch(Exception e) {
            List < String > errorMsg = new List < String > ();
            errorMsg.add(e.getMessage());
            return errorMsg;
        }
    }
}