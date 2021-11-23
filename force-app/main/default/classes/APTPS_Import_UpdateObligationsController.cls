/*************************************************************************************************************************
@Name: APTPS_Import_UpdateObligationsController
@Author: Shishir Bose
@Created Date: 04/28/2016
@Descripton: This controller is created for importing/updating obligations from a CSV file
@Used By: APTPS_Init_ImportObligations VF page
*************************************************************************************************************************/
public class APTPS_Import_UpdateObligationsController {
    
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<Apttus_SRM__SRMObligation__c> obligationsToBeInserted{get;set;}
    public List<Apttus_SRM__SRMObligation__c> obligationsToBeUpdated{get;set;}
    public string agreementName{get;set;}
    public Apttus__APTS_Agreement__c parentAgreement {get; set;}
    public List<APTPS_ObligationWrapper> obligationsToBeDisplayed {get; set;}
    
    //showGrid and showFileSelection: This variables are used to hide/show the file selection section and data grid section
    public string showGrid {get; set;}
    public string showFileSelection {get; set;}
    public string errorMessage{get; set;}
    public APTPS_Import_UpdateObligationsController(){
        
    }
    
    
    public APTPS_Import_UpdateObligationsController(ApexPages.StandardController stdController){
        if(!Test.isRunningTest()){
            stdController.addFields(new List<string>{'Name','Apttus__Status_Category__c', 'Apttus__Status__c'});
        }
        parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
        agreementName = parentAgreement.Name;
        csvFileLines = new String[]{};
            showGrid = 'none';
        showFileSelection = 'block';
    }
    
    /*************************************************************************************************************************
    @Name: importUpdateCSVFile
    @Author: Shishir Bose
    @Created Date: 04/28/2016
    @Descripton: This method creates the list of obligations to be updated or inserted
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
                
                obligationsToBeInserted = new List<Apttus_SRM__SRMObligation__c>();
                obligationsToBeUpdated = new List<Apttus_SRM__SRMObligation__c>();
                Map<string,Apttus_SRM__SRMObligation__c> existingObligations = new Map<string,Apttus_SRM__SRMObligation__c>();
                Apttus_SRM__SRMObligation__c existingObligationRecord;
                Apttus_SRM__SRMObligation__c obligation;
                obligationsToBeDisplayed = new List<APTPS_ObligationWrapper>();
                
                for(Apttus_SRM__SRMObligation__c exstgOblg :  [select Id, Name, Apttus_SRM__AgreementId__c from Apttus_SRM__SRMObligation__c where 
                                                                                Apttus_SRM__AgreementId__c  =:parentAgreement.Id])
                {
                    
                    existingObligations.put(exstgOblg.Name, exstgOblg);
                }
                //Iterate through each row in the file and if the obligation exist put in the update list and if not in the insert list     
                for(Integer i = 1;i < csvFileLines.size();i++){
                    
                    string[] csvRecordData = csvFileLines[i].split(',');
                    
                    if(checkEmptyRow(csvRecordData))
                    {
                        continue;
                    }
                    obligation = new Apttus_SRM__SRMObligation__c() ;
                    
                    //See if the obligation exist for the agreement
                    if(existingObligations.get(csvRecordData[0]) != null)
                    {
                       
                        existingObligationRecord = existingObligations.get(csvRecordData[0]);
                    }
                    else
                    {
                        existingObligationRecord = null;
                    }
                    
                    obligation = populateObligation(existingObligationRecord, csvRecordData);
                    
                    if(obligation == null)
                    {
                        if(errorMessage != null)
                        {
                            ApexPages.Message errorMessage0 = new ApexPages.Message(ApexPages.severity.ERROR,errorMessage);
                            ApexPages.addMessage(errorMessage0);
                        }
                        else
                        {
                            ApexPages.Message errorMessage1 = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data. Please make sure that input csv file matches the format as described below.');
                            ApexPages.addMessage(errorMessage1);
                        }
                        
                        uploadNewDocument();
                        return;
                    }
                    
                    if(existingObligationRecord != null)
                    {
                        obligationsToBeUpdated.add(obligation);
                    }
                    else
                    {
                        obligationsToBeInserted.add(obligation);
                    }
                    
                    obligationsToBeDisplayed.add(new APTPS_ObligationWrapper(csvRecordData, existingObligationRecord, parentAgreement.Id));
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
           && string.isEmpty(csvRecordData[12].trim()))
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
@Name: confirm
@Author: Shishir Bose
@Created Date: 04/28/2016
@Descripton: This method updates or inserts the obligations
*************************************************************************************************************************/
    
    public PageReference confirm()
    {
        try{
            PageReference pageRef = new PageReference('/'+parentAgreement.Id);
            //pageRef.setredirect(true);
            
            
            if(obligationsToBeUpdated.size() > 0)
            {
                update obligationsToBeUpdated;                
            }
            
            
            if(obligationsToBeInserted.size() > 0)
            {
                insert obligationsToBeInserted;
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
@Name: uploadNewDocument
@Author: Shishir Bose
@Created Date: 04/28/2016
@Descripton: This method re sets the screen for uploading the new csv document
*************************************************************************************************************************/
    public void uploadNewDocument()
    {
        showGrid = 'none';
        showFileSelection = 'block';
        obligationsToBeInserted = new List<Apttus_SRM__SRMObligation__c>();
        obligationsToBeUpdated = new List<Apttus_SRM__SRMObligation__c>();
        obligationsToBeDisplayed = new List<APTPS_ObligationWrapper>();
    }
    
    
    
    /*************************************************************************************************************************
@Name: populateObligation
@Author: Shishir Bose
@Created Date: 04/28/2016
@Descripton: This method creates the list of obligation for update or insert.
*************************************************************************************************************************/
    
    private Apttus_SRM__SRMObligation__c populateObligation(Apttus_SRM__SRMObligation__c existingObligation, string[] csvRecordData)
    {
        Apttus_SRM__SRMObligation__c obligation = new Apttus_SRM__SRMObligation__c();
        string likeClause;
        errorMessage = null;
        Apttus__Agreement_Clause__c[] agreementClauses;
        
        if(existingObligation != null)
        {
            obligation = existingObligation;
        }
        else
        {
            obligation.Apttus_SRM__AgreementId__c = parentAgreement.Id;
        }
        
        //obligation = existingObligations[0];
        //obligation.APTPS_Agreement_Clause__c = csvRecordData[1];
        /*if(!string.isEmpty(csvRecordData[1]))
        {
            likeClause = '%' + csvRecordData[1];
            agreementClauses = [select Id, Name from Apttus__Agreement_Clause__c where Apttus__Agreement__c =: parentAgreement.Id and Name like :likeClause ];
            
            if(Test.isRunningTest()){
                Apttus__APTS_Template__c tempRecord = APTPS_TestClassData.templateRecord('ObligationsTest', 'Clause');
                Apttus__Agreement_Clause__c agmtClause = APTPS_TestClassData.agreementClauseRecord(parentAgreement.id, tempRecord.id);
                agreementClauses.add(agmtClause);
            }
            
            if(agreementClauses.size() > 0)
            {
                obligation.APTPS_Clause_Name__c = agreementClauses[0].Id;
            }
            else
            {
                errorMessage = 'The agreement clause number do not match. Please correct it and try to re import.';
                return null;
            }
        }*/
        
        obligation.APTPS_Clause_Name__c = csvRecordData[1];
        obligation.APTPS_Category__c = csvRecordData[2];
        obligation.APTPS_Sub_Category__c = csvRecordData[3];
        obligation.Apttus_SRM__Description__c = csvRecordData[4];
        //obligation.APTPS_Due_Date__c = Date.parse(csvRecordData[5]);
        obligation.APTPS_Obligation_Frequency__c = csvRecordData[6];
        obligation.Apttus_SRM__Comments__c = csvRecordData[7];
        obligation.Apttus_SRM__Responsible__c = csvRecordData[8];
        obligation.Apttus_SRM__Accountable__c = csvRecordData[9];
        obligation.Apttus_SRM__Consulted__c = csvRecordData[10];
        obligation.Apttus_SRM__Informed__c = csvRecordData[11];
		obligation.APTPS_Status__c= csvRecordData[12];
		obligation.APTPS_Approval_Required__c= csvRecordData[13];
		obligation.APTPS_Responsible__c= csvRecordData[14];
        
        if(!string.isEmpty(csvRecordData[5]))
        {
            
            obligation.APTPS_Due_Date__c = APTPS_CommonUtilities.setStringToDateFormat(csvRecordData[5]);
        }
        else
        {
            obligation.APTPS_Due_Date__c = null;
        }
        
        return obligation;               
        
    }
}