/**================================================================
 * Appirio, Inc
 * Name: Orchestration_LinkNumAndServOrchHandler
 * Description: Class to update SIMSerailNumber and IMSI in service spec
 * Created Date: July 16, 2020
 * Created By: Gaurang Maheshwari
 Prajakta       14/08/2020       EDGE-170096
 Prajakta       18/08/2020       EDGE-166432
 Prajakta       04/11/2020       EDGE-174930
 Prajakta       20/11/2020       EDGE-188748
 Vaibhav        03/12/2020       EDGE-192921
 Vaishali       08/12/2020       Sonar Fix -SOQL in For Loop
 Prajakta       25/01/2021      EDGE-195398 - refactoring of class
 Prajakta       04/02/2021      EDGE-194053
 Prajakta       24/02/2021      EDGE-152473
 Gnana      26/02/2020    EDGE-170545 - Modified the step to handle both inflight and normal orders 
 Mahima      23/03/2020      DPG-4545 - Suspend and Resume for AM Plan
 Pawan/Hitesh   20/05/2021      Partial Proccessing logic added
 Pawan/Hitesh   20/05/2021      INC000095943631 - AutoComplete flag resetting
 Vaibhav        08/06/2021      EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL
 ==================================================================*/
global with sharing class Orchestration_LinkNumAndServV1_Handler implements Orchestration_StepInterface{
     private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    //Store Id --> Service
    private Map<Id, csord__service__c> serviceMap = new Map<Id, csord__service__c>();
    //Order --> Service
    private Map<Id, List<csord__Service__c>> orderServiceMap = new Map<Id, List<csord__Service__c>>();
  
    //Store Id --> Subscription
    private Map<Id,csord__Subscription__c> subMap = new Map<Id,csord__Subscription__c>();
    private List<csord__service__c> updateserviceList = new List<csord__service__c>();
    private Map<Id,csord__Subscription__c> updatesubMap = new Map<Id,csord__Subscription__c>();
    private Map<Id,csord__service__c> updateServiceMap = new Map<Id,csord__service__c>();
    private Map<Id,csord__Order__c> updateorderMap = new Map<Id,csord__Order__c>();
    private Map<Id, Set<String>> currentStepskipRecIds = new Map<Id, Set<String>>();

    //Service --> Number
    private Map<String, Number__c> ServNumToNumberMap = new Map<String, Number__c>();
    //Service --> Attachment
    //private Map<String, Orchestration_AttachmentWrapper> serviceToAttachMap = new Map<String, Orchestration_AttachmentWrapper>();
    private Map<Id, List<Orchestration_Technical__c>> serviceToAttachMap = new Map<Id, List<Orchestration_Technical__c>>();
    //Store multiple records for a step at a place
    private Map<String, Set<String>> stepRelationshipMap = new Map<String, Set<String>>();
    //Store the active step Id
    private String currentStep = '';
    //Store the Id of the step where limit got hit
    private String pendingStep = '';
    //Collection to store attachments that needs updation
   // private Map<String, Attachment> AttMapTobeUpdated = new Map<String, Attachment>();
   Map<Id, Orchestration_Technical__c> techObjMap = new Map<Id, Orchestration_Technical__c>();
  Map<Id, Technical_Child_Attribute__c> alltechChildAttrMap = new Map<Id, Technical_Child_Attribute__c>();

  	//  private Map<String, Attachment> servAttachMap = new Map<String, Attachment>();
  	private List<String> target = new List<String>{'FULFILMENT','ASSURANCE'};
  	Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
  	Set<String> toSkipsvcid = new Set<String>();
    Id stepId;
  	Map<String, Object> payloadMap=new Map<String,Object>();
	    Set<Id> orderIds = new Set<Id>();


  	protected Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();
    private Map<Id, CSPOFA__Orchestration_Step__c> mapStepDetails = new Map<Id, CSPOFA__Orchestration_Step__c>();

    public void processUpdate(String payload) {
    system.debug('payload:'+payload); 
        
    // Deserialize payload
	Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(payload);
        
    /*List<Object> subscriptionLists = (List<Object>)m.get('subscriptionList');
    List <csord__Subscription__c> subscriptionList = (List<csord__Subscription__c>) (subscriptionLists);
        
    List<Object> serviceLists = (List<Object>)m.get('serviceListAll');
    List <csord__service__c> serviceListAll = (List<csord__service__c>) (serviceLists);*/
     
     //DN: commented out due to test class execution failure
     //orderIds = (Set<Id> ) m.get('orderIds');
     
     //DN: modified code start...
     /*List<Object> orderIdList = new List<Object>();
     orderIdList = (List<Object>) m.get('orderIds');
     
     for (Object currOrderId : orderIdList){
         orderIds.add((Id) currOrderId);
     }
     System.debug('[DN] orderIds: ' + orderIds);*/
     //DN: ...modified code end
    
    
    /*List<Id> ordIds= new List<Id> ();
        for(Object ordId: ordIdsObj) {
            ordIds.add((Id)String.valueOf(ordId));
     }
    Set<Id> orderIds = new Set<Id>(ordIds);
    //Set<Id> orderIds = (Set<Id>) m.get('orderIds');*/
	
	//ordId = new List<Id>(orderIds).get(0);
	//
	stepId = (String)m.get('StepId');
    String currentOrder = (String)m.get('Current');
    orderIds.add(currentOrder);    
    String processName = (String) m.get('ProcessName');
    //processedIds= (Map<Id, Orchestration_ProcessedRecords>)m.get('processedIds');
    //processedRecordIds  = processedIds.get(stepId);
    processedRecordIds = (Orchestration_ProcessedRecords) JSON.deserialize(JSON.serialize(m.get('ProcessedRecords')), Orchestration_ProcessedRecords.class);

        
    List<csord__Subscription__c> subscriptionList = Coms_PlatformCacheUtil.getAllSubscriptionFromCache(orderIds);
    List <csord__service__c> serviceListAll = Coms_PlatformCacheUtil.getAllServicesFromCache(orderIds);
    system.debug('resp from cache..........'+orderIds+' '+serviceListAll);
    Set<Id> servicesSet = new Set<Id>();	// serviceIds
    for(csord__service__c serv :serviceListAll) {
                servicesSet.add(serv.Id);
    }
    

        //Exception Handling
        try {
           // List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);
            //system.debug('stepList:'+stepList);
            //EDGE-170545 adding starts
            Set<Id> baseOrderSet = new Set<Id>();
            Set<Id> inflightOrderSet = new Set<Id>();
            //for(CSPOFA__Orchestration_Step__c step1 : stepList) 
            //{   
                if(processName =='Inflight Orchestration Process') 
                {
          			inflightOrderSet.add(currentOrder);    
                }
                else if(processName =='Order Fulfilment Process')
                {
                    baseOrderSet.add(currentOrder);
                }
                //Partial Proccessing - getting already processed records in previous transaction
                //processedRecordIds = getProcessedRecords(step1);

                    /*if (processedRecordIds != null) {
                        processedIds.put(stepId, processedRecordIds);
                        if(processedRecordIds != null  )
                            if(processedRecordIds.skipRecordsIds != null){
                                toSkipsvcid.addAll(processedRecordIds.skipRecordsIds);
                            }
                            if(processedRecordIds.serviceIds != null){
                                toSkipsvcid.addAll(processedRecordIds.serviceIds);
                            }
                        
                    }*/
            //}
            //EDGE-170545 adding ends
            //updated soql EDGE-192921, EDGE-170545

			 // Added by Poonam
			  //List <csord__service__c> serviceListAll = (List<csord__service__c>) Coms_PlatformCacheUtil.getAllServicesFromCache(orderIds);
			  List<csord__service__c> serviceList = new List<csord__service__c>();
			    for(csord__service__c serv :serviceListAll) {
                    if(!toSkipsvcid.contains(serv.Id)) {
                        serviceList.add(serv);
                    }
                }
			  Map<Id, csord__service__c> serviceMap = new Map<Id, csord__service__c> (serviceList);
			 
              //serviceMap = new Map<Id, csord__service__c>([SELECT Id, csord__Order__c, changeType__c, csord__Subscription__r.Suspension_reason__c,csordtelcoa__Service_Number__c, Scenario_Type__c,Sim_Serial_Number__c,csord__Subscription__c,csord__Status__c,csord__Service__c,csord__Service__r.changeType__c,csord__Order__r.Scenario_Type__c,csord__Subscription__r.orderversion__c,csord__Order__r.Fulfilment_Order_Version__c, csord__Order__r.Product_Basket__r.BasketType__c FROM csord__Service__c WHERE csord__Order__c IN :orderIds AND ( Id NOT IN : toSkipsvcid) /*AND csord__Service__c = null*/]);// EDGE-170096 Query change
            //Partial Proccessing - Id NOT IN : toSkipsvcid - skipping services already processed in previous transaction
            
            // EDGE-174930, Updated SOQL for EDGE-170545
            //List<csord__Subscription__c> subscriptionList = (List<csord__Subscription__c>) Coms_PlatformCacheUtil.getAllSubscriptionFromCache(orderIds);
            subMap = new Map<Id, csord__Subscription__c> (subscriptionList);
            // subMap=New Map<Id,csord__Subscription__c>([Select Id, csord__Order__c,csord__Status__c, csord__Order__r.csord__Status2__c,orderversion__c from csord__Subscription__c where csord__Order__c IN :orderIds]);
            Set<Id> serviceIds = new Set<Id>(); // Added as part of EDGE-170545


            
            // EDGE-174930, Updated SOQL for EDGE-170545
            // subMap=New Map<Id,csord__Subscription__c>([Select Id, csord__Order__c,csord__Status__c, csord__Order__r.csord__Status2__c,orderversion__c from csord__Subscription__c where csord__Order__c IN :orderIds]);
            
            if (serviceMap.size() > 0) {
                Set<String> servNumSet = new Set<String>(); 
                for (csord__service__c ser : serviceMap.values()) {
                    /*if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //Collection cannot be created there can process
                        return null;
                    }*/

                    //Create Order to Service Map
                    if (!orderServiceMap.containsKey(ser.csord__Order__c)) {
                        orderServiceMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                    } else {
                        orderServiceMap.get(ser.csord__Order__c).add(ser);
                    }
                    

                    //servNumSet.add(ser.csordtelcoa__Service_Number__c);
                    

                    // EDGE-170545 - Added below inflight and base order logic
                    if ((inflightOrderSet.contains(ser.csord__Order__c)) && (ser.csord__Subscription__r.orderversion__c == ser.csord__Order__r.Fulfilment_Order_Version__c))
                    {
                        if (!orderServiceMap.containsKey(ser.csord__Order__c)) {
                            orderServiceMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                        } else {
                            orderServiceMap.get(ser.csord__Order__c).add(ser);
                        }
                        servNumSet.add(ser.csordtelcoa__Service_Number__c);
                        serviceIds.add(ser.Id);
                    } 
                    
                    else if( baseOrderSet.contains(ser.csord__Order__c))
                    {
                        if (!orderServiceMap.containsKey(ser.csord__Order__c)) {
                            orderServiceMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                        } else {
                            orderServiceMap.get(ser.csord__Order__c).add(ser);
                        }
                        servNumSet.add(ser.csordtelcoa__Service_Number__c);
                        serviceIds.add(ser.Id);
                    }
                        set<Id>serSet = new set<Id>();
                        serSet.add(ser.id);
						List<Orchestration_Technical__c> technicalObjList = new List<Orchestration_Technical__c>();
                       technicalObjList = Coms_PlatformCacheUtil.getListofTechnicalObjectFromCache(serSet);

					 serviceToAttachMap.put(ser.id, technicalObjList);

                }
				
                //Added by Poonam
                List<Number__c> numberListAll = (List<Number__c>) Coms_PlatformCacheUtil.getNumberListFromCache(serviceIds);
                List<Number__c> numberList = new List<Number__c>();
                for(Number__c num :numberListAll) {
                    if(num.Mobile__c == 'Mobile') {
                        numberList.add(num);
                    }
                }
                for (Number__c num : numberList /*[SELECT Id, Service_Id__c, Mobile__c, Service_Number__c, IMSI__c, SimAvailabilityType__c,Sim_Serial_Number__c,SIM_Type__c FROM Number__c WHERE Service_Id__c IN :servNumSet AND Mobile__c = 'Mobile']*/) {

                    //Create Service Number to Number Map
                    ServNumToNumberMap.put(num.Service_Id__c, num);
                }
				
			
                
                        

                /*for (Attachment attch : [SELECT Id, body, parentId FROM Attachment WHERE parentId IN :serviceIds AND name = 'ServiceSpecifications.json']) {
                    //Create Service to Attachment Map
                    serviceToAttachMap.put(attch.parentId, new Orchestration_AttachmentWrapper(attch.Id, attch.body));
                  //  servAttachMap.put(attch.parentId,attch);
                }*/
            } /*else {
                //None of the order is eligible for processing
                return populateStepResults('Success: Processing is not required on the order', OrchestratorConstants.OrchestratorStep.Complete, (List<CSPOFA__Orchestration_Step__c>) steps);
            }*/

            //Step processing
            //for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    //Limit check
                    /*if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }*/

                    //Setting the current variable
                    currentStep = stepId;
                    
                /*     processedRecordIds = getProcessedRecords(step);

                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                    */

                    if (/*step.CSPOFA__Orchestration_Process__c != null &&*/ currentOrder != null) {
                        if (orderServiceMap.containsKey(currentOrder)) {
                            //Bulk Method - return true if limit hits
                            if (updateServiceSpec(currentOrder)) {
                                //Capturing the step where limit got
                               
                                //pendingStep = step.Id;
                                //Terminate the loop
                                //break;
                            }
                        }

                        //These will be marked as Complete directly
                        if (!stepRelationshipMap.containsKey(currentStep)) { // Check with PP
                            //Updating steps as complete where no processing required
                            //Partial Proccessing - Corrected the condition to have and for all processedIds records
                            /*if (processedIds.get(stepId) == null || (processedIds.get(stepId).attachmentIds.isempty() && processedIds.get(stepId).subsIds.isempty() && processedIds.get(stepId).serviceIds.isempty())) {
                            	//stepResults.put(step.Id, new stepResult('Success: Processing is not required on the order', OrchestratorConstants.OrchestratorStep.Complete));
                            	mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Processing is not required on the order',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                            }*/
                        }
                    } else {
                        //Updating steps as Error since no proper data linked to step
                        //stepResults.put(step.Id, new stepResult('Error: Steps do not have Orders', OrchestratorConstants.OrchestratorStep.Error));
                        mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: Steps do not have Orders',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
                    }
                } catch (Exception ex) {
                    //stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
                    mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
                }
           // }
            
            
        } catch (Exception ex) {
            mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
            /*for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
            }*/
        }
        
        
        updateServiceMap = new Map<Id, csord__service__c>(updateserviceList);

        if ( !updateServiceMap.isEmpty() || !updatesubMap.isEmpty() || !updateorderMap.isEmpty() || !techObjMap.isEmpty() || !currentStepskipRecIds.isEmpty()) {
            updateObjects();
        }
        //return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
        Coms_OrderParallelismUtil.updateStepStatus(mapStepDetails);
    }

    private Boolean updateServiceSpec(String ordId) {
        Set<String> skipRecordsIds = new Set<String>();
       boolean isAutocomplete = false;
       boolean isMigration = false;
       Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();
       Set<Id> subId = new Set<Id>();
      
         for (csord__service__c service : orderServiceMap.get(ordId)) {
			 
		Map<Id, Technical_Child_Attribute__c> techChildAttrMap = new Map<Id, Technical_Child_Attribute__c>();

		List<Orchestration_Technical__c> techobList = serviceToAttachMap.get(service.Id);
		
         //INC000095943631 - setting  isAutocomplete &isMigration to false on start of every service processing
        isAutocomplete = false;
        isMigration = false;
      
            
            /*if(processedIds.get(currentStep) != null && processedIds.get(currentStep).serviceIds != null && processedIds.get(currentStep).serviceIds.contains(service.id)){
                System.debug('Inside Continue');
                continue;
            }*/
              if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                       
                        pendingStep = currentStep;
                        break;
                    }
      
            //List<CS_SpecificationDTO.ServiceSpecification>fulfilmentSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            //List<CS_SpecificationDTO.ServiceSpecification>assuranceSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            //List<CS_SpecificationDTO.ServiceSpecification>allSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
             
            Map<String, String> AttrMap = new Map<String, String>();
            
            Number__c num = ServNumToNumberMap.get(service.csordtelcoa__Service_Number__c); 
            system.debug('num'+num);
            // EDGE-170096 start 
            if(service.Scenario_Type__c=='Replace SIM' && service.Sim_Serial_Number__c!= null ){
                AttrMap.put('SIMSerialNumber', service.Sim_Serial_Number__c);
                
            }
            else{ //EDGE-170096 end
 
                //Fetching the additional Attribute from the number record
               if (num != null && serviceToAttachMap.containsKey(service.Id)) { //Query - will it get serviceId?
                if (num.Sim_Serial_Number__c != null) {
                    AttrMap.put('SIMSerialNumber', num.Sim_Serial_Number__c);
                }
                
              }
            }
            
            //EDGE_174221 - Check SIMAvailabilityType for Shipping Required Flag.
             system.debug('num168'+num);
            if(num!= null){
            if (num.SimAvailabilityType__c != null  &&  num.SimAvailabilityType__c =='New SIM') { 
                        AttrMap.put('ShippingRequired', 'TRUE');
                
            }else {
                AttrMap.put('ShippingRequired', 'FALSE');
                    }
            
            
            if(service.changeType__c!='Change of Mobile Number'){ // EDGE-188748
                if(num.Service_Number__c != null && num.Service_Number__c != '')
                {
                //System.debug('CustomerFacingServiceId...'+MobileNumber);
                //newAddAttrMap.put('CustomerFacingServiceId',MobileNumber);
                AttrMap.put('CustomerFacingServiceId', num.Service_Number__c);
                }
            }
            
        
            if (num.IMSI__c != null & num.IMSI__c != '') {
                    AttrMap.put('IMSI', num.IMSI__c);
                }
                
              } 
              
              if(service.Scenario_Type__c!= null && service.Scenario_Type__c =='CHOWN'){ //EDGE-152473
                AttrMap.put('ShippingRequired', 'FALSE');  
              }
              
              
            system.debug('service.csord__Service__c'+service.csord__Service__c);
            if(service.csord__Service__c!=null) //added as part of EDGE-192921
              { 
                
                  if(service.csord__Service__r.changeType__c == 'Suspend' ||service.csord__Service__r.changeType__c == 'Resume' || service.csord__Service__r.changeType__c == 'Change of Mobile Number' || service.csord__Service__r.changeType__c =='Replace SIM'||(service.csord__Order__r.Product_Basket__r.BasketType__c!= null && service.csord__Order__r.Product_Basket__r.BasketType__c.equalsignorecase('Incoming'))) // EDGE-152473 added condition for chown
                  {
                       AttrMap.put('ShippingRequired', 'FALSE');
                  }
                  //Partial Proccessing - If the svc is processed or no processing is required on it then adding it to skip records so that it will not be picked up in next transaction for processing
                  skipRecordsIds.add(service.id);   
                  

              }

            //EDGE-166432 start
            if(num!= null && num.SIM_Type__c!= null){
                AttrMap.put('SIMType',num.SIM_Type__c);
                if(num.SIM_Type__c == 'SIM card')
                AttrMap.put('SKU', Label.SIM_card);
                else if(num.SIM_Type__c == 'eSIM') AttrMap.put('SKU', Label.eSIM); 
            }//EDGE-166432 end

            if(String.isNotBlank(service.csord__Subscription__r.Suspension_reason__c) && String.isNotBlank(service.changeType__c) 
                && service.changeType__c == 'Suspend'){
                String suspensionReason = 'NA';
                    //DPG 4545- if consition added
                    if(service.csord__Subscription__r.Suspension_reason__c.containsIgnoreCase('Requested by')){
                       
                if(service.csord__Subscription__r.Suspension_reason__c.containsIgnoreCase('Requested by Customer')){
                    suspensionReason = 'CUSTOMER';
                } else if(service.csord__Subscription__r.Suspension_reason__c.containsIgnoreCase('Requested by Telstra')){
                    suspensionReason = 'CREDIT MANAGEMENT';
                }
                AttrMap.put('SuspensionContext', suspensionReason);
            }
                    else{
                        //DPG -4545 condition for Suspend resume for AM plan
                        suspensionReason = service.csord__Subscription__r.Suspension_reason__c;
                        AttrMap.put('suspensionReason', suspensionReason);
                    }
                
            }

           System.debug('AttrMap:'+AttrMap);
                //Update Attachment
                if (AttrMap.size() > 0 && !serviceToAttachMap.isEmpty() && serviceToAttachMap.get(service.Id) != null) {
                    List<String> targetSystem = new List<String>{ 'FULFILMENT' };
                    

                    /*List<String> specCodes = new List<String>{ 'DMCAT_ProductSpecification_000263','DMCAT_ProductSpecification_001196_Fulfilment',
                                                                'DMCAT_ProductSpecification_000263','DMCAT_ProductSpecification_000871',
                                                                'DMCAT_ProductSpecification_000710','DMCAT_ProductSpecification_000966' };*/
                        //added 423 in speccodes as part of EDGE-192921
                      List<String> specCodes = new List<String>{ 'DMCAT_ProductSpecification_000263','DMCAT_ProductSpecification_000423','DMCAT_ProductSpecification_001196_Fulfilment'};
                    //system.debug('serviceToAttachMap232'+serviceToAttachMap.get(service.Id).attchBody.toString());
                    //String bodyToUpdate = Orchestration_Utility.addAdditionalAttribute(serviceToAttachMap.get(service.Id).attchBody.toString(), AttrMap, targetSystem, specCodes);
                    
			
		
		for( Orchestration_Technical__c techob :techobList){
		if(specCodes.contains(techob.Field_14__c)){
			//List<Technical_Child_Attribute__c> childAttrList=techob.Technical_Child_Attributes.Field_1__c;
			List<Technical_Child_Attribute__c> childAttrList = [SELECT Id, Field_1__c from Technical_Child_Attribute__c WHERE Orchestration_Technical__r.Id = :techob.Id and Field_1__c = :targetSystem[0]];
			// need to apply check for target system after checking with mary n rohit
			//Field_1__c for targetSystem
            if(!childAttrList.isEmpty()) {
                for(String at: AttrMap.keyset()){
                    Technical_Child_Attribute__c t1 = new Technical_Child_Attribute__c();
                    t1.Category__c ='Additional Attributes';
                    t1.Orchestration_Technical__c = techob.id;
                    t1.Complex_Attribute_Schema_Id__c = at; // adding name in field Complex_Attribute_Schema_Id__c
                    t1.Field_1__c = AttrMap.get(at); // adding value in field Field_1__c
                    alltechChildAttrMap.put(t1.id,t1);
                }
            }

		}}		

					
					/* System.debug('bodyToUpdate:'+bodyToUpdate);
                    if (!bodyToUpdate.equals('false')) {
                        //if (!hasDMLRowsLimitExceeded()) {
                            Attachment attAdd = new Attachment(Id = serviceToAttachMap.get(service.Id).attchId);
                            attAdd.body = Blob.valueOf(bodyToUpdate);
                            AttMapTobeUpdated.put(attAdd.id, attAdd);
                            //Maintain the relationship
                            if (!stepRelationshipMap.containsKey(currentStep)) {
                                stepRelationshipMap.put(currentStep, new Set<String>{ attAdd.Id });
                            } else {
                                stepRelationshipMap.get(currentStep).add(attAdd.Id);
                            }
                        /*} else {
                            //Limit got Hit
                            return true;
                        }
                    }
                    
                }*/
        
        // EDGE-174930 start 
        /*system.debug('serviceToAttachMap::'+serviceToAttachMap);
        if(!serviceToAttachMap.isEmpty() && serviceToAttachMap.get(service.Id) != null){
             if (serviceToAttachMap.containsKey(service.id)) {
                String attachmentBody = serviceToAttachMap.get(service.Id).attchBody.toString();
                system.debug('attachmentBody:'+attachmentBody);
                fulfilmentSrvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(attachmentBody), 'FULFILMENT'));
                assuranceSrvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(attachmentBody), 'ASSURANCE'));
                
        }
            
      if(!fulfilmentSrvspecList.isEmpty()){
      allSrvspecList.addAll(fulfilmentSrvspecList);}
      if(!assuranceSrvspecList.isEmpty()){
      allSrvspecList.addAll(assuranceSrvspecList);}
      
            system.debug('allSrvspecList:'+allSrvspecList);*/
      
            if(service.changeType__c!= null && service.changeType__c.containsIgnoreCase('Migration')){ //EDGE-194053
                
                isMigration = true;
                
            }
          
            if(service.csord__Order__r.Scenario_Type__c!=null && service.csord__Order__r.Scenario_Type__c.containsIgnoreCase('Device Replacement'))
            {
                isAutocomplete = false;
                
            }
			
			// for metadata attributes check with rohit
			
			/*else if(!fulfilmentSrvspecList.isEmpty()){
                for (CS_SpecificationDTO.ServiceSpecification spec : fulfilmentSrvspecList) {
                    system.debug('spec.MetadataAttributes:'+spec.MetadataAttributes);
                    if(!spec.MetadataAttributes.isEmpty()){
                        system.debug('spec.SimpleAttributes'+spec.MetadataAttributes);
                        for (CS_SpecificationDTO.MetadataAttributes simpleAttr : spec.MetadataAttributes) {
                            system.debug('simpleAttr.name:'+simpleAttr.name);
                            if ('autocomplete'.containsIgnoreCase(simpleAttr.name)) {
                                if (!String.isBlank(simpleAttr.value) && ('true'.equalsignorecase(simpleAttr.value))) {
                                    system.debug('simpleAttr.value:'+simpleAttr.value);
                                    isAutocomplete = true;
                                    system.debug('spec.serviceId:'+spec.serviceId);
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                }
                
            } */
				//List<Technical_Child_Attribute__c> childAttrList=techob.Technical_Child_Attributes.Field_1__c;
  // get child attributes from technical obj 
       //List<Technical_Child_Attribute__c> childAttrList = new List<Technical_Child_Attribute__c> ();
       for( Orchestration_Technical__c techob :techobList){
           List<Technical_Child_Attribute__c> childAttrList = [SELECT Id, Field_1__c from Technical_Child_Attribute__c WHERE Orchestration_Technical__r.Id = :techob.Id and Field_1__c = :target];
                     for(Technical_Child_Attribute__c chAtt :childAttrList){
						 if(chAtt.Category__c == 'Metadata Attributes' && chAtt.Complex_Attribute_Schema_Id__c =='autocomplete' &&chAtt.Field_1__c== 'true'){
							  isAutocomplete = true;
 
						 }
					 }
         
          if(isAutocomplete == true){
         /* Attachment attach = new Attachment();
          String attbody = 'false';
                            
                               // String attbody = csedm.API_1.updateServiceSpecificationProperty(servAttachMap.get(specs.serviceId).body.toString(), specs.guid, 'status', 'Complete');
                               
                              if(AttMapTobeUpdated.containsKey(serviceToAttachMap.get(service.Id).attchId)){
                               attbody =  Orchestration_Utility.updatespec( AttMapTobeUpdated.get(serviceToAttachMap.get(service.Id).attchId).body.toString(), 'Complete',target);
                              }
                              else{
                                   attbody =  Orchestration_Utility.updatespec( serviceToAttachMap.get(service.Id).attchBody.toString(), 'Complete',target);
                              }


                              if (!attbody.equals('false')) {
                                            //if (!hasDMLRowsLimitExceeded()) {
                                               attach = new Attachment(Id = serviceToAttachMap.get(service.Id).attchId);
                                                system.debug('attbody ' + attbody);
                                               system.debug('attach ' + attach);
                                                attach.body = Blob.valueOf(attbody);
                                                  AttMapTobeUpdated.put(attach.id,attach);
                                                  
                                                if (!stepRelationshipMap.containsKey(currentStep)) {
                                                    stepRelationshipMap.put(currentStep, new Set<String>{ attach.Id });
                                                } else {
                                                    stepRelationshipMap.get(currentStep).add(attach.Id);
                                                }
                                            //} 
                                        } */
										
									//for( Orchestration_Technical__c techob :techobList){
			   						//  how to check for targetSystem (Field_1__c)== fulfillment ,assurance check with mary or rohit	
									//List<Technical_Child_Attribute__c> childAttrList = [SELECT Id, Field_1__c from Technical_Child_Attribute__c WHERE Orchestration_Technical__r.Id = :techob.Id and Field_1__c = :target];
                                    for(Technical_Child_Attribute__c techChildOb: childAttrList) {
                                        techob.Field_3__c ='Complete';
                                    }
										
                                    
									
												 if (!stepRelationshipMap.containsKey(currentStep)) {
											stepRelationshipMap.put(currentStep, new Set<String>{ techob.Id });
										} else {
											stepRelationshipMap.get(currentStep).add(techob.Id);
										}	 //}
                              }
                              else{
                                  //Partial Proccessing - When there is no update on service attachment
                                  skipRecordsIds.add(service.id);
                              }
  
                   
             
        if(isAutocomplete == true && isMigration == false){
             service.csord__Status__c = 'In Progress';
             updateserviceList.add(service);
       system.debug('updateserviceList'+updateserviceList);
            // if (!hasDMLRowsLimitExceeded()) {
                 if (!stepRelationshipMap.containsKey(currentStep)) {
                    stepRelationshipMap.put(currentStep, new Set<String>{ service.Id });
                 } else {
                    stepRelationshipMap.get(currentStep).add(service.Id);
                 }
            /* }else {
                //Limit got Hit
                return true;
             }*/
             subId.add(service.csord__Subscription__c);
     
             system.debug('subMap:'+subMap);
       system.debug('sub:'+subMap.get(service.csord__Subscription__c));
             //Sonar Fix -SOQL in For Loop
            //for(csord__Subscription__c  sub : [Select Id, csord__Status__c, csord__Order__r.csord__Status2__c from csord__Subscription__c  where Id IN:subId]){
            if (subMap.containsKey(service.csord__Subscription__c)){
        system.debug('in if');
                csord__Subscription__c sub =subMap.get(service.csord__Subscription__c);
                sub.csord__Status__c = 'Provisioning In Progress';
                sub.csord__Order__r.csord__Status2__c ='In Progress';
                updatesubMap.put(sub.id,sub);
        system.debug('updatesubMap:'+updatesubMap);
                //if (!hasDMLRowsLimitExceeded()) {
                    if (!stepRelationshipMap.containsKey(currentStep)) {
                        stepRelationshipMap.put(currentStep, new Set<String>{ sub.Id });
                     } else {
                        stepRelationshipMap.get(currentStep).add(sub.Id);
                     }
                /*}else {
                    //Limit got Hit
                    return true;
                 }*/
                updateorderMap.put(sub.csord__Order__c,sub.csord__Order__r);
                //if (!hasDMLRowsLimitExceeded()) {
                    if (!stepRelationshipMap.containsKey(currentStep)) {
                        stepRelationshipMap.put(currentStep, new Set<String>{ sub.csord__Order__c });
                     } else {
                        stepRelationshipMap.get(currentStep).add(sub.csord__Order__c);
                     }
                /*}else {
                    //Limit got Hit
                    return true;
                }*/
             }

             //}
              isAutocomplete = false;   
        }
        else{
            //Partial Proccessing - when there is no update on service(Migration scenario & plan)
            skipRecordsIds.add(service.id);
        }
         }
                   techObjMap.putAll(techobList);

				 
		 } }    
    //Partial Proccessing   
    if(skipRecordsIds != null && !skipRecordsIds.isEmpty()){
          currentStepskipRecIds.put(currentStep, skipRecordsIds);
      if (!stepRelationshipMap.containsKey(currentStep)) {
            stepRelationshipMap.put(currentStep, skipRecordsIds);
        } else {
         stepRelationshipMap.get(currentStep).addAll(skipRecordsIds);
         }
     
    }     
     
     
    // stepRelationshipMap.put(currentStep, skipRecordsIds);
     // EDGE-174930 end  
        return false;
    }
           
    public void updateObjects() {
        
        Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
        //Success DML Attachment Ids
      //  List<Id> SeviceAttchSuccessIds = new List<Id>();
        List<Id> serviceSuccessIds = new List<Id>();
        List<Id> subsSuccessIds = new List<Id>();
        List<Id> orderSuccessIds = new List<Id>();
        List<Id> attchSuccessIds = new List<Id>();
        List<String> skipIds = new List<String>();
         
        //List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
        //Updating all the order records
        
       /* if (!servAttachMap.isEmpty()) {
            updateResult = Database.update(servAttachMap.values(), false);
            //Storing the Service attachment success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    SeviceAttchSuccessIds.add(rslt.getId());
                }
            }
        }*/
        system.debug('updateServiceMap:'+updateServiceMap);
        //system.debug('skipRecordsIds:'+skipRecordsIds);
        if (!updateServiceMap.isEmpty()) {
            Orchestration_PlatformCacheUtility.updatePlatformCache(updateServiceMap.values());
            /*updateResult = Database.update(updateServiceMap.values(), false);
            //Storing the Service success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    serviceSuccessIds.add(rslt.getId());
                }
            }*/
			            for (Id serId : updateServiceMap.keySet()) {
					     serviceSuccessIds.add(serId);

						}
        }
        
        if (!updatesubMap.isEmpty()) {
            Orchestration_PlatformCacheUtility.updatePlatformCache(updatesubMap.values());
            /*updateResult = Database.update(updatesubMap.values(), false);
            //Storing the subscription success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    subsSuccessIds.add(rslt.getId());
                }
            }*/
			for (Id subId : updatesubMap.keySet()) {
					     subsSuccessIds.add(subId);

						}
        }
        
        if (!updateorderMap.isEmpty()) {
            Orchestration_PlatformCacheUtility.updatePlatformCache(updateorderMap.values());
            /*updateResult = Database.update(updateorderMap.values(), false);
            //Storing the Order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    orderSuccessIds.add(rslt.getId());
                }
            }*/
			for (Id ordId : updateorderMap.keySet()) {
					     orderSuccessIds.add(ordId);

						}
        }
        
        if (!techObjMap.isEmpty()) {
            Orchestration_PlatformCacheUtility.updatePlatformCache(techObjMap.values());
            /*updateResult = Database.update(AttMapTobeUpdated.values(), false);
            //Storing the attachment success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    attchSuccessIds.add(rslt.getId());
                }
            }*/
			for (Id techId : techObjMap.keySet()) {
					     attchSuccessIds.add(techId);

						}
        }
        
        if(!alltechChildAttrMap.isEmpty()){
			            Orchestration_PlatformCacheUtility.updatePlatformCache(alltechChildAttrMap.values());

		}
         //Iteration over each step
        for (Id stepId : stepRelationshipMap.keySet()) {
        boolean isFailed = false;
        perStepSuccessIds.attachmentIds = new Set<String>();
        perStepSuccessIds.subsIds = new Set<String>();
        perStepSuccessIds.serviceIds= new Set<String>();
        perStepSuccessIds.skipRecordsIds= new Set<String>();
        //Iteration over each step
       
        system.debug('stepRelationshipMap:'+stepRelationshipMap);
        system.debug('serviceSuccessIds:'+serviceSuccessIds);
        Set<String> serid = new Set<String>();
       
           //Partial Proccessing - Adding records completed in previous step to perStepSuccessIds 
            if(processedRecordIds != null && processedRecordIds.serviceIds != null){
                perStepSuccessIds.serviceIds.addAll(processedRecordIds.serviceIds);
                perStepSuccessIds.skipRecordsIds.addAll(processedRecordIds.serviceIds);
            }
            if(processedRecordIds != null && processedRecordIds.skipRecordsIds != null){
                perStepSuccessIds.skipRecordsIds.addAll(processedRecordIds.skipRecordsIds);
            }
             if(processedRecordIds != null && processedRecordIds.attachmentIds != null){
                perStepSuccessIds.attachmentIds.addAll(processedRecordIds.attachmentIds);
            }
            if(currentStepskipRecIds != null && currentStepskipRecIds.get(stepId) != null){
                perStepSuccessIds.skipRecordsIds.addAll(currentStepskipRecIds.get(stepId));
                skipIds.addAll(currentStepskipRecIds.get(stepId));
                
            }

       
            
            
         for (Id recId : stepRelationshipMap.get(stepId)) {
             system.debug('recId:'+recId);
                if (attchSuccessIds.contains(recId)) {serid.add(recId);
                     system.debug('serid:'+serid);
                     perStepSuccessIds.attachmentIds.add(recId);
                } else if (subsSuccessIds.contains(recId)) {serid.add(recId);
                     system.debug('serid1:'+serid);
                     perStepSuccessIds.subsIds.add(recId);
                } else if (serviceSuccessIds.contains(recId)) {serid.add(recId);
                    system.debug('serid2:'+serid);
                    //Partial Proccessing - adding records of current transaction
                    perStepSuccessIds.serviceIds.add(recId);
                    perStepSuccessIds.skipRecordsIds.add(recId);
                   
                } else if (!(orderSuccessIds.contains(recId) || subsSuccessIds.contains(recId) || serviceSuccessIds.contains(recId) || attchSuccessIds.contains(recId) || skipIds.contains(recId)) ) {
                    ////Partial Proccessing - added check for skipIds as well
                    //Failure
                    isFailed = true;
                }
            
         }
         
            if (!isFailed && (String.isBlank(pendingStep) || !pendingStep.equals(stepId))) {
                //Partial Proccessing - removed perStepSuccessIds for success scenario from stepResults
                //stepResults.put(stepId, new stepResult('Success: Additional Attributes added on the Service Specs', OrchestratorConstants.OrchestratorStep.Complete));
                 mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c='Success: Additional Attributes added on the Service Specs',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));

			} else if (!isFailed && (!String.isBlank(pendingStep) && pendingStep.equals(stepId))) {
                //stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress,perStepSuccessIds));
                 mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c='Success: Partial records processed',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.InProgress,JSON__c=(String)JSON.serialize(perStepSuccessIds, true)));

			} else {
                //stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error,perStepSuccessIds));
                 mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c='Error: Unable to process records',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error,JSON__c=(String)JSON.serialize(perStepSuccessIds, true)));

			}
            }
    }

    /*private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [SELECT Id, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c,JSON__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];

        for (CSPOFA__Orchestration_Step__c step : stepList) {
            //Fetching the order Set
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
                System.debug('stepList...'+step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
            }
        }
    
        //Returning the step list
        return stepList;
    }*/

    /*public override boolean hasDMLRowsLimitExceeded() {
        if (AttMapTobeUpdated.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }*/
}