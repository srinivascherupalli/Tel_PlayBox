/*********** 
 * Team : Hawaii
 * Description : controller to get fields from field set and record type id from record type name
 * Jira : P2OB-10028
 * Created Date : 6 October 2020
*****************/
public with sharing class PRMContactRecordEditFormController {
	
    /*
    * @Description : Wrapper class contains the information about all the fields of a FieldSet
    */ 
    public class FieldSetMemberWrapperClass{
        
        //variable to store if the field is required by the field’s definition in its sObject
        @AuraEnabled
        public Boolean isDBRequired 					 { get; set; }
        //variable to store if the field is required by the field set
        @AuraEnabled
        public Boolean isRequired 						 { get; set; }
        //variable to store the field’s Apex data type
        @AuraEnabled
        public String fieldType 						 { get; set; }
        //variable to store the field's label
        @AuraEnabled
        public String fieldLabel 						 { get; set; }
        //variable to store the field's api name
        @AuraEnabled
        public String fieldAPIName 					     { get; set; }
        //variable to store picklist values of field if field type is picklist/multiselectpicklist
        @AuraEnabled 
        public List<Schema.PicklistEntry> pickListValues { get; set; }
    }
    
    //aura enabled method call from lightning component 'prmContactRecordEditForm'
    @AuraEnabled
    public static String getFieldSetMember(String objectName , String fieldSetName){
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
        if(String.isNotBlank(objectName) && String.isNotBlank(fieldSetName)){
            //get detail of object
            Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
            //get all field details with fieldset 
            for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
                //initialize wrapper class
                FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();
                wrapper.isDBRequired = fieldMember.getDbRequired();
                wrapper.isRequired = fieldMember.getRequired();
                wrapper.fieldType = String.valueOf(fieldMember.getType());
                wrapper.fieldLabel = fieldMember.getLabel();
                wrapper.fieldAPIName = fieldMember.getFieldPath();
                if(String.valueOf(fieldMember.getType()) == 'PICKLIST' || 
                                String.valueOf(fieldMember.getType()) == 'MULTIPICKLIST'){
                    wrapper.pickListValues = sObj.getDescribe().fields.getMap().get(fieldMember.getFieldPath())
                                                               .getDescribe().getPicklistValues();
                }
                wrapperList.add(wrapper);
            }
        }
        // serialize wrapper classlist
        return JSON.serialize(wrapperList);
    }
    
    //method to get record Type id from record type name
    @AuraEnabled
    public static String getRecordTypeId(String objectName , String recordTypeName){
        String recid = '';
        if(String.isNotBlank(objectName) && String.isNotBlank(recordTypeName)){
            //get record type id from record type name 
			recid = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
       	}
        //return record type id
        return recid;
    }
}