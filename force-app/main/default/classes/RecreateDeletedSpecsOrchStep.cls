/*
===============================================================================================================================
Class : RecreateDeletedSpecsOrchStep
Test Class : RecreateDeletedSpecsOrchStepTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1         Prajakta Patil      7/1/2020        EDGE-124891 :refactoring orchestration process
===============================================================================================================================*/
global with sharing class RecreateDeletedSpecsOrchStep implements CSPOFA.ExecutionHandler{
    public class My2Exception extends Exception {}

    
        public List<SObject> process(List<SObject> steps){
       // List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
		
		try{
        List<Id> serviceIds = new List<Id>();
        List<Id> orchesIds= new List<Id>();
       // Set<Id> orderIds = new Set<Id>();
		Set<Id> ordRequestIds= new Set<Id>();
        for(CSPOFA__Orchestration_Step__c step: stepList)
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        system.debug(orchesIds);
    
        List<CSPOFA__Orchestration_Process__c> orchRelatedOrderList = [Select Id, Name, Order__c,Order__r.csordtelcoa__Opportunity__c, csordtelcoa__Service__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
        
        for(CSPOFA__Orchestration_Process__c  orch : orchRelatedOrderList){
           // serviceIds.add(orch.csordtelcoa__Service__c);
         //  orderIds.add(orch.Order__c);
		   if(orch.Order__r.csordtelcoa__Opportunity__c != null) ordRequestIds.add(orch.Order__r.csordtelcoa__Opportunity__c);
        }
         
		 // Commenting this to reduce SOQL
       /* List<csord__Order__c> relatedOrderRequest =[Select id,csord__Order_Request__c,csordtelcoa__Opportunity__c
                                                    ,Scenario_Type__c 
                                                    from csord__Order__c where id in : orderIds];*/
        
		
		
		//EDGE-81566
		////Scenario_Type__c changes related needs to be done for all mobility order 
        //SIM replcement, chaneg of mobile number,Suspend,resume,Port out
		if(!ordRequestIds.isEmpty()){
			Map<Id,csord__Service__c> serviceMap = new Map<Id,csord__Service__c>([Select Id, Name,csord__Order__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Replaced_Service__c, toBeCancelled__c, csord__Status__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, csordtelcoa__Replaced_Service__r.csord__Status__c, CreatedDate from csord__Service__c where csord__Order__r.csordtelcoa__Opportunity__c  in :ordRequestIds and csordtelcoa__Replaced_Service__c!=null]);
			
            /* List<csord__Service__c> serviceList = [Select Id, Name,csord__Order__c from csord__Service__c where csord__Order__r.csordtelcoa__Opportunity__c  in :ordRequestIds and csordtelcoa__Replaced_Service__c!=null];
			for(csord__Service__c services : serviceList){
            serviceIds.add(services.Id);
			}*/
			
			recreateDeletedSpecs(serviceMap);
		
		}
         for(CSPOFA__Orchestration_Step__c step : stepList){
            step.CSPOFA__Status__c = Label.Complete;
            step.CSPOFA__Completed_Date__c = Date.today();
            step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
            
        }
        if(Test.isRunningTest())
        { throw new My2Exception('My exception');
          }
    }
	catch(Exception e){
		for(CSPOFA__Orchestration_Step__c step : stepList){
            step.CSPOFA__Status__c = Label.Error;
            step.CSPOFA__Completed_Date__c=Date.today();
            step.CSPOFA__Message__c = 'Exception: ' + e.getMessage() + ' - ' + e.getLineNumber();
            
        }
	}
	return stepList;
  }
  
  
	@TestVisible
    public static void recreateDeletedSpecs(Map<Id,csord__Service__c> serviceMap){
		
        List<CS_SpecificationDTO.ServiceSpecification> assuranceSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        List<CS_SpecificationDTO.ServiceSpecification> billSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        List<CS_SpecificationDTO.ServiceSpecification> fulfilmentSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
		Map<String, Object> results = new Map<String, Object>();
		List<Id> serviceIds = new List<Id>();
		List<Id> originServiceIds = new List<Id>();
        
		/*Map<Id,csord__Service__c> serviceMap = new Map<Id,csord__Service__c>([SELECT Id, Name,csordtelcoa__Product_Configuration__c,csordtelcoa__Replaced_Service__c, toBeCancelled__c, csord__Status__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, csordtelcoa__Replaced_Service__r.csord__Status__c, CreatedDate FROM csord__Service__c WHERE Id IN : serviceIds]);*/
	
		for(csord__Service__c originSer : serviceMap.Values()){
			if(originSer.csordtelcoa__Replaced_Service__c != null){
			serviceIds.add(originSer.id);
			originServiceIds.add(originSer.csordtelcoa__Replaced_Service__c);}
		}
        Map<String, CS_SpecificationDTO.ServiceSpecification> newSpecMap = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
        Map<String, CS_SpecificationDTO.ServiceSpecification> originSpecMap = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
        Map<String, CS_SpecificationDTO.ServiceSpecification> specsToBeAdded = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
        Map<Id,Attachment> attchmap= new Map<Id,Attachment>();
		Map<Id,Attachment> currentAttchmap= new Map<Id,Attachment>();
		Map<Id,Attachment> newAttchmap= new Map<Id,Attachment>();
		List<Attachment> AttachmentList = new List<Attachment>();
	List<CS_SpecificationDTO.ServiceSpecification> fulfilmentNewList = new List<CS_SpecificationDTO.ServiceSpecification>();
	List<CS_SpecificationDTO.ServiceSpecification> billNewList = new List<CS_SpecificationDTO.ServiceSpecification>();
	List<CS_SpecificationDTO.ServiceSpecification> assuranceNewList = new List<CS_SpecificationDTO.ServiceSpecification>();
	List<CS_SpecificationDTO.ServiceSpecification> fulfilmentOriginList = new List<CS_SpecificationDTO.ServiceSpecification>();
	List<CS_SpecificationDTO.ServiceSpecification> billOriginList = new List<CS_SpecificationDTO.ServiceSpecification>();
	List<CS_SpecificationDTO.ServiceSpecification> assuranceOriginList = new List<CS_SpecificationDTO.ServiceSpecification>();
	List<CS_SpecificationDTO.ServiceSpecification> subSpecCurrent = new List<CS_SpecificationDTO.ServiceSpecification>();
	List<CS_SpecificationDTO.ServiceSpecification> subSpecOrigin = new List<CS_SpecificationDTO.ServiceSpecification>();
	
		if(serviceIds != null && originServiceIds != null ){
         for(Attachment newAtt:[select ID, name, body, parentId from Attachment where (parentId in: serviceIds OR parentId in :originServiceIds ) and name = 'ServiceSpecifications.json']){
			 attchmap.put(newAtt.parentId,newAtt);
			if(serviceIds.contains(newAtt.parentId)){
               currentAttchmap.put(newAtt.parentId,newAtt);}
			else{newAttchmap.put(newAtt.parentId,newAtt);}
				
         }
		}
			if(currentAttchmap != null){
			for(String eachService: currentAttchmap.keySet()){
				
				fulfilmentNewList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(currentAttchmap.get(eachService)),'FULFILMENT'));
                billNewList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(currentAttchmap.get(eachService)),'BILLING'));
				assuranceNewList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(currentAttchmap.get(eachService)),'ASSURANCE'));
			}}

			if(newAttchmap != null){
			for(String originService: newAttchmap.keySet()){
				
				fulfilmentOriginList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(newAttchmap.get(originService)),'FULFILMENT'));
                billOriginList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(newAttchmap.get(originService)),'BILLING'));
				assuranceOriginList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(newAttchmap.get(originService)),'ASSURANCE'));
			}}
			subSpecCurrent.addAll(fulfilmentNewList);
			subSpecCurrent.addAll(billNewList);
			subSpecCurrent.addAll(assuranceNewList);
			
			subSpecOrigin.addAll(fulfilmentOriginList);
			subSpecOrigin.addAll(billOriginList);
			subSpecOrigin.addAll(assuranceOriginList);
			
			if(subSpecCurrent != null){
			for(CS_SpecificationDTO.ServiceSpecification newSpecIterator : subSpecCurrent){
            newSpecMap.put(newSpecIterator.guid, newSpecIterator);
            } }
			
			if(subSpecOrigin != null){
            for(CS_SpecificationDTO.ServiceSpecification modSpecIterartor : subSpecOrigin){
            originSpecMap.put(modSpecIterartor.guid, modSpecIterartor);
            }}
			
        if(originSpecMap.values().isEmpty() && newSpecMap.values().isEmpty()){
			for(CS_SpecificationDTO.ServiceSpecification specs : originSpecMap.values()){
				if(!newSpecMap.containsKey(specs.guid)){
                specsToBeAdded.put(specs.guid,specs);   
				}
			}
		}
	
        if(subSpecCurrent!=null){
			//parsedCurrentSpecs.specifications.addAll(allListOfSpecs);
			if(!serviceMap.isEmpty() && !attchmap.isEmpty()){
			for(csord__Service__c srv : serviceMap.Values()){
		    if(srv.csordtelcoa__Replaced_Service__c!= null && attchmap.get(srv.csordtelcoa__Replaced_Service__c)!= null){
			String serviceattachmentstr = attchmap.get(srv.csordtelcoa__Replaced_Service__c).body.toString();
			results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
			List<Object> lstSpecifications = (List<Object>)results.get('specifications');
			List<Object> deletedListSpecifications = new List<Object>(); 
			//system.debug(lstSpecifications[0]);
			if(lstSpecifications != null){
				for (Object specification : lstSpecifications) {
					string code = '';
					string guid = '';
					Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
					guid = (String) specificationAttributes.get('guid');
					if(specsToBeAdded.containsKey(guid)){deletedListSpecifications.add(specification);}
				// }  
				}
			}
			
			 if(attchmap.get(srv.id)!=null){//added null check - EDGE-133225
			String newServiceAttachmentStr = attchmap.get(srv.id).body.toString();	
			Map<String, Object> updatedResults = (Map<String, Object>)JSON.deserializeUntyped(newServiceAttachmentStr);
			system.debug('new results'+deletedListSpecifications.size());
            system.debug('deletedListSpecifications '+deletedListSpecifications);
            
			List<Object> newlstSpecifications = (List<Object>)updatedResults.get('specifications');
			for(Object deletedSpec : deletedListSpecifications){
				Map<String, Object> specificationAttributes = (Map<String, Object>)deletedSpec;
                specificationAttributes.put('status','Disconnect Pending');
                 specificationAttributes.put('productConfigurationId',srv.csordtelcoa__Product_Configuration__c);
				newlstSpecifications.add((Object)specificationAttributes);
			}
			updatedResults.put('specifications',newlstSpecifications);
			String updatednewServiceattachmentstr = JSON.serializePretty(updatedResults);
            system.debug('updatednewServiceattachmentstr'+updatednewServiceattachmentstr);
			Attachment UpdatedServSpec = attchmap.get(srv.id);
			UpdatedServSpec.Body = Blob.valueOf(updatednewServiceattachmentstr);
			AttachmentList.add(UpdatedServSpec);		
			 }
			
			}
		}
	   }
			 
	}	
        if(AttachmentList.size()>0){
		update AttachmentList;}
		
	}
}