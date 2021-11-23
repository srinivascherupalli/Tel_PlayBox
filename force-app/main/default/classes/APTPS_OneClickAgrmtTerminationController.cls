/*************************************************************************************************************************
 @Name: APTPS_OneClickAgrmtTerminationController
 @Author: Shishir Bose
 @Created Date: 07/11/2016
 @Descripton: This controller is created for displaying the list of child agreements. To let user know that they will be terminated alongwith
 parent agreement
 @Used By: APTS__Init_OneClickAgreementTermination VF page
*************************************************************************************************************************/
public with sharing class APTPS_OneClickAgrmtTerminationController
{
    public List<APTPS_AgreementSelection> agreementListToBeDisplayed {get; set;}
    
    public Apttus__APTS_Agreement__c parentAgreement {get; set;}
    public string agreementName{get;set;}
    //This is the constructor of the class. Here we will store the agreement id for further operations
    public APTPS_OneClickAgrmtTerminationController(ApexPages.StandardController  stdController)
    {
        if(!test.isRunningTest()){ // added as addFields method is not Testable.
            stdController.addFields(new List<string>{'Name','Apttus__Status_Category__c', 'Apttus__Status__c'});
        }
        parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();    
        agreementName = parentAgreement.Name;
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
                                                            where Apttus__Parent_Agreement__c =:parentAgreement.Id AND Apttus__Status__c <>'Terminated' 
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
    
    public PageReference confirmTermination()
    {
        PageReference pageRef = new PageReference('/apex/Apttus__AgreementTerminate?id='+parentAgreement.Id);
        //pageRef.setredirect(true);

        return pageRef;
    }

}