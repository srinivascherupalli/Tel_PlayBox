/*********************************************************************************************************************************
 *Class Name      :   ServiceSpecificationUtils

Test Class : ServiceSpecificationUtilsTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Rohit  Tripathi       8/7/2019        EDGE-96853->Mobile devices are not sent in MO payload when we are triggering CWP mobility
2.            Rohit  Tripathi       18/7/2019       EDGE-88787->Enhancements to Conditional Decomposition of EDM(Removing Tactical Fix)

2.            Rohit  Tripathi       18/7/2019       EDGE-88787->Enhancements to Conditional Decomposition of EDM(Removing Tactical Fix)
3.            Laxmi Rahate          09/10/2019      EDGE-113351 Added condition to make shipping req flag false in case of Mobile device and device
4.            Sandip Deshmane       20/2/2020       EDGE-132208 - Added Number Removal Status to update Specs.
5.            Shubhi/Manish Jha     28/02/2020      INC000092992238 added for shipping required in additionalAttributes
6.            Ankit Goswami         07/09/2020       EDGE-165020/EDGE-168784 
 *********************************************************************************************************************************
*/

public with sharing class ServiceSpecificationUtils {
    
    /**************************************************************************************
****** Desc: Method updates all the service specs status attribute with a value
****** Service specifications are identified by instance id for a service
***************************************************************************************/
    
    
    public static void updatesServiceSpecsStatus(List<Id> serviceIds, String targetStatus){
        List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE parentId IN :serviceIds AND name = 'ServiceSpecifications.json'];
        List<Id> servicewithoutAtt = new List<Id>();
        atts = updatesServiceSpecsStatus(atts, 'status', targetStatus);
        update atts;
    }
    
    /**************************************************************************************
****** Desc: Method accepts list of service spec attachment objects and return
****** map of attachment id and DTO
***************************************************************************************/
    public static List<Attachment> updatesServiceSpecsStatus(List<Attachment> atts, String property, String propertyValue){
        if(!atts.isEmpty()){
            for(Attachment att: atts){
                String attbody = String.valueOf(att.body.toString());
                String udtattbody = updateSpecStatus(attbody, property, propertyValue);
                att.body = Blob.valueOf(udtattbody);
                System.debug('forLoopattbody::'+udtattbody);
            }
        }
        
        return atts;
    }
    
    /**************************************************************************************
****** Desc: Method accepts list of service spec attachment objects and return
****** map of attachment id and DTO
***************************************************************************************/
    public static String updateSpecStatus(String attbody, String property, String propertyValue){
        //if(String.isNotEmpty(attbody)){
        String updattBody = attbody;
        String statusVal = propertyValue;
        List<CS_AttributeSpecsDTO.ServiceSpecification> specs = CS_AttributeSpecsDTO.parseSpec(attbody, 'Fulfilment');
        for(CS_AttributeSpecsDTO.ServiceSpecification spec: specs){
            System.debug('spec.guid::'+spec.guid);
            System.debug('spec.status::'+spec.status);
            System.debug('propertyValue::'+propertyValue);
            if(property == 'status'){
                statusVal = getStatus(spec.status, propertyValue); 
                System.debug('statusVal:::'+statusVal);
                if(spec.status!=Label.MO_Status_Complete && spec.status!=Label.MO_status_cancel){
                    updattBody = csedm.API_1.updateServiceSpecificationProperty(updattBody, spec.guid, 'status', statusVal);
                }
            }
        }
        //}
        return updattBody;
    }
    
    /**************************************************************************************
****** Desc: Method adds all the characteristics as additional attribute
****** Service specifications are identified by instance id for a service
***************************************************************************************/
    public static void updatesServiceSpecsAttributes(List<Id> serviceIds, Map<String, ManageOrderNotificationUtil.Product> attributes){
        List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE parentId IN :serviceIds AND name = 'ServiceSpecifications.json'];
        List<Id> servicewithoutAtt = new List<Id>();
        atts = updatesServiceSpecsAttrbutes(atts, attributes);
        update atts;
        addServiceSpecsAttrbutes(atts, attributes);
        System.debug('atts::'+atts);
    }
    
    /**************************************************************************************
****** Desc: Method adds all the characteristics as additional attribute
****** Service specifications are identified by instance id for a service
***************************************************************************************/
    public static List<Attachment> updatesServiceSpecsAttrbutes(List<Attachment> atts,  Map<String, ManageOrderNotificationUtil.Product> attributes){
        for(Attachment att: atts){
            String attbody = String.valueOf(att.body.toString());
            String udtattbody = updateSpecProperties(attbody, attributes);
            att.body = Blob.valueOf(udtattbody);
            System.debug('forLoopattbody::'+udtattbody);
        }
        return atts;
    }
    
    /**************************************************************************************
****** Desc: Method adds all the characteristics as additional attribute
****** Service specifications are identified by instance id for a service
***************************************************************************************/
    public static void addServiceSpecsAttrbutes(List<Attachment> atts,  Map<String, ManageOrderNotificationUtil.Product> attributes){
        for(Attachment att: atts){
            String attbody = String.valueOf(att.body.toString());
            addSpecattributes(attbody, attributes);
        }
    }
    
    /**************************************************************************************
****** Desc: Method adds all the characteristics as additional attribute
****** Service specifications are identified by instance id for a service
***************************************************************************************/
    public static void addSpecattributes(String attbody, Map<String, ManageOrderNotificationUtil.Product> attributes){
        String updattBody = attbody;
        List<CS_AttributeSpecsDTO.ServiceSpecification> specs = CS_AttributeSpecsDTO.parseSpec(attbody);
        for(CS_AttributeSpecsDTO.ServiceSpecification spec: specs){
            System.debug('spec.guid::'+spec.guid);
            ManageOrderNotificationUtil.Product prodMilestones = attributes.get(spec.guid);
            if(prodMilestones != null ){
                List<ManageOrderNotificationUtil.NotificationAttributes> prodMilestonesAttr = prodMilestones.attributes;
                System.debug('prodMilestonesAttr:::'+prodMilestonesAttr);
                addNewAttributes(updattBody, spec, prodMilestonesAttr);
            }
        }
    }
    
    /**************************************************************************************
****** Desc: Method adds all the characteristics as additional attribute
****** Service specifications are identified by instance id for a service
***************************************************************************************/
    public static String updateSpecProperties(String attbody, Map<String, ManageOrderNotificationUtil.Product> attributes){
        String updattBody = attbody;
        List<CS_AttributeSpecsDTO.ServiceSpecification> specs = CS_AttributeSpecsDTO.parseSpec(attbody);
        Map<String, String> specAttributes = (Map<String, String>) JSON.deserialize(Label.MO_Spec_Attributes, Map<String, String>.class);
        for(CS_AttributeSpecsDTO.ServiceSpecification spec: specs){
            System.debug('spec.guid::'+spec.guid);
            ManageOrderNotificationUtil.Product prodMilestones = attributes.get(spec.guid);
            if(prodMilestones != null ){
                List<ManageOrderNotificationUtil.NotificationAttributes> prodMilestonesAttr = prodMilestones.attributes;
                if(specAttributes.keySet().contains('status')){
                    ManageOrderNotificationUtil.NotificationAttributes statusAttr = new ManageOrderNotificationUtil.NotificationAttributes();
                    statusAttr.name = 'status'; statusAttr.value = prodMilestones.status;
                    prodMilestonesAttr.add(statusAttr);
                }
                System.debug('prodMilestonesAttr:::'+prodMilestonesAttr);
                updattBody = updateProperties(updattBody, spec, prodMilestonesAttr);
            }
        }
        return updattBody;
    }
    
    //method to update properties
    //input specid, map of string, string
    //updattBody = csedm.API_1.updateServiceSpecificationProperty(updattBody, spec.guid, 'startDate', attr.value);
    public static string updateProperties(String attbody, CS_AttributeSpecsDTO.ServiceSpecification spec, List<ManageOrderNotificationUtil.NotificationAttributes> prodMilestonesAttr){
        String updattBody = attbody;
        Map<String, String> specAttributes = (Map<String, String>) JSON.deserialize(Label.MO_Spec_Attributes, Map<String, String>.class);
        for(ManageOrderNotificationUtil.NotificationAttributes attr: prodMilestonesAttr){
            System.debug('sttr.name:::'+attr.name);
            System.debug('sttr.value:::'+attr.value);
            if(specAttributes.get(attr.name) != null){
                String attrName = specAttributes.get(attr.name);
                String attrValue = attr.value;
                if(attrName.contains('status')){
                    attrValue = getStatus(spec.status, attrValue);
                }
                updattBody = csedm.API_1.updateServiceSpecificationProperty(updattBody, spec.guid, attrName, attrValue);
            }
        }
        return updattBody;
    }
    
    //method to add additional attributes
    //input specid, map of string, string
    public static void addNewAttributes(String attBody, CS_AttributeSpecsDTO.ServiceSpecification spec, List<ManageOrderNotificationUtil.NotificationAttributes> prodMilestonesAttr){
        
        Map<String, String> additionalAttrs = new Map<String, String>();
        Map<String, String> specAttributes = (Map<String, String>) JSON.deserialize(Label.MO_Spec_Attributes, Map<String, String>.class);
        for(ManageOrderNotificationUtil.NotificationAttributes attr: prodMilestonesAttr){
            System.debug('sttr.name:::'+attr.name);
            System.debug('sttr.value:::'+attr.value);
            if(!specAttributes.keySet().contains(attr.name)){
                additionalAttrs.put(attr.name, attr.value);
            }
        }
        
        System.debug('additionalAttrs:::'+additionalAttrs);
        if(!additionalAttrs.isEmpty()) {
            System.debug('IF:spec.serviceId, spec.guid::'+spec.serviceId + ' --- '+spec.guid);
            csedm.API_1.addCharacteristic(spec.serviceId, spec.guid, additionalAttrs);
        }
    }
    
    //returns transition status following service spec status trainsitions
    public static String getStatus(String previousstatus, String updatestatus){
        String targetStatus = updatestatus;
        if(targetStatus.contains('In Progress')){
            if(previousstatus.contains(Label.MO_status_disconnect_pending))
                targetStatus = Label.MO_status_disconnect_in_progress;
            else if(previousstatus.contains(Label.MO_status_cancel_pending))
                targetStatus = Label.MO_status_cancel_in_progress;
            else 
                targetStatus = Label.MO_status_in_progress;
        }
        
        return targetStatus;
        
    }
    
    public static void updateUCNumberSpecNumberStatus(List<String> serviceIdList){
        try{
            Map<Id, Attachment> attsMapToUpdate = new Map<Id, Attachment>();
            
            Map<Id, Attachment> attmAP = new Map<Id, Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN :serviceIdList and name = 'ServiceSpecifications.json']);
            FOR(Id attId : attmAP.keyset()  ){
                String serviceattachmentstr = attmAP.get(attId).body.toString();
                //system.debug('serviceattachmentstr'+serviceattachmentstr);
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
                //system.debug('results'+results);
                List<Object> lstSpecifications = (List<Object>)results.get('specifications');
                //system.debug(lstSpecifications[0]);
                
                for (Object specification : lstSpecifications) {               
                    // now get attributes for this specification.               
                    Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                    Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('attributes');
                    Map<String,Object> tempAttributesMap = new Map<String,Object> ();
                    for(String atrributeattName: attributesMap.keyset()){
                        //system.debug('Attribute Name '+atrributeattName);
                        //system.debug('Attribute Value '+attributesMap.get(atrributeattName));
                        string tempValue = null;
                        if(atrributeattName!=null && atrributeattName.equalsIgnoreCase('Number')){
                            tempValue = JSON.serialize(attributesMap.get(atrributeattName));
                        }
                        if(tempValue!=null){
                            //EDGE-132208 - Added Number Removal Status.
                            tempAttributesMap.put(atrributeattName,(List<NumberServSpecDTO>)JSON.deserialize(tempValue.replace('RESERVED','ACTIVE').replace('IN TRANSITION','ACTIVE').replace('DISCONNECT PENDING','DISCONNECT IN PROGRESS').replace('DISCONNECT IN PROGRESS','DISCONNECTED').replace('DISCONNECTED','INACTIVE'), List<NumberServSpecDTO>.class));
                        }
                    }
                    if(tempAttributesMap.size()>0){
                        attributesMap.putAll(tempAttributesMap);
                    }
                }
                serviceattachmentstr = JSON.serializePretty(results);
                String str = serviceattachmentstr;
                attmAP.get(attId).body = blob.valueOf(str);
                attsMapToUpdate.put(attId, attmAP.get(attId));
            }
            if (attsMapToUpdate.size() > 0){
                update attsMapToUpdate.values();        
            }
        }catch(Exception e){
            system.debug('Exception in updateUCNumberSpecNumberStatus '+ e);
        }
    }
    
    public static String addAdditionalAttributeNoSOQL(String serviceattachmentstr, String guidToUpdate, Map<String,String> additionalAttrs){
        try{
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
            system.debug('results'+results);
            List<Object> lstSpecifications = (List<Object>)results.get('specifications');
            system.debug(lstSpecifications[0]);
             Map<String, Object> specificationAttributes = new Map<String, Object>();
            for (Object specification : lstSpecifications) {               
                // now get attributes for this specification.               
               specificationAttributes = (Map<String, Object>)specification;
                Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('attributes');
                Map<String, Object> tempAdditionalAttMap = (Map<String, Object>) specificationAttributes.get('additionalAttributes');
                String guid = (String) specificationAttributes.get('guid');
                if(guidToUpdate == guid){
                    for(String atrributeattName: additionalAttrs.keyset()){
                        system.debug('Attribute Name '+atrributeattName);
                        system.debug('Attribute Value '+attributesMap.get(atrributeattName));
                        tempAdditionalAttMap.put(atrributeattName,additionalAttrs.get(atrributeattName));
                    }
                    specificationAttributes.put('additionalAttributes', tempAdditionalAttMap);
                }
                
            }
            String updatedserviceattachmentstr= JSON.serializePretty(results);
            return updatedserviceattachmentstr;
        }catch(Exception e){
            system.debug('Exception in addAdditionalAttributeNoSOQL '+ e);
            return serviceattachmentstr;
        }
    }
    //EDGE-66222 
    //get all service specification from orderId
    public static Map<String, String> getServiceSpecFromOrderId(Id orderId){
        
        Map<String, String> serviceAttachmentMap = new Map<String, String>();
        try{            
            List<csord__Order__c> orderIdList = [Select Id,Name,csord__Primary_Order__c from csord__Order__c where csord__Primary_Order__r.Id =: orderId ];
            System.debug('orderIdList====>'+orderIdList);
            List<csord__Service__c> servList = [Select id,name,csord__Order__c from csord__Service__c where csord__Order__r.Id IN : orderIdList];
            System.debug('servList===?'+servList);
            List<Id> serviceIds = new List<Id>();
            
            // Map<String, String> serviceAttachmentMap = new Map<String, String>();
            for(csord__Service__c ser : servList){
                serviceIds.add(ser.id);
                System.debug('serviceIds===>'+serviceIds);
            }
            
            for(Attachment att: [Select id,body,parentId from Attachment where parentId in :serviceIds]){
                //servAttachmentRecordMap.put(att.parentId,att);
                serviceAttachmentMap.put(att.parentId,att.body.toString());
            }
            //System.debug('serviceAttachmentMap===>'+serviceAttachmentMap);
            return  serviceAttachmentMap;
        }catch(Exception e){
            System.debug('Exception in getServiceSpecFromOrderId '+e);
            return  serviceAttachmentMap;
        }
        
    }
                
/*********************************************************************************************************************************
 * Method Name      :   getServiceSpecWithOfferFromOrderId
 *return            :   Map<String, String> serviceAttachmentMap
 *Story             :   EDGE-71655
**********************************************************************************************************************************/
    //get all service specification from orderId with key as serviceId and offerId
    public static Map<String, String> getServiceSpecWithOfferFromOrderId(Id orderId, Set<String> offerSpecSet){
        
        Map<String, String> serviceAttachmentMap = new Map<String, String>();
        try{            
             System.debug('orderId===>'+orderId +'offerSpecSet==>'+offerSpecSet);
            Map<Id,csord__Service__c> serviceMap = new Map<Id,csord__Service__c>([Select id,name,csord__Order__c,csord__Subscription__r.MarketableOffer__r.Offer_ID__c from csord__Service__c where csord__Order__r.Id =: orderId and csord__Subscription__r.MarketableOffer__r.Offer_ID__c in : offerSpecSet]);
            System.debug('serviceMap===>'+serviceMap);
           
            for(Attachment att: [Select id,body,parentId from Attachment where parentId in :serviceMap.keySet()]){
                //servAttachmentRecordMap.put(att.parentId,att);
                System.debug('att.parentId+'+'::'+'+serviceMap.get(att.parentId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c==>'+att.parentId+'::'+serviceMap.get(att.parentId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c);
                serviceAttachmentMap.put(att.parentId+'::'+serviceMap.get(att.parentId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c,att.body.toString());
            }
            System.debug('serviceAttachmentMap===>'+serviceAttachmentMap);
            return  serviceAttachmentMap;
        }catch(Exception e){
            System.debug('Exception in getServiceSpecFromOrderId '+e);
            return  serviceAttachmentMap;
        }
        
    }

    
    public static Map<Id,Attachment> getAttachmentToUpdate(CS_SpecificationDTO.ServiceSpecification specs,Map<String, String> serviceAttachmentMap,Map<String,Attachment> servAttachmentRecordMap, Map<String, String> specToUpdatedStatusMap){
        Map<Id,Attachment> updatedAttSet = new Map<Id,Attachment>();
        try{            
            String udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
            Attachment att = servAttachmentRecordMap.get(specs.serviceId);
            system.debug('udtattbody ' + udtattbody);
            att.body = Blob.valueOf(udtattbody);
            //update att;
            serviceAttachmentMap.put(att.parentId,att.Body.toString());
            updatedAttSet.put(att.id,att);
            return updatedAttSet;
        }catch(Exception e){
            System.debug('Exception in getAttachmentToUpdate '+e);
            return updatedAttSet;
        }
        
    }
    
    public static Map<Id,Attachment> getAddCharacteristic(String serviceID, String guid,Map<String, String> additionalAttrs){
        
        Map<String, String> serviceAttachmentMap = new Map<String, String>();
        Map<String,Attachment> servAttachmentRecordMap = new Map<String,Attachment>();
        Map<Id,Attachment> updatedAttMap = new Map <Id,Attachment>();
        // for(String guid : AttrMap.keyset())
        // {
        //csedm.API_1.addCharacteristic(serviceID, guid, AttrMap.get(guid));
        //System.debug('AttrMap.get(guid)::' + AttrMap.get(guid));
        
        
        //tactical fixes for serviceId getting null because of addCharacteristic API 
        
        //  csedm.API_1.addCharacteristic(serviceID, guid, AttrMap.get(guid));
        
        for(Attachment att: [Select id,body,parentId from Attachment where parentId =: serviceID]){
            servAttachmentRecordMap.put(att.parentId,att);
            serviceAttachmentMap.put(att.parentId,att.body.toString());
        }
        String bodyAdditionalAttr = ServiceSpecificationUtils.addAdditionalAttributeNoSOQL(serviceAttachmentMap.get(serviceID),guid,additionalAttrs);
        Attachment attAdd = servAttachmentRecordMap.get(serviceID);
        
        attAdd.body = Blob.valueOf(bodyAdditionalAttr);     
        //update att;
        serviceAttachmentMap.put(attAdd.parentId,attAdd.Body.toString());
        System.debug('serviceAttachmentMap LRMMSISDNService===>'+serviceAttachmentMap);
        updatedAttMap.put(attAdd.id,attAdd);
        // }
        return updatedAttMap;
        
        /*  if(!updatedAttSet.isEmpty()){

update updatedAttSet.values();
}*/
    }
    
    //----- get All,Billing,Fulfilment,Assurance Specs based on Service Id -----//
    public static List<CS_SpecificationDTO.ServiceSpecification> getAllServSpecsByServId(String serviceId, String targetSystem){
        List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        
        try{
            List<csord__Service__c> srvcList = [SELECT Id, Name, csord__Status__c, csord__Order__c, csord__Order__r.id , 
                                                csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,
                                                csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c,
                                                csord__Order_Request__c, csordtelcoa__Service_Number__c, 
                                                csord__Subscription__c, ReplacedSubscription__c, 
                                                CreatedDate,Forecasted_Delivery_Date__c, Telstra_Committed_Date__c, 
                                                csord__Order__r.csordtelcoa__Opportunity__c FROM csord__Service__c 
                                                WHERE Id =:serviceId Order By CreatedDate];
            Map<Id, Attachment> servAttachmentRecordMap = new Map<Id, Attachment>();
            Map<Id,String> serviceAttachmentMap = new Map<Id,String>();
            for(Attachment att: [Select id,body,parentId from Attachment where parentId in :srvcList]){
                servAttachmentRecordMap.put(att.parentId,att);
                serviceAttachmentMap.put(att.parentId,att.body.toString());
            }
            for(String eachService: serviceAttachmentMap.keySet()){
                if(targetSystem == 'ALL'){
                    
                    srvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService))));
                }else if(targetSystem == 'BILLING'){
                    
                    srvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),'BILLING'));
                }else if(targetSystem == 'FULFILMENT'){
                    
                    srvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),'FULFILMENT'));
                } else if(targetSystem == 'ASSURANCE'){
                    
                    srvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),'ASSURANCE'));
                }
            }
            System.debug('srvSpecList::' + srvSpecList);
            return srvSpecList;
        }
        catch (Exception e){
            System.debug(' Exception in getAllServSpecsByServId:' + e);
            return srvSpecList;
        }
    }
    
    /*********************************************************************************************************************************
     * Method Name      :   updateServiceSpecAttachment
     *return            :   void
     *Story             :   EDGE-53883/82202  method to handle sim replacement servicespecs update
     *Developer            :   Shubhi
     * modified for INC000092992238 shubhi/manish
    **********************************************************************************************************************************/
    
    
    public static void updateServiceSpecAttachment(String speccode,Map<id,csord__Service__c> serviceMap,Map<String,Subwrapper> subWrapperToIdMap){
       Map<String, CS_SpecificationDTO.ServiceSpecification> specsToBeUpdated = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
       Map<Id,Attachment> attchmap= new Map<Id,Attachment>();
       List<Attachment> attachmentListTobeUpdated = new List<Attachment>();
        if(serviceMap.keyset().IsEmpty())
        {
            return;
        }
            //fetching attachment body and modifying it based on service map 
        for(Attachment att:[select ID, name, body, parentId from Attachment where parentId in: serviceMap.keyset() and name = 'ServiceSpecifications.json']){
            String newServiceAttachmentStr = att.body.toString();
            Map<String, Object> updatedResults = (Map<String, Object>)JSON.deserializeUntyped(newServiceAttachmentStr);
            List<Object>lstSpecifications=(List<Object>)updatedResults.get('specifications');
            List<Object> newlstSpecifications = new List<Object>();
            for(Object spec:lstSpecifications){
                Map<String, Object> specificationAttributes = (Map<String, Object>)spec;
                ProductIdentifier__c pMob=ProductIdentifier__c.getValues('mobility');
                string specIdentifier1=pMob.speccode__c;
                ProductIdentifier__c mobdevice=ProductIdentifier__c.getValues('mob_device');
                string specIdentifier2=mobdevice.speccode__c;
                // EDGE-165020/EDGE-168784 || start 
                 ProductIdentifier__c ngemMobility=ProductIdentifier__c.getValues('NGEM_Mobility');
                string specIdentifier3=ngemMobility.speccode__c;
                // EDGE-165020/EDGE-168784 || end
                if(specificationAttributes!=null && specificationAttributes.get('code')==speccode && (speccode.contains(specIdentifier1) || speccode.contains(specIdentifier3))) //  added OR condition EDGE-165020
                {
                    
                    Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('additionalAttributes'); //added INC000092992238
                    String simSerialNumber=subWrapperToIdMap.get(serviceMap.get(att.parentId).csord__Subscription__c).simSerialNumber;
                    //EDGE-174221 Start
          String SimAvailabilityType=subWrapperToIdMap.get(serviceMap.get(att.parentId).csord__Subscription__c).SimAvailabilityType;
          
                    if (attributesMap!=null && SimAvailabilityType!='' && SimAvailabilityType=='New SIM')
                    {
                        attributesMap.put('ShippingRequired','TRUE'); //if sim serial is there shipping not required
                    }
                    else
                    {
                        attributesMap.put('ShippingRequired','FALSE');
                    }
          //EDGE-174221 END
                    
                    if (attributesMap!=null)
                    {
                        specificationAttributes.put('additionalAttributes',(Object)attributesMap); //INC000092992238
                        specificationAttributes.put('status','Modified');   // updating status to modify for sim replacement mobility specifications
                    }
                    newlstSpecifications.add((Object)specificationAttributes);        
                }
                //EDGE-113351 - Added below code to make shipping req as false in case of mobile device and device for Fullfillment spec 423
                else if (specificationAttributes!=null && specificationAttributes.get('code')==speccode && speccode.contains(specIdentifier2))
                {
                    Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('additionalAttributes');//INC000092992238
                    //EDGE-174221 Start
          String SimAvailabilityType=subWrapperToIdMap.get(serviceMap.get(att.parentId).csord__Subscription__c).SimAvailabilityType;
          
                    if (attributesMap!=null && SimAvailabilityType!='' && SimAvailabilityType=='New SIM')
                    {
                        attributesMap.put('ShippingRequired','TRUE'); //if sim serial is there shipping not required
                    }
                    else
                    {
                        attributesMap.put('ShippingRequired','FALSE');
                    }  
          //EDGE-174221 END    
                    newlstSpecifications.add((Object)specificationAttributes);        

                }
                else{
                    newlstSpecifications.add(spec);
                }
            }            
            updatedResults.put('specifications',newlstSpecifications);
            String updatednewServiceattachmentstr = JSON.serializePretty(updatedResults);
            system.debug('updatednewServiceattachmentstr'+updatednewServiceattachmentstr);
            att.Body=Blob.valueOf(updatednewServiceattachmentstr);
            attachmentListTobeUpdated.add(att);            
        }
        if(attachmentListTobeUpdated.size()>0)
        {
            try{
                update attachmentListTobeUpdated;
            }
            catch(Exception e)
            {
                system.debug('Exception'+e);
            }
        }
    } 
    
    
     // To get service specifications using serive Id
    public static List<CS_SpecificationDTO.ServiceSpecification> getServiceSpecList(String servId){
        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        Map<String, String> serviceAttachmentMap = new Map<String, String>();
                    for(Attachment att: [Select id,body,parentId from Attachment where parentId = :servId]){
                    serviceAttachmentMap.put(att.parentId,att.body.toString());
                    }
                    for(String eachService: serviceAttachmentMap.keySet()){
                    srvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),'FULFILMENT'));
                }
                return srvspecList;
    }
	/**************************************************************************************
****** Desc         : Method to get map of service id and all the service specifications from service id for target = fulfilment
****** Story        : EDGE-138136
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> getServiceSpecFulfilmentMap(Set<Id> servId){
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> srvspecMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();
        List<CS_SpecificationDTO.ServiceSpecification> srvspecList;
        Map<Id, String> serviceAttachmentMap = new Map<Id, String>();

        for(Attachment att: [Select id,body,parentId from Attachment where parentId in :servId and name = 'ServiceSpecifications.json']){
            serviceAttachmentMap.put(att.parentId,att.body.toString());
        }

        for(String eachService: serviceAttachmentMap.keySet()){
            srvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            srvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),'FULFILMENT'));
            srvspecMap.put(eachService, srvspecList);
        }
        return srvspecMap;
    }
    
    
}