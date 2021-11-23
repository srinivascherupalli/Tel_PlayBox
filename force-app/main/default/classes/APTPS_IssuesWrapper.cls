/*************************************************************************************************************************
 @Name: APTPS_IssuesWrapper
 @Author: Shishir Bose
 @Created Date: 04/28/2016
 @Descripton: This wrapper is used for displaying Issues on screen
 @Used By: APTPS_Import_UpdateIssuesController, APTPS_ExportIssuesController
*************************************************************************************************************************/
public class APTPS_IssuesWrapper {
    
    @AuraEnabled
    public string riskId {get; set;}
    @AuraEnabled
    public string Status {get; set;}
    @AuraEnabled
    public string AreaofRiskImpact {get; set;}
    @AuraEnabled
    public string RiskSummary {get; set;}
    @AuraEnabled
    public string Impact {get; set;}
    @AuraEnabled
    public string Implications {get; set;}
    @AuraEnabled
    public string PartyRaisingRisk {get; set;}
    @AuraEnabled
    public string InherentRiskRating {get; set;}
    @AuraEnabled
    public string ImpactofRisk {get; set;}
    @AuraEnabled
    public string LikelihoodofEventuation {get; set;}
    @AuraEnabled
    public string ActionStatus {get; set;}
  
    public Boolean isInserted {get; set;}
    public string DisplayImage {get; set;}
    
    public string sOMPRiskDate {get; set;}
    public string sOMPID {get; set;}
    public string riskName {get; set;}
    public string issueTrigger {get; set;}
    public string description {get; set;}
    public string likelyImpact {get; set;}
    public string owner {get; set;}
    public string likelihoodWOControls {get; set;}
    public string impactWOControls {get; set;}
    public string riskExposureWOControls {get; set;}
    public string responseTypeWOControls {get; set;}
    public string likelihoodWControls {get; set;}
    public string impactWControls {get; set;}
    public string riskExposureWControls {get; set;}
    public string responseTypeWControls {get; set;}
    public string mitigation {get; set;}
    public string flag {get; set;}
    
   //This constructor is used to create the instance of APTPS_IssuesWrapper from Apttus_SRM__Issue__c      
    public APTPS_IssuesWrapper(Apttus_SRM__Issue__c issue)
     {
         
        riskId = issue.Name;
        Status = issue.Apttus_SRM__Status__c;
        AreaofRiskImpact = issue.APTPS_Area_of_Risk_Impact__c;
        RiskSummary = issue.APTPS_Risk_Summary__c;
        Impact = issue.APTPS_Impact__c;
        Implications = issue.APTPS_Implications__c;
        PartyRaisingRisk = issue.APTPS_Party_Raising_Risk__c;
        InherentRiskRating = issue.APTPS_Inherent_Risk_Rating__c;
        ImpactofRisk = issue.APTPS_Impact_of_Risk__c;
        LikelihoodofEventuation = issue.APTPS_Likelihood_of_Eventuation__c;
        ActionStatus = issue.APTPS_Action_Status__c;
      
     }
    
      //This constructor is used to create the instance of APTPS_IssuesWrapper from string array
    public APTPS_IssuesWrapper(Apttus_SRM__Issue__c existingIssue, string[] csvRecordData)
    {
        //Displaying the insert/update image based of Issue record 
        if(existingIssue == null)
        {
            Status = 'Insert';
            isInserted = true;
            DisplayImage = '/resource/1461913388000/APTPS_InsertImage';
        }
        else
        {
            Status = 'Update';
            isInserted = false;
            DisplayImage = '/resource/1461914842000/APTPS_UpdateImage';
        }
        
        riskId = csvRecordData[0];
        sOMPRiskDate = csvRecordData[1];
        sOMPID = csvRecordData[2];
        riskName = csvRecordData[3];
        issueTrigger = csvRecordData[4];
        description = csvRecordData[5];
        likelyImpact = csvRecordData[6];
        owner = csvRecordData[7];
        likelihoodWOControls = csvRecordData[8];
        impactWOControls = csvRecordData[9];
        riskExposureWOControls = csvRecordData[10];
        responseTypeWOControls = csvRecordData[11];
        likelihoodWControls = csvRecordData[12];
        impactWControls = csvRecordData[13];
        riskExposureWControls = csvRecordData[14];
        responseTypeWControls = csvRecordData[15];
        mitigation = csvRecordData[16];
        flag = csvRecordData[17];
        
        
    }
  
}