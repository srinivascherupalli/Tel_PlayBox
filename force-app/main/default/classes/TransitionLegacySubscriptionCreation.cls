public with sharing class TransitionLegacySubscriptionCreation {

//accepts Service DTO and creates legacy subscriptions and services 
public static Map<String,String> createLegacySubscriptionAndServices(ReplicatorGetServiceDataObject serviceDTO){
    String CIDN = serviceDTO.CIDN; 
    Set<String> adborSet = new Set<String>();
    List<ReplicatorGetServiceDataObject.SiteDTO> siteDTO = serviceDTO.Site;
    List<csord__Subscription__c> legacySubscriptionList = new List<csord__Subscription__c>();
    List<csord__Service__c> legacyServiceList = new List<csord__Service__c>();
    List<ReplicatorGetServiceDataObject.ServiceDTO> serviceList = new List<ReplicatorGetServiceDataObject.ServiceDTO>();
    Map<String,List<ReplicatorGetServiceDataObject.ServiceDTO>> serviceSiteMap = new Map<String,List<ReplicatorGetServiceDataObject.ServiceDTO>>();
    Map<String,ReplicatorGetServiceDataObject.ServiceDTO> serviceAndServiceDTOMap = new Map<String,ReplicatorGetServiceDataObject.ServiceDTO>();
    Map<String,String> nameValueMap = new Map<String,String>();
    for(ReplicatorGetServiceDataObject.SiteDTO site: siteDTO)   
    {
        //gets all the ADBOR Ids
        adborSet.add(site.ADBOR_Id);
        
        for(ReplicatorGetServiceDataObject.ProductDTO pd: site.productList)   
        {
            List<ReplicatorGetServiceDataObject.ServiceDTO> serTempList = new List<ReplicatorGetServiceDataObject.ServiceDTO>();
            serTempList.addAll(pd.service);
            if(serviceSiteMap!=null && serviceSiteMap.get(site.ADBOR_Id)!=null)
            {
                serTempList.addAll(serviceSiteMap.get(site.ADBOR_Id));
                
            }
            //map of Site ADBOR Id and servicelist 
            serviceSiteMap.put(site.ADBOR_Id,serTempList);
            serviceList.addAll(pd.service);
        }
    }

    //Query the site based on Account CIDN and ADBOR Id as address Id.
    List<cscrm__Site__c> siteList = new List<cscrm__Site__c>([SELECT Id, Name,cscrm__Installation_Address__r.cscrm__Address_Details__c,address_id__c 
                                                              FROM cscrm__Site__c 
                                                              WHERE cscrm__Account__r.CIDN__C=:CIDN and address_id__c in: adborSet]);

    Map<String,Id> siteAddressMap = new Map<String,Id>();
    Map<String,Id> siteSubscriptionMap = new Map<String,Id>();
    for(cscrm__Site__c site : siteList)
    {
        //map with ADBOR Id and site Id
        siteAddressMap.put(site.address_id__c,site.id);
    }
    for(ReplicatorGetServiceDataObject.SiteDTO site: siteDTO)   
    {
        //create legacy subscription for each site
        csord__Subscription__c sub = new csord__Subscription__c();
        if(siteAddressMap!=null && siteAddressMap.containsKey(site.ADBOR_Id))
        {
            sub.Name = 'Legacy Subscription ISDN_BRA';
            sub.Site__c = siteAddressMap.get(site.ADBOR_Id);
            sub.csord__Identification__c = site.ADBOR_Id;
            sub.csord__Status__c = 'Disconnect Pending';
        }    
        legacySubscriptionList.add(sub);          
    }  

    if(legacySubscriptionList !=null && legacySubscriptionList.size()>0)
    {
        insert legacySubscriptionList;
        for(csord__Subscription__c sub:legacySubscriptionList)
        {
            siteSubscriptionMap.put(sub.csord__Identification__c,sub.id);
        }
        for(ReplicatorGetServiceDataObject.SiteDTO site: siteDTO)   
        {
            //create legacy service for each service in Replicator
            for(ReplicatorGetServiceDataObject.ServiceDTO ser: serviceSiteMap.get(site.ADBOR_ID))   
            {
                csord__Service__c service= new csord__Service__c();
                service.Name = 'Legacy Service ISDN_BRA';
                service.Primary_FNN__c = ser.Service_Id;
                service.Offer_Type__c = 'ISDN-BRA';
                service.csord__Subscription__c = siteSubscriptionMap.get(site.ADBOR_ID);
                service.csord__Identification__c = 'Service_'+site.ADBOR_ID;
                service.csord__Status__c = 'Disconnect Pending';
                legacyServiceList.add(service);
                serviceAndServiceDTOMap.put(ser.Service_Id,ser);
            }
            
        }  
        
    }  

    if(legacyServiceList != null && legacyServiceList.size()>0)
    {
        insert legacyServiceList;
        List<Attachment> attachList = new List<Attachment>();
        JSONGenerator serviceSpecJSON;
        JSONGenerator serviceSpecFNNJSON;
        //Create Legacy Voice Specifications and Legacy Voice FNN Specifications for each service
        List<CS_SpecificationDTO.serviceSpecification> specificationList = new List<CS_SpecificationDTO.serviceSpecification>();
        for(csord__Service__c  serv : legacyServiceList)
        {   
            CS_SpecificationDTO.serviceSpecification spec = new CS_SpecificationDTO.serviceSpecification();
            JSONGenerator gen = JSON.createGenerator(true); 
            gen.writeStartObject();
            gen.writeStringField('serviceId',serv.Id);
            gen.writeFieldName('specifications');
            gen.writeStartArray();
            String guid = generateGuid();
            serviceSpecJSON = createLegacyServiceSpec(spec,serv,gen,guid);
            if(serviceAndServiceDTOMap.get(serv.Primary_FNN__c).serviceRelationship !=null)
            {
                for(ReplicatorGetServiceDataObject.serviceRelationshipDTO rel: serviceAndServiceDTOMap.get(serv.Primary_FNN__c).serviceRelationship)
                {  
                   List<ReplicatorGetServiceDataObject.serviceExtensionDTO> extList =rel.serviceExtension;  
                   if(extList !=null)
                   {
                     
                        for(integer i=0; i<extList.size() ; i++)
                        {
                            CS_SpecificationDTO.serviceSpecification spec1 = new CS_SpecificationDTO.serviceSpecification();
                            if(i+1<= extList.size()-1 && Integer.valueOf(extList[i+1].Services_FROM) - Integer.valueOf(extList[i].Services_TO) == 2)
                           {
                               nameValueMap.put(serv.Primary_FNN__c+'-'+i,extList[i].Services_FROM+'-'+extList[i+1].Services_TO);
                               serviceSpecFNNJSON = createLegacyFNNServiceSpec(spec1,serv,extList[i].Services_FROM,extList[i+1].Services_TO,gen,guid,nameValueMap,i);
                               i++;
                           }
                        else if(i+1<= extList.size()-1 && (Integer.valueOf(extList[i+1].Services_TO) - Integer.valueOf(extList[i].Services_FROM) < 2 || Integer.valueOf(extList[i+1].Services_TO) - Integer.valueOf(extList[i].Services_FROM) >2))
                        {
                            nameValueMap.put(serv.Primary_FNN__c+'-'+i,extList[i].Services_FROM+'-'+extList[i].Services_TO);
                            serviceSpecFNNJSON = createLegacyFNNServiceSpec(spec1,serv,extList[i].Services_FROM,extList[i].Services_TO,gen,guid,nameValueMap,i);
                            i++;   
                        }   
                        else
                        {
                            nameValueMap.put(serv.Primary_FNN__c+'-'+i,extList[i].Services_FROM+'-'+extList[i].Services_TO);
                            serviceSpecFNNJSON = createLegacyFNNServiceSpec(spec1,serv,extList[i].Services_FROM,extList[i].Services_TO,gen,guid,nameValueMap,i);
                            i++;   
                        }   
                        }
                      }     
                    }
                  } 
            gen.writeEndArray();
            gen.writeEndObject();
                String serializedBody = gen.getAsString();
                System.debug('****serializedBody'+ serializedBody);
                Blob body = Blob.valueOf(serializedBody);
                Attachment att = new Attachment();
                att.Name =  'ServiceSpecifications.json';
                att.ParentId = serv.Id;
                att.Body = body;
                attachList.add(att);
                }
            
            insert attachList;
         }          
        return namevalueMap;
    }
    public static Map<String,String> createLegacySubscriptionAndServices_V2(ReplicatorGetServiceDataObject_V2 serviceDTO){
        String CIDN = serviceDTO.CIDN; 
        Set<String> adborSet = new Set<String>();
        List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2> siteDTO = serviceDTO.Site;
        List<csord__Subscription__c> legacySubscriptionList = new List<csord__Subscription__c>();
        List<csord__Service__c> legacyServiceList = new List<csord__Service__c>();
        List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2  > serviceList = new List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();
        Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2  >> serviceSiteMap = new Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2  >>();
        Map<String,ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 > serviceAndServiceDTOMap = new Map<String,ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >();
        Map<String,String> nameValueMap = new Map<String,String>();
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site: siteDTO)   
        {
            //gets all the ADBOR Ids
            adborSet.add(site.ADBOR_Id);
            
            for(ReplicatorGetServiceDataObject_V2.productListDTO pd: site.productList)   
            {
                for(ReplicatorGetServiceDataObject_V2.serviceListDTO serv:pd.serviceList ){
                    List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> serTempList = new List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >();
                    serTempList.addAll(serv.service);
                    if(serviceSiteMap!=null && serviceSiteMap.get(site.ADBOR_Id)!=null)
                    {
                        serTempList.addAll(serviceSiteMap.get(site.ADBOR_Id));
                        
                    }
                    //map of Site ADBOR Id and servicelist 
                    serviceSiteMap.put(site.ADBOR_Id,serTempList);
                    serviceList.addAll(serv.service);
                    
                }
                
            }
        }

        //Query the site based on Account CIDN and ADBOR Id as address Id.
        List<cscrm__Site__c> siteList = new List<cscrm__Site__c>([SELECT Id, Name,cscrm__Installation_Address__r.cscrm__Address_Details__c,address_id__c 
                                                                  FROM cscrm__Site__c 
                                                                  WHERE cscrm__Account__r.CIDN__C=:CIDN and address_id__c in: adborSet]);

        Map<String,Id> siteAddressMap = new Map<String,Id>();
        Map<String,Id> siteSubscriptionMap = new Map<String,Id>();
        for(cscrm__Site__c site : siteList)
        {
            //map with ADBOR Id and site Id
            siteAddressMap.put(site.address_id__c,site.id);
        }
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site: siteDTO)   
        {
            //create legacy subscription for each site
            csord__Subscription__c sub = new csord__Subscription__c();
            if(siteAddressMap!=null && siteAddressMap.containsKey(site.ADBOR_Id))
            {
                sub.Name = 'Legacy Subscription ISDN_BRA';
                sub.Site__c = siteAddressMap.get(site.ADBOR_Id);
                sub.csord__Identification__c = site.ADBOR_Id;
                sub.csord__Status__c = 'Disconnect Pending';
            }    
            legacySubscriptionList.add(sub);          
        }  

        if(legacySubscriptionList !=null && legacySubscriptionList.size()>0)
        {
            insert legacySubscriptionList;
            for(csord__Subscription__c sub:legacySubscriptionList)
            {
                siteSubscriptionMap.put(sub.csord__Identification__c,sub.id);
            }
            for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site: siteDTO)   
            {
                //create legacy service for each service in Replicator
                for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2  ser: serviceSiteMap.get(site.ADBOR_ID))   
                {
                    csord__Service__c service= new csord__Service__c();
                    service.Name = 'Legacy Service ISDN_BRA';
                    service.Primary_FNN__c = ser.Service_Id;
                    service.Offer_Type__c = 'ISDN-BRA';
                    service.csord__Subscription__c = siteSubscriptionMap.get(site.ADBOR_ID);
                    service.csord__Identification__c = 'Service_'+site.ADBOR_ID;
                    service.csord__Status__c = 'Disconnect Pending';
                    legacyServiceList.add(service);
                    serviceAndServiceDTOMap.put(ser.Service_Id,ser);
                }
                
            }  
            
        }  

        if(legacyServiceList != null && legacyServiceList.size()>0)
        {
            insert legacyServiceList;
            List<Attachment> attachList = new List<Attachment>();
            JSONGenerator serviceSpecJSON;
            JSONGenerator serviceSpecFNNJSON;
            //Create Legacy Voice Specifications and Legacy Voice FNN Specifications for each service
            List<CS_SpecificationDTO.serviceSpecification> specificationList = new List<CS_SpecificationDTO.serviceSpecification>();
            for(csord__Service__c  serv : legacyServiceList)
            {   
                CS_SpecificationDTO.serviceSpecification spec = new CS_SpecificationDTO.serviceSpecification();
                JSONGenerator gen = JSON.createGenerator(true); 
                gen.writeStartObject();
                gen.writeStringField('serviceId',serv.Id);
                gen.writeFieldName('specifications');
                gen.writeStartArray();
                String guid = generateGuid();
                serviceSpecJSON = createLegacyServiceSpec(spec,serv,gen,guid);
                if(serviceAndServiceDTOMap.get(serv.Primary_FNN__c).serviceExtension  !=null)
                { 
                   List<ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2> extList =serviceAndServiceDTOMap.get(serv.Primary_FNN__c).serviceExtension;   
                   if(extList !=null)
                   {
                     
                        for(integer i=0; i<extList.size() ; i++)
                        {
                            CS_SpecificationDTO.serviceSpecification spec1 = new CS_SpecificationDTO.serviceSpecification();
                            if(i+1<= extList.size()-1 && Integer.valueOf(extList[i+1].Services_FROM) - Integer.valueOf(extList[i].Services_TO) == 2)
                           {
                               nameValueMap.put(serv.Primary_FNN__c+'-'+i,extList[i].Services_FROM+'-'+extList[i+1].Services_TO);
                               serviceSpecFNNJSON = createLegacyFNNServiceSpec(spec1,serv,extList[i].Services_FROM,extList[i+1].Services_TO,gen,guid,nameValueMap,i);
                               i++;
                           }
                        else if(i+1<= extList.size()-1 && (Integer.valueOf(extList[i+1].Services_TO) - Integer.valueOf(extList[i].Services_FROM) < 2 || Integer.valueOf(extList[i+1].Services_TO) - Integer.valueOf(extList[i].Services_FROM) >2))
                        {
                            nameValueMap.put(serv.Primary_FNN__c+'-'+i,extList[i].Services_FROM+'-'+extList[i].Services_TO);
                            serviceSpecFNNJSON = createLegacyFNNServiceSpec(spec1,serv,extList[i].Services_FROM,extList[i].Services_TO,gen,guid,nameValueMap,i);
                            i++;   
                        }   
                        else
                        {
                            nameValueMap.put(serv.Primary_FNN__c+'-'+i,extList[i].Services_FROM+'-'+extList[i].Services_TO);
                            serviceSpecFNNJSON = createLegacyFNNServiceSpec(spec1,serv,extList[i].Services_FROM,extList[i].Services_TO,gen,guid,nameValueMap,i);
                            i++;   
                        }   
                        }
                    }     
                } 
                gen.writeEndArray();
                gen.writeEndObject();
                    String serializedBody = gen.getAsString();
                    System.debug('****serializedBody'+ serializedBody);
                    Blob body = Blob.valueOf(serializedBody);
                    Attachment att = new Attachment();
                    att.Name =  'ServiceSpecifications.json';
                    att.ParentId = serv.Id;
                    att.Body = body;
                    attachList.add(att);
            }
                
            insert attachList;
        }           
        return namevalueMap;
    }

private static JSONGenerator createLegacyServiceSpec(CS_SpecificationDTO.serviceSpecification spec,csord__Service__c serv,JSONGenerator gen, String guid)         
{
    spec.ServiceId = serv.Id;
    gen.writeStartObject();
    spec.code = System.Label.LegacyVoiceSpecCode;
    spec.version = '1';
    spec.status = 'Disconnect Pending';
    spec.startDate = String.valueOf(Date.today());
    spec.name = 'LegacyVoice';
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
    CS_SpecificationDTO.SimpleAttributes sa = new CS_SpecificationDTO.SimpleAttributes();
    sa.name = 'PrimaryFNN';
    sa.value = serv.Primary_FNN__c;
    saList.add(sa);
    CS_SpecificationDTO.SimpleAttributes sa1 = new CS_SpecificationDTO.SimpleAttributes();   
    sa1.name = 'ServiceType';
    sa1.value = serv.Offer_Type__c;
    saList.add(sa1);
    CS_SpecificationDTO.SimpleAttributes sa2 = new CS_SpecificationDTO.SimpleAttributes();
    sa2.name = System.Label.UCInstanceId;
    sa2.value = 'PS_000104_Fulfilment';
    saList.add(sa2);
    CS_SpecificationDTO.SimpleAttributes sa3 = new CS_SpecificationDTO.SimpleAttributes();
    sa3.name = '__targetSystem';
    sa3.value = 'FULFILMENT';
    saList.add(sa3);
    spec.simpleAttributes = new List<CS_SpecificationDTO.simpleAttributes>();
    spec.simpleAttributes.addAll(saList);
    gen.writeFieldName('attributes');
    gen.writeStartObject();
    for(CS_SpecificationDTO.SimpleAttributes saa:spec.simpleAttributes)
    {
     gen.writeStringField(saa.name,saa.value);    
    }
    gen.writeEndObject();
    gen.writeEndObject();
       
    return gen;
    
}      
private static JSONGenerator createLegacyFNNServiceSpec(CS_SpecificationDTO.serviceSpecification spec,csord__Service__c serv, String ServiceFrom, String ServiceTo, JSONGenerator gen,String parentguid, Map<String,String> nameValueMap, Integer i)         
{
    spec.ServiceId = serv.Id;
    gen.writeStartObject();
    spec.code = System.Label.LegacyVoiceFNNSpecCode;
    spec.version = '1';
    spec.status = 'Disconnect Pending';
    spec.startDate = String.valueOf(Date.today());
    spec.name = 'LegacyVoiceFNN';    
    String guid = generateGuid();
    spec.guid = guid;
    spec.instanceId = guid;
    gen.writeStringField('code',spec.code);
    gen.writeStringField('version',spec.version);
    gen.writeStringField('status',spec.status);
    gen.writeStringField('startDate',spec.startDate);
    gen.writeStringField('name',spec.name);
    gen.writeStringField('instanceId',spec.instanceId);
    gen.writeStringField('guid',spec.guid);
    gen.writeFieldName('attributes');
    gen.writeStartObject();
    List<CS_SpecificationDTO.SimpleAttributes> saList = new List<CS_SpecificationDTO.SimpleAttributes>();
    CS_SpecificationDTO.SimpleAttributes sa = new CS_SpecificationDTO.SimpleAttributes();
    sa.name = 'From';
    sa.value = serviceFrom;
    saList.add(sa);
    CS_SpecificationDTO.SimpleAttributes sa1 = new CS_SpecificationDTO.SimpleAttributes();   
    sa1.name = 'To';
    sa1.value = serviceTo;
    saList.add(sa1);
    CS_SpecificationDTO.SimpleAttributes sa2 = new CS_SpecificationDTO.SimpleAttributes();   
    sa2.name = 'parentSpec';
    sa2.value = parentguid;
    saList.add(sa2);
    CS_SpecificationDTO.SimpleAttributes sa3 = new CS_SpecificationDTO.SimpleAttributes();
    sa3.name = '__targetSystem';
    sa3.value = 'FULFILMENT';
    saList.add(sa3);
    spec.simpleAttributes = new List<CS_SpecificationDTO.simpleAttributes>();
    spec.simpleAttributes.addAll(saList);
    //nameValueMap.put(serv.Primary_FNN__c+'parentSpec'+parentguid);
    for(CS_SpecificationDTO.SimpleAttributes saa:spec.simpleAttributes)
    {
     gen.writeStringField(saa.name,saa.value);    
    }
    String s = nameValueMap.get(serv.Primary_FNN__c+'-'+i);
    s = s + '-'+parentguid;
    nameValueMap.put(serv.Primary_FNN__c+'-'+i,s);
    gen.writeEndObject();
    gen.writeEndObject();
       
    return gen;      
}      
private static string generateGuid()
{
    //generate GUID
    Blob b = Crypto.GenerateAESKey(128);
    String h = EncodingUtil.ConvertTohex(b);
    String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    
    return guid;
}
}