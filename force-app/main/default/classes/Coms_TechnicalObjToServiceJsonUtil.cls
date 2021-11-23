/*************************************************************************************************************
 * @name			Coms_TechnicalObjToServiceJsonUtil
 * @author			BLR\rohit.pal <rohit.pal@crmit.com>
 * @created			27 / 08 / 2021
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-08-27		BLR\rohit.pal			Changes desription
 *
**************************************************************************************************************/
public with sharing class Coms_TechnicalObjToServiceJsonUtil {
    public List<specifications> specifications;
	public string serviceId;	//a4e2N0000005QVkQAM
	public List<legacyAttributes> legacyAttributes;
	public class Specifications {
		public string version;	//1
		public string status;	//Created
		public string startDate;	//
		public string specification;	//DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810
		public string productConfigurationId;	//a3T2N000000CgThUAK
		public string name;	//871_RC_810
		public metadata metadata;
		public string instanceId;	//
		public boolean includeBilling;
		public string guid;	//19d37d80-ea8a-4b0b-48e4-cc5057ff15ae
		public string endDate;	//
		public string description;	//Business Calling_Billing_RecurringCharge_000810
		public string code;	//DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810
		public attributes attributes;
		public additionalAttributes additionalAttributes;
	}
	public class Metadata {
	}
	public class Attributes {
		public string billDescription1;	//Feature Usage Charges
		public string externalId;	//DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_8336
		public string chargeId;	//DMCAT_RecurringCharge_000810
		public string billingSpecId;	//BSUSG005_CB
		public string type;	//RC
		public string currency1;	//AUD
		public string billingSubtype;	//HWM
		public string taxTreatment;	//GST Applicable
		public string targetSystem;
        public List<ComplexAttribute> strNumber;	//BILLING
	}
	public class AdditionalAttributes {
        public string name;
        public string value;
	}
	public class LegacyAttributes {
	}

    public class ComplexAttribute{
        public string schemaId;
        public List<SimpleAttribute> attributes;
    }
    public class SimpleAttribute{
        public string FNN;
        public string rangeFrom;
        public string rangeTo;
        public string status;
        public string listCode;
    }
    /**
    * @description 
    * @author Rohit Pal | 08-30-2021 
    * @param strCorrelationId 
    * @return Coms_TechnicalObjToServiceJsonUtil 
    **/
    public static Coms_TechnicalObjToServiceJsonUtil generateAttachmentJSON(string strServiceId){
        Coms_TechnicalObjToServiceJsonUtil objComsTechnicalObjToServiceJsonUtil = new Coms_TechnicalObjToServiceJsonUtil();
        List<Coms_TechnicalObjToServiceJsonUtil.Specifications> listSpecifications = new List<Coms_TechnicalObjToServiceJsonUtil.Specifications>();
        List<Coms_TechnicalObjToServiceJsonUtil.Attributes> listAttribute = new List<Coms_TechnicalObjToServiceJsonUtil.Attributes>();
        List<Coms_TechnicalObjToServiceJsonUtil.SimpleAttribute> listSimpleAttribute;
        List<Coms_TechnicalObjToServiceJsonUtil.ComplexAttribute> listComplexAttribute;
        Coms_TechnicalObjToServiceJsonUtil.Attributes objAttributes;
        Coms_TechnicalObjToServiceJsonUtil.Specifications objSpecifications;
        Coms_TechnicalObjToServiceJsonUtil.ComplexAttribute objComplexAttribute;
        Coms_TechnicalObjToServiceJsonUtil.SimpleAttribute objSimpleAttribute;
        
        objComsTechnicalObjToServiceJsonUtil.serviceId =strServiceId;
        for(Orchestration_Technical__c iterator : [SELECT id,
                                                        Name,
                                                        Field_1__c,Field_9__c,
                                                        Field_2__c,Field_10__c,
                                                        Field_3__c,Field_11__c,
                                                        Field_4__c,Field_12__c,
                                                        Field_5__c,Field_13__c,
                                                        Field_6__c,Field_14__c,
                                                        Field_7__c,Field_15__c,
                                                        Field_8__c,Field_19__c,
                                                        Service__c,
                                                    (SELECT id,
                                                            Field_1__c,
                                                            Field_2__c,Field_4__c,
                                                            Field_3__c,Field_5__c,
                                                            Field_6__c,
                                                            Category__c,
                                                            Complex_Attribute_Schema_Id__c,
                                                            CorrelationId__c
                                                            FROM Technical_Child_Attributes__r)
                                                FROM Orchestration_Technical__c 
                                                WHERE Service__c =:strServiceId]){
            //
            objSpecifications = new Coms_TechnicalObjToServiceJsonUtil.Specifications();
            objSpecifications.version                 =  iterator.Field_1__c;
            //objSpecifications.strSubscriptionId          =iterator.Field_2__c;
            objSpecifications.status                   =iterator.Field_3__c;
            objSpecifications.startDate =iterator.Field_4__c;
            //objSpecifications.strServiceId =iterator.Field_5__c;
            objSpecifications.specification=iterator.Field_6__c;
            objSpecifications.productConfigurationId=iterator.Field_6__c;
            objSpecifications.name=iterator.Field_7__c;
            objSpecifications.instanceId=iterator.Field_8__c;
            objSpecifications.guid=iterator.Field_9__c;
            objSpecifications.endDate=iterator.Field_10__c;
            objSpecifications.description=iterator.Field_11__c;
            objSpecifications.code =iterator.Field_12__c;
            // add those values in the list.
            listSpecifications.add(objSpecifications);
            objComsTechnicalObjToServiceJsonUtil.specifications = listSpecifications;
            objAttributes = new Coms_TechnicalObjToServiceJsonUtil.Attributes();
            objAttributes.billDescription1='';
            objAttributes.billingSpecId='';
            objAttributes.billingSubtype='';
            objAttributes.chargeId='';
            objAttributes.currency1='';
            objAttributes.externalId='';
            objAttributes.targetSystem='';
            objAttributes.taxTreatment='';
            objAttributes.type='';
            listComplexAttribute = new List<Coms_TechnicalObjToServiceJsonUtil.ComplexAttribute>();
            for(Technical_Child_Attribute__c childAttribute : iterator.Technical_Child_Attributes__r){
                objComplexAttribute = new Coms_TechnicalObjToServiceJsonUtil.ComplexAttribute();
                for(Technical_Child_Attribute__c childAttribute1 : iterator.Technical_Child_Attributes__r){
                    objSimpleAttribute = new Coms_TechnicalObjToServiceJsonUtil.SimpleAttribute();
                    objSimpleAttribute.FNN =childAttribute1.Field_1__c;
                    objSimpleAttribute.rangeFrom=childAttribute1.Field_2__c;
                    objSimpleAttribute.rangeTo=childAttribute1.Field_3__c;
                    objSimpleAttribute.status=childAttribute1.Field_4__c;
                    objSimpleAttribute.listCode=childAttribute1.Field_5__c;
                    listSimpleAttribute = new List<Coms_TechnicalObjToServiceJsonUtil.SimpleAttribute>();
                    listSimpleAttribute.add(objSimpleAttribute);
                    objComplexAttribute.attributes = listSimpleAttribute;
                    listComplexAttribute.add(objComplexAttribute);
                    break;
                }
                objComplexAttribute.schemaId = childAttribute.Complex_Attribute_Schema_Id__c.substringAfter('-');
            }
            objAttributes.strNumber = listComplexAttribute;
            // added all the attriute to this call;
            objSpecifications.attributes =objAttributes;
        }
        string strJson = JSON.serialize(objComsTechnicalObjToServiceJsonUtil);
        System.debug('strJson ---> ' + strJson);
        return objComsTechnicalObjToServiceJsonUtil;
    }
	public static Coms_TechnicalObjToServiceJsonUtil parse(string json){
		return (Coms_TechnicalObjToServiceJsonUtil) System.JSON.deserialize(json, Coms_TechnicalObjToServiceJsonUtil.class);
	}


    /**
    * @description : 
    * @author Rohit Pal | 08-30-2021 
    * @param mapJsonIdentifiersLabels 
    * @return Map<id, Map<string, string>>
    **/
    //Map<id,string>{'a4e2N0000005QVk' => 'Status,productConfigurationId,code'};
    // Map<string , string> return one to one mapping Status --> values
    public static Map<Id,  Map<string,string>> getOrchestrationObjectLabelValueMap(Map<id , string> mapJsonIdentifiersLabels){
        Map<string, TechnicalObjectFieldMapping__mdt> mapTechnicalObjectFieldMapping = Coms_PEPublishUtil.mdtGetTechnicalObjectFieldMapping();
        System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found mapTechnicalObjectFieldMapping ---> ' + mapTechnicalObjectFieldMapping);
        Map<string , List<string>> mapObjectAndFields;
        List<sobject> listobject = new List<sobject>();
        List<string> listCommaSeperatedLabel;
        Map<id , Orchestration_Technical__c> mapServiceAndOrchestration = new Map<id,Orchestration_Technical__c>();
        List<sobject> sobjectNewList  = new List<sobject>();
        List<Orchestration_Technical__c> listOrchestrationTechnical = new List<Orchestration_Technical__c>();
        Map<Id,  Map<string,string>> mapTechnicalObjectKeyValues = new Map<Id,  Map<string,string>>();
        Map<string, string> mapKeyValuePair;
        listOrchestrationTechnical = getOrchestrationTechnicals(mapJsonIdentifiersLabels.keySet());
        System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found listOrchestrationTechnical ---> ' + listOrchestrationTechnical);
        Orchestration_Technical__c objOrchestrationTechnical;
        for(Orchestration_Technical__c iterator : listOrchestrationTechnical){
            mapServiceAndOrchestration.put(iterator.service__c , iterator);
        }
        System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found mapServiceAndOrchestration ---> ' + mapServiceAndOrchestration);
        for(Id idIterator : mapJsonIdentifiersLabels.keySet()){
            mapObjectAndFields = new Map<string , List<string>>();
            listCommaSeperatedLabel = new List<string>();
            listCommaSeperatedLabel = string.valueOf(mapJsonIdentifiersLabels.get(idIterator)).split(',');
            Set<String> sStrings = new Set<String>(listCommaSeperatedLabel);
            System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found sStrings ---> ' + sStrings);
            for(string strIterator : mapTechnicalObjectFieldMapping.keySet()){
                if( mapTechnicalObjectFieldMapping.get(strIterator).Object_Name__c == 'Orchestration_Technical__c' && sStrings.contains(strIterator)){
                    objOrchestrationTechnical = new Orchestration_Technical__c();
                    objOrchestrationTechnical = mapServiceAndOrchestration.get(idIterator);
                    if(mapTechnicalObjectKeyValues.containsKey(idIterator)){
                        System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found strIterator ---> ' + strIterator);
                        mapKeyValuePair = new Map<string, string>();
                        mapKeyValuePair = mapTechnicalObjectKeyValues.get(idIterator);
                        mapKeyValuePair.put(strIterator , (string) objOrchestrationTechnical.get(mapTechnicalObjectFieldMapping.get(strIterator).Object_Field_Name__c));
                        mapTechnicalObjectKeyValues.put(idIterator ,mapKeyValuePair );
                        System.debug( 'Step 4. Remove undesired field  from mapKeyValuePair: ' + mapKeyValuePair );
                    }else if(!mapTechnicalObjectKeyValues.containsKey(idIterator)){
                        System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found strIterator ---> ' + strIterator);
                        mapTechnicalObjectKeyValues.put(idIterator ,new map<string , string>{strIterator => (string) objOrchestrationTechnical.get(mapTechnicalObjectFieldMapping.get(strIterator).Object_Field_Name__c)} );
                        System.debug( 'Step 4. Remove undesired field  from mapTechnicalObjectKeyValues: ' + mapTechnicalObjectKeyValues );
                    }
                }
            }
            System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found final mapTechnicalObjectKeyValues ---> ' + mapTechnicalObjectKeyValues);
        }
        return mapTechnicalObjectKeyValues;
    }

    /**
    * @description : 
    * @author Rohit Pal | 08-30-2021 
    * @param mapJsonIdentifiersLabels 
    * @return Map<id, Map<string, string>>
    **/
    //Map<id,string>{'a4e2N0000005QVk' => 'Status,productConfigurationId,code'};
    public static Map<id , List<Technical_Child_Attribute__c>> getTechnicalChildAttributeObjectLabelValueMap(Map<id , string> mapJsonIdentifiersLabels){
        Map<string, TechnicalObjectFieldMapping__mdt> mapTechnicalObjectFieldMapping = Coms_PEPublishUtil.mdtGetTechnicalObjectFieldMapping();
        System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found mapTechnicalObjectFieldMapping ---> ' + mapTechnicalObjectFieldMapping);
        Map<string , List<string>> mapObjectAndFields;
        List<sobject> listobject = new List<sobject>();
        List<string> listCommaSeperatedLabel;
        List<Technical_Child_Attribute__c> listOrchestrationTechnical;
        Map<id , List<Technical_Child_Attribute__c>> mapServiceAndOrchestration = new Map<id, List<Technical_Child_Attribute__c>>();
        List<sobject> sobjectNewList  = new List<sobject>();
        List<Technical_Child_Attribute__c> listOrchestrationTechnicals = new List<Technical_Child_Attribute__c>();
        listOrchestrationTechnicals = getTechnicalChildAttributes(mapJsonIdentifiersLabels.keySet());
        System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found listOrchestrationTechnicals ---> ' + listOrchestrationTechnicals);
        Technical_Child_Attribute__c objOrchestrationTechnical;
        for(Technical_Child_Attribute__c iterator : listOrchestrationTechnicals){
            if(mapServiceAndOrchestration.containskey(iterator.Orchestration_Technical__r.service__c)){
                listOrchestrationTechnical = new List<Technical_Child_Attribute__c>();
                listOrchestrationTechnical = mapServiceAndOrchestration.get(iterator.Orchestration_Technical__r.service__c);
                listOrchestrationTechnical.add(iterator);
                mapServiceAndOrchestration.put(iterator.Orchestration_Technical__r.service__c , listOrchestrationTechnical);
            }else{
                mapServiceAndOrchestration.put(iterator.Orchestration_Technical__r.service__c , new list<Technical_Child_Attribute__c>{iterator});
            }
        }
        System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found mapServiceAndOrchestration ---> ' + mapServiceAndOrchestration);
        for(Id idIterator : mapJsonIdentifiersLabels.keySet()){
            mapObjectAndFields = new Map<string , List<string>>();
            listCommaSeperatedLabel = new List<string>();
            listCommaSeperatedLabel = string.valueOf(mapJsonIdentifiersLabels.get(idIterator)).split(',');
            Set<String> sStrings = new Set<String>(listCommaSeperatedLabel);
            System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found sStrings ---> ' + sStrings);
            for(string strIterator : mapTechnicalObjectFieldMapping.keySet()){
                System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found strIterator ---> ' + strIterator);
                if( mapTechnicalObjectFieldMapping.get(strIterator).Object_Name__c == 'Technical_Child_Attribute__c' && !sStrings.contains(strIterator)){
                    listOrchestrationTechnical = new List<Technical_Child_Attribute__c>();
                    listOrchestrationTechnical = mapServiceAndOrchestration.get(idIterator);
                    for(Technical_Child_Attribute__c technicalAttribute :listOrchestrationTechnical){
                        System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found technicalAttribute ---> ' + technicalAttribute);
                        Map<String, Object> mapOrchestrationTechnical = new Map<String, Object>( technicalAttribute.getPopulatedFieldsAsMap());
                        mapOrchestrationTechnical.remove(mapTechnicalObjectFieldMapping.get(strIterator).Object_Field_Name__c);
                        technicalAttribute = (Technical_Child_Attribute__c) JSON.deserialize( JSON.serialize( mapOrchestrationTechnical ), Technical_Child_Attribute__c.class );
                        System.debug( 'Step 4. Remove undesired field  from map: ' + technicalAttribute );
                    }
                    mapServiceAndOrchestration.put(idIterator , listOrchestrationTechnical);
                }
            }
            System.debug('Coms_TechnicalObjToServiceJsonUtil :: getTechnicalObjectLabelValueMap :: found final mapServiceAndOrchestration ---> ' + mapServiceAndOrchestration);
        }
        return mapServiceAndOrchestration;
    }
    
    /**
    * @description : get Technical object Correlation id.
    * @author Rohit Pal | 08-18-2021 
    * @param setServices 
    * @return Map<Id, Orchestration_Technical__c> 
    **/
    public static List<Orchestration_Technical__c> getOrchestrationTechnicals(set<Id> setServices){
        List<Orchestration_Technical__c> listOrchestrationTechnical = new List<Orchestration_Technical__c>();
        SObjectType sobType =  Orchestration_Technical__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('Orchestration_Technical__c');
        listOrchestrationTechnical = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  Service__c =: setServices');
        system.debug('Coms_CorrelationIdGeneration :: getOrchestrationTechnicals found listOrchestrationTechnical---> ' + listOrchestrationTechnical);
        return listOrchestrationTechnical;
    }

    /**
    * @description : get Technical object Correlation id.
    * @author Rohit Pal | 08-18-2021 
    * @param setServices 
    * @return Map<Id, Orchestration_Technical__c> 
    **/
    public static List<Technical_Child_Attribute__c> getTechnicalChildAttributes(set<Id> setServices){
        List<Technical_Child_Attribute__c> listOrchestrationTechnical = new List<Technical_Child_Attribute__c>();
        SObjectType sobType =  Technical_Child_Attribute__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('Technical_Child_Attribute__c');
        listOrchestrationTechnical = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  Orchestration_Technical__r.Service__c =: setServices');
        system.debug('Coms_CorrelationIdGeneration :: getOrchestrationTechnicals found listOrchestrationTechnical---> ' + listOrchestrationTechnical);
        return listOrchestrationTechnical;
    }
}