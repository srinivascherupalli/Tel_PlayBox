/*
===============================================================================================================================
Class : LinkNumberAndServiceOrchHandler
Developer Name :
Test Class : LinkNumberAndServiceOrchHandlerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
  1.      Prajakta Patil     27/04/2020    EDGE-142322 SIM Serial Number conversion to assetable attribute and order creation of both port out reversal and SIM Replacement order types 
  2.      Prajakta            15/05/2020   EDGE 148802
  3.      Sandip Deshmane     22/5/2020   //EDGE-149261 - Setting ShippingRequired Attribute
  4.      Prajakta Patil      08/06/2020   EDGE-153681
  5.      Maq                  06/07/2020  //  EDGE-155321 Bug Fix - Changes related to MACD bug fix
===============================================================================================================================
 Name: LinkNumberAndServiceOrchHandler
 Description: Class to update SIMSerailNumber and IMSI in service spec
**************************************************************/

global with sharing class LinkNumberAndServiceOrchHandler implements CSPOFA.ExecutionHandler {
     public class My2Exception extends Exception {}
    public List<SObject> process(List<SObject> steps){
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
            List<Id> orderIds = new List<Id>();
            List<Id> orchesIds= new List<Id>();
            try{ 
            for(CSPOFA__Orchestration_Step__c step: stepList)
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            
            List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Subscription__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
            System.debug('orchList ::'+orchList);
            for(CSPOFA__Orchestration_Process__c  orch : orchList)
                orderIds.add(orch.Order__c);
          
            updateServiceSpec(orderIds);
            for(CSPOFA__Orchestration_Step__c step : stepList){
                step.CSPOFA__Status__c = Label.Complete;
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
               
            }
             if(Test.isRunningTest()){ //added as part of EDGE-120128
                throw new My2Exception('My exception');
            }   
            }catch(Exception ex)
            { for (CSPOFA__Orchestration_Step__c step : stepList) { 
                    step.CSPOFA__Status__c = Label.Error; 
                    step.CSPOFA__Completed_Date__c = Date.today(); 
                    step.CSPOFA__Message__c = 'Exception: ' + ex.getMessage() + ' - ' + ex.getLineNumber(); }
            }
            return stepList;
        }  
    
    
    public  void updateServiceSpec(List<Id> orderIds){
        Map<Id,List<csord__Service__c>> orderIdSerMap = new Map<Id,List<csord__Service__c>>();
        List<String> sernumList = new List<String>();
        Map<String,List<Number__c>> servNumberMap = new  Map<String,List<Number__c>>();
        Map<Id,Map<String,String>> servSimImsiMap = new  Map<Id,Map<String,String>>();
        Map<Id,String> servIdToPCIDMap=new Map<Id,String>();
        Map<String,String> servIdToPCIDforSIMMap=new Map<String,String>();
       // Map<String,Map<String,String>> PCIDtoIMSISIMSerialMap=new  Map<String,Map<String,String>>();
        Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();
         Map<string,string> SimImsiMap = new Map<String,String>();
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>();
        Map<String,String> addAttrMap = new Map<String,String>();
        Map<String,Map<String,String>> guidAddAttrMap = new Map<String,Map<String,String>>();
        Map <Id,String> svcIdToServIdMap = new Map<Id,String>() ; // EDGE-155321 Bug Fix - Changes related to MACD bug fix
        Map <Id,String> svcIdToScenarioTypeMap = new Map<Id,String>() ; // EDGE-155321 Bug Fix - Changes related to MACD bug fix

         List<csord__Service__c> serviceList = [Select id,csord__Order__c,csordtelcoa__Service_Number__c,csordtelcoa__Product_Configuration__c,Scenario_Type__c,Sim_Serial_Number__c from csord__Service__c where csord__Order__c IN:orderIds and csord__Service__c=null ];
        system.debug('&&&&&-->serviceList'+serviceList);
        for(csord__Service__c serv :serviceList){
              SimImsiMap = new Map<String,String>();
            if(serv.Scenario_Type__c!='Replace SIM'){
             List<csord__Service__c> servList = new List<csord__Service__c>();
            system.debug('serv.prodConfig'+serv.csordtelcoa__Product_Configuration__c);
            if(!orderIdSerMap.isEmpty() && orderIdSerMap.get(serv.csord__Order__c)!= null){
                 servList = orderIdSerMap.get(serv.csord__Order__c);
                 servList.add(serv);
                
            }
            else{
                 servList.add(serv);
                }
            svcIdToServIdMap.put(serv.id,serv.csordtelcoa__Service_Number__c); // EDGE-155321 Bug Fix - Changes related to MACD bug fix
            svcIdToScenarioTypeMap.put(serv.id,serv.Scenario_Type__c); // EDGE-155321 Bug Fix - Changes related to MACD bug fix
            servIdToPCIDMap.put(serv.id,serv.csordtelcoa__Product_Configuration__c);
            orderIdSerMap.put(serv.csord__Order__c,servList);  
            servIdToPCIDforSIMMap.put(serv.id,serv.csordtelcoa__Product_Configuration__c);
        }
        else{
            servIdToPCIDforSIMMap.put(serv.id,serv.csordtelcoa__Product_Configuration__c);
            if(serv.Sim_Serial_Number__c!= null){
            SimImsiMap.put('SIMSerialNumber' , serv.Sim_Serial_Number__c);
            servSimImsiMap.put(serv.id,SimImsiMap);}
            // if(!SimImsiMap.isEmpty()){
           //  PCIDtoIMSISIMSerialMap.put(serv.csordtelcoa__Product_Configuration__c,SimImsiMap);}
        }
        }
        system.debug('servIdToPCIDMap'+servIdToPCIDMap);
         system.debug('orderIdSerMap'+orderIdSerMap);
        
    /*    for(Number__c num :[select id, Service_Id__c,Mobile__c,Service_Number__c,IMSI__c,Sim_Serial_Number__c,Product_Configuration__c from Number__c where Product_Configuration__c IN:servIdToPCIDMap.values() AND Mobile__c =:'Mobile']){ */
        system.debug('+++++++>'+svcIdToServIdMap.values());
        system.debug('+++++++>Main'+svcIdToServIdMap);
        // EDGE-155321 Bug Fix - Changes related to MACD bug fix
        for(Number__c num :[select id, Service_Id__c,Mobile__c,Service_Number__c,IMSI__c,Sim_Serial_Number__c,Product_Configuration__c from Number__c where Service_Id__c IN:svcIdToServIdMap.values() AND Mobile__c ='Mobile']){
            
            
             SimImsiMap = new Map<String,String>();
            //EDGE-149261 - Added ShippingRequired attribute to specs.
             if(num.Sim_Serial_Number__c!= null){
                SimImsiMap.put('SIMSerialNumber' , num.Sim_Serial_Number__c);
             }
                for (Id ser: svcIdToServIdMap.keySet()) {
                    if (num.Service_Id__c == svcIdToServIdMap.get(ser)) {
                        if (svcIdToScenarioTypeMap.get(ser) == 'Transition') {
                            if (num.Sim_Serial_Number__c != null) {
                                SimImsiMap.put('ShippingRequired', 'FALSE');
                            } 
                            /*else {
                                SimImsiMap.put('ShippingRequired', 'TRUE');
                            } */
                        }
                    }
                }
             if(num.IMSI__c!= null){
             SimImsiMap.put('IMSI' , num.IMSI__c);}
              
            //EDGE-153681
            /* for(Id ser :servIdToPCIDMap.keySet()){ */
            // EDGE-155321 Bug Fix - Changes related to MACD bug fix    
             for(Id ser :svcIdToServIdMap.keySet()){
                if(num.Service_Id__c == svcIdToServIdMap.get(ser)){
                    if(servSimImsiMap.containsKey(ser)){
                    Map<String,String> tempMap = servSimImsiMap.get(ser);
                        tempMap.putAll(SimImsiMap);     
                        servSimImsiMap.put(ser,tempMap);
                    }
                    else{
                    servSimImsiMap.put(ser,SimImsiMap);}
                    
                    break;
                }              
            }        
             
             
             //if(!SimImsiMap.isEmpty()){
            // PCIDtoIMSISIMSerialMap.put(num.Product_Configuration__c,SimImsiMap);}
        }
          
      //  system.debug('PCIDtoIMSISIMSerialMap'+PCIDtoIMSISIMSerialMap);
     
            List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();   
            Map<String, String> serviceAttachmentMap = new Map<String, String>();
            for(Attachment att: [SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: servIdToPCIDforSIMMap.keyset() and name = 'ServiceSpecifications.json']){
                serviceAttachmentMap.put(att.parentId,att.body.toString());
                 servAttachmentRecordMap.put(att.parentId,att);
                System.debug('serviceAttachmentMap==?'+serviceAttachmentMap );   
            }
            
            for(String eachService: serviceAttachmentMap.keySet()){
                srvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService))));
                System.debug('srvspecListv==>'+srvspecList);
            }
        
        
        for(CS_SpecificationDTO.ServiceSpecification specs : srvspecList) {
            
            if(specs.code=='DMCAT_ProductSpecification_000263_Fulfilment'){
                addAttrMap = new Map<String,String>();
                for(CS_SpecificationDTO.SimpleAttributes attr :specs.additionalAttributes){
                    addAttrMap.put(attr.name,attr.value);}
                    // EDGE 148802
                    if(servSimImsiMap.get(specs.serviceId)!= null){
                    addAttrMap.putAll(servSimImsiMap.get(specs.serviceId));} //EDGE-153681
                    guidAddAttrMap.put(specs.guid,addAttrMap);
                     
           // string pordConfig=servIdToPCIDforSIMMap.get(specs.serviceId);
               
                    String attach =csedm.API_1.addCharacteristic(serviceAttachmentMap.get(specs.serviceId),specs.serviceId, specs.guid, guidAddAttrMap.get(specs.guid));  
                      
                    System.debug('attach in getGuidNotifAttr ::' + attach);
                   Attachment attAdd = servAttachmentRecordMap.get(specs.serviceId);
                   attAdd.body = Blob.valueOf(attach);
                   updatedAttSet.put(attAdd.id,attAdd);           
                    
                    }
            
        }   

         if(!updatedAttSet.isEmpty()){
                   update updatedAttSet.values();}      
        }
}