/*===========================================================
Prajakta   04/11/2020     EDGE-174930
==============================================================*/
public class CS_SpecificationDTO {
    public static final String billingSpec = 'BILLING';
    public static final String fulfilmentSpec = 'FULFILMENT';
  
      public class OrderSpecifications {
          public String subscriptionName;
          public List<SubscriptionSpecifications> subscriptionSpecificationList;
          public String orderId;
      }
      
      public class SubscriptionSpecifications{
          public List<ServiceSpecification> serviceSpecificationList { get; set; }
          public String serviceName { get; set; }
          public String subscriptionId { get; set; }
      }
      
      public class ServiceSpecifications {
          //public List<Specification> specifications;
          public String serviceId;
      }
  
      public class ServiceSpecification {
          public String serviceId;
          public String version;
          public String status;
          public String startDate;
          public List<SimpleAttributes> simpleAttributes;
          public String replacedSpecification;
          public String productConfigurationId;
          public String name;
          public String instanceId;
          public List<MetadataAttributes> metadataAttributes; //EDGE-174930
          public String identifier;
          public String guid;
          public String endDate;
          public String description;
          public Map<String, List<ComplexAttributes>> complexAttributes;
          public String code;
          public List<SimpleAttributes> additionalAttributes;
          public String subscriptionId;
      }
     
     //EDGE-174930
      public class MetadataAttributes{ 
          public String value;
          public String name;
      }
      public class SimpleAttributes {
          public String value;
          public String name;
          public String tenancyId;
          public String adborId;
      }
  
      public class ComplexAttributes {
          public List<SimpleAttributes> simpleAttributes;
          public String productConfigurationId;
      }
      
  
      public static List<ServiceSpecification> parse(String json) {
          List<ServiceSpecification> srvSpecMap = new List<ServiceSpecification>();
          List<OrderSpecifications> orderSpecList = (List<OrderSpecifications>) System.JSON.deserialize(json, List<OrderSpecifications>.class);
          for(OrderSpecifications ordSpec : orderSpecList) {
              List<SubscriptionSpecifications> subSpecList = new List<SubscriptionSpecifications> (ordSpec.subscriptionSpecificationList);
              for(SubscriptionSpecifications subSpec : subSpecList) {
                  List<ServiceSpecification> srvSpecList = new List<ServiceSpecification>(subSpec.serviceSpecificationList);
                  for(ServiceSpecification serSpec : srvSpecList) {
                      serSpec.subscriptionId = subSpec.subscriptionId;
                  }
                  srvSpecMap.addAll(srvSpecList);
              }
          }
          return srvSpecMap;
      }
    
      public static List<ServiceSpecification> parse(String json,String targetSystem) {
          List<ServiceSpecification> srvSpecMap = new List<ServiceSpecification>();
          List<ServiceSpecification> updatedServiceSpecList = new List<ServiceSpecification>();
          List<OrderSpecifications> orderSpecList = (List<OrderSpecifications>) System.JSON.deserialize(json, List<OrderSpecifications>.class);
          for(OrderSpecifications ordSpec : orderSpecList) {
              List<SubscriptionSpecifications> subSpecList = new List<SubscriptionSpecifications> (ordSpec.subscriptionSpecificationList);
              for(SubscriptionSpecifications subSpec : subSpecList) {
                  List<ServiceSpecification> srvSpecList = new List<ServiceSpecification>(subSpec.serviceSpecificationList);
                   updatedServiceSpecList = parseSpecs(srvSpecList,subSpec,targetSystem);
                   srvSpecMap.addAll(updatedServiceSpecList);
              }
          }
          system.debug('srvSpecMap::' + srvSpecMap);
          return srvSpecMap;
      }
      
      public static List<ServiceSpecification> parseSpecs(List<ServiceSpecification> srvSpecList,SubscriptionSpecifications subSpec,String targetSystem){
          List<ServiceSpecification> updatedServiceSpecList = new List<ServiceSpecification>();
          for(ServiceSpecification serSpec : srvSpecList) {
              serSpec.subscriptionId = subSpec.subscriptionId;
              if(serSpec.simpleAttributes!=null){
              for(SimpleAttributes simpleAttr : serSpec.simpleAttributes){
                  if(simpleAttr.name.contains('__targetSystem') && simpleAttr.value.equals(targetSystem)) {
          updatedServiceSpecList.add(serSpec);
              }
           }
          }
          }
          system.debug('updatedServiceSpecList::' + updatedServiceSpecList);
          return updatedServiceSpecList;
      }  
    
        public static List<ServiceSpecification> parseSubscriptionSpec(String json) {
          List<ServiceSpecification> srvSpecList = new List<ServiceSpecification>();
          List<SubscriptionSpecifications> subscriptionSpecList = (List<SubscriptionSpecifications>) System.JSON.deserialize(json, List<SubscriptionSpecifications>.class);
          System.debug('SubscriptionSpecList : '+ subscriptionSpecList);
          for(SubscriptionSpecifications subSpec : subscriptionSpecList) {
              //Added code to include all multiple service specs under a subscription- EDGE-16700
                   if(srvSpecList!=null)
                  {
                      srvSpecList.addAll(new List<ServiceSpecification>(subSpec.serviceSpecificationList));
                  }
                  else
                  {
                    srvSpecList = new List<ServiceSpecification>(subSpec.serviceSpecificationList);  
                  } 
                  for(ServiceSpecification serSpec : srvSpecList) {
                      serSpec.subscriptionId = subSpec.subscriptionId;
                  }                
          }
          return srvSpecList;
      }
      
     public static List<ServiceSpecification> parseSubscriptionSpec(String json, String targetSystem){
         List<ServiceSpecification> srvSpecList = new List<ServiceSpecification>();
         List<SubscriptionSpecifications> subscriptionSpecList = (List<SubscriptionSpecifications>) System.JSON.deserialize(json, List<SubscriptionSpecifications>.class); 
        for(SubscriptionSpecifications subSpec : subscriptionSpecList) {
                 if(subSpec != null){
             for(ServiceSpecification srvSpec : subSpec.serviceSpecificationList) {
                  for(SimpleAttributes attr : srvSpec.simpleAttributes) {
                      if('__targetSystem'.equals(attr.name) && attr.value.equals(targetSystem)) {
                          srvSpecList.add(srvSpec);
                      } 
                  } 
              } 
          }
         }
           return srvSpecList; 
     }
      
      public static List<ServiceSpecification> parseServiceSpec(String json) {
          List<ServiceSpecification> selectedServiceSpecifications = new List<ServiceSpecification>();
          List<ServiceSpecification> serviceSpecsList = (List<ServiceSpecification>) System.JSON.deserialize(json, List<ServiceSpecification>.class);
          return serviceSpecsList;
      }
  
      /**
      * @description 
      * @author Rohit Pal | 10-14-2021 
      * @param setServiceIds 
      * @param orderId 
      * @return List<ServiceSpecification> 
      **/
      public static List<ServiceSpecification> parseServiceSpec(set<id> setServiceIds , id orderId) {
          System.debug('setServiceIds --> ' + setServiceIds + 'orderId  ---> ' + orderId);
          List<Technical_Child_Attribute__c> listTechnicalChildAttribute = new List<Technical_Child_Attribute__c>();
          listTechnicalChildAttribute = Coms_PlatformCacheUtil.getTechnicalChildAttributes(orderId,setServiceIds);
          System.debug('listTechnicalChildAttribute --> ' + listTechnicalChildAttribute);
          List<CS_SpecificationDTO.ServiceSpecification> returnSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
          //Map<String, TechnicalObjectFieldMapping__mdt> mapTechnicalObjectFieldMapping = TechnicalObjectFieldMapping__mdt.getAll();
          Map<Id , Orchestration_Technical__c> mapOrchestrationTechnical = new Map<id , Orchestration_Technical__c>();
          Map<Id , List<Technical_Child_Attribute__c>> mapTechnicalChildAttributeSimple = new Map<Id , List<Technical_Child_Attribute__c>>();
          Map<Id , List<Technical_Child_Attribute__c>> mapTechnicalChildAttributeComplex =  new Map<Id , List<Technical_Child_Attribute__c>>();
          Map<Id , List<Technical_Child_Attribute__c>> mapTechnicalChildAttributeAdditional =  new Map<Id , List<Technical_Child_Attribute__c>>();
          Map<Id , csord__Service__c> mapOrchestrationTechnicalService =  new Map<Id , csord__Service__c>();
          List<Technical_Child_Attribute__c> listTechnicalChildAttributeNew;
          //
          for(Technical_Child_Attribute__c itertaor :listTechnicalChildAttribute){
              if(!mapOrchestrationTechnicalService.containsKey(itertaor.Orchestration_Technical__c)){
                  mapOrchestrationTechnicalService.put(itertaor.Orchestration_Technical__c , itertaor.Orchestration_Technical__r.Service__r);
              }
              if(!mapOrchestrationTechnical.containskey(itertaor.Orchestration_Technical__c)){
                  mapOrchestrationTechnical.put(itertaor.Orchestration_Technical__c , itertaor.Orchestration_Technical__r);
              }
              if(!mapTechnicalChildAttributeSimple.containskey(itertaor.Orchestration_Technical__c) && itertaor.Category__c == 'Simple Attributes'){
                  mapTechnicalChildAttributeSimple.put(itertaor.Orchestration_Technical__c , new list<Technical_Child_Attribute__c>{itertaor});
              }else if(mapTechnicalChildAttributeSimple.containskey(itertaor.Orchestration_Technical__c) && itertaor.Category__c == 'Simple Attributes'){
                  listTechnicalChildAttributeNew = new List<Technical_Child_Attribute__c>();
                  listTechnicalChildAttributeNew = mapTechnicalChildAttributeSimple.get(itertaor.Orchestration_Technical__c);
                  listTechnicalChildAttributeNew.add(itertaor);
                  mapTechnicalChildAttributeSimple.put(itertaor.Orchestration_Technical__c ,listTechnicalChildAttributeNew);
              }
              if(!mapTechnicalChildAttributeComplex.containskey(itertaor.Orchestration_Technical__c) && itertaor.Category__c == 'Complex Attributes'){
                  mapTechnicalChildAttributeComplex.put(itertaor.Orchestration_Technical__c , new list<Technical_Child_Attribute__c>{itertaor});
              }else if(mapTechnicalChildAttributeComplex.containskey(itertaor.Orchestration_Technical__c) && itertaor.Category__c == 'Complex Attributes'){
                  listTechnicalChildAttributeNew = new List<Technical_Child_Attribute__c>();
                  listTechnicalChildAttributeNew = mapTechnicalChildAttributeComplex.get(itertaor.Orchestration_Technical__c);
                  listTechnicalChildAttributeNew.add(itertaor);
                  mapTechnicalChildAttributeComplex.put(itertaor.Orchestration_Technical__c ,listTechnicalChildAttributeNew);
              }
              if(!mapTechnicalChildAttributeAdditional.containskey(itertaor.Orchestration_Technical__c) && itertaor.Category__c == 'Additional Attributes'){
                  mapTechnicalChildAttributeAdditional.put(itertaor.Orchestration_Technical__c , new list<Technical_Child_Attribute__c>{itertaor});
              }else if(mapTechnicalChildAttributeAdditional.containskey(itertaor.Orchestration_Technical__c) && itertaor.Category__c == 'Additional Attributes'){
                  listTechnicalChildAttributeNew = new List<Technical_Child_Attribute__c>();
                  listTechnicalChildAttributeNew = mapTechnicalChildAttributeAdditional.get(itertaor.Orchestration_Technical__c);
                  listTechnicalChildAttributeNew.add(itertaor);
                  mapTechnicalChildAttributeAdditional.put(itertaor.Orchestration_Technical__c ,listTechnicalChildAttributeNew);
              }
          }
          System.debug('mapOrchestrationTechnical --> ' + mapOrchestrationTechnical);
          System.debug('mapTechnicalChildAttributeSimple --> ' + mapTechnicalChildAttributeSimple);
          System.debug('mapOrchestrationTechnicalService --> ' + mapOrchestrationTechnicalService);
          for(Id iteratorId : mapTechnicalChildAttributeSimple.keyset()) {
              CS_SpecificationDTO.ServiceSpecification spec = new CS_SpecificationDTO.ServiceSpecification();
              CS_SpecificationDTO.ComplexAttributes objComplexAttribute;
              CS_SpecificationDTO.SimpleAttributes objSimpleAttribute;
              List<CS_SpecificationDTO.SimpleAttributes> listSimpleAttribute;
              List<CS_SpecificationDTO.ComplexAttributes> listComplexAttribute;
              Map<string , List<CS_SpecificationDTO.ComplexAttributes>> finalComplexAttributeMap;
              if(setServiceIds.contains(mapOrchestrationTechnical.get(iteratorId).Service__c)) {              
                  spec.serviceId = mapOrchestrationTechnical.get(iteratorId).Service__c;
                  spec.version = mapOrchestrationTechnical.get(iteratorId).Field_1__c;
                  //spec.version = record.isSet(version) ? (String) record.get(version) : null;                
                  spec.status = mapOrchestrationTechnical.get(iteratorId).Field_3__c;                
                  spec.startDate = mapOrchestrationTechnical.get(iteratorId).Field_4__c;
                  // spec.replacedSpecification = record.isSet(replacedSpecification) ? (String) record.get(replacedSpecification) : null;
                  spec.productConfigurationId = mapOrchestrationTechnical.get(iteratorId).Field_6__c;
                  spec.name = mapOrchestrationTechnical.get(iteratorId).Field_7__c;                
                  spec.instanceId = mapOrchestrationTechnical.get(iteratorId).Field_8__c;
                  spec.identifier = mapOrchestrationTechnical.get(iteratorId).Field_10__c;
                  spec.guid = mapOrchestrationTechnical.get(iteratorId).Field_9__c;
                  spec.endDate = mapOrchestrationTechnical.get(iteratorId).Field_10__c;
                  spec.description = mapOrchestrationTechnical.get(iteratorId).Field_11__c;
                  spec.code = mapOrchestrationTechnical.get(iteratorId).Field_12__c;
                  spec.subscriptionId = mapOrchestrationTechnical.get(iteratorId).Field_2__c;
                  System.debug('spec ---> ' + spec);
                  //Simple attributes
                  if(!mapTechnicalChildAttributeSimple.isEmpty()){
                      List<Technical_Child_Attribute__c> listTechnicalChildAttributesSimple= mapTechnicalChildAttributeSimple.get(iteratorId);
                      //System.debug('listTechnicalChildAttributesSimple ---> ' + listTechnicalChildAttributesSimple);
                      listSimpleAttribute = new List<CS_SpecificationDTO.SimpleAttributes>();
                      for(Technical_Child_Attribute__c childAttribute : listTechnicalChildAttributesSimple){
                          System.debug('listTechnicalChildAttributesSimple childAttribute ---> ' + childAttribute);
                          objSimpleAttribute = new CS_SpecificationDTO.SimpleAttributes();
                          objSimpleAttribute.name = childAttribute.Complex_Attribute_Schema_Id__c;
                          objSimpleAttribute.value = childAttribute.Field_1__c;
                          listSimpleAttribute.add(objSimpleAttribute);
                      }
                      //Map<String,List<TransientDataDTO.TransientAttribute>> transientAttributes = new Map<String,List<TransientDataDTO.TransientAttribute>>();
                      //TransientDataDTO dtoTransient = new TransientDataDTO();
                      //System.debug('mapcsordService '+mapcsordService .get('a4e2N0000005QVk'));
                      if(!mapOrchestrationTechnicalService.isEmpty() && mapOrchestrationTechnicalService.get(iteratorId).OrderTransientDataDetails__c != null){
                          for(TransientDataDTO.DataDTO dtoIter : TransientDataDTO.parseDataDTO(mapOrchestrationTechnicalService.get(iteratorId).OrderTransientDataDetails__c)){
                              for(TransientDataDTO.TransientAttribute objTransientAttribute : dtoIter.attributes){
                                  objSimpleAttribute = new CS_SpecificationDTO.SimpleAttributes();
                                  objSimpleAttribute.name = objTransientAttribute.name;
                                  objSimpleAttribute.value = objTransientAttribute.value;
                                  listSimpleAttribute.add(objSimpleAttribute);
                              }
                          }
                      }
                      spec.simpleAttributes =listSimpleAttribute;
                  }
                  //Additional Attributes
                  if(!mapTechnicalChildAttributeAdditional.isEmpty()){
                      List<Technical_Child_Attribute__c> listTechnicalChildAttributesAdditional= mapTechnicalChildAttributeAdditional.containsKey(iteratorId) ? mapTechnicalChildAttributeAdditional.get(iteratorId) : null;
                      //System.debug('listTechnicalChildAttributesSimple ---> ' + listTechnicalChildAttributesSimple);
                      listSimpleAttribute = new List<CS_SpecificationDTO.SimpleAttributes>();
                      for(Technical_Child_Attribute__c childAttribute : listTechnicalChildAttributesAdditional){
                          System.debug('listTechnicalChildAttributesAdditional childAttribute ---> ' + childAttribute);
                          objSimpleAttribute = new CS_SpecificationDTO.SimpleAttributes();
                          objSimpleAttribute.name = childAttribute.Complex_Attribute_Schema_Id__c;
                          objSimpleAttribute.value = childAttribute.Field_1__c;
                          listSimpleAttribute.add(objSimpleAttribute);
                      }
                      spec.additionalAttributes =listSimpleAttribute;
                  }
                  //complex attributes
                  if(!mapTechnicalChildAttributeComplex.isEmpty()){
                      listComplexAttribute =new List<CS_SpecificationDTO.ComplexAttributes>();
                  List<Technical_Child_Attribute__c> listTechnicalChildAttributes= mapTechnicalChildAttributeComplex.get(iteratorId);
                  for(Technical_Child_Attribute__c childAttribute : listTechnicalChildAttributes){
                      objComplexAttribute = new CS_SpecificationDTO.ComplexAttributes();
                      for(Technical_Child_Attribute__c childAttribute1 : listTechnicalChildAttributes){
                          objSimpleAttribute = new CS_SpecificationDTO.SimpleAttributes();
                          objSimpleAttribute.value =childAttribute1.Field_1__c;
                          objSimpleAttribute.name=childAttribute1.Field_2__c;
                          objSimpleAttribute.tenancyId=childAttribute1.Field_3__c;
                          objSimpleAttribute.adborId=childAttribute1.Field_4__c;
                          //objSimpleAttribute.listCode=childAttribute1.Field_5__c;
                          listSimpleAttribute = new List<CS_SpecificationDTO.SimpleAttributes>();
                          listSimpleAttribute.add(objSimpleAttribute);
                          objComplexAttribute.simpleAttributes = listSimpleAttribute;
                          objComplexAttribute.productConfigurationId =childAttribute.Complex_Attribute_Schema_Id__c.substringAfter('-');
                          listComplexAttribute.add(objComplexAttribute);
                          break;
                      }
                      finalComplexAttributeMap = new Map<string , List<CS_SpecificationDTO.ComplexAttributes>>();
                      finalComplexAttributeMap.put('Number' , listComplexAttribute);
                  }
                  spec.complexAttributes = finalComplexAttributeMap;
                  }
              }
              string strJson = JSON.serialize(spec);
              System.debug('strJson ---> ' + strJson);
              returnSpecList.add(spec);
          } 
          return returnSpecList;
      }
  
      public static List<ServiceSpecification> parseServiceSpec(String jsonStr,String targetSystem) {
          List<ServiceSpecification> selectedServiceSpecifications = new List<ServiceSpecification>();
          List<ServiceSpecification> serviceSpecsList = new List<ServiceSpecification>();
          if(jsonStr!=null){
          serviceSpecsList = (List<ServiceSpecification>) System.JSON.deserialize(jsonStr, List<ServiceSpecification>.class);
          }
          for(ServiceSpecification srvSpec : serviceSpecsList) {
              for(SimpleAttributes simpleAttr : srvSpec.simpleAttributes) {
                  if(simpleAttr.name.contains('__targetSystem') && simpleAttr.value.equals(targetSystem)) {
              selectedServiceSpecifications.add(srvSpec);
                     }
              }
          }
          return selectedServiceSpecifications;
      }
  
      
                      
      /*********************************************************************************************************************************
       * Method Name      :   parseServiceSpec(String,String,List<String>)
       *return            :   List<ServiceSpecification> selectedServiceSpecifications
       *Story             :   EDGE-71655
      **********************************************************************************************************************************/
      public static List<ServiceSpecification> parseServiceSpec(String jsonStr,String targetSystem, List<String> specCodeList) {
          List<ServiceSpecification> selectedServiceSpecifications = new List<ServiceSpecification>();
          List<ServiceSpecification> serviceSpecsList = new List<ServiceSpecification>();
          if(jsonStr!=null){
              serviceSpecsList = (List<ServiceSpecification>) System.JSON.deserialize(jsonStr, List<ServiceSpecification>.class);
          }
          for(ServiceSpecification srvSpec : serviceSpecsList) {
              if(specCodeList.contains(srvSpec.code)){
                  for(SimpleAttributes simpleAttr : srvSpec.simpleAttributes) {
                      if(simpleAttr.name.contains('__targetSystem') && simpleAttr.value.equals(targetSystem)) {
                          selectedServiceSpecifications.add(srvSpec);
                          System.debug('selectedServiceSpecifications==>'+selectedServiceSpecifications);
                      }
                      System.debug('selectedServiceSpecifications after==>'+selectedServiceSpecifications);
                  }
              }
          }
          return selectedServiceSpecifications;
      }
  
      
  }