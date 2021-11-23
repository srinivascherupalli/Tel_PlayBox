/*************************************************************************************************************************
@Name: APTPS_ImportFullySignedDocController
@Author: Shishir Bose
@Created Date: 05/16/2016
@Descripton: This class is used to import fully signed agreement after wet signatures
post the activated agreement to chatter
@Used By: APTPS_Init_ImportFullySignedDocument VF page
*************************************************************************************************************************/

public with sharing class APTPS_ImportFullySignedDocController {
    
    public string agreementName{get;set;}
    public Apttus__APTS_Agreement__c parentAgreement {get; set;}
    
    public Id bsaRecordtypeid {get; set;} 
    public Id panelRecordtypeid {get; set;}
    public String fileName {get; set;}
    public List<APTPS_AgreementSelection> agreementListToBeDisplayed {get; set;}
    
    //Creating the instance of Attachment for importing the fully signed document   
    //Public transient Attachment importedAttachment {get; set;}
    public Transient Blob importedAttachment {get; set;}
    //{get; set;}
    public Attachment  myDoc
    {
        get
        {
            if(myDoc==null)
            {
                myDoc = new Attachment();
                //myDoc = someTest;
            }
            return myDoc;
        }
        set;
    }
    
    /*************************************************************************************************************************
    @Name: Constructor for APTPS_ImportFullySignedDocController 
    @Author: Shishir Bose
    @Created Date: 05/16/2016
    @Descripton: This constructor gets the Parent agreement data. And sets the record type for BSA and Panel agreements for
    further processing
    *************************************************************************************************************************/ 
    public APTPS_ImportFullySignedDocController(ApexPages.StandardController  stdController)
    {
        if(!Test.isRunningTest()){
        stdController.addFields(new List<string>{'Name','Apttus__Status_Category__c','Apttus__Status__c'});
    }
        parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
        
        agreementName = parentAgreement.Name;
        
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Apttus__APTS_Agreement__c' and Name = 'SA' LIMIT 1];
        bsaRecordtypeid = rt.Id;
        
        rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Apttus__APTS_Agreement__c' and Name = 'Panel' LIMIT 1];
        panelRecordtypeid = rt.Id;
        
    }
    
    
        /*************************************************************************************************************************
     @Name: getAgreements
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method returns the list of Child agreements along with the parent agreement for displaying on the screen
    *************************************************************************************************************************/
    public List<APTPS_AgreementSelection> getAgreements()
    {
        try
        {
            if(agreementListToBeDisplayed == null)
            {
                agreementListToBeDisplayed = new List<APTPS_AgreementSelection>();

                for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c, 
                                                            Apttus__Status__c,  Apttus__Agreement_Category__c,  Apttus__Subtype__c,
                                                            APTPS_Agreement_Subcategory__c,Apttus__Parent_Agreement__c,createddate, RecordTypeId 
                                                            from Apttus__APTS_Agreement__c
                                                            where Apttus__Parent_Agreement__c =:parentAgreement.Id
                                                            and (Apttus__Status_Category__c =: APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY
                                                            or Apttus__Status_Category__c =: APTPS_Constants.IN_SIGNATURES_STATUS_CATEGORY)
                                                            order by createddate])
                {
                    //Converting the agreement record into AgreementForGeneration wrapper class
                    agreementListToBeDisplayed.add(new APTPS_AgreementSelection(agrmnt));
					system.debug('agreementListToBeDisplayed@@@'+agreementListToBeDisplayed);
                }
            }

            return agreementListToBeDisplayed;
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
            return null;
        }


    }
    
    /*************************************************************************************************************************
    @Name: import
    @Author: Shishir Bose
    @Created Date: 05/16/2016
    @Descripton: This method validates the data and required fields, then calls method to update the parent and 
    child(In case of panel and BSA) fields and create tasks.
    *************************************************************************************************************************/ 
    public PageReference import()
    {
       try
        {    
            if(parentAgreement.Apttus__Company_Signed_Date__c == null && fileName == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Company signed date is mandatory.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Select fully signed agreement for upload.'));
                myDoc.body = null;
                myDoc = new Attachment();
                return null;
            }
            else if(parentAgreement.Apttus__Company_Signed_Date__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Company signed date is mandatory.'));
                myDoc.body = null;            
                myDoc = new Attachment();
                return null;
            }
            else if(fileName == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Select fully signed agreement for upload.'));
                myDoc.body = null;
                myDoc = new Attachment();
                return null;    
            }

            
            
            //Method call for agreement data update and task creation
            performActionOnAgreements();

            if(importedAttachment != null)
            {
                Attachment attach = new Attachment();
                attach.Body = importedAttachment;
                attach.Name = fileName;
                //attach.ContentType= contentType;
                attach.ParentId = parentAgreement.id;   
                insert attach;                
            }           
            
            PageReference pageRef = cancel();
            return pageRef;
            
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
            myDoc.body = null;
            myDoc = new Attachment();
            return null;             
        }
        
    }
    
    /*************************************************************************************************************************
    @Name: performActionOnAgreements
    @Author: Shishir Bose
    @Created Date: 05/16/2016
    @Descripton: This method creates the list of child agreements in case of Panel and BSA for further processing
    *************************************************************************************************************************/ 
    private void performActionOnAgreements()
    {   
        //romil.anand fixed sonar bug by assigning default value null to variable child agreements
                                Apttus__APTS_Agreement__c[] childAgreements=null;
        Apttus__APTS_Agreement__c childAgreement;
        if(parentAgreement.RecordTypeId == bsaRecordtypeid || parentAgreement.RecordTypeId == panelRecordtypeid)
        {
            childAgreements = new List<Apttus__APTS_Agreement__c>();
                                                List<Id> lstChildAgreementId = new List<Id>();
            for(APTPS_AgreementSelection selectedChildAgreement : agreementListToBeDisplayed)
            {
                system.debug('selectedChildAgreement@@@@@'+selectedChildAgreement);
               if(selectedChildAgreement.selected == true)
                {
                                                                
                                                                                lstChildAgreementId.add(selectedChildAgreement.agreement.Id);
                    /*
                                                                                childAgreement = new Apttus__APTS_Agreement__c();
                    childAgreement = [select Id, Name, Apttus__Status_Category__c, Apttus__Status__c, APTPS_Other_Party_Signed_By__c,
                                      Apttus__Other_Party_Signed_Date__c, APTPS_Company_Signed_By__c, Apttus__Company_Signed_Date__c 
                                      from Apttus__APTS_Agreement__c where Id =: selectedChildAgreement.agreement.Id];
                                                                                                                                                  
                    //system.debug('childAgreement@@@'+childAgreement);
                    if(childAgreement != null)
                    {
                        childAgreements.add(childAgreement);                        
                    }
                                                                                */
                }
            }
                                                List <Apttus__APTS_Agreement__c> lstQueriedChildAgreement = [select Id, Name, Apttus__Status_Category__c, Apttus__Status__c, APTPS_Other_Party_Signed_By__c,
                                      Apttus__Other_Party_Signed_Date__c, APTPS_Company_Signed_By__c, Apttus__Company_Signed_Date__c 
                                      from Apttus__APTS_Agreement__c where Id IN: lstChildAgreementId]; 
            
            updateAgreementAndCreateTask(parentAgreement, lstQueriedChildAgreement);
        
        }
         //system.debug('childAgreements#####'+lstQueriedChildAgreement);
        // updateAgreementAndCreateTask(parentAgreement, lstQueriedChildAgreement);
        
    }

    /*************************************************************************************************************************
    @Name: updateAgreementAndCreateTask
    @Author: Shishir Bose
    @Created Date: 05/16/2016
    @Descripton: This method updates the parent and child records and calls method to create tasks
    *************************************************************************************************************************/ 
    private void updateAgreementAndCreateTask(Apttus__APTS_Agreement__c parentAgreement, Apttus__APTS_Agreement__c[] childAgreements)
    {
        parentAgreement.Apttus__Status_Category__c = 'In Signatures';
        parentAgreement.Apttus__Status__c = 'Fully Signed';
        List<Apttus__APTS_Agreement__c> updateChildAgreements=new List<Apttus__APTS_Agreement__c>();
        List<Apttus__APTS_Agreement__c> updateParentAgreement=new List<Apttus__APTS_Agreement__c>();
        
        if(childAgreements!=null && childAgreements.size() > 0)
        {
            for(Apttus__APTS_Agreement__c agreement : childAgreements)
            {
                agreement.Apttus__Status_Category__c = 'In Signatures';
                agreement.Apttus__Status__c = 'Fully Signed';
                
                agreement.APTPS_Other_Party_Signed_By__c = parentAgreement.APTPS_Other_Party_Signed_By__c;
                agreement.Apttus__Other_Party_Signed_Date__c = parentAgreement.Apttus__Other_Party_Signed_Date__c;
                agreement.APTPS_Company_Signed_By__c = parentAgreement.APTPS_Company_Signed_By__c;
                agreement.Apttus__Company_Signed_Date__c = parentAgreement.Apttus__Company_Signed_Date__c;
                
                updateChildAgreements.add(agreement);
                
            }
            if(updateChildAgreements.size() >0)
            {
                
            createTask(updateChildAgreements);
            update updateChildAgreements;
            }
        }
        updateParentAgreement.add(parentAgreement);
        createTask(updateParentAgreement);
        
        update parentAgreement;
        
    }
    
    /*************************************************************************************************************************
    @Name: createTask
    @Author: Shishir Bose
    @Created Date: 05/16/2016
    @Descripton: This method creates task
    *************************************************************************************************************************/ 
    private void createTask(List<Apttus__APTS_Agreement__c> childAgreements)
    {
        List<Task> importSignedAgreementTasks = new List<Task>();
        for(Apttus__APTS_Agreement__c agreement : childAgreements){
            Task importSignedAgreementTask = new Task();
            importSignedAgreementTask.WhatId = agreement.id;
            importSignedAgreementTask.Subject = 'Imported Fully Signed Document';   
            importSignedAgreementTask.status = 'Completed';
            importSignedAgreementTask.description = 'Fully Signed Document imported after wet signatures';
            importSignedAgreementTask.ActivityDate = Date.today();
            importSignedAgreementTasks.add(importSignedAgreementTask);
        }
        if(importSignedAgreementTasks.size() >0){
        	insert importSignedAgreementTasks;
        }
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
}