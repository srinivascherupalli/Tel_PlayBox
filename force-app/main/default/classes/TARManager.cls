/*Class created to handle methods for TAR calculations and request payload for QUERY & RESERVE appointment 
*/
public with sharing class TARManager {
    
    /* Method to fetch Advance start date for the current configuration
	*/
	public Double fetchStartDateForSite(String rootId){
        try{
            List<String> specCodeList = getAllRelatedProductSpecCodeList(rootId);
            List<String> specMetaIDList = getSpecificationMetadataRecords(specCodeList);
            Double maxLeadTime = getMaxLeadTime(specMetaIDList);
            return maxLeadTime;
        }
        catch(Exception e){
            return 0;
        }
    }
    /*Method to populate Site Address for Query Appointment
	*/
    public AppointmentSlotRequestDTO.SlotSiteAddress populateSlotSiteAddress(String rootConfigId){
        AppointmentSlotRequestDTO.SlotSiteAddress slotSiteAddress = new AppointmentSlotRequestDTO.SlotSiteAddress();
        try{
            slotSiteAddress.id = getProdConfigAttributeValue(rootConfigId,'AdborID');
            return slotSiteAddress;
        }catch(Exception e){
            system.debug('Exception in populateSlotSiteAddress ' + e);
            return slotSiteAddress;
        }
    }
    
    /* Method to populate the task payload for Query Appointment
	*/
    public List<AppointmentSlotRequestDTO.SlotTask> populateSlotTasks(String rootConfigId){
        List<AppointmentSlotRequestDTO.SlotTask> slotTaskList = new List<AppointmentSlotRequestDTO.SlotTask>();
        try{
            Map<String,Map<String,String>> taskMap = calculateTAR(rootConfigId);
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
    
    /* method to populate Contact payload for Reserve Appointment
	*/
    public List<AppointmentReserveRequestDTO.Contacts> populateContactForReserveAppointment(String rootPCId){
        List<AppointmentReserveRequestDTO.Contacts> contactList = new List<AppointmentReserveRequestDTO.Contacts>();
        try{
            Map<String,String> roleMap = new Map<String,String>();
            roleMap.put('primary','Primary Site Contact');
            roleMap.put('secondary','Technical contact');
            roleMap.put('site','Project Contact');
            for(cscfga__Product_Configuration__c rootConfig : [select id,name,cscfga__Product_Basket__c from cscfga__Product_Configuration__c where id =:rootPCId]){
                List<cscfga__Product_Configuration__c> prodConfigList = [select id,name,cscfga__Product_Basket__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: rootConfig.cscfga__Product_Basket__c and name ='Site Details'];
                if(prodConfigList!=null && prodConfigList.size()>0){
                    for(String key : roleMap.keySet()){
                        AppointmentReserveRequestDTO.Contacts contact = new AppointmentReserveRequestDTO.Contacts();
                        String contactId = null;
                        for(cscfga__Product_Configuration__c config : prodConfigList){
                            contactId = getProdConfigAttributeValue(''+config.Id,roleMap.get(key));
                        }
                        if(contactId!=null){
                            for(Contact contactRecord : [select id,name,Phone from Contact where id =:contactId]){
                                if(contactRecord.Phone!=null && contactRecord.Phone.length()>0){
                                	contact.name = contactRecord.name;
                                    contact.phoneNumber = ''+contactRecord.Phone;
                                    contact.role = key;
                                    contactList.add(contact);
                                    break;    
                                }
                            }
                        }
                    }
                }
            }
            return contactList;
        }catch(Exception e){
            system.debug('Exception in populateContactForReserveAppointment ' + e);
            return contactList;
        }
    }
    
    /* Method to get Lead time considering all the spec codes for the current configuration
	*/
    public Double getMaxLeadTime(List<String> specMetaIDList){
        try{
            Double maxLeadTime = 0;
            List<Specification_Metadata__c> specMetadataList = [select id, Installation_Lead_Time__c,Appointment_Required__c from Specification_Metadata__c where id in :specMetaIDList and Appointment_Required__c = true];
            for(Specification_Metadata__c specMetaDataRecord : specMetadataList){
                Double leadTime = specMetaDataRecord.Installation_Lead_Time__c;
                if(leadTime > maxLeadTime){
                    maxLeadTime = leadTime;
                }
            }
            return maxLeadTime;
        }catch(Exception e){
            return 0;
        }
    }
    /* Generic Method to get all the Related Product Spec Codes for the current product configuration
	*/
    public List<String> getAllRelatedProductSpecCodeList(String rootPCId){
        List<String> specCodeList = new List<String>();
		List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        try{
            if(checkIfMAC(rootPCId)){
              prodConfigList = fetchMACApptRequiredPC(rootPCId);
          }else{
              prodConfigList = [select id,cscfga__Root_Configuration__c,cscfga__Product_Definition__c,cscfga__Product_Definition__r.product_Specification__c from cscfga__Product_Configuration__c where cscfga__Root_Configuration__c =:rootPCId];
          }
          //List<cscfga__Product_Configuration__c> prodConfigList = [select id,cscfga__Root_Configuration__c,cscfga__Product_Definition__c,cscfga__Product_Definition__r.product_Specification__c from cscfga__Product_Configuration__c where cscfga__Root_Configuration__c =:rootPCId];
            for(cscfga__Product_Configuration__c config : prodConfigList){
                specCodeList.add(config.cscfga__Product_Definition__r.product_Specification__c);
            }
            return specCodeList;
        }catch(Exception e){
            return specCodeList;
        }
    }
    
    /* Generic method to get value of the Attribute Definition from the configuration
	*/
    public String getProdConfigAttributeValue(String prodConfigId, String attrName){
        try{
            String attrValue = '';
            for(cscfga__Attribute__c attr: [select id, name, cscfga__Value__c from cscfga__Attribute__c where cscfga__Product_Configuration__c =: prodConfigId and name =: attrName]){
                attrValue = attr.cscfga__Value__c;
                break;
            }
            return attrValue;
        }
        catch(Exception e){
            system.debug('getProdConfigAttributeValue exception ' + e);
            return '';
        }
    }
	public Boolean checkIfMAC(String rootPCId){
        try{
            for(cscfga__Attribute__c attr: [select id, name, cscfga__Value__c from cscfga__Attribute__c where cscfga__Product_Configuration__c =: rootPCId and name like '%ConfigurationChanged']){
                if(attr.cscfga__Value__c == 'true'){
                    return true;
                }
            }
            return false;
        }catch(Exception e){
            system.debug('Exception in Appointment checkIfMAC '  +e);
            return false;
        }
    }
    public List<cscfga__Product_Configuration__c> fetchMACApptRequiredPC(String rootPCId){
        List<cscfga__Product_Configuration__c> returnPCList = new List<cscfga__Product_Configuration__c>();
        try{
            List<cscfga__Product_Configuration__c> prodConfigList = [select id,cscfga__Root_Configuration__c,OfferName__c,cscfga__Product_Definition__c,cscfga__Product_Definition__r.product_Specification__c from cscfga__Product_Configuration__c where cscfga__Root_Configuration__c =:rootPCId];
            for(cscfga__Product_Configuration__c prodConfig : prodConfigList){
                for(cscfga__Attribute__c attr: [select id, name, cscfga__Value__c from cscfga__Attribute__c where cscfga__Product_Configuration__c =: prodConfig.id and name like '%ConfigurationChanged']){
                    if(attr.cscfga__Value__c=='true'){
                        returnPCList.add(prodConfig);
                    }   
                }
            }
            return returnPCList;
        }catch(Exception e){
            System.debug('Exception in fetchMACApptRequiredPC '  +e);
            return null;
        }
    }
    /* Method to calculate TAR into a Map to be parsed into request payload
	*/
    public Map<String,Map<String,String>> calculateTAR(String rootPCId){
        Map<String,Map<String,String>> taskMap = new Map<String,Map<String,String>>();
        try{
            //List<String> specCodeList = getAllRelatedProductSpecCodeList(rootPCId);
            List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
            List<Specification_Metadata__c> specMetadataList = [select id, Specification__c,Specification__r.csedm__Code__c,Appointment_Required__c,Access_Flag__c,Product_TAR_Name__c,Type__c from Specification_Metadata__c where Type__c = 'Appointment' and Appointment_Required__c = true and Specification__c != null];
			if(checkIfMAC(rootPCId)){
                prodConfigList = fetchMACApptRequiredPC(rootPCId);
            }else{
                prodConfigList = [select id,cscfga__Root_Configuration__c,OfferName__c,cscfga__Product_Definition__c,cscfga__Product_Definition__r.product_Specification__c from cscfga__Product_Configuration__c where cscfga__Root_Configuration__c =:rootPCId];
            }
            for(cscfga__Product_Configuration__c config : prodConfigList){
                String configSpecCode = config.cscfga__Product_Definition__r.product_Specification__c;
                for(Specification_Metadata__c specMetaDataRecord : specMetadataList){
                    if(specMetaDataRecord.Specification__r.csedm__Code__c!=null && specMetaDataRecord.Specification__r.csedm__Code__c.contains(configSpecCode)){
                        Map<String,String> jobMap = new Map<String,String>();
                        String technology = calculateTechnology(specMetaDataRecord,config);
                        String resource = calculateResource(specMetaDataRecord,config);
                        String description = calculateDescription(specMetaDataRecord,config);
                        String quantity = getProdConfigAttributeValue(config.Id,'Quantity');
                        jobMap.put('technology',technology);
                        jobMap.put('action','Install');
                        jobMap.put('resourceType',resource);
                        jobMap.put('description', description + resource);
                        jobMap.put('quantity', quantity);
                        taskMap.put(config.id+'',jobMap);
                    }
                }
            }
            return taskMap;
        }
        catch(Exception e){
            system.debug('Exception in calculateTAR method ' + e);
            return taskMap;
        }
    }
    /* Method to calculate Technology 'T' value for TAR using specification Metadata and configuration
     * Please modify this for B2B2 products as it is hardcoded for B2B1 products
	*/
    public String calculateTechnology(Specification_Metadata__c specMetaDataRecord,cscfga__Product_Configuration__c config){
        try{
            String productTarName = '';
            List<Specification_Metadata__c> specMetadataList = [select id, name, Specification__c,Appointment_Required__c,Product_TAR_Name__c,Type__c from Specification_Metadata__c where Type__c = 'Appointment' and name ='Telstra Fibre Access'];
            for(Specification_Metadata__c specmetaRecord : specMetadataList){
                productTarName = specmetaRecord.Product_TAR_Name__c;
            }if(config != null){
                String offerName = getProdConfigAttributeValue(config.id,'OfferName');
                return productTarName + ' ' + 'Connected Workplace';
            }else{
                return productTarName;
            }
        }catch(Exception e){
            system.debug('exception in calculateTechnology ' + e);
            return '';
        }
    }
    /* Method to calculate Resource 'R' value for TAR using specification Metadata and configuration
    */
    public String calculateResource(Specification_Metadata__c specMetaDataRecord,cscfga__Product_Configuration__c config){
        try{
            if(specMetaDataRecord!= null && config != null){
                String resourceValue = '';
                List<TAR_Metadata__c> tarList = [select id,Type__c, Weight__c,Attribute_Name__c,IsReference__c,Attribute_TAR_Value__c,Specification_Metadata__c from TAR_Metadata__c where Specification_Metadata__c = : specMetaDataRecord.id and Type__c = 'Resource' order by Weight__c];
                for(TAR_Metadata__c tarRecord : tarList){
                    if(tarRecord.IsReference__c){
                       resourceValue +=  tarRecord.Attribute_TAR_Value__c +' ';
                    }else{
                       resourceValue +=  getProdConfigAttributeValue(''+config.id,tarRecord.Attribute_Name__c) + ' ';
                    }
                }
                return resourceValue.trim();
            }
            return '';
        }catch(Exception e){
            system.debug('exception in calculateResource ' + e);
            return '';
        }
    }
    /* Method to calculate Job Description value for TAR using specification Metadata and configuration
     */
    public String calculateDescription(Specification_Metadata__c specMetaDataRecord,cscfga__Product_Configuration__c config){
        try{
            String descriptionValue = '';
            if(specMetaDataRecord!= null && config != null){
                List<TAR_Metadata__c> tarList = [select id,Type__c, Weight__c,IsReference__c,Attribute_Name__c,Attribute_TAR_Value__c,Specification_Metadata__c from TAR_Metadata__c where Specification_Metadata__c = : specMetaDataRecord.id and Type__c = 'Job Description' order by Weight__c];
                if(tarList!= null && tarList.size()>0){
                    descriptionValue = 'Install ';
                    for(TAR_Metadata__c tarRecord : tarList){
                        if(tarRecord.IsReference__c){
                            descriptionValue +=  tarRecord.Attribute_TAR_Value__c +' ';
                        }else{
                            descriptionValue +=  getProdConfigAttributeValue(''+config.id,tarRecord.Attribute_Name__c) + ' ';
                        }
                    }
                }
                return descriptionValue.trim();
            }
            return '';
        }catch(Exception e){
            system.debug('exception in calculateDescription ' + e);
            return '';
        }
    }
    /* Method to fetch a list of Salesforce Ids of the Specification Metadata records for the passed spec codes 
	*/
    public List<String> getSpecificationMetadataRecords(List<String> specCodeList){
        try{
            List<String> prodDefnNameList = new List<String>();
            List<String> specMetaIDList = new List<String>();

            List<Specification_Metadata__c> specMetadataList = [select id, Specification__c,Specification__r.csedm__Code__c,Type__c from Specification_Metadata__c where Type__c = 'Appointment'];
            for(Specification_Metadata__c specMetaDataRecord : specMetadataList){
                for(String specCode : specCodeList){
                    //specCode == specMetaDataRecord.Specification__r.csedm__Code__c
                    if(specMetaDataRecord.Specification__r.csedm__Code__c!=null && specMetaDataRecord.Specification__r.csedm__Code__c.contains(specCode)){
                        specMetaIDList.add(specMetaDataRecord.id);
                    }
                }
            }
            return specMetaIDList;
        }
        catch(Exception e){
            system.debug('Exception in getSpecificationMetadataRecords ' + e);
            return null;
        }
    }
}