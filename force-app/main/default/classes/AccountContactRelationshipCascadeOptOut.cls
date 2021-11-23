public without sharing class AccountContactRelationshipCascadeOptOut {
    @AuraEnabled
    public static String getAllAccountContactRelationRecords(String acrId,String sortField,String sortOrder){
        Contact contacts=null;
        List<AccountContactRelation> acrList=new List<AccountContactRelation>();
        AccountContactRelation acr=[select id,contactId,AccountId from AccountContactRelation where id=:acrId Limit 1];
        //Making Dynamic query by adding all the substrings
        String conId=acr.ContactId;//Storing in reference variable as dynamic population of Id doesn't work
        String soqlPartA='SELECT id,(SELECT id,roles,Account.name,Relationship_End_Date__c  FROM AccountContactRelations WHERE id <>:acrId AND Relationship_End_Date__c = null ORDER BY ';
        String soqlOnLoad='SELECT id,(SELECT id,roles,Account.name,Relationship_End_Date__c  FROM AccountContactRelations WHERE id <>:acrId AND Relationship_End_Date__c = null ORDER BY Account.Name ASC,Relationship_End_Date__c ASC NULLS FIRST) From Contact WHERE id=:conId';
        string queryStr = (String.isNotBlank(sortField))?soqlPartA+sortField+' '+sortOrder+' ) From Contact WHERE id=:conId' : soqlOnLoad;
        contacts=Database.query(queryStr);
        //IF blocks for all the combinations of sorting
        if(contacts!=null){
            acrList=contacts.AccountContactRelations;
            return JSON.serialize(acrList);
        }
        return null;
    }
    
     //EDGE - 30617
     @AuraEnabled
    public static void saveAcrPreferences(String acrId,List<String> ids){
        List<AccountContactRelation> acrList= [select id,contactId,AccountId from AccountContactRelation where id in:ids];
         AccountContactRelation refAcr = [SELECT id,Hospitality_Events__c,Not_Re_searchable__c,Opt_Out_Electronic_Marketing__c,
                                          Opt_Out_SMS_MMS__c,Opt_Out_Emails__c,Opt_Out_Social_Media_Direct_Message__c,
                                          Opt_Out_Market_Research__c,Opt_Out_All_Direct_Marketing__c,
                                          Opt_Out_Telemarketing__c, Opt_Out_Direct_Mail_White_Mail__c,
                                          Opt_Out_Face_to_Face__c
                                          FROM AccountContactRelation WHERE id =:acrId];
        if(!acrList.isEmpty()){
            for(AccountContactRelation acrs:acrList){
                acrs.Hospitality_Events__c=refAcr.Hospitality_Events__c;
                acrs.Not_Re_searchable__c=refAcr.Not_Re_searchable__c;
                acrs.Opt_Out_Electronic_Marketing__c=refAcr.Opt_Out_Electronic_Marketing__c;
                acrs.Opt_Out_SMS_MMS__c=refAcr.Opt_Out_SMS_MMS__c;
                acrs.Opt_Out_Emails__c=refAcr.Opt_Out_Emails__c;
                acrs.Opt_Out_Social_Media_Direct_Message__c=refAcr.Opt_Out_Social_Media_Direct_Message__c;
                acrs.Opt_Out_Market_Research__c=refAcr.Opt_Out_Market_Research__c;
                acrs.Opt_Out_All_Direct_Marketing__c=refAcr.Opt_Out_All_Direct_Marketing__c;
                acrs.Opt_Out_Telemarketing__c=refAcr.Opt_Out_Telemarketing__c;
                acrs.Opt_Out_Direct_Mail_White_Mail__c=refAcr.Opt_Out_Direct_Mail_White_Mail__c;
                acrs.Opt_Out_Face_to_Face__c=refAcr.Opt_Out_Face_to_Face__c;
            }
        }
        update acrList;
    }
}