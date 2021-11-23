/**
* This class is to handle the POST API request for Custom wrapper API to support high volume orders.
* Developer: Vanita Mude
* Date: 10 June 2019
* Description: EDGE-86669 expose OrderSpecs via Custom wrapper API to support high volume orders
* Modified :Manjunath Ediga added OrderNum__c as a part of EDGE: 105942 for getting Order specification details with Order Number as input
Change.No.    Developer Name          Date          Story Description
1.            Vaibhav Deshpande     13/04/2020      EDGE-144219 fix
********************************************************************************************************/
public with sharing class GetOrderSpecAPIPostHandler {
     public class My2Exception extends Exception {} //added as part of EDGE-144219
    public String reqBody;
    public GetOrderSpecAPIPostHandler(){}
    public GetOrderSpecAPIPostHandler(String reqBody){
        this.reqBody=reqBody;
    }
    public static Map<String,List<CS_SpecificationDTO.ServiceSpecification>> getAllServSpecsFromService(Map<Id,csord__Service__c> srvcMap, String targetSystem){
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = new Map<String,List<CS_SpecificationDTO.ServiceSpecification>>();
        try{
            //List<Attachment> srvcAttachments = [SELECT Id, ParentId, Name, Body from Attachment WHERE Name = 'ServiceSpecifications.json' AND ParentId IN :srvcMap.keySet()];
            List<CS_SpecificationDTO.ServiceSpecification> allServSpecList =  new List<CS_SpecificationDTO.ServiceSpecification>();
            List<CS_SpecificationDTO.ServiceSpecification> fulServSpecList =  new List<CS_SpecificationDTO.ServiceSpecification>();
            List<CS_SpecificationDTO.ServiceSpecification> billServSpecList =  new List<CS_SpecificationDTO.ServiceSpecification>();
            List<CS_SpecificationDTO.ServiceSpecification> assuServSpecList =  new List<CS_SpecificationDTO.ServiceSpecification>();
            String updatedBody;
             //System.debug('transientAttributes.get(specs.guid)::'+transientAttributes);

            for(Attachment att : [SELECT Body from Attachment WHERE Name = 'ServiceSpecifications.json' AND ParentId IN :srvcMap.keySet()]){
                String specStr;
                if(targetSystem != 'FULFILMENT' ){
                   specStr = EDMConversionUtil.ConvertServiceEDMToSpec(att.Body.toString());
                }

                if(targetSystem == 'FULFILMENT'){
                    fulServSpecList.addAll(EDMConversionUtil.ConvertServiceEDMToSpecDTO(att.Body.toString(), 'FULFILMENT'));
                    srvSpecMap.put('FULFILMENT',fulServSpecList);
                } else if(targetSystem == 'BILLING'){
                    billServSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(specStr,'BILLING'));
                    srvSpecMap.put('BILLING',billServSpecList);
                }else if(targetSystem == 'ASSURANCE'){
                    assuServSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(specStr,'ASSURANCE'));
                    srvSpecMap.put('ASSURANCE',assuServSpecList);
                }else {
                    //Added as part of EDGE-229416 
                    allServSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(specStr));   
                    srvSpecMap.put('',allServSpecList); // replace ALL with blank
                } 
            }
            //System.debug('srvSpecMap===>'+srvSpecMap);
             if(Test.isRunningTest()){ 
                throw new My2Exception('My exception');
            }
            return srvSpecMap;
        }catch(Exception e){
            //handle excption  
            System.debug('exception'+e.getStackTraceString());
            return srvSpecMap;
        }
    }
    public String getOrderSpecs(String orderId,String targetSystem, String Order_Number)
    {
        String retVal = '';
        // String exceptionVal = 'Exception';
        try{
            //EDGE-217119 Added by Nikhil part of B2B 1260 Fixes
            List<csord__Order__c> order = [SELECT ID, Scenario_Type__c FROM csord__Order__c WHERE ID =: orderId]; 
            if(!order.isEmpty() && order[0].Scenario_Type__c == 'Manage Fixed Numbers'){
                return 'Manage Fixed Numbers';
            }
            //EDGE-217119 END
            //Start of EDGE: 105942  Added Order Number in the where clause 
            //Chnaged OrderNum to Order_Number which i failing at MS
            Map<Id, csord__Service__c> srvcMap = new Map<Id, csord__Service__c>();
            Boolean isNGUCConnected = false;
            // Modified by Nikhil as part of EDGE-222787
            for(csord__Service__c service : [SELECT Id, Name, csord__Subscription__c,csord__Subscription__r.ConfigSpecID__c, csord__Order__c,
                                            csord__Status__c,csord__Order__r.csord__Order_Number__c FROM csord__Service__c WHERE 
                                            ((csord__Order__c != '' AND csord__Order__c = :orderId) OR 
                                            (csord__Order__r.csord__Order_Number__c != '' AND csord__Order__r.csord__Order_Number__c = :Order_Number) 
                                            OR (csord__Order__r.csord__Primary_Order__c != '' AND csord__Order__r.csord__Primary_Order__c = :orderId))]){
                if(service.csord__Subscription__r?.ConfigSpecID__c == 'DMCAT_ProductSpecification_000871' && 
                   String.isNotBlank(service.csord__Status__c) && service.csord__Status__c.equalsIgnoreCase('Connected')){
                      isNGUCConnected = true;
                       continue;
                }else{
                    srvcMap.put(service.Id,service);
                }
            }
            Map<Id,Attachment> attachmentMap = new Map<Id,Attachment>([Select id,ParentId,Body  from Attachment where parentId = :orderId and Name = 'TransientDataDetails.json']);
            Map<Id,String> orderAttachmentMap = new Map<Id,String>();
            for(Attachment att : attachmentMap.values()){
                orderAttachmentMap.put(att.parentId,att.body.toString());
            }
            //End of EDGE: 105942
            //system.debug('srvcMap--->'+srvcMap);
            Map<String,List<TransientDataDTO.TransientAttribute>> transientAttributes = new Map<String,List<TransientDataDTO.TransientAttribute>>();
            TransientDataDTO dtoTransient = new TransientDataDTO();
            if(!orderAttachmentMap.isEmpty()){
            System.debug('orderAttachmentMap.get(orderId)::'+orderAttachmentMap.get(orderId));
            for(TransientDataDTO.DataDTO dtoIter : TransientDataDTO.parseDataDTO(orderAttachmentMap.get(orderId))){
                        if(!string.isEmpty(dtoIter.specGuid)){
                            transientAttributes.put(dtoIter.specGuid,dtoIter.attributes);
            }
            }
            }

            //System.debug('Attributes:::'+transientAttributes);

            Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = getAllServSpecsFromService(srvcMap, targetSystem);
            //system.debug('srvSpecMap=='+srvSpecMap);
            if(srvcMap.isEmpty() || srvSpecMap.isEmpty()){return isNGUCConnected ? 'Manage Fixed Numbers' : retVal;}
            if(srvcMap.values() != null){
                if(targetSystem == 'FULFILMENT'){
                    //System.debug('JSON.serializ FULFILMENT ===>'+JSON.serialize(srvSpecMap.get('FULFILMENT')));
                    Map<String,Map<String,String>> guidAttributesMap = new Map<String,Map<String,String>>();
                    
                   for(CS_SpecificationDTO.ServiceSpecification specs: srvSpecMap.get('FULFILMENT')){
                   Map<String,String> addAttributes = new Map<String,String>();
                   if(transientAttributes.containsKey(specs.guid)){
                    System.debug('transientAttributes.get(specs.guid)::'+transientAttributes.get(specs.guid));
                    List<CS_SpecificationDTO.SimpleAttributes> simpleAttrList = new List<CS_SpecificationDTO.SimpleAttributes >();
                    for(TransientDataDTO.TransientAttribute transAttr : transientAttributes.get(specs.guid)){
                        CS_SpecificationDTO.SimpleAttributes simpAtt = new CS_SpecificationDTO.SimpleAttributes();
                        simpAtt.name = transAttr.name; 
                        simpAtt.value = transAttr.value;
                        simpleAttrList.add(simpAtt); }
                         specs.SimpleAttributes.addAll(simpleAttrList);
                    }
                }
                    return '{"data":'+ JSON.serialize(srvSpecMap.get('FULFILMENT'))+'}';
                }else if(targetSystem == 'BILLING'){
                    System.debug('JSON.serializ BILLING ===>'+JSON.serialize(srvSpecMap.get('BILLING')));
                    return '{"data":'+JSON.serialize(srvSpecMap.get('BILLING'))+'}';
                }else if(targetSystem == 'ASSURANCE'){
                    System.debug('JSON.serializ BILLING ===>'+JSON.serialize(srvSpecMap.get('BILLING')));           
                    return '{"data":'+JSON.serialize(srvSpecMap.get('ASSURANCE'))+'}';
                }else                 
                    return '{"data":'+JSON.serialize(srvSpecMap.get(''))+'}';
            } else {
                return retVal; 
            }
        }
        catch(Exception e){
            return retVal;
        }
    }
}