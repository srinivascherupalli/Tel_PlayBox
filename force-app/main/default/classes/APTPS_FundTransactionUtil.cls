/*************************************************************************************************************************
 @Name: APTPS_FundTransactionUtil
 @Author: Akanksha Trivedi
 @Created Date: 06/02/2017
 @Descripton: This utility is used to create the annual fund transactions 
 @Used By: APTPS_YearlyFundTransactionBatch
*************************************************************************************************************************/
public with sharing class APTPS_FundTransactionUtil {
    
   
 /*************************************************************************************************************************
 @Name: activateAgreement
 @Author: Akanksha Trivedi
 @Created Date: 06/02/2017
 @Descripton: This method creates the fund transactions for fund
*************************************************************************************************************************/

    public Static void createFundTransaction(Fund__c fund)
    {
        try
        {  
           
           Id expCreditTypeId = Schema.SObjectType.Fund_Transaction__c.getRecordTypeInfosByName().get('Expiring Credit').getRecordTypeId();
           Id anniversaryTypeId = Schema.SObjectType.Fund_Transaction__c.getRecordTypeInfosByName().get('Anniversary Payment').getRecordTypeId();
           Id growthTypeId = Schema.SObjectType.Fund__c.getRecordTypeInfosByName().get('Growth').getRecordTypeId();
            
           List<Fund_Transaction__c> fndTransactions = new List<Fund_Transaction__c>();                
                Fund_Transaction__c fndTransaction = checkFundExpiry(fund);
                
                fndTransaction.Fund__c = fund.Id;
                fndTransaction.APTPS_Fund_Approval_Status__c = 'Approved';
                // changed action type from 'Adjusting Entry' to 'Anniversary Payment' for restricted picklist for action type
                fndTransaction.APTPS_Action_Type__c = 'Anniversary Payment';           
                fndTransaction.RecordTypeId = anniversaryTypeId;
                Date originalEndDate = (fund.APTPS_Expiry_Date__c).addDays(-30);           
                if(fund.RecordTypeId== growthTypeId && originalEndDate >= system.today()){
                   // make expiry record also
                   
                    Fund_Transaction__c expFndTransaction = new Fund_Transaction__c();
                    expFndTransaction.Fund__c = fund.Id;
                    expFndTransaction.APTPS_Fund_Approval_Status__c = 'Approved';
                    expFndTransaction.APTPS_Action_Type__c = 'Adjusting Entry';           
                    expFndTransaction.RecordTypeId = expCreditTypeId;
                    // check the expiry amount 
                    if(fund.APTPS_Current_Fund_Amount__c != 0)
                      expFndTransaction.APTPS_Transaction_Amount__c=  (fund.APTPS_Current_Fund_Amount__c * (-1));
                    else{
                      expFndTransaction.APTPS_Transaction_Amount__c=0;  
                    }
                     if(fndTransaction !=null && fndTransaction.APTPS_Transaction_Amount__c != null && expFndTransaction.APTPS_Transaction_Amount__c != 0){ 
                          fndTransactions.add(expFndTransaction);  
                       }
                    
                }
            
				if(fndTransaction !=null && fndTransaction.APTPS_Transaction_Amount__c != null && fndTransaction.APTPS_Transaction_Amount__c > 0){ 
                    fndTransactions.add(fndTransaction);                     
                }

        if(!fndTransactions.isEmpty())
            database.insert(fndTransactions,false); 
        
        }catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());          
        } 
              
    }
    
    private static Fund_Transaction__c  checkFundExpiry(Fund__c fund){
        Date originalEndDate = (fund.APTPS_Expiry_Date__c).addDays(-30);
        Fund_Transaction__c fndTransaction = new Fund_Transaction__c();
        if(originalEndDate >= system.today()){
                  if((fund.APTPS_Start_Date__c).addYears(1)==system.today() ){
                          //fndTransaction.APTPS_Transaction_Amount__c = fund.APTPS_Annual_Fund_Payment_Yr_1__c;
                          fndTransaction.APTPS_Transaction_Amount__c = fund.Annual_Fund_Payment_Yr_2__c;
                  }
                  if((fund.APTPS_Start_Date__c).addYears(2)==system.today() ){
                           //fndTransaction.APTPS_Transaction_Amount__c = fund.Annual_Fund_Payment_Yr_2__c;
                           fndTransaction.APTPS_Transaction_Amount__c = fund.APTPS_Annual_Fund_Payment_Yr_3__c;
                  }
                  if((fund.APTPS_Start_Date__c).addYears(3)==system.today() ){
                           //fndTransaction.APTPS_Transaction_Amount__c = fund.APTPS_Annual_Fund_Payment_Yr_3__c;
                           fndTransaction.APTPS_Transaction_Amount__c = fund.APTPS_Annual_Fund_Payment_Yr_4__c;
                  }
                  if((fund.APTPS_Start_Date__c).addYears(4)==system.today() ){
                           //fndTransaction.APTPS_Transaction_Amount__c = fund.APTPS_Annual_Fund_Payment_Yr_4__c;
                      		fndTransaction.APTPS_Transaction_Amount__c = fund.APTPS_Annual_Fund_Payment_Yr_5__c;
                  }
                  //if((fund.APTPS_Start_Date__c).addYears(5)==system.today() ){
                  //         fndTransaction.APTPS_Transaction_Amount__c = fund.APTPS_Annual_Fund_Payment_Yr_5__c;
                  //}   
              }
        return fndTransaction;
           }
   
}