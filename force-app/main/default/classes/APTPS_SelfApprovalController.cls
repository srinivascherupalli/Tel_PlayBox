/*************************************************************************************************************************
 @Name: APTPS_SelfApprovalController
 @Author: Akanksha Trivedi
 @Created Date: 01/24/2017
 @Descripton: This controller is created for handling the self Approval of Agreement Clauses
 @Used By: APTPS_Init_SelfApproval VF page
*************************************************************************************************************************/
public with sharing class APTPS_SelfApprovalController
{
    public Apttus__APTS_Agreement__c parentAgreement{get;set;}
    public Id parentAgreementId{get;set;}
    public List<APTPS_AgreementClauseWrapper> agreementClauseWrapperList {get;set;}
    public List<Apttus__Agreement_Clause__c> selfApprovedClauseList {get;set;}
    public Map<ID,Apttus__Agreement_Clause__c> agreementClauseMap {get;set;}
    public APTPS_SelfApprovalController(ApexPages.StandardController  stdController)
   
    {  
        parentAgreementId = stdController.getId();
        parentAgreement = [select Id, Name from Apttus__APTS_Agreement__c where id=: parentAgreementId]; 
        agreementClauseWrapperList = new List<APTPS_AgreementClauseWrapper>();
        agreementClauseMap = new Map<ID,Apttus__Agreement_Clause__c>();
        List<Apttus__Agreement_Clause__c> clauseList= [select Id, Name,Approval_Status__c,Apttus__Clause__c,Apttus__Risk_Rating__c,APTPS_Self_Approved__c,Apttus__Text__c,
                              Apttus__PrevText__c,APTPS_Approval_Guidence__c,Apttus__Agreement__c,Apttus__Status__c,Apttus__Comments__c,APTPS_Non_Standard_Legal_Language__c, Apttus__DiffText2__c from Apttus__Agreement_Clause__c
                                                    where Apttus__Agreement__c=:parentAgreementId  and Approval_Status__c='Approval Required'
                                               order by createddate];
        for(Apttus__Agreement_Clause__c agrClause :clauseList)
         {                                   
           agreementClauseWrapperList.add(new APTPS_AgreementClauseWrapper(agrClause));
           agreementClauseMap.put(agrClause.id,agrClause);
         }
        selfApprovedClauseList= new List<Apttus__Agreement_Clause__c>();
    }
    
    public PageReference saveSelfApprovedClause()
   {
        try
        {   for(APTPS_AgreementClauseWrapper clause: agreementClauseWrapperList){
                Apttus__Agreement_Clause__c aggClause = agreementClauseMap.get(clause.Id);
                if(clause.selfApproved){
                    aggClause.Approval_Status__c='Approved';
                    aggClause.APTPS_Self_Approved__c=true;
                }
                aggClause.APTPS_Non_Standard_Legal_Language__c=clause.nonStandardLegalLanguage;
                selfApprovedClauseList.add(aggClause);
            }
            upsert selfApprovedClauseList;
            return cancel();
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());                
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,e.getMessage()));   
            return null;
        }
   }
    public PageReference cancel()
   {
        try
        {       
            PageReference pageRef = new PageReference('/home/home.jsp');
              pageRef = new PageReference('/'+parentAgreementId);        
              pageRef.setredirect(true);
              return pageRef;
        }catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
            return null;
        }
     }
    public class APTPS_AgreementClauseWrapper {
        public string Id {get; set;}
        public string Name {get; set;}
        public string approvalStatus {get; set;}
        public string clause {get; set;}
        public string riskRating {get; set;}
        public string text {get; set;}
        public string prevTextp {get; set;}
        public string comments {get; set;}
        public boolean selfApproved {get; set;}
        public string approvalGuidence {get; set;}
        public boolean nonStandardLegalLanguage {get; set;}
        public APTPS_AgreementClauseWrapper(Apttus__Agreement_Clause__c agreementClause)
        {

            Id = agreementClause.Id;
            Name = agreementClause.Name;
            approvalStatus = agreementClause.Approval_Status__c;
            clause = agreementClause.Apttus__Clause__c;
            riskRating = agreementClause.Apttus__Risk_Rating__c;
            text = agreementClause.Apttus__Text__c;
            //prevTextp = agreementClause.Apttus__PrevText__c;
            prevTextp = agreementClause.Apttus__DiffText2__c;            
            comments = agreementClause.Apttus__Comments__c;
            approvalGuidence = agreementClause.APTPS_Approval_Guidence__c;
            nonStandardLegalLanguage = agreementClause.APTPS_Non_Standard_Legal_Language__c;  
        }
     }
}