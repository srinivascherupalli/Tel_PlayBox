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
global with sharing class Orchestration_LinkNumAndServOrchHandler extends Orchestration_AbstractStepHandler {
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
    private Map<String, Orchestration_AttachmentWrapper> serviceToAttachMap = new Map<String, Orchestration_AttachmentWrapper>();
    //Store multiple records for a step at a place
    private Map<String, Set<String>> stepRelationshipMap = new Map<String, Set<String>>();
    //Store the active step Id
    private String currentStep = '';
    //Store the Id of the step where limit got hit
    private String pendingStep = '';
    //Collection to store attachments that needs updation
    private Map<String, Attachment> AttMapTobeUpdated = new Map<String, Attachment>();
  //  private Map<String, Attachment> servAttachMap = new Map<String, Attachment>();
  private List<String> target = new List<String>{'FULFILMENT','ASSURANCE'};
  Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
  Set<String> toSkipsvcid = new Set<String>();

    /**************************************************************
        Name: process
        Parameters: List<SObject> steps
        Return Type: List<SObject>
        Description: Overriding the process method of ExecutionHandler interface
      *******************************************************************/
    public override List<SObject> process(List<SObject> steps) {
    system.debug('steps:'+steps); 
        List<SObject> sobjList=new List<SObject>();// Added as part of EDGE-222326
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            return sobjList;// Added as part of EDGE-222326
        }

        //Exception Handling
        try {
            List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);
            system.debug('stepList:'+stepList);
            //EDGE-170545 adding starts
            Set<Id> baseOrderSet = new Set<Id>();
            Set<Id> inflightOrderSet = new Set<Id>();
            for(CSPOFA__Orchestration_Step__c step1 : stepList) 
            {   
                if(step1.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name =='Inflight Orchestration Process') 
                {
          inflightOrderSet.add(step1.CSPOFA__Orchestration_Process__r.Order__c);    
                }
                else if(step1.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name =='Order Fulfilment Process')
                {
                    baseOrderSet.add(step1.CSPOFA__Orchestration_Process__r.Order__c);
                }
                //Partial Proccessing - getting already processed records in previous transaction
                processedRecordIds = getProcessedRecords(step1);

                    if (processedRecordIds != null) {
                        processedIds.put(step1.Id, processedRecordIds);
                        if(processedRecordIds != null  )
                            if(processedRecordIds.skipRecordsIds != null){
                                toSkipsvcid.addAll(processedRecordIds.skipRecordsIds);
                            }
                            if(processedRecordIds.serviceIds != null){
                                toSkipsvcid.addAll(processedRecordIds.serviceIds);
                            }
                        
                    }
            }
            //EDGE-170545 adding ends
            //updated soql EDGE-192921, EDGE-170545


              serviceMap = new Map<Id, csord__service__c>([SELECT Id, csord__Order__c, changeType__c, csord__Subscription__r.Suspension_reason__c,csordtelcoa__Service_Number__c, Scenario_Type__c,Sim_Serial_Number__c,csord__Subscription__c,csord__Status__c,csord__Service__c,csord__Service__r.changeType__c,csord__Order__r.Scenario_Type__c,csord__Subscription__r.orderversion__c,csord__Order__r.Fulfilment_Order_Version__c, csord__Order__r.Product_Basket__r.BasketType__c,Action_Type__c FROM csord__Service__c WHERE csord__Order__c IN :orderIds AND ( Id NOT IN : toSkipsvcid) /*AND csord__Service__c = null*/]);// EDGE-170096 Query change
            //Partial Proccessing - Id NOT IN : toSkipsvcid - skipping services already processed in previous transaction
            
            // EDGE-174930, Updated SOQL for EDGE-170545
             subMap=New Map<Id,csord__Subscription__c>([Select Id, csord__Order__c,csord__Status__c, csord__Order__r.csord__Status2__c,orderversion__c from csord__Subscription__c where csord__Order__c IN :orderIds]);
            Set<Id> serviceIds = new Set<Id>(); // Added as part of EDGE-170545


            
            // EDGE-174930, Updated SOQL for EDGE-170545
             subMap=New Map<Id,csord__Subscription__c>([Select Id, csord__Order__c,csord__Status__c, csord__Order__r.csord__Status2__c,orderversion__c from csord__Subscription__c where csord__Order__c IN :orderIds]);
            
            if (serviceMap.size() > 0) {
                Set<String> servNumSet = new Set<String>(); 
                for (csord__service__c ser : serviceMap.values()) {
                    /*if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //Collection cannot be created there can process
                        return null;
                    }*/

                    //Create Order to Service Map
                    /*if (!orderServiceMap.containsKey(ser.csord__Order__c)) {
                        orderServiceMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                    } else {
                        orderServiceMap.get(ser.csord__Order__c).add(ser);
                    }*/
                    

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

                }

                for (Number__c num : [SELECT Id, Service_Id__c, Mobile__c, Service_Number__c, IMSI__c, SimAvailabilityType__c,Sim_Serial_Number__c,SIM_Type__c FROM Number__c WHERE Service_Id__c IN :servNumSet AND Mobile__c = 'Mobile']) {

                    //Create Service Number to Number Map
                    ServNumToNumberMap.put(num.Service_Id__c, num);
                }

                for (Attachment attch : [SELECT Id, body, parentId FROM Attachment WHERE parentId IN :serviceIds AND name = 'ServiceSpecifications.json']) {
                    //Create Service to Attachment Map
                    serviceToAttachMap.put(attch.parentId, new Orchestration_AttachmentWrapper(attch.Id, attch.body));
                  //  servAttachMap.put(attch.parentId,attch);
                }
            } else {
                //None of the order is eligible for processing
                return populateStepResults('Success: Processing is not required on the order', OrchestratorConstants.OrchestratorStep.Complete, (List<CSPOFA__Orchestration_Step__c>) steps);
            }

            //Step processing
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    //Limit check
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }

                    //Setting the current variable
                    currentStep = step.Id;
                    
                /*     processedRecordIds = getProcessedRecords(step);

                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                    */

                    if (step.CSPOFA__Orchestration_Process__c != null && step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                        if (orderServiceMap.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                            //Bulk Method - return true if limit hits
                            if (updateServiceSpec(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                                //Capturing the step where limit got
                               
                                pendingStep = step.Id;
                                //Terminate the loop
                                break;
                            }
                        }

                        //These will be marked as Complete directly
                        if (!stepRelationshipMap.containsKey(currentStep)) {
                            //Updating steps as complete where no processing required
                            //Partial Proccessing - Corrected the condition to have and for all processedIds records
                            if (processedIds.get(step.Id) == null || (processedIds.get(step.Id).attachmentIds.isempty() && processedIds.get(step.Id).subsIds.isempty() && processedIds.get(step.Id).serviceIds.isempty())) {
                            stepResults.put(step.Id, new stepResult('Success: Processing is not required on the order', OrchestratorConstants.OrchestratorStep.Complete));}
                        }
                    } else {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Steps do not have Orders', OrchestratorConstants.OrchestratorStep.Error));
                    }
                } catch (Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
                }
            }
            
            
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
            }
        }
        
        
        updateServiceMap = new Map<Id, csord__service__c>(updateserviceList);

        if ( !updateServiceMap.isEmpty() || !updatesubMap.isEmpty() || !updateorderMap.isEmpty() || !AttMapTobeUpdated.isEmpty() || !currentStepskipRecIds.isEmpty()) {
            updateObjects();
        }
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    private Boolean updateServiceSpec(String ordId) {
        Set<String> skipRecordsIds = new Set<String>();
       boolean isAutocomplete = false;
       boolean isMigration = false;
       Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();
       Set<Id> subId = new Set<Id>();
      
         for (csord__service__c service : orderServiceMap.get(ordId)) {
         //INC000095943631 - setting  isAutocomplete &isMigration to false on start of every service processing
        isAutocomplete = false;
        isMigration = false;
      
            
            if(processedIds.get(currentStep) != null && processedIds.get(currentStep).serviceIds != null && processedIds.get(currentStep).serviceIds.contains(service.id)){
                System.debug('Inside Continue');
                continue;
            }
              if (Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()) {
                        //terminate the loop
                       
                        pendingStep = currentStep;
                        break;
                    }
      
            List<CS_SpecificationDTO.ServiceSpecification>fulfilmentSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            List<CS_SpecificationDTO.ServiceSpecification>assuranceSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            List<CS_SpecificationDTO.ServiceSpecification>allSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
             
            Map<String, String> AttrMap = new Map<String, String>();
            
            Number__c num = ServNumToNumberMap.get(service.csordtelcoa__Service_Number__c); 
            system.debug('num'+num);
            // EDGE-170096 start 
            if(service.Scenario_Type__c=='Replace SIM' && service.Sim_Serial_Number__c!= null ){
                AttrMap.put('SIMSerialNumber', service.Sim_Serial_Number__c);
                
            }
            else{ //EDGE-170096 end
 
                //Fetching the additional Attribute from the number record
               if (num != null && serviceToAttachMap.containsKey(service.Id)) {
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
                    system.debug('serviceToAttachMap232'+serviceToAttachMap.get(service.Id).attchBody.toString());
                    String bodyToUpdate = Orchestration_Utility.addAdditionalAttribute(serviceToAttachMap.get(service.Id).attchBody.toString(), AttrMap, targetSystem, specCodes);
                     System.debug('bodyToUpdate:'+bodyToUpdate);
                    if (!bodyToUpdate.equals('false')) {
                        if (!hasDMLRowsLimitExceeded()) {
                            Attachment attAdd = new Attachment(Id = serviceToAttachMap.get(service.Id).attchId);
                            attAdd.body = Blob.valueOf(bodyToUpdate);
                            AttMapTobeUpdated.put(attAdd.id, attAdd);
                            //Maintain the relationship
                            if (!stepRelationshipMap.containsKey(currentStep)) {
                                stepRelationshipMap.put(currentStep, new Set<String>{ attAdd.Id });
                            } else {
                                stepRelationshipMap.get(currentStep).add(attAdd.Id);
                            }
                        } else {
                            //Limit got Hit
                            return true;
                        }
                    }
                    
                }
        
        // EDGE-174930 start 
        system.debug('serviceToAttachMap::'+serviceToAttachMap);
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
      
            system.debug('allSrvspecList:'+allSrvspecList);
      
            if(service.changeType__c!= null && service.changeType__c.containsIgnoreCase('Migration')){ //EDGE-194053
                
                isMigration = true;
                
            }
      
    
            if(service.csord__Order__r.Scenario_Type__c!=null && service.csord__Order__r.Scenario_Type__c.containsIgnoreCase('Device Replacement'))
            {
                isAutocomplete = false;
                
            }else if(!fulfilmentSrvspecList.isEmpty()){
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
                
            } 
      
      
         
            if(isAutocomplete == true){
          Attachment attach = new Attachment();
          String attbody = 'false';
                            
                               // String attbody = csedm.API_1.updateServiceSpecificationProperty(servAttachMap.get(specs.serviceId).body.toString(), specs.guid, 'status', 'Complete');
                               
                              if(AttMapTobeUpdated.containsKey(serviceToAttachMap.get(service.Id).attchId)){
                               attbody =  Orchestration_Utility.updatespec( AttMapTobeUpdated.get(serviceToAttachMap.get(service.Id).attchId).body.toString(), 'Complete',target);
                              }
                              else{
                                   attbody =  Orchestration_Utility.updatespec( serviceToAttachMap.get(service.Id).attchBody.toString(), 'Complete',target);
                              }


                              if (!attbody.equals('false')) {
                                            if (!hasDMLRowsLimitExceeded()) {
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
                                            } 
                                        }
                              
                              }
                              else{
                                  //Partial Proccessing - When there is no update on service attachment
                                  skipRecordsIds.add(service.id);
                              }
  
           }        
             //DPG-6193: Adding condition on ActionType and Status of Service
             if(isAutocomplete == true && isMigration == false && !service.Action_Type__c.equalsignorecase('PaidOut') && !service.Action_Type__c.equalsignorecase('PayOut')){
             service.csord__Status__c = 'In Progress';
             updateserviceList.add(service);
       system.debug('updateserviceList'+updateserviceList);
             if (!hasDMLRowsLimitExceeded()) {
                 if (!stepRelationshipMap.containsKey(currentStep)) {
                    stepRelationshipMap.put(currentStep, new Set<String>{ service.Id });
                 } else {
                    stepRelationshipMap.get(currentStep).add(service.Id);
                 }
             }else {
                //Limit got Hit
                return true;
             }
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
                if (!hasDMLRowsLimitExceeded()) {
                    if (!stepRelationshipMap.containsKey(currentStep)) {
                        stepRelationshipMap.put(currentStep, new Set<String>{ sub.Id });
                     } else {
                        stepRelationshipMap.get(currentStep).add(sub.Id);
                     }
                }else {
                    //Limit got Hit
                    return true;
                 }
                updateorderMap.put(sub.csord__Order__c,sub.csord__Order__r);
                if (!hasDMLRowsLimitExceeded()) {
                    if (!stepRelationshipMap.containsKey(currentStep)) {
                        stepRelationshipMap.put(currentStep, new Set<String>{ sub.csord__Order__c });
                     } else {
                        stepRelationshipMap.get(currentStep).add(sub.csord__Order__c);
                     }
                }else {
                    //Limit got Hit
                    return true;
                }
             }

             //}
              isAutocomplete = false;   
        }
        else{
            //Partial Proccessing - when there is no update on service(Migration scenario & plan)
            skipRecordsIds.add(service.id);
        }
      
    }     
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
           
    public override void updateObjects() {
        
        Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
        //Success DML Attachment Ids
      //  List<Id> SeviceAttchSuccessIds = new List<Id>();
        List<Id> serviceSuccessIds = new List<Id>();
        List<Id> subsSuccessIds = new List<Id>();
        List<Id> orderSuccessIds = new List<Id>();
        List<Id> attchSuccessIds = new List<Id>();
        List<String> skipIds = new List<String>();
         
        List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
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
            updateResult = Database.update(updateServiceMap.values(), false);
            //Storing the Service success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    serviceSuccessIds.add(rslt.getId());
                }
            }
        }
        
        if (!updatesubMap.isEmpty()) {
            updateResult = Database.update(updatesubMap.values(), false);
            //Storing the subscription success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    subsSuccessIds.add(rslt.getId());
                }
            }
        }
        
        if (!updateorderMap.isEmpty()) {
            updateResult = Database.update(updateorderMap.values(), false);
            //Storing the Order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    orderSuccessIds.add(rslt.getId());
                }
            }
        }
        
        if (!AttMapTobeUpdated.isEmpty()) {
            updateResult = Database.update(AttMapTobeUpdated.values(), false);
            //Storing the attachment success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    attchSuccessIds.add(rslt.getId());
                }
            }
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
            if(processedIds.get(stepId) != null && processedIds.get(stepId).serviceIds != null){
                perStepSuccessIds.serviceIds.addAll(processedIds.get(stepId).serviceIds);
                perStepSuccessIds.skipRecordsIds.addAll(processedIds.get(stepId).serviceIds);
            }
            if(processedIds.get(stepId) != null && processedIds.get(stepId).skipRecordsIds != null){
                perStepSuccessIds.skipRecordsIds.addAll(processedIds.get(stepId).skipRecordsIds);
            }
             if(processedIds.get(stepId) != null && processedIds.get(stepId).attachmentIds != null){
                perStepSuccessIds.attachmentIds.addAll(processedIds.get(stepId).attachmentIds);
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
                stepResults.put(stepId, new stepResult('Success: Additional Attributes added on the Service Specs', OrchestratorConstants.OrchestratorStep.Complete));
            } else if (!isFailed && (!String.isBlank(pendingStep) && pendingStep.equals(stepId))) {
                stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress,perStepSuccessIds));
            } else {
                stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error,perStepSuccessIds));
            }
            }
    }

    private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
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
    }

    public override boolean hasDMLRowsLimitExceeded() {
        if (AttMapTobeUpdated.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
}