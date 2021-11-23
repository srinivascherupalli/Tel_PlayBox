public with sharing class APTPS_AmendmentViewController {

    Public List<Apttus__APTS_Agreement__c> ListOfAggrement{get;set;}
    Public Apttus__APTS_Agreement__c CurrentAgreement{get; set;}
    Public String View {get; set;}
    Public List<Apttus__APTS_Agreement__c> ListOfParentAggrements{get;set;}
    //Private id OriginalId;
    public List<APTPS_AgreementSelection> agreementListToBeDisplayed {get; set;}
    public APTPS_AmendmentViewController(ApexPages.StandardController controller) {
            
            CurrentAgreement= (Apttus__APTS_Agreement__c) Controller.GetRecord();
    }
    
    
    public List<APTPS_AgreementSelection> getAgreements()
    {
        List<Id> ListOfRelatedIds=new List<ID>();
        agreementListToBeDisplayed = new List<APTPS_AgreementSelection>(); 
        View='';
        ID CurrentID=CurrentAgreement.ID;    
            
            FOR (Apttus__APTS_Related_Agreement__c RelatedAgreement:[Select Apttus__APTS_Contract_From__c,Apttus__APTS_Contract_To__c 
                                        From Apttus__APTS_Related_Agreement__c where Apttus__APTS_Contract_From__c=:CurrentAgreement.Id]){
                  
                          ListOfRelatedIds.Add(RelatedAgreement.Apttus__APTS_Contract_To__c);
                                        
                 }
                 
            If(ListOfRelatedIds.size()<=0){
              
                     FOR (Apttus__APTS_Related_Agreement__c RelatedAgreement:[Select Apttus__APTS_Contract_From__c,Apttus__APTS_Contract_To__c 
                                        From Apttus__APTS_Related_Agreement__c where Apttus__APTS_Contract_To__c =:CurrentAgreement.Id]){

                          CurrentID=RelatedAgreement.Apttus__APTS_Contract_From__c;
                          ListOfRelatedIds.Add(RelatedAgreement.Apttus__APTS_Contract_To__c);
                                        
                 }
             }
             
           
                                     
           List<Apttus__APTS_Agreement__c> TemporaryListOfAggrement =  new List<Apttus__APTS_Agreement__c>();
           
           If(ListOfRelatedIds.size() > 0)
           {
               TemporaryListOfAggrement=[Select Id,Apttus__FF_Agreement_Number__c, Apttus__Agreement_Number__c,Name,Apttus__Contract_Start_Date__c,
                                    Apttus__Contract_End_Date__c,Apttus__Total_Contract_Value__c,
                                    Apttus__Auto_Renewal__c,Apttus__Internal_Renewal_Notification_Days__c,Apttus__Term_Months__c, Apttus__Parent_Agreement__c 
                                    From Apttus__APTS_Agreement__c  where ID in:ListOfRelatedIds];
                                    
           }
        
           
           
           
           
           //Child agreements
            for(Apttus__APTS_Agreement__c agrmnt : [Select Id,Apttus__FF_Agreement_Number__c, Apttus__Agreement_Number__c,Name,Apttus__Contract_Start_Date__c,
                                                    Apttus__Contract_End_Date__c,Apttus__Total_Contract_Value__c,
                                                    Apttus__Auto_Renewal__c,Apttus__Internal_Renewal_Notification_Days__c,Apttus__Term_Months__c,Apttus__Parent_Agreement__c 
                                                    From Apttus__APTS_Agreement__c
                                                    where Id =:CurrentID or Apttus__Parent_Agreement__c =:CurrentID
                                                    order by createddate])
            {
                  agreementListToBeDisplayed.add(new APTPS_AgreementSelection(agrmnt, 'Original'));
            }
           
           
           for(Apttus__APTS_Agreement__c Aggr:TemporaryListOfAggrement)
           {
               agreementListToBeDisplayed.add(new APTPS_AgreementSelection(Aggr, 'Amendment'));
           }
               
       
          return agreementListToBeDisplayed;
        
        
    }
    Public Void View1(){
        
       View ='View1';
    }
   Public Void View2(){
        
       View ='View2';
    }
   Public PageReference GoBack(){
        
       Pagereference PR=new PageReference('/'+ CurrentAgreement.Id);
       PR.SetRedirect(True);
       Return PR;
    }  
    
}