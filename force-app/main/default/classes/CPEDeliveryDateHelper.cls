/*
===============================================================================================================================
Class : CPEDeliveryDateHelper
Developer Name : Kunal Dixit
Test Class : CPEDeliveryDateHelperTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Kunal Dixit         17/04,2019    EDGE-77677 Urgent fix to close B2B4 SIT : CPE delivery date value is not reflecting in the payload for PRM order
2.        Jainish Shukla      31/07/2018    
3.        Abinash Barik       03/20/2018    EDGE-74971 CPE delivery date value is not reflecting in the payload for PRM order
4.        Vaibhav Deshpande   23/12/2019    EDGE-127367  DML and SOQL inside FOR loop	
5.        Vaibhav Deshpande   03/01/2020    EDGE-124891  Refactoring orchestration process
===============================================================================================================================
*/

public with sharing class CPEDeliveryDateHelper {
    public static final Integer  workingDays = 10;
    public static void modifyCPEDeliveryDate(String subscriptionID) {
        DateTime startDate = null;
        Map<Id,Attachment> attachmentToUpdate=new Map<Id,Attachment>();
        System.debug('inside modifyCPEDeliveryDate');
        Logger2 logger = Logger2.getLogger('CPEDeliveryDateHandler');
        try{
            for(Appointment__c apptRecord: [select SlotId__c,Subscription__c, Notes__c,StartDate__c,EndDate__c from Appointment__c where Subscription__c = : subscriptionID]){
                if(apptRecord.StartDate__c!=null){startDate = apptRecord.StartDate__c;}
                break;
            }
            if(startDate!=null){
                //Commenting code as part of EDGE-127367
                //List<csord__Service__c> serviceList = [select id from csord__Service__c where csord__Subscription__c = : subscriptionID];
                //EDGE-127367 - created map to store service related data
                Map<Id,csord__Service__c> serviceMap = new Map<Id,csord__Service__c>([select id from csord__Service__c where csord__Subscription__c = : subscriptionID]);
                Map<String,String> serviceAttachmentMap=new Map<String,String>();
                Map<String,Attachment> servAttachmentRecordMap = new Map<String,Attachment>();
                /* EDGE-127367
                 * remove this query from inside forloop, resolved as per sonar findings
				*/
                for(Attachment att: [select Id,body,parentId from Attachment where parentId=:serviceMap.keyset()]){
                    serviceAttachmentMap.put(att.parentId,att.Body.toString());
                    servAttachmentRecordMap.put(att.parentId,att);
                }
                
                for(csord__Service__c serv : serviceMap.values()){
                    String specJSON = csedm.API_1.getServiceSpecificationsById(serv.id+'');
                    if(specJSON!=null){
                        List<CS_SpecificationDTO.ServiceSpecification> serviceSpecDTOList = CS_SpecificationDTO.parseServiceSpec(specJSON,'FULFILMENT');
                        //Map<String, String> additionalAttrs = new Map<String, String>(); // Sr-2 Map initializing inside forloop
                        Attachment attAdd;
                        /*Commenting code as part of EDGE-127367
                         * Map<String,String> serviceAttachmentMap=new Map<String,String>();
                        Map<String,Attachment> servAttachmentRecordMap = new Map<String,Attachment>();
                        for(Attachment att: [select Id,body,parentId from Attachment where parentId=:serv.Id]){
                            serviceAttachmentMap.put(att.parentId,att.Body.toString());
                            servAttachmentRecordMap.put(att.parentId,att);
                        }*/
                        
                        for(CS_SpecificationDTO.ServiceSpecification servSpecDTO : serviceSpecDTOList){
                            System.debug('Simpleattributes<><>'+servSpecDTO.simpleAttributes);
                            
                            Map<String, String> additionalAttrs=new Map<String, String>(); // Sr-2 Map initializing inside forloop
                            for(CS_SpecificationDTO.SimpleAttributes simpleAttr : servSpecDTO.simpleAttributes) {
                                if(string.isNotBlank(simpleAttr.Name) && simpleAttr.Name.contains('CPE')) {
                                    
                                    DateTime tt = addbusinessDays(startDate, (-1) * workingDays);
                                    system.debug('Testing cpedelivery date ' + tt);
                                    additionalAttrs.put(simpleAttr.name, tt.format('yyyy-MM-dd\'T\'HH:mm:ss'));
                                }
                                /*else if(string.isNotBlank(simpleAttr.Name) && simpleAttr.Name.contains('parentSpec') && !simpleAttr.value.startsWith('DMCAT_ProductSpecification_')) {
                                    //additionalAttrs.put(simpleAttr.name, simpleAttr.value);
                                }
                                else if(string.isNotBlank(simpleAttr.Name) && (simpleAttr.Name.contains('InstanceId')||simpleAttr.Name.contains('InstanceID'))&& !simpleAttr.value.startsWith('DMCAT_ProductSpecification_')) {
                                    //additionalAttrs.put(simpleAttr.name, simpleAttr.value);
                                }*/
                            }
                            System.debug('additionalAttrs<><>'+additionalAttrs);
                            if(!additionalAttrs.isEmpty()) {
                                system.debug('TestTest');
                                
                                //**********
                                String bodyAdditionalAttribute=ServiceSpecificationUtils.addAdditionalAttributeNoSOQL(serviceAttachmentMap.get(servSpecDTO.serviceId),servSpecDTO.guid,additionalAttrs);
                                
                                attAdd=servAttachmentRecordMap.get(servSpecDTO.serviceId);
                                attAdd.body=Blob.valueOf(bodyAdditionalAttribute);
                                serviceAttachmentMap.put(servSpecDTO.serviceId,attAdd.body.toString());
                                additionalAttrs.clear();
                            }
                        }
                        if(attAdd!=null)
                            attachmentToUpdate.put(serv.Id,attAdd);
                        attAdd=null;
                    }
                }
                if(!attachmentToUpdate.isEmpty()){
                    system.debug('User---> '+UserInfo.getName());
                    
                    update attachmentToUpdate.values();
                    system.debug('after update---> '+attachmentToUpdate);
                }
                
                
            }else{
                logger.logMessages('', '', '', 'Technical', 'Exception', 'Exception : Start Date is null for the subscription with id  ' + subscriptionID + ' and hence not able to update CPE delivery date for the same.', false, false);
                system.debug('Exception : Start Date is null for the subscription with id  ' + subscriptionID + ' and hence not able to update CPE delivery date for the same.');
                system.debug('Please execute this method directly by passing the subscription ID after populating startdate');
            }
        }catch(Exception e){
            system.debug('Exception in modifyCPEDeliveryDate ' + e);
        }
    }
	
	//EDGE-124891 added bulkified version of method modifyCPEDeliveryDate
	public static void modifyCPEDeliveryDate(List<csord__Subscription__c> subscriptionList) {
        DateTime startDate = null;
        Map<Id,Attachment> attachmentToUpdate=new Map<Id,Attachment>();
		Map<String,String> serviceAttachmentMap=new Map<String,String>();
        Map<String,Attachment> servAttachmentRecordMap = new Map<String,Attachment>();
               
   
        Logger2 logger = Logger2.getLogger('CPEDeliveryDateHandler');
        try{
            for(Appointment__c apptRecord: [select SlotId__c,Subscription__c, Notes__c,StartDate__c,EndDate__c from Appointment__c where Subscription__c IN: subscriptionList]){ //EDGE-124891 - updated where clause in SOQL query
                if(apptRecord.StartDate__c!=null){
					startDate = apptRecord.StartDate__c;}
                break;
            }
             if(startDate!=null){
               
                Map<Id,csord__Service__c> serviceMap = new Map<Id,csord__Service__c>([select id from csord__Service__c where csord__Subscription__c IN: subscriptionList]); //EDGE-124891 - updated where clause in SOQL query
               
                for(Attachment att: [select Id,body,parentId from Attachment where parentId=:serviceMap.keyset()]){
                    serviceAttachmentMap.put(att.parentId,att.Body.toString());
                    servAttachmentRecordMap.put(att.parentId,att);
                }
				
				for(String attBody:serviceAttachmentMap.values())
				{
					String specJSON = csedm.API_1.getServiceSpecifications(attBody); //EDGE-124891 - used bulkified API's
					 if(specJSON!=null){
                        List<CS_SpecificationDTO.ServiceSpecification> serviceSpecDTOList = CS_SpecificationDTO.parseServiceSpec(specJSON,'FULFILMENT');
                       
                        Attachment attAdd;
                      
                        
                        for(CS_SpecificationDTO.ServiceSpecification servSpecDTO : serviceSpecDTOList){
                            System.debug('Simpleattributes<><>'+servSpecDTO.simpleAttributes);
                            
                            Map<String, String> additionalAttrs=new Map<String, String>(); // Sr-2 Map initializing inside forloop
                            for(CS_SpecificationDTO.SimpleAttributes simpleAttr : servSpecDTO.simpleAttributes) {
                                if(string.isNotBlank(simpleAttr.Name) && simpleAttr.Name.contains('CPE')) {
                                    
                                    DateTime tt = addbusinessDays(startDate, (-1) * workingDays);
                                    system.debug('Testing cpedelivery date ' + tt);
                                    additionalAttrs.put(simpleAttr.name, tt.format('yyyy-MM-dd\'T\'HH:mm:ss'));
                                }
                            
                            }
                            System.debug('additionalAttrs<><>'+additionalAttrs);
                            if(!additionalAttrs.isEmpty()) {
                             
                                
                                //**********
                                String bodyAdditionalAttribute=ServiceSpecificationUtils.addAdditionalAttributeNoSOQL(attBody,servSpecDTO.guid,additionalAttrs);
                                
                                attAdd=servAttachmentRecordMap.get(servSpecDTO.serviceId);
                                attAdd.body=Blob.valueOf(bodyAdditionalAttribute);
                                //serviceAttachmentMap.put(servSpecDTO.serviceId,attAdd.body.toString());
                                additionalAttrs.clear();
                            }
                        }
                        if(attAdd!=null)
                            attachmentToUpdate.put(attAdd.parentId,attAdd);
                        attAdd=null;
                    }
				}
                
           
                if(!attachmentToUpdate.isEmpty()){
                    system.debug('User---> '+UserInfo.getName());
                    
                    update attachmentToUpdate.values();
                    system.debug('after update---> '+attachmentToUpdate);
                }
                
                
            }else{
                logger.logMessages('', '', '', 'Technical', 'Exception', 'Exception : Start Date is null for the subscription with id  ' + subscriptionList + ' and hence not able to update CPE delivery date for the same.', false, false);
                system.debug('Exception : Start Date is null for the subscription with id  ' + subscriptionList + ' and hence not able to update CPE delivery date for the same.');
                system.debug('Please execute this method directly by passing the subscription ID after populating startdate');
            }
        }catch(Exception e){
            system.debug('Exception in modifyCPEDeliveryDate ' + e);
        }
    }
    public static DateTime AddBusinessDays(DateTime StartDate, Integer days){
      //Add or decrease in BusinessDaysToAdd days 
        Integer BusinessDaysToAdd = days;
        DateTime finalDate = StartDate;
        system.debug('finaldate = '+finalDate);
        integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
        system.debug('direction = '+direction);
        while(BusinessDaysToAdd != 0){
            finalDate = finalDate.AddDays(direction);
            system.debug('BusinessDaysToAdd = '+BusinessDaysToAdd);            
            system.debug('finaldate = '+finalDate);
            if (!isWeekendDay(finalDate))
            {
               BusinessDaysToAdd -= direction;
               
            }
        }
        return finalDate;
    }
    
    public static Boolean IsWeekendDay(Datetime dateParam){     
        boolean result     = false;    
        Date startOfWeek   = dateParam.date().toStartOfWeek();      
        Integer dayOfWeek  = dateParam.day() - startOfWeek.day();       
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;     
        return result;   
    }
}