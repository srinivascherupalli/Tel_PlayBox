/****************************************************************************************************************
 @Name: APTPS_AgreementGenerationController
 @Author: Shishir Bose
 @Created Date: 04/12/2016
 @Descripton: This controller is created for handling the One Click Agreement Generattion functionality which helps in 
 generating more than one agreement attachment
 @Used By: APTS__Init_OneClickAgrmntGeneration VF page
*********************************************************************************************************/
public with sharing class APTPS_AgreementGenerationController {
 
public List<TemplateWrapper> templateListToBeDisplayed {get; set;}

public string agreementName{get;set;}

public String generatedDocId{get;set;}    
//Getting the record type id
public Id recordtypeid {get; set;}

public List<Apttus__APTS_Agreement__c> agreementsToBeUpdated {get; set;}
    
public Apttus__APTS_Agreement__c parentAgreement {get; set;}
public Id selectedEmailTemplateId {get; set;}
public string actionName{get;set;}
//This is the constructor of the class. Here we will store the agreement id for further operations
public APTPS_AgreementGenerationController(ApexPages.StandardController  stdController)
{
    if(!test.isRunningTest()){ // added as addFields method is not Testable.
        stdController.addFields(new List<string>{'Name','Apttus__Status_Category__c', 'Apttus__Status__c','Apttus__Subtype__c','Apttus__Version_Number__c'});
    }
    
    actionName = ApexPages.currentPage().getParameters().get('actionName');
    parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
    recordtypeid = parentAgreement.RecordTypeId;
    agreementName = parentAgreement.Name;
    agreementsToBeUpdated = new List<Apttus__APTS_Agreement__c>();
    selectedEmailTemplateId = null;
    generatedDocId = null;
}




/*************************************************************************************************************************
 @Name: getTemplates
 @Author: Shishir Bose
 @Created Date: 03/06/2017
 @Descripton: This method returns the list of templates for displaying on the screen
*************************************************************************************************************************/
public List<TemplateWrapper> getTemplates()
{
    try
    {
        if(templateListToBeDisplayed == null)
        {   
            templateListToBeDisplayed = new List<TemplateWrapper>();
            List<Apttus__APTS_Template__c> templates=null;//EDGE-69042 Sonar fix
                  
            if(('Supporting').equalsIgnoreCase(actionName))
            { 
                Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
                Id panelRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
                Id scheduleRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Schedule').getRecordTypeId();

                if(recordtypeid == saRecordTypeId || recordtypeid == panelRecordTypeId)
                {                
                    string agreementType=null; //EDGE-69042 Sonar fix
                    if(recordtypeid == saRecordTypeId)
                    {
                        agreementType = 'SA';
                    }
                    else
                    {
                        agreementType = 'Panel';
                    }
                    if(parentAgreement.Apttus__Version_Number__c > 0)
                    {                        
                        templates = [select Id, Name, Apttus__Category__c, Apttus__Subcategory__c, Apttus__Type__c, Apttus__Guidance__c, Apttus__Agreement_Types__c from Apttus__APTS_Template__c
                        where Apttus__Agreement_Types__c =: agreementType and Apttus__Type__c = 'Supporting Document' and Apttus__Keywords__c = 'Variation'];
                    }
                    else
                    {                       
                        templates = [select Id, Name, Apttus__Category__c, Apttus__Subcategory__c, Apttus__Type__c, Apttus__Guidance__c, Apttus__Agreement_Types__c from Apttus__APTS_Template__c
                        where Apttus__Agreement_Types__c =: agreementType and Apttus__Type__c = 'Supporting Document' and Apttus__Keywords__c != 'Variation'];
                    }
                }
                else if(recordtypeid == scheduleRecordTypeId)
                {
                    if(parentAgreement.Apttus__Version_Number__c > 0)
                    {
                        templates = [select Id, Name, Apttus__Category__c, Apttus__Subcategory__c, Apttus__Type__c, Apttus__Guidance__c, Apttus__Agreement_Types__c from Apttus__APTS_Template__c
                        where Apttus__Agreement_Types__c = 'Schedule' and Apttus__Type__c = 'Supporting Document' and Apttus__Keywords__c = 'Variation' and 
                        (Apttus__Subcategory__c = 'Variation' or Apttus__Subcategory__c =: parentAgreement.Apttus__Subtype__c)];
                    }
                    else
                    {
                        templates = [select Id, Name, Apttus__Category__c, Apttus__Subcategory__c, Apttus__Type__c, Apttus__Guidance__c, Apttus__Agreement_Types__c from Apttus__APTS_Template__c
                        where Apttus__Agreement_Types__c = 'Schedule' and Apttus__Type__c = 'Supporting Document' and Apttus__Keywords__c != 'Variation' and 
                        Apttus__Subcategory__c =: parentAgreement.Apttus__Subtype__c];
                    }
                }
            }
            else            
            {
               //BAsed on record type determine the template and call generateAgreement Method    
                APTPS_QueryTemplateUtil util = new APTPS_QueryTemplateUtil();
                templates = util.getAllTemplatesByQueryTemplates(parentAgreement.Id);
            }
            
          
            if(templates != null)
            {
            
                for(Apttus__APTS_Template__c template : templates)
                {
                    //Converting the templates record into TemplateWrapper class
                    templateListToBeDisplayed.add(new TemplateWrapper(template));
                }
            }
        }
       
        return templateListToBeDisplayed;
    }
    catch(Exception e)
    {
        System.debug('CaLMs System exception caught: ' + e.getMessage());  
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
        return null;
    }
    
}

/*************************************************************************************************************************
 @Name: getSelected
 @Author: Shishir Bose
 @Created Date: 03/06/2017
 @Descripton: This method sets the template Id
*************************************************************************************************************************/
 public void getSelected() 
{
  selectedEmailTemplateId = ApexPages.currentPage().getParameters().get('selectedEmailTemplateid');       
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
 @Name: generateAgreement
 @Author: Shishir Bose
 @Created Date: 03/06/2017
 @Descripton: This method is called from the VF page. This method calls the generate action
*************************************************************************************************************************/

public PageReference generateAgreement()
{
    try
    {
        if(selectedEmailTemplateId == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Please select atleast one template.'));
            return null;
        }
        
        generate();
        return cancelAndUpdate();
        
    }
    catch(Exception e)
    {
        System.debug('CaLMs System exception caught: ' + e.getMessage());  
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
        return null;
    }
    
    
}

/*************************************************************************************************************************
 @Name: generate
 @Author: Shishir Bose
 @Created Date: 03/06/2017
 @Descripton: This method is called by generateAgreementAsync method. This method calls the generate method API
*************************************************************************************************************************/

@TestVisible private void generate()
{
    //Getting the session Id of the user
    String apiSessionId = UserInfo.getSessionId(); 
    String pLevel = 'Insert comments and tracked changes only'; 
    String docFormat = 'DOCX'; 
    String apiServerURL = System.Url.getSalesforceBaseUrl(). toExternalForm() + APTPS_Constants.SOAP_API_ADDRESS + UserInfo.getOrganizationId(); 
    
    
    Apttus__APTS_Agreement__c agreement = parentAgreement;
    try
    {
        if(!test.isRunningTest()){ //added temporatily
            generatedDocId = Apttus.MergeWebService.generateDoc2(selectedEmailTemplateId, parentAgreement.Id, pLevel, docFormat, false, apiSessionId, apiServerURL);//For INC000095158163 changed waterMark variable to false 
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
    //Added under case 109622
        Apttus__APTS_Template__c templaterec=[select id, Apttus__ActiveVersionId__r.Apttus__VersionNumber__c,Apttus__ActiveVersionId__c from Apttus__APTS_Template__c where id=:selectedEmailTemplateId and Apttus__IsActive__c=true];
        Apttus__APTS_Agreement__c agrmtrec=[select id,APTPS_Template_Version__c from Apttus__APTS_Agreement__c where id=:parentAgreement.Id];
        if(agrmtrec !=null){
        agrmtrec.APTPS_Template_Version__c=templaterec.Apttus__ActiveVersionId__c;
        update agrmtrec;
        }
}

public class TemplateWrapper
   {
       public Apttus__APTS_Template__c docTemplate{get; set;}

       //This field helps in determining whether the agreement is selected or not
       public Boolean selected{get; set;}
       
       public TemplateWrapper(Apttus__APTS_Template__c template)
       {
           docTemplate = template;
           selected = false;
       }
   } 


}