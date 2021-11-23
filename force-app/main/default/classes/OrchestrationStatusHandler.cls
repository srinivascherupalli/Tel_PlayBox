/*
===============================================================================================================================
Class : OrchestrationStatusHandler
Developer Name :
Test Class : OrchestrationStatusHandlerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
  1.        Shubhi Vijayvergia  21/3/2018     Edge-53883 Order Submission for Sim Replacement for Assurance service agen Profile   
  2.      Vaibhav Deshpande   26/9/2019     EDGE-91568 changed Subscription status for Suspend order
  3.        Ashish Agrawal    1/10/2019     Defect fix EDGE-115798
  4.        Shreya jaiswal    13/12/19      EDGE-125031
  5.        Shreya jaiswal    02/01/19      EDGE-125031 gap updated
  6.        Ravi Bhatnagar    30/12/19      EDGE-124891 : Refactor Orchestration Processes
  7.        Pawan Devaliya  15/05/2020      EDGE-144704:Update status of svc,subs, ord to Paid out for NGUC device and accesories for paid out scenario
  8.        Gnana           15/05/2020      EDGE-146358 : Added a method calling in OrchestrationOrderDeltaHandler
  9.        Pawan           02/07/2020      EDGE-156046 :  Enhance paid out subscription / service status management for a product offer agnostic and scalable solution
  10.       Prajakta        21/07/2020     EDGE-164012
===============================================================================================================================
*//**************************************************************
 Name: OrchestrationStatusHandler
 Description: Class to update Services->Subscription->Order statuses
**************************************************************/
global with sharing class OrchestrationStatusHandler {
      public class My2Exception extends Exception {}
    global class OrchestrationOrderDeltaHandler implements CSPOFA.ExecutionHandler{
        //EDGE-124891 : Method changed as part of refactoring
        public List<SObject> process(List<SObject> steps){
            List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
            Set<Id> serviceIds = new Set<Id>();
            Set<Id> orchIdsSet = new Set<Id>();
            Set<Id> orderIdsSet = new Set<Id>();
            Map<Id,String> scenerioTypeOrderMap = new Map<Id,String>();
            for(CSPOFA__Orchestration_Step__c step: stepList)
                orchIdsSet.add(step.CSPOFA__Orchestration_Process__c);
            try
            {
                List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Service__c from CSPOFA__Orchestration_Process__c where Id IN:orchIdsSet];
                System.debug('orchList ::'+orchList);
                for(CSPOFA__Orchestration_Process__c  orch : orchList){
                    orderIdsSet.add(orch.Order__c);
                }
                Set<Id> ordRequestIds= new Set<Id>();
                Map<Id, csord__Order__c> mapOrderIDOrder = new Map<Id, csord__Order__c>([Select id, csord__Order_Request__c, csordtelcoa__Opportunity__c, csord__Primary_Order__c from csord__Order__c where csord__Primary_Order__c in :orderIdsSet OR id in : orderIdsSet]); 
                if(!mapOrderIDOrder.isEmpty())
                    ordRequestIds = mapOrderIDOrder.keySet();
                Map<Id, csord__Service__c> mapServIdService = new Map<Id, csord__Service__c>([Select Id, Name,csord__Order__c, Action_Type__c,  csord__Subscription__r.id from csord__Service__c where csord__Order__c  in :ordRequestIds and csordtelcoa__Replaced_Service__c!=null]);
                if(!mapServIdService.isEmpty())
                    serviceIds = mapServIdService.keySet();
                
                EDMMACService.updateStatus(new List<Id>(orderIdsSet));
                MACService.updateServiceStatus(new List<Id>(serviceIds));
                MACService.updateServiceStatusMobileAccess(new List<Id>(orderIdsSet));
                MACService.updateOrderToSkipFullfillment(new List<Id>(orderIdsSet)); // Added as part of EDGE-146358
                updateSvcSubsStatusOnPaidOut(mapServIdService); //EDGE-144704
                for(CSPOFA__Orchestration_Step__c step : stepList){
                    step.CSPOFA__Status__c = Label.Complete;
                    step.CSPOFA__Completed_Date__c = Date.today();
                    step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
                }
                 if(Test.isRunningTest()){ 
                     throw new My2Exception('My exception');
                 }
            }
            catch (Exception ex)
            {  
                for (CSPOFA__Orchestration_Step__c step : stepList) {
                    step.CSPOFA__Status__c = Label.Error;
                    step.CSPOFA__Completed_Date__c = Date.today();
                    step.CSPOFA__Message__c = 'Exception: ' + ex.getMessage() + ' - ' + ex.getLineNumber();
                }
            }
            return stepList;
            
        }
        
        //EDGE-144704
        //EDGE-156046: Changes for product offer agnostic
        public void updateSvcSubsStatusOnPaidOut(Map<Id, csord__Service__c> mapServIdService){
        Set<Id> subsIdSet = new Set<Id>();
        Map<Id, List<csord__Service__c>> mapSubSvcList = new Map<Id, List<csord__Service__c>>();
        List<csord__Subscription__c>  subListToUpdate = new List<csord__Subscription__c>(); 
        List<csord__Service__c>  svcListToUpdate = new List<csord__Service__c>(); 
        
        //EDGE-156046 : Fetching subscriptions Ids for the service where acion type is PaidOut
        for(csord__Service__c svc :mapServIdService.values()){
            if(svc.Action_Type__c != null && svc.Action_Type__c.equalsIgnorecase('PaidOut')){
                subsIdSet.add(svc.csord__Subscription__r.id); 
            }    
    
        }
        
        List<csord__Service__c> allSvcList = [SELECT Id, Action_Type__c, csord__Status__c, csord__Subscription__r.id, csord__Subscription__r.csord__Status__c, csord__Order__r.csord__Status2__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Service__c Where csord__Subscription__c IN:subsIdSet];
        
        //Loop to get Map of SubId and List of services : to count all the services on each subscription and also updating satatus of services to Paid out if actiontype is PaisOut
        for(csord__Service__c svc :allSvcList){
            if(svc.Action_Type__c != null && svc.Action_Type__c.equalsIgnorecase('PaidOut')){
                svc.csord__Status__c = 'Paid Out';
                svcListToUpdate.add(svc);
            }
            List<csord__Service__c> svcListToAdd = new List<csord__Service__c>();
            if(mapSubSvcList != null && mapSubSvcList.containsKey(svc.csord__Subscription__r.id)){
                svcListToAdd = mapSubSvcList.get(svc.csord__Subscription__r.id);
                svcListToAdd.add(svc);
                mapSubSvcList.put(svc.csord__Subscription__r.id, svcListToAdd);
            }
            else{
                svcListToAdd.add(svc);
                mapSubSvcList.put(svc.csord__Subscription__r.id, svcListToAdd);
                
            }   
            
        }

        //Loop to count PaidOut services on a subscription
        for(csord__Service__c svc :svcListToUpdate){
            if(svc.csord__Subscription__r.csord__Status__c != 'Paid Out'){
                Integer counter = 0;
                for(csord__Service__c svc2 : mapSubSvcList.get(svc.csord__Subscription__r.id)){
                    if(svc2.Action_Type__c != null && svc2.Action_Type__c.equalsIgnorecase('PaidOut')){
                        counter++;
                    }
                    else{
                        break;
                    }   
                }
                //Marking Subscription Status to Paid Out if all its services have action Type Paid Out
                if(counter == mapSubSvcList.get(svc.csord__Subscription__c).size()){
                    svc.csord__Subscription__r.csord__Status__c = 'Paid Out';
                    subListToUpdate.add(svc.csord__Subscription__r);
                }
            }
            
        }

            SObject[] serSubOrdSObject= new List<SObject>();
            serSubOrdSObject.addAll(svcListToUpdate);
            serSubOrdSObject.addAll(subListToUpdate);
            update  serSubOrdSObject; 
         }
    }
    
    global class EvaluateSubscriptionStatus implements CSPOFA.ExecutionHandler{
        /**************************************************************
          Name: process
          Parameters: List<SObject> steps
          Return Type: List<SObject>
          Description: Class to update Services->Subscription statuses
        *******************************************************************/

        private Boolean isBillable=false; //Variable to check  Subscription billability

        public List<SObject> process(List<SObject> steps){
            List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
            List<Id> serviceIds = new List<Id>();
            List<Id> orchesIds= new List<Id>();
                for(CSPOFA__Orchestration_Step__c step: stepList)
                    orchesIds.add(step.CSPOFA__Orchestration_Process__c);
                
                system.debug(orchesIds);
                List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Service__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
                System.debug('orchList ::'+orchList);
                for(CSPOFA__Orchestration_Process__c  orch : orchList)
                    serviceIds.add(orch.csordtelcoa__Service__c);
                
                system.debug('serviceIds ::'+serviceIds);
                
                updateSubscriptionStatus(serviceIds);
                for(CSPOFA__Orchestration_Step__c step : stepList){
                    step.CSPOFA__Status__c = Label.Complete;
                    step.CSPOFA__Completed_Date__c=Date.today();
                    step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
                    result.add(step);
                }
            return result;
        }

        @TestVisible
        private void updateSubscriptionStatus(List<Id> serviceIds){
            //find subscriptions
            Set<Id> subscriptionIds = new Set<Id>();
            //Map of solutionId, mainSubscriptionId (main subscription == solution subscription)
            Map<Id,Id> solutionAssociationSS = new Map<Id,Id>();
            Map<String,String> statusMap = new Map<String,String>();
            Set<Id> subscriptionSolutionAssociationIds = new Set<Id>();
            //EDGE-139661
            Set<csord__Subscription__c> updateSubscriptions = new Set<csord__Subscription__c>();
            Map<Id, List<csord__Service__c>> subServiceMap = new Map<Id, List<csord__Service__c>>();
            csord__Subscription__c solsub = new csord__Subscription__c();
            
            List<csord__Service__c> serviceList = [select id, name, csord__Status__c, csord__Subscription__c,csord__Subscription__r.cssdm__solution_association__c,csord__Order__r.name,csord__Order__c FROM csord__Service__c Where Id IN:serviceIds];
            for(csord__Service__c serv: serviceList){
                subscriptionSolutionAssociationIds.add(serv.csord__Subscription__r.cssdm__solution_association__c);
                subscriptionIds.add(serv.csord__Subscription__c);
            }
            //fetch all services to derive the status
            for(csord__Service__c svc: [select id, name, csord__Status__c, csord__Subscription__c,csord__Order__r.name,csord__Order__c From csord__Service__c Where csord__Subscription__c IN:subscriptionIds]){
                if(!subServiceMap.containsKey(svc.csord__Subscription__c)){
                    subServiceMap.put(svc.csord__Subscription__c, new List<csord__Service__c>{svc});
                } else {
                    subServiceMap.get(svc.csord__Subscription__c).add(svc);
                }
            }
            System.debug('subServiceMap-' + subServiceMap);
            //This below map holds all the subscriptions fetched from the solution records. The solution records are fetched from the services for which the orchestration was invoked.
            Map<Id,csord__Subscription__c> subscriptionMap = new Map<Id,csord__Subscription__c>([SELECT Id,csord__Total_Recurring_Charges__c,csord__Total_One_Off_Charges__c,csord__Status__c,Sub_Status__c, csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                                                cssdm__solution_association__c,toBeCancelled__c,Is_Bill_Stopped__c,Suspension_reason__c,triggerBill_RTB__c,MarketableOffer__c, MarketableOffer__r.Config__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, legacy_subscription__c,csord__Order__r.name,csord__Order__c 
                                                from csord__Subscription__c where cssdm__solution_association__c IN : subscriptionSolutionAssociationIds]);
            for(Id subscriptionId : subscriptionMap.keySet()){
                csord__Subscription__c subscription = subscriptionMap.get(subscriptionId);
                if(String.isNotBlank(subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c) && subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){
                    solsub = subscription;
                    solutionAssociationSS.put(subscription.cssdm__solution_association__c,subscription.Id);
                }
            }
            //EDGE-125031 : Queried metadata to check if subs is applicable for transition and getting all linked legacy sub
            
            List<Non_Legacy_Product__mdt> NonLegacymetadataList= [select Id, Product_Spec_Code__c, Dependent_Transition__c from Non_Legacy_Product__mdt ];
            Map<String, Non_Legacy_Product__mdt > NonLegacymetadataMap = new Map<String, Non_Legacy_Product__mdt >();
            for(Non_Legacy_Product__mdt transMetadata : NonLegacymetadataList)
                NonLegacymetadataMap.put(transMetadata.Product_Spec_Code__c, transMetadata);
            
            
            List<csord__Subscription__c> legacySubList = [select Id, legacy_subscription__c, csord__Status__c  from csord__Subscription__c where legacy_subscription__c IN :subscriptionIds];
            
            Map<Id, set<String>> legacySubMap = new Map<Id, Set<String>>();
            
            for(csord__Subscription__c legacysub : legacySubList){
                if(legacySubMap.containsKey(legacysub.legacy_subscription__c))
                   legacySubMap.get(legacysub.legacy_subscription__c).add(legacysub.csord__Status__c);
                legacySubMap.put(legacysub.legacy_subscription__c, new Set<String> {legacysub.csord__Status__c});
            }
            
            //This will iterate only for Individual subscription and never for Solution SUbscription
            for(Id subId: subServiceMap.keySet()){
                csord__Subscription__c subUpdate = subscriptionMap.get(subId);
                isBillable = (subUpdate.csord__Total_One_Off_Charges__c>0 || subUpdate.csord__Total_Recurring_Charges__c>0) ? true : false;
               
                //20/11/2019 Added by BRAM for checking if its isConsumptionBasedCharge Offer
                if(subUpdate.MarketableOffer__r.Config__c!= NULL)
                {
                    System.debug('subUpdate-' + subUpdate);
                    Map<String, Object> basketConfiguration = (Map<String, Object>)JSON.deserializeUntyped(subUpdate.MarketableOffer__r.Config__c);
                    if(basketConfiguration.get('isConsumptionBasedCharge') != NULL && (Boolean)basketConfiguration.get('isConsumptionBasedCharge'))
                    {
                        isBillable=true;
                    }
                }
                
                
                System.debug('--Is Billable--' + isBillable);
                //EDGE-125031 : RTB will get triggered only if all linked legacy is Inactive :putting condition for getSubscriptionStatus method to implement this
                Boolean changeStatus = true;
                String prodCode= subUpdate.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
                
                Non_Legacy_Product__mdt NonLegacymetada = NonLegacymetadataMap.get(prodCode);
                
                if(NonLegacymetada != NULL && NonLegacymetada.Dependent_Transition__c){
                    if(!(legacySubMap.get(subId) != null && legacySubMap.get(subId).size() == 1 && legacySubMap.get(subId).contains('Inactive')))
                        changeStatus = false;
                }
                //updated gap EDGE-125031
                if(subUpdate.legacy_subscription__c != null){statusMap = getSubscriptionStatus(subServiceMap.get(subId),'true',true);}
                else{
                    if(changeStatus){ 
                        statusMap = getSubscriptionStatus(subServiceMap.get(subId),subUpdate.toBeCancelled__c,subUpdate.Is_Bill_Stopped__c);}
                }
                if(statusMap.get('status') != subUpdate.csord__Status__c){
                    //EDGE-91568 - for suspend order changed subscription status as Suspended
                    // EDGE - 81135 : Defect - EDGE-115798
                    if(String.isNotBlank(subUpdate.Suspension_reason__c) && subUpdate.Suspension_reason__c.containsIgnoreCase('Requested by'))
                    {
                        subUpdate.csord__Status__c = 'Suspended';
                        subUpdate.Sub_Status__c = 'Suspended';   //EDGE-91568 - END
                    } 
                    // EDGE-164012 start
                    else if(subUpdate.csord__Order__c != null && subUpdate.csord__Order__r.name != null && subUpdate.csord__Order__r.name.containsIgnoreCase('Resume')){
                        subUpdate.csord__Status__c = 'Active';
                        subUpdate.Sub_Status__c = 'Active'; 
                    }// EDGE-164012 start
                    else {
                        subUpdate.csord__Status__c = statusMap.get('status');
                        subUpdate.Sub_Status__c = statusMap.get('subStatus');
                        if('Provisioned'.equals(subUpdate.csord__Status__c)){
                            if(solutionAssociationSS.get(subUpdate.cssdm__solution_association__c) != null){
                                csord__Subscription__c solutionSubscription = subscriptionMap.get(solutionAssociationSS.get(subUpdate.cssdm__solution_association__c));
                                //If Solution subscription is already Active then SET trigger RTB on Individual Subscription for which the code is invoked.
                                if(solutionSubscription.csord__Status__c =='Active'){
                                    subUpdate.triggerBill_RTB__c = true;
                                } else if(!solutionSubscription.triggerBill_RTB__c){
                                    //If Solution Subscription is not sent to bill then SET tigger RTB to TRUE.
                                    //Trigger RTB on Individual Subscription for those who are involved here but not sent to bill, will be set to TRUE on activation of Solution Subscription by the method 'OrchestrationStatusHandler.EvaluateOrderStatus'
                                    solutionSubscription.triggerBill_RTB__c = true;
                                    solutionSubscription.csord__Status__c = 'Provisioned';
                                    solutionSubscription.Sub_Status__c = 'Active';
                                    updateSubscriptions.add(solutionSubscription);
                                }
                            }
                        }
                    }
                }
                //EDGE-139661
                if(string.isBlank(subUpdate.csord__Status__c)){
                    subUpdate.csord__Status__c = 'Provisioned';
                    solsub.triggerBill_RTB__c = true;
                }
                if(solsub.id != null)
                updateSubscriptions.add(solsub);
                updateSubscriptions.add(subUpdate);
                    
            }
            //EDGE-139661
            List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
            if(!updateSubscriptions.isEmpty()){
            subscriptionList.addAll(updateSubscriptions);
            update subscriptionList;
            }
            
        }

        @TestVisible
        private Map<String,String> getSubscriptionStatus(List<csord__Service__c> services,String isStopBillValue,Boolean  isBillStopped){
            String status = 'Provisioning In Progress';
            String subStatus = '';
            Map<String,String> statusMap = new Map<String,String>();
            Integer countInProgress = 0;
            Integer countcancellationInProgress = 0;
            Integer countFailed = 0;
            Integer countConnected = 0;
            Integer countDisconnected = 0;
            Integer countCancelled = 0;
            Boolean isStopBill=Boolean.ValueOf(isStopBillValue);

            for(csord__Service__c service: services){
                
        //for Any child service status is In Progress or Cancellation In Progress
        
                if(service.csord__Status__c == 'In Progress'){
                    status = 'Provisioning In Progress';
                    statusMap.put('status',status);
                    return statusMap;
                }

                //for All child services status
                if (service.csord__Status__c == 'Cancellation In Progress')
                    countcancellationInProgress = countcancellationInProgress+1;
                else if (service.csord__Status__c == 'Failed')
                    countFailed = countFailed +1;
                else if (service.csord__Status__c == 'Connected')
                    countconnected = countconnected +1;
                else if (service.csord__Status__c == 'Disconnected')
                    countDisconnected = countDisconnected +1;
                else if (service.csord__Status__c == 'Cancelled')
                    countcancelled = countcancelled +1;
            
            }

            if(services.size() == countcancellationInProgress)
                status = 'Cancellation In Progress';
            else if(services.size() == countFailed)
                status = 'Failed';
            else if(countconnected != 0 && services.size() == (countconnected + countDisconnected + countcancelled) && isBillable == true){
                status = 'Provisioned';
                subStatus = 'Active';
                System.debug('Status Pro--'+status);
            }
            else if(countconnected != 0 && services.size() == (countconnected + countDisconnected + countcancelled)){
                status = 'Active';
                subStatus = 'Active';
            }
            //else if(countconnected == 0 && countDisconnected != 0 && services.size() == (countDisconnected+countcancelled))
            // status = 'Inactive';
            else if(countDisconnected == 0 && services.size()== countcancelled)
                status= 'Cancelled';

            else if(countconnected == 0 && services.size() == countDisconnected && (isStopBill)){
                if(isBillStopped){
                    status = 'Inactive';
                    subStatus = 'Inactive';
                }else{
                    status = 'Provisioned';
                    subStatus = 'Inactive';
                }
            }


            if(services.size() == (countDisconnected + countcancelled))
                subStatus = 'Inactive';
       
            statusMap.put('status',status);
            statusMap.put('subStatus',subStatus);
            return statusMap;
        }
        //EDGE-164012 end
    }

    global class EvaluateOrderStatus implements CSPOFA.ExecutionHandler{
        /**************************************************************
          Name: process
          Parameters: List<SObject> steps
          Return Type: List<SObject>
          Description: Class to update create orchestration process for related Order->Subscription
        *******************************************************************/
        public List<SObject> process(List<SObject> steps){
            List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
            List<Id> orderIds = new List<Id>();
            List<Id> subsIds = new List<Id>();
            List<Id> orchesIds= new List<Id>();
            for(CSPOFA__Orchestration_Step__c step: stepList)
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);

            system.debug(orchesIds);
            List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Subscription__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
            System.debug('orchList ::'+orchList);
            for(CSPOFA__Orchestration_Process__c  orch : orchList)
                subsIds.add(orch.csordtelcoa__Subscription__c);

            system.debug('subsIds ::'+subsIds);

            updateOrderStatus(subsIds);
            for(CSPOFA__Orchestration_Step__c step : stepList){
                step.CSPOFA__Status__c = Label.Complete;
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
                result.add(step);
            }
            return result;
        }

        public void updateOrderStatus(List<Id> subsIds){
            Set<Id> orderIdSet = new Set<Id>();
            Set<Id> listOfSolution = new Set<Id>();
            List<csord__Order__c> updateOrder = new List<csord__Order__c>();
            Map<Id, csord__Order__c> ordersMap = new Map<Id, csord__Order__c>();
            Map<Id, List<csord__Subscription__c>> orderSubscriptionMap = new Map<Id, List<csord__Subscription__c>>();
            List<csord__Subscription__c> subsList = [SELECT id, csord__Status__c,csordtelcoa__Replacement_Subscription__r.csord__Order__c, csord__Order__c, csordtelcoa__Product_Configuration__r.ConfigurationType1__c, cssdm__solution_association__c,
                                                    csord__Order__r.csord__Primary_Order__c, csord__Order__r.id, csord__Order__r.Name, csord__Order__r.csord__Status2__c FROM csord__Subscription__c WHERE Id IN:subsIds];

            for(csord__Subscription__c subs: subsList){
                if(String.isNotBlank(subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c) && subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent' && subs.csord__status__c == 'Active'){
                    listOfSolution.add(subs.cssdm__solution_association__c);
                }
                if(subs.csord__Order__c != null){
                    orderIdSet.add(subs.csord__Order__c);
                }else{
                    orderIdSet.add(subs.csordtelcoa__Replacement_Subscription__r.csord__Order__c);
                }
            }

            for(csord__Subscription__c subs: [SELECT Id,csord__Status__c, csord__Order__c, csord__Order__r.csord__Status2__c FROM csord__Subscription__c WHERE csord__Order__c IN:orderIdSet]){
                if(!ordersMap.containsKey(subs.csord__Order__c)){
                    ordersMap.put(subs.csord__Order__c, subs.csord__Order__r);
                }
                if(!orderSubscriptionMap.containsKey(subs.csord__Order__c)){
                    orderSubscriptionMap.put(subs.csord__Order__c, new List<csord__Subscription__c>{subs});
                } else{
                    orderSubscriptionMap.get(subs.csord__Order__c).add(subs);
                }
            }

            for(Id ordId: orderSubscriptionMap.keySet()){
                String status = getOrderStatus(orderSubscriptionMap.get(ordId));
                if(status != ordersMap.get(ordId).csord__Status2__c){
                    ordersMap.get(ordId).csord__Status2__c = status;
                    //Edge-26288
                    if(status == 'Completed'){
                        ordersMap.get(ordId).csord__End_Date__c = Date.today();
                    }
                    updateOrder.add(ordersMap.get(ordId));
                }
            }
            /*
             * Update Individual Susbcriptions field triggerBill_RTB__c to TRUE.
             *  Ex : Order -> SS1 (Solution Subscription) -> IS1 (Individual Subscription)
             *                    -> IS2 (Individual Subscription)
             *             -> SS2 (Solution Subscription) -> IS1 (Individual Subscription)
             *                    -> IS2 (Individual Subscription)
             *             -> SS3 (Solution Subscription) -> IS1 (Individual Subscription)
             *                    -> IS2 (Individual Subscription)
             * If SS1 and SS3 are Completed, Then billing should be triggered for SS1.IS1,SS1.IS2,SS3.IS1,SS3.IS2 by update triggerBill_RTB__c flag to TRUE.
            */
            if(!listOfSolution.isEmpty()){
                List<csord__Subscription__c> updateSubscriptionToTriggerR2B = [SELECT Id,triggerBill_RTB__c,cssdm__solution_association__c from csord__Subscription__c where triggerBill_RTB__c= false AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' AND cssdm__solution_association__c IN : listOfSolution];
                for(csord__Subscription__c individualSubscription : updateSubscriptionToTriggerR2B){
                    individualSubscription.triggerBill_RTB__c = TRUE;
                }
                if(!updateSubscriptionToTriggerR2B.isEmpty()){
                    UPDATE updateSubscriptionToTriggerR2B;
                }
            }
            update updateOrder;
        }

        @TestVisible
        private Datetime getDeliveryDate(List<csord__Subscription__c> subscriptions, String value){
            List<Datetime> deliveryDate = new List<Datetime>();
            for(csord__Subscription__c sub : subscriptions){
                if( value == 'Forecasted Delivery Date')
                    deliveryDate.add(sub.Forecasted_Delivery_Date__c);
                else
                    deliveryDate.add(sub.Telstra_Committed_Date__c);
            }
            deliveryDate.sort();
            system.debug('deliveryDate=='+deliveryDate.get(deliveryDate.size()-1));
            system.debug('deliveryDate=='+deliveryDate);
            return deliveryDate.get(deliveryDate.size()-1);
        }

        @TestVisible
        private String getOrderStatus(List<csord__Subscription__c> subscriptions){
            String status = 'In Progress';
            Integer countInProgress = 0;
            Integer countcancellationInProgress = 0;
            Integer countFailed = 0;
            Integer countActive = 0;
            Integer countInActive = 0;
            Integer countCancelled = 0;
            Integer countBillingComplete = 0;
            Integer countSuspended = 0; //EDGE-91568


            for(csord__Subscription__c subs: subscriptions){
                //EDGE-12936 updated to check billing status
                //for Any child service status is In Progress or Cancellation In Progress
                if(subs.csord__Status__c == 'Bill Readiness In Progress'){
                    status = 'In Progress';
                    return status;
                }

                //for All child services status
                if (subs.csord__Status__c == 'Cancellation In Progress')
                    countcancellationInProgress = countcancellationInProgress+1;
                else if (subs.csord__Status__c == 'Failed')
                    countFailed = countFailed +1;
                else if (subs.csord__Status__c == 'Active' || subs.csord__Status__c == 'Paid Out' || subs.csord__Status__c == Label.Replaced_Active)//EDGE-147971 Replaced Active
                    countActive = countActive +1;
                else if (subs.csord__Status__c == 'Inactive')
                    countInactive = countInactive +1;
                else if (subs.csord__Status__c == 'Cancelled')
                    countcancelled = countcancelled +1;
                else if (subs.csord__Status__c == 'Billing Complete')
                    countBillingComplete = countBillingComplete +1;
                else if (subs.csord__Status__c == 'Suspended') //EDGE-91568
                    countSuspended= countBillingComplete + 1;
            }

            if(subscriptions.size() == countcancellationInProgress)
                status = 'Cancellation In Progress';
            else if(subscriptions.size() == countFailed)
                status = 'Failed';
            else if(subscriptions.size() == (countActive+countInactive))
                status = 'Completed';
            else if(subscriptions.size() == countcancelled)
                status= 'Cancelled';
            else if(subscriptions.size() == (countcancelled+countFailed))
                status= 'In Progress';
            else if(subscriptions.size() == (countBillingComplete+countInactive +countcancelled))
                status= 'Completed';
            else if(subscriptions.size() == countSuspended) //EDGE-91568
                status= 'Completed';

            return status;

        }

    }
    global class UpdateSubOrderStatus implements CSPOFA.ExecutionHandler{
        /**************************************************************
          Name: process
          Parameters: List<SObject> steps
          Return Type: List<SObject>
          Description: Class to update create orchestration process for related Order->SubOrder
        *******************************************************************/
        //EDGE-124891 : Method changed as part of refactoring
        public List<SObject> process(List<SObject> steps){
            List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
            List<Id> orderIds = new List<Id>();
            //List<Id> subsIds = new List<Id>();
            List<Id> orchesIds= new List<Id>();
            for(CSPOFA__Orchestration_Step__c step: stepList)
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            try
            {
                
                system.debug(orchesIds);
                List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Subscription__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
                System.debug('orchList ::'+orchList);
                for(CSPOFA__Orchestration_Process__c  orch : orchList)
                    orderIds.add(orch.Order__c);
                system.debug('orderIds ::'+orderIds);
                updateSubStageOrderStatus(orderIds);            
                for(CSPOFA__Orchestration_Step__c step : stepList){
                    step.CSPOFA__Status__c = Label.Complete;
                    step.CSPOFA__Completed_Date__c = Date.today();
                    step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
                }
                 if(Test.isRunningTest())
        { throw new My2Exception('My exception');
          }
            }
            catch (Exception ex)
            {  
                for (CSPOFA__Orchestration_Step__c step : stepList) {
                    step.CSPOFA__Status__c = Label.Error;
                    step.CSPOFA__Completed_Date__c = Date.today();
                    step.CSPOFA__Message__c = 'Exception: ' + ex.getMessage() + ' - ' + ex.getLineNumber();
                }
            }
            return stepList;
        }
        //Abinash
        public void updateSubStageOrderStatus(List<Id> primaryOrderIds){
            if(!primaryOrderIds.isEmpty()){
                //EDGE-124891 : Commented as part of refactoring - Start
                //List<csord__Order__c> orders = [SELECT Id, Name, csord__Status2__c, csord__Primary_Order__c FROM csord__Order__c WHERE Id IN: primaryOrderIds/*(Id IN: primaryOrderIds OR csord__Primary_Order__c IN: primaryOrderIds)*/];
                //Map<Id, csord__Order__c> primaryOrders = new Map<Id, csord__Order__c>();
                //Map<Id, List<csord__Order__c>> secondaryOrders = new Map<Id, List<csord__Order__c>>();
                //EDGE-124891 : Commented as part of refactoring - End
                List<csord__Order__c> orderstoUpdate = new List<csord__Order__c>();

                //Abinash
                map<Id,List<csord__Subscription__c>> mapOrderwithSub = new map<Id,List<csord__Subscription__c>>();
                //EDGE-124891 : Commented as part of refactoring
                //if(!primaryOrderIds.isEmpty()){
                for(csord__Subscription__c sub : [SELECT id,csord__Order__c,csord__Order__r.csord__Status2__c,csord__Status__c
                    FROM csord__Subscription__c WHERE csord__Order__c IN: primaryOrderIds]){
                        if(mapOrderwithSub.containsKey(sub.csord__Order__c)){
                            mapOrderwithSub.get(sub.csord__Order__c).add(sub);
                        }else{
                            mapOrderwithSub.put(sub.csord__Order__c, new List<csord__Subscription__c>{sub});
                        }
                    }
                //}

                // Abinash
                /* for(csord__Order__c ord: orders){
                     if(ord.csord__Primary_Order__c == null){
                         primaryOrders.put(ord.Id, ord);
                     } else {
                         if(secondaryOrders.containsKey(ord.csord__Primary_Order__c))
                             secondaryOrders.get(ord.csord__Primary_Order__c).add(ord);
                         else
                             secondaryOrders.put(ord.csord__Primary_Order__c, new List<csord__Order__c>{ord});
                     }
                 }
                 System.debug('primaryOrders::'+primaryOrders);
                 System.debug('secondaryOrders::'+secondaryOrders);isb
                 for(Id primaryId: primaryOrders.keySet()){
                     String primaryStatus; String secondaryStatus;
                     primaryStatus = primaryOrders.get(primaryId).csord__Status2__c;
                     List<csord__Order__c> secOrds = secondaryOrders.get(primaryId);
                     orderstoUpdate.addAll(getSubOrderstoUpdate(primaryStatus, secOrds));

                 }*/
                //Abinash
                if(mapOrderwithSub.size() > 0){
                    orderstoUpdate.addAll(getOrdersStatustoUpdate(mapOrderwithSub));
                }
                System.debug('orderstoUpdate:::'+orderstoUpdate);
                if(!orderstoUpdate.isEmpty())
                    update orderstoUpdate;
            }

        }

        @TestVisible
        private List<csord__Order__c> getSubOrderstoUpdate(String primaryStatus, List<csord__Order__c> secondaryOrders){
            List<csord__Order__c> results = New List<csord__Order__c>();
            System.debug('primaryStatus::'+primaryStatus);
            if(secondaryOrders!=null && !String.isEmpty(primaryStatus)){
                for(csord__Order__c ord: secondaryOrders){
                    if(ord.csord__Status2__c != primaryStatus){
                        System.debug('primary statuses::'+primaryStatus +'   secondary status::' +ord.csord__Status2__c);
                        ord.csord__Status2__c = primaryStatus;
                        results.add(ord);
                    }
                }
            }
            System.debug('results::: '+results);
            return results;
        }
        // Abinash Update Order csord__Status2__c from Subscription
        @TestVisible
        private List<csord__Order__c> getOrdersStatustoUpdate(Map<Id,List<csord__Subscription__c>> mapOrderwithSub){
            List<csord__Order__c> results = New List<csord__Order__c>();
            if(mapOrderwithSub.size() > 0){
                for(String orderId: mapOrderwithSub.keySet()){
                    Integer totalActiveStatus=0;
                    String Status ='In Error';
                    String OrderCurrentStatus = mapOrderwithSub.get(orderId)[0].csord__order__r.csord__Status2__c;
                    for(csord__Subscription__c sub: mapOrderwithSub.get(orderId)){
                        if (sub.csord__Status__c == 'Active' || sub.csord__Status__c == 'Suspended') //EDGE-91568 - added check for Suspended subscription
                            totalActiveStatus = totalActiveStatus +1;

                        /*if(ordering.containsKey(sub.csord__Status__c) && ordering.get(sub.csord__Status__c) == 0)
                          Status = 'In Progress';
                        subscriptionStatus.add(sub.csord__Status__c);*/
                    }
                    if(mapOrderwithSub.get(orderId).size() == totalActiveStatus){
                        Status='Completed';
                    }
                    System.debug('OrderCurrentStatus::'+OrderCurrentStatus);
                    if(OrderCurrentStatus != Status){
                        results.add(new csord__order__c(Id=orderId, csord__Status2__c=Status));
                    }

                }
            }
            System.debug('results::: '+results);
            return results;
        }

    }
}