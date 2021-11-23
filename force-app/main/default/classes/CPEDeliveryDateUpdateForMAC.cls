/*
===============================================================================================================================
Class : CPEDeliveryDateUpdateForMAC
Developer Name : Manish Kumar 
Date : 19/02/2018
Test Class : CPEDeliveryDateUpdateForMACTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Manish Kumar        29/05/2018    EDGE-12496 : (Technical Story) Update CPE delivery date if there are no changes in MAC for that module
===============================================================================================================================
*/
public with sharing class CPEDeliveryDateUpdateForMAC {
    
    public static final Integer workingDays = integer.ValueOf(Label.WorkingDaysForMac);
    //public static final Integer  workingDays = 10;
     
    public static void addCPEAttr(List<Id> serviceIds) {    
        
        List<Id> subIdList = new List<Id>();
        List<Id> ordIdList = new List<Id>();
        List<Id> ipPCIDList = new List<Id>();
        Map<Id,Id> pcIdSubIdMap = new Map<Id,Id>();
        Map<Id,Id> pcIdOrdIdMap = new Map<Id,Id>();
        
        for(csord__Service__c service : [SELECT Id, Name, csordtelcoa__Product_Configuration__c, csord__Subscription__c, csord__Order__c FROM csord__Service__c where Name = 'IP Site' AND Id IN: serviceIds]){
            ipPCIDList.add(service.csordtelcoa__Product_Configuration__c);
            if(service.csord__Order__c != null){
                System.debug('<><><>');
                pcIdOrdIdMap.put(service.csordtelcoa__Product_Configuration__c, service.csord__Order__c);
            }
        }
        
        if(ipPCIDList.Size()>0){
            for(cscfga__Product_Configuration__c pc: [SELECT Id, Name, (SELECT Id, Name, cscfga__Value__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c Where Id IN: ipPCIDList]){
                Boolean changeType = false;
                Boolean ipSiteConfigurationChanged = true;
                for(cscfga__Attribute__c att: pc.cscfga__Attributes__r){
                    //System.debug('attname'+att.Name+' '+att.cscfga__Value__c);
                    if(att.Name == 'ChangeType' && (att.cscfga__Value__c != '' &&  att.cscfga__Value__c != null)){
                        System.debug('attname'+att.Name+' '+att.cscfga__Value__c);
                        changeType =true;
                    }
                    if(att.Name == 'IPSiteConfigurationChanged' && (att.cscfga__Value__c == '' || att.cscfga__Value__c == null)){
                       System.debug('attname'+att.Name+' '+att.cscfga__Value__c);
                       ipSiteConfigurationChanged = false;
                    }
                }
                if(changeType == true && ipSiteConfigurationChanged == false){
                    if(pcIdOrdIdMap.get(pc.Id) != null){
                        ordIdList.add(pcIdOrdIdMap.get(pc.Id));
                    }
                }
                
            }
        }
        System.debug('OrderIdList<><>'+ordIdList);
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> mapServiceSpecification = getOrderSpecs(ordIdList);
        //System.debug('Simpleattributes<><>');
        for(List<CS_SpecificationDTO.ServiceSpecification> lstSerSpec : mapServiceSpecification.values()) {
            for(CS_SpecificationDTO.ServiceSpecification serSpec : lstSerSpec) {
                Map<String, String> additionalAttrs = new Map<String, String>();
                System.debug('Simpleattributes<><>'+serSpec.simpleAttributes);
                for(CS_SpecificationDTO.SimpleAttributes simpleAttr : serSpec.simpleAttributes) {
                    if(string.isNotBlank(simpleAttr.Name) && simpleAttr.Name.contains('CPE')) {
                        DateTime tt = addbusinessDays(System.today(), workingDays);
                        additionalAttrs.put(simpleAttr.name, tt.format('yyyy-MM-dd\'T\'HH:mm:ss'));
                    }
                    else if(string.isNotBlank(simpleAttr.Name) && simpleAttr.Name.contains('parentSpec') && !simpleAttr.value.startsWith('DMCAT_ProductSpecification_')) {
                        additionalAttrs.put(simpleAttr.name, simpleAttr.value);
                    }
                    else if(string.isNotBlank(simpleAttr.Name) && (simpleAttr.Name.contains('InstanceId')||simpleAttr.Name.contains('InstanceID'))&& !simpleAttr.value.startsWith('DMCAT_ProductSpecification_')) {
                        additionalAttrs.put(simpleAttr.name, simpleAttr.value);
                    }
                }
                if(!additionalAttrs.isEmpty()) {
                    system.debug('TestTest');
                    csedm.API_1.addCharacteristic(serSpec.serviceId, serSpec.guid, additionalAttrs);
                }
            }
        }   
    }
    
    public static Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> getOrderSpecs(List<Id> orderIds) {
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> specMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();
        for (Id ordId: orderIds) {
            List<CS_SpecificationDTO.ServiceSpecification>  specList = new List<CS_SpecificationDTO.ServiceSpecification>();
            String orderSpec = csedm.API_1.getOrderSpecificationsById(ordId);
            if(!String.isEmpty(orderSpec)){
                system.debug('**************orderSpec : '+orderSpec);
                specList = CS_SpecificationDTO.parse(orderSpec);
                system.debug('**************specList<><>: '+specList);
                specMap.put(ordId, specList);
            }
        }
        return specMap;
    }
    public static DateTime AddBusinessDays(Date StartDate, Integer days){
      //Add or decrease in BusinessDaysToAdd days 
        Integer BusinessDaysToAdd = days;
        Date finalDate = StartDate;
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