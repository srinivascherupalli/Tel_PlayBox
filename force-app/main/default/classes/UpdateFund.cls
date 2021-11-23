global class UpdateFund{
    webservice static LIST<Fund__c> getFund(){
         LIST<Fund__c> FU = [SELECT ID,APTPS_Fund_Balance_Variance__c,APTPS_Fund_Balance_in_Billing_System__c,APTPS_Total_MIPP_Credits__c FROM Fund__c];
         return FU;
       }
      
       
       }