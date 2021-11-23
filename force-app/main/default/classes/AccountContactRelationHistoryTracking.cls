public without sharing class AccountContactRelationHistoryTracking {
    private static Boolean run = true;
    private static Boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    //ACRHistory Mapping For EDGE-16057
    private AccountContactRelationshipHistory__c getAccountContactRelationHistory(Id ids,Map<Id,AccountContactRelation> oldMap,Map<Id,AccountContactRelation> newMap,Boolean flag){
        AccountContactRelationshipHistory__c acrHistory=new AccountContactRelationshipHistory__c();
        acrHistory.Context__c=(flag)?'User':'System';
        acrHistory.Account__c=oldMap.get(ids).AccountId;
        acrHistory.Account_New__c=newMap.get(ids).AccountId;
        acrHistory.Active__c=oldMap.get(ids).IsActive;
        acrHistory.Active_New__c=newMap.get(ids).IsActive;
        acrHistory.All_Direct_Marketing__c=oldMap.get(ids).Opt_Out_All_Direct_Marketing__c;
        acrHistory.All_Direct_Marketing_New__c=newMap.get(ids).Opt_Out_All_Direct_Marketing__c;
        acrHistory.Contact_Usage__c=oldMap.get(ids).Contact_Usage__c;
        acrHistory.Contact_Usage_new__c=newMap.get(ids).Contact_Usage__c;
        acrHistory.Company_Officeholder_Role__c=oldMap.get(ids).Company_Officeholder_role__c;
        acrHistory.Company_Officeholder_Role_New__c=newMap.get(ids).Company_Officeholder_role__c;
        acrHistory.Contact__c=oldMap.get(ids).ContactID;
        acrHistory.Contact_New__c=newMap.get(ids).ContactID;
        acrHistory.Job_Description__c=oldMap.get(ids).Job_Description__c;
        acrHistory.Job_Description_New__c=newMap.get(ids).Job_Description__c;
        acrHistory.Job_Title__c=oldMap.get(ids).Job_Title__c;
        acrHistory.Job_Title_New__c=newMap.get(ids).Job_Title__c;
        acrHistory.Primary_Contact__c=oldMap.get(ids).isPrimary__c;
        acrHistory.Primary_Contact_New__c=newMap.get(ids).isPrimary__c;
        acrHistory.Relationship_End_Date__c=oldMap.get(ids).Relationship_End_Date__c;
        acrHistory.Relationship_End_Date_New__c=newMap.get(ids).Relationship_End_Date__c;
        acrHistory.Relationship_Expiry_Date__c=oldMap.get(ids).Relationship_Expiry_Date__c;
        acrHistory.Relationship_Expiry_Date_New__c=newMap.get(ids).Relationship_Expiry_Date__c;
        acrHistory.Relationship_Verified_Date__c=oldMap.get(ids).Relationship_Verified_Date__c;
        acrHistory.Relationship_Verified_Date_New__c=newMap.get(ids).Relationship_Verified_Date__c;
        acrHistory.Roles__c=oldMap.get(ids).Roles;
        acrHistory.Role_New__c=newMap.get(ids).Roles;
        acrHistory.Account__c=oldMap.get(ids).AccountId;
        acrHistory.Account_New__c=newMap.get(ids).AccountId;
        acrHistory.Verification_Recommended__c=oldMap.get(ids).Verification_Recommended__c;
        acrHistory.Verification_Recommended_New__c=newMap.get(ids).Verification_Recommended__c;	
        acrHistory.Verified_Relationship__c=oldMap.get(ids).Verified_Relationship__c;
        acrHistory.Verified_Relationship_New__c=newMap.get(ids).Verified_Relationship__c;
        acrHistory.Diamond_Member_Previous__c=oldMap.get(ids).Diamond_Member__c;
        acrHistory.Diamond_Member_New__c=newMap.get(ids).Diamond_Member__c;
        acrHistory.Mandatory_Contact_Previous__c=oldMap.get(ids).Mandatory_Contact__c;
        acrHistory.Mandatory_Contact_New__c=newMap.get(ids).Mandatory_Contact__c;
        acrHistory.EEF_Contact_Previous__c=oldMap.get(ids).EEF_Contact__c;
        acrHistory.EEF_Contact_New__c=newMap.get(ids).EEF_Contact__c;
        acrHistory.Opt_Out_All_Previous__c=oldMap.get(ids).Not_Re_searchable__c;
        acrHistory.Opt_Out_All_New__c=newMap.get(ids).Not_Re_searchable__c;
        acrHistory.Market_Research_Previous__c=oldMap.get(ids).Opt_Out_Market_Research__c;
        acrHistory.Market_Research_New__c=newMap.get(ids).Opt_Out_Market_Research__c;	
        acrHistory.Hospitality_Events_Previous__c=oldMap.get(ids).Hospitality_Events__c;
        acrHistory.Hospitality_Events_New__c=newMap.get(ids).Hospitality_Events__c;
        acrHistory.Electronic_Marketing_Previous__c=oldMap.get(ids).Opt_Out_Electronic_Marketing__c;
        acrHistory.Electronic_Marketing_New__c=newMap.get(ids).Opt_Out_Electronic_Marketing__c;
        acrHistory.All_Direct_Marketing__c=oldMap.get(ids).Opt_Out_All_Direct_Marketing__c;
        acrHistory.All_Direct_Marketing_New__c=newMap.get(ids).Opt_Out_All_Direct_Marketing__c;
        acrHistory.SMS_MMS_Previous__c=oldMap.get(ids).Opt_Out_SMS_MMS__c;
        acrHistory.SMS_MMS_New__c=newMap.get(ids).Opt_Out_SMS_MMS__c;
        acrHistory.Face_to_Face_Previous__c=oldMap.get(ids).Opt_Out_Face_to_Face__c;
        acrHistory.Face_to_Face_New__c=newMap.get(ids).Opt_Out_Face_to_Face__c;
        acrHistory.Emails_Previous__c=oldMap.get(ids).Opt_Out_Emails__c;
        acrHistory.Emails_New__c=newMap.get(ids).Opt_Out_Emails__c;
        acrHistory.Direct_Mail_White_Mail_Previous__c=oldMap.get(ids).Opt_Out_Direct_Mail_White_Mail__c;
        acrHistory.Direct_Mail_White_Mail_New__c=newMap.get(ids).Opt_Out_Direct_Mail_White_Mail__c;
        acrHistory.Social_Media_Direct_Message_Previous__c=oldMap.get(ids).Opt_Out_Social_Media_Direct_Message__c;
        acrHistory.Social_Media_Direct_Message_New__c=newMap.get(ids).Opt_Out_Social_Media_Direct_Message__c;
        acrHistory.Telemarketing_New__c=newMap.get(ids).Opt_Out_Telemarketing__c;
        acrHistory.Telemarketing_Previous__c=oldMap.get(ids).Opt_Out_Telemarketing__c;
        //acrHistory.Strategic_NPS_Contact_Previous__c=oldMap.get(ids).CVA_Contact_Customer_Value_Analysis__c;
        //acrHistory.Strategic_NPS_Contact_New__c=newMap.get(ids).CVA_Contact_Customer_Value_Analysis__c;     
		acrHistory.Strategic_NPS_Contact_Previous__c=oldMap.get(ids).CVA_Contact_Customer_Value_Analysis__c;
        acrHistory.Strategic_NPS_Contact_New__c=newMap.get(ids).CVA_Contact_Customer_Value_Analysis__c; 
        acrHistory.Business_Challenge_Previous__c=oldMap.get(ids).Business_Challenge__c;
        acrHistory.Business_Challenge_New__c=newMap.get(ids).Business_Challenge__c;
        acrHistory.Business_Priority_1_Previous__c=oldMap.get(ids).Business_Priority_1__c;
        acrHistory.Business_Priority_1_New__c=newMap.get(ids).Business_Priority_1__c;
        acrHistory.Business_Priority_2_Previous__c=oldMap.get(ids).Business_Priority_2__c;
        acrHistory.Business_Priority_2_New__c=newMap.get(ids).Business_Priority_2__c;
        acrHistory.Business_Priority_3_Previous__c=oldMap.get(ids).Business_Priority_3__c;
        acrHistory.Business_Priority_3_New__c=newMap.get(ids).Business_Priority_3__c;
        return acrHistory;
    }
    //EDGE-16057
    public void trackHistoryOfACRToACRHistoryObj(Map<Id,AccountContactRelation> oldMap,Map<Id,AccountContactRelation> newMap){
       	List<AccountContactRelationshipHistory__c> acrHistoryList=new List<AccountContactRelationshipHistory__c>();
        if(AccountContactRelationHistoryTracking.runOnce()){
            for(Id ids:newMap.keySet()){
                acrHistoryList.add(getAccountContactRelationHistory(ids,oldMap,newMap,true));
            }
        }
        else{
            for(Id ids:newMap.keySet()){
                acrHistoryList.add(getAccountContactRelationHistory(ids,oldMap,newMap,false));
            }
        }
        insert acrHistoryList;
    }   
}