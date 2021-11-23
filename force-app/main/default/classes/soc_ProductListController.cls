public without sharing class soc_ProductListController {
    
    
     @AuraEnabled
        public static String[] picklist_values(String object_name, String field_name) {
          String[] values = new String[]{};
          String[] types = new String[]{object_name};
          Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
          for(Schema.DescribeSobjectResult res : results) {
             for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {values.add(entry.getValue());}
             }
          }
          return values;
       }
        
        
    /*@AuraEnabled
    public static Map<String,Object> getProductList(String caseId){        
        Map<String,Object> results=new Map<String,Object>();
        String recId_SFD_ProductType=[Select id from RecordType where sObjectType = 'Case' and DeveloperName ='soc_SFD_Product' ].id;
        results.put('status','fail');       
        try{
			List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
			String MyProflieName = PROFILE[0].Name;            
            String ownerId=[select ownerId from Case where id=:caseId].ownerId;
            List<Case> items=[select id,soc_SFD_Product_number__c,accountId,RecordTypeId,OpportunityId__c,soc_Product__c,
                              Status,soc_SFD_Product_Status__c,soc_SFD_Sub_Status__c,soc_Order_Number__c,soc_Domain__c,soc_SFD_product_Text_ID__c from  Case where 
                              soc_Parent_SFD_Reference__c=:caseId and RecordTypeId=:recId_SFD_ProductType];
            
            results.put('status','pass');
            //results.put('options',picklist_values('Case','soc_SFD_Product_Status__c'));
            results.put('items',items);
            if( MyProflieName!='SFD Agent' &&  MyProflieName!='SOC Concierge' ){
            	results.put('visibility',false);
            }
            else if(ownerId!=UserInfo.getUserId()){
                results.put('visibility',false);
            }
            else{
                results.put('visibility',true);
            }

            
        }
        catch(Exception e){
            results.put('status','fail');
            results.put('response',e);            
        }
        return results;       
    }
    
    
    public static Boolean checkVisibility(String caseid){
        Boolean visibility=true;
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
			String MyProflieName = PROFILE[0].Name;
        String ownerId=[select ownerId from Case where id=:caseId].ownerId;
        
        if( MyProflieName!='SFD Agent' &&  MyProflieName!='SOC Concierge' ){
            	visibility=false;
            }
            else if(ownerId!=UserInfo.getUserId()){
                visibility=false;
            }
            else{
               visibility=true;
            }
        
        return visibility;
        
        
    }
    
    @AuraEnabled
    public static Map<String,Object> saveProductList(List<SObject> sfdProducts){        
        Map<String,Object> results=new Map<String,Object>();
        Boolean isVisible=true;
        List<Case> cases=new List<Case>();
        results.put('status','fail');       
        try{
            for(SObject obj:sfdProducts){
                Case cse=(Case)obj;
                cases.add(cse);
            }
            System.debug('Cases To Upsert');
            System.debug(cases);
            if(cases.size()>0){
                isVisible=checkVisibility(cases[0].soc_Parent_SFD_Reference__c);
            }
            if(isVisible){
                upsert cases;
                results.put('status','pass');
                results.put('response',cases);
            }
            else{
                results.put('status','fail');
                results.put('response',' Cannot update.The case ownership is changed.');
            }
              
        }
        catch(Exception e){
            results.put('status','fail');
            results.put('response',e);            
        }
        return results;       
    }
    
   
        
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase(UserInfo.getLocale());
        String dependentField = depfieldApiName.toLowerCase(UserInfo.getLocale());
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        Integer value=val;
        while (value > 0) {
            Integer remainder = Math.mod(value, 2);
            value = Integer.valueOf(Math.floor(value / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }*/
}