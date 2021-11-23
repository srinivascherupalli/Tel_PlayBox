/**
* @Description : 
* @Author : Anu Yadav
* @Date : 02/Feb/2018
* @Story : EDGE-61
*/
public without sharing class NotifyCustomerHelper {
    
    public static List<Account_Industry_Relationship__c> getExistingAccountIndustry(Id accountId){
        System.debug('!@#$% Querying for exisitng AccountIndustry with Account ID : ' + accountId);
        List<Account_Industry_Relationship__c> accIndustry = [Select Id, AccountID__c,IndustryID__c,SIC_Code__c from Account_Industry_Relationship__c where AccountID__c= :accountId];
        System.debug('!@#$% Querying result : ' + accIndustry);
        if(accIndustry != null && !accIndustry.isEmpty()){
            return accIndustry;
        }
        return null;
    }
    
    public static List<Account_Industry_Relationship__c> mapRequestToAccountIndustry(NotifyCustomerRequest req,Account a){
        List<Account_Industry_Relationship__c> accIndustry = new List<Account_Industry_Relationship__c>();
        if(req.data.ansicCode != null && String.isNotBlank(req.data.ansicCode)){
            List<ASIC__c> asic = [Select Id,Industry__c,SIC_Code__c from ASIC__c where SIC_Code__c= :req.data.ansicCode];
            if(!asic.isEmpty()){
                Account_Industry_Relationship__c accInd = new Account_Industry_Relationship__c();
                accInd.AccountID__c = a.Id; 
                accInd.IndustryID__c=asic[0].Id;   
                accIndustry.add(accInd);
            }
        }
        return accIndustry;
    }
}