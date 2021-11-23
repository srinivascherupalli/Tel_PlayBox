/*************************************************************************************************************************
 @Name: APTPS_ExportIssuesController
 @Author: Shishir Bose
 @Created Date: 04/27/2016
 @Descripton: This controller is created for exporting Issues to a CSV file
 @Used By: APTPS_Init_ExportIssues VF page
*************************************************************************************************************************/
public without sharing class APTPS_ExportIssuesController {
    
    public List<APTPS_IssuesWrapper> issues {get; set;}
    public id parentAgreementId {get; set;}
   
   public APTPS_ExportIssuesController()
   {
       parentAgreementId = System.currentPageReference().getParameters().get('Id');   
   }
    
    /*************************************************************************************************************************
    @Name: generateCSV
    @Author: Shishir Bose
    @Created Date: 04/28/2016
    @Descripton: This method gets the issue data to be exported to CSV
    *************************************************************************************************************************/
    public void generateCSV()
     {
        try
        {
             Id inheretRiskRecordTypeId  = Schema.SObjectType.Apttus_SRM__Issue__c.getRecordTypeInfosByName().get('0 - Inherent Risk').getRecordTypeId();
             issues = new List<APTPS_IssuesWrapper>();
             List<Apttus_SRM__Issue__c> agreementIssues = [select Id, Name, Apttus_SRM__Agreement__c, APTPS_SOMP_Risk_Date__c, APTPS_SOMP_ID__c, APTPS_Risk_Name__c, APTPS_Trigger__c, APTPS_Description__c, APTPS_Likely_Impact__c, APTPS_Issues_Owner__c, 
                                                            APTPS_Likelihood_Without_Controls__c, APTPS_Impact_Without_Controls__c, APTPS_Risk_Exposure_Without_Controls__c, APTPS_Response_WithoutControl__c, 
                                                            APTPS_Likelihood_With_Controls__c, APTPS_Impact_With_Controls__c, APTPS_Risk_Exposure_With_Controls__c, APTPS_Response_Type_With_Controls__c, APTPS_Mitigation__c, APTPS_Flag__c,
                                                            RecordTypeId, ownerId from Apttus_SRM__Issue__c
                                                            where Apttus_SRM__Agreement__c =: parentAgreementId and RecordTypeId =: inheretRiskRecordTypeId]  ;

            for(Apttus_SRM__Issue__c issue : agreementIssues)
            {
                issues.add(new APTPS_IssuesWrapper (issue));
            }
        }
        catch(Exception e)
        {
           
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));
        }
        
     }
    
    @AuraEnabled
    public static List<APTPS_IssuesWrapper> generateCSV(Id parentAgreementId)
     {
         
             List<APTPS_IssuesWrapper> issues = new List<APTPS_IssuesWrapper>();
             List<Apttus_SRM__Issue__c> agreementIssues = [select Id, Name,Apttus_SRM__Status__c, APTPS_Area_of_Risk_Impact__c, APTPS_Risk_Summary__c, 
															APTPS_Impact__c, APTPS_Implications__c, APTPS_Party_Raising_Risk__c, APTPS_Inherent_Risk_Rating__c, 
															APTPS_Impact_of_Risk__c, APTPS_Likelihood_of_Eventuation__c, APTPS_Action_Status__c from Apttus_SRM__Issue__c
                                                            where Apttus_SRM__Agreement__c =: parentAgreementId];

         	
            for(Apttus_SRM__Issue__c issue : agreementIssues)
            {
                issues.add(new APTPS_IssuesWrapper (issue));
            }
        
        return issues;
        
     }
}