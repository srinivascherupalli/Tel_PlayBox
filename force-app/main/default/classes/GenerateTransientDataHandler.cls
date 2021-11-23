/********************************************************
Class Name      :   GenerateTransientDataHandler
Test Class : GenerateTransientDataHandlerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Vanita Mude             -          EDGE-71655
2.            Abinash               -           EDGE-80870
3.            Shreya Jaiswal        24/12/19        EDGE-125552
4.            Manish Jha            02/01/20    Transient Fix
5.            Vaibhav               30/03/2020   EDGE-142395 fix
******************************************************************************************************************/
global with sharing class GenerateTransientDataHandler implements CSPOFA.ExecutionHandler{
    public List<SObject> process(List<SObject> steps){
        List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
        Set<Id> orchesIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        for(CSPOFA__Orchestration_Step__c step: stepList)
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        system.debug(orchesIds);
        List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Service__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
        System.debug('orchList ::'+orchList);
        for(CSPOFA__Orchestration_Process__c  orch : orchList){
            orderIds.add(orch.Order__c);
        }
            prepareTransientDataForOrder(new List<Id>(orderIds));
        for(CSPOFA__Orchestration_Step__c step : stepList){
            step.CSPOFA__Status__c = Label.Complete;
            step.CSPOFA__Completed_Date__c = Date.today();
            step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
            result.add(step);
        }
        system.debug('result='+result);
        return result;
    }
    //@future
    public static void prepareTransientDataForOrder(List<Id> orderID){
        TransientDataDTO dto = new TransientDataDTO();
        Set<String> servSet = new Set<String>();
        List<csord__Order__c> ordList = [Select id,isTransientComplete__c,scenario_type__c from csord__Order__c where id =: orderID];
        for(csord__Order__c ord : ordList){
            ord.isTransientComplete__c = true;
        }
         update ordList;
        List<csord__Service__c> serviceIDList = [Select id,csord__Order__c from csord__Service__c where csord__Order__c =: orderID];
        system.debug('serviceIDList==>'+serviceIDList);
        for(csord__Service__c serv : serviceIDList){
            servSet.add(serv.id);
        }
       //Zeeshan 
        List<csord__service__c> serviceList = [select id,name,Replaced_Device_Id__c,csord__Status__c ,csord__Order__c from csord__service__c where csord__Order__c IN :ordList];
        Set<Id> servIdSet = new Set<Id>();
        Map<String,csord__service__c> replacingServiceMap = new Map<String,csord__service__c>();
           for(csord__service__c serv : serviceList){
                if(serv.Replaced_Device_Id__c != '' && serv.csord__Status__c == Constants.Service_Status){
                    replacingServiceMap.put(serv.id,serv);
                }
                servIdSet.add(serv.id);
            }
            List<CS_SpecificationDTO.ServiceSpecification> allReqdSrvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            Map<Id, Attachment> attmAP = new Map<Id, Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: servIdSet and name = 'ServiceSpecifications.json']);
        for(csord__Order__c order : ordList){
            system.debug('Scenario >>>>' + order.scenario_type__c);
            if(order.scenario_type__c ==label.Device_Replacement){
                //EDGE-80870
                poulateTransientForScenarioType(order);
            }else{
                getAllRequiredServiceSpecMappings(order.Id,dto,servSet);
            }
        }
    }
    /*********************************************************************************************************************************
* Method Name      :   getAllRequiredServiceSpecMappings
*Return            :   Returns Map<String,String>
**********************************************************************************************************************************/
    public static Map<String,String> getAllRequiredServiceSpecMappings(Id orderID,TransientDataDTO transientData,Set<String> serviceIDSet){
        List<CS_SpecificationDTO.ServiceSpecification> allReqdSrvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        Map<String,String> guidFinalStringMap = new Map<String,String>();
        try{
            Map<String,String> offerServiceToAttachmentMap = ServiceSpecificationUtils.getServiceSpecWithOfferFromOrderId(orderID,new CS_TransientMetadataHelper().getOfferListForNonAssetableProducts());
            List<String> specCodeForTransientList = new CS_TransientMetadataHelper().getSpecCodeListForNonAssetableProducts();
            for(String servOfferId : offerServiceToAttachmentMap.keyset()){
                serviceIDSet.add(servOfferId.split('::')[0]);
                allReqdSrvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(offerServiceToAttachmentMap.get(servOfferId)),'FULFILMENT',specCodeForTransientList));
            }
            //Commenting as DeviceReplacement specific code has been put in separate method
            System.debug('serviceIDSet==>'+serviceIDSet+'allReqdSrvSpecList==>'+allReqdSrvSpecList);
            Map<String,String> servIdOfferIdMap = new Map<String,String>();
      //EDGE-125552
      Map<String,String> servIdscenarioMap = new Map<String,String>();
            //Remove the soql below and populate the map in above for loop
            for(csord__Service__c serv : [Select Id,Scenario_Type__c,name,csordtelcoa__Service_Number__c,csord__Subscription__c,csord__Subscription__r.MarketableOffer__r.Offer_ID__c,csord__Order__r.csord__Status__c,csord__Status__c from csord__Service__c where id IN : serviceIDSet]){
                servIdOfferIdMap.put(serv.id,serv.csord__Subscription__r.MarketableOffer__r.Offer_ID__c);
        //EDGE-125552
        servIdscenarioMap.put(serv.id,serv.Scenario_Type__c);
                //System.debug('servIdOfferIdMap==>'+servIdOfferIdMap);
            }
            System.debug('servIdOfferIdMap==>'+servIdOfferIdMap);
            Map<String,List<String>> specCodeChangeTypeMap = new CS_TransientMetadataHelper().getSpecCodeChangeTypeForNonAssetableProducts();
            System.debug('specCodeChangeTypeMap===>'+specCodeChangeTypeMap);
            Map<String,CS_SpecificationDTO.ServiceSpecification> guidFinalMap2 = new Map<String,CS_SpecificationDTO.ServiceSpecification>();
            List<TransientDataDTO.DataDTO> transDataDTOList = new List<TransientDataDTO.DataDTO>();
            for(CS_SpecificationDTO.ServiceSpecification specs: allReqdSrvSpecList){
                if(servIdOfferIdMap.get(specs.serviceId) != null){
                    TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO(); 
                    //Commenting as DeviceReplacement specific code has been put in separate method
                    /*
                    if(serviceId!=null && specs.serviceId == serviceId) {
                         TransientDataDTO.TransientAttribute deviceId = new TransientDataDTO.TransientAttribute();                             
                            deviceId.name = 'DeviceId'; 
                            if(replacedAsset != null){
                                deviceId.value = replacedAsset;
                            }
                            TransientDataDTO.TransientAttribute deviceType = new TransientDataDTO.TransientAttribute();                             
                            deviceType.name = 'DeviceType'; 
                            deviceType.value = null;
                            List<TransientDataDTO.TransientAttribute> listAttribute = new List<TransientDataDTO.TransientAttribute>();
                            listAttribute.add(deviceId);
                            listAttribute.add(deviceType);
                            dataDTO.attributes=listAttribute;
                    }
                    */
                    if(specCodeChangeTypeMap.keySet().contains(servIdOfferIdMap.get(specs.serviceId)+'::'+specs.code.remove('_Fulfilment'))){
                        List<String> changeTypeList = specCodeChangeTypeMap.get(servIdOfferIdMap.get(specs.serviceId)+'::'+specs.code.remove('_Fulfilment'));
                        system.debug('changeTypeList>>>>'+changeTypeList);
                        if(changeTypeList.contains('New') && specs.status == 'Created'){  
                            //TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO(); 
                            dataDTO.offerID = servIdOfferIdMap.get(specs.serviceId); 
                            dataDTO.specCode = specs.code; dataDTO.specGUID = specs.guid; 
                            dataDTO.changeType = 'New'; 
                            //transDataDTOList.add(dataDTO); 
                            guidFinalMap2.put(specs.guid,specs);
                            //EDGE-125552
                        }else if((changeTypeList.contains('Modify')||changeTypeList.contains(servIdscenarioMap.get(specs.serviceId))) && specs.status == 'Modified'){ 
                            //TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO();
                            dataDTO.offerID = servIdOfferIdMap.get(specs.serviceId); 
                            dataDTO.specCode = specs.code;  //remember this will have value ending with _Fulfilment
                            dataDTO.specGUID = specs.guid;
                            dataDTO.changeType = 'Modify';
                            //transDataDTOList.add(dataDTO);
                            guidFinalMap2.put(specs.guid,specs);
                        }
                        if(dataDTO!=null) {
                            transDataDTOList.add(dataDTO);
                        }
                    }
                }
                guidFinalStringMap.put(specs.guid,servIdOfferIdMap.get(specs.serviceId)+':'+specs.code+'::'+specs.status);
            }
            if(transDataDTOList!=null && transDataDTOList.size()>0){ transientData.dataDTOList = transDataDTOList;
            }
            System.debug('orderID=>'+orderID+'transientData==>'+transientData+'guidFinalMap2===>'+guidFinalMap2+'serviceIDSet==>'+serviceIDSet);
            populateTransientDTO(orderID,transientData,guidFinalMap2,serviceIDSet);
            return guidFinalStringMap; }catch(Exception e){ return guidFinalStringMap;
        }
    }
    /*********************************************************************************************************************************
* Method Name      :   populateTransientDTO
*Purpose           :   to get transient data 
**********************************************************************************************************************************/
    //@future
    public static void populateTransientDTO(Id orderID,TransientDataDTO transientData,Map<String,CS_SpecificationDTO.ServiceSpecification> guidFinalMap2,Set<String> serviceIDSet){
        try{
            List<TransientDataDTO.DataDTO> transDataDTOList = transientData.dataDTOList;
            List<Product_Attribute_Metadata__c> productMetadataList = new CS_TransientMetadataHelper().getAttributeReferenceForNonAssetableProducts();
            List<String> fieldAPINameList = new CS_TransientMetadataHelper().getTransientReferenceAPINameList();
            Set<String> uniqueProdMetaSet = new Set<String>();
            Map<Id,csord__Service__c> serviceIDTransientDataMap = new CS_TransientMetadataHelper().fetchTransientDataFromService(serviceIDSet,fieldAPINameList);
            System.debug('serviceIDTransientDataMap ===>'+serviceIDTransientDataMap );
            for(TransientDataDTO.DataDTO dataDTO : transDataDTOList){ 
                List<TransientDataDTO.TransientAttribute> transientAttrList = new List<TransientDataDTO.TransientAttribute>();
                Map<String,String> attributeNameValueMap = new Map<String,String>();
                //Transient fix : updated by Manish Jha
                String serviceID = '';
                if(dataDTO.specGUID != null && guidFinalMap2.get(dataDTO.specGUID)!= null ){
                    serviceID = guidFinalMap2.get(dataDTO.specGUID).serviceId;
                System.debug('serviceID ==>'+serviceID );
                    csord__Service__c serviceRecord = serviceIDTransientDataMap.get(serviceID);
                System.debug('productMetadataList==>'+productMetadataList);
                for(Product_Attribute_Metadata__c prodMetadata : productMetadataList){
                    if(prodMetadata.Offer_Id__c == dataDTO.offerID && prodMetadata.Product_ID__c == dataDTO.specCode.remove('_Fulfilment') && prodMetadata.Change_Type__c == dataDTO.changeType){
                        TransientDataDTO.TransientAttribute transientAttribute = new TransientDataDTO.TransientAttribute(); transientAttribute.name = prodMetadata.Attribute_Name__c; 
                        transientAttribute.value = String.valueOf(serviceRecord.get(prodMetadata.ReferenceField__c));
                        //Commenting as DeviceReplacement specific code has been put in separate method
                        /*
                        if(serviceRecord.Scenario_Type__c == Label.Device_Replacement ){
                            TransientDataDTO.TransientAttribute deviceReplacement = new TransientDataDTO.TransientAttribute(); 
                            deviceReplacement.name = 'Quantity'; 
                            deviceReplacement.value = '1';
                            transientAttrList.add(deviceReplacement);
                            TransientDataDTO.TransientAttribute deviceId = new TransientDataDTO.TransientAttribute(); 
                            deviceId.name = 'DeviceId'; 
                            deviceId.value = serviceRecord.Replaced_Device_Id__c;
                            transientAttrList.add(deviceId);
                        }
                        */
                        transientAttrList.add(transientAttribute);
                    }
                }
             } //added check as part of EDGE-142395
                if(transientAttrList!= null && transientAttrList.size()>0){
                    dataDTO.attributes = transientAttrList;    
                }
            }
            System.debug('transientData==>'+transientData);
            insertAttachmentOnOrder(orderId,transientData);
        }catch(Exception e){
            //handle exception here
        }
    }
    /*********************************************************************************************************************************
* User story#      :EDGE-100986
* Method Name      :   getReplacedAssetId
*Purpose           :   To fetch the old asset id from the new asset associated with the generated order.
* Modified by      :Zeeshan
**********************************************************************************************************************************/
       public static string getReplacedAssetId(Id orderId ){
     String oldAsset ;
        try{
             Asset checkorderid  =   [SELECT id,name , csordtelcoa__Replaced_Asset__r.AssetID__c,AssetID__c FROM Asset WHERE csordtelcoa__Replaced_Asset__c != null AND Subscription__c!=null and Subscription__r.csord__Order__c =:orderId AND status='InActive' AND (Subscription__r.csord__Status__c ='In progress' OR Subscription__r.csord__Status__c ='Pending')  AND Subscription__r.csord__Order__r.Scenario_Type__c='Device Replacement' LIMIT 1];
        //system.debug('---->checkorderid'+checkorderid);
        if(checkorderid !=null) {
           oldAsset = checkorderid.csordtelcoa__Replaced_Asset__r.AssetID__c;
        }
        system.debug('---->oldAsset'+oldAsset);
        }catch(Exception e){}
     return oldAsset;
    }
    /*********************************************************************************************************************************
* Method Name      :   insertAttachmentOnOrder
*Purpose           :   to insert TransientDataDetails.json on Order
**********************************************************************************************************************************/
    public static void insertAttachmentOnOrder(Id orderId, TransientDataDTO transientData){
        try{
            if(transientData!=null && transientData.dataDTOList != null){
                String jsonStr = TransientDataDTO.parse(transientData.dataDTOList);
                System.debug('jsonStr ===>'+jsonStr);
                Attachment att = new Attachment();
                att.Body = Blob.valueOf(String.valueOf(jsonStr));
                att.ParentId = orderId;
                att.name = 'TransientDataDetails.json';
                insert att;
            } }catch(Exception e){
            //exception
        }
    }
    //Zee
   /* public static void poulateTransientForScenarioType(csord__Order__c order){
        List<csord__service__c>serviceList = null;
         poulateTransientForScenarioType(csord__Order__c order, List<csord__service__c>serviceList,Map<Id, Attachment> attmAP);
    }*/
    //EDGE-80870 Start
    public static void poulateTransientForScenarioType(csord__Order__c order){
         EnvironmentVariable__c hvEnvironmentVariable = EnvironmentVariable__c.getInstance('EnableHV');
        if(order.scenario_type__c == Label.Device_Replacement && hvEnvironmentVariable.Value__c != 'True'){
            Map<String,csord__service__c> replacingServiceMap = new Map<String,csord__service__c>();
            Set<Id> servIdSet = new Set<Id>();
            for(csord__service__c serv : [select id,name,Replaced_Device_Id__c,csord__Status__c from csord__service__c where csord__Order__c = : order.Id]){
                if(serv.Replaced_Device_Id__c != '' && serv.csord__Status__c == Constants.Service_Status){
                    replacingServiceMap.put(serv.id,serv);
                }
                servIdSet.add(serv.id);
            }
            List<CS_SpecificationDTO.ServiceSpecification> allReqdSrvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            Map<Id, Attachment> attmAP = new Map<Id, Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: servIdSet and name = 'ServiceSpecifications.json']);
            Map<Id, Attachment> serviceIdToSpecAttachMap = new Map<Id, Attachment>();
            for(Attachment tempAttachment: attmAP.values()){
                serviceIdToSpecAttachMap.put(tempAttachment.parentId, tempAttachment);
            }
            Map<String,String> guidToServiceMap = new Map<String,String>();
            Map<String,String> guidToSpecCodeMap = new Map<String,String>();
            for(String servId : servIdSet){
                String serviceattachmentstr = serviceIdToSpecAttachMap.get(servId).body.toString();
                List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceattachmentstr));
                for(CS_SpecificationDTO.ServiceSpecification specification : srvSpecList){
                    string code = specification.code;
                    system.debug('code>>>>'+code + '>>>>>' + label.DMCAT_ProductSpecification_000263);
                    if(code == 'DMCAT_ProductSpecification_000423_Fulfilment' || code == 'DMCAT_ProductSpecification_000622_Fulfilment' || code == Label.Service_Specification_Code || code == Label.Service_Specification_Code_nguc || code == label.DMCAT_ProductSpecification_000263){
                        guidToServiceMap.put(specification.guid,specification.serviceId);                       
                    }
                    //EDG-100986 :Added NGUC and Device Outright offers in the if condition
                    if(code==label.DMCAT_ProductSpecification_000263  || code == label.DMCAT_ProductSpecification_000622_Fulfilment || code == label.DMCAT_ProductSpecification_000423_Fulfilment){
                        guidToSpecCodeMap.put(specification.guid,code);
                    }
                }
            }
            List<TransientDataDTO.DataDTO> transDataDTOList = new List<TransientDataDTO.DataDTO>();

            for(String guid : guidToServiceMap.keySet()){
                TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO(); 
                List<TransientDataDTO.TransientAttribute> transientAttrList = new List<TransientDataDTO.TransientAttribute>();
                dataDTO.specGUID = guid;

                /*system.debug('isShippingAddress++---->'+guidToSpecCodeMap.get(guid) +'=='+ label.DMCAT_ProductSpecification_000263);
                if(guidToSpecCodeMap.containsKey(guid) && guidToSpecCodeMap.get(guid) == label.DMCAT_ProductSpecification_000263){
                    system.debug('Inside Idf>>>>>>');
                    TransientDataDTO.TransientAttribute shippingrequired = new TransientDataDTO.TransientAttribute(); 
                    shippingrequired.name = 'ShippingRequired'; 
                    shippingrequired.value = 'FALSE'; 
                    transientAttrList.add(shippingrequired);
                }else */

                if( guidToSpecCodeMap.containsKey(guid) && (guidToSpecCodeMap.get(guid) == label.DMCAT_ProductSpecification_000622_Fulfilment || guidToSpecCodeMap.get(guid) == label.DMCAT_ProductSpecification_000423_Fulfilment)){
                 
				 //OSAKA Start of EDGE-100986 : Update Device ID with replacement id for NGUC and Device Outright  
                 system.debug('---->guidToSpecCodeMap.get(guid)<----'+guidToSpecCodeMap.get(guid));
                 	// Adding fix to mitigate HV order issue (hvEnvironmentVariable.Value__c != 'True')(Non osaka requirement) 
                 	// Start of EDGE-144537              
                    TransientDataDTO.TransientAttribute attributeDevice = new TransientDataDTO.TransientAttribute(); 
                    string getReplacedasset = getReplacedAssetId(Order.Id);
                    attributeDevice.name='DeviceID';
                    attributeDevice.value = getReplacedasset;       
                    transientAttrList.add(attributeDevice);

                    //As confirmed by Nirvana EDGE-144537
                    TransientDataDTO.TransientAttribute attributeQty = new TransientDataDTO.TransientAttribute(); 
                    attributeQty.name = 'Quantity'; 
                    attributeQty.value = '1'; 
                    transientAttrList.add(attributeQty); 
                 }
                    //OSAKA END of EDGE-100986

                /*if(replacingServiceMap.get(guidToServiceMap.get(guid))!=''){
                    TransientDataDTO.TransientAttribute deviceIdAttr = new TransientDataDTO.TransientAttribute(); 
                    deviceIdAttr.name = 'DeviceId'; 
                    deviceIdAttr.value = replacingServiceMap.get(guidToServiceMap.get(guid)).Replaced_Device_Id__c;
                    transientAttrList.add(deviceIdAttr);
                }*/
                if(transientAttrList!= null && transientAttrList.size()>0){
                    dataDTO.attributes = transientAttrList;    
                }
                transDataDTOList.add(dataDTO);
            }
            TransientDataDTO transientData = new TransientDataDTO();
            transientData.dataDTOList = transDataDTOList;
            if(transDataDTOList.size()>0){
                insertAttachmentOnOrder(order.Id,transientData);
            }
        }
    }
    //EDGE-80870 End
}