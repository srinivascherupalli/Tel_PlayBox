/**
* Utility class to determine updates to field values for monitored fields for a given object type
* @Description : EDGE 38. Custom Invoking Manage Interface Dynamically
* @Author : Shambo Ray
* @Date : 31/01/2018
* @Story : EDGE-38 : Invoking Manage Interface Dynamically
**/

/*
 * Modified By : Team Lisbon
 * Date : 22/10/2020
 * Jira : P2OB-9530 
 * Description : making changes in After update trigger hander of Contact and AccountContactRelation Object. 
				 So that specific field update for this object will trigger CustomerMS event. To Monitor Fields we have 
				 created CustomMetadata.Utility Class check Update against specific Field: FieldUpdateIdentifier
 * Updates :
 * Date : 22/11/2020
 * Jira : P2OB-9997 
	Description : making changes in After update trigger hander of Account Object. 
				 So that specific field update for this object will trigger CustomerMS event. To Monitor Fields we have 
				 created CustomMetadata.Utility Class check Update against specific Field: FieldUpdateIdentifier
*/
public without sharing class FieldUpdateIdentifier {
    
    private Schema.SObjectType objectType;
    private string integrationType;
    private List<Monitored_Field__mdt> monitoredFields;
    
    /**
    * Constructor to set the object type being monitored
    *
    * @param objectType type of object
    **/
    public FieldUpdateIdentifier(Schema.SObjectType objectType) {
        System.debug('FieldUpdateIdentifier - Object name : '+objectType.getDescribe().getName() );
        this.objectType = objectType;
        this.monitoredFields = loadMontitoredFields();
    }
    
        /**
    * Constructor to set the object type being monitored
    * P2OB-9530 : CustomerMS event for only for specific field Update

    * @param objectType type of object
    * @param integrationType type of Integration i.e 'TCM' or 'CustomerMS'
    **/
    public FieldUpdateIdentifier(Schema.SObjectType objectType,string integrationType) {
        System.debug('FieldUpdateIdentifier - Object name : '+objectType.getDescribe().getName() );
        this.objectType = objectType;
        this.integrationType = integrationType;
        this.monitoredFields = loadMontitoredFields();
    }
    
    /**
    * Find any field updates for the monitored fields for the object type
    *
    * This method will loop through all provided records and as soon as it finds a non matched field it will add it to a map
    * of matched records and skip any further checks on the record and iterate to the next one in the list
    *
    * @param records Updated object records
    * @param oldRecords Previous version of the records
    *
    * @return Map of records with changes to a mapped field
    **/
    public Map<Id, sObject> identifyUpdatesToMonitoredFields(Map<Id, sObject> records, Map<Id, sObject> oldRecords){
        Map<Id, sObject> udpatedRecordMatches = new Map<Id, sObject>();
        if(oldRecords != NULL && !monitoredFields.isEmpty()){
            for(sObject record : records.values()){
                for(Monitored_Field__mdt monitoredField : monitoredFields){
                    if(monitoredField != null && monitoredField.Field_API_Name__c!=null && record.get(monitoredField.Field_API_Name__c) != oldRecords.get(record.Id).get(monitoredField.Field_API_Name__c)){
                        if(TestDataCheck.datacheck != null && TestDataCheck.datacheck && monitoredField.test_data__c){
                            udpatedRecordMatches.put(record.Id, record);
                            break;
                        } else if(!monitoredField.test_data__c) {
                             udpatedRecordMatches.put(record.Id, record);
                             break;
                        }
                    }
                }
            }
        }
        return udpatedRecordMatches;
    }
    
    /**
    * Load the fields which have been configured as monitored for object type
    *
    * @return List of monitored fields for the object type passed in the constructor
    **/
    private List<Monitored_Field__mdt> loadMontitoredFields(){
        system.debug('FieldUpdateIdentifier - Object name -- loadMontitoredFields : '+objectType.getDescribe().getName());
        String objectName = objectType.getDescribe().getName();
            //P2OB-9530 : CustomerMS event for only for specific field Update
        if(integrationType != Label.CustomerMS_Integration){
            if('cscrm__Contact_Address_Relationship__c'.equals(objectType.getDescribe().getName())){
                objectName='Contact_Address_Relationship';
            }
        }else{
             if('AccountContactRelation'.equals(objectType.getDescribe().getName())){
                objectName='ACR_For_CustomerMS';
             }else if('Contact'.equals(objectType.getDescribe().getName())){
                objectName='Contact_For_CustomerMS';
             }else if('Account'.equals(objectType.getDescribe().getName())){
                objectName='Account_For_CustomerMS';		 
			 }
        }

        List<Monitored_Field__mdt> objectTypeFields = [select Id, Field_API_Name__c,QualifiedApiName,DeveloperName,Object_Field_Monitor__r.DeveloperName,Object_Field_Monitor__r.Active__c,test_data__c from Monitored_Field__mdt where Object_Field_Monitor__r.DeveloperName=:objectName and Object_Field_Monitor__r.Active__c=true];
        return objectTypeFields;
    }
    
}