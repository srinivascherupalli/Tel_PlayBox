public with sharing class importO2ADataFromCSVController {
  
  public String documentName {get;set;}
    public Blob csvFileBody{get;set;}
  public List <DatesO2ADTO.DatesO2A>lstDates {get;set;}
    public boolean readSuccess {get;set;}
    
    Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();
    Map<Id,csord__Service__c> updateServMap = new Map<Id,csord__Service__c>();
    List<csord__Subscription__c> updateSubList = new List<csord__Subscription__c>();
    
  public importO2ADataFromCSVController() {
        documentName = '';
        readSuccess = FALSE;
  lstDates = new List<DatesO2ADTO.DatesO2A>();}
       
    public void readFromFile(){
        try{
            String contactDataAsString  = csvFileBody.toString();
            readCSVFile(contactDataAsString);
        }
        catch(exception e){
            readSuccess = FALSE;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading JSON file');
            ApexPages.addMessage(errorMessage);
        }
    }    
  public void readCSVFile( String contactDataAsString) {
    lstDates.clear();
      system.debug('contactDataAsString:'+contactDataAsString);
      
      Map<String,Map<String,String> > guidDateMap = new Map<String,Map<String,String> >();
      Map<String,Map<String,String> >svcDateMap = new Map<String,Map<String,String> >();
      Map<String,String>serIdNumMap = new Map<String,String>();
       List<String>orderNumbers = new List<String>();
        List<String>svcNumbers = new List<String>();
        List<Id>servIdList = new List<id>();
       Map<String,String>svcguidMap = new Map<String,String>();
        Map<Id,String> serviceAttachmentMap = new Map<Id,String>();
       Map<String,Attachment> servAttachmentRecordMap = new Map<String,Attachment>();
       Map<Id,csord__Subscription__c>subMap = new Map<Id,csord__Subscription__c>();
       List<csord__Service__c> childserList = new List<csord__Service__c>();
      Map<String,List<csord__Service__c>>serChildMap =new Map<String,List<csord__Service__c>>();
      Map<String,Map<String,String>>serIdDatemap = new Map<String,Map<String,String>>();
       
        List<CS_SpecificationDTO.ServiceSpecification>srvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
       DatesO2ADTO dto = DatesO2ADTO.parse(contactDataAsString);
       system.debug('datesO2AList:'+dto);
       for(DatesO2ADTO.DatesO2A  d:dto.datesO2AList){
              Map<String,String>dateMap =  new Map<String,String>();

         if(!String.isBlank(d.telstraCommittedDate)){
         dateMap.put('telstraCommittedDate',d.telstraCommittedDate);}
         
         if(!String.isBlank(d.currentForecastedDeliveryDate)){
         dateMap.put('currentForecastedDeliveryDate',d.currentForecastedDeliveryDate);}
         
         if(!String.isBlank(d.productCompletionDate)){
         dateMap.put('productCompletionDate',d.productCompletionDate);}
         
         if(!String.isBlank(d.productCancellationDate)){
         dateMap.put('productCancellationDate',d.productCancellationDate);}
         
         if(!String.isBlank(d.ServiceActivationDate)){
         dateMap.put('ServiceActivationDate',d.ServiceActivationDate);}
         
         if(!String.isBlank(d.ServiceDeactivationDate)){
         dateMap.put('ServiceDeactivationDate',d.ServiceDeactivationDate);}
         
         if(!String.isBlank(d.DesignCompletionDate)){
         dateMap.put('DesignCompletionDate',d.DesignCompletionDate);}
         
         if(!String.isBlank(d.InstallationDate)){
         dateMap.put('InstallationDate',d.InstallationDate);}
         
         if(!String.isBlank(d.EquipmentDeliveredDate)){
         dateMap.put('EquipmentDeliveredDate',d.EquipmentDeliveredDate);}
         
         if(!String.isBlank(d.CustomerOrderAcceptanceDate)){
         dateMap.put('CustomerOrderAcceptanceDate',d.CustomerOrderAcceptanceDate);}
         
         if(!String.isBlank(d.EstimatedDeliveryDate)){ dateMap.put('EstimatedDeliveryDate',d.EstimatedDeliveryDate);}
         
         if(!String.isBlank(d.EquipmentOrderedDate)){
             dateMap.put('EquipmentOrderedDate',d.EquipmentOrderedDate);}

           String orderId; String srvcNumber; String guid;
          
                List<String> keyparams = d.Order_Item_ID.split('\\|');
                if(keyparams.size() > 0){ orderId = keyparams[0]; }
                if(keyparams.size() > 1){ srvcNumber = keyparams[1]; }
                if(keyparams.size() > 2){ guid = keyparams[2]; }
                orderNumbers.add(orderId);
                svcNumbers.add(srvcNumber);
                svcguidMap.put(srvcNumber,guid);
                guidDateMap.put(guid,dateMap);
                String identifier = orderId+'|'+srvcNumber;
                svcDateMap.put(identifier,dateMap);
           lstDates.add(d);
       }
       
     
      system.debug('guidDateMap:'+guidDateMap);

       List<csord__Service__c> srvcList = [SELECT Id, Name, csord__Status__c, csordtelcoa__Service_Number__c,csord__Order__c,csord__Subscription__c,Telstra_Committed_Date__c,Forecasted_Delivery_Date__c,Completion_Date__c,Initial_Activation_DateTime__c,Deactivation_Date__c,csord__Subscription__r.Estimated_Delivery_Date__c,csord__Order__r.csord__Order_Number__c,csord__Service__c,(Select id,Name, csord__Status__c, csord__Subscription__c,csord__Subscription__r.customerFacingServiceId__c ,csord__Order__c,toBeCancelled__c, csord__Order__r.id , csordtelcoa__Service_Number__c,Forecasted_Delivery_Date__c, csord__Subscription__r.id,Telstra_Committed_Date__c,Completion_Date__c,Initial_Activation_DateTime__c,Deactivation_Date__c,csord__Subscription__r.Estimated_Delivery_Date__c,csord__Service__c from csord__Services__r) FROM csord__Service__c WHERE csordtelcoa__Service_Number__c IN:svcNumbers FOR UPDATE];
       
           system.debug('srvcList:'+srvcList);


       for(csord__Service__c ser :srvcList){
          servIdList.add(ser.id);
          serIdNumMap.put(ser.id,ser.csordtelcoa__Service_Number__c);
          subMap.put(ser.csord__Subscription__c, ser.csord__Subscription__r);
          childserList.addAll(ser.csord__Services__r);      
          serChildMap.put(ser.id,childserList);       
       }
       
       for(csord__Service__c ch :childserList){ servIdList.add(ch.id);  
       }
       
            for(Attachment att: [Select id,body,parentId from Attachment where parentId in :servIdList]){
                serviceAttachmentMap.put(att.parentId,att.body.toString());
                servAttachmentRecordMap.put(att.parentId,att);
            }
            
            if(!srvcList.isEmpty()){
             for(csord__Service__c serv : srvcList){
                 
                    if(!serviceAttachmentMap.isEmpty()){
                    for(String eachService: serviceAttachmentMap.keySet()){
                         srvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(serv.Id)),'FULFILMENT'));
                    }}
                        
                        if(!svcDateMap.isEmpty() && svcDateMap.get(serv.csord__Order__r.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c)!= null){
                         Map<String,String> dtMap= svcDateMap.get(serv.csord__Order__r.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c);
                          serIdDatemap.put(serv.id,dtMap);
                             if(dtMap.containsKey('telstraCommittedDate')){serv.Telstra_Committed_Date__c =DateTime.valueOfGmt(dtMap.get('telstraCommittedDate').replaceAll('T',' '));}
                             
                             if(dtMap.containsKey('currentForecastedDeliveryDate')){serv.Forecasted_Delivery_Date__c =DateTime.valueOfGmt(dtMap.get('currentForecastedDeliveryDate').replaceAll('T',' '));}
                             
                             if(dtMap.containsKey('productCompletionDate')){serv.Completion_Date__c =DateTime.valueOfGmt(dtMap.get('productCompletionDate').replaceAll('T',' '));}
                             
                             if(dtMap.containsKey('ServiceActivationDate')){serv.Initial_Activation_DateTime__c =DateTime.valueOfGmt(dtMap.get('ServiceActivationDate').replaceAll('T',' '));}
                             
                             if(dtMap.containsKey('ServiceDeactivationDate')){serv.Deactivation_Date__c =DateTime.valueOfGmt(dtMap.get('ServiceDeactivationDate').replaceAll('T',' '));}
                             
                             updateServMap.put(serv.id,serv);
                          
                            if(dtMap.containsKey('EstimatedDeliveryDate')){
                                
                                if(subMap.ContainsKey(serv.csord__Subscription__c)){ csord__Subscription__c subs = subMap.get(serv.csord__Subscription__c);
                                    subs.Estimated_Delivery_Date__c = DateTime.valueOfGmt(dtMap.get('EstimatedDeliveryDate').replaceAll('T',' '));
                                    
                        updateSubList.add(subs);}}
                        }                               
                            
                }}
                         
         
             system.debug('srvspecList:'+srvspecList);
             
             for(CS_SpecificationDTO.ServiceSpecification spec :srvspecList){
                  
            if(spec.guid == svcguidMap.get(serIdNumMap.get(spec.serviceId))){
                system.debug('inside if::');
                if(!serviceAttachmentMap.isEmpty() && serviceAttachmentMap.get(spec.serviceId)!= null && !guidDateMap.isEmpty()&& guidDateMap.get(spec.guid)!= null){
                 // String attach = csedm.API_1.addCharacteristic(serviceAttachmentMap.get(spec.serviceId),spec.serviceId, spec.guid,guidDateMap.get(spec.guid));
         String attach = ServiceSpecificationUtils.addAdditionalAttributeNoSOQL(serviceAttachmentMap.get(spec.serviceId),spec.guid,guidDateMap.get(spec.guid));
                  Attachment att = servAttachmentRecordMap.get(spec.serviceId); att.body = Blob.valueOf(attach);updatedAttSet.put(att.id,att);}
             }}
             
           for(Id parentId  :serChildMap.keyset()){
               List<csord__Service__c> chList = serChildMap.get(parentId); 
             if(!chList.isEmpty()){            
               for(csord__Service__c child :chList){
                   system.debug('serIdDatemap:'+serIdDatemap);
                    system.debug('serIdDatemap1:'+serIdDatemap.get(child.csord__Service__c));
                 Map<String,String> childDateMap = serIdDatemap.get(child.csord__Service__c);
                 
                 system.debug('childDateMap:'+childDateMap);
                 if(serIdDatemap.get(child.csord__Service__c)!= null){ if(childDateMap.containsKey('telstraCommittedDate')){
                               
                                 child.Telstra_Committed_Date__c =DateTime.valueOfGmt(childDateMap.get('telstraCommittedDate').replaceAll('T',' '));}
                             
                             if(childDateMap.containsKey('currentForecastedDeliveryDate')){child.Forecasted_Delivery_Date__c =DateTime.valueOfGmt(childDateMap.get('currentForecastedDeliveryDate').replaceAll('T',' '));}
                             
                             if(childDateMap.containsKey('productCompletionDate')){child.Completion_Date__c =DateTime.valueOfGmt(childDateMap.get('productCompletionDate').replaceAll('T',' '));}
                             
                             if(childDateMap.containsKey('ServiceActivationDate')){child.Initial_Activation_DateTime__c =DateTime.valueOfGmt(childDateMap.get('ServiceActivationDate').replaceAll('T',' '));}
                             
                             if(childDateMap.containsKey('ServiceDeactivationDate')){ child.Deactivation_Date__c =DateTime.valueOfGmt(childDateMap.get('ServiceDeactivationDate').replaceAll('T',' '));}
                             
                 updateServMap.put(child.id,child);}

               List<CS_SpecificationDTO.ServiceSpecification> childsrvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(child.Id)),'FULFILMENT');
                if(!childsrvspecList.isEmpty()){
                for(CS_SpecificationDTO.ServiceSpecification childspec :childsrvspecList){
                    //String childattach = csedm.API_1.addCharacteristic(serviceAttachmentMap.get(childspec.serviceId),childspec.serviceId, childspec.guid,childDateMap);
             String childattach = ServiceSpecificationUtils.addAdditionalAttributeNoSOQL(serviceAttachmentMap.get(childspec.serviceId),childspec.guid,childDateMap);
                  Attachment childatt= servAttachmentRecordMap.get(childspec.serviceId);
                  childatt.body = Blob.valueOf(childattach);updatedAttSet.put(childatt.id,childatt);
                }}
               }
           }
          }
        if(lstDates.size() > 0){
            readSuccess = TRUE;
        }          
  }
  public void saveData() {
    try {
      System.debug('lstDates:'+lstDates);
      System.debug('updatedAttSet.values():'+updatedAttSet.values());
       if(!updatedAttSet.isEmpty()) {update updatedAttSet.values();}
       
       if(!updateServMap.isEmpty()){update updateServMap.values();}
       
       if(!updateSubList.isEmpty()) {update updateSubList;}
       
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, 'Records updated successfully');
      ApexPages.addMessage(errorMessage);
    } catch (Exception e) { ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured while saving data');
      ApexPages.addMessage(errorMessage);
    }
  }
}