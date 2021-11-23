/*************************************************************************************************************************
 @Name: APTPS_ExportObligationsController
 @Author: Shishir Bose
 @Created Date: 04/27/2016
 @Descripton: This controller is created for exporting obligations in a CSV file
 @Used By: APTPS_Init_ExportObligations VF page
*************************************************************************************************************************/
public without sharing class APTPS_ExportObligationsController {
    
 public List<APTPS_ObligationWrapper> obligations {get; set;}
 public id parentAgreementId {get; set;}
//This is constructor for getting the obligations data and export to csv.
 public APTPS_ExportObligationsController()
 {
   parentAgreementId = System.currentPageReference().getParameters().get('Id');                                               
 }
 
  /*************************************************************************************************************************
    @Name: generateCSV
    @Author: Shishir Bose
    @Created Date: 04/28/2016
    @Descripton: This method gets the obligations data to be exported to CSV
    *************************************************************************************************************************/
public void generateCSV()
 {
     try
     {
         obligations = new List<APTPS_ObligationWrapper>();
         List<Apttus_SRM__SRMObligation__c> agreementObligations = [select Id, Name,Apttus_SRM__AgreementId__c,APTPS_Clause_Name__c,APTPS_Agreement_Clause__r.Name,APTPS_Category__c,
                                                                    APTPS_Sub_Category__c,Apttus_SRM__Description__c,APTPS_Due_Date__c,APTPS_Obligation_Frequency__c,Apttus_SRM__Comments__c,CreatedById,
                                                                    Apttus_SRM__Responsible__c, Apttus_SRM__Accountable__c, Apttus_SRM__Consulted__c, Apttus_SRM__Informed__c from 
                                                                    Apttus_SRM__SRMObligation__c 
                                                                    where Apttus_SRM__AgreementId__c = :(System.currentPageReference().getParameters().get('Id')) ] ;
                                                   
        for(Apttus_SRM__SRMObligation__c obl : agreementObligations)
        {
            obligations.add(new APTPS_ObligationWrapper (obl));
        }
     }
    catch(Exception e)
    {
        System.debug('CaLMs System exception caught: ' + e.getMessage());  
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occured. Please contact the system administrator'));
    }
 }

@AuraEnabled	
 public static List<APTPS_ObligationWrapper> generateCSV(Id parentAgreementId)
 {
    
     
        List<APTPS_ObligationWrapper> obligations = new List<APTPS_ObligationWrapper>();
         List<Apttus_SRM__SRMObligation__c> agreementObligations = [select Id, Name,Apttus_SRM__AgreementId__c,APTPS_Clause_Name__c,APTPS_Agreement_Clause__r.Name,APTPS_Category__c,
                                                                    APTPS_Sub_Category__c,Apttus_SRM__Description__c,APTPS_Due_Date__c,APTPS_Obligation_Frequency__c,Apttus_SRM__Comments__c,CreatedById,
                                                                    Apttus_SRM__Responsible__c, Apttus_SRM__Accountable__c, Apttus_SRM__Consulted__c, Apttus_SRM__Informed__c from 
                                                                    Apttus_SRM__SRMObligation__c 
                                                                    where Apttus_SRM__AgreementId__c = :parentAgreementId ] ;
                                                   
        for(Apttus_SRM__SRMObligation__c obl : agreementObligations)
        {
            obligations.add(new APTPS_ObligationWrapper (obl));
        }
     
    return obligations;
 }
}