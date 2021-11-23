/*Class created to handle methods for TAR calculations and request payload for QUERY & RESERVE appointment 
*/
public with sharing class TARManagerV2 {
    public Static String accessType = '';
    public Static String changeType = '';
    public Static Date cancelDate = System.Today();
  
    public TARManagerV2(){}
   
    public Class ServiceSpecificationWrapper{
        public String serviceID;
        public String specCode;
        public CS_SpecificationDTO.ServiceSpecification serviceSpecification;
        public String specificationMetadataID;
    }
    
    ///Appointment v2 code goes here
     public Double fetchStartDateForSiteAPV2(String subscriptionID){
        try{
            List<String> specCodeList = getAppointmentRequiredSpecCodeList();
            system.debug('ALL Appt Required SPEC CODE LIST ' + specCodeList);
            Set<String> specCodeForApptSet = getSpecCodeListFromServices(subscriptionID,specCodeList);
            system.debug('SPEC CODE FOR APPT FROM SUBSCRIPTION ' + specCodeForApptSet);
            String orderType = checkMacSubscription(subscriptionID);
            system.debug('Order Type value ' + orderType);
            Double maxLeadTime = getMaxLeadTimeAPV2(subscriptionID,specCodeForApptSet,orderType);
            return maxLeadTime;
        }
        catch(Exception e){
            return 0;
        }
    }
    
    public String checkMacSubscription(String subscriptionID){
        try{
            for(csord__Subscription__c subReplaceList : [select id,csordtelcoa__Replaced_Subscription__c from csord__Subscription__c where Id = : subscriptionID]){
                if (subReplaceList.csordtelcoa__Replaced_Subscription__c!=null){
                    return 'MAC';
                }
                else
                {
                    return 'New';
                }
            }
            return 'New';
        }catch(Exception e){
            system.debug('Exception in checkMacSubscription ' + e);
            return 'New';
        }
    }
    
    public List<String> getAppointmentRequiredSpecCodeList(){
        List<String> specCodeList = new List<String>();
        try{
            List<Specification_Metadata__c> specMetadataList = [select id,Installation_Lead_Time__c,Specification__r.csedm__Code__c from Specification_Metadata__c where Appointment_Required__c = true];
            for(Specification_Metadata__c specMetadata : specMetadataList){
                specCodeList.add(specMetadata.Specification__r.csedm__Code__c);
            }
            return specCodeList;
        }catch(Exception e){
            system.debug('Exception in getAppointmentRequiredSpecCodeList ' + e);
            return specCodeList;
        }
    }
    
    public Set<String> getSpecCodeListFromServices(String subscriptionID,List<String> specCodeList){
        Set<String> specCodeSet = new Set<String>();
        try{
            List<csord__Service__c> serviceList = [select id from csord__Service__c where csord__Subscription__c = : subscriptionID];
            for(csord__Service__c serv : serviceList){
                String specJSON = csedm.API_1.getServiceSpecificationsById(serv.id+'');
                if(specJSON!=null){
                    List<CS_SpecificationDTO.ServiceSpecification> serviceSpecDTOList = CS_SpecificationDTO.parseServiceSpec(specJSON,'FULFILMENT');
                    //system.debug('PARSED SERVICE SPEC ' + serv.id +'--'+ serviceSpecDTOList);
                    for(CS_SpecificationDTO.ServiceSpecification servSpecDTO : serviceSpecDTOList){
                        String specCodeFulfilment = '';
                        if(servSpecDTO.code!=null&& servSpecDTO.code.split('_F').size()>0){
                            specCodeFulfilment = servSpecDTO.code.split('_F')[0];
                        }
                        if(specCodeList.contains(servSpecDTO.code) || specCodeList.contains(specCodeFulfilment)){
                            specCodeSet.add(servSpecDTO.code);
                        }
                    }
                }
            }
            return specCodeSet;
        }catch(Exception e){
            system.debug('Exception in getSpecCodeList' +e);
            return specCodeSet;
        }
    }
    
    public String getAccessType(String subscriptionID){
        if(accessType == '' || accessType == null){
            csord__Subscription__c subOrdRequest =  [Select id,csord__Order__c from csord__Subscription__c where id = : subscriptionID];
            List<csord__Service__c> service = [SELECT Id,TechnologyType__c FROM csord__Service__c WHERE  csord__Order__c =: subOrdRequest.csord__Order__c AND TechnologyType__c != null];
      if(!service.isEmpty())
        accessType = service[0].TechnologyType__c;
      else
        accessType = null;
        }  
        return accessType;
    }
    public Date getCancelLeadDate(String subscriptionID){
        if(cancelDate != null){
            csord__Subscription__c subOrdRequest =  [Select id,csord__Order__c from csord__Subscription__c where id = : subscriptionID];
            List<csord__Service__c> service = [SELECT Id,TechnologyType__c,Cust_Req_Disconn_Date__c FROM csord__Service__c WHERE  csord__Order__c =: subOrdRequest.csord__Order__c AND Cust_Req_Disconn_Date__c != null];
      if(!service.isEmpty())
        cancelDate = service[0].Cust_Req_Disconn_Date__c;
      else
        cancelDate = System.Today();
        }  
        return cancelDate;
    }
    public String getChangeType(String subscriptionID){
        if(changeType == '' || changeType == null){
            List<csord__Subscription__c> subOrdRequest =  [Select id,csord__Order__c,csordtelcoa__Change_Type__c from csord__Subscription__c where id = : subscriptionID];
            system.debug('Change Type values ' + subOrdRequest);
      if(!subOrdRequest.isEmpty())
        changeType = subOrdRequest[0].csordtelcoa__Change_Type__c;
      else
        changeType = null;
        }  
        return changeType;
    }   
    //update the parameter list to include subscriptionId
    public Double getMaxLeadTimeAPV2(String subscriptionID, Set<String> specCodeList,String orderType){
        system.debug('ABCSpecodelist' + specCodeList);
        system.debug('Inside getMaxLeadTimeAPV2');
        try{
            system.debug('Before accessType');
            Double maxLeadTime = 0;
            List<Specification_Metadata__c> specMetadataList = new List<Specification_Metadata__c>();
            accessType = getAccessType(subscriptionID);
            changeType = getChangeType(subscriptionID);
            cancelDate = getCancelLeadDate(subscriptionID);
            system.debug('ABC1277654' + cancelDate);
            system.debug('ABC123456' + changeType);
            if(accessType == 'Telstra Fibre Access' || accessType == '' || accessType == null){
                specMetadataList = [select id, Installation_Lead_Time__c,mac_installation_lead_time__c,Appointment_Required__c,Specification__r.csedm__Code__c from Specification_Metadata__c where Appointment_Required__c = true and Specification__r.csedm__Code__c in :specCodeList and access_type__c = 'Telstra Fibre Access'];   
            }else if(accessType == 'Mobile Access' && accessType != '' && accessType != null){
                specMetadataList = [select id, Installation_Lead_Time__c,mac_installation_lead_time__c,Appointment_Required__c,Specification__r.csedm__Code__c from Specification_Metadata__c where Appointment_Required__c = false and Specification__r.csedm__Code__c in :specCodeList and access_type__c = 'Mobile Access'];
            }
            for(Specification_Metadata__c specMetaDataRecord : specMetadataList){
                Double leadTime = 0;
                System.debug('Order type value '+orderType);
                if(orderType == 'New' && changeType != 'Cancel'){
                    leadTime = specMetaDataRecord.Installation_Lead_Time__c; 
                    system.debug(' if leadTime::: '+leadTime); 
                }
                else if (orderType == 'MAC' && changeType == 'Cancel' )
                {
                    leadTime = System.Today().daysBetween(cancelDate); 
                    system.debug('else leadTime canceldate::: '+leadTime); 
                }
                else
                {
                    leadTime = specMetaDataRecord.mac_installation_lead_time__c; 
                    system.debug('else leadTime::: '+leadTime); 
                }
                
                if(leadTime > maxLeadTime){
                    maxLeadTime = leadTime;
                }
            }
            return maxLeadTime;
        }catch(Exception e){
            return 0;
        }
    }
    
    public List<ServiceSpecificationWrapper> getServiceSpecificationList(String subscriptionID, List<String> specCodeList){
        List<ServiceSpecificationWrapper> specWrapperList = new List<ServiceSpecificationWrapper>();
        try{
            List<csord__Service__c> serviceList = [select id from csord__Service__c where csord__Subscription__c = : subscriptionID];
            for(csord__Service__c serv : serviceList){
                String specJSON = csedm.API_1.getServiceSpecificationsById(serv.id+'');
                if(specJSON!=null){
                    List<CS_SpecificationDTO.ServiceSpecification> serviceSpecDTOList = CS_SpecificationDTO.parseServiceSpec(specJSON,'FULFILMENT');
                    for(CS_SpecificationDTO.ServiceSpecification servSpecDTO : serviceSpecDTOList){
                        if(specCodeList.contains(servSpecDTO.code)){
                            ServiceSpecificationWrapper serviceWrapper = new ServiceSpecificationWrapper();
                            serviceWrapper.serviceID = servSpecDTO.guid;
                            serviceWrapper.specCode = servSpecDTO.code;
                            serviceWrapper.serviceSpecification = servSpecDTO;
                            specWrapperList.add(serviceWrapper);
                        }
                    }
                }
            }
            system.debug('spec code Wrapper List '+ specWrapperList);
            return specWrapperList;
        }catch(Exception e){
            system.debug('Exception in getServiceSpecificationList '+e);
            return specWrapperList;
        }
    }
    
    public AppointmentSlotRequestDTO.SlotSiteAddress populateSlotSiteAddressAPV2(String subscriptionID){
        AppointmentSlotRequestDTO.SlotSiteAddress slotSiteAddress = new AppointmentSlotRequestDTO.SlotSiteAddress();
        try{
            String adBorID  = '';
            for(csord__Subscription__c sub : [select id, Site__r.AdborID__c from csord__Subscription__c where id =: subscriptionID]){
                adBorID = sub.Site__r.AdborID__c;
            }
            slotSiteAddress.id = adBorID;
            return slotSiteAddress;
        }catch(Exception e){
            system.debug('Exception in populateSlotSiteAddress ' + e);
            return slotSiteAddress;
        }
    }
    
    public List<AppointmentSlotRequestDTO.SlotTask> populateSlotTasksAPV2(String subscriptionID){
        List<AppointmentSlotRequestDTO.SlotTask> slotTaskList = new List<AppointmentSlotRequestDTO.SlotTask>();
        try{
            List<String> specCodeList = getAppointmentRequiredSpecCodeList();
            List<ServiceSpecificationWrapper> specWrapperList = getServiceSpecificationList(subscriptionID,specCodeList);
            system.debug('Test class ' + specWrapperList);
            Map<String,Map<String,String>> taskMap = calculateTARAPV2(specWrapperList,subscriptionID);
            for(String keyTaskMap : taskMap.keySet()){
                system.debug('TASKMAP ITERATE');
                Map<String,String> jobItemMap = taskMap.get(keyTaskMap);
                AppointmentSlotRequestDTO.SlotTask slotTask = new AppointmentSlotRequestDTO.SlotTask();
                slotTask.extTaskReferenceId = keyTaskMap;
                List<AppointmentSlotRequestDTO.JobItem> jobItemList = new List<AppointmentSlotRequestDTO.JobItem>();
                AppointmentSlotRequestDTO.JobItem jobItem = new AppointmentSlotRequestDTO.JobItem();
                jobItem.technology = jobItemMap.get('technology');
                jobItem.action = jobItemMap.get('action');
                jobItem.resourceType = jobItemMap.get('resourceType');
                jobItem.description = jobItemMap.get('description');
                jobItem.quantity = jobItemMap.get('quantity');
                jobItemList.add(jobItem);
                slotTask.jobItems = jobItemList;
                slotTaskList.add(slotTask);
            }
            return slotTaskList;
        }catch(Exception e){
            system.debug('Exception in populateSlotTasks ' + e);
            return slotTaskList;
        }
    }
    
    public Map<String,Map<String,String>> calculateTARAPV2(List<ServiceSpecificationWrapper> specWrapperList, String subscriptionID){
        Map<String,Map<String,String>> taskMap = new Map<String,Map<String,String>>();
        try{
            for(ServiceSpecificationWrapper specWrapper : specWrapperList){
                Map<String,String> jobMap = new Map<String,String>();
                String technology = calculateTechnologyAPV2(subscriptionID);
                String action = calculateActionAPV2(subscriptionID);
                String resource = calculateResourceAPV2(specWrapper.specCode,specWrapper,subscriptionID);
                String description = calculateDescriptionAPV2(specWrapper.specCode,specWrapper,subscriptionID);
                String quantity = getAttributeValueFromServiceSpec(specWrapper.serviceSpecification,'Quantity');
                jobMap.put('technology',technology);
                jobMap.put('action',action);
                jobMap.put('resourceType',resource);
                jobMap.put('description', description + ' ' + resource);
                jobMap.put('quantity', quantity);
                taskMap.put(specWrapper.serviceID,jobMap);
            }
            //List<String> specCodeList = getAllRelatedProductSpecCodeList(rootPCId);
            return taskMap;
        }
        catch(Exception e){
            system.debug('Exception in calculateTARAPV2 method ' + e);
            return taskMap;
        }
    }
    
    public String calculateTechnologyAPV2(String subscriptionID){
        String productTarName = '';
        accessType = getAccessType(subscriptionID);
        changeType = getChangeType(subscriptionID);
        try{
            List<Specification_Metadata__c> specMetadataList = new List<Specification_Metadata__c>();
            if(accessType == 'Telstra Fibre Access' || accessType == '' || accessType == null){
            specMetadataList = [select id, name, Specification__c,Appointment_Required__c,Product_TAR_Name__c,Type__c from Specification_Metadata__c where Type__c = 'Appointment' and name = 'Telstra Fibre Access'];
            }
            else if(accessType == 'Mobile Access' && accessType != '' && accessType != null){
            specMetadataList = [select id, name, Specification__c,Appointment_Required__c,Product_TAR_Name__c,Type__c from Specification_Metadata__c where Type__c = 'Appointment' and name = 'Mobile Access'];
            }
            system.debug('specMetadataList123>>>' + specMetadataList);
            for(Specification_Metadata__c specmetaRecord : specMetadataList){
                productTarName = specmetaRecord.Product_TAR_Name__c;
            }
            return productTarName + ' ' + 'Connected Workplace';
        }catch(Exception e){
            system.debug('exception in calculateTechnologyAPV2 ' + e);
            return productTarName;
        }
    }
    
    public String calculateActionAPV2(String subscriptionID){
        String apptActionName = '';
        accessType = getAccessType(subscriptionID);
        changeType = getChangeType(subscriptionID);
        try{
            List<Specification_Metadata__c> specMetadataList = new List<Specification_Metadata__c>();
            if(accessType == 'Telstra Fibre Access' || accessType == '' || accessType == null){
            specMetadataList = [select id, name, Specification__c,Appointment_Required__c,Product_TAR_Name__c,Type__c from Specification_Metadata__c where Type__c = 'Appointment' and name = 'Telstra Fibre Access'];
            }
            else if(accessType == 'Mobile Access' && accessType != '' && accessType != null){
            specMetadataList = [select id, name, Specification__c,Appointment_Required__c,Product_TAR_Name__c,Type__c from Specification_Metadata__c where Type__c = 'Appointment' and name = 'Mobile Access'];
            }
            system.debug('specMetadataList123>>>' + specMetadataList);
            if(specMetadataList!= null && specMetadataList.size()>0){
                    if (changeType == 'Cancel')
                    apptActionName = 'Recover ';
                    else 
                    apptActionName = 'Install ';
            }
            return apptActionName;
        }catch(Exception e){
            system.debug('exception in calculateTechnologyAPV2 ' + e);
            return apptActionName;
        }
    }
    /* Method to calculate Resource 'R' value for TAR using specification Metadata and configuration
    */
    public String calculateResourceAPV2(String specCode, ServiceSpecificationWrapper specWrapper,String subscriptionID){
        String resourceValue = '';
        accessType = getAccessType(subscriptionID);
        try{
            List<TAR_Metadata__c> tarList = new List<TAR_Metadata__c>();
            if(specCode!= null && specWrapper != null){
                List<Specification_Metadata__c> specMetadataList = [select id, name, Specification__c,Appointment_Required__c,Access_Type__c from Specification_Metadata__c where Specification__r.csedm__Code__c =:specCode and Appointment_Required__c = true];
                system.debug('Specs123456' + specMetadataList.size());
                if(specMetadataList!=null && specMetadataList.size()>1){
                    for(Specification_Metadata__c specMetadata : specMetadataList){
                        if(specMetadata.Access_Type__c == accessType){
                            tarList = [select id,Type__c, Weight__c,Attribute_Name__c,IsReference__c,Attribute_TAR_Value__c,Specification_Metadata__c from TAR_Metadata__c where Specification_Metadata__c =: specMetadata.id and Type__c = 'Resource' order by Weight__c];
                        }
                    }
                }else if(specMetadataList!=null && specMetadataList.size()<2){
                    tarList = [select id,Type__c, Weight__c,Attribute_Name__c,IsReference__c,Attribute_TAR_Value__c,Specification_Metadata__c from TAR_Metadata__c where Specification_Metadata__r.Specification_Code__c =: specCode and Type__c = 'Resource' order by Weight__c Limit 1];
                }
                for(TAR_Metadata__c tarRecord : tarList){
                    if(tarRecord.IsReference__c){
                       resourceValue +=  tarRecord.Attribute_TAR_Value__c +' ';
                    }else{
                       resourceValue +=  getAttributeValueFromServiceSpec(specWrapper.serviceSpecification,tarRecord.Attribute_Name__c) + ' ';
                    }
                }
            }
            return resourceValue.trim();
        }catch(Exception e){
            system.debug('exception in calculateResourceAPV2 ' + e);
            return '';
        }
    }
    /* Method to calculate Job Description value for TAR using specification Metadata and configuration
     */
    public String calculateDescriptionAPV2(String specCode, ServiceSpecificationWrapper specWrapper,String subscriptionID){
    accessType = getAccessType(subscriptionID);
    changeType = getChangeType(subscriptionID);
        try{
            String descriptionValue = '';
      List<TAR_Metadata__c> tarList = new List<TAR_Metadata__c>();
            if(specCode!= null && specWrapper != null){
        List<Specification_Metadata__c> specMetadataList = [select id, name, Specification__c,Appointment_Required__c,Access_Type__c from Specification_Metadata__c where Specification__r.csedm__Code__c =:specCode and Appointment_Required__c = true];
                if(specMetadataList!=null && specMetadataList.size()>1){
                    for(Specification_Metadata__c specMetadata : specMetadataList){
                        if(specMetadata.Access_Type__c == accessType){
                            tarList = [select id,Type__c, Weight__c,Attribute_Name__c,IsReference__c,Attribute_TAR_Value__c,Specification_Metadata__c from TAR_Metadata__c where Specification_Metadata__c =: specMetadata.id and Type__c = 'Job Description' order by Weight__c];
                        }
                    }
                }else if(specMetadataList!=null && specMetadataList.size()<2){
                    tarList = [select id,Type__c, Weight__c,Attribute_Name__c,IsReference__c,Attribute_TAR_Value__c,Specification_Metadata__c from TAR_Metadata__c where Specification_Metadata__r.Specification_Code__c =: specCode and Type__c = 'Job Description' order by Weight__c Limit 1];
                }
                if(tarList!= null && tarList.size()>0){
                    if (changeType == 'Cancel')
                    descriptionValue = 'Recover ';
                    else 
                    descriptionValue = 'Install ';  
                    for(TAR_Metadata__c tarRecord : tarList){
                        if(tarRecord.IsReference__c){
                            descriptionValue +=  tarRecord.Attribute_TAR_Value__c +' ';
                        }else{
                            descriptionValue +=  getAttributeValueFromServiceSpec(specWrapper.serviceSpecification,tarRecord.Attribute_Name__c) + ' ';
                        }
                    }
                }
                return descriptionValue.trim();
            }
            return '';
        }catch(Exception e){
            system.debug('exception in calculateDescriptionAPV2 ' + e);
            return '';
        }
    }
    
    public String getAttributeValueFromServiceSpec(CS_SpecificationDTO.ServiceSpecification specWrapper,String attributeName){
        try{
            if(specWrapper != null){
                for(CS_SpecificationDTO.SimpleAttributes simpleAttribute: specWrapper.additionalAttributes){
                    if(simpleAttribute.name == attributeName){
                        return simpleAttribute.value;
                    }
                }
            }
            return '';
        }catch(Exception e){
            return '';
        }
    }
    
    public List<AppointmentReserveRequestDTO.Contacts> populateContactForReserveAppointmentAPV2(String subscriptionID){
        List<AppointmentReserveRequestDTO.Contacts> contactList = new List<AppointmentReserveRequestDTO.Contacts>();
        try{
            /*
            Map<String,String> roleMap = new Map<String,String>();
            roleMap.put('primary','Primary Site Contact');
            roleMap.put('secondary','Technical Contact');
            roleMap.put('site','Project Contact');
            String siteID  = '';
            for(csord__Subscription__c sub : [select id, Site__c from csord__Subscription__c where id =: subscriptionID]){
                siteID = sub.Site__c;
            }
            if(siteID!=''){
                for(String key : roleMap.keySet()){
                    for(Functional_Contact_Role__c fContactRole : [select id, Role__c,ContactID__c,SiteID__c from Functional_Contact_Role__c where SiteID__c =:siteID and Role__c =: roleMap.get(key)]){
                        for(Contact contactRecord : [select id,name,Phone,MobilePhone from Contact where id =:fContactRole.ContactID__c]){
                            AppointmentReserveRequestDTO.Contacts contact = new AppointmentReserveRequestDTO.Contacts();
                            if((contactRecord.Phone!=null && contactRecord.Phone.length()>0) || (contactRecord.MobilePhone!=null && contactRecord.MobilePhone.length()>0)){
                                String contactPhoneNumber = ''; 
                                if(contactRecord.Phone!=null &&contactRecord.Phone.length()>0){ 
                                contactPhoneNumber=contactRecord.Phone; 
                                }else{ 
                                contactPhoneNumber=contactRecord.MobilePhone; 
                                }
                                contact.name = contactRecord.name;
                                contact.phoneNumber = ''+contactPhoneNumber;
                                //contact.phoneNumber = ''+contactRecord.Phone;
                                contact.role = key;
                                contactList.add(contact);
                                break;    
                            }
                        }
                    }
                }
            }
            return contactList;
            */
            Map<Id,String> roleMap = new Map<Id,String>();
            Set<Id> contactIdSet = new Set<Id>();
          // roleMap.put('primary','Primary Site Contact');
          // roleMap.put('secondary','Technical Contact');
          // roleMap.put('site','Project Contact');
                         
            
            for(csord__service__c servObj : [Select Id, Primary_Contact__c, Technical_Contact__c, Project_Contact__c from csord__service__c where csord__Subscription__c =: subscriptionID and csord__service__c = null]){
                if(servObj.Primary_Contact__c!=null){
                    contactIdSet.add(servObj.Primary_Contact__c);
                    roleMap.put(servObj.Primary_Contact__c, 'primary');
                }
                if(servObj.Technical_Contact__c!=null){
                    contactIdSet.add(servObj.Technical_Contact__c);
                    roleMap.put( servObj.Technical_Contact__c, 'secondary');
                }
                if(servObj.Project_Contact__c!=null){
                    contactIdSet.add(servObj.Project_Contact__c);
                    roleMap.put(servObj.Project_Contact__c, 'site');
                }
            }
            
            Map<Id, Contact> contactMap= new Map<Id, Contact>([Select Id, Name, Phone, MobilePhone from Contact where Id IN: contactIdSet]);
            
            
           if(contactMap!= null ){
               for(Id key : contactMap.keySet()){
                  // for(Functional_Contact_Role__c fContactRole : [select id, Role__c,ContactID__c,SiteID__c from Functional_Contact_Role__c where SiteID__c =:siteID and Role__c =: roleMap.get(key)]){
                      // for(Contact contactRecord : [select id,name,Phone,MobilePhone from Contact where id =:fContactRole.ContactID__c]){
                           AppointmentReserveRequestDTO.Contacts contactInstance = new AppointmentReserveRequestDTO.Contacts();
                          // if((contactRecord.Phone!=null && contactRecord.Phone.length()>0) || (contactRecord.MobilePhone!=null && contactRecord.MobilePhone.length()>0)){
                               Contact contactRecord = contactMap.get(key);
                                String contactPhoneNumber = '';
                               if(contactRecord.Phone!=null &&contactRecord.Phone.length()>0){
                               contactPhoneNumber=contactRecord.Phone;
                               }else{
                               contactPhoneNumber=contactRecord.MobilePhone;
                               }
                               contactInstance.name = contactRecord.name;
                               contactInstance.phoneNumber = ''+contactPhoneNumber;
                               //contact.phoneNumber = ''+contactRecord.Phone;
                               contactInstance.role = roleMap.get(key);
                               contactList.add(contactInstance);
                               //break;
                          // }
                       //}
                   //}
               }
           }
           return contactList;
        }catch(Exception e){
            system.debug('Exception in populateContactForReserveAppointment ' + e);
            return contactList;
        }
    }
}