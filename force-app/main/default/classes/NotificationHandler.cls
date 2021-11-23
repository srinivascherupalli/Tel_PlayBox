/****
 * Created By : Madhu Rathi
 * Date : 16/05/018
 * Description: handler class for handling trigger on Notification Object.
 * *****/
 public with sharing class NotificationHandler {
    //handler Method to validated new notification records
    public static Boolean temp = true;
    public static void validateNotificationFields(list<Notification__c> newNotifications){
		temp = true;
    	String error = '';
        List<Notification__c> NotificationList = new List<Notification__c>();
        Map<String,Notification_Handler__mdt> notificationAttMap=new Map<String,Notification_Handler__mdt>();
            
        String queryNotificationMdtStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Notification_Handler__mdt')) + '\n ' +
                          ' FROM Notification_Handler__mdt \n ';
        List<Notification_Handler__mdt> notificationAttrRecordList = Database.query(queryNotificationMdtStr); 
        if(notificationAttrRecordList == null || notificationAttrRecordList.isEmpty()){
            System.debug('No notification settings found.');
           
        } else if(!notificationAttrRecordList.isEmpty()){
            for(Notification_Handler__mdt notificationAtt: notificationAttrRecordList){
                notificationAttMap.put(notificationAtt.DeveloperName, notificationAtt);
            }

        }
        system.debug('=====notificationAtt-===='+notificationAttMap.keyset());
        List<String> orderNumbersList = new List<String>();
        List<String> serviceNumbersList = new List<String>();
        List<String> appSlotIdList = new List<String>();
        List<String> eventIdList = new List<String>();
        for(Notification__c notificationObj:newNotifications){
            if(notificationAttMap.get(notificationObj.eventtype__c+notificationObj.sourcesystem__c)!=null && notificationObj.orderItemId__c!=null){
                if(notificationObj.eventtype__c == 'appointmentNotification' && notificationObj.sourcesystem__c == 'Fulfilment'){
                    appSlotIdList.add(notificationObj.orderItemId__c);
                } else if((notificationObj.eventtype__c == 'statusNotification'||notificationObj.eventtype__c == 'delay' || notificationObj.eventtype__c == 'milestoneNotification') && notificationObj.sourcesystem__c == 'Fulfilment'){
                    if(Pattern.matches('^[A-Za-z0-9_-]+\\|[A-Za-z0-9_-]+\\|[A-Za-z0-9_-]+$', notificationObj.orderItemId__c)){
                        orderNumbersList.add(notificationObj.orderItemId__c.split('\\|')[0]);
                        serviceNumbersList.add(notificationObj.orderItemId__c.split('\\|')[1]);
                    }
                    else{
                    	error = 'orderItemId';
                        notificationObj.addError(error+': Bad/Incorrect format!');
                        temp = false; 
                    }
                }else if(notificationObj.eventtype__c!=null && notificationObj.sourcesystem__c == 'Billing'){
                    eventIdList.add(notificationObj.orderItemId__c);
                }     
            }
        }
        Map<String, Appointment__c> appointmentMap = new Map<String, Appointment__c>();
        List<Appointment__c> apptList = [SELECT Id,SlotId__c FROM Appointment__c WHERE  SlotId__c IN: appSlotIdList];
        for(Appointment__c appt: apptList){
            appointmentMap.put(String.valueof(appt.SlotId__c), appt);
        }
        
        Map<String, csord__Order__c> orderMap = new Map<String, csord__Order__c>();
        Map<id, List<String>> orderServiceMap = new Map<id, List<String>>();
        Map<String,List<String>> servToSpecMap = new Map<String,List<String>>();
        List<csord__Order__c> orderList = [SELECT id, csord__Order_Number__c FROM csord__Order__c WHERE csord__Order_Number__c IN:orderNumbersList];
        List<csord__Service__c> srvcList =[SELECT id, csord__Order__r.csord__Order_Number__c, csord__Order__r.csord__Primary_Order__r.csord__Order_Number__c, csordtelcoa__Service_Number__c,csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Order_Number__c, csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Primary_Order__r.csord__Order_Number__c FROM csord__Service__c where csordtelcoa__Service_Number__c IN: serviceNumbersList];
            
        for(csord__Order__c orderObj: orderList){
            orderMap.put(orderObj.csord__Order_Number__c,orderObj);
            List<String> srvcNumbers = new List<String>();
            for(csord__Service__c srv: srvcList){
            	if(srv.csord__Order__r.csord__Order_Number__c == orderObj.csord__Order_Number__c || srv.csord__Order__r.csord__Primary_Order__r.csord__Order_Number__c == orderObj.csord__Order_Number__c || srv.csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Order_Number__c==orderObj.csord__Order_Number__c || srv.csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Primary_Order__r.csord__Order_Number__c == orderObj.csord__Order_Number__c){
	           		srvcNumbers.add(srv.csordtelcoa__Service_Number__c);
	           		List<String> servSpecList = new List<String>();
	                String json = csedm.API_1.getServiceSpecificationsById(srv.id);
	                if(String.isNotEmpty(json)) {
	                    List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
	                    srvSpecList = CS_SpecificationDTO.parseServiceSpec(json, 'FULFILMENT');
	                    for(CS_SpecificationDTO.ServiceSpecification serSpec : srvSpecList) {
	                        servSpecList.add(serSpec.guid);
	                    }
	                }
	                servToSpecMap.put(srv.csordtelcoa__Service_Number__c, servSpecList);  
            	}
            }
            orderServiceMap.put(orderObj.id,srvcNumbers);
        }
 
        
        Map<String, csord__Subscription__c> subscriptionMap = new Map<String, csord__Subscription__c>();
        List<csord__Subscription__c> subsList = [SELECT Id,eventId__c FROM csord__Subscription__c WHERE eventId__c IN:eventIdList];
        for(csord__Subscription__c sub: subsList){
            subscriptionMap.put(sub.eventId__c, sub);
        }
        
        for(Notification__c notificationObj:newNotifications){   
            if((notificationObj.eventType__c ==null) || 
            (notificationObj.sourceSystem__c ==null) ||
            (notificationObj.eventTimeStamp__c ==null && notificationAttMap.get(notificationObj.eventtype__c+notificationObj.sourcesystem__c).eventTimeStamp__c==true) || 
            (notificationObj.externalOrderId__c ==null && notificationAttMap.get(notificationObj.eventtype__c+notificationObj.sourcesystem__c).externalOrderId__c==true) || 
            (notificationObj.orderItemId__c ==null && notificationAttMap.get(notificationObj.eventtype__c+notificationObj.sourcesystem__c).orderItemId__c==true) || 
            (notificationObj.orderItemVersion__c ==null && notificationAttMap.get(notificationObj.eventtype__c+notificationObj.sourcesystem__c).orderItemVersion__c==true) ||
            (notificationObj.notificationAttributes__c ==null && notificationAttMap.get(notificationObj.eventtype__c+notificationObj.sourcesystem__c).notificationAttributes__c==true))
            {
            	notificationObj.addError('Mandatory Fields Missing!');
              	temp = false;
            } else {
                if(notificationObj.eventType__c == 'appointmentNotification' && notificationObj.sourceSystem__c =='Fulfilment' && appointmentMap.get(notificationObj.orderItemId__c) ==null){
                    notificationObj.addError('Appointment does not exist!'); 
                    temp = false;    
                }
                else if(temp == true && (notificationObj.eventType__c == 'statusNotification' || notificationObj.eventtype__c == 'delay' || notificationObj.eventtype__c == 'milestoneNotification') && notificationObj.sourceSystem__c =='Fulfilment'){
                    String orderNumber = notificationObj.orderItemId__c.split('\\|')[0];
                    String srvNumber = notificationObj.orderItemId__c.split('\\|')[1];
                    String servSpecGuid = notificationObj.orderItemId__c.split('\\|')[2];
                    System.debug('orderNumber++'+orderNumber);
                    if(orderMap.get(orderNumber) ==null){
                    	notificationObj.addError('Order does not exist!');
                    	temp = false;
                    }
                    else if(!orderServiceMap.get(orderMap.get(orderNumber).id).contains(srvNumber) ){
                        notificationObj.addError('Service for given Order does not exist!');
                        temp = false;
                    }
                    else if(!servToSpecMap.get(srvNumber).contains(servSpecGuid)){
                        notificationObj.addError('ServiceSpec for given Service does not exist!');
                        temp = false;
                    }
                }
                else if(notificationObj.sourceSystem__c == 'Billing' && subscriptionMap.get(notificationObj.orderItemId__c) ==null){
                    notificationObj.addError('Subscription does not exist!');
                    temp = false;      
                }
                  
            }
            if(temp){
            	try{
            		String notificationAttr= '{'+notificationObj.notificationAttributes__c+'}';
                    ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
                }catch(Exception e){
                    error = 'notificationAttributes';
                    notificationObj.addError(error+ ': Bad/Incorrect format!');
                    temp = false;
                }   
            }
            if(temp==true && notificationObj.orderItemDetails__c !=null){
                try{
                	String orderItemDetails = '{'+notificationObj.orderItemDetails__c+'}';
                    ManageOrderNotificationUtil.Product productUpdates = ManageOrderNotificationUtil.parse(orderItemDetails);
				}catch(Exception e){
                    error = 'orderItemDetails';
                    notificationObj.addError(error+ ': Bad/Incorrect format!');
                    temp = false;
                }
            }
            if(temp==true && notificationObj.errorDetails__c !=null){
                try{
                	JSONParser parser = JSON.createParser(notificationObj.errorDetails__c);
                    if(parser.nextToken() != null){
                        //do nothing
                    }
                }catch(Exception e){
                    error = 'errorDetails';
                    notificationObj.addError(error+ ': Bad/Incorrect format!');
                    temp = false;
                }
            }
        }
    }
}