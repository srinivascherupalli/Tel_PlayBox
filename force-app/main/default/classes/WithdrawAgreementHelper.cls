public without sharing class WithdrawAgreementHelper {
    @AuraEnabled
   public Static boolean  changeStatusvalue(id domainid,String Status ){
       if(!String.isBlank(Status)){
       try{
       Partner_of_Record_Domain__c p1 =new Partner_of_Record_Domain__c();
                       p1.id=domainid;
                       p1.Status__c=Status;
                       update p1;
        return true;
       
       }
       catch(DmlException e) {
   System.debug('An unexpected error has occurred: ' + e.getMessage());
}
       }
       return false;
   }
   
       
  
}