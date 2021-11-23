/*************************************************************************************************************************
 @Name: APTPS_ObligationWrapper
 @Author: Shishir Bose
 @Created Date: 04/28/2016
 @Descripton: This wrapper is used for displaying obligations on screen
 @Used By: APTPS_Import_UpdateObligationsController, APTPS_ExportObligationsController
*************************************************************************************************************************/
public without sharing class APTPS_ObligationWrapper {
    
    @AuraEnabled
    public string Obligation_Id {get; set;}
    @AuraEnabled
    public string Agreement_Clause {get; set;}
    @AuraEnabled
    public string Category {get; set;}
    @AuraEnabled
    public string Sub_Category {get; set;}
    @AuraEnabled
    public string Description {get; set;}
    @AuraEnabled
    public string Due_Date {get; set;}
    @AuraEnabled
    public string Obligation_Frequency {get; set;}
    @AuraEnabled
    public string Comments {get; set;}
    @AuraEnabled
    public string CreatedBy {get; set;}
    @AuraEnabled
    public string Responsible {get; set;}
    @AuraEnabled
    public string Accountable {get; set;}
    @AuraEnabled
    public Boolean isInserted {get; set;}
    @AuraEnabled
    public string DisplayImage {get; set;}
    @AuraEnabled
    public string Status {get; set;}
    @AuraEnabled
    public string Consulted {get; set;}
    @AuraEnabled
    public string Informed {get; set;}
    
    
//This constructor is used to create the instance of APTPS_ObligationWrapper from Apttus_SRM__SRMObligation__c    
    public APTPS_ObligationWrapper(Apttus_SRM__SRMObligation__c obligation)
    {
        Obligation_Id = obligation.Name;
        Agreement_Clause = obligation.APTPS_Clause_Name__c;
        Category = obligation.APTPS_Category__c;
        Sub_Category = obligation.APTPS_Sub_Category__c;
        Description = obligation.Apttus_SRM__Description__c;
        
        Due_Date = APTPS_CommonUtilities.GetStringFromDate(obligation.APTPS_Due_Date__c, APTPS_Constants.CSV_DATE_FORMAT);
        Obligation_Frequency = obligation.APTPS_Obligation_Frequency__c;
        Comments = obligation.Apttus_SRM__Comments__c;
       
       User usr = [select Id, Name from User where id = :obligation.CreatedById limit 1];
        CreatedBy = usr.Name;
        Responsible = obligation.Apttus_SRM__Responsible__c;
        Accountable = obligation.Apttus_SRM__Accountable__c;
        Consulted = obligation.Apttus_SRM__Consulted__c;
        Informed = obligation.Apttus_SRM__Informed__c;
    }

	    //This constructor is used to create the instance of APTPS_ObligationWrapper from string array
    public APTPS_ObligationWrapper(string[] csvRecordData, Apttus_SRM__SRMObligation__c existingObligationRecord, Id parentAgreementId){
    }

	
}