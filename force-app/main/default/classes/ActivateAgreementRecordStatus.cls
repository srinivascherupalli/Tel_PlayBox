/* Class Name      :   ActivateAgreementRecordStatus
   Sr.No.    Developer Name          Date          Story Description
   1.       Divya Chilakabathini    02/12/2020     change the status of the contract junction to contract Accepted
 */
public with sharing class ActivateAgreementRecordStatus {
    
    private static final Id AGREEMENT_SCHEDULE_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
    
    // This method is called on click of button from contractJunction record page to change the status of the contract junction to contract Accepted
    @AuraEnabled
    public static String changeAgreementRecordStatus(Id conJunId){
        system.debug('conJunId:'+conJunId);
        String result;
        
        //fetching price schedule record based on the related contract junction Id and recordtype Id
        Apttus__APTS_Agreement__c priceScheduleRecord = getPriceSchRecord(conJunId);
        
        system.debug('priceScheduleRecord:'+priceScheduleRecord);
        
        //checking the PS record Related Basket & Related contract is not null and also the status is activated or fully signed 
        result = changeContractStatus(priceScheduleRecord);
        
        return result;
            
    }
    
    //fetching the contract junction record based on the conJunId ID passed from UI
     @AuraEnabled
    public static Contractjunction__c getContractStatus(Id conJunId){
        Contractjunction__c contractRec = [Select Id,Status__c,Restrict_Conga_Flow__c,isTransitionContract__c from Contractjunction__c Where Id =: conJunId];
        return contractRec;
    }
    
    //get the Price Schedule record based on contract junction Id
    private static Apttus__APTS_Agreement__c getPriceSchRecord(Id conJunId){
        Apttus__APTS_Agreement__c priceScheduleRecord = [Select Apttus__Agreement_Category__c,Apttus__Account__c,Related_Contract__c,APTPS_Record_Type_Name__c,
                                                         RecordTypeId,Related_Basket__c,Apttus__Parent_Agreement__c,Apttus__Status__c,Apttus__Status_Category__c from Apttus__APTS_Agreement__c 
                                                         Where Related_Contract__c =: conJunId and RecordTypeId =: AGREEMENT_SCHEDULE_RECORDTYPEID];
		return priceScheduleRecord;
    }
    
    //change the status of contract junction based on PS record
    private static String changeContractStatus(Apttus__APTS_Agreement__c priceScheduleRecord){
        Boolean checkStatusFlag = false;
        if(priceScheduleRecord != null){
        	if(priceScheduleRecord.Related_Basket__c != null && priceScheduleRecord.Related_Contract__c != null 
               && ((priceScheduleRecord.Apttus__Status__c == 'Activated' && priceScheduleRecord.Apttus__Status_Category__c == 'In Effect') 
                    || (priceScheduleRecord.Apttus__Status__c == 'Fully Signed' && priceScheduleRecord.Apttus__Status_Category__c == 'In Signatures')) 
               && priceScheduleRecord.APTPS_Record_Type_Name__c == 'Schedule' 
               && priceScheduleRecord.Apttus__Agreement_Category__c == 'Pricing'){
                   
                   //fetching the contract junction based on PS related contract junction Id and updating the status is contract accepted
                   Contractjunction__c contStatusRecord = [Select Id, Status__c from Contractjunction__c Where Id=: priceScheduleRecord.Related_Contract__c];
                   contStatusRecord.Status__c = 'Contract Accepted';
                   update contStatusRecord;
                   checkStatusFlag = true;
                   system.debug('contStatusRecord:'+contStatusRecord);
                   
               }
        }
        system.debug('checkStatusFlag:'+checkStatusFlag);
        if(checkStatusFlag)
            return 'Success';
        else
            return 'Failure';
    }
    
}