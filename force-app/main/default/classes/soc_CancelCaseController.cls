/*****************************************************************************
@Author: Kritika Bhati
@CreateDate: 25 march 2019
@Description: This class contains logic to Update Status and Sub status of Parent Case,
for Cancel Case button.
@Modified By : Kritika Bhati for Bug EDGE-82470 on 30 April 2019.
*******************************************************************************/
public class soc_CancelCaseController {
	
    @AuraEnabled
	public static Case updateCase(Id recordId){
    Case caseRec = [SELECT Id, Status, Stage__c, soc_SFD_Sub_Status__c, soc_Is_Not_Cancel_Case__c FROM Case WHERE id=:recordId];
  
    caseRec.soc_Is_Not_Cancel_Case__c = false;
    caseRec.status = 'Withdrawn';
	caseRec.soc_SFD_Sub_Status__c = 'No Longer Required';    

    update caseRec;
    return caseRec;
}
}