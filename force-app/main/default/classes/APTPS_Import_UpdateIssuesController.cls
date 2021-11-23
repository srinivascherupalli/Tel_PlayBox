/*************************************************************************************************************************
 @Name: APTPS_Import_UpdateIssuesController
 @Author: Shishir Bose
 @Created Date: 05/13/2016
 @Descripton: This controller is created for importing/updating issues from a CSV file
 @Used By: APTPS_Init_ImportUpdateIssues VF page
*************************************************************************************************************************/

public with sharing class APTPS_Import_UpdateIssuesController {

public Blob csvFileBody{get;set;}
public string csvAsString{get;set;}
public String[] csvFileLines{get;set;}
public List<Apttus_SRM__Issue__c> issuesToBeInserted{get;set;}
public List<Apttus_SRM__Issue__c> issuesToBeUpdated{get;set;}
public string agreementName{get;set;}
public Apttus__APTS_Agreement__c parentAgreement {get; set;}
public List<APTPS_IssuesWrapper> issuesToBeDisplayed {get; set;}
public Id inheretRiskRecordTypeId {get; set;}

//showGrid and showFileSelection: This variables are used to hide/show the file selection section and data grid section
public string showGrid {get; set;}
public string showFileSelection {get; set;}

public APTPS_Import_UpdateIssuesController(){
    
  }
  
  
  public APTPS_Import_UpdateIssuesController(ApexPages.StandardController stdController){
     if(!Test.isRunningTest()){
     stdController.addFields(new List<string>{'Name','Apttus__Status_Category__c', 'Apttus__Status__c'});
     }
     parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
     agreementName = parentAgreement.Name; 
     csvFileLines = new String[]{};
     showGrid = 'none';
     showFileSelection = 'block';
     
    inheretRiskRecordTypeId  = Schema.SObjectType.Apttus_SRM__Issue__c.getRecordTypeInfosByName().get('0 - Inherent Risk').getRecordTypeId();
  }
  
  
  /*************************************************************************************************************************
 @Name: importUpdateCSVFile
 @Author: Shishir Bose
 @Created Date: 04/28/2016
 @Descripton: This method creates the list of issues to be updated or inserted
*************************************************************************************************************************/
  public void importUpdateCSVFile(){
      
      //If the file name is empty show the error message
      if(string.isEmpty(csvAsString))
           {
               showFileSelection = 'block';
               ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Select CSV File to upload Obligations.'));
           }
           else
           {
             try{
                       showGrid = 'block';
                       showFileSelection = 'none';
               
                       csvAsString = csvFileBody.toString();
                       csvFileLines = csvAsString.split('\n'); 
                    
                       issuesToBeInserted = new List<Apttus_SRM__Issue__c>();
                       issuesToBeUpdated = new List<Apttus_SRM__Issue__c>();
                       Map<string,Apttus_SRM__Issue__c> existingIssues = new Map<string,Apttus_SRM__Issue__c>();
                       Apttus_SRM__Issue__c issue;
                       issuesToBeDisplayed = new List<APTPS_IssuesWrapper>();
                      Apttus_SRM__Issue__c existingIssueRecord = null;
                   
                   for(Apttus_SRM__Issue__c exstgIssue :  [select Id, Name,Apttus_SRM__Agreement__c from Apttus_SRM__Issue__c where 
                                                                       Apttus_SRM__Agreement__c =:parentAgreement.Id])
                        {
                            existingIssues.put(exstgIssue.Name, exstgIssue);
                        }
                      //Iterate through each row in the file and if the issue exist put in the update list and if not in the insert list     
                       for(Integer i = 1;i < csvFileLines.size();i++){
                           
                           string[] csvRecordData = csvFileLines[i].split(',');
                           
                            if(checkEmptyRow(csvRecordData))
                            {
                                continue;
                            }
                           
                           issue = new Apttus_SRM__Issue__c() ;
                           
                           //See if the issue exist for the agreement
                           if(existingIssues.get(csvRecordData[0]) != null)
                           {
                               existingIssueRecord = existingIssues.get(csvRecordData[0]);
                           }
                           else
                           {
                               existingIssueRecord = null;
                           }
                            
                           
                           issue = populateIssue(existingIssueRecord, csvRecordData);
                           if(existingIssueRecord != null)
                           {
                              issuesToBeUpdated.add(issue);
                           }
                           else
                           {
                               issuesToBeInserted.add(issue);
                           }
                           
                           issuesToBeDisplayed.add(new APTPS_IssuesWrapper(existingIssueRecord, csvRecordData));
                    }
            
            }                
             catch (Exception e)
             {
                 showGrid = 'none';
                 showFileSelection = 'block';
                 ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data. Please make sure that input csv file matches the format as described below.');
                 ApexPages.addMessage(errorMessage);
             }
         
           } 
  }
    
    private boolean checkEmptyRow(string[] csvRecordData)
    {
        boolean isEmptyRecord = false;
        
        if(string.isEmpty(csvRecordData[0].trim()) && string.isEmpty(csvRecordData[1].trim()) && string.isEmpty(csvRecordData[2].trim()) 
           && string.isEmpty(csvRecordData[3].trim()) && string.isEmpty(csvRecordData[4].trim()) && string.isEmpty(csvRecordData[5].trim()) 
           && string.isEmpty(csvRecordData[6].trim()) && string.isEmpty(csvRecordData[7].trim()) && string.isEmpty(csvRecordData[8].trim()) 
           && string.isEmpty(csvRecordData[9].trim()) && string.isEmpty(csvRecordData[10].trim()) && string.isEmpty(csvRecordData[11].trim())
           && string.isEmpty(csvRecordData[12].trim()) && string.isEmpty(csvRecordData[13].trim()) && string.isEmpty(csvRecordData[14].trim())
           && string.isEmpty(csvRecordData[15].trim()) && string.isEmpty(csvRecordData[16].trim()) && string.isEmpty(csvRecordData[17].trim()))
        {
            isEmptyRecord = true;
        }
        
        return isEmptyRecord;
    }
  
  /*************************************************************************************************************************
 @Name: cancel
 @Author: Shishir Bose
 @Created Date: 04/28/2016
 @Descripton: This method is called on clicking cancel button on VF page and takes the user back on agreement page
*************************************************************************************************************************/
    public PageReference cancel()
    {
        PageReference pageRef = new PageReference('/'+parentAgreement.Id);
        //pageRef.setredirect(true);
        
        return pageRef;
    }
    
    
    /*************************************************************************************************************************
 @Name: uploadNewDocument
 @Author: Shishir Bose
 @Created Date: 04/28/2016
 @Descripton: This method re sets the screen for uploading the new csv document
*************************************************************************************************************************/
    public void uploadNewDocument()
    {
        showGrid = 'none';
        showFileSelection = 'block';
        issuesToBeInserted = new List<Apttus_SRM__Issue__c>();
        issuesToBeUpdated = new List<Apttus_SRM__Issue__c>();
        issuesToBeDisplayed = new List<APTPS_IssuesWrapper>();
    }

    
    /*************************************************************************************************************************
 @Name: confirm
 @Author: Shishir Bose
 @Created Date: 04/28/2016
 @Descripton: This method updates or inserts the issues
*************************************************************************************************************************/

    public PageReference confirm()
    {
      try{
                PageReference pageRef = new PageReference('/'+parentAgreement.Id);
               
                if(issuesToBeUpdated.size() > 0)
                {
                    update issuesToBeUpdated;
                }
                
                
                if(issuesToBeInserted.size() > 0)
                {
                    insert issuesToBeInserted;
                }
                
                return pageRef;
         }
        catch (Exception e)
         {
            showGrid = 'none';
            showFileSelection = 'block';
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data. Please make sure that input csv file matches the format as described below.');
            ApexPages.addMessage(errorMessage);
            return null;
         }
    }
    
    /*************************************************************************************************************************
 @Name: populateIssue
 @Author: Shishir Bose
 @Created Date: 04/28/2016
 @Descripton: This method creates the list of issues for update or insert.
*************************************************************************************************************************/

    private Apttus_SRM__Issue__c populateIssue(Apttus_SRM__Issue__c existingIssue, string[] csvRecordData)
    {
        Apttus_SRM__Issue__c issue = new Apttus_SRM__Issue__c();
        Account[] customers = null;
        RecordType[] recordTypes = null;
        
         if(existingIssue != null)
         {
             issue = existingIssue;
         }
        else
        {
            issue.Apttus_SRM__Agreement__c = parentAgreement.Id;
        }
           
        issue.RecordTypeId = inheretRiskRecordTypeId;
        
        
          if(!string.isEmpty(csvRecordData[1]))
           {
               
                issue.APTPS_SOMP_Risk_Date__c = APTPS_CommonUtilities.setStringToDateFormat(csvRecordData[1]);
           }
           else
           {
               issue.APTPS_SOMP_Risk_Date__c = null;
           }
          
        
        issue.APTPS_SOMP_ID__c = integer.valueOf(csvRecordData[2]);
        issue.APTPS_Risk_Name__c = csvRecordData[3];
        issue.APTPS_Trigger__c = csvRecordData[4];
        issue.APTPS_Description__c = csvRecordData[5];
        issue.APTPS_Likely_Impact__c = csvRecordData[6];
        issue.APTPS_Issues_Owner__c = csvRecordData[7];
        issue.APTPS_Likelihood_Without_Controls__c = csvRecordData[8];
        issue.APTPS_Impact_Without_Controls__c = csvRecordData[9];
        issue.APTPS_Risk_Exposure_Without_Controls__c = csvRecordData[10];
        issue.APTPS_Response_WithoutControl__c = csvRecordData[11];
        issue.APTPS_Likelihood_With_Controls__c = csvRecordData[12];
        issue.APTPS_Impact_With_Controls__c = csvRecordData[13];
        issue.APTPS_Risk_Exposure_With_Controls__c = csvRecordData[14];
        issue.APTPS_Response_Type_With_Controls__c = csvRecordData[15];
        issue.APTPS_Mitigation__c = csvRecordData[16];       
        issue.APTPS_Flag__c = csvRecordData[17];
        issue.APTPS_Action_Status__c = 'In Progress';
        
           
          return issue;               
                   
    }
    
   
}