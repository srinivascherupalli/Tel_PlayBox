/********************************************************************************
 * Class Name  : SYS_OrderNotifcationMain 
 * Description : This class is Main Class for Order Notification Function.   
 * Created By  :  Dunna, Uday Kumar
 * Change Log  : Created.  14/09/2021
 *               Merges, Uplift 22/10/2021
*******************************************************************************
1.DIGI-35474        Mukta Wadhwani          removed 871 prod spec from checkUCCompletionAndUpdateNumber
 ********************************************************************************/

Public class SYS_OrderNotifcationMain {

    // DECLARE GLOBAL VARIABLES  

    Public Static List < NotificationParameters > statusNotifications;
    Public Static List < NotificationParameters > subStageNotifications;
    public static final String STATUS = 'status';
    public static final String FULFILMENT = 'FULFILMENT';
    public static List < CS_SpecificationDTO.ServiceSpecification > srvspecList = new List < CS_SpecificationDTO.ServiceSpecification > ();
    public static boolean isOrderNotification = false;
    public static Map < string, csord__Service__c > partservmap = new Map < string, csord__Service__c > (); //EDGE-170552  
    public static Map < Id, csord__Subscription__c > solToSubMap = new Map < Id, csord__Subscription__c > (); //added as part of solution supression
    public static Map < Id, csord__Service__c > solToServMap = new Map < Id, csord__Service__c > (); //added as part of EDGE-224556  
    private static String correlationId = GuidUtil.NewGuid();
    private static final String CONST_INTERFACENAME = 'ManageOrderNotificationServiceMSUpdate';

    //CONSTRUCTOR 
    Public SYS_OrderNotifcationMain(NotificationParameters[] params) {

        statusNotifications = New List < NotificationParameters > ();
        subStageNotifications = New List < NotificationParameters > ();
        List < NotificationParameters > statusNotifList = new List < NotificationParameters > ();
        Map < String, List < NotificationParameters >> orderItemIdNotifMap = new Map < String, List < NotificationParameters >> ();
        for (NotificationParameters a: params) {

            // IF PAYLOAD SOURCESYSTEM IS NULL CONSIDER AS FULLFILMENT
            if (a.sourceSystem == null) a.sourceSystem = 'Fulfilment';

            // STEP 1 - SUBSTAGE NOTIFICATION
            if (a.eventType.equalsIgnoreCase('subStageNotification')) subStageNotifications.add(a);
            else
                //STEP 2 - STATUS NOTIFICATION                 
                statusNotifications.add(a);

            if (a.eventType.equalsIgnoreCase('statusNotification') || a.eventType.equalsIgnoreCase('error') || a.eventType.equalsIgnoreCase('delay') || a.eventType.equalsIgnoreCase('appointmentNotification')) {
                statusNotifList.add(a);
            }

        }

        if (!statusNotifList.isEmpty()) {
            processNotificationRecordMS(statusNotifList);
        }
    }

    public static void processNotification(Map < String, List < NotificationParameters >> orderItemIdNotifMap) {
        String toLog ='';  
        boolean enableThrowException = Boolean.valueOf(EnvironmentVariable__c.getValues('EnableThrowException').Value__c); //EDGE-215225  
        try {
            List < NotificationParameters > paramsList = new List < NotificationParameters > ();
            List < NotificationParameters > statusNotifList = new List < NotificationParameters > ();
            List < NotificationParameters > substageNotifList = new List < NotificationParameters > ();
            Map < String, String > numberGroupStatusMap = new Map < String, String > (); // EDGE-141545  
            Map < String, String > numberGroupSubStageMap = new Map < String, String > (); // EDGE-141545  
            Map < String, String > numberStatusMap = new Map < String, String > (); // DIGI 1413
            List < NotificationParameters > NumberParamsList = new List < NotificationParameters > (); // DIGI 1413
            List < NotificationParameters > serviceNotificationList = new List < NotificationParameters > (); // EDGE-143006 @VM 16th March  
            List < NotificationParameters > subscriptionNotificationList = new List < NotificationParameters > (); // EDGE-205529

            for (String orderItem: orderItemIdNotifMap.keySet()) {
                paramsList.addAll(orderItemIdNotifMap.get(orderItem));
            }

            for (NotificationParameters notif: paramsList) {
                //Added as part of EDGE-141545 to check to call processFulfilmentNotifications for Number Group fulfilment notification  
                if (notif.orderItemId != null && notif.orderItemId.split('\\|') != null &&
                    notif.orderItemId.split('\\|').size() > 2 && notif.orderItemId.split('\\|')[1] != null && notif.orderItemId.split('\\|')[1].startsWith('NG-')) {
                    if ((notif.eventType.equalsIgnoreCase('statusNotification') || notif.eventType.equalsIgnoreCase('subStageNotification')) &&
                        notif.sourceSystem == 'Fulfilment') {
                        ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes('{' + String.valueOf(notif.notificationAttributes) + '}');
                        for (ManageOrderNotificationUtil.NotificationAttributes attr: notifyAttrs.attributes) {
                            if (attr.name.contains('status') && notif.eventType.equalsIgnoreCase('statusNotification')) {
                                numberGroupStatusMap.put(notif.orderItemId.split('\\|')[1], attr.value);
                            }
                            if (attr.name.contains('status') && notif.eventType.equalsIgnoreCase('subStageNotification')) {
                                numberGroupSubStageMap.put(notif.orderItemId.split('\\|')[1], attr.value);
                            }
                        }
                    }

                }
                // DIGI 1413
                else if (notif.orderItemId != null && notif.orderItemId.split('\\|') != null &&
                    notif.orderItemId.split('\\|').size() > 2 && notif.orderItemId.split('\\|')[1] != null && notif.orderItemId.split('\\|')[1].startsWith('NU-')) {
                    if ((notif.eventType.equalsIgnoreCase('statusNotification') || notif.eventType.equalsIgnoreCase('subStageNotification')) &&
                        notif.sourceSystem == 'Fulfilment') {
                        ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes('{' + String.valueOf(notif.notificationAttributes) + '}');
                        for (ManageOrderNotificationUtil.NotificationAttributes attr: notifyAttrs.attributes) {
                            if (attr.name.contains('status') && (notif.eventType.equalsIgnoreCase('statusNotification') || notif.eventType.equalsIgnoreCase('subStageNotification'))) {
                                numberStatusMap.put(notif.orderItemId.split('\\|')[1], attr.value);
                            }
                        }
                        numberParamsList.add(notif);
                    }
                }
                //EDGE-141545 Ends  
                else if (notif.eventType.equalsIgnoreCase('statusNotification') || notif.eventType.equalsIgnoreCase('error') || notif.eventType.equalsIgnoreCase('delay') || notif.eventType.equalsIgnoreCase('appointmentNotification') || notif.eventType.equalsIgnoreCase('PONR') || notif.eventType.equalsIgnoreCase('OrderNotification')) { //check added for PONR and OrderNotiication as part of EDGE-170550                      
                    statusNotifList.add(notif);
                } else if (notif.eventType.equalsIgnoreCase('subStageNotification')) {
                    substageNotifList.add(notif);
                }
                // Added as part of EDGE-205529  
                else if (notif.eventType.equalsIgnoreCase('subscriptionNotification') && notif.sourceSystem == 'Billing') {
                    subscriptionNotificationList.add(notif);
                }

                if (notif.eventType.equalsIgnoreCase('serviceNotification') || notif.eventType.equalsIgnoreCase('error') && notif.sourceSystem == 'Billing') { // Process serviceNotification EDGE-143006 @VM 16th March  
                    serviceNotificationList.add(notif);
                }
            }

            //EDGE-141545 starts  
            if (!numberGroupStatusMap.isEmpty() || !numberGroupSubStageMap.isEmpty()) {
                ManageNumberGroupNotification.processFulfilmentNotifications(numberGroupStatusMap, numberGroupSubStageMap);
            }
            //EDGE-141545 ends  
            if (!statusNotifList.isEmpty()) {
                processNotificationRecordMS(statusNotifList);
            }
            if (!substageNotifList.isEmpty()) {
                ManageSubStageNotificationMSUpdate.processSubStageNotification(orderItemIdNotifMap, substageNotifList);
            }
            // Process serviceNotification EDGE-143006 @VM 16th March  
            if (!serviceNotificationList.isEmpty()) {
                ManageNumberGroupNotification.processBillingNotifications(serviceNotificationList);
            }
            // End : EDGE-143006 @VM  
            // Added as part of EDGE-205529  
            if (!subscriptionNotificationList.isEmpty()) {
                ManageBillingSubsNotificationHelper.processSubscriptionNotification(orderItemIdNotifMap, subscriptionNotificationList);
            }
            //DIGI 1413 
            if (!numberParamsList.isEmpty()) {
                ManageNumberGroupNotification.processFulfilmentNotifications(numberStatusMap, numberParamsList);
            }


        } catch (Exception e) {
            logException('processNotification', '', correlationId,  e.getMessage() + '-' + e.getStackTraceString(), 'Process Notifications after successfull criteria evaluation');  
            if(!Test.isRunningTest() && enableThrowException){throw e;}//EDGE-215225  
        }
    }


    public static void EventHandler(List < NotificationParameters > paramsList) {
        List < Notification__c > notigRecsUpdated = new List < Notification__c > ();
        Map < Id, Notification__c > notifMap = new Map < Id, Notification__c > ();
        Map < String, List < NotificationParameters >> orderItemIdNotifMap = new Map < String, List < NotificationParameters >> ();
        String toLog = '';
        integer k = 0;
        List < String > orderItemIdList = null;
        List < Notification__c > notificationList = new List < Notification__c > ();
        List < Notification__c > notificationErrorList = new List < Notification__c > ();
        Map < string, string > orderItemIdstatusMap = new Map < string, string > ();
        List < String > orderIdList = new List < String > ();
        Map < String, List < notificationParameters >> orderidNotificationMap = new Map < String, List < notificationParameters >> ();
        list < String > orderNumberList = new list < String > ();
        boolean isbill = false;
        List < NotificationParameters > allNotifList = new List < NotificationParameters > ();
        try {
            for (notificationParameters notifparam: paramsList) {
                orderIdList.add(notifparam.externalOrderId);
                if (notifparam.sourceSystem == null) {
                    notifparam.sourceSystem = 'Fulfilment';
                }
                List < NotificationParameters > notificationsList = new List < NotificationParameters > ();
                allNotifList.add(notifparam);
                if (!orderItemIdNotifMap.isEmpty() && orderItemIdNotifMap.get(notifparam.orderItemId) != null) {
                    notificationsList = orderItemIdNotifMap.get(notifparam.orderItemId);
                    notificationsList.add(notifparam);
                    notificationsList = sort(notificationsList);
                } else {
                    notificationsList.add(notifparam);
                }
                orderItemIdNotifMap.put(notifparam.orderItemId, notificationsList);
            }
            system.debug('orderItemIdNotifMap::' + orderItemIdNotifMap);
            List < csord__Order__c > ordlist = [select id, csord__Order_Number__c from csord__Order__c where csord__Order_Number__c IN: orderIdList];
            system.debug('ordlist::' + ordlist);
            if (ordlist.isEmpty()) {
                for (notificationParameters noti: paramsList) {
                    Notification__c notif = new Notification__c();
                    notif.orderItemId__c = noti.orderItemId;
                    notif.notificationAttributes__c = noti.notificationAttributes;
                    notif.eventType__c = noti.eventType;
                    notif.orderItemDetails__c = noti.orderItemDetails;
                    notif.sourceSystem__c = noti.sourceSystem;
                    notif.eventTimeStamp__c = noti.eventTimestamp;
                    notif.externalOrderId__c = noti.externalOrderId;
                    notif.orderItemVersion__c = noti.orderItemVersion;
                    notif.errorDetails__c = noti.errorDetails;
                    notif.Status__c = 'Error';
                    notif.msCorrelationId__c = noti.msCorrelationId;
                    notif.externalOrderVersion__c = noti.externalOrderVersion; //EDGE-170548 
                    notif.subscriptionDetails__c = noti.subscriptionDetails;
                    notificationErrorList.add(notif);
                    orderItemIdstatusMap.put(noti.orderItemId, 'Failed');
                    toLog += '*' + noti.orderItemId + '-->' + notif.Status__c + '->' + noti.msCorrelationId + '\n';
                }
                if (!notificationErrorList.isEmpty()) {
                    try {
                        insert notificationErrorList;
                    } catch (DmlException e) {
                        Map < String, Object > inputMap = new Map < String, Object > ();
                        inputMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH);
                        inputMap.put('errorDescription', e.getMessage());
                        inputMap.put('LoggingLevel.INFO', e.getStackTraceString());
                        C2O_Utilities.logException(inputMap, false);
                    }
                }
                publishEventCallbackMS(paramsList, orderItemIdstatusMap);
            } else {
                try {
                    processNotification(orderItemIdNotifMap);
                } catch (Exception e) {
                    Map < String, Object > inputMap = new Map < String, Object > ();
                    inputMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH);
                    inputMap.put('errorDescription', e.getMessage());
                    inputMap.put('LoggingLevel.INFO', e.getStackTraceString());
                    C2O_Utilities.logException(inputMap, false);
                }

                for (notificationParameters notifparam: allNotifList) {
                    Notification__c notification = new Notification__c();
                    notification.orderItemId__c = notifparam.orderItemId;
                    notification.notificationAttributes__c = notifparam.notificationAttributes;
                    notification.eventType__c = notifparam.eventType;
                    notification.orderItemDetails__c = notifparam.orderItemDetails;
                    notification.sourceSystem__c = notifparam.sourceSystem;
                    notification.eventTimeStamp__c = notifparam.eventTimestamp;
                    notification.externalOrderId__c = notifparam.externalOrderId;
                    notification.orderItemVersion__c = notifparam.orderItemVersion;
                    notification.errorDetails__c = notifparam.errorDetails;
                    notification.Status__c = 'Completed';
                    notification.msCorrelationId__c = notifparam.msCorrelationId;
                    notification.externalOrderVersion__c = notifparam.externalOrderVersion; //EDGE-170548                     
                    notificationList.add(notification);
                    orderItemIdstatusMap.put(notification.orderItemId__c, notification.Status__c);
                }

                if (!notificationList.isEmpty()) {
                    insert notificationList;
                }

                publishEventCallbackMS(allNotifList, orderItemIdstatusMap);
            }
        } catch (Exception e) {
            System.debug('Exception:::' + e.getMessage() + '--' + e.getLineNumber());
            Map < String, Object > inputMap = new Map < String, Object > ();
            inputMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH);
            inputMap.put('errorDescription', e.getMessage());
            inputMap.put('LoggingLevel.INFO', e.getStackTraceString());
            C2O_Utilities.logException(inputMap, false);
        }

    }

    public static void publishEventCallbackMS(List < NotificationParameters > tempNotifList, Map < string, string > orderItemIdstatusMap) {
        List < EventMSCallBackDTO > EventMSCallBackList = new List < EventMSCallBackDTO > ();
        Logger2 log = Logger2.getLogger('EventMSCallBack');
        try {
            if (!tempNotifList.isEmpty() && !orderItemIdstatusMap.isEmpty()) {
                for (notificationParameters notif: tempNotifList) {
                    EventMSCallBackDTO EventMSCallBack = new EventMSCallBackDTO();
                    EventMSCallBack.msCorrelationId = notif.msCorrelationId;
                    EventMSCallBack.orderItemId = notif.orderItemId;
                    EventMSCallBack.status = orderItemIdstatusMap.get(notif.orderItemId);
                    EventMSCallBackList.add(EventMSCallBack);
                }
                EventMSCallBack__e EventMS = new EventMSCallBack__e();
                EventMS.eventresponse__c = JSON.serialize(EventMSCallBackList);
                Database.SaveResult sr = EventBus.publish(EventMS);
                System.debug('Events are published');
                log.logMessages(JSON.serialize(EventMS, true), '', '', '', '', '', false, false, 200, '', '', '');
                log.exitLogger();
            }
        } catch (Exception e) {
            System.debug('Exception:::' + e.getMessage() + '--' + e.getLineNumber());
            Map < String, Object > inputMap = new Map < String, Object > ();
            inputMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH);
            inputMap.put('errorDescription', e.getMessage());
            inputMap.put('LoggingLevel.INFO', e.getStackTraceString());
            C2O_Utilities.logException(inputMap, false);
        }
    }

    public static List < NotificationParameters > sort(List < NotificationParameters > notificationList) {
        system.debug('Insidesort=========');
        NotificationParameters swap1 = new NotificationParameters();
        for (integer i = 0; i < notificationList.size(); i++) {
            for (integer j = i; j < notificationList.size(); j++) {
                if (notificationList[i].sequence > notificationList[j].sequence) {
                    swap1 = notificationList[i];
                    notificationList[i] = notificationList[j];
                    notificationList[j] = swap1;
                }
            }
        }
        return notificationList;
    }

    @invocableMethod
    public static void billingNotificationHandler(List < NotificationParameters > paramsList) {
        Map < String, List < NotificationParameters >> orderItemIdNotifMap = new Map < String, List < NotificationParameters >> ();
        Set < Id > allRecsId = new Set < Id > ();
        List < Notification__c > updatedNotifList = new List < Notification__c > ();
        Map < Id, Notification__c > notifMap = new Map < Id, Notification__c > ();
        try {
            for (NotificationParameters params: paramsList) {
                allRecsId.add(params.notificationId);
            }
            processNotification(orderItemIdNotifMap);

            notifMap = new Map < ID, Notification__c > ([Select Id, Name, orderItemId__c, Status__c, Internal_Error_Description__c from Notification__c where Id in: allRecsId]);

            for (NotificationParameters params: paramsList) {
                Notification__c notifRec = notifMap.get(params.notificationId);
                if (notifRec != null) notifRec.Status__c = 'Completed';
                updatedNotifList.add(notifRec);
            }


            if (!updatedNotifList.isEmpty()) update updatedNotifList;
        } catch (Exception e) {
            Map < String, Object > inputMap = new Map < String, Object > ();
            inputMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH);
            inputMap.put('errorDescription', e.getMessage());
            inputMap.put('LoggingLevel.INFO', e.getStackTraceString());
            C2O_Utilities.logException(inputMap, false);
        }
    }

    public static void processNotificationRecordMS(List < NotificationParameters > paramsList) {
        boolean enableThrowException = Boolean.valueOf(EnvironmentVariable__c.getValues('EnableThrowException').Value__c); //EDGE-215225  
        List < String > paramBillingList = new List < String > ();
        List < String > paramAppointmentList = new List < String > ();

        List < CS_SpecificationDTO.ComplexAttributes > simpleChars = new List < CS_SpecificationDTO.ComplexAttributes > ();
        List < CS_SpecificationDTO.ComplexAttributes > simpleCharsMobile = new List < CS_SpecificationDTO.ComplexAttributes > ();
        String OrderidNumber;
        Map < String, ManageOrderNotificationUtil.Parameters > parameterMap = new Map < String, ManageOrderNotificationUtil.Parameters > ();
        List < String > appointmentIds = new List < String > ();
        List < String > eventIds = new List < String > ();
        List < String > orderNumbers = new List < String > ();
        List < String > srvNumbers = new List < String > ();
        List < id > orderIdList = new List < Id > ();
        List < Id > allServiceId = new List < id > ();
        Map < String, Attachment > servAttachmentRecordMap = new Map < String, Attachment > ();
        Map < String, String > serviceAttachmentMap = new Map < String, String > ();
        List < Id > ReplacedsubscrpList = new List < Id > ();
        List < csord__Service__c > uceServList = new List < csord__Service__c > ();
        boolean isFulfillment = false;
        List < NotificationParameters > completeNotifications = new List < NotificationParameters > ();
        List < NotificationParameters > combinedNotifications = new List < NotificationParameters > ();
        List < NotificationParameters > inprogressNotifications = new List < NotificationParameters > ();
        List < csord__Subscription__c > subsList = new List < csord__Subscription__c > ();
        List < Appointment__c > apptList = new List < Appointment__c > ();
        Map < Id, csord__Service__c > servList = new Map < Id, csord__Service__c > ();
        Boolean acceptanceNotification = false;
        Set < String > orderNumbersBilling = new Set < String > (); //added as part of solution suppression  

        String toLog = '';
        try {
            for (NotificationParameters notif: paramsList) {
                ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
                params.orderIdc = notif.orderItemId;
                if (String.isNotEmpty(notif.notificationAttributes)) params.notifyAttributes = '{' + notif.notificationAttributes + '}'; //convert string to JSON supported format  
                ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(params.notifyAttributes);
                for (ManageOrderNotificationUtil.NotificationAttributes attr: notifyAttrs.attributes) {
                    if (attr.name.contains('status') && attr.value == Label.Complete) {
                        toLog += '*' + notif.orderItemId + '-->' + attr.name + '->' + notif.msCorrelationId + '\n';
                        completeNotifications.add(notif);
                    } else if (attr.name.contains('status') && attr.value == 'In Progress') {
                        toLog += '*' + notif.orderItemId + '-->' + attr.name + '->' + notif.msCorrelationId + '\n';
                        inprogressNotifications.add(notif);
                    } else if (attr.name.contains('status') && attr.value == Label.Accepted) {
                        toLog += '*' + notif.orderItemId + '-->' + attr.name + '->' + notif.msCorrelationId + '\n';
                        // Accepted Notifications  
                        acceptanceNotification = true;
                    }
                }
                if (!completeNotifications.isEmpty())
                    combinedNotifications.addAll(completeNotifications);
                if (!inprogressNotifications.isEmpty())
                    combinedNotifications.addAll(inprogressNotifications);
                if (String.isNotEmpty(notif.orderItemDetails)) params.orderItemDetails = '{' + notif.orderItemDetails + '}'; //convert string to JSON supported format  
                params.eventType = notif.eventType;
                if (notif.sourceSystem == 'Fulfilment' && (notif.eventType.equalsIgnoreCase('statusNotification') || notif.eventType.equalsIgnoreCase('delay') || notif.eventType.equalsIgnoreCase('PONR') || notif.eventType.equalsIgnoreCase('OrderNotification'))) { //added check as part of EDGE-170550(PONR & OrderNotification)  
                    // paramsUC = params;  
                    isFulfillment = true;
                    if (params.orderIdc != null) {
                        orderNumbers.add(params.orderIdc.split('\\|')[0]);
                        srvNumbers.add(params.orderIdc.split('\\|')[1]);
                    } else { //added as part of EDGE-170550  
                        orderNumbers.add(notif.externalOrderId);
                    }
                    if (notif.eventType.equalsIgnoreCase('OrderNotification')) {
                        isOrderNotification = true;
                    }
                } else if (notif.sourceSystem == 'Fulfilment' && notif.eventType == 'appointmentNotification') {
                    parameterMap.put(params.orderIdc, params);
                    appointmentIds.add(params.orderIdc);
                } else if (notif.sourceSystem == 'Billing') {
                    parameterMap.put(params.orderIdc, params);
                    eventIds.add(params.orderIdc);
                }
            }
            if (!appointmentIds.isEmpty()) {
                apptList = [SELECT Id, Status__c, SlotId__c FROM Appointment__c WHERE SlotId__c IN: appointmentIds
                    for update
                ];
            }
            if (!eventIds.isEmpty()) {
                //Added Suspension_reason_summary__c in query -DPg 4545
                subsList = [SELECT Id, Name, Sub_status__c, eventId__c, csord__Status__c, csordtelcoa__Subscription_Number__c, Suspension_reason__c, CreatedDate, toBeCancelled__c, cssdm__solution_association__c, csord__Order__c, csord__Order__r.csord__Order_Number__c, Suspension_reason_summary__c
                    FROM csord__Subscription__c WHERE eventId__c IN: eventIds order by createdDate DESC
                ];
                servList = new Map < Id, csord__Service__c > ([SELECT Id, Name, csord__Order__c, Scenario_Type__c, csord__Service__c, toBeCancelled__c, csord__Subscription__r.eventId__c, Action_Type__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, csordtelcoa__Cancelled_By_Change_Process__c, csord__Subscription__r.csordtelcoa__Cancelled_By_Change_Process__c FROM csord__Service__c WHERE csord__Subscription__r.eventId__c IN: eventIds
                    for update
                ]);
                system.debug('subsList===>' + subsList);
                for (csord__Subscription__c subs: subsList) {
                    orderNumbersBilling.add(subs.csord__Order__r.csord__Order_Number__c);
                }
            }
            List < csord__Order__c > orderList = new List < csord__Order__c > ();
            if (orderNumbersBilling.isEmpty()) {
                orderList = [SELECT id, Name, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate, csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c, csord__Order_Type__c, csordtelcoa__Opportunity__c, csordtelcoa__Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c,
                    (select id, Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c, csordtelcoa__Product_Configuration__r.ConfigurationType1__c from csord__Subscriptions__r)
                    FROM csord__Order__c
                    WHERE csord__Order_Number__c IN: orderNumbers Or csord__Primary_Order__r.csord__Order_Number__c IN: orderNumbers
                    for update
                ]; //added the subquery EDGE-191827  
            }
            Map < csord__Order__c, List < csord__Subscription__c >> orderToSubMap = new Map < csord__Order__c, List < csord__Subscription__c >> (); //added the map EDGE-191827  
            for (csord__Order__c ord: orderList) {
                orderIdList.add(ord.id);
                if (ord.csord__Subscriptions__r != null) {
                    orderToSubMap.put(ord, ord.csord__Subscriptions__r); //added the map EDGE-191827  
                }
            }
            system.debug('===>' + orderNumbersBilling);
            for (csord__Subscription__c sub: [select id, csord__Status__c, Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c, csordtelcoa__Product_Configuration__r.ConfigurationType1__c, cssdm__solution_association__c, csord__Order__r.csord__Order_Number__c, (Select id, name, csord__Status__c from csord__Services__r) from csord__Subscription__c where csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent'
                    and csord__Order__r.csord__Order_Number__c IN: orderNumbersBilling
                ]) //added as part of solution compression  
            {
                solToSubMap.put(sub.cssdm__solution_association__c, sub);
                for (csord__Service__c serv: sub.csord__Services__r) {
                    solToServMap.put(sub.cssdm__solution_association__c, serv);
                }

            }
            //added csord__Activation_Date__c in SOQL // Initial_Activation_DateTime__c,Deactivation_Date__c added as part of EDGE-174924  
            List < csord__Service__c > srvcList = new List < csord__Service__c > ();
            //DPG-4545- added csord__Subscription__r.Suspension_reason_summary__c in the queries
            if (isOrderNotification == true) {
                srvcList = [SELECT Id, toBeCancelled__c, Name, csord__Status__c, csord__Order__c, csord__Order__r.id, csord__Subscription__r.csordtelcoa__Replaced_Subscription__c, csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, ReplacedSubscription__c, CreatedDate, Forecasted_Delivery_Date__c, Telstra_Committed_Date__c, csord__Order__r.csordtelcoa__Opportunity__c, csord__Subscription__r.Suspension_reason__c, csord__Service__c, csord__Subscription__r.csord__Status__c, csord__Order__r.Name, csord__Order__r.csord__Status2__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c, csord__Activation_Date__c, csord__Service__r.id, csord__Deactivation_Date__c, csordtelcoa__Replaced_Service__c, Initial_Activation_DateTime__c, Deactivation_Date__c, Action_Type__c, csord__Subscription__r.cancel_Point_of_No_Return_Reached__c, csord__Subscription__r.Point_of_No_Return_Reached__c, csord__Subscription__r.orderversion__c, csord__Order__r.Fulfilment_Order_Version__c, csord__Order__r.csord__Order_Number__c, csordtelcoa__Cancelled_By_Change_Process__c, csord__Subscription__r.csordtelcoa__Cancelled_By_Change_Process__c, csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c, csord__Subscription__r.Suspension_reason_summary__c FROM csord__Service__c WHERE csord__Order__r.id IN: orderIdList];
            } else {
                srvcList = [SELECT Id, toBeCancelled__c, Name, csord__Status__c, csord__Order__c, csord__Order__r.id, csord__Subscription__r.csordtelcoa__Replaced_Subscription__c, csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, ReplacedSubscription__c, CreatedDate, Forecasted_Delivery_Date__c, Telstra_Committed_Date__c, csord__Order__r.csordtelcoa__Opportunity__c, csord__Subscription__r.Suspension_reason__c, csord__Service__c, csord__Subscription__r.csord__Status__c, csord__Order__r.Name, csord__Order__r.csord__Status2__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c, csord__Activation_Date__c, csord__Service__r.id, csord__Deactivation_Date__c, csordtelcoa__Replaced_Service__c, Initial_Activation_DateTime__c, Deactivation_Date__c, Action_Type__c, csord__Subscription__r.cancel_Point_of_No_Return_Reached__c, csord__Subscription__r.Point_of_No_Return_Reached__c, csord__Subscription__r.orderversion__c, csord__Order__r.Fulfilment_Order_Version__c, csord__Order__r.csord__Order_Number__c, csordtelcoa__Cancelled_By_Change_Process__c, csord__Subscription__r.csordtelcoa__Cancelled_By_Change_Process__c, csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c, csord__Subscription__r.Suspension_reason_summary__c FROM csord__Service__c WHERE csord__Order__r.id IN: orderIdList AND(csord__Service__r.csordtelcoa__Service_Number__c IN: srvNumbers OR csordtelcoa__Service_Number__c IN: srvNumbers) FOR UPDATE]; // csord__Deactivation_Date__c added as part of EDGE-164354 added as part of EDGE-164354 csordtelcoa__Replaced_Service__c EDGE-175697 //added few fields as part of EDGE-191827  
            }
            for (csord__Service__c svc: srvcList) {
                allServiceId.add(svc.id);
                ReplacedsubscrpList.add(svc.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c);
                if ((svc.csordtelcoa__Product_Configuration__c != null && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c != null && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != null && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c.contains('DMCAT_ProductOffering_000304') && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name.contains('IP')) || ((svc.csordtelcoa__Product_Configuration__c != null && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c != null && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != null && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c.contains('DMCAT_ProductSpecification_000871')))) {
                    uceServList.add(svc);
                }
            }
            for (Attachment att: [Select id, body, parentId from Attachment where parentId in: allServiceId for update]) {
                servAttachmentRecordMap.put(att.parentId, att);
                serviceAttachmentMap.put(att.parentId, att.body.toString());
            }
            List < csord__Service__c > ReplacedserviceSubsList = [SELECT Id, Name, Action_Type__c, csord__Status__c, csord__Order__c, csord__Order__r.id, csord__Order_Request__c, csord__Subscription__r.csordtelcoa__Replaced_Subscription__c, csordtelcoa__Service_Number__c, csord__Subscription__c, ReplacedSubscription__c, CreatedDate, Forecasted_Delivery_Date__c, Telstra_Committed_Date__c, cancellationDate__c, csord__Order__r.csordtelcoa__Opportunity__c, csordtelcoa__Cancelled_By_Change_Process__c, csord__Subscription__r.csordtelcoa__Cancelled_By_Change_Process__c FROM csord__Service__c WHERE csord__Subscription__c IN: ReplacedsubscrpList FOR UPDATE];
            // Added as part of EDGE-170546  
            if (acceptanceNotification) {
                System.debug('inside accepted notification block...');
                updateInflightSubsOrchestration(orderList, orderIdList);
            }

            System.debug('ReplacedserviceSubsList:::' + ReplacedserviceSubsList);
            if (!paramsList.isEmpty()) {
                if (isFulfillment == true) {
                    updateServiceRecordMS(paramsList, parameterMap, orderList, srvcList, serviceAttachmentMap, servAttachmentRecordMap, ReplacedserviceSubsList, orderToSubMap);
                }
                if (!eventIds.isEmpty()) {
                    updateSubscriptionRecordMS(paramsList, parameterMap, subsList, servList);
                }
                if (!appointmentIds.isEmpty()) {
                    updateAppointmenRecordMS(paramsList, parameterMap, apptList);
                }
                //updateOrderRecordMS(orderToSubMap);//added the method call EDGE-191827  
            }
            ReplacedserviceSubsList.clear();
            apptList.clear();
            apptList.clear();
            servList.clear();
            parameterMap.clear();

            Map < String, boolean > servCheck = new Map < String, boolean > ();
            if (!combinedNotifications.isEmpty() && eventIds.isEmpty()) {
                servCheck = checkUCCompletionAndUpdateNumber(combinedNotifications);
            }
            if (!completeNotifications.isEmpty() && eventIds.isEmpty()) {
                List < csord__Service__c > ucServList = new List < csord__Service__c > ();
                //EDGE-81250 changes  
                // List<csord__Service__c> uceServList = [select id from csord__service__c where csordtelcoa__Service_Number__c IN:servCheck.keyset() and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c like '%DMCAT_ProductOffering_000304%' and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name like'%IP%' FOR Update];  
                if (!servCheck.isEmpty() && !uceServList.isEmpty()) {
                    for (csord__Service__c svc: uceServList)
                        if (servCheck.get(svc.csordtelcoa__Service_Number__c) == true) {
                            uceServList.add(svc);
                        }
                }
                //sorting by createdDate  
                if (uceServList != null) {
                    uceServList = (List < csord__Service__c > ) CustomSortUtility.customSort(uceServList, 'createddate', 'DateTime'); //list in ascending order                     
                    ServiceSpecificationUtils.updateUCNumberSpecNumberStatus(new List < Id > (new Map < Id, csord__service__c > (uceServList).keySet()));
                }
            }
            if (!String.isBlank(toLog)) {
                Logger2 log = Logger2.getLogger('ProcessNotifications');
                log.logMessages(JSON.serialize(toLog, true), '', '', '', '', '', false, false, 200, '', '', '');
                log.exitLogger();
            }
        } catch (Exception e) {
            logException('processNotificationRecordMS', '', correlationId, e.getMessage() + '-' + e.getStackTraceString(), 'Process Notifications from MS');
            if(!Test.isRunningTest() && enableThrowException){throw e;}//EDGE-215225  
        }
    }

    @TestVisible
    private static void updateAppointmenRecordMS(List < NotificationParameters > paramsList, Map < String, ManageOrderNotificationUtil.Parameters > parameterMap, List < Appointment__c > apptList) {
        String toLog = '';
        boolean enableThrowException;
        if (!Test.isRunningTest()) {
            enableThrowException = Boolean.valueOf(EnvironmentVariable__c.getValues('EnableThrowException').Value__c); //EDGE-215225  
        }

        try {
            List < Appointment__c > apptListtoUpdate = new List < Appointment__c > ();
            Map < String, Appointment__c > appointmentMap = new Map < String, Appointment__c > ();
            for (Appointment__c appt: apptList) {
                appointmentMap.put(String.valueof(appt.SlotId__c), appt);
            }
            for (String key: parameterMap.keySet()) {
                ManageOrderNotificationUtil.Parameters param = parameterMap.get(key);
                Appointment__c appt = appointmentMap.get(param.orderIdc);
                String notificationAttr = param.notifyAttributes;
                ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
                for (ManageOrderNotificationUtil.NotificationAttributes attr: notifyAttrs.attributes) {
                    if (attr.name.contains(STATUS) && attr.value != '' && appt != null) {
                        appt.Status__c = attr.value;
                        apptListtoUpdate.add(appt);
                    }
                    toLog += '*' + appt.Id + '-->' + appt.Status__c + '\n';
                }
            }
            if (!apptListtoUpdate.isEmpty()) {
                update apptListtoUpdate;
            }
            if (!String.isBlank(toLog)) {
                Logger2 log = Logger2.getLogger('UpdateAppointment');
                log.logMessages(JSON.serialize(toLog, true), '', '', '', '', '', false, false, 200, '', '', '');
                log.exitLogger();
            }
        } catch (Exception e) {
            logException('updateAppointmenRecordMS', '', correlationId, e.getMessage(), 'Updated Appointment records based on notification from MS');
            if (!Test.isRunningTest() && enableThrowException) {
                throw e;
            } //EDGE-215225  
        }
    }

    @TestVisible
    private static void updateSubscriptionRecordMS(List < NotificationParameters > paramsList, Map < String, ManageOrderNotificationUtil.Parameters > parameterMap, List < csord__Subscription__c > subsList, Map < Id, csord__Service__c > servList) {
        boolean enableThrowException;
        if (!Test.isRunningTest()) {
            enableThrowException = Boolean.valueOf(EnvironmentVariable__c.getValues('EnableThrowException').Value__c); //EDGE-215225  
        }
        try {
            String toLog = '';
            List < csord__Subscription__c > subsListtoUpdate = new List < csord__Subscription__c > ();
            subsList = (List < csord__Subscription__c > ) CustomSortUtility.customSort(subsList, 'createddate', 'DateTime'); //list in ascending order  
            Map < String, csord__Subscription__c > subscriptionMap = new Map < String, csord__Subscription__c > ();
            Map < Id, csord__Subscription__c > subIdSubMap = new Map < Id, csord__Subscription__c > ();
            List < CS_SpecificationDTO.ServiceSpecification > srvspecList = new List < CS_SpecificationDTO.ServiceSpecification > ();
            String updatedServiceattachmentstr;
            Map < Id, Attachment > updatedAttSet = new Map < Id, Attachment > ();
            List < String > subNumList = new List < String > ();
            Map < String, List < Number__c >> subNumListMap = new Map < String, List < Number__c >> ();
            for (csord__Subscription__c sub: subsList) {
                subscriptionMap.put(sub.eventId__c, sub);
                subIdSubMap.put(sub.id, sub);
                subNumList.add(sub.csordtelcoa__Subscription_Number__c);
            }
            //EDGE-154773  
            //EDGE-174221 - Updated Query Removed Where Status!=Active condition to get all numbers of related to subscription  
            List < Number__c > numList = [Select id, name, Service_Number__c, Status__c, Subscription_number__c, Service_Id__c, Product_ID__c, toBeCancelled__c From Number__c where Subscription_number__c IN: subNumList and Mobile__c = 'Mobile']; //EDGE-175339  
            if (!numList.isEmpty()) {
                List < Number__c > UpdateNumberlist = new List < Number__c > ();
                for (Number__c num: numList) {
                    if (num.Status__c != 'Active') {
                        List < Number__c > numberList = new List < Number__c > ();
                        if (!subNumListMap.isEmpty() && subNumListMap.get(num.Subscription_number__c) != null) {
                            numberList = subNumListMap.get(num.Subscription_number__c);
                            numberList.add(num);
                        } else {
                            numberList.add(num);
                        }
                        subNumListMap.put(num.Subscription_number__c, numberList);
                    } else { //EDGE-174221 - Updating SimAvailabilityType__c of Active Numbers  
                        for (csord__Service__c serv: servList.values()) {
                            if (serv.Scenario_Type__c == 'Replace SIM') {
                                num.SimAvailabilityType__c = '';
                                UpdateNumberlist.add(num);
                            }
                        }
                    }
                }
                if (!UpdateNumberlist.isEmpty()) {
                    try {
                        Update UpdateNumberlist;
                    } catch (DmlException e) {
                        logException('updateSubscriptionRecordMS', '', correlationId, e.getMessage() + '-' + e.getStackTraceString(), 'Update number failed');
                        if (!Test.isRunningTest() && enableThrowException) {
                            throw e;
                        } //EDGE-215225  
                    }
                }
            }
            //Lists to collect Subscription Numbers to update - Bulkify (Gnana)  
            List < Number__c > listOfActiveSubscriptionNumbers = new List < Number__c > ();
            List < Number__c > listOfInActiveSubscriptionNumbers = new List < Number__c > ();
            Map < String, List < Number__c >> mapStatusSubNum = new Map < String, List < Number__c >> ();
            Set < Id > subsIdsToUpdate = new Set < Id > ();
            Map < Id, List < csord__Service__c >> subsMapToUpdate = new Map < Id, List < csord__Service__c >> ();
            Map < Id, List < csord__Service__c >> subSvcMap = new Map < Id, List < csord__Service__c >> ();
            Map < Id, Boolean > isParentSVCPayOut = new Map < Id, Boolean > (); //EDGE-164355  
            List < csord__Service__c > updatableService = new List < csord__Service__c > ();
            //for every notification update specs  
            for (String key: parameterMap.keySet()) {
                ManageOrderNotificationUtil.Parameters param = parameterMap.get(key);
                String eventType = param.eventType;
                csord__Subscription__c sub = subscriptionMap.get(param.orderIdc);
                if (sub != null) {
                    String notificationAttr = param.notifyAttributes;
                    ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
                    for (ManageOrderNotificationUtil.NotificationAttributes attr: notifyAttrs.attributes) {
                        //EDGE-156196 - start *******************  
                        if (sub.toBeCancelled__c != 'true' && attr.name.contains(STATUS) && attr.value == Label.Complete) {
                            sub.csord__Status__c = Label.MO_status_active;
                            subsListtoUpdate.add(sub);
                        } else if (sub.toBeCancelled__c == 'true' && attr.name.contains(STATUS) && attr.value == Label.Complete) {
                            sub.csord__Status__c = Label.MO_status_inactive;
                            subsListtoUpdate.add(sub);
                        }
                        if (eventType == 'error' && attr.name.contains('error')) {
                            sub.csord__Status__c = Label.MO_Acknowledge_fail_status;
                            subsListtoUpdate.add(sub);
                        }
                        //EDGE-156196 - end *******************  
                        //EDGE-154773  
                        if (!subNumListMap.isEmpty() && subNumListMap.get(sub.csordtelcoa__Subscription_Number__c) != null) {
                            List < Number__c > numbList = subNumListMap.get(sub.csordtelcoa__Subscription_Number__c);
                            for (Number__c num: numbList) {
                                if (num.toBeCancelled__c != true && attr.name.contains(STATUS) && attr.value == Label.Complete) { //EDGE-154773       
                                    listOfActiveSubscriptionNumbers.add(num);
                                } else if (num.toBeCancelled__c == true && attr.name.contains(STATUS) && attr.value == Label.Complete) {
                                    listOfInActiveSubscriptionNumbers.add(num);

                                }

                            }
                        }
                    }
                    //added as part of B2B-328 - Solution Supress - Start  
                    csord__Subscription__c solution;
                    csord__Service__c serv;
                    if (solToSubMap.containsKey(sub.cssdm__solution_association__c) && solToSubMap.get(sub.cssdm__solution_association__c).csord__Status__c != 'Active' && sub.csord__Status__c == 'Active') {
                        solution = solToSubMap.get(sub.cssdm__solution_association__c);
                        solution.csord__Status__c = 'Active';
                        subsListtoUpdate.add(solution);
                        //EDGE-224556 - start
                        if (solToServMap.containsKey(sub.cssdm__solution_association__c) && solToServMap.get(sub.cssdm__solution_association__c).csord__Status__c != 'Connected') {
                            serv = solToServMap.get(sub.cssdm__solution_association__c);
                            serv.csord__Status__c = 'Connected';
                            updatableService.add(serv);
                            //EDGE-224556 - End
                        }
                    } //added as part of B2B-328 - Solution Supress - End  
                    toLog += '*' + sub.Id + '-->' + sub.csord__Status__c + '\n';
                }

            }
            // Calling UpdateNumberStatusBulkified method for Active Subscription Numbers (Gnana)  
            if (listOfActiveSubscriptionNumbers != null && listOfActiveSubscriptionNumbers.size() > 0) {
                mapStatusSubNum.put('Active', listOfActiveSubscriptionNumbers);
                //NumberUtil.UpdateNumberStatusBulkified(null,listOfActiveSubscriptionNumbers,'Active');  
            }
            // Calling UpdateNumberStatusBulkified method for InActive Subscription Numbers (Gnana)  
            if (listOfInActiveSubscriptionNumbers != null && listOfInActiveSubscriptionNumbers.size() > 0) {
                mapStatusSubNum.put('Inactive', listOfInActiveSubscriptionNumbers);
                //NumberUtil.UpdateNumberStatusBulkified(null,listOfInActiveSubscriptionNumbers,'Inactive');  
            }
            NumberUtil.UpdateNumberStatusBulkified2(null, mapStatusSubNum);

            for (csord__Subscription__c sub: subsListtoUpdate) {
                subIdSubMap.put(sub.Id, sub); //EDGE-144704 & EDGE-156046  
                
            }
            List < Id > servIdList = new List < Id > ();
            for (Id servId: servList.keyset()) {
                servIdList.add(servId);
            }

            Map < Id, String > serviceAttachmentMap = new Map < Id, String > ();
            Map < Id, Attachment > servspecattchmentMap = new Map < Id, Attachment > ();
            for (Attachment att: [Select id, body, parentId from Attachment where parentId in: servIdList]) {
                serviceAttachmentMap.put(att.parentId, att.body.toString());
                servspecattchmentMap.put(att.parentId, att);
            }
            for (csord__Service__c serv: servList.values()) {
                for (String eachService: serviceAttachmentMap.keySet()) {
                    if (serviceAttachmentMap.containsKey(serv.Id)) {
                        srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(serv.Id)), 'BILLING');
                    }
                }
                //EDGE-156046  
                //To count services on each subscription Start  
                if (subSvcMap.containsKey(serv.csord__Subscription__c)) {
                    List < csord__Service__c > svcListAE = subSvcMap.get(serv.csord__Subscription__c);
                    svcListAE.add(serv);
                    subSvcMap.put(serv.csord__Subscription__c, svcListAE);
                } else {
                    List < csord__Service__c > svcListNew = new List < csord__Service__c > ();
                    svcListNew.add(serv);
                    subSvcMap.put(serv.csord__Subscription__c, svcListNew);
                }
                //To count services on each subscription end  
                /*EDGE-156046  
Count number of services against subscriptions where actionType on service is PayOut*/
                if (serv.Action_Type__c != null && serv.Action_Type__c == 'PayOut' && subIdSubMap.get(serv.csord__Subscription__c).csord__Status__c != Label.MO_Acknowledge_fail_status) { //When error is recieved from BDS, not processing notification  
                    serv.csord__Status__c = 'Paid Out';
                    //subsIdsToUpdate.add(serv.csord__Subscription__c);  
                    if (subsMapToUpdate.containsKey(serv.csord__Subscription__c)) {
                        List < csord__Service__c > svcListAE = subsMapToUpdate.get(serv.csord__Subscription__c);
                        svcListAE.add(serv);
                        subsMapToUpdate.put(serv.csord__Subscription__c, svcListAE);
                    } else {
                        List < csord__Service__c > svcListNew = new List < csord__Service__c > ();
                        svcListNew.add(serv);
                        subsMapToUpdate.put(serv.csord__Subscription__c, svcListNew);
                    }
                    updatableService.add(serv);
                    if (serv.csord__Service__c == null) {
                        isParentSVCPayOut.put(serv.csord__Subscription__c, true); //EDGE-164355  
                    }
                }
                updatedServiceattachmentstr = serviceAttachmentMap.get(serv.Id);
                Map < String, String > additionalAttrs = new Map < String, String > ();
                for (CS_SpecificationDTO.ServiceSpecification spec: srvspecList) {
                    if (servList.get(spec.serviceId).toBeCancelled__c == 'true') {
                        updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(updatedServiceattachmentstr, spec.guid, 'status', 'Disconnected');
                        additionalAttrs.put('completionDate', String.valueOf(System.now())); //EDGE-174924  
                    }
                    //Added for EDGE-144704 & EDGE:156046  
                    else if (servList.get(spec.serviceId).Action_Type__c != null && servList.get(spec.serviceId).Action_Type__c.equalsIgnoreCase('PayOut')) {
                        updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(updatedServiceattachmentstr, spec.guid, 'status', 'Paid Out');
                        additionalAttrs.put('completionDate', String.valueOf(System.now())); //EDGE-174924  
                    } else if (servList.get(spec.serviceId).Action_Type__c != null && servList.get(spec.serviceId).Action_Type__c.equalsIgnoreCase('Suspended')) {
                        additionalAttrs.put('completionDate', String.valueOf(System.now())); //EDGE-174924  
                    } else {
                        updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(updatedServiceattachmentstr, spec.guid, 'status', 'Complete');
                        additionalAttrs.put('completionDate', String.valueOf(System.now())); //EDGE-174924  
                    }
                    if (updatedServiceattachmentstr != null) {
                        Attachment toUpdateAtt = servspecattchmentMap.get(spec.serviceId);
                        toUpdateAtt.body = Blob.valueof(updatedServiceattachmentstr);
                        updatedAttSet.put(toUpdateAtt.id, toUpdateAtt);
                    }
                    //EDGE-174924  
                    if (!additionalAttrs.isEmpty())
                        csedm.API_1.addCharacteristic(spec.serviceId, spec.guid, additionalAttrs);
                }
            }
            /*EDGE-144704 & EDGE-156046 start  
Checking if number of services with actionType PayOut on subscription is equal to all the services on subscription, If yes then updating subscription status to Paid Out as well.  
*/
            for (Id subId: subsMapToUpdate.keySet()) {
                if (subsMapToUpdate.get(subId).size() == subSvcMap.get(subId).size() || (isParentSVCPayOut != null && isParentSVCPayOut.size() > 0 && isParentSVCPayOut.get(subId))) { //EDGE-164355 : added isParentSVCPayOut.get(subId) & added null check EDGE-180787  
                    csord__Subscription__c sub = subIdSubMap.get(subId);
                    sub.csord__Status__c = 'Paid Out';
                    subIdSubMap.put(sub.Id, sub);
                    toLog += '*' + sub.Id + '-->' + sub.csord__Status__c + '\n';
                }
            }
            //EDGE-144704 & EDGE-156046 End  
            try {
                if (!updatableService.isEmpty()) {
                    update updatableService;
                }
            } catch (DmlException e) {
                logException('updateSubscriptionRecordMS', '', correlationId, e.getMessage() + '-' + e.getStackTraceString(), 'Update service records failed');
                if (!Test.isRunningTest() && enableThrowException) {
                    throw e;
                } //EDGE-215225  
            }
            try {
                if (!updatedAttSet.isEmpty()) {
                    update updatedAttSet.values();
                }
            } catch (DmlException e) {
                logException('updateSubscriptionRecordMS', '', correlationId, e.getMessage() + '-' + e.getStackTraceString(), 'Update attribute set failed');
                if (!Test.isRunningTest() && enableThrowException) {
                    throw e;
                } //EDGE-215225  
            }
            try {
                if (!subIdSubMap.isEmpty())
                    update subIdSubMap.values();
            } catch (DmlException e) {
                logException('updateSubscriptionRecordMS', '', correlationId, e.getMessage() + '-' + e.getStackTraceString(), 'Update subscription records failed');
                if (!Test.isRunningTest() && enableThrowException) {
                    throw e;
                } //EDGE-215225  
            }
            if (!subsList.isEmpty()) {
                updateSchedulesonCallback(subIdSubMap.values());
            }
            if (!String.isBlank(toLog)) {
                Logger2 log = Logger2.getLogger('UpdateSubscription');
                log.logMessages(JSON.serialize(toLog, true), '', '', '', '', '', false, false, 200, '', '', '');
                log.exitLogger();
            }
        } catch (Exception e) {
            logException('updateSubscriptionRecordMS', '', correlationId, e.getMessage() + '-' + e.getStackTraceString(), 'Update service records with notifications coming from');
            if (!Test.isRunningTest() && enableThrowException) {
                throw e;
            } //EDGE-215225  
        }
    }

    @TestVisible
    private static void updateServiceRecordMS(List < NotificationParameters > paramsList, Map < String, ManageOrderNotificationUtil.Parameters > parameterMap, List < csord__Order__c > orderList, List < csord__Service__c > srvcList, Map < String, String > serviceAttachmentMap, Map < String, Attachment > servAttachmentRecordMap, List < csord__Service__c > ReplacedserviceSubsList, Map < csord__Order__c, List < csord__Subscription__c >> orderToSubMap) {
        boolean enableThrowException;
        if (!Test.isRunningTest()) {
            enableThrowException = Boolean.valueOf(EnvironmentVariable__c.getValues('EnableThrowException').Value__c); //EDGE-215225  
        }
        // String eventsrvcNumber;  
        List < String > guidList = new List < String > (); //String orderItemIdc;String notificationAttr;String orderItemDetails;String eventType;Boolean stopprocessing = false;//String notifStatus='';  
        List < String > keyparams = new List < String > ();
        String orderId;
        String srvcNumber;
        String instanceId;
        //Boolean isSuspendResume=false;  
        Map < Id, Boolean > ordIdisSuspendResume = new Map < Id, Boolean > ();
        List < Id > orderIdList = new List < Id > ();
        Map < String, String > specToUpdatedStatusMap = new Map < String, String > ();
        Map < String, Map < String, String >> guidToAttributesMap = new Map < String, Map < String, String >> (); //added as part of EDGE-154104  
        Map < String, String > guidToservMap = new Map < String, String > (); //added as part of EDGE-154104  
        Map < Id, DateTime > servIDtoActivationDateMap = new Map < Id, DateTime > (); //added as part of EDGE-154104 // Modified Date to DateTime as part of EDGE-174924  
        Map < Id, DateTime > servIDtoDeactivationDateMap = new Map < Id, DateTime > (); //EDGE-164354 // Modified Date to DateTime as part of EDGE-174924  
        List < CS_SpecificationDTO.ServiceSpecification > srvspList = new List < CS_SpecificationDTO.ServiceSpecification > (); //added as part of EDGE-165183  
        Map < String, String > MapsrvcnumandId = new Map < String, Id > (); //EDGE-175697  
        Map < String, String > Servidguid = new Map < String, String > (); //EDGE-175697  
        Map < String, String > Guidnotifstatus = new Map < String, String > (); //EDGE-175697  
        Map < String, String > ServidStatus = new Map < String, String > (); //EDGE-175697  
        Map < String, String > Servnumnotifstatus = new Map < String, String > (); //EDGE-175697  
        Map < String, csord__Order__c > orderIdtoOrdMap = new Map < String, csord__Order__c > (); //added as part of EDGE-170550  
        Map < String, String > rejectionReasonmap = new Map < String, String > (); //added as part of EDGE-170550  
        Map < String, Boolean > amendnotAllowedMap = new Map < String, Boolean > (); //added as part of EDGE-170550  
        Map < String, Boolean > cancelnotAllowedMap = new Map < String, Boolean > (); //added as part of EDGE-170550  
        Map < String, String > acceptedOrdermap = new Map < String, String > (); //added as part of EDGE-170550  
        String toLog = '';
        try {
            Map < Id, csord__Service__c > srvcListtoUpdate = new Map < Id, csord__Service__c > ();
            Map < Id, csord__Service__c > srvcUpdate = new Map < Id, csord__Service__c > ();
            // String subscriptionId = '';  
            // String primaryOrderId = '';  
            orderList = (List < csord__Order__c > ) CustomSortUtility.customSort(orderList, 'createddate', 'DateTime');
            //EDGE-180743 start  
            Map < ID, csord__Subscription__c > orderSubsMap = new Map < ID, csord__Subscription__c > ();
            for (csord__Subscription__c sub: [select Id, changeType__c, csord__Order__c from csord__Subscription__c where csord__Order__c in: orderList]) {
                orderSubsMap.put(sub.csord__Order__c, sub);
            }
            for (Id ordId: orderSubsMap.keySet()) {
                orderIdList.add(ordId);
                if (orderSubsMap.get(ordId).changeType__c != null && (orderSubsMap.get(ordId).changeType__c.containsIgnoreCase('Resume') || orderSubsMap.get(ordId).changeType__c.containsIgnoreCase('Suspend'))) {
                    ordIdisSuspendResume.put(ordId, true);
                } else {
                    ordIdisSuspendResume.put(ordId, false);
                }
            }

            for (csord__Order__c ord: orderList) {
                orderIdtoOrdMap.put(ord.csord__Order_Number__c, ord); //added as part of EDGE-170550  
            }
            Map < String, csord__Service__c > serviceMap = new Map < String, csord__Service__c > ();
            Map < String, csord__Service__c > serviceMapWithId = new Map < String, csord__Service__c > ();
            Set < String > orderIds = new Set < String > ();
            Set < String > replacedSubscriptionIds = new Set < String > ();
            Map < Id, Attachment > updatedAttSet = new Map < Id, Attachment > ();
            Map < Id, List < csord__Service__c >> childMap = new Map < Id, List < csord__Service__c >> (); //added as part of EDGE-165183  
            for (csord__Service__c svc: srvcList) {
                orderIds.add(svc.csord__Order__r.id);
                replacedSubscriptionIds.add(svc.ReplacedSubscription__c);
                serviceMap.put(svc.csordtelcoa__Service_Number__c, svc);
                serviceMapWithId.put(svc.Id, svc);
                MapsrvcnumandId.put(svc.csordtelcoa__Service_Number__c, svc.Id); // EDGE-175697  
                if (svc.csord__Service__c != null) { //added as part of EDGE-165183  
                    if (childMap.containsKey(svc.csord__Service__r.id)) {
                        List < csord__Service__c > tempList = childMap.get(svc.csord__Service__r.id);
                        tempList.add(svc);
                        childMap.put(svc.csord__Service__r.id, tempList);
                    } else {
                        List < csord__Service__c > tempList = new List < csord__Service__c > ();
                        tempList.add(svc);
                        childMap.put(svc.csord__Service__r.id, tempList);
                    }
                }
            }
            for (csord__Service__c svc: ReplacedserviceSubsList) {
                //EDGE-175697  
                if (serviceMap.get(svc.csordtelcoa__Service_Number__c) == null) {
                    serviceMap.put(svc.csordtelcoa__Service_Number__c, svc);
                    serviceMapWithId.put(svc.Id, svc);
                } // EDGE-175697  
                // serviceMap.put(svc.csordtelcoa__Service_Number__c, svc); EDGE-175697  
                //serviceMapWithId.put(svc.Id,svc);  
            }
            //for every notification update specs  
            srvspecList = new List < CS_SpecificationDTO.ServiceSpecification > ();
            Map < ID, List < CS_SpecificationDTO.ServiceSpecification >> mapSerIDSpecList = new Map < ID, List < CS_SpecificationDTO.ServiceSpecification >> ();
            for (String eachService: serviceAttachmentMap.keySet()) {
                List < CS_SpecificationDTO.ServiceSpecification > temp = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)), FULFILMENT);
                mapSerIDSpecList.put(eachService, temp);
                srvspecList.addAll(temp);
                //srvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),FULFILMENT));  
            }
            for (CS_SpecificationDTO.ServiceSpecification spec: srvspecList) { //added as part of EDGE-154104  
                guidToservMap.put(spec.guid, spec.serviceId);
                Servidguid.put(spec.serviceId, spec.guid); //EDGE-175697  
            }
            Map < String, CS_SpecificationDTO.ServiceSpecification > serviceSpecMap = new Map < String, CS_SpecificationDTO.ServiceSpecification > ();
            serviceSpecMap = getallOrderSpecs(srvspecList);

            String currentSpecStatus;
            Map < String, Set < string >> servGuidMap = new Map < String, Set < string >> (); //EDGE-184831  
            String orId;
            String srNum;
            for (NotificationParameters notif: paramsList) {
                Set < String > guidSet = new Set < String > (); //EDGE-184831  
                Map < String, String > childIdstatus = new Map < String, String > ();
                if (notif.orderItemId != null) { //added as part of EDGE-170550  
                    List < String > keyparam = notif.orderItemId.split('\\|');
                    if (keyparam.size() > 0) {
                        orId = keyparam[0];
                    }
                    if (keyparam.size() > 1) {
                        srNum = keyparam[1];
                    }
                } else {
                    orId = notif.externalOrderId;
                }
                if (notif.orderItemDetails != null) { //added as part of EDGE-170550  
                    toLog += '*' + notif.orderItemId + '-->' + notif.msCorrelationId + '\n';
                    ManageOrderNotificationUtil.Product productUpdates = ManageOrderNotificationUtil.parse('{' + String.valueOf(notif.orderItemDetails) + '}');
                    //EDGE-184831 start  
                    guidSet.add(productUpdates.productId);
                    childIdstatus = getChildProducts(productUpdates);
                    guidSet.addAll(childIdstatus.keySet());
                    servGuidMap.put(srNum, guidSet); ////EDGE-184831  
                    //EDGE-184831 end  
                    specToUpdatedStatusMap.put(productUpdates.productId, productUpdates.status);
                    specToUpdatedStatusMap.putAll(getChildProducts(productUpdates));
                    guidList.addAll(specToUpdatedStatusMap.keySet());
                    system.debug('productUpdates==>' + productUpdates);
                    system.debug('productUpdates.attributes==>' + productUpdates.attributes);
                    // for(ManageOrderNotificationUtil.Product prd :productUpdates){     //added as part of EDGE-154104 ---------------Start  
                    for (ManageOrderNotificationUtil.NotificationAttributes attr: productUpdates.attributes) {
                        Map < String, String > attrMap = new Map < String, String > ();
                        if (attr.name.equalsIgnoreCase('ServiceActivationDate')) {
                            if (attr.value != null && !String.isBlank(attr.value)) {
                                attrMap.put(attr.name, attr.value);
                                attrMap.put('completionDate', attr.value); // Added as part of EDGE-174924  
                                Integer hoursToAdd = Integer.valueOf((attr.value.substringAfter('+')).substringBefore(':')); // Added as part of EDGE-174924  
                                //guidToAttributesMap.put(productUpdates.productId,attrMap);  
                                datetime servActivation = (datetime) json.deserialize('"' + attr.value + '"', datetime.class); // Added as part of EDGE-174924  
                                //Date servActivation= Date.valueOF(attr.value.substringBefore('T'));//added as part of EDGE-169583  
                                //Date servActivation=(date)json.deserialize('"'+attr.value+'"', date.class);  
                                servIDtoActivationDateMap.put(guidToservMap.get(productUpdates.productId), servActivation.addHours(hoursToAdd)); // Modified as part of EDGE-174924  
                            }
                        } else if (attr.name.equalsIgnoreCase('ServiceDeactivationDate')) { // start of EDGE-164354  
                            if (attr.value != null && !String.isBlank(attr.value)) {
                                attrMap.put(attr.name, attr.value);
                                attrMap.put('completionDate', attr.value); // Added as part of EDGE-174924  
                                Integer hoursToAdd = Integer.valueOf((attr.value.substringAfter('+')).substringBefore(':')); // Added as part of EDGE-174924  
                                //Date servDeactivation= Date.valueOF(attr.value.substringBefore('T'));  
                                datetime servDeactivation = (datetime) json.deserialize('"' + attr.value + '"', datetime.class); // Added as part of EDGE-174924  
                                servIDtoDeactivationDateMap.put(guidToservMap.get(productUpdates.productId), servDeactivation.addHours(hoursToAdd)); // Modified as part of EDGE-174924  
                            }
                        } // end of EDGE-164354  
                        if (guidToAttributesMap.containsKey(productUpdates.productId)) {
                            Map < String, String > tempMap = guidToAttributesMap.get(productUpdates.productId);
                            tempMap.putAll(attrMap);
                            guidToAttributesMap.put(productUpdates.productId, tempMap);
                        } else {
                            guidToAttributesMap.put(productUpdates.productId, attrMap);
                        }
                        // guidToAttributesMap.put(productUpdates.productId,attrMap);  
                    }
                    if (productUpdates.childProduct != NULL) {
                        for (ManageOrderNotificationUtil.childProduct childProd: productUpdates.childProduct) {
                            Guidnotifstatus.put(childProd.productId, childProd.status); //EDGE-175697  
                            for (ManageOrderNotificationUtil.NotificationAttributes attrChild: childProd.attributes) {
                                Map < String, String > attrMap = new Map < String, String > ();
                                if (attrChild.name.equalsIgnoreCase('ServiceActivationDate')) {
                                    if (attrChild.value != null && !String.isBlank(attrChild.value)) {
                                        attrMap.put(attrChild.name, attrChild.value);
                                        attrMap.put('completionDate', attrChild.value); // Added as part of EDGE-174924  
                                        Integer hoursToAdd = Integer.valueOf((attrChild.value.substringAfter('+')).substringBefore(':')); // Added as part of EDGE-174924  
                                        //datetime servActivationDate = (datetime)json.deserialize('"'+attrChild.value+'"', datetime.class);  
                                        //Date servActivation= Date.valueOF(attrChild.value.substringBefore('T'));//added as part of EDGE-169583  
                                        datetime servActivation = (datetime) json.deserialize('"' + attrChild.value + '"', datetime.class); // Added as part of EDGE-174924  
                                        //Date servActivation= Date.valueOF(servActivationDate);  
                                        //Date servActivation=(date)json.deserialize('"'+attrChild.value+'"', date.class);  
                                        servIDtoActivationDateMap.put(guidToservMap.get(childProd.productId), servActivation.addHours(hoursToAdd)); // Modified as part of EDGE-174924  
                                    }
                                } else if (attrChild.name.equalsIgnoreCase('ServiceDeactivationDate')) { // start of EDGE-164354  
                                    if (attrChild.value != null && !String.isBlank(attrChild.value)) {
                                        attrMap.put(attrChild.name, attrChild.value);
                                        attrMap.put('completionDate', attrChild.value); // Added as part of EDGE-174924  
                                        Integer hoursToAdd = Integer.valueOf((attrChild.value.substringAfter('+')).substringBefore(':')); // Added as part of EDGE-174924  
                                        //Date servDeactivation= Date.valueOF(attrChild.value.substringBefore('T'));  
                                        datetime servDeactivation = (datetime) json.deserialize('"' + attrChild.value + '"', datetime.class); // Added as part of EDGE-174924  
                                        servIDtoDeactivationDateMap.put(guidToservMap.get(childProd.productId), servDeactivation.addHours(hoursToAdd)); // Modified as part of EDGE-174924  
                                    }
                                } // end of EDGE-164354  
                                if (attrChild.name.equalsIgnoreCase('DeviceCareId')) {
                                    if (attrChild.value != null && !String.isBlank(attrChild.value)) {
                                        attrMap.put(attrChild.name, attrChild.value);
                                    }
                                }
                                if (guidToAttributesMap.containsKey(childProd.productId)) {
                                    Map < String, String > tempMap = guidToAttributesMap.get(childProd.productId);
                                    tempMap.putAll(attrMap);
                                    guidToAttributesMap.put(childProd.productId, tempMap);
                                } else {
                                    guidToAttributesMap.put(childProd.productId, attrMap);
                                }
                            }
                        }
                    }
                    //}  
                    //added by vaibhav----------------END  
                }
            }

            //EDGE-175697 start  
            if (!Servidguid.isEmpty() && !Guidnotifstatus.isEmpty()) {
                for (String srvcid: Servidguid.keySet()) {
                    if (Guidnotifstatus.get(Servidguid.get(srvcid)) != null) {
                        ServidStatus.put(srvcid, Guidnotifstatus.get(Servidguid.get(srvcid)));
                    }
                }
            }
            if (!ServidStatus.isEmpty() && !MapsrvcnumandId.isEmpty()) {
                for (String srvcnum: MapsrvcnumandId.keySet()) {
                    if (ServidStatus.get(MapsrvcnumandId.get(srvcnum)) != null) {
                        Servnumnotifstatus.put(srvcnum, ServidStatus.get(MapsrvcnumandId.get(srvcnum)));
                    }
                }
            }
            //EDGE-175697 end  
            Set < Id > serviceIds = new Set < Id > ();
            Map < String, String > replacedSpecToUpdatedStatusMap = new Map < String, String > ();
            if (!specToUpdatedStatusMap.isEmpty()) {
                specMapUpdateErrorStatus(specToUpdatedStatusMap, replacedSpecToUpdatedStatusMap, serviceSpecMap, serviceIds, serviceAttachmentMap, servAttachmentRecordMap);
            }

            if (!serviceMapWithId.isEmpty()) {
                for (String ser: serviceMapWithId.keyset()) {
                    srvcListtoUpdate.put(ser, serviceMapWithId.get(ser));
                }
                //EDGE-175697 added tobecancelled field to soql  
                //DPG-4545 added csord__Subscription__r.Suspension_reason_summary__c field in query  
                List < csord__Service__c > serviceList = [SELECT Id, Name, csord__Status__c, csord__Order__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, CreatedDate, csord__Subscription__c, csord__Order__r.Name, csord__Subscription__r.csord__Status__c, toBeCancelled__c, Action_Type__c, csord__Subscription__r.Suspension_reason_summary__c, csordtelcoa__Cancelled_By_Change_Process__c, csord__Subscription__r.csordtelcoa__Cancelled_By_Change_Process__c from csord__Service__c where Id IN: serviceIds FOR UPDATE];
                if (serviceList != null) {
                    for (csord__Service__c srv: serviceList) srvcListtoUpdate.put(srv.Id, srv);
                }
            }
            //}  
            //if notification type is statusNotification update service specs  
            //update the specs as per status update recieved  
            //update the specs as per status update recieved  
            Map < String, String > additionalAttrs = new Map < String, String > ();
            Map < String, String > existingAdditionalAttrs = new Map < String, String > ();
            //Map<String,<String,String>> guidTOexistingAdditionalAttrs = new Map<String,<String,String>>();  
            Map < String, String > dateAdditionalAttrs = new Map < String, String > ();
            /*Datetime forecastedDate = NULL; //Commented as part of EDGE-165183  
Datetime committedDate = NULL;*/
            //EDGE : 99309 ::Added  
            String tenancyId;
            Map < String, String > serviceNotifstatus = new Map < String, String > ();
            Map < String, Map < String, Datetime >> srvDateMap = new Map < String, Map < String, Datetime >> (); //added as part of EDGE-165183  
            for (NotificationParameters noti: paramsList) {
                string srvcNum;
                String oId;
                Map < String, Datetime > dateMap = new Map < String, Datetime > (); //added as part of EDGE-165183  
                //additionalAttrs = new Map<String,String>();  
                //existingAdditionalAttrs = new Map<String,String>();  
                //dateAdditionalAttrs = new Map<String,String>();  
                ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
                if (String.isNotEmpty(noti.orderItemId)) {
                    params.orderIdc = noti.orderItemId;
                    List < String > kparams = params.orderIdc.split('\\|');
                    if (kparams.size() > 0) {
                        oId = kparams[0];
                    }
                    if (kparams.size() > 1) {
                        srvcNum = kparams[1];
                    }
                } else { //added as part of EDGE-170550  
                    oId = noti.externalOrderId;
                }
                ManageOrderNotificationUtil.NotificationAttributesDataObject notifAttrs = ManageOrderNotificationUtil.parseAttributes('{' + String.valueOf(noti.notificationAttributes) + '}');
                for (ManageOrderNotificationUtil.NotificationAttributes attr: notifAttrs.attributes) {
                    if (attr.name.contains('status') && attr.value == Label.Complete) {
                        serviceNotifstatus.put(srvcNum, 'Complete');
                        //  notifStatus  = 'Complete';  
                    } else if (attr.name.contains('status') && attr.value == 'In Progress') {
                        serviceNotifstatus.put(srvcNum, 'In Progress');
                        //   notifStatus  = 'In Progress';  
                    } else if (attr.name.contains('status') && attr.value == 'Cancelled') {
                        serviceNotifstatus.put(srvcNum, 'Cancelled');
                    }
                    toLog += '*' + noti.orderItemId + '-->' + noti.msCorrelationId + '\n';
                }
                serviceNotifstatus.putAll(Servnumnotifstatus); //EDGE-175697  
                if (noti.eventType == 'statusNotification' || noti.eventType == 'delay' && !serviceMap.isEmpty()) {
                    ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes('{' + String.valueOf(noti.notificationAttributes) + '}');
                    List < CS_SpecificationDTO.ServiceSpecification > specList = new List < CS_SpecificationDTO.ServiceSpecification > (); //added as part of EDGE-165183  
                    if (serviceMap.get(srvcNum) != null && mapSerIDSpecList.get(serviceMap.get(srvcNum).Id) != null) {
                        specList.addAll(mapSerIDSpecList.get(serviceMap.get(srvcNum).Id));
                    }
                    if (serviceMap.get(srvcNum) != null && childMap.containsKey((serviceMap.get(srvcNum).Id))) {
                        for (csord__Service__c serv: childMap.get(serviceMap.get(srvcNum).id)) {
                            if (mapSerIDSpecList.get(serv.id) != null) {
                                specList.addAll(mapSerIDSpecList.get(serv.id));
                            }
                        }
                    } //EDGE-165183 -- End  
                    for (CS_SpecificationDTO.ServiceSpecification specs: specList) {
                        additionalAttrs = new Map < String, String > ();
                        existingAdditionalAttrs = new Map < String, String > ();
                        dateAdditionalAttrs = new Map < String, String > ();
                        if (specToUpdatedStatusMap.containsKey(specs.guid)) {
                            currentSpecStatus = specs.status;
                            String udtattbody;
                            if (currentSpecStatus.contains('Disconnect') && specToUpdatedStatusMap.get(specs.guid).contains(Label.Complete)) {
                                specToUpdatedStatusMap.put(specs.guid, Label.MO_status_disconnected);
                                dateAdditionalAttrs.put('completionDate', String.ValueOf(System.now())); //EDGE-174925  
                                udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
                                //csedm.API_1.updateServiceSpecificationPropertyById(specs.serviceId, specs.guid, STATUS, Label.MO_status_disconnected);  
                            } else if (currentSpecStatus.contains('Disconnect') && specToUpdatedStatusMap.get(specs.guid).contains('In Progress')) {
                                specToUpdatedStatusMap.put(specs.guid, 'Disconnect In Progress');
                                udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
                            } else if (currentSpecStatus.contains('Suspend') && specToUpdatedStatusMap.get(specs.guid).contains('In Progress')) { //EDGE-125635 -updating service spec status in case of suspend - In progress  
                                system.debug('specToUpdatedStatusMap'); //DPG-4545  
                                system.debug(specToUpdatedStatusMap); // DPG-4545  
                                //specToUpdatedStatusMap.put(specs.guid, system.label.subscription_Suspended_Status);//EDGE-180743 commented this line  
                                specToUpdatedStatusMap.put(specs.guid, system.label.srvSpec_suspendInProgress_Status); //EDGE-180743  
                                udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
                            } //EDGE-180743 starts  
                            //DPG-4545 -- Updated for Resume Status Update for childs Specs - Mahima-- removed temperorily && srvcListtoUpdate.get(specs.serviceId).csord__Subscription__r.Suspension_reason_summary__c==''  
                            else if (currentSpecStatus.contains('Resume') && specToUpdatedStatusMap.get(specs.guid).contains('In Progress')) { //EDGE-125635 -updating service spec status in case of suspend - In progress  
                                specToUpdatedStatusMap.put(specs.guid, system.label.srvSpec_resumeInProgress_Status);
                                udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
                            } //EDGE-180743 starts  
                            //DPG-4545 Spec Status Fix  Suspend complete or Intermediat Resume.  
                            else if ((currentSpecStatus.contains('Suspend') || (currentSpecStatus.contains('Resume') && (srvcListtoUpdate.get(specs.serviceId).csord__Subscription__r.Suspension_reason_summary__c != '' && srvcListtoUpdate.get(specs.serviceId).csord__Subscription__r.Suspension_reason_summary__c != null))) && specToUpdatedStatusMap.get(specs.guid).contains(Label.Complete)) { //EDGE-125635 -updating service spec status in case of suspend - Complete  
                                system.debug('currentSpecStatus==>' + currentSpecStatus);
                                system.debug('specToUpdatedStatusMap.get(specs.guid)===>' + specToUpdatedStatusMap.get(specs.guid));
                                system.debug('srvcListtoUpdate.get(specs.serviceId).csord__Subscription__r.Suspension_reason_summary__c==>' + srvcListtoUpdate.get(specs.serviceId).csord__Subscription__r.Suspension_reason_summary__c);
                                dateAdditionalAttrs.put('completionDate', String.ValueOf(System.now())); //EDGE-174924  
                                specToUpdatedStatusMap.put(specs.guid, system.label.subscription_Suspended_Status);
                                udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
                            } else if (srvcListtoUpdate.get(specs.serviceId).toBeCancelled__c == 'true' && srvcListtoUpdate.get(specs.serviceId).csord__Status__c.contains('Disconnect')) {
                                String stat;
                                if (specToUpdatedStatusMap.get(specs.guid).contains('In Progress')) {
                                    stat = Label.MO_status_disconnect_in_progress;
                                } else if (specToUpdatedStatusMap.get(specs.guid).contains('Complete') || specToUpdatedStatusMap.get(specs.guid).contains('Disconnect')) {
                                    if (srvcListtoUpdate.get(specs.serviceId).Action_Type__c != null && srvcListtoUpdate.get(specs.serviceId).Action_Type__c.equalsIgnoreCase('PayOut')) { //EDGE-184795  
                                        stat = 'Complete';
                                    } else {
                                        stat = Label.MO_status_disconnected;
                                    }
                                }
                                dateAdditionalAttrs.put('completionDate', String.ValueOf(System.now())); //EDGE-174924  
                                udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', stat);
                                //EDGE-175697  
                            } else {
                                if (specToUpdatedStatusMap.get(specs.guid).contains(Label.Complete)) {
                                    dateAdditionalAttrs.put('completionDate', String.ValueOf(System.now())); //EDGE-174924  
                                }
                                udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
                              
                            }
                                Attachment att = servAttachmentRecordMap.get(specs.serviceId);
                                att.body = Blob.valueOf(udtattbody);
                                serviceAttachmentMap.put(att.parentId, att.Body.toString());
                                updatedAttSet.put(att.id, att);
                            for (CS_SpecificationDTO.SimpleAttributes simpleAttr: specs.additionalAttributes) {
                                existingAdditionalAttrs.put(simpleAttr.name, simpleAttr.value);
                            }
                            for (ManageOrderNotificationUtil.NotificationAttributes attr: notifyAttrs.attributes) {
                                //if(currentSpecStatus =='In Progress'){  //commented as part of EDGE-165183  
                                if (attr.name.contains('currentForecastedDeliveryDate') || attr.name.contains('current Forecasted Delivery Date')) {
                                    dateAdditionalAttrs.put(attr.name, attr.value);
                                    //forecastedDate = (datetime)json.deserialize('"'+attr.value+'"', datetime.class);//commented as part of EDGE-165183  
                                    dateMap.put('currentForecastedDeliveryDate', (datetime) json.deserialize('"' + attr.value + '"', datetime.class)); //added as part of EDGE-165183  
                                    existingAdditionalAttrs.remove('currentForecastedDeliveryDate'); //added as part of EDGE-165183  
                                } else if (attr.name.contains('telstraCommittedDate') || attr.name.contains('telstra Committed Date')) {
                                    dateAdditionalAttrs.put(attr.name, attr.value);
                                    //committedDate = (datetime)json.deserialize('"'+attr.value+'"', datetime.class); //commented as part of EDGE-165183  
                                    dateMap.put('telstraCommittedDate', (datetime) json.deserialize('"' + attr.value + '"', datetime.class)); //added as part of EDGE-165183  
                                    existingAdditionalAttrs.remove('telstraCommittedDate'); //added as part of EDGE-165183  
                                } else if (attr.name.contains('productCompletionDate') || attr.name.contains('product Completion Date')) { //added as part of EDGE-154104  
                                    dateAdditionalAttrs.put(attr.name, attr.value);
                                } else if (attr.name.contains('productCancellationDate')) { // EDGE-193568 start  
                                    dateAdditionalAttrs.put(attr.name, attr.value);
                                    dateMap.put('productCancellationDate', (datetime) json.deserialize('"' + attr.value + '"', datetime.class));
                                    existingAdditionalAttrs.remove('productCancellationDate');
                                } // EDGE-193568 end  
                                //EDGE : 99309 ::Added  
                                if (existingAdditionalAttrs.containsKey('TenancyID')) {
                                    tenancyId = existingAdditionalAttrs.get('TenancyID');
                                }
                                //}  
                                if (serviceMap.get(srvcNum) != null) { //added as part of EDGE-165183  
                                    if (srvDateMap.containsKey(serviceMap.get(srvcNum).id)) {
                                        Map < String, Datetime > tempMap = srvDateMap.get(serviceMap.get(srvcNum).id);
                                        tempMap.putAll(dateMap);
                                        srvDateMap.put(serviceMap.get(srvcNum).id, tempMap);
                                    } else {
                                        srvDateMap.put(serviceMap.get(srvcNum).id, dateMap);
                                    }
                                }
                            }
                            //additionalAttrs.putAll(existingAdditionalAttrs);  
                            //guidTOexistingAdditionalAttrs.put(specs.guid,existingAdditionalAttrs); //containsKey  
                            if (guidToAttributesMap.containsKey(specs.guid)) {
                                Map < String, String > tempMap = guidToAttributesMap.get(specs.guid);
                                tempMap.putAll(existingAdditionalAttrs);
                                guidToAttributesMap.put(specs.guid, tempMap);
                            } else {
                                guidToAttributesMap.put(specs.guid, existingAdditionalAttrs);
                            }
                            additionalAttrs.putAll(dateAdditionalAttrs);
                            //csedm.API_1.addCharacteristic(serviceMap.get(srvcNumber).Id, specs.guid,additionalAttrs);  
                            String bodyexistingAttr = ServiceSpecificationUtils.addAdditionalAttributeNoSOQL(serviceAttachmentMap.get(specs.serviceId), specs.guid, guidToAttributesMap.get(specs.guid));
                            String bodyAdditionalAttr = ServiceSpecificationUtils.addAdditionalAttributeNoSOQL(bodyexistingAttr, specs.guid, additionalAttrs);
                            Attachment attAdd = servAttachmentRecordMap.get(specs.serviceId);
                            attAdd.body = Blob.valueOf(bodyAdditionalAttr);
                            //update att;  
                            serviceAttachmentMap.put(attAdd.parentId, attAdd.Body.toString());
                            updatedAttSet.put(attAdd.id, attAdd);
                            csord__Service__c ser = serviceMap.get(srvcNum);
                            if (srvDateMap.get(serviceMap.get(srvcNum).id) != null && srvDateMap.get(serviceMap.get(srvcNum).id).get('currentForecastedDeliveryDate') != null) { //added as part of EDGE-165183  
                                if (serviceMap.get(srvcNum).Forecasted_Delivery_Date__c == NULL || serviceMap.get(srvcNum).Forecasted_Delivery_Date__c < srvDateMap.get(serviceMap.get(srvcNum).id).get('currentForecastedDeliveryDate')) {
                                    //ser.Forecasted_Delivery_Date__c = forecastedDate; //Commented as part of EDGE-165183  
                                    ser.Forecasted_Delivery_Date__c = srvDateMap.get(serviceMap.get(srvcNum).id).get('currentForecastedDeliveryDate');
                                }
                            }
                            if (srvDateMap.get(serviceMap.get(srvcNum).id) != null && srvDateMap.get(serviceMap.get(srvcNum).id).get('telstraCommittedDate') != null) { //added as part of EDGE-165183  
                                if (serviceMap.get(srvcNum).Telstra_Committed_Date__c == NULL || serviceMap.get(srvcNum).Telstra_Committed_Date__c < srvDateMap.get(serviceMap.get(srvcNum).id).get('telstraCommittedDate')) {
                                    //ser.Telstra_Committed_Date__c = committedDate; //Commented as part of EDGE-165183  
                                    ser.Telstra_Committed_Date__c = srvDateMap.get(serviceMap.get(srvcNum).id).get('telstraCommittedDate');
                                }
                            }
                            // EDGE-193568 start  
                            if (srvDateMap.get(serviceMap.get(srvcNum).id) != null && srvDateMap.get(serviceMap.get(srvcNum).id).get('productCancellationDate') != null) {
                                ser.cancellationDate__c = srvDateMap.get(serviceMap.get(srvcNum).id).get('productCancellationDate');
                            } // EDGE-193568 end  
                            //EDGE : 99309 ::Added  
                            if (String.isNotBlank(tenancyId)) {
                                ser.Tenancy_Id__c = tenancyId;
                            }
                            //srvcListtoUpdate.put(ser.Id,ser);  
                            srvcListtoUpdate.put(specs.serviceId, serviceMapWithId.get(specs.serviceId));
                            System.debug('specToUpdatedStatusMap::' + specToUpdatedStatusMap);
                            System.debug('specToUpdatedStatusMapValue::' + specToUpdatedStatusMap.get(specs.guid));
                            System.debug('Values++++++' + specs.serviceId + '___' + specs.guid);
                            // specToUpdatedStatusMap.remove(specs.guid);  
                        }
                    }
                }
                if (noti.eventType == 'PONR' || noti.eventType == 'OrderNotification') { //added as part of EDGE-170550  
                    for (ManageOrderNotificationUtil.NotificationAttributes attr: notifAttrs.attributes) {
                        if (attr.name.contains('status') && attr.value == 'Accepted') {
                            acceptedOrdermap.put(oId, attr.Value);
                        }
                        if (attr.name.contains('rejectionReason') && !String.isBlank(attr.Value)) {
                            rejectionReasonmap.put(oId, attr.Value);
                        }
                        //}  
                        if (attr.name.contains('amendNotAllowed') && !String.isBlank(attr.Value)) {
                            amendnotAllowedMap.put(srvcNum, Boolean.valueOf(attr.Value));
                        }
                        if (attr.name.contains('cancelNotAllowed') && !String.isBlank(attr.Value)) {
                            cancelnotAllowedMap.put(srvcNum, Boolean.valueOf(attr.Value));
                        }
                    }
                    getParticipatingServices(srvcList);
                } // EDGE-170550 - End  
            }
            srvspList = new List < CS_SpecificationDTO.ServiceSpecification > (); //added as part of EDGE-165183  
            for (String eachService: serviceAttachmentMap.keySet()) {
                srvspList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)), FULFILMENT));
            }
            serviceSpecMap = new Map < String, CS_SpecificationDTO.ServiceSpecification > ();
            serviceSpecMap = getallOrderSpecs(srvspList);
            //srvcListtoUpdate.put(serviceMap.get(srvcNumber).Id, serviceMap.get(srvcNumber));  
            Map < Id, csord__Service__c > serList = new Map < Id, csord__Service__c > ();
            //if there are any remaining updates fetch it from the order and update it  
            if (!specToUpdatedStatusMap.isEmpty()) {
                //Id ordId = serviceMap.get(srvcNumber).csord__Order__r.csordtelcoa__Opportunity__c;  
                // System.debug('orderReq:::'+ordId);  
                Map < String, CS_SpecificationDTO.ServiceSpecification > allspecMap = serviceSpecMap;
                System.debug('specToUpdatedStatusMap::' + specToUpdatedStatusMap);
                System.debug('allspecMap::' + allspecMap);
                Set < Id > serIds = new Set < Id > ();
                for (String guid: specToUpdatedStatusMap.keySet()) {
                    System.debug('guid::' + guid);
                    CS_SpecificationDTO.ServiceSpecification specs = allspecMap.get(guid);
                    currentSpecStatus = specs.status;
                    if (currentSpecStatus.contains('Disconnect') && specToUpdatedStatusMap.get(specs.guid).contains(Label.Complete)) {
                        specToUpdatedStatusMap.put(specs.guid, Label.MO_status_disconnected);
                    } else if (currentSpecStatus.contains('Disconnect') && specToUpdatedStatusMap.get(specs.guid).contains('In Progress')) {
                        specToUpdatedStatusMap.put(specs.guid, Label.MO_status_disconnect_in_progress);
                    } //EDGE-175697  
                    String udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
                    Attachment att = servAttachmentRecordMap.get(specs.serviceId);

                    serviceAttachmentMap.put(att.parentId, udtattbody);
                    additionalAttrs.clear();
                    existingAdditionalAttrs.clear();
                    //guidTOexistingAdditionalAttrs.clear();  
                    for (CS_SpecificationDTO.SimpleAttributes simpleAttr: specs.additionalAttributes) {
                        existingAdditionalAttrs.put(simpleAttr.name, simpleAttr.value);
                        /*existingAdditionalAttrs.remove('currentForecastedDeliveryDate'); //commented as part of EDGE-165183  
existingAdditionalAttrs.remove('telstraCommittedDate');*/
                    }
                    //additionalAttrs.putAll(existingAdditionalAttrs);  
                    guidToAttributesMap.put(specs.guid, existingAdditionalAttrs);

                    String attach = csedm.API_1.addCharacteristic(serviceAttachmentMap.get(specs.serviceId), specs.serviceId, specs.guid, guidToAttributesMap.get(specs.guid));
                    // Attachment att = servAttachmentRecordMap.get(specs.serviceId);  
                    serIds.add(specs.serviceId);
                    //String newattbody = csedm.API_1.addCharacteristic(udtattbody,guidToservMap.get(specs.guid),specs.guid, guidToAttributesMap.get(specs.guid));  
                    att.body = Blob.valueOf(attach);
                    serviceAttachmentMap.put(att.parentId, att.Body.toString());
                    updatedAttSet.put(att.id, att);
                    //Added - End  
                    specToUpdatedStatusMap.remove(specs.guid);
                }
                //EDGE : 99309 ::Modified  
                //DPG 4545- cscfga__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c  
                List < csord__Service__c > serviceList = [SELECT Id, Name, csord__Status__c, csord__Order__c, csord__Order__r.csord__Status2__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, CreatedDate, Forecasted_Delivery_Date__c, Telstra_Committed_Date__c, csord__Subscription__c, Tenancy_Id__c, csord__Subscription__r.Suspension_reason__c, csord__Service__c, csord__Subscription__r.csord__Status__c, csord__Order__r.Name, csord__Order__r.csord__Order_Number__c, csord__Order__r.rejectionReason__c, toBeCancelled__c, csord__Activation_Date__c, csord__Deactivation_Date__c, csord__Service__r.id, Deactivation_Date__c, Initial_Activation_DateTime__c, csord__Subscription__r.MarketableOffer__c, csord__Subscription__r.MarketableOffer__r.Offer_ID__c, csordtelcoa__Cancelled_By_Change_Process__c, csord__Subscription__r.csordtelcoa__Cancelled_By_Change_Process__c, Scenario_Type__c, csord__Subscription__r.Suspension_reason_summary__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c from csord__Service__c where Id IN: serIds FOR UPDATE];

                //EDGE-177027 : Added csord__Subscription__r.MarketableOffer__c, csord__Subscription__r.MarketableOffer__r.Offer_ID__c  
                //csord__Deactivation_Date__c added as part of EDGE-164354 // Initial_Activation_DateTime__c , Deactivation_Date__c added part of EDGE-174924  
                //EDGE-202433 added Scenario_Type__c in query  
                for (csord__Service__c srv: serviceList) {
                    if (srv.csord__Service__r.id == null && srvDateMap.get(srv.id) != null && srvDateMap.get(srv.id).get('currentForecastedDeliveryDate') != null) { //added as part of EDGE-165183  
                        if (srv.Forecasted_Delivery_Date__c < srvDateMap.get(srv.id).get('currentForecastedDeliveryDate') || srv.Forecasted_Delivery_Date__c == NULL) {
                            srv.Forecasted_Delivery_Date__c = srvDateMap.get(srv.id).get('currentForecastedDeliveryDate');
                        }
                    }
                    if (srv.csord__Service__r.id == null && srvDateMap.get(srv.id) != null && srvDateMap.get(srv.id).get('telstraCommittedDate') != null) { //added as part of EDGE-165183  
                        if (srv.Telstra_Committed_Date__c < srvDateMap.get(srv.id).get('telstraCommittedDate') || srv.Telstra_Committed_Date__c == NULL) {
                            srv.Telstra_Committed_Date__c = srvDateMap.get(srv.id).get('telstraCommittedDate');
                        }
                    }
                    if (srv.csord__Service__r.id != null && srvDateMap.get(srv.csord__Service__r.id) != null && srvDateMap.get(srv.csord__Service__r.id).get('currentForecastedDeliveryDate') != null) { //added as part of EDGE-165183  
                        if (srv.Forecasted_Delivery_Date__c < srvDateMap.get(srv.csord__Service__r.id).get('currentForecastedDeliveryDate') || srv.Forecasted_Delivery_Date__c == NULL) {
                            srv.Forecasted_Delivery_Date__c = srvDateMap.get(srv.csord__Service__r.id).get('currentForecastedDeliveryDate');
                        }
                    }
                    if (srv.csord__Service__r.id != null && srvDateMap.get(srv.csord__Service__r.id) != null && srvDateMap.get(srv.csord__Service__r.id).get('telstraCommittedDate') != null) { //added as part of EDGE-165183  
                        if (srv.Telstra_Committed_Date__c < srvDateMap.get(srv.csord__Service__r.id).get('telstraCommittedDate') || srv.Telstra_Committed_Date__c == NULL) {
                            srv.Telstra_Committed_Date__c = srvDateMap.get(srv.csord__Service__r.id).get('telstraCommittedDate');
                        }
                    }
                    if (String.isNotBlank(tenancyId)) //EDGE : 99309 ::Added  
                    {
                        srv.Tenancy_Id__c = tenancyId;
                    }
                    serList.put(srv.Id, srv);
                    //EDGE-202433 adding starts  
                    if (serviceNotifstatus.get(srv.csordtelcoa__Service_Number__c).containsIgnoreCase('Complete') && serviceNotifstatus.get(srv.csordtelcoa__Service_Number__c) != null && srv.Scenario_Type__c != null && srv.Scenario_Type__c.equalsIgnoreCase('No Fault Return')) {
                        List < Id > serviceIdList = new List < Id > ();
                        serviceIdList.add(srv.Id);
                        AssetUpsertionHelper.updateAssetToReturned(serviceIdList);
                    }
                    //EDGE-202433 adding ends  
                }
            }
            if (!srvcUpdate.isEmpty()) {
                update srvcUpdate.values();
            }
            // if(!updatedAttSet.isEmpty()){update updatedAttSet.values();} //EDGE-170552  
            //for every service update status  
            String subStageStatus = NULL;
            List < csord__Subscription__c > subs = new List < csord__Subscription__c > ();
            Map < Id, csord__Subscription__c > subMap = new Map < Id, csord__Subscription__c > ();
            Map < Id, csord__Order__c > ordMap = new Map < Id, csord__Order__c > ();
            List < CS_SpecificationDTO.ServiceSpecification > updatedSrvSpecList = new List < CS_SpecificationDTO.ServiceSpecification > ();
            for (String eachService: serviceAttachmentMap.keySet()) {
                updatedSrvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)), FULFILMENT));
            }
            Map < Id, String > srvsubStageStatusMap = new Map < Id, String > ();
            Map < Id, csord__Service__c > srvcListtoUp = new Map < Id, csord__Service__c > ();
            for (csord__Service__c svc: serList.values()) {
                String status = calculateServiceStatus(svc.Id, updatedSrvSpecList);
                string planOfferId = 'DMCAT_Offer_001233';
                string cmpOfferId = 'DMCAT_Offer_000646';
                string cmpDeviceSpec = 'DMCAT_ProductSpecification_000423';
                if (!String.isEmpty(status)) { //commented as part of EDGE-168304  
                    system.debug('serviceNotifstatus==' + serviceNotifstatus);
                    if (serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c) != null && status.containsIgnoreCase('Suspended')) //EDGE-91568 - Update parent service status as Suspended if status contains Suspended value  
                    { //updated if as part of EDGE-168304  
                        System.debug('inside suspend');
                        system.debug('status==>' + status);
                        if (serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c).containsIgnoreCase('In Progress')) {
                            if (svc.csord__Service__c == null) {
                                svc.csord__Status__c = 'In Progress';
                                //DPG-4545 - Fix- DPG-5282 -start  
                                if (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == planOfferId || (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == cmpOfferId && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != cmpDeviceSpec)) {
                                    svc.csord__Status__c = 'Suspend In Progress';
                                }
                                //DPG-4545 - Fix- DPG-5282 -end  
                                svc.csord__Subscription__r.csord__Status__c = 'Provisioning In Progress';
                                svc.csord__Order__r.csord__Status2__c = 'In Progress'; //update subscription status as Suspended in Suspend Scenario  
                            } else {
                                svc.csord__Status__c = 'Connected';
                                //DPG-4545 - Fix- DPG-5282 -start  
                                if (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == planOfferId || (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == cmpOfferId && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != cmpDeviceSpec)) {
                                    svc.csord__Status__c = 'Suspend In Progress';
                                }
                                //DPG-4545 - Fix- DPG-5282 -end  
                                svc.csord__Subscription__r.csord__Status__c = 'Provisioning In Progress';
                                svc.csord__Order__r.csord__Status2__c = 'In Progress'; //update subscription status as Suspended in Suspend Scenario  
                            }
                        } else if (serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c).containsIgnoreCase('Complete')) {
                            if (svc.csord__Service__c == null) {
                                svc.csord__Status__c = status;
                                //DPG-4545 - Fix- DPG-5282 -start  
                                if (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == planOfferId || (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == cmpOfferId && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != cmpDeviceSpec)) {
                                    svc.csord__Status__c = 'Suspended';
                                }
                                //DPG-4545 - Fix- DPG-5282 -end  
                                svc.csord__Subscription__r.csord__Status__c = 'Suspended';
                                svc.csord__Order__r.csord__Status2__c = 'Completed';
                                svc.csord__Order__r.csord__End_Date__c = Date.today(); //update subscription status as Suspended in Suspend Scenario  
                            } else {
                                svc.csord__Status__c = 'Connected';
                                //DPG-4545 - Fix- DPG-5282 -start  
                                if (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == planOfferId || (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == cmpOfferId && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != cmpDeviceSpec)) {
                                    svc.csord__Status__c = 'Suspended';
                                }
                                //DPG-4545 - Fix- DPG-5282 -end  
                                svc.csord__Subscription__r.csord__Status__c = 'Suspended';
                                svc.csord__Order__r.csord__Status2__c = 'Completed'; //update subscription status as Suspended in Suspend Scenario  
                            }
                        }
                    } else if (serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c) != null && svc.csord__Order__r.Name.containsIgnoreCase('Resume')) { //updated if as part of EDGE-168304  
                        System.debug('inside Resume =' + serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c));
                        system.debug('status==' + status);
                        if (serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c).containsIgnoreCase('In Progress')) {
                            System.debug('inside Resume in progress');
                            svc.csord__Status__c = status;
                            //DPG-4545 - Fix- DPG-5282 -start  
                            system.debug('svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c===' + svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c);
                            if (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == planOfferId || (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == cmpOfferId && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != cmpDeviceSpec)) {
                                svc.csord__Status__c = system.label.srvSpec_resumeInProgress_Status;
                            } //system.label.srvSpec_resumeInProgress_Status ;  
                            //DPG-4545 - Fix- DPG-5282 -end  
                            svc.csord__Subscription__r.csord__Status__c = 'Provisioning In Progress';
                            svc.csord__Order__r.csord__Status2__c = 'In Progress';
                        } else if (serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c).containsIgnoreCase('Complete')) {
                            svc.csord__Subscription__r.csord__Status__c = 'Active';
                            svc.csord__Status__c = status;
                            //DPG-4545 -Fix DPG-5879- start
                            if (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == planOfferId || svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == cmpOfferId) {
                                if (svc.csord__Subscription__r.Suspension_reason_summary__c != '' && svc.csord__Subscription__r.Suspension_reason_summary__c != null) {
                                    svc.csord__Subscription__r.csord__Status__c = 'Suspended';
                                }
                            }
                            //DPG-4545 -Fix DPG-5879- end
                            //DPG-4545 - Fix- DPG-5282 -start  
                            if (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == planOfferId || (svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c == cmpOfferId && svc.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != cmpDeviceSpec)) {
                                if (svc.csord__Subscription__r.Suspension_reason_summary__c == '' || svc.csord__Subscription__r.Suspension_reason_summary__c == null) {
                                    svc.csord__Status__c = 'Connected';
                                } else {
                                    svc.csord__Subscription__r.csord__Status__c = 'Suspended';
                                    svc.csord__Status__c = 'Suspended';
                                }
                            }
                            //DPG-4545 - Fix- DPG-5282 -end  
                            svc.csord__Order__r.csord__Status2__c = 'Completed';
                            svc.csord__Order__r.csord__End_Date__c = Date.today();
                        }
                    } else if (svc.toBeCancelled__c == 'true' && serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c) != null) { //EDGE-165687  
                        if ((serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c)).containsIgnoreCase('In Progress')) {
                            svc.csord__Status__c = Label.MO_status_disconnect_in_progress;
                        } else if ((serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c)).containsIgnoreCase('Complete')) {
                            svc.csord__Status__c = Label.MO_status_disconnected;
                        }
                    }
                    //EDGE-177027 : Start  
                    else if (serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c) != null && serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c).containsIgnoreCase('Complete') && svc.csord__Subscription__r.MarketableOffer__c != null && svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c != null && System.label.SvcSubsStatusClosed.contains(svc.csord__Subscription__r.MarketableOffer__r.Offer_ID__c)) {
                        svc.csord__Status__c = 'Closed';
                    } //EDGE-177027 : End  
                    //EDGE-193568 start  
                    else if (serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c) != null && serviceNotifstatus.get(svc.csordtelcoa__Service_Number__c).containsIgnoreCase('Cancelled')) {
                        svc.csord__Status__c = Label.Cancelled;
                        svc.csord__Subscription__r.csord__Status__c = Label.Cancelled;
                    }
                    //EDGE-193568 end  
                    else {
                        svc.csord__Status__c = status;
                    }
                    // subStageStatus = status;  
                    if (status != null && status.containsIgnoreCase('Connected')) {
                        srvsubStageStatusMap.put(svc.id, status);
                    }
                    //  subscriptionId = svc.csord__Subscription__c;  
                    if (status.containsIgnoreCase('Disconnected')) {
                        svc.substage__c = 'Complete';
                        svc.stage__c = 'Closed';
                    } else if (status.containsIgnoreCase('Connected')) {
                        svc.substage__c = 'Product Completion Notice';
                        svc.stage__c = 'Closed';
                    }
                    if (servIDtoActivationDateMap.get(svc.id) != null) //added as part of EDGE-154104  
                    {
                        svc.csord__Activation_Date__c = servIDtoActivationDateMap.get(svc.id).Date(); // Modified as part of EDGE-174924  
                        svc.Initial_Activation_DateTime__c = servIDtoActivationDateMap.get(svc.id); // Added as part of EDGE-174924  
                        svc.Completion_Date__c = servIDtoActivationDateMap.get(svc.id); // Added as part of EDGE-174924  
                    } else if (servIDtoDeactivationDateMap.get(svc.id) != null) { //EDGE-164354  
                        svc.csord__Deactivation_Date__c = servIDtoDeactivationDateMap.get(svc.id).Date(); // Modified as part of EDGE-174924  
                        svc.Deactivation_Date__c = servIDtoDeactivationDateMap.get(svc.id); // Added as part of EDGE-174924  
                        svc.Completion_Date__c = servIDtoDeactivationDateMap.get(svc.id); // Added as part of EDGE-174924  
                    }
                    srvcListtoUp.put(svc.id, svc);
                    subs.add(svc.csord__Subscription__r);
                    subMap.put(svc.csord__Subscription__c, svc.csord__Subscription__r);
                    System.debug('subMap:::1' + subMap);
                    ordMap.put(svc.csord__Order__c, svc.csord__Order__r);
                    System.debug('ordMap:::1' + ordMap);
                }
            }

            system.debug('acceptedOrderMap1512' + acceptedOrderMap);
            system.debug('orderIdtoOrdMap1512' + orderIdtoOrdMap);
            for (String ordnum: orderIdtoOrdMap.keySet()) { //added as part of EDGE-170552  
                boolean isAccepted = false;
                boolean isRejected = false;
                csord__Order__c orderToUpdate = orderIdtoOrdMap.get(ordnum);
                if (acceptedOrderMap.containsKey(ordnum)) {
                    isAccepted = true;
                    orderToUpdate.csord__Status2__c = 'In Progress';
                } else if (rejectionReasonmap.containsKey(ordnum)) {
                    isRejected = true;
                    orderToUpdate.csord__Status2__c = 'Amend Rejected';
                    orderToUpdate.rejectionReason__c = rejectionReasonmap.get(ordnum);
                }
                if (isAccepted == true || isRejected == true) {
                    ordMap.put(orderToUpdate.id, orderToUpdate);
                }
            }
            system.debug('serviceMap1535' + serviceMap);
            for (String servnum: serviceMap.keyset()) //added as part of EDGE-170550  
            {
                boolean amendNotAllowed = false;
                boolean cancelNotAllowed = false;
                boolean isParticipating = false;
                // if(serviceMap.containsKey(servnum)){  
                csord__Service__c serv;
                if (srvcListtoUp.containsKey(serviceMap.get(servnum).Id)) {
                    serv = srvcListtoUp.get(serviceMap.get(servnum).Id);
                } else {
                    serv = serviceMap.get(servnum);
                }
                system.debug('serv' + serv);
                if (amendnotAllowedMap.containsKey(serv.csordtelcoa__Service_Number__c)) {
                    serv.csordtelcoa__Point_of_No_Return_Reached__c = amendnotAllowedMap.get(serv.csordtelcoa__Service_Number__c);
                    serv.csord__Subscription__r.Point_of_No_Return_Reached__c = amendnotAllowedMap.get(serv.csordtelcoa__Service_Number__c); //added as part of EDGE-191827  
                    amendNotAllowed = true;
                }
                if (cancelnotAllowedMap.containsKey(serv.csordtelcoa__Service_Number__c)) {
                    serv.cancel_Point_of_No_Return_Reached__c = cancelnotAllowedMap.get(serv.csordtelcoa__Service_Number__c);
                    serv.csord__Subscription__r.cancel_Point_of_No_Return_Reached__c = cancelnotAllowedMap.get(serv.csordtelcoa__Service_Number__c); //added as part of EDGE-191827  
                    cancelNotAllowed = true;
                }
                system.debug('partservmap' + partservmap);
                if (partservmap.containsKey(servnum)) //EDGE-170552  
                {
                    isParticipating = true;
                    //List<CS_SpecificationDTO.ServiceSpecification> specList = mapSerIDSpecList.get(serv.id);  
                    if (acceptedOrderMap.containsKey(serv.csord__Order__r.csord__Order_Number__c)) { //EDGE-215635 : Once Canelled notification recieved, not changing status of svc on any other notification  
                        if (!serv.csord__Status__c.equalsIgnoreCase('Cancelled')) {
                            if (serv.csordtelcoa__Cancelled_By_Change_Process__c == true) //for Service  
                            {
                                serv.csord__Status__c = 'Cancellation In Progress';
                            } else {
                                serv.csord__Status__c = 'In Progress';
                            }
                            if (mapSerIDSpecList.containsKey(serv.id)) {
                                for (CS_SpecificationDTO.ServiceSpecification servspec: mapSerIDSpecList.get(serv.id)) {
                                    String attachBody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(servspec.serviceId)), servspec.guid, 'status', serv.csord__Status__c);
                                    Attachment att = servAttachmentRecordMap.get(servspec.serviceId);
                                    att.body = Blob.valueOf(attachBody);
                                    serviceAttachmentMap.put(att.parentId, att.Body.toString());
                                    updatedAttSet.put(att.id, att);
                                }
                            }
                            if (serv.csord__Subscription__r.csordtelcoa__Cancelled_By_Change_Process__c == true) //for subscription  
                            {
                                serv.csord__Subscription__r.csord__Status__c = 'Cancellation In Progress';
                            } else {
                                serv.csord__Subscription__r.csord__Status__c = 'Provisioning In Progress';
                            }
                        }
                    } else if (rejectionReasonmap.containsKey(serv.csord__Order__r.csord__Order_Number__c)) {
                        if (serv.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c == null) {
                            serv.csord__Subscription__r.csord__Status__c = 'Amend Rejected';
                            serv.csord__Status__c = 'Amend Rejected';
                            if (mapSerIDSpecList.containsKey(serv.id)) {
                                for (CS_SpecificationDTO.ServiceSpecification servspec: mapSerIDSpecList.get(serv.id)) {
                                    String attachBody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(servspec.serviceId)), servspec.guid, 'status', 'Amend Rejected');
                                    Attachment att = servAttachmentRecordMap.get(servspec.serviceId);
                                    att.body = Blob.valueOf(attachBody);
                                    serviceAttachmentMap.put(att.parentId, att.Body.toString());
                                    updatedAttSet.put(att.id, att);
                                }
                            }
                        } else {
                            serv.csord__Subscription__r.csord__Status__c = ' Amend Rejected';
                        }
                    }
                }
                if (amendNotAllowed == true || cancelNotAllowed == true || isParticipating == true) {
                    srvcListtoUp.put(serv.id, serv);
                    subMap.put(serv.csord__Subscription__c, serv.csord__Subscription__r); //added as part of EDGE-191827  
                }
                //}  
            }
            if (!srvcListtoUp.isEmpty()) {
                update srvcListtoUp.values();
            }
            if (!subMap.isEmpty()) {
                update subMap.values();
            }
            if (orderToSubMap != null) {
                updateOrderRecordMS(orderToSubMap); //updated the method call EDGE-210579  
            }
            if (!ordMap.isEmpty()) {
                update ordMap.values();
            }
            /*if(orderToSubMap != null){  
updateOrderRecordMS(orderToSubMap);//added the method call EDGE-191827 // commented method call for EDGE-210579  
}*/
            if (!updatedAttSet.isEmpty()) {
                update updatedAttSet.values();
            }
            List < Id > subIdList = new List < Id > ();
            List < Id > ordidList = new List < Id > ();
            for (csord__Service__c ser: [SELECT Id, Name, csord__Order__c, csord__Subscription__c FROM csord__Service__c WHERE Id IN: srvsubStageStatusMap.keyset()]) {
                subIdList.add(ser.csord__Subscription__c);
                ordidList.add(ser.csord__Order__c);
            }

            // notif.Status__c = 'Completed';  
            InvokeInventoryPublishEvents.publishServiceSpecificationHandlerMSUpdate(servguidMap);
            // EDGE-113552  
            Map < Id, String > ordStatusMap = new Map < Id, String > ();
            for (id ordr: orderIdList) {
                ordStatusMap.put(ordr, 'Success');
            }
            // if(!isSuspendResume)  
            //{  
            ManageOrderAcknowledgeHandler.processAcknowledgementsMSUpdate(orderList, ordStatusMap, ordIdisSuspendResume);
            //}  
            if (!String.isBlank(toLog)) {
                Logger2 log = Logger2.getLogger('UpdateServices');
                log.logMessages(JSON.serialize(toLog, true), '', '', '', '', '', false, false, 200, '', '', '');
                log.exitLogger();
            }
        } catch (Exception e) {
            logException('updateServiceRecordMS', '', correlationId, e.getMessage() + '-' + e.getStackTraceString(), 'Update service records with notifications from MS');
            if (!Test.isRunningTest() && enableThrowException) {
                throw e;
            } //EDGE-215225  
        }
    }


    public static Map < String, boolean > checkUCCompletionAndUpdateNumber(List < NotificationParameters > paramsList) {
        Map < String, boolean > servCheckMap = new Map < String, boolean > ();

        try {
            List < String > srvcNumberList = new List < String > ();
            Map < String, String > notiftoServNumMap = new Map < String, String > (); //added as part of EDGE-160243 - Start
            Map < String, List < csord__Service__c >> servNumtoServMap = new Map < String, List < csord__Service__c >> ();
            List < csord__Service__c > allServList = new List < csord__Service__c > ();
            List < csord__Service__c > childServList = new List < csord__Service__c > (); //EDGE-160243 - End
            Map < String, List < String >> ordIdTosrvcNumberList = new Map < String, List < String >> (); // Added as part of EDGE-174174
            for (NotificationParameters notif: paramsList) {
                String orderId = null;
                String srvcNumber = null;
                String instanceId = null;
                Boolean stopprocessing = false;
                List < String > keyparams = notif.orderItemId.split('\\|');
                if (keyparams.size() > 0) {
                    orderId = keyparams[0];
                }
                if (keyparams.size() > 1) {
                    srvcNumber = keyparams[1];
                }
                if (keyparams.size() > 2) {
                    instanceId = keyparams[2];
                }
                if (srvcNumber == null || orderId == null || instanceId == null) {
                    stopprocessing = true;
                }
                // Added as part of EDGE-174174- Start
                if (ordIdTosrvcNumberList.containsKey(orderId)) {
                    ordIdTosrvcNumberList.get(orderId).add(srvcNumber);
                } else {
                    ordIdTosrvcNumberList.put(orderId, new List < String > {
                        srvcNumber
                    });
                }

                // Added as part of EDGE-174174- End
                srvcNumberList.add(srvcNumber);

            }
            // Added as part of EDGE-174174- End
            List < String > listOfSrvNum = new List < String > ();
            for (String ordNum: ordIdTosrvcNumberList.keyset()) {
                listOfSrvNum.addAll(ordIdTosrvcNumberList.get(ordNum));
            }
            // Added as part of EDGE-174174- End
            //updated soql as part of EDGE-160243
            List < csord__Service__c > serviceList = [SELECT Id, Name, csord__Status__c, csord__Subscription__c, csord__Subscription__r.csordtelcoa__Subscription_Number__c, csord__Order__c, csord__Order__r.csord__Order_Number__c, csord__Order__r.id, csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c, Forecasted_Delivery_Date__c, csordtelcoa__Product_Configuration__c, CreatedDate, toBeCancelled__c,
                (Select Id, Name, GUID__c, Service__c FROM Service_Specifications__r),
                (Select id, Name, csord__Status__c, csord__Subscription__c, csord__Order__c, toBeCancelled__c, csord__Order__r.id, csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c, Forecasted_Delivery_Date__c, NetworkserviceId__c from csord__Services__r)
                FROM csord__Service__c
                WHERE csordtelcoa__Service_Number__c IN: listOfSrvNum and csord__Order__r.csord__Order_Number__c IN: ordIdTosrvcNumberList.keySet() order by CreatedDate desc
            ]; // Modified as part of EDGE-174174

            List < Id > allserviceId = new List < Id > ();
            for (csord__Service__c service: serviceList) {
                allserviceId.add(service.id);
                for (csord__Service__c childServ: service.csord__Services__r) //added as part of EDGE-160243 - Start
                {
                    childServList.add(childServ);
                }
                allServList.add(service);
                allServList.addAll(childServList);
                servNumtoServMap.put(service.csordtelcoa__Service_Number__c, allServList); //EDGE-160243 - End

            }
            //EDGE-81250 start
            serviceList = (List < csord__Service__c > ) CustomSortUtility.customSort(serviceList, 'createddate', 'DateTime'); //list in ascending order
            //end EDGE-81250
            List < NotificationParameters > notifList = new List < NotificationParameters > ();
            String status;
            String ordId;
            String serviceNumber;
            String instanceId;
            Map < String, String > notifGuidMap = new Map < String, String > ();
            Map < String, String > servStatus = new Map < String, String > ();

            for (NotificationParameters notif: notifList) {
                ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes('{' + String.valueOf(notif.notificationAttributes) + '}');
                for (ManageOrderNotificationUtil.NotificationAttributes attr: notifyAttrs.attributes) {
                    if (attr.name.contains('status')) {
                        status = attr.value;
                    }
                }
                List < String > keyparams = notif.orderItemId.split('\\|');
                if (keyparams.size() > 0) {
                    ordId = keyparams[0];
                }
                if (keyparams.size() > 1) {
                    serviceNumber = keyparams[1];
                }
                if (keyparams.size() > 2) {
                    instanceId = keyparams[2];
                }
                notifGuidMap.put(notif.msCorrelationId, instanceId);
                notiftoServNumMap.put(notif.msCorrelationId, serviceNumber); //added as part of EDGE-160243
                servStatus.put(serviceNumber, status);
            }
            NumberNCSHelper ncs = new NumberNCSHelper();
            Map < Id, Attachment > serviceIdToSpecAttachMap = new Map < Id, Attachment > ();
            List < CS_SpecificationDTO.ServiceSpecification > srvspecList = new List < CS_SpecificationDTO.ServiceSpecification > ();

            Map < Id, Attachment > attmAP = new Map < Id, Attachment > ([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: allserviceId and name = 'ServiceSpecifications.json']);

            for (Attachment tempAttachment: attmAP.values()) {
                serviceIdToSpecAttachMap.put(tempAttachment.parentId, tempAttachment);
            }

            //Lists to collect Subscription Numbers to update - Bulkify (Gnana)
            List < Number__c > listOfProvisionedSubscriptionNumbers = new List < Number__c > ();
            List < String > listOfProvisionedServiceSpecId = new List < String > ();
            List < Number__c > listOfDisconnectedSubscriptionNumbers = new List < Number__c > ();
            List < String > listOfDisconnectedServiceSpecId = new List < String > ();
            List < Number__c > listOfProvisionInProgSubscriptionNumbers = new List < Number__c > ();
            List < String > listOfProvisionInProgServiceSpecId = new List < String > ();
            List < Number__c > listOfDisconnectInProgSubscriptionNumbers = new List < Number__c > ();
            List < String > listOfDisconnectInProgServiceSpecId = new List < String > ();
            Map < String, List < Number__c >> mapStatusSubNum = new Map < String, List < Number__c >> ();
            List < String > listOfAllSpecId = new List < String > ();
            Map < string, List < Number__c >> servNumberListMap = new Map < string, List < Number__c >> ();
            Map < Id, String > servIdtoPCMap = new Map < Id, String > (); //added as part of EDGE-160243 - Start
            Map < String, List < NumberNCSDTO.Configuration >> PCToNumberMap = new Map < String, List < NumberNCSDTO.Configuration >> ();
            List < NumberNCSDTO.Configuration > ncsNumberList = new List < NumberNCSDTO.Configuration > (); //EDGE-160243 - End
            //EDGE-154773 start 
            //  EDGE-158300 : added toBeCancelled__c field in soql
            //  EDGE-169970 : updated soql where condition


            List < Number__c > numList = [Select id, name, Service_Number__c, Service_Id__c, Status__c, Subscription_number__c, Product_ID__c, toBeCancelled__c From Number__c where Service_Id__c IN: srvcNumberList AND Status__c != 'Active'];
            if (numList != null && !numList.isEmpty()) {
                for (Number__c num: numList) {
                    List < Number__c > numberList = new List < Number__c > ();
                    if (!servNumberListMap.isEmpty() && servNumberListMap.get(num.Service_Id__c) != null) {

                        numberList = servNumberListMap.get(num.Service_Id__c);
                        numberList.add(num);

                    } else {
                        numberList.add(num);
                    }

                    servNumberListMap.put(num.Service_Id__c, numberList);
                }
            }


            for (String msCorrelationId: notifGuidMap.keySet()) {
                if (notiftoServNumMap != null && notiftoServNumMap.get(msCorrelationId) != null && servNumtoServMap != null && servNumtoServMap.get(notiftoServNumMap.get(msCorrelationId)) != null) { // added null check EDGE-180260
                    for (csord__Service__c srv: servNumtoServMap.get(notiftoServNumMap.get(msCorrelationId))) { //added as part of EDGE-160243

                        String attchStr;
                        List < Number__c > numbList = servNumberListMap.get(srv.csordtelcoa__Service_Number__c); ////EDGE-154773 
                        if (serviceIdToSpecAttachMap.get(srv.id) != null) {
                            attchStr = serviceIdToSpecAttachMap.get(srv.id).body.toString();
                        }
                        if (attchStr != null) {
                            for (CS_SpecificationDTO.ServiceSpecification srvSpec: CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(attchStr), FULFILMENT)) {

                                if (numbList != null && !numbList.isEmpty()) {
                                    for (Number__c num: numbList) { //EDGE-154773
//removed 871 spec code as part of DIGI-35474
                                        if ((notifGuidMap.get(msCorrelationId) == srvSpec.guid) && ((srvSpec.code == 'DMCAT_ProductSpecification_000322_Fulfilment') || (srvSpec.code == 'DMCAT_ProductSpecification_000312_Fulfilment') || (srvSpec.code == 'DMCAT_ProductSpecification_000263_Fulfilment') || (srvSpec.code == 'DMCAT_ProductSpecification_000420_Fulfilment') ||  (srvSpec.code == 'DMCAT_ProductSpecification_001196_Fulfilment')) && servStatus.get(srv.csordtelcoa__Service_Number__c) == 'Complete') //EDGE-173009
                                        {

                                            //ncs.updateNCSForStatus(srv.csordtelcoa__Product_Configuration__c); //commented as part of refactoring - EDGE-160243
                                            servIdtoPCMap.put(srv.id, srv.csordtelcoa__Product_Configuration__c); //added as part of EDGE-160243
                                            //checkStatus = true;



                                            if (num.toBeCancelled__c != true) {
                                                listOfProvisionedServiceSpecId.add(srvSpec.code.removeEnd('_Fulfilment'));
                                                listOfProvisionedSubscriptionNumbers.add(num);

                                                // Commented out below line to avoid soql inside for loop (Gnana)
                                                //NumberUtil.UpdateNumberStatus(srvSpec.code,srv.csord__Subscription__r.csordtelcoa__Subscription_Number__c,'Provisioned');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                                            } else {
                                                listOfDisconnectedServiceSpecId.add(srvSpec.code.removeEnd('_Fulfilment'));
                                                listOfDisconnectedSubscriptionNumbers.add(num);
                                                // Commented out below line to avoid soql inside for loop (Gnana)
                                                //NumberUtil.UpdateNumberStatus(srvSpec.code,srv.csord__Subscription__r.csordtelcoa__Subscription_Number__c,'Disconnected');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                                            }
                                            servCheckMap.put(srv.csordtelcoa__Service_Number__c, true);
                                            // return true;
                                            //removed 871 spec code as part of DIGI-35474
                                        } else if ((notifGuidMap.get(msCorrelationId) == srvSpec.guid) && ((srvSpec.code == 'DMCAT_ProductSpecification_000322_Fulfilment') || (srvSpec.code == 'DMCAT_ProductSpecification_000312_Fulfilment') || (srvSpec.code == 'DMCAT_ProductSpecification_000263_Fulfilment') || (srvSpec.code == 'DMCAT_ProductSpecification_000420_Fulfilment') || (srvSpec.code == 'DMCAT_ProductSpecification_001196_Fulfilment')) && status == 'In Progress') //EDGE-173009
                                        {

                                            if (num.toBeCancelled__c != true) {
                                                listOfProvisionInProgServiceSpecId.add(srvSpec.code.removeEnd('_Fulfilment'));
                                                listOfProvisionInProgSubscriptionNumbers.add(num);
                                                // Commented out below line to avoid soql inside for loop (Gnana)
                                                //NumberUtil.UpdateNumberStatus(srvSpec.code,srv.csord__Subscription__r.csordtelcoa__Subscription_Number__c,'Provisioning In Progress');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                                            } else {
                                                listOfDisconnectInProgServiceSpecId.add(srvSpec.code.removeEnd('_Fulfilment'));
                                                listOfDisconnectInProgSubscriptionNumbers.add(num);
                                                // Commented out below line to avoid soql inside for loop (Gnana)
                                                //NumberUtil.UpdateNumberStatus(srvSpec.code,srv.csord__Subscription__r.csordtelcoa__Subscription_Number__c,'Disconnect In Progress');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                                            }
                                        }
                                    }
                                }
                            }

                            servCheckMap.put(srv.csordtelcoa__Service_Number__c, false);
                        }
                    }
                }

            }


            if (!servIdtoPCMap.isEmpty()) { //added as part of EDGE-160243
                for (Attachment att: [select Id, Body, ParentId FROM Attachment WHERE ParentId IN: servIdtoPCMap.values() and Name like '%NumberManagement%']) {
                    if (att != null) {
                        String jsonStr = att.body.toString();

                        NumberNCSDTO ncsDTO = NumberNCSDTO.parse(jsonStr);

                        for (NumberNCSDTO.Configuration config: ncsDTO.configurations) {

                            if ((config.status == Label.NumberStatus_RESERVED || config.status == Label.NumberStatus_TRANSITION)) {
                                config.status = Label.NumberStatus_ACTIVE;
                            }

                            ncsNumberList.add(config);

                        }
                        PCToNumberMap.put(att.ParentId, ncsNumberList);

                    }
                }
                //system.debug('servIdtoPCMap.values()1549'+servIdtoPCMap.values());
                //system.debug('PCToNumberMap1550'+PCToNumberMap);
                if (!PCToNumberMap.isEmpty() && !servIdtoPCMap.isEmpty()) {
                    ncs.updateExistingNCSbulk(servIdtoPCMap.values(), 'NumberManagementv1', PCToNumberMap);
                }
            } //EDGE-160243 - End


            // Calling UpdateNumberStatusBulkified method for all Subscription Numbers - Start (Gnana)
            if(listOfProvisionedServiceSpecId != null && listOfProvisionedSubscriptionNumbers != null){  
                mapStatusSubNum.put('Provisioned',listOfProvisionedSubscriptionNumbers);listOfAllSpecId.addAll(listOfProvisionedServiceSpecId);  
                //NumberUtil.UpdateNumberStatusBulkified(listOfProvisionedServiceSpecId, listOfProvisionedSubscriptionNumbers, 'Provisioned');  
            }  
            if(listOfDisconnectedServiceSpecId != null && listOfDisconnectedSubscriptionNumbers != null){  
                mapStatusSubNum.put('Disconnected',listOfDisconnectedSubscriptionNumbers);listOfAllSpecId.addAll(listOfDisconnectedServiceSpecId);  
                //NumberUtil.UpdateNumberStatusBulkified(listOfDisconnectedServiceSpecId, listOfDisconnectedSubscriptionNumbers, 'Disconnected');  
            }  
            if(listOfProvisionInProgServiceSpecId != null && listOfProvisionInProgSubscriptionNumbers != null){  
                mapStatusSubNum.put('Provisioning In Progress',listOfProvisionInProgSubscriptionNumbers);listOfAllSpecId.addAll(listOfProvisionInProgServiceSpecId);  
                //NumberUtil.UpdateNumberStatusBulkified(listOfProvisionInProgServiceSpecId, listOfProvisionInProgSubscriptionNumbers, 'Provisioning In Progress');  
            }  
            if(listOfDisconnectInProgServiceSpecId != null  && listOfDisconnectInProgSubscriptionNumbers != null){  
                mapStatusSubNum.put('Disconnect In Progress',listOfDisconnectInProgSubscriptionNumbers); listOfAllSpecId.addAll(listOfDisconnectInProgServiceSpecId);  
                //NumberUtil.UpdateNumberStatusBulkified(listOfDisconnectInProgServiceSpecId, listOfDisconnectInProgSubscriptionNumbers, 'Disconnect In Progress');  
            } 

            NumberUtil.UpdateNumberStatusBulkified2(listOfAllSpecId, mapStatusSubNum);
            // Calling UpdateNumberStatusBulkified method for all Subscription Numbers - End (Gnana)

            //return false;
            return servCheckMap;
        } catch (Exception e) {
            logException('checkUCCompletionAndUpdateNumber', '', correlationId,  e.getMessage() + '-' + e.getStackTraceString(), 'Check UC Completion and update number');  
            return servCheckMap;  
        }

    }

    private static void specMapUpdateErrorStatus(Map < String, String > specToUpdatedStatusMap, Map < String, String > replacedSpecToUpdatedStatusMap, Map < String, CS_SpecificationDTO.ServiceSpecification > serviceSpecMap, Set < Id > serviceIds, Map < String, String > serviceAttachmentMap, Map < String, Attachment > servAttachmentRecordMap) {
        String currentSpecStatus;
        try {
            Map < Id, Attachment > updatedAttSet = new Map < Id, Attachment > ();
            for (String guid: specToUpdatedStatusMap.keySet()) {
                CS_SpecificationDTO.ServiceSpecification spec = serviceSpecMap.get(guid);
                if (spec != null) {
                    currentSpecStatus = spec.status;

                    if (currentSpecStatus.contains('Disconnect') && specToUpdatedStatusMap.get(spec.guid).contains(Label.Complete)) {
                        specToUpdatedStatusMap.put(spec.guid, Label.MO_status_disconnected);
                    } else {
                        String udtattbody = csedm.API_1.updateServiceSpecificationProperty(serviceAttachmentMap.get(spec.serviceId), spec.guid, 'status', specToUpdatedStatusMap.get(spec.guid));
                        Attachment att = servAttachmentRecordMap.get(spec.serviceId);

                        att.body = Blob.valueOf(udtattbody);
                        //update att;
                        serviceAttachmentMap.put(att.parentId, att.Body.toString());
                        updatedAttSet.put(att.id, att);
                    }

                    serviceIds.add(spec.serviceId);
                } else {
                    replacedSpecToUpdatedStatusMap.put(guid, specToUpdatedStatusMap.get(guid));
                }
            }


            if (!updatedAttSet.isEmpty()) {
                update updatedAttSet.values();
            }
        } catch (Exception e) {
            logException('specMapUpdateErrorStatus', '', correlationId,  e.getMessage() + '-' + e.getStackTraceString(), 'Spec map update');  
        }
    }

    @TestVisible
    private static Map < String, String > getChildProducts(ManageOrderNotificationUtil.Product prd) {
        Map < String, String > statuses = new Map < String, String > ();
        try {
            if (prd != null && prd.childProduct != null) {
                List < ManageOrderNotificationUtil.ChildProduct > childPrds = prd.childProduct;
                for (ManageOrderNotificationUtil.ChildProduct childp: childPrds) {
                    statuses.put(childp.productId, childp.status);
                }
            }
        } catch (Exception e) {
            System.debug('Exception:' + e.getTypeName() + ',' + e.getMessage() + ',' + e.getLineNumber());
        }
        return statuses;
    }
    //@TestVisible
    public static String calculateServiceStatus(String srvcId,List<CS_SpecificationDTO.ServiceSpecification> cfsAttrList){  
        system.debug('calculating  Service status ');  
        String status;  
        //List<CS_SpecificationDTO.ServiceSpecification> cfsAttrList = new List<CS_SpecificationDTO.ServiceSpecification>();  
        //cfsAttrList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(srvcId),FULFILMENT);  
        Integer completeCount = 0;  
        Integer disconnectedCount = 0;  Integer cancelledCount = 0;  Integer failedCount = 0; Integer specSize = 0;  
        csord__Service__c serv = [SELECT Id, Name, csord__Status__c, csord__Order__c,csord__Order__r.Name , csord__Order_Request__c, csordtelcoa__Service_Number__c, CreatedDate,Forecasted_Delivery_Date__c,Telstra_Committed_Date__c,csord__Subscription__c, Tenancy_Id__c,csord__Subscription__r.Suspension_reason__c,csord__Subscription__r.Suspension_reason_summary__c,csord__Service__c,csordtelcoa__Cancelled_By_Change_Process__c,csord__Subscription__r.csordtelcoa__Cancelled_By_Change_Process__c  from csord__Service__c where Id=: srvcId];  
        //add query on subscription via service  
        try{  
            for(CS_SpecificationDTO.ServiceSpecification specs: cfsAttrList){  
                if(specs.serviceId == srvcId){  
                    specSize +=1;  
                    system.debug('specs.status==>'+specs.status);  
                    if(specs.status == Label.MO_Acknowledge_fail_status)         failedCount += 1;  
                    if(specs.status == Label.MO_status_error)         failedCount += 1;  
                    if(specs.status == Label.MO_status_in_progress)       status = Label.MO_status_in_progress;  
                    if(specs.status == Label.MO_status_cancel_in_progress)   status = Label.MO_status_cancel_in_progress;  
                    if(specs.status == Label.MO_status_disconnect_in_progress)       status = Label.MO_status_disconnect_in_progress;  
                    if(specs.status == Label.Complete)       completeCount += 1 ;  
                    if(specs.status == Label.MO_status_disconnected)     disconnectedCount += 1;  
                    if(specs.status == Label.MO_status_cancel)       cancelledCount += 1;  
                    //DPG-4545 - 5339  - Mahima  
                    if(specs.status == system.label.srvSpec_resumeInProgress_Status)  status = system.label.srvSpec_resumeInProgress_Status;
                    //DPG-4545 - DPG-5351  - Mahima
                    if(specs.status == system.label.subscription_Suspended_Status)  status = system.label.subscription_Suspended_Status;
                }  
            }  
            System.debug('Status::'+status);  
            System.debug('Total Specs:::'+specSize+'completeCount::'+completeCount+'cancelledCount:::'+cancelledCount+'disconnectedCount:::'+disconnectedCount+'failedCount::'+failedCount);  
            if(completeCount == specSize){status = Label.MO_Service_Status_Connected;}  
            //removed && serv.csord__Subscription__r.Suspension_reason__c.containsIgnoreCase('Requested by') - DPG-4545 fix.  
            if(serv.csord__Subscription__r.Suspension_reason__c!=null ){status = system.label.subscription_Suspended_Status;} //If suspension reason is populated on subscription then sending status as suspended  
            if(disconnectedCount == specSize) status = Label.MO_status_disconnected;  
            if(cancelledCount == specSize) status = Label.MO_status_cancel;  
            if(failedCount > 0) status = Label.MO_Acknowledge_fail_status;  
        }  
        catch(Exception e){  
            logException('calculateServiceStatus', '', correlationId, e.getTypeName() +','+e.getMessage() +','+  e.getLineNumber(), 'calculateServiceStatus');  
        }  
        return status;  
    } 

    public static Map < String, CS_SpecificationDTO.ServiceSpecification > getallOrderSpecs(List < CS_SpecificationDTO.ServiceSpecification > srvspecList) {
        Map < String, CS_SpecificationDTO.ServiceSpecification > srvSpecMap = new Map < String, CS_SpecificationDTO.ServiceSpecification > ();
        try {
            if (!srvspecList.isEmpty()) {
                for (CS_SpecificationDTO.ServiceSpecification serSpec: srvspecList) {
                    srvSpecMap.put(serSpec.guid, serSpec);
                }
            }

        } catch (Exception e) {
           logException('getallOrderSpecs', '', correlationId, e.getTypeName() +','+e.getMessage() +','+  e.getLineNumber(), 'getallOrderSpecs'); 
        }

        return srvSpecMap;
    }

    //added method as part of EDGE-124711/EDGE-124029
     public static void updateSchedulesonCallback(List<csord__Subscription__c> subsList){  
        boolean enableThrowException = Boolean.valueOf(EnvironmentVariable__c.getValues('EnableThrowException').Value__c); //EDGE-215225  
        try {  
            Map<Id, csord__Service__c> serviceIdsToFetchNew = new Map<Id, csord__Service__c>();  
            Map<Id, csord__Service__c> serviceIdsToFetchModify = new Map<Id, csord__Service__c>();  
            set<Id> baseOrderServiceIDModify=new set<Id>();  
            set<Id> baseOrderServiceIDCancel=new set<Id>();  
            Map<Id, csord__Service__c> serviceMapPricing =  new Map<Id, csord__Service__c>([SELECT Id,  Name, csord__Subscription__c, Scenario_Type__c,toBeCancelled__c,csordtelcoa__Replaced_Service__c FROM csord__Service__c where csord__Subscription__c IN : subsList]);  
            for(Id serviceKey : serviceMapPricing.keyset()){  
                if(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c == null){  
                    serviceIdsToFetchNew.put(serviceKey, serviceMapPricing.get(serviceKey));  
                }  
                else if(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c != null && serviceMapPricing.get(serviceKey).toBeCancelled__c.equalsIgnoreCase('false')){  
                    serviceIdsToFetchNew.put(serviceKey, serviceMapPricing.get(serviceKey));  
                    baseOrderServiceIDModify.add(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c);  
                    //serviceIdsToFetchModify.put(serviceKey, serviceMap.get(serviceKey));  
                }else if(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c != null && serviceMapPricing.get(serviceKey).toBeCancelled__c.equalsIgnoreCase('true')){  
                    baseOrderServiceIDCancel.add(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c);  
                }  
            }  
            if(serviceIdsToFetchNew!=null)  
            {  
                CeasePriceScheduleStep.updateSchedule(serviceIdsToFetchNew.keySet(), 'Active');  
            }  
            if(baseOrderServiceIDModify!=null)  
            {  
                CeasePriceScheduleStep.updateSchedule(baseOrderServiceIDModify, 'Replaced');  
            }  
            if(baseOrderServiceIDCancel!=null)  
            {  
                CeasePriceScheduleStep.updateSchedule(baseOrderServiceIDCancel, 'Inactive');  
            }  
        }  
        catch(Exception e) {  
            logException('updateSchedulesonCallback', '', correlationId,  e.getMessage() + '-' + e.getStackTraceString(), 'Update schedules failed');  
            if(!Test.isRunningTest() && enableThrowException){throw e;}//EDGE-215225  
        }  
    } 
    public static void updateOrderRecordMS(map<csord__Order__c,List<csord__Subscription__c>> orderToSubsMap){  
        Map<Id, csord__Order__c> orderMapToUpdate = new Map<Id, csord__Order__c>();  
        system.debug('orderMapToUpdate'+orderToSubsMap);  
        for(csord__Order__c ord: orderToSubsMap.keySet())  {  
            Integer amendNotallowedTrue = 0 ;  
            Integer amendNotallowedFalse = 0 ;  
            Integer cancelNotallowedTrue = 0 ;  
            Integer cancelNotallowedFalse = 0 ;  
            system.debug('orderMapToUpdate2274'+ orderToSubsMap.get(ord));  
            if(orderToSubsMap.get(ord)!=null){  
                for(csord__Subscription__c sub : orderToSubsMap.get(ord)){  
                    if(sub.Point_of_No_Return_Reached__c == false){  
                        amendNotallowedFalse++;  
                    }else if(sub.Point_of_No_Return_Reached__c == true){  
                        amendNotallowedTrue++;  
                    }  
                    if(sub.cancel_Point_of_No_Return_Reached__c == false){  
                        cancelNotallowedFalse++;  
                    }else if(sub.cancel_Point_of_No_Return_Reached__c == true){  
                        cancelNotallowedTrue++;  
                    }  
                }  
            }  
            csord__Order__c ordToUpdate =ord;  
            if(amendNotallowedFalse>1 )// exclude solution component check as no notification will be received and added check to limit no rows updating  
            {  
                ordToUpdate.csordtelcoa__Point_of_No_Return_Reached__c = false;  
            }  
            else  
                if(amendNotallowedTrue>1){// added check to limit no rows updating  //EDGE-200953 Fix  
                    ordToUpdate.csordtelcoa__Point_of_No_Return_Reached__c = true;  
                }  
            if(cancelNotallowedFalse>1) /*&& ordToUpdate.cancel_Point_of_No_Return_Reached__c != true) - exclude solution component check as no notification will be received - EDGE-214690 removed and condition */  
            {  
                ordToUpdate.cancel_Point_of_No_Return_Reached__c = false;  
            }  
            else  
                if(cancelNotallowedTrue>1){   //EDGE-200953 Fix  
                    ordToUpdate.cancel_Point_of_No_Return_Reached__c = true;  
                }  
            orderMapToUpdate.put(ordToUpdate.id, ordToUpdate);  
            System.debug('ordToUpdate:::'+ordToUpdate);  
        }  
        if(!orderMapToUpdate.isEmpty() && orderMapToUpdate != null){  
            update orderMapToUpdate.values();  
            System.debug('orderMapToUpdate123:::'+orderMapToUpdate);  
        }  
    }  
    // Method to update Subscription's Orchestration Process - EDGE-170546  
    public static void updateInflightSubsOrchestration(List<csord__Order__c> orderList, List<String> orderListIds) {  
        boolean enableThrowException = Boolean.valueOf(EnvironmentVariable__c.getValues('EnableThrowException').Value__c); //EDGE-215225  
        try {  
            System.debug('inside updateInflightSubsOrchestration...'+orderListIds);  
            Map<Id, csord__Subscription__c> subMap = new Map<Id, csord__Subscription__c>();  
            Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();  
            List<String> subsIdList = new List<String>();  
            List<String> servIdList = new List<String>();  
            Map<Id, List<csord__Subscription__c>> ordIdSubsMap = new Map<Id, List<csord__Subscription__c>>();  
            Map<Id, CSPOFA__Orchestration_Process__c> orchMap = new Map<Id, CSPOFA__Orchestration_Process__c>();  
            Map<Id, CSPOFA__Orchestration_Process__c> servOrchMap = new Map<Id, CSPOFA__Orchestration_Process__c>();  
            Map<Id, List<CSPOFA__Orchestration_Process__c>> subsOrchMap = new Map<Id, List<CSPOFA__Orchestration_Process__c>>();  
            Map<Id, List<CSPOFA__Orchestration_Process__c>> servicesOrchMap = new Map<Id, List<CSPOFA__Orchestration_Process__c>>();  
            List<CSPOFA__Orchestration_Process__c> listOfOrchProccessToUpd = new List<CSPOFA__Orchestration_Process__c>();  
            Map<Id, List<csord__Service__c>> subsToServiceMap = new Map<Id, List<csord__Service__c>>();  
            //Block to create map of OrderId and its Subscriptions  
            String subQuery = 'SELECT Id, Name, csord__Status__c,';  
            subQuery += 'csord__Order__c, orderversion__c ';  
            subQuery += ' FROM csord__Subscription__c Where csord__Order__r.Id IN :orderListIds';  
            System.debug('subQuery...'+subQuery);  
            subMap = new Map<Id, csord__Subscription__c>((List<csord__Subscription__c>) Database.query(subQuery));  
            for(csord__Subscription__c sub :subMap.values()){  
                subsIdList.add(sub.Id);  
                if(!ordIdSubsMap.containsKey(sub.csord__Order__c)){  
                    ordIdSubsMap.put(sub.csord__Order__c, new List<csord__Subscription__c>{sub});  
                } else {  
                    ordIdSubsMap.get(sub.csord__Order__c).add(sub);  
                }  
            }  
            //Block to create map of SubsId and its OrchestrationProcess  
            String orchName = 'Subscription Fulfilment Process';  
            String orchQuery = 'SELECT Id, Name, csordtelcoa__Subscription__c ';  
            orchQuery += ' FROM CSPOFA__Orchestration_Process__c Where csordtelcoa__Subscription__c IN:subsIdList AND CSPOFA__Orchestration_Process_Template__r.Name=:orchName';  
            orchMap = new Map<Id, CSPOFA__Orchestration_Process__c>((List<CSPOFA__Orchestration_Process__c>) Database.query(orchQuery));  
            for(CSPOFA__Orchestration_Process__c orch :orchMap.values()){  
                if(!subsOrchMap.containsKey(orch.csordtelcoa__Subscription__c)){  
                    subsOrchMap.put(orch.csordtelcoa__Subscription__c, new List<CSPOFA__Orchestration_Process__c>{orch});  
                } else {  
                    subsOrchMap.get(orch.csordtelcoa__Subscription__c).add(orch);  
                }  
            }  
            String servQuery = 'SELECT Id, Name, csord__Status__c,';  
            servQuery += 'csord__Order__c, csord__Subscription__c,csordtelcoa__Cancelled_By_Change_Process__c,csord__Subscription__r.csordtelcoa__Cancelled_By_Change_Process__c ';  
            servQuery += ' FROM csord__Service__c WHERE csord__Subscription__c IN :subsIdList';  
            serviceMap = new Map<Id, csord__Service__c>((List<csord__Service__c>) Database.query(servQuery));  
            for (csord__Service__c serv : serviceMap.values()) {  
                servIdList.add(serv.Id);  
                if (subsToServiceMap.containsKey(serv.csord__Subscription__c)) {  
                    subsToServiceMap.get(serv.csord__Subscription__c).add(serv);  
                } else {  
                    subsToServiceMap.put(serv.csord__Subscription__c, new List<csord__Service__c>{ serv });  
                }  
            }  
            //Block to create map of ServId and its OrchestrationProcess  
            String servOrchName = 'Service Fulfilment Process';  
            String servOrchQuery = 'SELECT Id, Name, csordtelcoa__Service__c';  
            servOrchQuery += ' FROM CSPOFA__Orchestration_Process__c Where csordtelcoa__Service__c IN :servIdList AND CSPOFA__Orchestration_Process_Template__r.Name = :servOrchName';  
            servOrchMap = new Map<Id, CSPOFA__Orchestration_Process__c>((List<CSPOFA__Orchestration_Process__c>) Database.query(servOrchQuery));  
            for(CSPOFA__Orchestration_Process__c orch :servOrchMap.values()){  
                if(!servicesOrchMap.containsKey(orch.csordtelcoa__Service__c)){  
                    servicesOrchMap.put(orch.csordtelcoa__Service__c, new List<CSPOFA__Orchestration_Process__c>{orch});  
                } else {  
                    servicesOrchMap.get(orch.csordtelcoa__Service__c).add(orch);  
                }  
            }  
            //Block to create list of OrchestrationProcess to update  
            for(csord__Order__c ord : orderList){  
                for(csord__Subscription__c subscription :ordIdSubsMap.get(ord.Id)){  
                    if(subscription.orderversion__c == ord.Fulfilment_Order_Version__c){  
                        if(subsOrchMap.containsKey(subscription.Id)){  
                            for(CSPOFA__Orchestration_Process__c orch : subsOrchMap.get(subscription.Id)){  
                                CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c(Id = orch.Id,CSPOFA__Process_On_Hold__c = false);  
                                listOfOrchProccessToUpd.add(orchProcess);  
                            }  
                            for (csord__service__c service : subsToServiceMap.get(subscription.Id)) {  
                                for(CSPOFA__Orchestration_Process__c orch : servicesOrchMap.get(service.Id)){  
                                    CSPOFA__Orchestration_Process__c servOrchProcess = new CSPOFA__Orchestration_Process__c(Id = orch.Id,CSPOFA__Process_On_Hold__c = false);  
                                    listOfOrchProccessToUpd.add(servOrchProcess);  
                                }  
                            }  
                        }  
                    }  
                }  
            }  
            System.debug('listOfOrchProccessToUpd...'+listOfOrchProccessToUpd);  
            if(listOfOrchProccessToUpd!=null && listOfOrchProccessToUpd.size()>0){  
                update listOfOrchProccessToUpd;  
            }  
        }  
        catch(Exception e) {  
            logException('updateInflightSubsOrchestration', '', correlationId,  e.getMessage() + '-' + e.getStackTraceString(), 'Process accepted notifications with orchestration');  
            if(!Test.isRunningTest() && enableThrowException){throw e;}//EDGE-215225  
        }  
    }  
    //EDGE-170552  
    public static void getParticipatingServices(List<csord__Service__c> srvcList){  
        //Map<string,csord__Service__c> partservmap =new Map<string,csord__Service__c>();  
        for(csord__Service__c serv :srvcList)  
        {  
            if(serv.csord__Subscription__r.orderversion__c == serv.csord__Order__r.Fulfilment_Order_Version__c)  
            {  
                partservmap.put(serv.csordtelcoa__Service_Number__c,serv);  
            }  
        }  
    } 
    /** 
     * @description Exception Handling Framework  
     */
    private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription) {
        Map < String, Object > eLogMap = new Map < String, Object > ();
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
}