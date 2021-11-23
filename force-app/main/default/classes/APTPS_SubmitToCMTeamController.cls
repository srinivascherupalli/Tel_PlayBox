public with sharing class APTPS_SubmitToCMTeamController
{
    public Apttus__APTS_Agreement__c parentAgreement {get; set;}
    public APTPS_SubmitToCMTeamController(ApexPages.StandardController  stdController)
    {
        if(!test.isRunningTest()){ // added as addFields method is not Testable.
            stdController.addFields(new List<string>{'Apttus__Account__c'});
        }
        parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();        
    }
    
    public PageReference changeOwner()
    {
       Account agreementAccount = [select Id, APTPS_Contract_Manager__c, APTPS_Tier__c from Account where Id =: parentAgreement.Apttus__Account__c  ];
       List<Apttus__APTS_Agreement__c> agreementsToBeUpdated = new List<Apttus__APTS_Agreement__c>();
       Group[] ccoCentral = [Select Id from Group where Type = 'Queue' AND Name = 'CCO Central'];
        
        for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, OwnerId from Apttus__APTS_Agreement__c
                                                    where (Id =:parentAgreement.Id or Apttus__Parent_Agreement__c =:parentAgreement.Id)
                                                	])
        {
            
            if(agreementAccount.APTPS_Tier__c == '3')
            {
                //Owner is CCO Central Queue
                if(!ccoCentral.isEmpty())
                {
                   agrmnt.OwnerId = ccoCentral[0].Id; 
                   agrmnt.Is_submitted_to_CM__c = TRUE;
                }
            }
            else if(agreementAccount.APTPS_Tier__c == '1' || agreementAccount.APTPS_Tier__c == '2')
            {
                //Owner is Contract Manager
                if(agreementAccount.APTPS_Contract_Manager__c != null)
                {
                    agrmnt.OwnerId = agreementAccount.APTPS_Contract_Manager__c;
                    agrmnt.Is_submitted_to_CM__c = TRUE;
                }
            }
            
            agreementsToBeUpdated.add(agrmnt);
        }
        
        if(agreementsToBeUpdated.size() > 0)
        {
            update agreementsToBeUpdated;
        }
        
        
        PageReference pageRef = new PageReference('/'+parentAgreement.Id);
        
        return pageRef;
    }

}