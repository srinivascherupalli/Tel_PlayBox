/*
===============================================================================================================================
Class : TransitionServicesCreationObserverHelper
Test Class : TransitionServiceObserverHelperTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1           Pawan               08/29/2019      EDGE-109442 : Created custom label to hold associate role values & did related change in code.
2           Anu Yadav           11/14/2019      EDGE-101066 : updated methods to create Subscription and modified service and specs.
3.        Shreya jaiswal          12/13/19        EDGE-125031 : Transition
4.      Sandip Deshmane    20/5/2020    //EDGE-149573 : Updated attributes to send in Specs in case of Transition
5.      Sandip Deshmane    29/5/2020    EDGE-152029 : Updated Transition ID attribute Name
6.      Sandip Deshmane    4/6/2020    //EDGE-151668 - commented below line to avoid passing multiple numbers in same service.
7.      Sandip Deshmane     6/11/2020   EDGE-154518 - Fixed Primary String Literal and Sending Prime number in Number Block
8.    Sandip Deshmane    6/18/2020  EDGE-156658 - Added gdn association role.
===============================================================================================================================*/

public with sharing class TransitionServicesCreationObserverHelper {
    static Boolean IsServiceInserted=false;
    static Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>> servlistmap=null;
    static Map<String,List<TransitionDataDTO.serviceDTOMobile>> ngUcServiceListMap = null;
    //accepts Service DTO and creates legacy subscriptions and services
    public static void createLegacyServices(List<Id> subscriptionIdList){
        Set<ID> ProductBasketID=new Set<ID>();
        Map<Id,ID> PCRToServicecIdMap=new Map<Id,ID>();
        Map<id,id> ServicecToOrderMap=new Map<id,id>();
        Map<id,id> ServicecToSubMap=new Map<id,id>();
        Set<String> PC_ID_set=new Set<String>();
               
        //Method to create legacy services on connected workplace subscription
        for(csord__Service__c serv:[select id,csord__Subscription__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c,csordtelcoa__Product_Configuration__c,csord__Order__c from csord__Service__c WHERE csord__Subscription__c IN: subscriptionIdList and csordtelcoa__Product_Configuration__c!=null]){
            ProductBasketID.add(serv.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c);
            PCRToServicecIdMap.put(serv.csordtelcoa__Product_Configuration__c,serv.id);
            ServicecToOrderMap.put(serv.Id,serv.csord__Order__c);
            ServicecToSubMap.put(serv.Id,serv.csord__Subscription__c);
            PC_ID_set.add(serv.csordtelcoa__Product_Configuration__c); //EDGE-98459
        }
        //Vimal: commenting as order id can be fetched from previous soql //EDGE-98459
        /*for(csord__Service__c serv:[select id,csord__Subscription__c,csordtelcoa__Product_Configuration__c,csord__Order__c from csord__Service__c where csord__Subscription__c IN: subscriptionIdList and name=:System.Label.ProductConfigName]){
            PCRToSubscriptionIdMap.put(serv.csordtelcoa__Product_Configuration__c,serv.csord__Subscription__c);
            SubscriptionToOrderMap.put(serv.csord__Subscription__c,serv.csord__Order__c);
        }*/
        //Set<String> PCR_ID_set=new Set<String>();

        //Map<ID,ID> PC_To_PCR_Map=new Map<ID,ID>();
        //Vimal: commenting PCR query as no soql is needed
        /*for(csbb__Product_Configuration_Request__c pcr:[Select id,csbb__Product_Configuration__c from csbb__Product_Configuration_Request__c where csbb__Product_Basket__c IN:ProductBasketID and csbb__Product_Configuration__r.name=:System.Label.ProductConfigName]){
            PCR_ID_set.add(pcr.id);
            PC_To_PCR_Map.put(pcr.id,pcr.csbb__Product_Configuration__c);
        }*/
        
        /*for(cscfga__Product_Configuration__c pc:[Select id,cscfga__Product_Basket__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c IN:ProductBasketID and name=:System.Label.ProductConfigName]){
            PC_ID_set.add(pc.id);
            //PC_To_PCR_Map.put(pc.id,pc);
        }*/
        //system.debug('@@PCR_ID_set@@'+PCR_ID_set);
        system.debug('@@PC_ID_set@@'+PC_ID_set);
        system.debug('@@PCRToSubscriptionIdMap@@'+PCRToServicecIdMap);
        //system.debug('@@PC_To_PCR_Map@@'+PC_To_PCR_Map);       
         
        Map<id,ReplicatorGetServiceDataObject_V2> DTO_to_PcrMap=new Map<id,ReplicatorGetServiceDataObject_V2>();
        Map<Id,TransitionDataDTO> ngUCPcrMap = new Map<Id,TransitionDataDTO>();
        for(Attachment atchmnt:[select ID, name, body, parentId from Attachment where parentId in: PC_ID_set and (name =:System.label.DTOName OR name =:System.label.NgUcTransitionName)]){
            system.debug('@@pcr_att_id@@'+String.valueOf(atchmnt.parentId));
            //atttchmentWithParentId.put(atchmnt.parentId, atchmnt);
             
            system.debug('attt'+atchmnt.body.toString());
            if(atchmnt.name == System.label.DTOName){
            ReplicatorGetServiceDataObject_V2 AttchedServiceDTO = ReplicatorGetServiceDataObject_V2.parse(atchmnt.body.toString());
            DTO_to_PcrMap.put(atchmnt.parentId,AttchedServiceDTO);         
        }
        else if (atchmnt.name == System.label.NgUcTransitionName){
            TransitionDataDTO transitionDTO=TransitionDataDTO.parse(atchmnt.body.toString());
            ngUCPcrMap.put(atchmnt.parentId,transitionDTO);
        }       
        }
        //Commenting this out
        /*for(Id PCR_ID:DTO_to_PcrMap.keySet()){
            system.debug('***inside create services****');
            //system.debug('***subscriptionId***'+PCRToSubscriptionIdMap.get(PC_To_PCR_Map.get(PCR_ID)));
            if(PCRToSubscriptionIdMap.get(PC_To_PCR_Map.get(PCR_ID))!=null){
                LegacyServiceList(DTO_to_PcrMap.get(PCR_ID),PCRToSubscriptionIdMap.get(PC_To_PCR_Map.get(PCR_ID)),SubscriptionToOrderMap.get(PCRToSubscriptionIdMap.get(PC_To_PCR_Map.get(PCR_ID))));
            }   
        }*/  
        
        for(Id PC_ID : ngUCPcrMap.keySet()){
          ngUCLegacyServiceList(ngUCPcrMap.get(PC_ID),ServicecToSubMap.get(PCRToServicecIdMap.get(PC_ID)),ServicecToOrderMap.get(PCRToServicecIdMap.get(PC_ID)));
        }           
        for(Id PC_ID:DTO_to_PcrMap.keySet()){
          LegacyServiceList(DTO_to_PcrMap.get(PC_ID),ServicecToSubMap.get(PCRToServicecIdMap.get(PC_ID)),ServicecToOrderMap.get(PCRToServicecIdMap.get(PC_ID)));
          
        } 
    }
      
    //insert legacyservices,spec,fnn specs 
     public static void  LegacyServiceList(ReplicatorGetServiceDataObject_V2 siteDTO,ID SubscrptionID,Id OrderID){
        Map<String,ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> serviceAndServiceDTOMap = new Map<String,ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();
        Map<String,String> nameValueMap = new Map<String,String>();
        List<csord__Service__c> servListTobeInserted= new List<csord__Service__c>();
        servlistmap=new Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>>();
        JSONGenerator PrimaryFNN=JSON.createGenerator(true) ;
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site: siteDTO.site)  
        {
            //create legacy service for each service in Replicator
            system.debug('**Adbor_id**'+site.ADBOR_ID);
            system.debug('**SubscrptionID**'+SubscrptionID);
            for(ReplicatorGetServiceDataObject_V2.productListDTO prod: site.productList )
            {
                if(prod.checkValue==true){
                    csord__Service__c service= new csord__Service__c();
                    service.Name = System.Label.LegacySpecName;
                    service.Offer_Type__c = prod.Product_Type;
                    service.csord__Subscription__c = SubscrptionID;
                    service.csord__Order__c=OrderID;
                    List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> servList1=new List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();
                    for(ReplicatorGetServiceDataObject_V2.serviceListDTO  servlist: prod.serviceList)  
                    {      
                        //PrimaryFNN = generatePrimaryFNNAttribute(servlist.service);
                       // NumberJSON=generateNumberAttribute(servlist.service);
                       if(servlistmap.containsKey(prod.Product_Type)){
                            servList1=servlistmap.get(prod.Product_Type);
                            servList1.addAll(servlist.service);
                        }else{
                            servList1.addAll(servlist.service);
                        }
                        servlistmap.put(prod.Product_Type,servList1);                    
                         
                    }
                    system.debug('@@servlistmap@@'+servlistmap);
                    //service.Primary_FNN__c=PrimaryFNN.getAsString();
                    //system.debug(System.label.PrimaryFNN+service.Primary_FNN__c);
                    service.csord__Identification__c = 'Service_'+SubscrptionID;
                    service.csord__Status__c =System.Label.LegacySpecStatus;
                    system.debug('@service@'+service);
                    servListTobeInserted.add(service);
                }
            }
             
        }
        if(servListTobeInserted != null && servListTobeInserted.size()>0)
        {  
            insert servListTobeInserted;
            List<Attachment> attachList = new List<Attachment>();
            JSONGenerator serviceSpecJSON;
            //Create Legacy Voice Specifications and Legacy Voice FNN Specifications for each service
            List<CS_SpecificationDTO.serviceSpecification> specificationList = new List<CS_SpecificationDTO.serviceSpecification>();
            for(csord__Service__c  serv : servListTobeInserted)
            {  
                CS_SpecificationDTO.serviceSpecification spec = new CS_SpecificationDTO.serviceSpecification();
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('serviceId',serv.Id);
                gen.writeFieldName('specifications');
                gen.writeStartArray();
                String guid = generateGuid();
                List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> service=servlistmap.get(serv.Offer_Type__c);
                system.debug('@@service@@'+service);

                serviceSpecJSON = createLegacyServiceSpec(spec,serv,gen,guid,service);
               
                gen.writeEndArray();
                gen.writeEndObject();
                String serializedBody = gen.getAsString().replace('\\"','');
                System.debug('****serializedBody'+ serializedBody);
                String tempJson1 = serializedBody.replaceAll('\\[ ','[');
                //String tempJson2 = tempJson1.replaceAll('[]','[]');
                String tempJson3 = tempJson1.replaceAll(' \\]',']');
                Blob body = Blob.valueOf(tempJson3);
                Attachment att = new Attachment();
                att.Name =  'ServiceSpecifications.json';
                att.ParentId = serv.Id;
                att.Body = body;
                attachList.add(att);
            }
            system.debug('@attachList@'+attachList);   
            insert attachList;
         
        } 
    }
    //generate Service records for Transition UC subscription records for ngUC : EDGE-101066
     public static void  ngUCLegacyServiceList(TransitionDataDTO transitionDTO,ID SubscrptionID,Id OrderID){
        Map<String,TransitionDataDTO.serviceDTOMobile> serviceAndServiceDTOMap = new Map<String,TransitionDataDTO.serviceDTOMobile>();
        Map<String,String> nameValueMap = new Map<String,String>();
        List<csord__Service__c> servListTobeInserted= new List<csord__Service__c>();
        List<String> siteADBORID = new List<String>();
        List<csord__Subscription__c> subListTobeInserted = new List<csord__Subscription__c>();
        ngUcServiceListMap=new Map<String,List<TransitionDataDTO.serviceDTOMobile>>();
         
        JSONGenerator PrimaryFNN=JSON.createGenerator(true) ;
        
         Map<Id,String> mapSubIdToSubNumber = new Map<Id,String>();
         for(csord__Subscription__c subRec : [SELECT Id,Name,csordtelcoa__Subscription_Number__c FROM csord__Subscription__c WHERE Id =:SubscrptionID ]){
             mapSubIdToSubNumber.put(subRec.Id,subRec.csordtelcoa__Subscription_Number__c);
        }
        
        for(TransitionDataDTO.productListDTO productList : transitionDTO.productList)   
        {
            //create legacy service for each service in Replicator
            //system.debug('**Adbor_id**'+site.ADBOR_Id);
            //system.debug('**SubscrptionID**'+SubscrptionID);
            for(TransitionDataDTO.SiteDTOMobile siteDTO:productList.site)
            {
                //EDGE-151668   
                //List<TransitionDataDTO.serviceDTOMobile> servList1=new List<TransitionDataDTO.serviceDTOMobile>();
                    for(TransitionDataDTO.serviceListDTOMobile serviceListDTO : siteDTO.serviceList ){  
                      for(TransitionDataDTO.groupDTOMobile groupDTO : serviceListDTO.groupType ){
                          if(groupDTO.checkValue==true){
                             csord__Subscription__c newSub = new csord__Subscription__c();
                             newSub.Name=System.Label.LegacySubscriptionName+' '+groupDTO.groupId;//'Transition UC Subscription';
                             newSub.csord__Status__c=System.Label.LegacySpecStatus;
                             newSub.Billing_Account__c=null;
                             newSub.csord__Order__c = OrderID;
                             newSub.csord__Identification__c='SUB_'+SubscrptionID;
                             //EDGE-125031 : removed
                             //newSub.Commercial_Subscription__c = mapSubIdToSubNumber.get(SubscrptionID);
                             newSub.ADBORID__c = siteDTO.ADBOR_Id;
                             newSub.Product_Type__c = productList.Product_Type;
                             newSub.Transition_ID__c = groupDTO.transitionId;
                             //EDGE-125031 : added
                             newSub.legacy_subscription__c = SubscrptionID;
                             subListTobeInserted.add(newSub);   
                             siteADBORID.add(siteDTO.ADBOR_Id);
                             
                         }
                        //EDGE-151668
                        ngUcServiceListMap.put(groupDTO.transitionId, groupDTO.service);      
                        /*  
                        for(TransitionDataDTO.serviceDTOMobile serviceDTO : groupDTO.service ){                 
                         if(ngUcServiceListMap.containsKey(productList.Product_Type)){
                            servList1=ngUcServiceListMap.get(productList.Product_Type);
                            servList1.addAll(groupDTO.service);
                        }else{
                           servList1.addAll(groupDTO.service);
                        }
                          ngUcServiceListMap.put(productList.Product_Type,servList1);                    
                         
                        }*/
                     }
                    }
                    system.debug('@@servlistmap@@'+ngUcServiceListMap);
                    //service.Primary_FNN__c=PrimaryFNN.getAsString();
                    //system.debug(System.label.PrimaryFNN+service.Primary_FNN__c);
                    //service.csord__Identification__c = 'Service_'+SubscrptionID;
                    //service.csord__Status__c =System.Label.LegacySpecStatus;
                    
              
            }
             
        }
        if(!subListTobeInserted.isEmpty()){
            insert subListTobeInserted;
            
            for(csord__Subscription__c subRec : subListTobeInserted){
               csord__Service__c serv= new csord__Service__c();
               serv.Name = 'Legacy Service'+' '+subRec.ADBORID__c;
               serv.csord__Subscription__c = subRec.ID;
               serv.csord__Order__c=OrderID;
               serv.csord__Identification__c ='SVC'+'_'+subRec.ADBORID__c;
               serv.Offer_Type__c = subRec.Product_Type__c;
               serv.Transition_Id__c = subRec.Transition_ID__c;
               serv.csord__Status__c ='Disconnect Pending';//System.Label.LegacySpecStatus;
               servListTobeInserted.add(serv);  
            }
        }   
         System.debug('servListTobeInserted::'+servListTobeInserted);
        if(!servListTobeInserted.isEmpty())
        {  
            insert servListTobeInserted;
            
            Map<Id,String> mapServIdToAdborId = new Map<Id,String>();
            for(csord__Service__c service : servListTobeInserted){
               String getAdborId = service.csord__Identification__c;
               String AdborId = getAdborId.removeStart('SVC_');
               mapServIdToAdborId.put(service.Id,AdborId);
            }   
            System.debug('mapServIdToAdborId::'+mapServIdToAdborId);
            List<Attachment> attachList = new List<Attachment>();
            JSONGenerator serviceSpecJSON;
            //Create Legacy Voice Specifications and Legacy Voice FNN Specifications for each service
            List<CS_SpecificationDTO.serviceSpecification> specificationList = new List<CS_SpecificationDTO.serviceSpecification>();
            for(csord__Service__c  serv : servListTobeInserted)
            {  
                CS_SpecificationDTO.serviceSpecification spec = new CS_SpecificationDTO.serviceSpecification();
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('serviceId',serv.Id);
                gen.writeFieldName('specifications');
                gen.writeStartArray();
                String guid = generateGuid();
                //EDGE-151668
                List<TransitionDataDTO.serviceDTOMobile> service=ngUcServiceListMap.get(serv.Transition_Id__c);
                system.debug('@@service@@'+service);

                serviceSpecJSON = createNGUCLegacyServiceSpec(spec,serv,gen,guid,service,mapServIdToAdborId.get(serv.Id),serv.Transition_Id__c);
               
                gen.writeEndArray();
                gen.writeEndObject();
                String serializedBody = gen.getAsString().replace('\\"','');
                System.debug('****serializedBody'+ serializedBody);
                String tempJson1 = serializedBody.replaceAll('\\[ ','[');
                //String tempJson2 = tempJson1.replaceAll('[]','[]');
                String tempJson3 = tempJson1.replaceAll(' \\]',']');
                Blob body = Blob.valueOf(tempJson3);
                Attachment att = new Attachment();
                att.Name =  'ServiceSpecifications.json';
                att.ParentId = serv.Id;
                att.Body = body;
                attachList.add(att);
            }
            system.debug('@attachList@'+attachList);   
            insert attachList;
         
        } 
    }
    //generate service specification CWP
    private static JSONGenerator createLegacyServiceSpec(CS_SpecificationDTO.serviceSpecification spec,csord__Service__c serv,JSONGenerator gen, String guid,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> service)        
    {
        spec.ServiceId = serv.Id;
        gen.writeStartObject();
        spec.code = System.Label.LegacyVoiceSpecCode;
        //spec.code='DMCAT_ProductSpecification_000343_Fulfilment';
        spec.version = '1';
        spec.status = System.Label.LegacySpecStatus;
        spec.startDate = String.valueOf(Date.today());
        spec.name = System.Label.LegacySpecName;
        spec.instanceId = guid;
        spec.guid = guid;
        gen.writeStringField('code',spec.code);
        gen.writeStringField('version',spec.version);
        gen.writeStringField('status',spec.status);
        gen.writeStringField('startDate',spec.startDate);
        gen.writeStringField('name',spec.name);
        gen.writeStringField('instanceId',spec.instanceId);
        gen.writeStringField('guid',spec.guid);
        List<CS_SpecificationDTO.SimpleAttributes> saList = new List<CS_SpecificationDTO.SimpleAttributes>();
        CS_SpecificationDTO.SimpleAttributes sa1 = new CS_SpecificationDTO.SimpleAttributes();  
        sa1.name = System.Label.LegacyProductType;
        sa1.value = serv.Offer_Type__c;
        saList.add(sa1);
        CS_SpecificationDTO.SimpleAttributes sa2 = new CS_SpecificationDTO.SimpleAttributes();
        sa2.name = System.Label.UCInstanceId;//'UCSiteProductInstanceID';
        sa2.value = System.Label.UCSiteProductInstanceID_Value;//'DMCAT_ProductSpecification_000322_Fulfilment';
        saList.add(sa2);
        CS_SpecificationDTO.SimpleAttributes sa3 = new CS_SpecificationDTO.SimpleAttributes();
        sa3.name =System.Label.LegacyTargetSystem;
        sa3.value =System.Label.LegacyTargetSystemValue; //'FULFILMENT';
        saList.add(sa3);
        CS_SpecificationDTO.SimpleAttributes sa4 = new CS_SpecificationDTO.SimpleAttributes();
        sa4.name = System.label.BSServiceTypeProductInstanceID;
        sa4.value = System.label.BSServiceTypeProductInstanceValue;//'DMCAT_ProductSpecification_000312_Fulfilment';
        saList.add(sa4);
        spec.simpleAttributes = new List<CS_SpecificationDTO.simpleAttributes>();
        spec.simpleAttributes.addAll(saList);
        gen.writeFieldName('attributes');
        gen.writeStartObject();
        for(CS_SpecificationDTO.SimpleAttributes saa:spec.simpleAttributes)
        {
         gen.writeStringField(saa.name,saa.value);   
        }
        //****PrimaryFNN Json*****
         
        //gen.writeFieldName(System.Label.PrimaryFNN);
        //gen.writeStartArray(); 
        List<String> sList=new List<String>();
        for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2  ser : service)
        {  
            if((ser.Association_Role=='' || ser.Association_Role==null || ser.Association_Role=='Primary'))
            {
                JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();
                gen2.writeStringField('Number',ser.Service_Id);
                //gen2.writeStringField('action',system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s=gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(s);
                String serializedresult=JSON.serialize(results);
                system.debug('@@'+serializedresult);
                sList.add(serializedresult);
            }
        }
        system.debug(sList);
        String serializedresult2=System.JSON.serializePretty(sList);
        system.debug('@@'+serializedresult2);
        gen.writeStringField(System.Label.PrimaryFNN,serializedresult2.replace('\\"', '\''));
        //NumberJson
        //gen.writeFieldName('Numbers');
        List<String> sList1=new List<String>();
        for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2  ser : service)
        {      
             
            if(ser.Association_Role=='Auxiliary')
            {
                JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();
                gen2.writeStringField('Number',ser.Service_Id);
                //gen2.writeStringField('action',system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s=gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(s);
                String serializedresult=JSON.serialize(results);
                system.debug('@@'+serializedresult);
                sList1.add(serializedresult);
            }
            List<ServiceExtentionComparableWrapper > serEXtList = new List<ServiceExtentionComparableWrapper > ();
            //List<ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2> serEXtList=new List<ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2>();
            for(ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 serExt:ser.serviceExtension){
                serEXtList.add(new ServiceExtentionComparableWrapper(serExt.Services_To,serExt.Services_From));
            }
            if(serEXtList!= null && serEXtList.size () > 0) {
                serEXtList.sort();
                //serEXtList.addAll(serEXtList);
            }
            
            system.debug('serEXtList**'+serEXtList);
            
            for(integer i=0; i<serEXtList.size() ; i++)
            {  
                JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();
                system.debug('@@i@@'+i);
                if(i+1<= serEXtList.size()-1 && Integer.valueOf(serEXtList[i+1].Services_FROM) - Integer.valueOf(serEXtList[i].Services_TO) == 2){
                    /*Integer index=0;
                    for(integer j=i+2; j<serEXtList.size(); j++){
                        system.debug('@@@Services_FROM@@@'+Integer.valueOf(serEXtList[j].Services_FROM));
                        system.debug('@@@Services_TO@@@'+Integer.valueOf(serEXtList[j-1].Services_TO));
                        if(j<= serEXtList.size()-1 && j-1>0 && Integer.valueOf(serEXtList[j].Services_FROM) - Integer.valueOf(serEXtList[j-1].Services_TO) == 1){
                            system.debug('inside for j');
                            index=j;                            
                        }else{
                            break;
                        }
                         
                    }
                    if(index==0){
                        gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[i+1].Services_To);
                    }else{
                        gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[index].Services_To);
                    }
                   i=index;*/
                   gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[i+1].Services_To);
                   i++;
                }
                else if(i+1<= serEXtList.size()-1 && Integer.valueOf(serEXtList[i+1].Services_FROM) - Integer.valueOf(serEXtList[i].Services_TO) == 1){
                   gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[i+1].Services_To);
                   i++;
                }
                else if(i+1<= serEXtList.size()-1 && (Integer.valueOf(serEXtList[i+1].Services_TO) - Integer.valueOf(serEXtList[i].Services_FROM) < 2 || Integer.valueOf(serEXtList[i+1].Services_TO) - Integer.valueOf(serEXtList[i].Services_FROM) >2 )){
                    gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[i].Services_To);
                    i++;   
                }   
                else{
                    gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[i].Services_To);  
                } 
                //gen2.writeStringField('action',system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s=gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(s);
                String serializedresult=JSON.serialize(results);
                system.debug('@@'+serializedresult);
                sList1.add(serializedresult);
            }
             
        }
        system.debug(sList1);
        String serializedresult21=System.JSON.serializePretty(sList1);
        system.debug('@@'+serializedresult21);
        String finalNumbers = serializedresult21.replace('\\"', '\'');
        system.debug('@@'+finalNumbers);
        gen.writeStringField('Numbers',finalNumbers);
        gen.writeEndObject();
        gen.writeEndObject();          
        return gen;
         
    }
     //generate service specification ngUC EDGE-101066
    private static JSONGenerator createNGUCLegacyServiceSpec(CS_SpecificationDTO.serviceSpecification spec,csord__Service__c serv,JSONGenerator gen, String guid,List<TransitionDataDTO.serviceDTOMobile> service,String adborId,String transitionId)        
    {
        //EDGE-154518 - Adding variables to define string literal
        String PRIME_SERVICE_ASSOCIATION_ROLE = 'prime';
        String AUXILIARY_SERVICE_ASSOCIATION_ROLE = 'auxiliary';
        //EDGE-156658 - Added gdn Association Role
        String GDN_SERVICE_ASSOCIATION_ROLE = 'gdn';
        spec.ServiceId = serv.Id;
        gen.writeStartObject();
        spec.code = System.Label.LegacyVoiceSpecCode;
        //spec.code='DMCAT_ProductSpecification_000343_Fulfilment';
        spec.version = '1';
        spec.status = System.Label.LegacySpecStatus;
        spec.startDate = String.valueOf(Date.today());
        spec.name = System.Label.LegacySpecName;
        spec.instanceId = guid;
        spec.guid = guid;
        gen.writeStringField('code',spec.code);
        gen.writeStringField('version',spec.version);
        gen.writeStringField('status',spec.status);
        gen.writeStringField('startDate',spec.startDate);
        gen.writeStringField('name',spec.name);
        gen.writeStringField('instanceId',spec.instanceId);
        gen.writeStringField('guid',spec.guid);
        List<CS_SpecificationDTO.SimpleAttributes> saList = new List<CS_SpecificationDTO.SimpleAttributes>();
        CS_SpecificationDTO.SimpleAttributes sa1 = new CS_SpecificationDTO.SimpleAttributes();  
        sa1.name = System.Label.LegacyProductType;
        sa1.value = serv.Offer_Type__c;
        saList.add(sa1);
        //EDGE-149573 - Commented as not required to pass to O2A
        /*CS_SpecificationDTO.SimpleAttributes sa2 = new CS_SpecificationDTO.SimpleAttributes();
        sa2.name = System.Label.UCInstanceId;//'UCSiteProductInstanceID';
        sa2.value = System.Label.UCSiteProductInstanceID_Value;//'DMCAT_ProductSpecification_000322_Fulfilment';
        saList.add(sa2);*/
        CS_SpecificationDTO.SimpleAttributes sa3 = new CS_SpecificationDTO.SimpleAttributes();
        sa3.name =System.Label.LegacyTargetSystem;
        sa3.value =System.Label.LegacyTargetSystemValue; //'FULFILMENT';
        saList.add(sa3);
        //EDGE-149573 - Commented as not required to pass to O2A
        /*CS_SpecificationDTO.SimpleAttributes sa4 = new CS_SpecificationDTO.SimpleAttributes();
        sa4.name = System.label.BSServiceTypeProductInstanceID;
        sa4.value = System.label.BSServiceTypeProductInstanceValue;//'DMCAT_ProductSpecification_000312_Fulfilment';
        saList.add(sa4);*/
        //EDGE-149573 - Added to pass to O2A
        CS_SpecificationDTO.SimpleAttributes sa4 = new CS_SpecificationDTO.SimpleAttributes();
        sa4.name = System.label.NextGenerationVoiceProductInstanceID;
        sa4.value = System.label.NextGenerationVoiceProductInstanceValue;//'DMCAT_ProductSpecification_000871_Fulfilment';
        saList.add(sa4);
        CS_SpecificationDTO.SimpleAttributes sa5 = new CS_SpecificationDTO.SimpleAttributes();
        //EDGE-152029 - Update name
        sa5.name = 'transitionId';
        sa5.value =transitionId;
        saList.add(sa5);
        CS_SpecificationDTO.SimpleAttributes sa6 = new CS_SpecificationDTO.SimpleAttributes();
        sa6.name = 'ADBOR ID';
        sa6.value =adborId;
        saList.add(sa6);
        spec.simpleAttributes = new List<CS_SpecificationDTO.simpleAttributes>();
        spec.simpleAttributes.addAll(saList);
        gen.writeFieldName('attributes');
        gen.writeStartObject();
        if(spec.simpleAttributes != null){
        for(CS_SpecificationDTO.SimpleAttributes saa:spec.simpleAttributes)
        {
         gen.writeStringField(saa.name,saa.value);
        }
       }
        //****PrimaryFNN Json*****
         
        //gen.writeFieldName(System.Label.PrimaryFNN);
        //gen.writeStartArray(); 
        List<String> sList=new List<String>();
        for(TransitionDataDTO.serviceDTOMobile  ser : service)
        { 
          //EDGE-154518 - Updated hard coded value from Primary to Prime   
            if((ser.service_association_role=='' || ser.service_association_role==null || ser.service_association_role==PRIME_SERVICE_ASSOCIATION_ROLE))
            {
              JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();
                gen2.writeStringField('Number',ser.Service_Id);
                gen2.writeStringField('action',system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s=gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(s);
                String serializedresult=JSON.serialize(results);
                system.debug('@@'+serializedresult);
                sList.add(serializedresult);
            }
        }
        system.debug(sList);
        String serializedresult2=System.JSON.serializePretty(sList);
        system.debug('@@'+serializedresult2);
        gen.writeStringField(System.Label.PrimaryFNN,serializedresult2.replace('\\"', '\''));
        //NumberJson
        //gen.writeFieldName('Numbers');
        List<String> sList1=new List<String>();
        for(TransitionDataDTO.serviceDTOMobile  ser : service)
        {      
            //EDGE-154518 - Updated hard coded value and added more condition to send Prime number from DisconnectFNN to Numbers block
            //EDGE-156658 - Added gdn Association Role
            if(ser.service_association_role==AUXILIARY_SERVICE_ASSOCIATION_ROLE || ser.service_association_role=='' || ser.service_association_role==null || ser.service_association_role==PRIME_SERVICE_ASSOCIATION_ROLE || ser.service_association_role==GDN_SERVICE_ASSOCIATION_ROLE)
            {
              JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();
                gen2.writeStringField('Number',ser.Service_Id);
                gen2.writeStringField('action',system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s=gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(s);
                String serializedresult=JSON.serialize(results);
                system.debug('@@'+serializedresult);
                sList1.add(serializedresult);
            }
            List<ServiceExtentionComparableWrapper> serEXtList = new List<ServiceExtentionComparableWrapper > ();
            //List<ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2> serEXtList=new List<ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2>();
            for(TransitionDataDTO.serviceExtensionDTO serExt:ser.serviceExtensions){
                serEXtList.add(new ServiceExtentionComparableWrapper(serExt.serviceExtensionTo,serExt.serviceExtensionFrom));
            }
            if(serEXtList!= null && serEXtList.size () > 0) {
                serEXtList.sort();
                //serEXtList.addAll(serEXtList);
            }
            
            system.debug('serEXtList**'+serEXtList);
            
            for(integer i=0; i<serEXtList.size() ; i++)
            {  
                JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();
                system.debug('@@i@@'+i);
                if(i+1<= serEXtList.size()-1 && Integer.valueOf(serEXtList[i+1].Services_FROM) - Integer.valueOf(serEXtList[i].Services_TO) == 2){
                   
                   gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[i+1].Services_To);
                   i++;
                }
                else if(i+1<= serEXtList.size()-1 && Integer.valueOf(serEXtList[i+1].Services_FROM) - Integer.valueOf(serEXtList[i].Services_TO) == 1){
                   gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[i+1].Services_To);
                   i++;
                }
                else if(i+1<= serEXtList.size()-1 && (Integer.valueOf(serEXtList[i+1].Services_TO) - Integer.valueOf(serEXtList[i].Services_FROM) < 2 || Integer.valueOf(serEXtList[i+1].Services_TO) - Integer.valueOf(serEXtList[i].Services_FROM) >2 )){
                    gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[i].Services_To);
                    i++;   
                }   
                else{
                    gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[i].Services_To);  
                } 
                gen2.writeStringField('action',system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s=gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(s);
                String serializedresult=JSON.serialize(results);
                system.debug('@@'+serializedresult);
                sList1.add(serializedresult);
            }
             
        }
        system.debug(sList1);
        String serializedresult21=System.JSON.serializePretty(sList1);
        system.debug('@@'+serializedresult21);
        String finalNumbers = serializedresult21.replace('\\"', '\'');
        system.debug('@@'+finalNumbers);
        gen.writeStringField('Numbers',finalNumbers);
        gen.writeEndObject();
        gen.writeEndObject();          
        return gen;
         
    }
    /*//Generate PrimaryFNN
    private static JSONGenerator generatePrimaryFNNAttribute(List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> service){
        //create legacy service for each service in Replicator
        //system.debug('**Adbor_id**'+site.ADBOR_ID);
        JSONGenerator gen1 = JSON.createGenerator(true);                           
        gen1.writeStartObject();
        gen1.writeFieldName(System.Label.PrimaryFNN);
        gen1.writeStartArray();
         
        for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2  ser : service)
        {  
             
            if(ser.Association_Role=='' || ser.Association_Role==null || ser.Association_Role=='Primary')
            {  
                gen1.writeStartObject();
                gen1.writeStringField('Number',ser.Service_Id);
                gen1.writeStringField('action',system.label.PrimaryFNNAction);
                gen1.writeEndObject();
            }
             
        }
        gen1.writeEndArray();
        gen1.writeEndObject();
        system.debug(gen1.getAsString());      
        return gen1;
    }*/
    //generate GUID
    private static string generateGuid()
    {
        //generate GUID
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
         
        return guid;
    }
    
    //Comparing the association roles coming from the service with roles stored in custom labels
    public Static boolean compareAssociationRoles(List<String> associationRoleList, String serAssociationRole){
        boolean assocRoleFlag = false;
        for(String assocRole :associationRoleList){
            if(assocRole.trim().equalsIgnoreCase(serAssociationRole.trim())){
            assocRoleFlag = true;
            break;
        }
    }
        return assocRoleFlag;
    } 
}