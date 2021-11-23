/************************************************************************
 Name: ObserverReferenceImplementation
 Description: Implements the ObserverApi interface
 ************************************************************************/
global with sharing class ObserverReferenceImplementation implements csordcb.ObserverApi.IObserver 
{
 /***********************************************************************
  Name: ObserverReferenceImplementation
  Description: Constructor 
*******************************************************************/

    global ObserverReferenceImplementation()
    {
    }
/********************************************************************
  Name: execute
  Parameters: csordcb.ObserverApi.Observable o, Object arg
  Return Type: void
  Description: Method executed when Order,Service and Subscriptions
               are created using Orders and Subscription CloudSense
               package  
*******************************************************************/

    global void execute(csordcb.ObserverApi.Observable o, Object arg) 
    {
        csordtelcoa.OrderGenerationObservable observable = (csordtelcoa.OrderGenerationObservable)o;
        List<Id> orderRequestIds = observable.getOrderRequestIds();
        List<Id> subscriptionIds = observable.getSubscriptionIds();
        List<Id> serviceIds = observable.getServiceIds();
        List<Id> orderIds = observable.getOrderIds();
        List<Id> solutionIds = observable.getSolutionIds();
        List<Id> sliIds = observable.getServiceLineItemIds();
        List<Id> oliIds = observable.getOrderLineItemIds();
        List<Id> sfAssetIds = observable.getSalesforceAssetIds();
        List<Id> csAssetIds = observable.getCloudsenseAssetIds();
        System.debug('Order request count:' + orderRequestIds.size());
        System.debug('Subscriptions count:' + subscriptionIds.size());
        System.debug('Services count:' + serviceIds.size());
        System.debug('Orders count:' + orderIds.size());
        System.debug('Solution count:' +solutionIds.size());
        System.debug('Service Line Item count:' + sliIds.size());
        System.debug('Order Line Item count:' + oliIds.size());
        System.debug('SF Asset count:' + sfAssetIds.size());
        System.debug('CS Asset count:' + csAssetIds.size());
        
        //List<String> orderIdsinString = (List<String>)JSON.deserialize(JSON.serialize(orderIds), List<String>.class);
		String TransitionVersion = EnvironmentVariable__c.getValues('TransitionVersion').Value__c;
		if(TransitionVersion=='3'){
			if(subscriptionIds.size()>0){
            TransitionServicesCreationObserverHelper.createLegacyServices(subscriptionIds);
			}
			List<Id> serviceIds_1 = observable.getServiceIds();
			system.debug('***ServiceIds***'+serviceIds_1);
		}
		
        //commenting as part of defect 8893 order creation failure due to clash with orchestration process class
        List<id> finalOrderIDList = OrderMerge.singleOrder(orderIds);
        List<String> orderIdsinString = (List<String>)JSON.deserialize(JSON.serialize(finalOrderIDList), List<String>.class);
        OrderHeaderInformation.updateOrderHeaderInformation(finalOrderIDList);
        LinkParentSubscription.updateParentSubscription(orderIds);
        RecordTypeAssignHandler.assignRecordTypeToService(serviceIds);
        UpdateServiceSubscriptionsFields.updateServiceFields(serviceIds);
        UpdateServiceSubscriptionsFields.updateSubscriptionFields(subscriptionIds);
        Feature_Flag__mdt ft= FeatureFlagUtility.getFeatureTogglingByName('B2B2');
        if(!ft.IsActive__c){
        ManageOrderOrchestrationProcessHandler.createOrderOrchestrationProcess(orderIdsinString);
        }
        //OrchestrationProcessHelper.CreateOrchestrationProcessforNewProvide(subscriptionIds);
        FunctionalContactRoleOperation.upsertFunctionalContactRole(serviceIds);
        //EDMMACService.updateStatus(orderIds);
        if(!ft.IsActive__c){
         EDMMACService.updateStatus(orderIds);
        }
        EDMRelationshipService.createRelationShip(orderIds);
        if(!ft.IsActive__c){
        MACService.updateServiceStatus(serviceIds);
        }
        CPEDeliveryDateUpdateForMAC.addCPEAttr(serviceIds);
        if(ft.IsActive__c){
        //Link Agreement and Subscription - EDGE-33875
        ObserverImplSubscriptionHelper.associateContractJunctionRecord(subscriptionIds);
        }
        String apptVersion = EnvironmentVariable__c.getValues('AppointmentVersion').Value__c;
        if(apptVersion=='2'){
            //EDGE-21276
            OrderStatusHandler.changeOrderStatus(serviceIds);    
        }else if (apptVersion=='1'){
            LinkAppointmentSubscription.assignSubscriptionToAppointment(serviceIds);    
        }
    
    }
}