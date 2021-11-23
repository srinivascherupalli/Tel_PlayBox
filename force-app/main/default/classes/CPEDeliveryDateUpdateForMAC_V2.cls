/*
===============================================================================================================================
Class : CPEDeliveryDateUpdateForMAC_V2
Developer Name : Ashish Agarwal
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Ashish Agarwal      7/11/2018    
2.       Vaibhav Deshpande    23/12/2019    EDGE-127367 DML and SOQL inside FOR loop
===============================================================================================================================
*/

public with sharing class CPEDeliveryDateUpdateForMAC_V2 {

      public static final Integer workingDays = integer.ValueOf(Label.WorkingDaysForMac);
    //public static final Integer workingDays = 10;
    public static void addCPEAttr(List<Id> serviceIds) {  
        Map<Id, Attachment> attsMapToUpdate = new Map<Id, Attachment>();
        List<Id> subIdList = new List<Id>();
        Set<Id> serviceList = new Set<Id>();
        Set<Id> updateServiceList = new Set<Id>();
        List<Id> servicePcIdList = new List<Id>();
        Map<Id,Id> pcIdSubIdMap = new Map<Id,Id>();
        Map<Id,Id> pcIdToServiceIdMap = new Map<Id,Id>();
        for(csord__Service__c serviceInstance : [SELECT Id, Name, csordtelcoa__Product_Configuration__c, csord__Subscription__c, csord__Order__c FROM csord__Service__c where csord__Service__c = null AND Appointment_Required__c!='true' AND Id IN: serviceIds]){
            if(serviceInstance.csordtelcoa__Product_Configuration__c != null){
                servicePcIdList.add(serviceInstance.csordtelcoa__Product_Configuration__c);
                System.debug('<><><>');
                pcIdToServiceIdMap.put(serviceInstance.csordtelcoa__Product_Configuration__c, serviceInstance.Id);
            }
        }
        if(servicePcIdList.Size()>0){
            for(cscfga__Product_Configuration__c pc: [SELECT Id, Name, (SELECT Id, Name, cscfga__Value__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c Where Id IN: servicePcIdList]){
                Boolean changeType = false;
                Boolean ipSiteConfigurationChanged = false;
                for(cscfga__Attribute__c att: pc.cscfga__Attributes__r){
                    //System.debug('attname'+att.Name+' '+att.cscfga__Value__c);
                    if(att.Name == 'ChangeType' && (att.cscfga__Value__c != '' &&  att.cscfga__Value__c != null)){
                        System.debug('attname'+att.Name+' '+att.cscfga__Value__c);
                        changeType =true;
                    }
                    if(att.Name == 'IPSiteConfigurationChanged' && (att.cscfga__Value__c == '' || att.cscfga__Value__c == null)){
                       System.debug('attname'+att.Name+' '+att.cscfga__Value__c);
                       ipSiteConfigurationChanged = true;
                    }
                }
                if(changeType == true && ipSiteConfigurationChanged == true){
                    if(pcIdToServiceIdMap.get(pc.Id) != null){
                        serviceList.add(pcIdToServiceIdMap.get(pc.Id));
                    }
                }
            }
        }
        System.debug('OrderIdList<><>'+serviceList);
        for(csord__Service__c serviceInstance : [SELECT Id, csord__Service__c FROM csord__Service__c where Id IN: serviceList OR csord__Service__c IN: serviceList]){
            updateServiceList.add(serviceInstance.Id);
        }
        Map<Id, Attachment> attmAP = new Map<Id, Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: updateServiceList and name = 'ServiceSpecifications.json']);
        FOR(Id attId : attmAP.keyset()  ){
                String serviceattachmentstr = attmAP.get(attId).body.toString();
                //system.debug('serviceattachmentstr'+serviceattachmentstr);
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
                system.debug('results'+results);
                List<Object> lstSpecifications = (List<Object>)results.get('specifications');
                system.debug(lstSpecifications[0]);
                for(Object specification : lstSpecifications) {
                    Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                     // now loop through our specification attributes.
                      
                    Map<String, String> additionalAttrs = new Map<String, String>();
                    Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('attributes');
                    for(String atrributeattName: attributesMap.keyset()){
                        system.debug('atrributeattName'+atrributeattName);
                        string tempValue = (String)JSON.deserialize(JSON.serialize(atrributeattName), String.class);
                        /*string tempValue = '';
                                if(attributesMap.get(atrributeattName) != null && attributesMap.get(atrributeattName) != ''){
                                tempValue = (String)JSON.deserialize(JSON.serialize(attributesMap.get(atrributeattName)), String.class);
                                }*/
                        if(tempValue.contains('CPEDeliveryDate')){
                            system.debug('in main part');
                            DateTime tt = addbusinessDays(System.today(), workingDays);
                            additionalAttrs.put(atrributeattName, tt.format('yyyy-MM-dd\'T\'HH:mm:ss'));
                        }
                    }
                    system.debug('additionalAttrs===='+additionalAttrs);
                    if(!additionalAttrs.isEmpty()) {
                                    // MG fix for SOQL101 start
                                    //csedm.API_1.addCharacteristic(serSpec.serviceId, serSpec.guid, additionalAttrs);
                                    if(specificationAttributes.get('additionalAttributes')!=null){
                                        Map<String, Object> tempAdditionalAttMap = (Map<String, Object>) specificationAttributes.get('additionalAttributes');
                                        tempAdditionalAttMap.putall(additionalAttrs);
                                        specificationAttributes.put('additionalAttributes', tempAdditionalAttMap);
                                    }else{
                                        specificationAttributes.put('additionalAttributes', additionalAttrs);
                                    }
                                    serviceattachmentstr = JSON.serializePretty(results);
                                    String str = serviceattachmentstr;
                                    attmAP.get(attId).body = blob.valueOf(str);
                                    attsMapToUpdate.put(attId, attmAP.get(attId));
                    }
                }
                system.debug('attsMapToUpdate===='+attsMapToUpdate);
           /* if (attsMapToUpdate.size() > 0){ 
                update attsMapToUpdate.values();    //taking outside of FOR loop to update - as per sonar cube report   -- Vaibhav
            }*/ 
        } 
        //**EDGE-127367 - Start
        if (attsMapToUpdate.size() > 0){
                update attsMapToUpdate.values();       
            }  //**EDGE-127367 - End
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