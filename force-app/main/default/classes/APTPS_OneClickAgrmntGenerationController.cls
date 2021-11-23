/**********************************************************************************************************************
 @Name: APTPS_OneClickAgrmntGenerationController
 @Author: Shishir Bose
 @Created Date: 04/12/2016
 @Descripton: This controller is created for handling the One Click Agreement Generattion functionality which helps in 
 generating more than one agreement attachment
 @Used By: APTS__Init_OneClickAgrmntGeneration VF page
*************************************************************************************************************************/
/**************************************************************************************************************  
@Author: Kunal Dixit  
@Modified Date: 12/10/2018  
@Descripton: Updated this controller to impose agreement protectoion dynamically for the MS Case#215879  
****************************************************************************************************************/ 
public with sharing class APTPS_OneClickAgrmntGenerationController {
 
    public List<APTPS_AgreementSelection> agreementListToBeDisplayed {get; set;}
    
    public map<Id, Apttus__APTS_Agreement__c> selectedAgreementList {get; set;}
    
    public Integer selectedAgreementListSize{get; set;}
    
    public List<string> selectedAgreementListIds {get; set;}
    public string agreementName{get;set;}
    
    public String generatedDocId;    
    //Getting the record type id
     public Id recordtypeid {get; set;}
    
    public List<Apttus__APTS_Agreement__c> agreementsToBeUpdated {get; set;}
        
    public Apttus__APTS_Agreement__c parentAgreement {get; set;}
    //Start of Changes for MS Case #00215879 (Added these lines)  
    private Apttus.AgreementGenerateController  theController;    
    public Apttus.AgreementGenerateController.ProtectionInfo  protectionInfo  { get; set; }    
    //End of Changes for MS Case #00215879 
    //This is the constructor of the class. Here we will store the agreement id for further operations
    public APTPS_OneClickAgrmntGenerationController(ApexPages.StandardController  stdController)
    {
        if(!test.isRunningTest()){ // added as addFields method is not Testable.
            stdController.addFields(new List<string>{'Name','Apttus__Status_Category__c', 'Apttus__Status__c'});
        }
      //Start of Changes for MS Case #00215879 (Added these lines)  
      theController = new Apttus.AgreementGenerateController(stdController);  
      //End of Changes for MS Case #00215879
      
        parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
        recordtypeid = parentAgreement.RecordTypeId;
        agreementName = parentAgreement.Name;
        agreementsToBeUpdated = new List<Apttus__APTS_Agreement__c>();
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
                                                            APTPS_Agreement_Subcategory__c,Apttus__Parent_Agreement__c,createddate, RecordTypeId, 
                                                            Apttus__Account__c
                                                            from Apttus__APTS_Agreement__c
                                                            where (Id =:parentAgreement.Id or Apttus__Parent_Agreement__c =:parentAgreement.Id)
                                                            and Apttus__Status_Category__c !=: APTPS_Constants.IN_EFFECT_STATUS_CATEGORY
                                                            and (Apttus__Status__c !=: APTPS_Constants.IN_EFFECT_STATUS and Apttus__Status_Category__c !=: APTPS_Constants.CANCELLED_STATUS_CATEGORY and Apttus__Status_Category__c != : APTPS_Constants.TERMINATED_STATUS_CATEGORY)
                                                            order by createddate])
                {
                    //Converting the agreement record into AgreementForGeneration wrapper class
                    agreementListToBeDisplayed.add(new APTPS_AgreementSelection(agrmnt));
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
     @Name: cancel
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method is called on clicking cancel button on VF page and takes the user back on agreement page
    *************************************************************************************************************************/
    public PageReference cancel()
    {
        PageReference pageRef = new PageReference('/'+parentAgreement.Id);
        //pageRef.setredirect(true);
        
        return pageRef;
    }
    
        
    /*************************************************************************************************************************
     @Name: cancelAndUpdate
     @Author: Shishir Bose
     @Created Date: 01/24/2017
     @Descripton: This method is called at the end of document generation
    *************************************************************************************************************************/
    public PageReference cancelAndUpdate()
    {
        PageReference pageRef = new PageReference('/'+parentAgreement.Id);
        //pageRef.setredirect(true);
        
        for(Apttus__APTS_Agreement__c agrmnt : agreementsToBeUpdated)
        {
            agrmnt.Apttus__Status_Category__c = APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY;
            agrmnt.Apttus__Status__c = APTPS_Constants.IN_AUTHOR_CONTRACT_STATUS;     
        }
        
        update agreementsToBeUpdated;    
        return pageRef;
    }
    
    
    
    /*************************************************************************************************************************
     @Name: createListForGenerateAgreements
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method is called on clicking generate button. It populates a list of selected agreement and kicks off 
     the agreement generation process
    *************************************************************************************************************************/
    public PageReference createListForGenerateAgreements()
    {
        try
        {
            Map<String, Apttus__APTS_Agreement__c> apptuAgreementAccountIdMap = new Map<String, Apttus__APTS_Agreement__c>(); //Added as part of  DIGI-33094 by Gautam Kumar
            selectedAgreementList = new map<Id, Apttus__APTS_Agreement__c>();
            selectedAgreementListIds = new List<string>();
            
            for(APTPS_AgreementSelection agrGen : agreementListToBeDisplayed)
            {
                //Adding the selected agreement to the list
                if(agrGen.selected == true)
                {
                    selectedAgreementList.put(agrGen.agreement.Id, agrGen.agreement);
                    selectedAgreementListIds.add(agrGen.agreement.Id);
                    apptuAgreementAccountIdMap.put(agrGen.agreement.Id, agrGen.agreement); //Added as part of  DIGI-33094 by Gautam Kumar
                }
            }
            
            system.debug('G*G apptuAgreementAccountIdMap '+ apptuAgreementAccountIdMap);
            //Added as part of  DIGI-33094 by Gautam Kumar
            if(!apptuAgreementAccountIdMap.isEmpty() && FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','beforelogsinsertion')
            && FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion')) insertTransactionLogs(apptuAgreementAccountIdMap);
            //Checking if any agreement is selected or not to send the error message on screen
            if(selectedAgreementList.size() == 0)
            {
                selectedAgreementListSize = 0;
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Please select atleast one record.'));
            }
            
            else
            {
                //Setting this variable helps in javascript to find out whether the generate agreement to be called or not
                selectedAgreementListSize = selectedAgreementList.size();
               
            }
            
            return null;
            
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
            return null;
        }
        
    }
    
    
    /*************************************************************************************************************************
     @Name: generateAgreementAsync
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method is called from the VF page. This method determines the correct template
     id and sends the agreementID, templateID and sessionID to generateAgreement method
    *************************************************************************************************************************/
    
    public void generateAgreementAsync()
    {
        try
        {
             Id templateId;
             String generatedDocId;
             
             string agreementId = String.valueOf(ApexPages.currentPage().getParameters().get('agreementId')).trim();
             
             
              id agrmtId = Id.valueOf(agreementId);
              Apttus__APTS_Agreement__c agreement = selectedAgreementList.get(Id.valueOf(agreementId));
              
              
            //BAsed on record type determine the template and call generateAgreement Method    
             APTPS_QueryTemplateUtil util = new APTPS_QueryTemplateUtil();
             templateId = util.getTemplateByQueryTemplates(agreement.Id);
             generateAgreement(agreement.Id, templateId);
            //Added under case 109622
            Apttus__APTS_Template__c templaterec=[select id, Apttus__ActiveVersionId__r.Apttus__VersionNumber__c,Apttus__ActiveVersionId__c from Apttus__APTS_Template__c where id=:templateId and Apttus__IsActive__c=true];
            Apttus__APTS_Agreement__c agrmtrec=[select id,APTPS_Template_Version__c from Apttus__APTS_Agreement__c where id=:agreement.Id];
           if(agrmtrec !=null){
            agrmtrec.APTPS_Template_Version__c=templaterec.Apttus__ActiveVersionId__c;
            upsert agrmtrec;
            }
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
        }
        
        
    }
    
    
    /*************************************************************************************************************************
     @Name: generateAgreement
     @Author: Shishir Bose
     @Created Date: 04/14/2016
     @Descripton: This method is called by generateAgreementAsync method. This method calls the generate method API
    *************************************************************************************************************************/
    
    @TestVisible private void generateAgreement(Id agreementId, Id templateId)
    {
        //Getting the session Id of the user
        String apiSessionId = UserInfo.getSessionId(); 
      
      //Start of Changes for MS Case #00215879  
      protectionInfo = theController.getProtectionInfoForAction(Apttus.AgreementGenerateController.ACTION_GENERATE);  
      //End of Changes for MS Case #00215879
      
        String pLevel = 'Insert comments and tracked changes only'; 
        String docFormat = 'DOCX'; 
        String apiServerURL = System.Url.getSalesforceBaseUrl(). toExternalForm() + APTPS_Constants.SOAP_API_ADDRESS + UserInfo.getOrganizationId(); 
        
        generatedDocId = null;
        Apttus__APTS_Agreement__c agreement;
        try
        {
            System.debug('Shishir Inside the method agreementId: '+ agreementId);
            agreement = selectedAgreementList.get(agreementId);
            
            System.debug('**Protection Level: '+ protectionInfo.ProtectionLevel);
            System.debug('Shishir Inside the method templateId: '+ templateId);
            
            if(!test.isRunningTest()){ //added temporatily
                //Start of Changes for MS Case #00215879 (Commented old line of code and added new one) 
          //generatedDocId = Apttus.MergeWebService.generateDoc2(templateId, agreementId, pLevel, docFormat, true, apiSessionId, apiServerURL);  
    
           generatedDocId = Apttus.MergeWebService.generateDoc2(templateId, agreementId, protectionInfo.ProtectionLevel, docFormat, false, apiSessionId, apiServerURL);  //For INC000095158163 changed waterMark variable to false
    
                //End of Changes for MS Case #00215879  
            }
            
            
            Attachment generatedAttachment =null;
           
            
            
            
            if(agreement.Apttus__Status_Category__c != 'Request' && agreement.Apttus__Status__c != 'Request')
            {
                generatedAttachment = [select id, Name from Attachment where id =:generatedDocId];
                if(generatedAttachment != null)
                {
                    if(generatedAttachment.Name.contains(APTPS_Constants.GENERATED_ATTACHMENT_ORIGINAL))
                    {
                        agreementName = generatedAttachment.Name;
                        agreementName = agreementName.replace(APTPS_Constants.GENERATED_ATTACHMENT_ORIGINAL,
                                                                APTPS_Constants.REGENERATED_ATTACHMENT_REGENERATED);
                        generatedAttachment.Name = agreementName;
                        update generatedAttachment;
                    }
                }
            }       
        }
        
        catch(CalloutException ex)
        {
            System.debug('Shishir Inside the method CalloutException: '+ agreement);
            agreementsToBeUpdated.add(agreement);        
        }
        catch(Exception ex)
        {
            System.debug('Shishir Inside the method SystemException: '+ agreement);
            System.debug('Bose generatedDocId ex: ' + ex);
        }
    }
    
    /*  
        * Method Name : insertTransactionLogs
        * Author : Gautam Kumar
        * Jira : DIGI-33094
       */
        
      public static void insertTransactionLogs(Map<String, Apttus__APTS_Agreement__c> apttusAgreementAccountIdMap)
      {
      
          system.debug('G*G insertTransactionLogs APTPS_OneClickAgrmntGenerationController outer called');
    
          for(String agreementId: apttusAgreementAccountIdMap.keySet()){
              if(apttusAgreementAccountIdMap.get(agreementId).Apttus__Account__c != null && String.isBlank(apttusAgreementAccountIdMap.get(agreementId).Apttus__Parent_Agreement__c)){
              system.debug('G*G insertTransactionLogs APTPS_OneClickAgrmntGenerationController inner called');
              string corId = apttusAgreementAccountIdMap.get(agreementId).Apttus__Account__c + '-' + agreementId;
              Map<String,Object> loggerdetailsMap=new Map<String,Object>();
              loggerdetailsMap.put('event','Legacy Contract generation initiated');
              loggerdetailsMap.put('AgreementType','Legacy');
              loggerdetailsMap.put('AgreementStatus',apttusAgreementAccountIdMap.get(agreementId).Apttus__Status__c);
              TransactionLogger.insertTransactionLogs(corId,loggerdetailsMap,'APTPS_OneClickAgrmntGenerationController');
              }
          }
          
          
         
    
      }
    
    
    }