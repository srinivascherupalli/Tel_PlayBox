/********************************************************************************
EDGE        -140733
Class       -ConstantMetadataUtility
Description -To handle all the constant value in ConstantMetadataUtility metadataType
Author      -Abinash Barik/Dheeraj Bhatt
 ********************************************************************************/
public without sharing class ConstantMetadataUtility {
	public static map<string,Sobject> customMetadataNameValueMap=new map<string,Sobject>();
    public static List<cscfga__Product_Basket__c> basketdetails =new List<cscfga__Product_Basket__c>();
    public static List<Service_Qualification__c> lstserviceQual = new List<Service_Qualification__c>();
    public static Map <String, List <String>> fieldsForType = new Map <String, List <String>>();
    public static List<TransitionResponseCodes__c> responseCodeList = new List<TransitionResponseCodes__c>();

/**********************************************************************************************************
Method      -getTransitionResponse
Description -fetch all the Sobject records
Author      -Abinash Barik/Dheeraj Bhatt
************************************************************************************************************/    
    
    Public static List<TransitionResponseCodes__c> getTransitionResponse(){
        if(responseCodeList.isEmpty()){
            responseCodeList = [SELECT Status__c, Reason__c, Toast_Message__c, TRAMAS_Code__c FROM TransitionResponseCodes__c];        
        }
        return responseCodeList;
    } 
/**********************************************************************************************************
 EDGE       -140733
Method      -getConstantMetadataUtilityRecords
Description -fetch all the Sobject records
Author      -Abinash Barik/Dheeraj Bhatt
************************************************************************************************************/        
    public static map<string,Sobject> getConstantMetadataUtilityRecords(String objectName){
        List<String> strfldsList = new List<String>();
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        strfldsList = new List<String>(objectFields.keySet());
       String fields = '';
        for(String s : objectFields.keySet()){
            if(fields == ''){
                fields = s;
            }else{
                fields = fields +','+s;
            }
        }
        
        String query = '';
        if(!strfldsList.isEmpty()){
            query = 'SELECT ' + fields + ' FROM ' + objectName;
        }
        List<Sobject> results=Database.query(Query);
        if(customMetadataNameValueMap.isEmpty()){
            for(sObject customMetadata:results){ 
                system.debug('>>>'+customMetadata.get('DeveloperName'));                
               customMetadataNameValueMap.put(String.valueOf(customMetadata.get('DeveloperName')), customMetadata);
            }
        }
        return customMetadataNameValueMap;
    }
  /*------------------------------------------------------------------------------------
EDGE        -142351
Method      -insertFile
Description -Insert file and give visibilty access
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------------------*/    
    
    public static ContentVersion uploadFile(Id parentId, String fileName, String base64Data, String contentType)  
    { 
        String encodedData = EncodingUtil.urlDecode(base64Data, 'UTF-8'); 
        ContentVersion uploadFileVersion =new ContentVersion(); 
        uploadFileVersion.Title =fileName; 
        uploadFileVersion.VersionData=EncodingUtil.base64Decode(encodedData.escapeHtml4());
        uploadFileVersion.PathOnClient='/' + fileName ;
        insert uploadFileVersion; 
         
        //File Visibility access to user
        uploadFileVersion = [select id, ContentDocumentId from ContentVersion WHERE Id =: uploadFileVersion.Id];
        ContentDocumentLink uploadFileLink = new ContentDocumentLink();
        uploadFileLink.ContentDocumentId = uploadFileVersion.ContentDocumentId;
        uploadFileLink.LinkedEntityId = parentId; 
        uploadFileLink.ShareType = 'V';
        uploadFileLink.Visibility = 'AllUsers';
        insert uploadFileLink;
        return uploadFileVersion;
    }
    //get basket based on basket Id EDGE-147324
    public static List<cscfga__Product_Basket__c> getbasketdetails(String basketId){
        if(basketdetails.isEmpty()){
            system.debug('Inside If>>>');
            basketdetails = [SELECT id, csordtelcoa__Basket_Stage__c,Name,csbb__Account__c,csbb__Account__r.name,cscfga__Opportunity__c,isEligibilityCheckComplete__c , isEligibilityTriggered__c,Transition_basket_stage__c 
                             FROM cscfga__Product_Basket__c where id=:basketid];
        }
        return basketdetails;
    }
    // get Service Qualification based on accountId
     /*public static List<Service_Qualification__c> getserviceQualification(String accountId){
         if(lstserviceQual.isEmpty()){
             lstserviceQual = [Select id,Account__c,Added_to_CA_form__c,Portability_Status__c,Service_Number__c,UniqueBasketMSISDN__c,Portability_Code__c,
                               Incumbent_Account_Number__c,Incumbent_Carrier__c
								from Service_Qualification__c where Account__c= :accountId order by Service_Number__c];
         }
         return lstserviceQual;
     }*/
    /*-------------------------------------------------------------------------------------------------------
Story		-DIGI-867
Method      -getserviceQualification
Description -get service qualification records. Filter by account and basket
Author      -Kalashree Borgaonkar
----------------------------------------------------------------------------------------------------------*/  
     public static List<Service_Qualification__c> getserviceQualification(String accountId,String basketid){
         if(lstserviceQual.isEmpty()){
             lstserviceQual = [SELECT id,Account__c,Added_to_CA_form__c,Portability_Status__c,Service_Number__c,PPV_Status__c,
                               UniqueBasketMSISDN__c,Portability_Code__c,Incumbent_Account_Number__c,Incumbent_Carrier__c
							   FROM Service_Qualification__c 
                               WHERE Account__c= :accountId AND basket_id__c = :basketid order BY Service_Number__c];
         }
         return lstserviceQual;
     }
    
    //Abinash
    @AuraEnabled  
    public static List<picklistWrapper> findPicklistOptions(string objAPIName, string fieldAPIname) {
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        // Get the object type of the SObject.
		Schema.sObjectType objType = schemaMap.get(objAPIName);
		// Describe the SObject using its object type.
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		// Get a map of fields for the SObject
		map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
		// Get the list of picklist values for this field.
		list < Schema.PicklistEntry > values = fieldMap.get(fieldAPIname).getDescribe().getPickListValues();
		// Add these values to the selectoption list.
		for (Schema.PicklistEntry a: values) {
			picklistWrapper aa = new picklistWrapper();
			aa.label = a.getLabel();
			aa.value = a.getValue();
			returnValue.add(aa); 
		}
        system.debug('*****returnValue'+returnValue);
        return returnValue;
        
        
    }
 /******************************************************************
EDGE        -150172
Method      -checkForPartnerUser 
Description -Check logged in user in partner user or CRM user
Author      -Dheeraj Bhatt
******************************************************************/ 
     public static Boolean checkForPartnerUser(){
        return [SELECT Id,IsPortalEnabled FROM User WHERE id =:UserInfo.getUserId()].IsPortalEnabled;
        
    }
    public class picklistWrapper{
        @AuraEnabled 
		public string label;
        @AuraEnabled 
		public string value;
        
    }

    // Abinash : get dynamic soql query by passing sobject type,fields list and conditions
    public static String getSOQL(String objectType, List < String > fieldList, String conditionExpression, String orderBy) {
        String soql = 'SELECT {fieldList} FROM {objectType} ';
        soql = soql.replace('{fieldList}', String.join(fieldList, ','));
        soql = soql.replace('{objectType}', objectType);
        if (String.isNotBlank(conditionExpression)){
            //Kalashree Borgaonkar. fix for SOQL injection
            soql += ' WHERE ' + String.escapeSingleQuotes(conditionExpression) ;
        }
        if (String.isNotBlank(orderBy)){
            soql += ' order By ' + orderBy;
        }
        return soql;
    }
    
    //Abinash :  get all the fields by passing sObjectType
    public static String[] getAllFields(String type) {
        //use cached version if possible.
        if (fieldsForType.containsKey(type)) {
            return fieldsForType.get(type);
        }
        SObjectType sObjType = Schema.getGlobalDescribe().get(type);
        if (sObjType == null) {
            return new String[] {};
		}
        Map < String, Schema.SObjectField > sObjectFields = sObjType.getDescribe().fields.getMap();
        String[] keys = new String[] {};
            keys.addAll(sObjectFields.keyset());
        fieldsForType.put(type, keys);
        return keys;
    }
    /*=========================================================================================================================
EDGE       -EDGE-170949/170948
Method     -fetchProductandPlanMetadata 
Description-Fetch all the Products and its related Plans from CustomMetadata
Author     -Dheeraj Bhatt/Veena Putta
===========================================================================================================================*/
     public static  Map<string,List<Plan__mdt>> fetchProductandPlanMetadata(){
      Map<string,List<Plan__mdt>>mapOfProductAndPlan= new Map<string,List<Plan__mdt>>();
        for(Product__mdt product:[SELECT DeveloperName,Label,product_Specification__c, (SELECT Id,Label,Communication_Method__c,Type__c FROM Plan__r ) FROM Product__mdt]){
            mapOfProductAndPlan.put(product.product_Specification__c,product.Plan__r);
        }
        return mapOfProductAndPlan;  
    }
}