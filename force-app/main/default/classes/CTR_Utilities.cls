/*
* @Desc : CTR Utility called from RF_ProductBasketDataHandler
* @Jira : DIGI-518
*/
global with sharing class CTR_Utilities{
    @TestVisible
    public static Contract_Generation_Setting__mdt getContractGenerationSettings(String hName) {
        Contract_Generation_Setting__mdt contractGenerationSettingRecord = New Contract_Generation_Setting__mdt();
        /*
        String queryStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Contract_Generation_Setting__mdt')) + '\n ' + ' FROM Contract_Generation_Setting__mdt \n ' + ' WHERE DeveloperName = \'' + String.escapeSingleQuotes(hName) + '\' LIMIT 1 ';
        List < Contract_Generation_Setting__mdt > contractGenerationSettingRecordList = Database.query(queryStr);
        */
		List < Contract_Generation_Setting__mdt > contractGenerationSettingRecordList = [SELECT Agreement_Category__c, Agreement_Subcategory__c, Apttus_Subtype__c, Approval_Status__c, Auto_Renew__c, Variation_Summary_Page_Needed__c, Source__c, Addresses_for_Notices__c from Contract_Generation_Setting__mdt WHERE DeveloperName =: hName LIMIT 1];        
        if (contractGenerationSettingRecordList != null && !contractGenerationSettingRecordList.isEmpty() && contractGenerationSettingRecordList.get(0) != null) {
            contractGenerationSettingRecord = contractGenerationSettingRecordList.get(0);
        }
        return contractGenerationSettingRecord;
    }

    public static boolean checkifContractExistsForAccount(String basketId,String Offer){      //// offer is not being used 
        Boolean ExistingContract=false;
        //start defect - 59875
        List<String> inactiveContractStatus=new List<String>{'Signature Declined','Cancelled','Void'}; 
        String soqlOnExistingContract='select id from ContractJunction__c where Related_Basket__c!=\''+ String.escapeSingleQuotes(basketId) +'\' and account__c IN(select csbb__Account__c from cscfga__Product_Basket__c where id=\''+ String.escapeSingleQuotes(basketId) +'\') and BSA_Generated__c =true and Status__c not in :inActiveContractStatus';
        //end defect - 59875
        List<ContractJunction__c> Cj = Database.query(soqlOnExistingContract);
        ////List<ContractJunction__c> Cj = [SELECT Id FROM ContractJunction__c WHERE Related_Basket__c !=: basketId AND Account__c IN(SELECT csbb__Account__c from cscfga__Product_Basket__c WHERE Id=: basketId AND BSA_Generated__c = true AND Status__c NOT IN(inActiveContractStatus)];
        if(Cj.size()>0)
            return true;
        else
            return false;
    }
}