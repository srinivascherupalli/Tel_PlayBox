public with sharing class CompUtilityReplicatorManagerHelper {
    
    public static String productSpecMobile = Label.ProductSpecificationMobile;
    public static List<String> listproductSpecMobile = productSpecMobile.split(',');
    public static List < String > listproductSpecNgUc = Label.ProductSpecificationNgUc.split(',');
 /*****************************************************************************************************************************
 * Story: DIGI-1753
 * Team : Osaka
 * Developer : Pradeep Mudenur
 * Description: Load the Transition landing page dynamically based on TransitionJson being already present.
 * ************************************************************************************************************************************/	
    @AuraEnabled
    public static boolean checkReplicatorResponse(String basketId) {
        Boolean isTransitionJson;
        List < Attachment > attachmentList = New List < Attachment > ();
        try {         
            attachmentList = [SELECT Id, ParentId, Name, Body from Attachment WHERE ParentId IN(SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND (cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile OR cscfga__Product_Definition__r.product_Specification__c IN:listproductSpecNguc)) AND Name LIKE '%Transition%'];
            System.debug('@@@@@@ Attachment size is' + attachmentList.size());
            if (attachmentList.size() > 0){
                isTransitionJson = true;
                System.debug('@@@@@@TransitionJson Boolean Flag true' + isTransitionJson);
            }else{
                isTransitionJson = false;
                System.debug('*****TransitionJson Boolean Flag false' + isTransitionJson);
            }
           }
        catch (Exception ex) 
        {
            System.debug('Exception in checkReplicatorResponse' + ex);
        }
        return isTransitionJson;
    }     

}