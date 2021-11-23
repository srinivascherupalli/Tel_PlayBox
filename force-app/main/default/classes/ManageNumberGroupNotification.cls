/*
* @Author  : Mukta Wadhwani
* @Date    : 12-03-2021
* @Desc    : This class is to update the Number Group and Number status when statusNotification is triggered for NGUC
* @Jira : EDGE-141545
1. EDGE-143006 : VivEK mAKKAR 16TH mARCH 2021 : processBillingNotifications
2. EDGE-204265 : Mukta Wadhwwani 0806-2021    : Introduced feature toggeling.
3. Team Apple : Updaing processBillingNotifications way to active and inactive
   as 1636 design issue : 8th June 2021
4. DIGI-1413 : Aniket 06-08-2021 : Notification Management

*/

public class ManageNumberGroupNotification {
    private static final String CONST_INTERFACENAME = 'ManageNumberGroupNotification';
    private static String correlationId = GuidUtil.NewGuid();
    //Method to update status of Number Group and Number as per O2A response
    public static void processFulfilmentNotifications(Map<String,String> numbreGroupStatusMap,Map<String,String> numberGroupSubStageMap) {
        List<Number_Group__c> groupUpdateList       =  new List<Number_Group__c>();
        Set<Number_Group__c> groupUpdateSet         =  new Set<Number_Group__c>();
        List<Number__c> numberUpdateList            =  new List<Number__c>();
        Boolean o2ANotificationProcessing           =  FeatureEligibilityChecker.determineFeatureEligiblity('O2ANotificationProcessing','O2ANotifications');
        Boolean o2APortOutProcessing                =  FeatureEligibilityChecker.determineFeatureEligiblity('O2APortOutProcessing','O2APortOut');
        try{
            if((numbreGroupStatusMap == null || numbreGroupStatusMap.keySet().size() <= 0) && !o2ANotificationProcessing && !o2APortOutProcessing){
                   return;
               }
            
            for(Number__c numberObj : [select Number_Group__c,Number_Group__r.Name,Number_Group__r.Status__c,Number_Group__r.Scenario_Type__c,id,Name,Status__c  from Number__c where Number_Group__r.Name=:numbreGroupStatusMap.keySet()]){
                if(numbreGroupStatusMap.containsKey(numberObj.Number_Group__r.Name)){
                    Number_Group__c groupObj = new Number_Group__c(Id = numberObj.Number_Group__c);
                    //If O2ANotifications feature is enabled for all update Number and number group as per O2A response for add/remove/transition scenario.
                    if(o2ANotificationProcessing && numberObj.Number_Group__r.Scenario_Type__c != 'Port Out'){
                        groupUpdateSet.addAll(changeNumberGroupStatus(groupObj,numbreGroupStatusMap.get(numberObj.Number_Group__r.Name)));
                        numberUpdateList.addAll(chnageNumbersStatus(numberObj,numbreGroupStatusMap.get(numberObj.Number_Group__r.Name)));
                    }
                    //If O2APortOut feature is enabled for all update Number and number group as per O2A response for Port Out scenario.
                    if( o2APortOutProcessing && numberObj.Number_Group__r.Scenario_Type__c == 'Port Out'){
                        groupUpdateSet.addAll(changeNumberGroupStatusPortOut(groupObj,numbreGroupStatusMap.get(numberObj.Number_Group__r.Name)));
                        numberUpdateList.addAll(chnageNumbersStatusPortOut(numberObj,numbreGroupStatusMap.get(numberObj.Number_Group__r.Name)));
                    }
                    
                    
                }
            }
            
            
            if(!groupUpdateSet.isEmpty() && !numberUpdateList.isEmpty()){
                groupUpdateList.addAll(groupUpdateSet);
                update groupUpdateList;
                update numberUpdateList;
            }
            
        }
        catch(Exception e){
            NumberReservationHelper.logException('processFulfilmentNotifications','',correlationId, e.getMessage(), 'O2A Notification for Number Group Failed.',CONST_INTERFACENAME);
        }
    }
    //Method Ends
    //DIGI 1413
    public static void processFulfilmentNotifications(Map<String,String> numberStatusMap,List<NotificationParameters> NumberParamsList){
        List<Number_Group__c> numberGroupUpdateList = new List<Number_Group__c>();
        Set<Id> orderSet = new Set<Id>();
        Map<Id,Integer> removedNumberMap = new Map<Id,Integer>();
        Set<String> activeSubscriptions = new Set<String>();
        Set<String> conectedSubscriptions = new Set<String>();
        Map<Id,Decimal> completedNumbersCountMap = new Map<Id,Decimal>();
        Map<String,String> numberGrpSubscriptionMap = new Map<String,String>();
        List<csord__Service__c> parentServices = new List<csord__Service__c>();
        Map<Id,List<csord__Service__c>> childServicesMap = new Map<Id,List<csord__Service__c>>();
        Map<String,csord__Service__c> subscriptionServiceMap = new Map<String,csord__Service__c>();
        try{
            updateNumberRecords(NumberParamsList);
            List<Number__c> numberList=[select Number_Group__c,External_Id__c,Status__c,Number_Group__r.OrderId__c,Subscription_number__c,Number_Group__r.Total_Numbers_Completed__c,Number_Group__r.Scenario_Type__c,Number_Group__r.Total_Numbers_Reserved__c  from Number__c where External_Id__c IN :numberStatusMap.keySet() WITH SECURITY_ENFORCED];
            for(Number__c numberObj : numberList){
                activeSubscriptions.add(numberObj.Subscription_number__c);
                orderSet.add(numberObj.Number_Group__r.OrderId__c);
                if(numberObj.Number_Group__r.Scenario_Type__c == 'Remove'){
                    removedNumberMap.put(numberObj.Number_Group__c,Integer.valueOf(numberObj.Number_Group__r.Total_Numbers_Reserved__c));
                }
                if(numberStatusMap.get(numberObj.External_Id__c)=='Complete'){ 
                    numberGrpSubscriptionMap.put(numberObj.Number_Group__c,numberObj.Subscription_number__c);
                    if(completedNumbersCountMap.containsKey(numberObj.Number_Group__c)){
                        completedNumbersCountMap.put(numberObj.Number_Group__c,completedNumbersCountMap.get(numberObj.Number_Group__c)+1);
                    }else{
                        completedNumbersCountMap.put(numberObj.Number_Group__c,numberObj.Number_Group__r.Total_Numbers_Completed__c+1);
                    }
                    numberObj.Status__c=numberObj.Number_Group__r.Scenario_Type__c == 'Remove'?'Disconnected':'Provisioned';
                }else{

                    numberObj.Status__c=numberObj.Number_Group__r.Scenario_Type__c == 'Remove'?'Disconnect In Progress':numberStatusMap.get(numberObj.External_Id__c);
                }
                
            }
            List<csord__Service__c> lstService = [Select Id,csord__Status__c,csord__Service__c,Quantity__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c
                                                    from csord__Service__c where csord__Order__c IN :orderSet
                                                    WITH SECURITY_ENFORCED];
            for(csord__Service__c servc:lstService){
                if(servc.csord__Service__c==null){
                    parentServices.add(servc);
                    String subscriptionNumber=servc.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
                    if(activeSubscriptions.contains(subscriptionNumber)){
                        subscriptionServiceMap.put(subscriptionNumber,servc);
                    }
                }else{
                    List<csord__Service__c> tempList=new List<csord__Service__c>();
                    if(childServicesMap.containsKey(servc.csord__Service__c)){
                        tempList.addAll(childServicesMap.get(servc.csord__Service__c));
                    }
                    tempList.add(servc);
                    childServicesMap.put(servc.csord__Service__c,tempList);
                }
            }
            for(Id ngId: completedNumbersCountMap.keySet()){
                if(removedNumberMap.containsKey(ngId)){
                    if(removedNumberMap.get(ngId) <= completedNumbersCountMap.get(ngId)){
                        numberGroupUpdateList.add(new Number_Group__c(Id=ngId,Status__c='Disconnected',Total_Numbers_Completed__c=completedNumbersCountMap.get(ngId)));
                    }else{
                        numberGroupUpdateList.add(new Number_Group__c(Id=ngId,Status__c='Disconnect In Progress',Total_Numbers_Completed__c=completedNumbersCountMap.get(ngId)));
                    }
                }else{
                    if(subscriptionServiceMap.get(numberGrpSubscriptionMap.get(ngId)).Quantity__c<=completedNumbersCountMap.get(ngId)){
                        numberGroupUpdateList.add(new Number_Group__c(Id=ngId,Status__c='Complete',Total_Numbers_Completed__c=completedNumbersCountMap.get(ngId)));
                        conectedSubscriptions.add(numberGrpSubscriptionMap.get(ngId));
                    }else{
                        numberGroupUpdateList.add(new Number_Group__c(Id=ngId,Total_Numbers_Completed__c=completedNumbersCountMap.get(ngId)));
                    }
                }
            }
            for(Id ngId:removedNumberMap.keySet()){
                if(!completedNumbersCountMap.containsKey(ngId)){
                    numberGroupUpdateList.add(new Number_Group__c(Id=ngId,Status__c='Disconnect In Progress'));
                }

            } 
            List<csord__Service__c> servToUpdate= new List<csord__Service__c>();
            for(csord__Service__c servc:parentServices){
                if(activeSubscriptions.contains(servc.csord__Subscription__r.csordtelcoa__Subscription_Number__c)){
                    if(conectedSubscriptions.contains(servc.csord__Subscription__r.csordtelcoa__Subscription_Number__c)){
                        servc.csord__Status__c='Connected';
                        servToUpdate.add(servc);
                        if(childServicesMap.containsKey(servc.Id))
                        for(csord__Service__c childServ: childServicesMap.get(servc.Id)){
                            if(childServ.csord__Status__c!='Connected'){
                                childServ.csord__Status__c='Connected';
                                servToUpdate.add(childServ);
                            }
                        }
                    }else{
                        servc.csord__Status__c='In Progress';
                        servToUpdate.add(servc);
                        if(childServicesMap.containsKey(servc.Id))
                        for(csord__Service__c childServ: childServicesMap.get(servc.Id)){
                            if(childServ.csord__Status__c!='Connected'){
                                childServ.csord__Status__c='In Progress';
                                servToUpdate.add(childServ);
                            }
                        }
                    }
                }
            }
            update numberList;
            update numberGroupUpdateList;
            update servToUpdate;
        }
        catch(Exception e){
            NumberReservationHelper.logException('processFulfilmentNotifications','',correlationId, e.getMessage(), 'O2A Notification for Number Failed.',CONST_INTERFACENAME);
        }

    }
    public static void updateNumberRecords(List<NotificationParameters> numberParamsList){
        Map<String,Map<String,String>> numberAttrMap = new Map<String,Map<String,String>>();
        Set<String> oredrUpdateLSet=new Set<String>();
        for(NotificationParameters notification:numberParamsList){

            ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes('{' + String.valueOf(notification.notificationAttributes) + '}');
            for (ManageOrderNotificationUtil.NotificationAttributes attr : notifyAttrs.attributes) {
                if (attr.name.contains('status') && notification.eventType.equalsIgnoreCase('statusNotification')) {
                    
                    oredrUpdateLSet.add(notification.externalOrderId);
                }
            }

            String numberExtId;
            Map<String,String> attrMap=new Map<String,String>();
            List<String> keyparams = notification.orderItemId.split('\\|');
            if(keyparams.size() > 1){ 
                numberExtId = keyparams[1];
                ManageOrderNotificationUtil.Product productUpdates = ManageOrderNotificationUtil.parse('{'+String.valueOf(notification.orderItemDetails)+'}');  
                if(productUpdates.attributes != NULL){  
                    for(ManageOrderNotificationUtil.NotificationAttributes attr : productUpdates.attributes){ 
                        attrMap.put(attr.name,attr.value);
                    } 
                    if(!attrMap.isEmpty()){
                        numberAttrMap.put(numberExtId, attrMap);
                    }    
                }
            }
        }
        
        List<csord__Order__c> orderList=[SELECT csord__Status2__c FROM csord__Order__c where csord__Status2__c = 'Submitting' AND csord__Order_Number__c IN :oredrUpdateLSet];
        for(csord__Order__c order:orderList){
            order.csord__Status2__c='In Progress';
        }
        if(!orderList.isEmpty()){
            update orderList;
        }
        if(!numberAttrMap.isEmpty()){
            List<Number__C> lstNumber=[SELECT IMSI__c, Sim_Serial_Number__c,External_Id__c 
                                       FROM Number__c WHERE 
                                       External_Id__c != null AND External_Id__c IN:numberAttrMap.keySet()];
            for(Number__C numberobj:lstNumber){
                Map<String,String> attr=numberAttrMap.get(numberobj.External_Id__c);
                if(!attr.isEmpty()){    
                    if(attr.ContainsKey('IMSI')){   
                        numberobj.IMSI__c = attr.get('IMSI');   
                        if(attr.ContainsKey('SIMSerialNumber')) 
                            numberobj.Sim_Serial_Number__c = attr.get('SIMSerialNumber');   
                    }   
                } 
            }
           update lstNumber;   
        }
    }
    //Method to Update number group status for add/Transition/Remove.
    public static List<Number_Group__c> changeNumberGroupStatus(Number_Group__c groupObj,String groupStatus){
        List<Number_Group__c> groupUpdateList            =  new List<Number_Group__c>();
        
        if(groupStatus == 'In Progress'){
            groupObj.Status__c = groupObj.Scenario_Type__c == 'Remove' ? 'Disconnect In Progress' : 'Provisioning In Progress';
            groupUpdateList.add(groupObj);
        }
        else if(groupStatus == 'Complete'){
            groupObj.Status__c = groupObj.Scenario_Type__c == 'Remove' ? 'Disconnected' : 'Provisioned';
            groupUpdateList.add(groupObj);
        }
        
        return groupUpdateList;
    }
    //Method ends.
    
    //Method to Update number group status for Port Out.
    public static List<Number_Group__c> changeNumberGroupStatusPortOut(Number_Group__c groupObj,String groupStatus){
        List<Number_Group__c> groupUpdateList            =  new List<Number_Group__c>();
        
        if(groupStatus == 'In Progress'){
            groupObj.Status__c = 'Disconnect In Progress';
            groupUpdateList.add(groupObj);
        }
        else if(groupStatus == 'Complete'){
            groupObj.Status__c = 'Disconnected';
            groupUpdateList.add(groupObj);
        }
        
        return groupUpdateList;
    }
    //Mehtod ends.
    
    //Method to Update number status for add/Transition/Remove.
    public static List<Number__c> chnageNumbersStatus(Number__c numberObj,String groupStatus){
        List<Number__c> numberUpdateList            =  new List<Number__c>();
        
        if(groupStatus == 'In Progress'){
            numberObj.Status__c = numberObj.Number_Group__r.Scenario_Type__c == 'Remove' ? 'Disconnect In Progress' : 'Provisioning In Progress';
            numberUpdateList.add(numberObj);
        }
        else if(groupStatus == 'Complete'){
            numberObj.Status__c = numberObj.Number_Group__r.Scenario_Type__c == 'Remove' ? 'Disconnected' : 'Provisioned';
            numberUpdateList.add(numberObj);
        }
        
        return numberUpdateList;
    }
    //method ends
    
    //Method to Update number group status for add/Transition/Remove.
    public static List<Number__c> chnageNumbersStatusPortOut(Number__c numberObj,String groupStatus){
        List<Number__c> numberUpdateList            =  new List<Number__c>();
        
        if(groupStatus == 'In Progress'){
            numberObj.Status__c = 'Disconnect In Progress';
            numberUpdateList.add(numberObj);
        }
        else if(groupStatus == 'Complete'){
            numberObj.Status__c =  'Disconnected';
            numberUpdateList.add(numberObj);
        }
        
        return numberUpdateList;
    }
    //method ends
    
    // Method Starts EDGE-143006 
    public static void processBillingNotifications( List<NotificationParameters> paramsList ) {
        
        List<String> orderItemId                        =   new List<String>() ;
        List<String> externalOrderId                    =   new List<String>();
        Set<String> excludedNumberSet                   =   new Set<String>();
        List<Number__c> numbersListToUpdate             =   new List<Number__c>();
        Map<String , String> serviceWithError           =   new Map<String, String>();
        
        processErrorServices( paramsList, orderItemId, externalOrderId, excludedNumberSet, numbersListToUpdate, serviceWithError  );
        handleServiceStatusUpdate(  excludedNumberSet, numbersListToUpdate, serviceWithError, externalOrderId, orderItemId );    
        
    }
    
    // Method to process service Notification to fetch errors and keep track of failed services
    public static void processErrorServices( List<NotificationParameters> paramsList , List<String> orderItemId , List<String> externalOrderId , Set<String> excludedNumberSet, List<Number__c> numbersListToUpdate, Map<String , String> serviceWithError   ) {
        if( paramsList != null && !paramsList.isEmpty() ) {
            for( NotificationParameters notifObj :paramsList ) {
                
                if (  notifObj.eventType == 'error' ){
                    ErrorDetailWrap eWrap                               = new ErrorDetailWrap();
                    NotificationAttributesDataObject errorDetailList    = eWrap.parseAttributes(String.valueOf('{'+String.valueOf(notifObj.errorDetails)+'}'));
                    System.debug('errorDetailList --> ' + errorDetailList);
                    if(errorDetailList != null && errorDetailList.error != null){
                        for ( NotificationAttributes errorServiceBlock : errorDetailList.error ) {
                            excludedNumberSet.add( errorServiceBlock.serviceNumber );
                            if (! serviceWithError.containsKey( errorServiceBlock.serviceNumber )){
                                serviceWithError.put( String.valueOf( errorServiceBlock.serviceNumber ) , String.valueOf( errorServiceBlock.errorDescription ) );
                            }
                        }
                    }
                } 
                orderItemId.add(notifObj.orderItemId);
                externalOrderId.add(notifObj.externalOrderId);
                
            }
        }
    } 
    
    // Method to update status of Number/ Services based on Billing response
    public static void handleServiceStatusUpdate (  Set<String> excludedNumberSet, List<Number__c> numbersListToUpdate, Map<String , String> serviceWithError, List<String> externalOrderId , List<String> orderItemId ) {
        
        List<Number__c> numbersList = [SELECT Id ,IsDisconnected__c,BDS_Error_Message__c,Name,Service_Number__c, BDS_EventId__c , Status__c , Number_Group__r.Scenario_Type__c FROM Number__c WHERE BDS_EventId__c IN: orderItemId OR BDS_EventId__c IN: externalOrderId];
        
        if (numbersList.isEmpty()){
            return;
        }
        
        for( Number__c numberser : numbersList ){
            if (! excludedNumberSet.contains( String.valueOf( numberser.Service_Number__c)) ){
                 //  Design fix 1636 @Apple
                if ( numberser.BDS_EventId__c != null &&  numberser.IsDisconnected__c ){
                    numberser.Status__c = 'Inactive';
                }else if ( numberser.BDS_EventId__c != null &&  !numberser.IsDisconnected__c ){
                    numberser.Status__c = 'Active';
                }                       
            }else{
                numberser.Status__c             = 'Error';
                if ( serviceWithError.containsKey( String.valueOf( numberser.Service_Number__c) )){
                    numberser.BDS_Error_Message__c  = serviceWithError.get( String.valueOf( numberser.Service_Number__c) );
                }
            }
            numbersListToUpdate.add(numberser);
        }
        
        
        if (!numbersListToUpdate.isEmpty()){
            try{
                UPDATE NumbersListToUpdate;
            }
            catch(Exception e){
                ApplicationLog__c failLog = new ApplicationLog__c(Error_Description__c= 'Class : ManageNumberGroupNotification',Message__c = e.getMessage());
                insert failLog;
            }
        }
    }
    
    public class ErrorDetailWrap{    
        public NotificationAttributesDataObject parseAttributes(String json) {
            return (NotificationAttributesDataObject) System.JSON.deserialize(json, NotificationAttributesDataObject.class);
        }
    }
    
    public class NotificationAttributes{
        public String errorCode {get; set;}
        public String errorDescription {get; set;}
        public String serviceNumber {get; set;}
    }
    
    public class NotificationAttributesDataObject{
        public List<NotificationAttributes> error;
    }
    // Method End EDGE-143006 
    
    
}