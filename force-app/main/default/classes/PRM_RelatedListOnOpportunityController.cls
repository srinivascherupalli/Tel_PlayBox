/* Team Hawaii
 * Get Product Basket list for Partner User
 * P2OB-2458 - Update Edit Access Logic
*/
public with sharing class PRM_RelatedListOnOpportunityController {
    
    @auraEnabled
    public static String getRelatedListData(String recordId, String childObject, String parentField,String fieldsToBeDisplayed){
        ChildRecordWrapper childRecordWrapper = new ChildRecordWrapper();
        System.debug('::test'+recordId);
        childRecordWrapper.isEditAccess = false;
        childRecordWrapper.listData = new List<Sobject>();
        try{
            if(recordId != null){
                // get the opportunity Access 
				List<OpportunityShare> opptyShare = [SELECT  id, OpportunityAccessLevel  FROM OpportunityShare WHERE opportunityId = : recordId AND userOrGroupId = : UserInfo.getUserId() AND (OpportunityAccessLevel = 'Edit' OR OpportunityAccessLevel = 'All')]; 
				if(opptyShare.size() > 0){
					childRecordWrapper.isEditAccess = true;
				}else{
					User partnerUserDetails;
					for(User usr : [SELECT id, contactId, AccountId FROM User where id =: UserInfo.getUserId()]){
						partnerUserDetails = usr;
					}
					if(partnerUserDetails != null){
						for(Opportunity oppty : [select id, Owner.AccountId,Associated_Distributor__c from opportunity where id =: recordId]){
							if(oppty.Owner.AccountId == partnerUserDetails.AccountId || (oppty.Associated_Distributor__c != null && oppty.Associated_Distributor__c == partnerUserDetails.AccountId)){
								childRecordWrapper.isEditAccess = true;
							}
						}
					}
				}
				String soqlQuery = ' SELECT Id, Name ';
				if(!fieldsToBeDisplayed.contains(parentField)){
					soqlQuery += ',' + parentField;
				}
				soqlQuery += (fieldsToBeDisplayed != null && fieldsToBeDisplayed != '' ? ',' + fieldsToBeDisplayed :'' ) + ' FROM  ' + childObject + ' WHERE ' + parentField + '= : recordId ';
				// get the related list data (Product Basket)
				List<Sobject> sobjectList = (List<Sobject>)Database.query(soqlQuery); 
				
				childRecordWrapper.listData = sobjectList;
			  }
        childRecordWrapper.fieldWrapperList = getFieldDetails(fieldsToBeDisplayed,childObject);    
        }catch(Exception ex){
            return 'Error:'+ex.getMessage();
        }
        return JSON.serialize(childRecordWrapper);
    } 
    /* get field Details to be Display on list*/ 
    private static List<FieldWrapper> getFieldDetails(String fieldsToBeDisplayed, String childObject){
        List<FieldWrapper> fieldWrapperList = new List<FieldWrapper>();
        List<String> fields = fieldsToBeDisplayed.split(',');
        SObjectType sobjType = Schema.getGlobalDescribe().get(childObject);
        Map<String,Schema.SObjectField> mfields = sobjType.getDescribe().fields.getMap();
        
        for(String f : fields){
            f = f.trim();
            if(mfields.containsKey(f)){
                FieldWrapper fw = new FieldWrapper();
                Schema.DescribeFieldResult sf = mfields.get(f).getDescribe();
                fw.label = sf.getLabel().toupperCase();
                fw.fieldName = f;
                fw.type = getFieldType(sf.getType());
                fieldWrapperList.add(fw);
            }
        }
        return fieldWrapperList;
        
    }
    
    /* get field Type*/ 
    private static String getFieldType(Schema.DisplayType fieldType){
  
        if(fieldType == Schema.DisplayType.String || 
            fieldType == Schema.DisplayType.TextArea ||
            fieldType == Schema.DisplayType.Id ||
            fieldType == Schema.DisplayType.Picklist ||
            fieldType == Schema.DisplayType.Reference ||
            fieldType == Schema.DisplayType.Phone ||
            fieldType == Schema.DisplayType.Email ||
            fieldType == Schema.DisplayType.URL ||
            fieldType == Schema.DisplayType.MultiPicklist)
                return 'String';
        if(fieldType == Schema.DisplayType.Currency ||
           fieldType == Schema.DisplayType.Double)
            return 'Decimal';
        if(fieldType == Schema.DisplayType.Integer)
            return 'Integer';
        if(fieldType == Schema.DisplayType.Boolean)
            return 'boolean';
        if(fieldType == Schema.DisplayType.DateTime)
            return 'dateTime';    
        if(fieldType == Schema.DisplayType.Date)
            return 'date';            
        if(fieldType == Schema.DisplayType.Time)
            return 'Time';   
        if(fieldType == Schema.DisplayType.base64 )
            return 'base64 ';               
       return 'UNKNOWN';    
    } 
    public class ChildRecordWrapper{
        public Boolean isEditAccess {get;set;}
        public List<FieldWrapper> fieldWrapperList {get;set;}
        public List<Sobject> listData {get;set;}
    }
    
    public class FieldWrapper {
        public String label {get;set;}
        public String fieldName {get;set;}
        public String type {get;set;}
    }
}