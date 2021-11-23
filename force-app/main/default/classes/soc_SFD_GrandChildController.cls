/*****************************************************************************
@Author: Kritika Bhati
@CreateDate: 12 feb 2019
@ModifiedByandDate: 
@Description: Controller for soc_ChildCaseProductRow . 
@References
Epic :EDGE-65104: Case Line Item View on Parent Case

*******************************************************************************/
public without sharing class soc_SFD_GrandChildController {
   
    @AuraEnabled
    public static List<Case> getChildHierarchy(String recordId) {
        List<Case> accList = new List<Case>();
        accList = [select id, caseNumber,ownerId,Owner.name,subject, stage__c,status,(select id,soc_Product_Name__c, 
                                                                   soc_order_number__c from Case_Line_Items__r),ClosedDate 
                from case where parentId=:recordId];
       
        return accList;
    }

}