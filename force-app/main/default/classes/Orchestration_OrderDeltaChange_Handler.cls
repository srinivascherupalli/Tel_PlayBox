/**================================================================ 
* Name: Orchestration_OrderDeltaChange_Handler
* Description: Class to update Delta changes
* Created Date: 
* Created By: 
==================================================================*/
public class Orchestration_OrderDeltaChange_Handler implements Orchestration_StepInterface{
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    private Id IncompleteStepId = null;
    //private Map<Id, csord__Subscription__c> subsMap = new Map<Id, csord__Subscription__c>();
    List<object> SubList = new List<object>();
    
    private Set<Id> orderToSkipFullfillmentCheck = new Set<Id>();
    
    private Map<Id, Set<String>> stepRelationshiptoSkipMap = new Map<Id, Set<String>>();
    
    private Map<Id, List<csord__Service__c>> ordToServiceMap = new Map<Id, List<csord__Service__c>>();
    //Store Order --> Subscription
    private Map<Id, List<csord__Subscription__c>> ordToSubsMap = new Map<Id, List<csord__Subscription__c>>();
    private Map<Id, List<csord__Subscription__c>> updatedOrdToSubsMap = new Map<Id, List<csord__Subscription__c>>();
    //Order --> Solution Component Subscription
    private Map<Id, List<csord__Subscription__c>> ordToSolnSubsMap = new Map<Id, List<csord__Subscription__c>>();
    //Store Subscription --> Service
    private Map<Id, List<csord__Service__c>> subsToServiceMap = new Map<Id, List<csord__Service__c>>();
    //Store Service --> Attachment
    //private Map<Id, Orchestration_AttachmentWrapper> serviceToAttachMap = new Map<Id, Orchestration_AttachmentWrapper>();
    private Map<Id, Orchestration_Technical__c> serviceToAttachMap = new Map<Id, Orchestration_Technical__c>();
    
    public List<String> exclusionList = new List<String>();
    //Store initial service state
    private String srvStatus = '';
    //Limit hit check
    private Boolean isLimitHit = false;
    //Store multiple records for a step at a place, use set to avoid duplication
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
    
    private Map<Id, csord__Order__c> updateOrderMap = new Map<Id, csord__Order__c>();
    //Keep track of subscription updation, map to avoid duplication
    private Map<Id, csord__Subscription__c> subsToUpdate = new Map<Id, csord__Subscription__c>();
    //Keep track of service updation, map to avoid duplication
    private Map<Id, csord__Service__c> servicesToUpdate = new Map<Id, csord__Service__c>();
    //Keep track of attachment updation, map to avoid duplication
    // private Map<Id, Attachment> attachmentsToUpdate = new Map<Id, Attachment>();
    private Map<Id, Orchestration_Technical__c> attachmentsToUpdate = new Map<Id, Orchestration_Technical__c>();
    List<String> specCodes = new List<String>{ 'DMCAT_ProductSpecification_000871','DMCAT_ProductSpecification_000263'};
        private String NGEMplanSpecCode='DMCAT_ProductSpecification_001196'; // DPG-4545 mahima
    //Added for EDGE-179268 : PRM Action Types changes ,suspend resume                                                      
    private boolean isMigration= false;
    private map<Id,string> serviceTransitionIdMap=new  map<Id,string>(); //EDGE-208435
    private map<string,boolean> serviceMicaDependencyMap=new  map<string,boolean>(); //EDGE-208435
    private map<string,boolean> subscriptionMicaDependencyMap=new  map<string,boolean>();//EDGE-208435
    private set<id>solutionSubscriptionIdSet=new set<id>();//EDGE-208435
    private Map<Id,Id> solutionSubscriptionMap =new Map<Id,Id>();// Added by Nikhil as part of EDGE-226305
    private List<csord__Order__c> orderList = new List<csord__Order__c>();
    Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
    private Map<Id, CSPOFA__Orchestration_Step__c> mapStepDetails = new Map<Id, CSPOFA__Orchestration_Step__c>();
    public  void processUpdate(String strPayload) {
        List<SObject> sobjList = new List<SObject>(); // Added as part of EDGE-222326
        Set<Id> orderIds = new Set<Id>();
        Id stepId;
        Id orderId;
		
		//Id orId;
        // if (Orchestration_LimitsUtility.areLimitsViolated()) {
        //Cannot process the records
        //return sobjList; // Added as part of EDGE-222326
        //  }
        
        try {
            Map<String, Object> mapPayload = (Map<String, Object>)JSON.deserializeUntyped(strPayload);
            orderId = (Id)mapPayload.get('OrderId');
            //processedRecordIds = (Orchestration_ProcessedRecords)mapPayload.get('processedRecordIds');
            stepId = (Id)mapPayload.get('StepId');
            
            orderIds.add(orderId);
            
           
            
            //processedRecordIds = processedIds.get(stepId);
            
            
            ////List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);
            //Set<Id> ordRequestIds = new Set<Id>();
            
            //commented as part of coms upliftment
            /* subsMap = new Map<Id, csord__Subscription__c>(
[
SELECT
Id,
Name,
MarketableOffer__r.Config__c,
csord__Order__r.csord__Primary_Order__c,
csord__Order__r.Name,
csord__Status__c,
triggerBill_RTB__c,
Trigger_RTS__c,
toBeCancelled__c,
csordtelcoa__Product_Configuration__c,
csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name,
MarketableOffer__c,
MarketableOffer__r.Offer_ID__c,
csordtelcoa__Replaced_Subscription__c,
ConfigSpecID__c,
changeType__c, // EDGE-179268 : PRM Action Types change
cssdm__solution_association__c//EDGE-208435
FROM csord__Subscription__c
WHERE csord__Order__c IN :orderIds
]
);*/
            orderList = Coms_PlatformCacheUtil.getOrderFromCache(orderIds);
            subList= Coms_PlatformCacheUtil.getAllSubscriptionFromCache(orderIds);
            
            system.debug('OrderIds '+orderIds);
            system.debug('subList '+subList);
            for (csord__Subscription__c sub : (List<csord__Subscription__c>)subList) {
                
                if (!Orchestration_LimitsUtility.areLimitsViolated()) {
                    //Cannot create collections
                    /*return null;
}*/
                    // Added by Nikhil as part of EDGE-226305
                    if (sub?.csordtelcoa__Product_Configuration__r?.ConfigurationType1__c == 'SolutionComponent') {
                        if(sub.csord__Status__c != 'Active'){
                            solutionSubscriptionMap.put(sub.cssdm__solution_association__c,sub.Id);
                        }
                    }
                    if (ordToSubsMap.containsKey(sub.csord__Order__c)) {
                        ordToSubsMap.get(sub.csord__Order__c).add(sub);
                    } else {
                        ordToSubsMap.put(sub.csord__Order__c, new List<csord__Subscription__c>{ sub });
                    }
                    system.debug('ordToSubsMap '+ordToSubsMap);
                    //Check skip fulfillment
                    List<String> statusList = new List<String>{ OrchestratorConstants.SubscriptionStatus.Pending, OrchestratorConstants.SubscriptionStatus.ProvisioningInProgress, OrchestratorConstants.SubscriptionStatus.DisconnectPending, OrchestratorConstants.SubscriptionStatus.DisconnectInProgress };
                        } }
            
            Set<Id> replaceService = new Set<Id>();
            List<csord__Service__c> servList = new List<csord__Service__c>();
            Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();
            //Fetch services of order and subscriptions
            /*
Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>(
[
SELECT
Id,
Name,
toBeCancelled__c,
csord__Status__c,
csord__Subscription__c,
csord__Subscription__r.csord__Status__c,
csord__Subscription__r.triggerBill_RTB__c,
csordtelcoa__Replaced_Service__r.csord__Status__c,
csordtelcoa__Replaced_Service__r.Payment_Type__c,
csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
csordtelcoa__Product_Configuration__r.Name,
Payment_Type__c,
Action_Type__c,
csordtelcoa__Product_Configuration__r.Remaining_Term__c,
csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name,
csord__Order__r.csord__Status2__c,
csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c,
csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
csord__Order__c,
csord__Service__c,
changeType__c,// EDGE-179268 : PRM Action Types change
csordtelcoa__Replaced_Service__c,
csordtelcoa__Product_Configuration__c,
csord__Order__r.csord__Primary_Order__c,
csord__Subscription__r.MarketableOffer__c,
csord__Subscription__r.MarketableOffer__r.Offer_ID__c,
Scenario_Type__c,
csord__Order__r.Product_Basket__r.BasketType__c,

csord__Service__r.csord__Subscription__r.ConfigSpecID__c,// DPG-4545
csord__Subscription__r.Suspension_reason_summary__c, // DPG-4545
csord__Subscription__r.cssdm__solution_association__c,Transition_Id__c//EDGE-208435
FROM csord__Service__c
WHERE csord__Subscription__c IN :subsMap.keySet() /* AND csordtelcoa__Replaced_Service__c != null // already commented previously
]
);
*/
            
            
            servList =Coms_PlatformCacheUtil.getAllServicesFromCache(orderIds);
            system.debug('service.csordtelcoa__Product_Configuration__r.Name '+servList[0].csordtelcoa__Product_Configuration__r.Name);
            List<FormulaRecalcResult> results = Formula.recalculateFormulas(servList);
            system.debug('afterformula '+servList[0].csordtelcoa__Product_Configuration__r.Name);
            system.debug('afterformula1 '+servList[0].csordtelcoa__Product_Configuration__r.ConfigurationType1__c);
            //Fetching Services related to the Orders
            for (csord__Service__c serv : servList) {
                
                serviceMap.put(serv.id, serv);
                if(serv.changeType__c =='Migration'){
                    isMigration = true;
                }
                /*Start-EDGE-208435-Dheeraj Bhatt-Enhance Subscription orchestration process steps to hold Right to Bill trigger for migration MRO subscription.*/
                if(serv.changeType__c == 'Migration' && string.IsNotBlank(serv.Transition_Id__c) && (serv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c =='DMCAT_ProductSpecification_001342' || serv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c=='DMCAT_ProductSpecification_001455')){
                    serviceTransitionIdMap.put(serv.id,serv.Transition_Id__c);
                }
                
                /*  if (Orchestration_LimitsUtility.areLimitsViolated()) {
//Cannot create collections
return null;
}
*/
                
                //Filter the services related to the subscription
                //if (subsMap.keySet().contains(serv.csord__Subscription__c)) {
                if (subsToServiceMap.containsKey(serv.csord__Subscription__c)) {
                    subsToServiceMap.get(serv.csord__Subscription__c).add(serv);
                } else {
                    subsToServiceMap.put(serv.csord__Subscription__c, new List<csord__Service__c>{ serv });
                }
                //}
            }
            system.debug('subsToServiceMap '+subsToServiceMap);
            /*Start-EDGE-208435-Dheeraj Bhatt-Enhance Subscription orchestration process steps to hold Right to Bill trigger for migration MRO subscription.*/
            if(!serviceTransitionIdMap.isEmpty()){
                List<Service_Add_On__c> serviceAddOnList= new List<Service_Add_On__c>([SELECT  id,isMicaDependency__c,Instance_Id__c FROM Service_Add_On__c WHERE Instance_Id__c IN:serviceTransitionIdMap.values() AND isMicaDependency__c=false]);    
                if(!serviceAddOnList.isEmpty()){
                    for(String serviceId:serviceTransitionIdMap.keySet()){
                        for(Service_Add_On__c addOn:serviceAddOnList){
                            if(addOn.Instance_Id__c==serviceTransitionIdMap.get(serviceId)){
                                serviceMicaDependencyMap.put(serviceId, addOn.isMicaDependency__c);
                                subscriptionMicaDependencyMap.put(serviceMap.get(serviceId).csord__Subscription__c, addOn.isMicaDependency__c);
                                solutionSubscriptionIdSet.add(serviceMap.get(serviceId).csord__Subscription__r.cssdm__solution_association__c);
                            }
                        } 
                    }
                }
            }
            //Fetching the attachments for service and replaced service
            
            /*
for (Attachment attch : [SELECT Id, Name, body, parentId FROM Attachment WHERE parentId IN :serviceMap.keySet() /*OR parentId IN :replaceService AND Name = :OrchestratorConstants.DataOrchestrationNames.service]) { // already commented for replaced service
/*if (Orchestration_LimitsUtility.areLimitsViolated()) {
//Cannot create collections
return null;
}

serviceToAttachMap.put(attch.parentId, new Orchestration_AttachmentWrapper(attch.Id, attch.body));
}*/
            //List<object> attachList = new List<object>();
            List<Orchestration_Technical__c> attachList = new List<Orchestration_Technical__c>();
            
            attachList =Coms_PlatformCacheUtil.getTechnicalObjectFromCache(orderId,serviceMap.keySet());
            
            /*for(Attachment attch :(List<Attachment>)attachList){
serviceToAttachMap.put(attch.parentId,new Orchestration_AttachmentWrapper(attch.Id, attch.body));
}*/
            for(Orchestration_Technical__c techObj:attachList){
                serviceToAttachMap.put(techObj.Service__c, techObj);
            }
            
            for (Excluded_Spec_Attributes__mdt excludeAttr : [SELECT Exclusion_Name__c FROM Excluded_Spec_Attributes__mdt WHERE Exclusion_Type__c = :OrchestratorConstants.Exclusion.DeltaCheck]) {
                exclusionList.add(excludeAttr.Exclusion_Name__c);
            }
            
            //Fetching the initial state of service from custom setting
            if (csordtelcoa__Orders_Subscriptions_Options__c.getInstance() != null) {
                srvStatus = csordtelcoa__Orders_Subscriptions_Options__c.getInstance().csordtelcoa__Service_Initial_State__c;
            }
            
            ////  for (CSPOFA__Orchestration_Step__c step : stepList) {
            try {
                ////   if (Orchestration_LimitsUtility.areLimitsViolated()) {
                //terminate the loop
                ////  break;
                ////}
                ////    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                
                ////    if (processedRecordIds != null) {
                ////        processedIds.put(step.Id, processedRecordIds);
                ////    }
                
                
                
                //Check for data issue - order should be present
                ////    if (step.CSPOFA__Orchestration_Process__r.Order__c == null || ordToSubsMap == null || (ordToSubsMap.keyset()!=null && !ordToSubsMap.containskey(step.CSPOFA__Orchestration_Process__r.order__c))) {
                //Updating steps as Error since no proper data linked to step
                ////  stepResults.put(stepId, new stepResult('Error: Step do not have an order or subscriptions', OrchestratorConstants.OrchestratorStep.Error));
                //Check the next step
                ////     continue;
                ////   }
                
                Boolean SkipFulfilmet = true;
                List<csord__subscription__c> updatedSubsList = new List<csord__subscription__c>();
                
                //for (csord__subscription__c subscription : ordToSubsMap.get(step.CSPOFA__Orchestration_Process__r.order__c)) {
                for (csord__subscription__c subscription : ordToSubsMap.get(orderId)) {
                    
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        IncompleteStepId = stepId;
                        break;
                    }
                    
                    boolean isParentSVCPaidOut = false; //EDGE-164355
                    
                    Boolean isPartnerDeliveredOffer = false;
                    Boolean markServicesConnected = false; //EDGE-189508
                    if (processedRecordIds == null || (processedRecordIds.subsIds == null || !processedRecordIds.subsIds.contains(subscription.Id)) && (processedRecordIds.skipRecordsIds == null || !processedRecordIds.skipRecordsIds.contains(subscription.Id))) {
                        
                        
                        //System.debug('subscriptionSOM'+subscription);
                        if (subscription.MarketableOffer__r != null && String.isNotBlank(subscription.MarketableOffer__r.Config__c)) {
                            Map<String, Object> basketConfiguration = (Map<String, Object>) JSON.deserializeUntyped(subscription.MarketableOffer__r.Config__c);
                            if (basketConfiguration.get('SOMOpenAir') != null && (Boolean) basketConfiguration.get('SOMOpenAir')) {isPartnerDeliveredOffer = true;}
                            /* EDGE-189508 Begin*/
                            if (basketConfiguration.get('markServicesConnected') != null && (Boolean) basketConfiguration.get('markServicesConnected')) {markServicesConnected = true;}
                        }
                        /* EDGE-189508 End*/
                        //Map<Id, Map<String, String>>
                        Integer countTotalFulfilmentSpecSub = 0;
                        Integer countTotalBillSpecSub = 0;
                        Integer countTotalCompFulfilmentSpecSub = 0;
                        Integer countTotalCompBillSpecSub = 0;
                        Integer servicesPaidOutCount = 0;
                        Integer servicesPayOutCount = 0; //EDGE-163712
                        Integer servicesConnectedCount = 0; //EDGE-163712
                        Integer servicesDisconnectedCount = 0; //EDGE-163712
                        system.debug('serviceId '+subsToServiceMap);
                        system.debug('subsId### '+subscription.Id);
                        for (csord__service__c service : subsToServiceMap.get(subscription.Id)) {
                            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                //terminate the loop
                                IncompleteStepId = stepId;
                                break;
                            }
                            
                            system.debug('RUNNING FOR SERVICE ==' + service.Id + '--' + service.Name + '--' + service.toBeCancelled__c);
                            system.debug('service#### '+service.csordtelcoa__Product_Configuration__r.Name);
                            /****Variables for each service to calculate its status later****/
                            Boolean isServiceToBeDisconnected = false;
                            if(service.toBeCancelled__c!=null)
                            isServiceToBeDisconnected = service.toBeCancelled__c.equalsIgnoreCase('true');
                            //Map<Id, Map<String, String>>
                            Integer countTotalFulfilmentSpec = 0;
                            Integer countTotalBillSpec = 0;
                            Integer countTotalCompFulfilmentSpec = 0;
                            Integer countTotalCompBillSpec = 0;
                            Id currTOId = (Id)serviceToAttachMap.get(service.id).get('Field_19__c');
                            /*****************************************************************/
                            
                            EDMMACServiceUtilsV2.serviceSpecDelta specDelta = new EDMMACServiceUtilsV2.serviceSpecDelta();
                            /*****TODO****/
                            //if(service.csordtelcoa__Replaced_Service__c!=null){
                            if (serviceToAttachMap != null && serviceToAttachMap.containskey(service.Id)) {
                                system.debug('YES ENTERED' +service.csordtelcoa__Replaced_Service__c);
                                if (service.csordtelcoa__Replaced_Service__c != null && (Test.isRunningTest() || processedRecordIds == null)){// || (processedRecordIds.attachmentIds != null && !processedRecordIds.attachmentIds.contains(currTOId)))) {
                                    if (service.csordtelcoa__Replaced_Service__c != null) {
                                        Map<String, String> deltaResultMap = new Map<String, String>();
                                        
                                        //System.debug('Status:::' + service.csord__Status__c + ' srvStatus :::' + srvStatus);
                                        //System.debug('Replaced Serv:::' + service.csordtelcoa__Replaced_Service__c + ' tobeCancelled :::' + service.tobecancelled__c);
                                     //   System.debug('Configuration Name :::' + service.csordtelcoa__Product_Configuration__r.Name + ' Config Type :::' + service.csordtelcoa__Product_Configuration__r.ConfigurationType1__c);
                                        
                                        if (
                                            service.csord__Status__c == srvStatus &&
                                            service.csordtelcoa__Replaced_Service__c != null &&
                                            service.tobecancelled__c != 'true' && (Test.isRunningTest() ||
                                            (service.csordtelcoa__Product_Configuration__r.Name != '' && !service.csordtelcoa__Product_Configuration__r.Name.contains('Connected Workplace Solution')) &&
                                            (service.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == '' ||
                                             service.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent')
                                        )) {
                                            //System.debug('service.Id:::' + service.Id + 'service.csordtelcoa__Replaced_Service__c ::' + service.csordtelcoa__Replaced_Service__c);
                                            String jsonspecDelta = csedm.API_1.createServiceSpecificationsDelta(service.Id, service.csordtelcoa__Replaced_Service__c);
                                            System.debug('jsonspecDelta:::' + jsonspecDelta);
                                            if (String.isNotEmpty(jsonspecDelta)) {
                                                specDelta = EDMMACServiceUtilsV2.parse(jsonspecDelta);
                                                System.debug('specDelta:::' + specDelta);
                                                if (!specDelta.changed.isEmpty()) {
                                                    deltaResultMap = getAllDeltaSpecsV2(service.Id, specDelta.changed);
                                                }
                                            }
                                        }
                                        
                                        //// String serviceattachmentstr = serviceToAttachMap.get(service.Id).attchBody.toString();
                                        ////  Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
                                        //Map<String, Object> updatedResults = (Map<String, Object>) JSON.deserializeUntyped(newServiceAttachmentStr);
                                        ////  List<Object> lstSpecifications = (List<Object>) results.get(OrchestratorConstants.ServiceSpecificationKey.Specifications);
                                        ////   List<Object> updatedSpecificationList = new List<Object>();
                                        
                                        boolean isStatusChanged = false;
                                        ////    for (Object specification : lstSpecifications) {
                                        for(Orchestration_Technical__c techObj: serviceToAttachMap.values()){
                                            ////  Map<String, Orchestration_Technical__c> specificationObject = (Map<String, Orchestration_Technical__c>) techObj;
                                            Orchestration_Technical__c specificationObject = new Orchestration_Technical__c();
                                            
                                            string code = '';
                                            string guid = '';
                                            string specStatus = '';
                                            string targetSystem = '';
                                            
                                            
                                            
                                            //// guid = (String) specificationObject.get('guid');
                                            ////  code = (String) specificationObject.get('code');
                                            ////  specStatus = (String) specificationObject.get('status');
                                            guid = techObj.Field_11__c;
                                            code = techObj.Field_14__c;
                                            specStatus=techObj.Field_3__c;
                                            targetSystem=techObj.Field_1__c;
                                            //collect the attribute value for __targetSytem
                                            ////   Map<String, Object> attributesPropertyInSpecification = (Map<String, Object>) specificationObject.get('attributes');
                                            ////  for (String currAtt : attributesPropertyInSpecification.keySet()) {
                                            ////    if (currAtt != null && currAtt != '' && attributesPropertyInSpecification.get(currAtt) instanceof String) {
                                            ////        if (currAtt.contains('__targetSystem')) {
                                            ////            targetSystem = (String) attributesPropertyInSpecification.get(currAtt);
                                            ////         }
                                            ////     }
                                            ////  }
                                            /**collect final status here***/
                                            if (isServiceToBeDisconnected) {
                                                if (specStatus != 'Created' && (targetSystem == 'FULFILMENT' || targetSystem == 'BILLING' || targetSystem == 'ASSURANCE')) {
                                                    /*if((code.contains('DMCAT_ProductSpecification_000423') || code.contains('DMCAT_ProductSpecification_000623') || code.contains('DMCAT_ProductSpecification_000622')) && (service.Action_Type__c=='PayOut' || (service.Action_Type__c!=null && service.Action_Type__c.equalsIgnoreCase('PaidOut')))){
if(targetSystem=='BILLING'){
if(service.Action_Type__c!=null && service.Action_Type__c.equalsIgnoreCase('PaidOut')){ 
specificationObject.put('status', 'Paid Out');
} else if(code.contains('DMCAT_ProductSpecification_000423')){ 
specificationObject.put('status', 'Disconnect Pending');
}
}else if(code.contains('DMCAT_ProductSpecification_000423') && service.Action_Type__c=='PayOut'){
specificationObject.put('status', 'Paid Out');
}
}commented as part of 156046 */
                                                    //156046 : Updating Billing spec to Paid Out
                                                    if (service.Action_Type__c != null && service.Action_Type__c.equalsIgnoreCase('PaidOut') && targetSystem == 'BILLING') {
                                                        //specificationObject.put('status', 'Paid Out');
                                                        specificationObject.Field_3__c = 'Paid Out';
                                                    } else if (service.Action_Type__c != null && service.Action_Type__c.equalsIgnoreCase('PayOut') && targetSystem == 'BILLING') {
                                                        specificationObject.Field_3__c = 'Disconnect Pending';
                                                    }
                                                    else if (service.Action_Type__c != null && service.Action_Type__c.equalsIgnoreCase('No Fault Return') && targetSystem == 'FULFILMENT')
                                                    {
                                                        specificationObject.Field_3__c = 'Disconnect Pending';
                                                    }//EDGE-202433 added
                                                    else if (
                                                        (code.contains('DMCAT_ProductSpecification_000423') || code.contains('DMCAT_ProductSpecification_001211') || code.contains('DMCAT_ProductSpecification_000622') || (service.Action_Type__c != null && service.Action_Type__c.equalsIgnoreCase('PayOut'))) &&
                                                        targetSystem == 'FULFILMENT'
                                                    ) {
                                                        //EDGE-163712 : for cancel or PayOut not changing fulfillment specs
                                                        //Do nothing, the fulfillment spec should stay as it is
                                                    } else if (code.contains('DMCAT_ProductSpecification_000423') && (service.Action_Type__c == 'None') && service.csordtelcoa__Product_Configuration__r.Remaining_Term__c == 0) {specificationObject.Field_3__c = 'Paid Out';
                                                                                                                                                                                                                                 } else if ((code.contains('DMCAT_ProductSpecification_000622') || code.contains('DMCAT_ProductSpecification_000423')) && service.Payment_Type__c == 'Rental') {specificationObject.Field_3__c = 'Disconnect Pending';
                                                                                                                                                                                                                                                                                                                                                                                               } else if (
                                                                                                                                                                                                                                                                                                                                                                                                   (code.contains('DMCAT_ProductSpecification_000622') || code.contains('DMCAT_ProductSpecification_000623')) &&
                                                                                                                                                                                                                                                                                                                                                                                                   service.Payment_Type__c != 'Rental' &&
                                                                                                                                                                                                                                                                                                                                                                                                   targetSystem != null &&
                                                                                                                                                                                                                                                                                                                                                                                                   targetSystem.contains('FULFILMENT') && service.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name != 'Device Outright Purchase') {specificationObject.put('status', 'Disconnected');}
                                                    else {
                                                        //EDGE-110172 Upliftment
                                                        specificationObject.put('status', 'Disconnect Pending');
                                                    }
                                                }
                                            } else {
                                                
                                                
                                                
                                                if (targetSystem == 'FULFILMENT' || targetSystem == 'BILLING') {
                                                    /*if((code.contains('DMCAT_ProductSpecification_000423')|| code.contains('DMCAT_ProductSpecification_000623') || code.contains('DMCAT_ProductSpecification_000622')) && (service.Action_Type__c=='PayOut' || (service.Action_Type__c!=null && service.Action_Type__c.equalsIgnoreCase('PaidOut')))){

if(targetSystem=='BILLING'){
if(service.Action_Type__c!=null && service.Action_Type__c.equalsIgnoreCase('PaidOut')){
specificationObject.put('status', 'Paid Out');

} else if(code.contains('DMCAT_ProductSpecification_000423')){
specificationObject.put('status', 'Disconnect Pending');

}                                
}else if(code.contains('DMCAT_ProductSpecification_000423') && service.Action_Type__c=='PayOut'){
specificationObject.put('status', 'Paid Out');
}
} commented as part of 156046*/
                                                    //156046 : Updating Billing spec to Paid Out
                                                    //Added for EDGE-179268 : PRM Action Types changes ,suspend resume ,added for change of mobile number.   
                                                    //   List<String> specCodes = new List<String>{ 'DMCAT_ProductSpecification_000263','DMCAT_ProductSpecification_000871'};
                                                    
                                                    if((service.changeType__c == 'Suspend' || service.changeType__c == 'Resume'|| service.changeType__c == 'Change of Mobile Number') && targetSystem == 'FULFILMENT' && (code.contains('DMCAT_ProductSpecification_000420')) ){specificationObject.Field_3__c = 'Modified';}
                                                    
                                                    //  specStatus = (String) specificationObject.get('status');
                                                    
                                                    if((service.changeType__c == 'Suspend' || service.changeType__c == 'Resume'|| service.changeType__c == 'Change of Mobile Number') && targetSystem == 'FULFILMENT' && (code.contains('DMCAT_ProductSpecification_000420')) ){specificationObject.Field_3__c = 'Modified';}
                                                    
                                                    //  specStatus = (String) specificationObject.get('status');
                                                    //Added if condition for DMCAT_ProductSpecification_001196 - Adaptive mobility plan - DPG -4545- Mahima                                                   
                                                    if(service.changeType__c == 'Suspend' && targetSystem == 'FULFILMENT' && ((code.contains(NGEMplanSpecCode)|| (service.csord__Service__c!=null && service.csord__Service__r.csord__Subscription__r.ConfigSpecID__c==NGEMplanSpecCode))|| code.contains('DMCAT_ProductSpecification_000263') || code.contains('DMCAT_ProductSpecification_000871')) ){specificationObject.Field_3__c = 'Suspend';}
                                                    
                                                    // specStatus = (String) specificationObject.get('status');
                                                    //Added if condition for DMCAT_ProductSpecification_001196 - Adaptive mobility plan - DPG -4545- Mahima 
                                                    else if(service.changeType__c == 'Resume' && targetSystem == 'FULFILMENT' ) {
                                                        
                                                        if((code.contains(NGEMplanSpecCode) || (service.csord__Service__c!=null && service.csord__Service__r.csord__Subscription__r.ConfigSpecID__c==NGEMplanSpecCode)) &&  service.csord__Subscription__r.Suspension_reason_summary__c==''){ specificationObject.Field_3__c =  'Resume';}
                                                        else if(code.contains('DMCAT_ProductSpecification_000263') || code.contains('DMCAT_ProductSpecification_000871')){ specificationObject.Field_3__c = 'Resume';}
                                                    }
                                                    
                                                    //Added for EDGE-179268 : PRM Action Types changes for change of mobile number.
                                                    else if(service.changeType__c == 'Change of Mobile Number' && targetSystem == 'FULFILMENT' && code.contains('DMCAT_ProductSpecification_000263')){specificationObject.Field_3__c = 'Modified';}
                                                    
                                                    //End of EDGE-179268 chanegs
                                                    else if (service.Action_Type__c != null && service.Action_Type__c.equalsIgnoreCase('No Fault Return') && targetSystem == 'FULFILMENT')
                                                    {
                                                        specificationObject.Field_3__c = 'Disconnect Pending';
                                                    }//EDGE-202433 added
                                                    else if (service.Action_Type__c != null && service.Action_Type__c.equalsIgnoreCase('PayOut') && targetSystem == 'FULFILMENT') {
                                                        //Do nothing, the fulfillment spec should stay as it is
                                                    } else if (service.Action_Type__c != null && service.Action_Type__c.equalsIgnoreCase('PaidOut') && targetSystem == 'BILLING') {
                                                        //updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Paid Out');
                                                        specificationObject.Field_3__c = 'Paid Out';
                                                    } else if (service.Action_Type__c != null && service.Action_Type__c.equalsIgnoreCase('PayOut') && targetSystem == 'BILLING') {
                                                        //EDGE-163712
                                                        specificationObject.Field_3__c = 'Disconnect Pending';
                                                    } 
                                                    else if(service.csord__Order__r.Product_Basket__r.BasketType__c!= null && service.csord__Order__r.Product_Basket__r.BasketType__c.equalsignorecase('Incoming')&& targetSystem == 'FULFILMENT'){
                                                        //EDGE-152473 & EDGE-216816
                                                        
                                                        if(code.contains('DMCAT_ProductSpecification_001211_Fulfilment')||code.contains('DMCAT_ProductSpecification_001389_Fulfilment')||code.contains('DMCAT_ProductSpecification_001342_Fulfilment')||code.contains('DMCAT_ProductSpecification_001455_Fulfilment'))//  EDGE-216816 : added condition for spec status change  of  chown device and accessories order
                                                        {
                                                            specificationObject.Field_3__c = 'Complete'; 
                                                        }
                                                        else{
                                                            specificationObject.Field_3__c = 'Modified'; }
                                                    }
                                                    else if (code.contains('DMCAT_ProductSpecification_000423') && (service.Action_Type__c == 'None') && service.csordtelcoa__Product_Configuration__r.Remaining_Term__c == 0) {
                                                        specificationObject.Field_3__c =  'Paid Out';
                                                    } else if ((code.contains('DMCAT_ProductSpecification_000622') || code.contains('DMCAT_ProductSpecification_000423')) && service.Payment_Type__c != service.csordtelcoa__Replaced_Service__r.Payment_Type__c && service.Payment_Type__c == 'Rental') {
                                                        specificationObject.Field_3__c = 'Disconnect Pending';
                                                    } else if (deltaResultMap != null && deltaResultMap.containsKey(guid)) {
                                                        specificationObject.Field_3__c =  deltaResultMap.get(guid);
                                                    }
                                                } else if (deltaResultMap != null && deltaResultMap.containsKey(guid)) {
                                                    specificationObject.Field_3__c =  deltaResultMap.get(guid);
                                                }
                                            }
                                            system.debug ('==Mod Service=='+specificationObject);
                                            /**if status has changed, then collect**/
                                            ////String finalStatus = (String) specificationObject.get('status');
                                            String finalStatus = specificationObject.Field_3__c;
                                            system.debug(specStatus + '==original==vs==actual==' + finalStatus);
                                            if (targetSystem == 'FULFILMENT') {
                                                countTotalFulfilmentSpec += 1;
                                                countTotalFulfilmentSpecSub += 1;
                                                if (finalStatus == Label.Complete || finalStatus == 'Paid Out' || finalStatus == 'Disconnected') {
                                                    countTotalCompFulfilmentSpec += 1;
                                                    countTotalCompFulfilmentSpecSub += 1;
                                                }
                                            } else if (targetSystem == 'BILLING') {
                                                countTotalBillSpec += 1;
                                                countTotalBillSpecSub += 1;
                                                if (finalStatus == Label.Complete || finalStatus == 'Paid Out' || finalStatus == 'Disconnected') {
                                                    countTotalCompBillSpec += 1;
                                                    countTotalCompBillSpecSub += 1;
                                                }
                                            }
                                            if (specStatus != finalStatus) {
                                                isStatusChanged = true;
                                            }
                                            //// updatedSpecificationList.add((Object) specificationObject);
                                            attachmentsToUpdate.put(specificationObject.Id,specificationObject);
                                        }
                                        
                                        system.debug ('==Mod Service=='+attachmentsToUpdate);
                                        
                                        /********IF no status changed, then dont update attachment*********************************/
                                        //if (isStatusChanged && !updatedSpecificationList.isEmpty()) {
                                        if (isStatusChanged && !attachmentsToUpdate.isEmpty()) {
                                            /* results.put(OrchestratorConstants.ServiceSpecificationKey.Specifications, updatedSpecificationList);
String updatednewServiceattachmentstr = JSON.serializePretty(results);
Attachment UpdatedServSpec = new Attachment(Id = serviceToAttachMap.get(service.Id).attchId);
UpdatedServSpec.Body = Blob.valueOf(updatednewServiceattachmentstr);
attachmentsToUpdate.put(UpdatedServSpec.Id, UpdatedServSpec);*/
                                            ////   Id currTOId = (Id)serviceToAttachMap.get(service.id).get('Field_19__c');
                                            if (!stepRelationshipMap.containsKey(stepId)) {
                                                stepRelationshipMap.put(stepId, new Set<Id>{ currTOId });
                                            } else {
                                                stepRelationshipMap.get(stepId).add(currTOId);
                                            }
                                        }
                                    }
                                } else {
                                    //if attachment already updated in previous batch iterations or transactions
                                    string code = '';
                                    string guid = '';
                                    string specStatus = '';
                                    string targetSystem = '';
                                    ////   String serviceattachmentstr = serviceToAttachMap.get(service.Id).attchBody.toString();
                                    ////    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
                                    //Map<String, Object> updatedResults = (Map<String, Object>) JSON.deserializeUntyped(newServiceAttachmentStr);
                                    ////    List<Object> lstSpecifications = (List<Object>) results.get(OrchestratorConstants.ServiceSpecificationKey.Specifications);
                                    //// List<Object> updatedSpecificationList1 = new List<Object>();
                                    boolean isStatusChanged = false;
                                    for(Orchestration_Technical__c techObj: serviceToAttachMap.values()){
                                        ////  Map<String, Orchestration_Technical__c> specificationObject = (Map<String, Orchestration_Technical__c>) techObj;
                                        Orchestration_Technical__c specificationObject = new Orchestration_Technical__c();
                                        //// guid = (String) specificationObject.get('guid');
                                        ////  code = (String) specificationObject.get('code');
                                        ////  specStatus = (String) specificationObject.get('status');
                                        guid = techObj.Field_11__c;
                                        code = techObj.Field_14__c;
                                        specStatus=techObj.Field_3__c;
                                        targetSystem=techObj.Field_1__c;
                                        
                                        //// for (Object specification : lstSpecifications) {
                                        ////       Map<String, Object> specificationObject = (Map<String, Object>) specification;
                                        
                                        //  string specStatus = '';
                                        //  string targetSystem = '';
                                        ////specStatus = (String) specificationObject.get('status');
                                        //// Map<String, Object> attributesPropertyInSpecification = (Map<String, Object>) specificationObject.get('attributes');
                                        ////   for (String currAtt : attributesPropertyInSpecification.keySet()) {
                                        ////        if (currAtt != null && currAtt != '' && attributesPropertyInSpecification.get(currAtt) instanceof String) {
                                        ////             if (currAtt.contains('__targetSystem')) {
                                        ////                targetSystem = (String) attributesPropertyInSpecification.get(currAtt);
                                        ////             }
                                        ////         }
                                        ////}
                                        
                                        ////     guid = (String) specificationObject.get('guid');
                                        ////      code = (String) specificationObject.get('code');
                                        ////      specStatus = (String) specificationObject.get('status'); 
                                        
                                        if (targetSystem == 'FULFILMENT' || targetSystem == 'BILLING') {
                                            //Added for EDGE-179268 : PRM Action Types changes ,suspend resume
                                            
                                            if((service.changeType__c == 'Suspend' || service.changeType__c == 'Resume' || service.changeType__c == 'Change of Mobile Number') && targetSystem == 'FULFILMENT' && (code.contains('DMCAT_ProductSpecification_000420'))){ specificationObject.Field_3__c = 'Modified';}
                                            
                                            //  specStatus = (String) specificationObject.get('status');                                                    
                                            // Added Codition for code.contains('DMCAT_ProductSpecification_001196') For Adaptive mobility Plan- DPG- 4545- Mahima 
                                            
                                            if(service.changeType__c == 'Suspend' && targetSystem == 'FULFILMENT' && ((code.contains(NGEMplanSpecCode)|| (service.csord__Service__c!=null && service.csord__Service__r.csord__Subscription__r.ConfigSpecID__c==NGEMplanSpecCode)) || code.contains('DMCAT_ProductSpecification_000263') || code.contains('DMCAT_ProductSpecification_000871'))) {specificationObject.Field_3__c = 'Suspend';}
                                            
                                            // specStatus = (String) specificationObject.get('status');
                                            //Added if condition for DMCAT_ProductSpecification_001196 - Adaptive mobility plan - DPG -4545- Mahima 
                                            else if(service.changeType__c == 'Resume' && targetSystem == 'FULFILMENT' ){
                                                
                                                if((code.contains(NGEMplanSpecCode)|| (service.csord__Service__c!=null && service.csord__Service__r.csord__Subscription__r.ConfigSpecID__c==NGEMplanSpecCode)) ){ specificationObject.Field_3__c = 'Resume';}
                                                
                                                else if(code.contains('DMCAT_ProductSpecification_000263') || code.contains('DMCAT_ProductSpecification_000871')){ specificationObject.Field_3__c ='Resume';}
                                            }
                                            //  specStatus = (String) specificationObject.get('status');
                                            
                                            //Added for EDGE-179268 : PRM Action Types changes for change of mobile number.
                                            else if(service.changeType__c == 'Change of Mobile Number' && targetSystem == 'FULFILMENT' && code.contains('DMCAT_ProductSpecification_000263')){specificationObject.Field_3__c = 'Modified';}
                                            
                                            //End of EDGE-179268 chanegs
                                        }
                                        system.debug( '==original Service=='+specificationObject);
                                        ////  String finalStatus = (String) specificationObject.get('status');
                                        String finalStatus = specificationObject.Field_3__c;
                                        system.debug(specStatus + '==original==vs==actual==' + finalStatus);
                                        //system.debug(specStatus + '==original==');
                                        if (targetSystem == 'FULFILMENT') {
                                            //system.debug(specStatus + '==original FULFIL==');
                                            countTotalFulfilmentSpec += 1;
                                            countTotalFulfilmentSpecSub += 1;
                                            if (finalStatus == Label.Complete || finalStatus == 'Paid Out' || finalStatus == 'Disconnected') {
                                                countTotalCompFulfilmentSpec += 1;
                                                countTotalCompFulfilmentSpecSub += 1;
                                            }
                                        } else if (targetSystem == 'BILLING') {
                                            //system.debug(specStatus + '==original BILL==');
                                            countTotalBillSpec += 1;
                                            countTotalBillSpecSub += 1;
                                            if (finalStatus == Label.Complete || finalStatus == 'Paid Out' || finalStatus == 'Disconnected') {
                                                countTotalCompBillSpec += 1;
                                                countTotalCompBillSpecSub += 1;
                                            }
                                            
                                            
                                        }
                                        if (specStatus != finalStatus) {isStatusChanged = true;}
                                        //// updatedSpecificationList1.add((Object) specificationObject);
                                        attachmentsToUpdate.put(specificationObject.Id,specificationObject);
                                    } //lstSpecifications for closed
                                    
                                    system.debug('==original Service=='+attachmentsToUpdate);
                                    /********IF no status changed, then dont update attachment*********************************/
                                    if (isStatusChanged && !attachmentsToUpdate.isEmpty()) {
                                        ////     results.put(OrchestratorConstants.ServiceSpecificationKey.Specifications, updatedSpecificationList1);
                                        ////      String updatednewServiceattachmentstr = JSON.serializePretty(results);
                                        ////     Attachment UpdatedServSpec = new Attachment(Id = serviceToAttachMap.get(service.Id).attchId);
                                        ////     UpdatedServSpec.Body = Blob.valueOf(updatednewServiceattachmentstr);
                                        ////      attachmentsToUpdate.put(UpdatedServSpec.Id, UpdatedServSpec);
                                        ////    Id currTOId = (Id)serviceToAttachMap.get(service.id).get('Field_19__c');
                                        if (!stepRelationshipMap.containsKey(stepId)) {stepRelationshipMap.put(stepId, new Set<Id>{ currTOId });
                                                                                      } else {stepRelationshipMap.get(stepId).add(currTOId);
                                                                                             }
                                    }
                                }//New order else close
                            }//
                            
                            //}
                            
                            /*************************LOGICAL BLOCK FOR SERVICE STATUS*********************************************/
                            /*if (Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()) {
//terminate the loop
IncompleteStepId = step.Id;
break;
}*/                       //already commented limits
                            system.debug(
                                'all counters serially ------ ' +
                                service.Name +
                                '-BSTot-' +
                                countTotalBillSpec +
                                '-BSSubTOT-' +
                                countTotalBillSpecSub +
                                '-BSCom-' +
                                countTotalCompBillSpec +
                                '-BSSCOpSub-' +
                                countTotalCompBillSpecSub +
                                '-FSTot-' +
                                countTotalFulfilmentSpec +
                                '-FSSubTOT-' +
                                countTotalFulfilmentSpecSub +
                                '-FSSCOp-' +
                                countTotalCompFulfilmentSpec +
                                '-FSSCOpSub-' +
                                countTotalCompFulfilmentSpecSub
                            );
                            system.debug('isPartnerDeliveredOffer*' +isPartnerDeliveredOffer + 'countTotalFulfilmentSpec* ' +countTotalFulfilmentSpec + 'service.csordtelcoa__Replaced_Service__c* ' +service.csordtelcoa__Replaced_Service__c + 'markServicesConnected* ' +markServicesConnected);
                            system.debug('ActionType '+service.Action_Type__c);
                            if (service.Action_Type__c != null && service.Action_Type__c == 'PaidOut') {
                                if (service.csord__Status__c != 'Paid Out') {
                                    service.csord__Status__c = 'Paid Out';
                                    servicesToUpdate.put(service.Id, service);
                                    if (!stepRelationshipMap.containsKey(stepId)) {stepRelationshipMap.put(stepId, new Set<Id>{ service.Id });}
                                    else {
                                        stepRelationshipMap.get(stepId).add(service.Id);
                                    }
                                }
                            } else if (service.Action_Type__c != null && service.Action_Type__c == 'PayOut') {
                                //EDGE-163712 : Setting service status to 'Connected' for Payout because it will not go for fulfillment
                                if (service.csord__Status__c != 'Connected') {
                                    service.csord__Status__c = 'Connected';
                                    servicesToUpdate.put(service.Id, service);
                                    if (!stepRelationshipMap.containsKey(stepId)) { stepRelationshipMap.put(stepId, new Set<Id>{ service.Id });}
                                    else {  stepRelationshipMap.get(stepId).add(service.Id);}
                                    
                                }
                            }
                            
                            /*Start-EDGE-208435-Dheeraj Bhatt-Enhance Subscription orchestration process steps to hold Right to Bill trigger for migration MRO subscription.*/
                            //else if (service.changeType__c != null && service.changeType__c == 'Migration' && service.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c =='DMCAT_ProductSpecification_001342'){
                            else if(!serviceMicaDependencyMap.isEmpty() && serviceMicaDependencyMap.containsKey(service.id)){
                                //EDGE-194053 : Setting service status to 'Connected' for Miration order
                                if (service.csord__Status__c != 'Connected') {
                                    service.csord__Status__c = 'Connected';
                                    servicesToUpdate.put(service.Id, service);
                                    if (!stepRelationshipMap.containsKey(stepId)) { 
                                        stepRelationshipMap.put(stepId, new Set<Id>{ service.Id });
                                    }
                                    else { 
                                        stepRelationshipMap.get(stepId).add(service.Id);
                                    }
                                }
                            }
                            /* End-EDGE-208435 */
                            else if (isServiceToBeDisconnected) {
                                if (
                                    (!isPartnerDeliveredOffer && (countTotalFulfilmentSpec == 0 || (countTotalFulfilmentSpec != 0 && countTotalCompFulfilmentSpec == countTotalFulfilmentSpec)) && (countTotalBillSpec != 0 && countTotalBillSpec != countTotalCompBillSpec)) &&
                                    subscription.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name != 'Device Outright Purchase'
                                ) {
                                    if (service.csord__Status__c != 'Disconnected') {
                                        service.csord__Status__c = 'Disconnected';
                                        servicesToUpdate.put(service.Id, service);
                                        if (!stepRelationshipMap.containsKey(stepId)) {stepRelationshipMap.put(stepId, new Set<Id>{ service.Id });
                                                                                      } else {stepRelationshipMap.get(stepId).add(service.Id);
                                                                                             }
                                    }
                                } else if (service.csord__Status__c != 'Disconnect Pending') {
                                    if (isPartnerDeliveredOffer){service.csord__Status__c = 'Disconnected';}
                                    
                                    
                                    else
                                    {
                                        service.csord__Status__c = 'Disconnect Pending';
                                    }
                                    servicesToUpdate.put(service.Id, service);
                                    if (!stepRelationshipMap.containsKey(stepId)) {
                                        stepRelationshipMap.put(stepId, new Set<Id>{ service.Id });
                                    } else {
                                        stepRelationshipMap.get(stepId).add(service.Id);
                                    }
                                }
                                
                                
                            } 
                            else if ((!isPartnerDeliveredOffer && countTotalFulfilmentSpec == 0) || (service.csordtelcoa__Replaced_Service__c != null && countTotalFulfilmentSpec == 0)|| markServicesConnected ) {
                                //system.debug('==DID I ENTER HERE==' + countTotalFulfilmentSpec);
                                if(service.csord__Subscription__r.MarketableOffer__c != null && service.csord__Subscription__r.MarketableOffer__r.Offer_ID__c != null && System.label.SvcSubsStatusClosed.contains(service.csord__Subscription__r.MarketableOffer__r.Offer_ID__c)){
                                    //EDGE-177027
                                    //Do nothing : do not update status of solution service to Connected for blank SIM offer 
                                }
                                else if (service.csord__Status__c != 'Connected') {
                                    service.csord__Status__c = 'Connected';
                                    servicesToUpdate.put(service.Id, service);
                                    if (!stepRelationshipMap.containsKey(stepId)) {
                                        stepRelationshipMap.put(stepId, new Set<Id>{ service.Id });
                                    } else {
                                        stepRelationshipMap.get(stepId).add(service.Id);
                                    }
                                }
                                // MS modify DPG-4370: Ila
                                if(Test.isRunningTest() || (service.csord__Subscription__r.MarketableOffer__r.Offer_ID__c== System.Label.ManagedService_MarketableOfferId && service.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' && service.csordtelcoa__Replaced_Service__c!=null && service.csord__Status__c == 'Connected' )){
                                    service.csord__Subscription__r.csord__Status__c = 'Provisioned'; 
                                    service.csord__Subscription__r.triggerBill_RTB__c = true; //Making true as part of sol suppress 
                                    subsToUpdate.put(service.csord__Subscription__c,  service.csord__Subscription__r);
                                    system.debug('subsToUpdate*' +subsToUpdate); 
                                    if (!stepRelationshipMap.containsKey(stepId)) {
                                        stepRelationshipMap.put(stepId, new Set<Id>{ service.csord__Subscription__c });
                                    } else {
                                        stepRelationshipMap.get(stepId).add(service.csord__Subscription__c);
                                    }
                                }
                                //MS modify end DPG-4370: Ila
                                
                            } else if (!isPartnerDeliveredOffer && (countTotalFulfilmentSpec != 0 && countTotalFulfilmentSpec == countTotalCompFulfilmentSpec) && (countTotalBillSpec == 0 || (countTotalBillSpec != 0 && countTotalBillSpec == countTotalCompBillSpec))) {
                                if (service.Action_Type__c == 'None' && service.csordtelcoa__Product_Configuration__c != null && service.csordtelcoa__Product_Configuration__r.Remaining_Term__c != null && service.csordtelcoa__Product_Configuration__r.Remaining_Term__c == 0) {
                                    if (service.csord__Status__c != 'Paid Out') {
                                        service.csord__Status__c = 'Paid Out';
                                        servicesToUpdate.put(service.Id, service);
                                        if (!stepRelationshipMap.containsKey(stepId)) {
                                            stepRelationshipMap.put(stepId, new Set<Id>{ service.Id });
                                        } else {
                                            stepRelationshipMap.get(stepId).add(service.Id);
                                        }
                                    }
                                } else {
                                    if (service.csord__Status__c != 'Connected' /*service.csordtelcoa__Replaced_Service__r.csord__Status__c*/) {
                                        service.csord__Status__c = 'Connected' /*service.csordtelcoa__Replaced_Service__r.csord__Status__c*/;
                                        servicesToUpdate.put(service.Id, service);
                                        if (!stepRelationshipMap.containsKey(stepId)) {
                                            stepRelationshipMap.put(stepId, new Set<Id>{ service.Id });
                                        } else {
                                            stepRelationshipMap.get(stepId).add(service.Id);
                                        }
                                    }
                                }
                            } else if (!isPartnerDeliveredOffer && countTotalFulfilmentSpec != 0 && ((countTotalCompFulfilmentSpec != countTotalFulfilmentSpec) || ((countTotalCompFulfilmentSpec != countTotalFulfilmentSpec) && countTotalBillSpec != countTotalCompBillSpec))) {
                                if (service.csord__Status__c != 'Pending') {
                                    service.csord__Status__c = 'Pending';
                                    servicesToUpdate.put(service.Id, service);
                                    if (!stepRelationshipMap.containsKey(stepId)) {
                                        stepRelationshipMap.put(stepId, new Set<Id>{ service.Id });
                                    } else {
                                        stepRelationshipMap.get(stepId).add(service.Id);
                                    }
                                }
                            } else if (!isPartnerDeliveredOffer && countTotalFulfilmentSpec != 0 && countTotalCompFulfilmentSpec == countTotalFulfilmentSpec && (countTotalBillSpec != 0 && countTotalBillSpec != countTotalCompBillSpec)) {
                                if (service.toBeCancelled__c == 'true' && subscription.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name != 'Device Outright Purchase') {
                                    if (service.csord__Status__c != 'Disconnected') {
                                        service.csord__Status__c = 'Disconnected';
                                        servicesToUpdate.put(service.Id, service);
                                        if (!stepRelationshipMap.containsKey(stepId)) {
                                            stepRelationshipMap.put(stepId, new Set<Id>{ service.Id });
                                        } else {stepRelationshipMap.get(stepId).add(service.Id);}
                                    }
                                } else {
                                    if (service.csord__Status__c != 'Connected') {
                                        service.csord__Status__c = 'Connected';
                                        servicesToUpdate.put(service.Id, service);
                                        if (!stepRelationshipMap.containsKey(stepId)) {
                                            stepRelationshipMap.put(stepId, new Set<Id>{ service.Id });
                                        } else {
                                            stepRelationshipMap.get(stepId).add(service.Id);
                                        }
                                    }
                                }
                            }
                            //EDGE - 156046
                            if (service.csord__status__c == 'Paid Out') {
                                servicesPaidOutCount += 1;
                                if (service.csord__Service__c == null) {
                                    isParentSVCPaidOut = true; //EDGE-164355
                                }
                            } else if (service.csord__status__c == 'Connected' || service.Action_Type__c == 'PayOut') {
                                servicesConnectedCount += 1; //EDGE-163712
                                if (service.Action_Type__c == 'PayOut') {
                                    servicesPayOutCount += 1;
                                }
                            } else if (service.csord__status__c == 'Disconnected') { servicesDisconnectedCount += 1;} //EDGE-163712
                            
                            
                            
                            /******************************************************************************************************/
                        }
                        
                        /****************LOGICAL BLOCK FOR SUB STATUS**************************************************************/
                        /*************************LOGICAL BLOCK FOR SERVICE STATUS*********************************************/
                        /*if (Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()) {
//terminate the loop
IncompleteStepId = step.Id;
break;
}*/
                        //already commented limits
                        
                        /*Start-EDGE-208435-Dheeraj Bhatt-Enhance Subscription orchestration process steps to hold Right to Bill trigger for migration MRO subscription.*/
                        if(!subscriptionMicaDependencyMap.isEmpty() && subscriptionMicaDependencyMap.containsKey(subscription.Id)){
                            subscription.csord__Status__c = 'Provisioned';  
                            subscription.triggerBill_RTB__c = true;
                            subsToUpdate.put(subscription.Id, subscription);
                            if (!stepRelationshipMap.containsKey(stepId)) {
                                stepRelationshipMap.put(stepId, new Set<Id>{ subscription.Id });
                            }
                            else {stepRelationshipMap.get(stepId).add(subscription.Id); 
                                 }
                            
                        }  /* END-EDGE-208435 */
                        else if (subsToServiceMap.get(subscription.Id).size() == servicesPaidOutCount || isParentSVCPaidOut) {  //EDGE - 156046
                            //EDGE-164355 : If parent svc is PaidOut then making subs PaidOut : done for device care
                            if (subscription.csord__Status__c != 'Paid Out') {
                                subscription.csord__Status__c = 'Paid Out';
                                subsToUpdate.put(subscription.Id, subscription);
                                if (!stepRelationshipMap.containsKey(stepId)) {
                                    stepRelationshipMap.put(stepId, new Set<Id>{ subscription.Id });
                                } else {
                                    stepRelationshipMap.get(stepId).add(subscription.Id);
                                }
                            }
                        } else if (!isPartnerDeliveredOffer && subscription.csord__Status__c != 'Paid Out' && servicesPayOutCount == 0) {
                            //EDGE-163712  :servicesPayOutCount == 0 : subs should not move to active if any of the svc is PayOut
                            
                            if ((countTotalFulfilmentSpecSub == 0 || (countTotalFulfilmentSpecSub == countTotalCompFulfilmentSpecSub)) && (countTotalBillSpecSub == 0 || (countTotalBillSpecSub == countTotalCompBillSpecSub))) {
                                if (subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent') {
                                    if (subscription.csord__Status__c != 'Active'&& subscription.csordtelcoa__Replaced_Subscription__c != null) { //svt fix
                                        System.debug('subscription' + subscription.Id);
                                        System.debug('countTotalFulfilmentSpecSub' + countTotalFulfilmentSpecSub);
                                        System.debug('countTotalCompFulfilmentSpecSub' + countTotalCompFulfilmentSpecSub);
                                        System.debug('countTotalBillSpecSub' + countTotalBillSpecSub);
                                        System.debug('countTotalCompBillSpecSub' + countTotalCompBillSpecSub);
                                        subscription.csord__Status__c = 'Active';
                                        // Added by Nikhil as part of EDGE-226305
                                        Id solutionsubscriptionId = null;
                                        if(solutionSubscriptionMap.size() > 0 && solutionSubscriptionMap.ContainsKey(subscription.cssdm__solution_association__c)){
                                            solutionsubscriptionId = solutionSubscriptionMap.get(subscription.cssdm__solution_association__c);
                                            csord__Subscription__c solutionSubscription = solutionsubscriptionId !=null && subsToUpdate.containsKey(solutionsubscriptionId) ? 
                                                subsToUpdate.get(solutionsubscriptionId) : new csord__Subscription__c(Id = solutionsubscriptionId);
                                            solutionSubscription.csord__Status__c = 'Active';
                                            subsToUpdate.put(solutionSubscription.Id, solutionSubscription);
                                            
                                        }
                                        subsToUpdate.put(subscription.Id, subscription);
                                        if (!stepRelationshipMap.containsKey(stepId)) {
                                            stepRelationshipMap.put(stepId, new Set<Id>{ subscription.Id });
                                            // Added by Nikhil as part of EDGE-226305
                                            if(solutionsubscriptionId !=null){
                                                stepRelationshipMap.get(stepId).add(solutionsubscriptionId);
                                            }
                                        } else {
                                            stepRelationshipMap.get(stepId).add(subscription.Id);
                                            // Added by Nikhil as part of EDGE-226305
                                            if(solutionsubscriptionId !=null){
                                                stepRelationshipMap.get(stepId).add(solutionsubscriptionId);
                                            }
                                        }
                                    }
                                    //subscription.csord__Status__c = 'Active';
                                } else {
                                    
                                    if((subscription.MarketableOffer__c != null && subscription.MarketableOffer__r.Offer_ID__c != null && System.label.SvcSubsStatusClosed.contains(subscription.MarketableOffer__r.Offer_ID__c)) || (System.label.Adaptive_Mobility_Offer_Id.contains(subscription.ConfigSpecID__c) && subscription.csordtelcoa__Replaced_Subscription__c == null )|| (System.label.CMP_Offer_Id.contains(subscription.ConfigSpecID__c) && subscription.csordtelcoa__Replaced_Subscription__c == null )){
                                        
                                        //EDGE-177027
                                        //Do nothing : do not update status of solution subscription to Provisioned for blank SIM offer 
                                        // OR
                                        //Do nothing : for CMP and AM Solution Subscription - EDGE-132434
                                        // and it should be base Order - added condition to check for replaced subscription - EDGE-202032
                                        system.debug('inside==');
                                        
                                    }
                                    //TODO sol suppress : status of sol subs check below
                                    else if (subscription.csord__Status__c != 'Provisioned') {
                                        subscription.csord__Status__c = 'Provisioned';
                                        subsToUpdate.put(subscription.Id, subscription);
                                        if (!stepRelationshipMap.containsKey(stepId)) { stepRelationshipMap.put(stepId, new Set<Id>{ subscription.Id }); }
                                        
                                        else {stepRelationshipMap.get(stepId).add(subscription.Id);}  }
                                    
                                    //subscription.csord__Status__c = 'Provisioned';
                                }
                            } else if ((countTotalFulfilmentSpecSub != 0 && (countTotalFulfilmentSpecSub != countTotalCompFulfilmentSpecSub)) && (countTotalBillSpecSub == 0 || (countTotalBillSpecSub != 0 && (countTotalBillSpecSub != countTotalCompBillSpecSub)))) {
                                if (subscription.csord__Status__c != 'Pending') {
                                    subscription.csord__Status__c = 'Pending';
                                    subsToUpdate.put(subscription.Id, subscription);
                                    if (!stepRelationshipMap.containsKey(stepId)) {
                                        stepRelationshipMap.put(stepId, new Set<Id>{ subscription.Id });
                                    } else {
                                        stepRelationshipMap.get(stepId).add(subscription.Id);
                                    }
                                } else {
                                    if (!stepRelationshiptoSkipMap.containsKey(stepId)) {
                                        stepRelationshiptoSkipMap.put(stepId, new Set<String>{ subscription.Id }); }
                                    else {stepRelationshiptoSkipMap.get(stepId).add(subscription.Id);}
                                }
                            } else if ((countTotalFulfilmentSpecSub == 0 || (countTotalFulfilmentSpecSub != 0 && countTotalFulfilmentSpecSub == countTotalCompFulfilmentSpecSub)) && (countTotalBillSpecSub != 0 && (countTotalBillSpecSub != countTotalCompBillSpecSub))) {
                                if (subscription.csord__Status__c != 'Provisioned') {
                                    subscription.csord__Status__c = 'Provisioned';
                                    //Sol suppress : making triggerBill_RTB true when subs gets provisioned
                                    if(!subscription.toBeCancelled__c.equalsIgnoreCase('true')){
                                        subscription.triggerBill_RTB__c = true;
                                    }
                                    if (
                                        subscription.Trigger_RTS__c != true &&
                                        (subscription.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c == 'DMCAT_ProductSpecification_000622' ||
                                         subscription.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c == 'DMCAT_ProductSpecification_000623') &&
                                        subscription.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name != 'Device Outright Purchase'
                                    ) {
                                        subscription.Trigger_RTS__c = true;
                                    }
                                    subsToUpdate.put(subscription.Id, subscription);
                                    if (!stepRelationshipMap.containsKey(stepId)) {stepRelationshipMap.put(stepId, new Set<Id>{ subscription.Id }); }
                                    
                                    else {
                                        stepRelationshipMap.get(stepId).add(subscription.Id);
                                    }
                                }
                            }
                            
                            //else if not partnerdelivererOffer
                        } else if (subsToServiceMap.get(subscription.Id).size() == (servicesConnectedCount + servicesDisconnectedCount + servicesPaidOutCount)) {
                            //EDGE-163712  : If all the services on subscription are Paid Out, Connected/PayOut Or Disconnected then moving subscription to Provisioned
                            if (subscription.csord__Status__c != 'Provisioned' && (subscription.MarketableOffer__r.Offer_ID__c!=System.Label.ManagedService_MarketableOfferId && subscription.MarketableOffer__r.Offer_ID__c!=System.Label.ProfessionalService_MarketableOfferId)) {
                                subscription.csord__Status__c = 'Provisioned';
                                if (subscription.toBeCancelled__c == 'true') {
                                    //EDGE-163712 : if cease subs orch process is created then setting trigger_RTS to true
                                    if ((!subscription.Trigger_RTS__c)) {
                                        subscription.Trigger_RTS__c = true;
                                    }
                                }
                                else{//Sol suppress 
                                    subscription.triggerBill_RTB__c = true;
                                }
                                subsToUpdate.put(subscription.Id, subscription);
                                if (!stepRelationshipMap.containsKey(stepId)) {stepRelationshipMap.put(stepId, new Set<Id>{ subscription.Id }); }
                                
                                else {
                                    stepRelationshipMap.get(stepId).add(subscription.Id);
                                }
                            }
                        }
                        
                        /******************************************************************************************************/
                    } //added for cpu limits
                    updatedSubsList.add(subscription);
                }
                
                /**********LOGICAL BLOCK FOR ORDER SKIP FULFILMENT UPDATE*********************/
                if (Orchestration_LimitsUtility.areLimitsViolated()) {
                    //terminate the loop
                    IncompleteStepId = stepId;
                    //  break;
                }
                if (IncompleteStepId == null || IncompleteStepId != stepId) {
                    for (csord__subscription__c subs : updatedSubsList) {
                        if (subs.csord__Status__c == 'Pending' || subs.csord__Status__c == 'Provisioning In Progress' || subs.csord__Status__c == 'Disconnect Pending' || subs.csord__Status__c == 'Disconnect in Progress') {
                            SkipFulfilmet = false;
                            break;
                            // Added by Nikhil as part of EDGE-222787
                        }else{
                            if (subs.ConfigSpecId__c == 'DMCAT_ProductSpecification_000871'){
                                SkipFulfilmet = false;
                                break;
                            }
                        }
                    }
                    
                    if (SkipFulfilmet) {
                        for(csord__Order__c ord:orderList){
                            if (!ord.skipFulfillment__c) {
                                ord.skipFulfillment__c = true;
                                updateOrderMap.put(ord.Id, ord);
                                if (!stepRelationshipMap.containsKey(stepId)) { stepRelationshipMap.put(stepId, new Set<Id>{ ord.Id });}
                                
                                else {
                                    stepRelationshipMap.get(stepId).add(ord.Id);
                                }
                            }
                        }
                    }
                    if (!stepRelationshipMap.containsKey(stepId)) {
                        
                        
                        system.debug('processedIds.get(step.Id)'+processedIds.get(stepId));
                        //system.debug('processedIds.get(step.Id).subsIds.isempty()'+processedIds.get(step.Id).subsIds.isempty());
                        //system.debug('processedIds.get(step.Id).attachmentIds.isempty()'+processedIds.get(step.Id).attachmentIds.isempty());
                        
                        
                        if (processedRecordIds == null || processedRecordIds.subsIds.isempty() && processedRecordIds.attachmentIds.isempty()) {
                            //// stepResults.put(stepId, new stepResult('Success - No update required as no data needed any update for this step', OrchestratorConstants.OrchestratorStep.Complete));
                            mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success - No update required as no data needed any update for this step',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                            
                        } else {
                            ////stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                            mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Records processed',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                            
                        }
                    }
                    
                    
                }
                
                /**************************************************************************/
            } catch (Exception ex) {
                //// stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error,StackTrace__c=ex.getStackTraceString()));
            }
            ////}
        } catch (Exception ex) {
            ////  for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
            ////   stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            //// }
            
            mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error,StackTrace__c=ex.getStackTraceString()));
            
        }
        
        if (!subsToUpdate.isEmpty() || !attachmentsToUpdate.isEmpty() || !servicesToUpdate.isEmpty() || !updateOrderMap.isEmpty() || !stepRelationshiptoSkipMap.isEmpty()) {
            updateObjects();
        }
        Coms_OrderParallelismUtil.updateStepStatus(mapStepDetails);
        
        // return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
    
    
    private class specList {
        private String guid;
        //private String serviceId;
        private String status;
    }
    
    public Map<String, String> getAllDeltaSpecsV2(String srvId, List<EDMMACServiceUtilsV2.deltaDTO> specs) {
        Map<String, String> specsToUpdate = new Map<String, String>();
        
        //Iteration over the changes between the service and replaced service specs
        for (EDMMACServiceUtilsV2.deltaDTO spc : specs) {
            Boolean specRequireUpdate = false;
            
            List<EDMMACServiceUtilsV2.Attribute> changedAttList = spc.changedAttributes;
            List<EDMMACServiceUtilsV2.Attribute> changedAddAttList = spc.changedAdditionalAttributes;
            List<EDMMACServiceUtilsV2.NonCommercialAttr> changedNonComercialAttList = spc.changedNonCommercialAttributes;
            
            //check for the attribute change
            if (changedAttList.isEmpty() && changedAddAttList.isEmpty() && changedNonComercialAttList.isEmpty()) { continue;} //move to next spec
            
            
            //Capturing the changed spec first
            
            for (EDMMACServiceUtilsV2.Attribute attr : spc.changedAttributes) {
                if (!exclusionList.contains(attr.name)) {
                    specRequireUpdate = true;
                    break;
                }
            }
            
            //If this require check
            
            if (!specRequireUpdate) {
                for (EDMMACServiceUtilsV2.Attribute attr : spc.changedAdditionalAttributes) {
                    if (!exclusionList.contains(attr.name)) {
                        specRequireUpdate = true;
                        break;
                    }
                }
            }
            
            //If this require check
            if (!specRequireUpdate) {
                for (EDMMACServiceUtilsV2.NonCommercialAttr nca : changedNonComercialAttList) {
                    for (EDMMACServiceUtilsV2.Attribute addedAttr : nca.addedAttributes) {
                        if (!exclusionList.contains(addedAttr.name)) {
                            specRequireUpdate = true;
                            break;
                        }
                    }
                    
                    //If this require check
                    if (!specRequireUpdate) {
                        for (EDMMACServiceUtilsV2.Attribute changedAttr : nca.changedAttributes) {
                            if (!exclusionList.contains(changedAttr.name)) {
                                specRequireUpdate = true;
                                break;
                            }
                        }
                    }
                    
                    //If this require check
                    if (!specRequireUpdate) {
                        for (EDMMACServiceUtilsV2.Attribute removedAttr : nca.removedAttributes) {
                            if (!exclusionList.contains(removedAttr.name)) {specRequireUpdate = true;break;}
                        }
                    }
                }
            }
            
            //If after exclusion, changed attributes are present for the spec
            if (specRequireUpdate) {
                specsToUpdate.put(spc.guid, Label.Service_Spec_MAC_Initial_Status);
            }
        }
        return specsToUpdate;
    }
    
    public void updateObjects(){
        //Success DML order Ids
        List<Id> orderSuccessIds = new List<Id>();
        //Success DML subscription Ids
        List<Id> subsSuccessIds = new List<Id>();
        //Success DML service Ids
        List<Id> serviceSuccessIds = new List<Id>();
        //Success DML Attachment Ids
        List<Id> attchSuccessIds = new List<Id>();
        
        // List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
        //Updating all the order records
        /*if (updateOrderMap.size() > 0) {
updateResult = Database.update(updateOrderMap.values(), false);*/
        if (updateOrderMap.size() > 0) {
            Orchestration_PlatformCacheUtility.updatePlatformCache(updateOrderMap.values());}
        
        //Storing the order success Ids
        for (Id ordId :updateOrderMap.keyset()) {
            orderSuccessIds.add(ordId);
        }
        
        
        //Updating all the subscription records
        /*if (subsToUpdate.size() > 0) {
updateResult = Database.update(subsToUpdate.values(), false);*/
        if (subsToUpdate.size() > 0) {
            Orchestration_PlatformCacheUtility.updatePlatformCache(subsToUpdate.values());}
        
        
        //Storing the subscription success Ids
        for (Id subId: subsToUpdate.keySet()) {
            subsSuccessIds.add(subId);
        }
        
        
        //Updating all the service records
        /*if (servicesToUpdate.size() > 0) {
updateResult = Database.update(servicesToUpdate.values(), false);*/
        
        if (servicesToUpdate.size() > 0) {
            Orchestration_PlatformCacheUtility.updatePlatformCache(servicesToUpdate.values());
        }
        
        //Storing the service success Ids
        for (Id serId : servicesToUpdate.keySet()) {
            serviceSuccessIds.add(serId);
        }
        
        
        //Updating all the attachment records
        /*if (attachmentsToUpdate.size() > 0) {
updateResult = Database.update(attachmentsToUpdate.values(), false);*/
        
        if (attachmentsToUpdate.size() > 0){
            Orchestration_PlatformCacheUtility.updatePlatformCache(attachmentsToUpdate.values());
        }
        //Storing the attachment success Ids
        for (Id attId : attachmentsToUpdate.keySet()) {
            attchSuccessIds.add(attId);
        }
        
        
        
        //Iteration over each step
        for (Id stepId : stepRelationshipMap.keySet()) {
            Boolean isFailed = false;
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the attachmentIds Set
            perStepSuccessIds.attachmentIds = new Set<String>();
            perStepSuccessIds.subsIds = new Set<String>();
            perStepSuccessIds.skipRecordsIds = new Set<String>();
            
            for (Id recId : stepRelationshipMap.get(stepId)) {
                if (attchSuccessIds.contains(recId)) {
                    perStepSuccessIds.attachmentIds.add(recId);
                } else if (subsSuccessIds.contains(recId)) {
                    perStepSuccessIds.subsIds.add(recId);
                    //Failure
                } else if (!(orderSuccessIds.contains(recId) || subsSuccessIds.contains(recId) || serviceSuccessIds.contains(recId) || attchSuccessIds.contains(recId))) 
                { isFailed = true;}
            }
            
            if (!isFailed && (String.isBlank(incompleteStepId) || !incompleteStepId.equals(stepId))) {
                //stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Records processed',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                continue;
            }
            
            //Get all the new attachments that are skipped and add to JSON.
            if (stepRelationshiptoSkipMap.containsKey(stepId)) {
                perStepSuccessIds.skipRecordsIds = stepRelationshiptoSkipMap.get(stepId);
                stepRelationshiptoSkipMap.remove(stepId);
            }
            
            //Adding existing data of Json
           // if (processedIds.containsKey(stepId)) {
                if (processedRecordIds.skipRecordsIds != null) {
                    perStepSuccessIds.skipRecordsIds.addAll(processedIds.get(stepId).skipRecordsIds);
                }
                
                //Adding the previous stored ids - error/partial processed case
                if (processedRecordIds.attachmentIds != null) {
                    perStepSuccessIds.attachmentIds.addAll(processedIds.get(stepId).attachmentIds);
                }
                //added for cpu time out issue
                if (processedRecordIds.subsIds != null) { 
                    perStepSuccessIds.subsIds.addAll(processedIds.get(stepId).subsIds);}
            //}
            
            
            
            if (!isFailed && !String.isBlank(incompleteStepId) && incompleteStepId.equals(stepId)) {
                //stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
                mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Partial records processed',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.InProgress,JSON__c=(String)JSON.serialize(perStepSuccessIds, true)));
                
            } else { //stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));}
                
                mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: Unable to process records',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error,JSON__c=(String)JSON.serialize(perStepSuccessIds, true)));
            }
            
        } 
        
        //If all records for a skip are skipped
        for (Id stepId :stepRelationshiptoSkipMap.keySet()){
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the attachmentIds Set
            perStepSuccessIds.attachmentIds = new Set<String>();
            perStepSuccessIds.subsIds = new Set<String>();
            perStepSuccessIds.skipRecordsIds = stepRelationshiptoSkipMap.get(stepId);
            
            //Adding existing data of Json
           // if (processedIds.containsKey(stepId)) {
                if (processedRecordIds.skipRecordsIds != null) {perStepSuccessIds.skipRecordsIds.addAll(processedIds.get(stepId).skipRecordsIds);}
                
                //Adding the previous stored ids - error/partial processed case
                if (processedRecordIds.attachmentIds != null) {perStepSuccessIds.attachmentIds.addAll(processedIds.get(stepId).attachmentIds);}
                //added for cpu time out issue
                if (processedRecordIds.subsIds != null) {perStepSuccessIds.subsIds.addAll(processedIds.get(stepId).subsIds);}
           // }
            
            //stepResults.put(stepId, new stepResult('Success: Skipped records stored in Json', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
            mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Skipped records stored in Json',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.InProgress,JSON__c= (String)JSON.serialize(perStepSuccessIds, true)));
            
        }
        
        
    }
    
    /*public static boolean hasDMLRowsLimitExceeded() {
if (updateOrderMap.size() + attachmentsToUpdate.size() + servicesToUpdate.size() + subsToUpdate.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
return false;
}
//Limit Hit
return true;
}*/
    
    
    
}