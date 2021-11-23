/*************************************************************
@Name: AgreementApprovalController
@Author: Akanksha Trivedi
@CreateDate: 1nd Feb 2017.
@Description: Controller is used in AgreementApprovalComponent
******************************************************************/
public class AgreementApprovalController { 
  public Apttus_Approval__Approval_Request__c approvalRequest{ get{
         
     List<Apttus_Approval__Approval_Request__c> approvalRequestList = [select id,name,Apttus_Approval__Related_Agreement__r.name,Apttus_Approval__Related_Agreement__r.Apttus__Status__c,
                            Apttus_Approval__Related_Agreement__c, Apttus_Approval__Related_Agreement__r.Apttus__Account__r.name ,
                            Apttus_Approval__Related_Agreement__r.Apttus__Description__c,Apttus_Approval__Related_Agreement__r.Apttus__FF_Agreement_Number__c,
                            Apttus_Approval__Related_Agreement__r.Apttus__Status_Category__c,Apttus_Approval__Related_Agreement__r.Apttus__Contract_Start_Date__c,
                            Apttus_Approval__Related_Agreement__r.Apttus__Total_Contract_Value__c ,Apttus_Approval__Related_Agreement_Owner__r.Name,
                            Apttus_Approval__Related_Agreement__r.APTPS_Comments_for_Billing__c,Apttus_Approval__Related_Agreement__r.Owner.Name,Apttus_Approval__Related_Agreement__r.Apttus__Contract_End_Date__c from Apttus_Approval__Approval_Request__c where id=: approvalRequest.id];       
         if(approvalRequestList.size()>0){
              approvalRequest = approvalRequestList[0];
         }
         return approvalRequest;
  }set; }
    
 public AgreementApprovalController(){
     } 
}