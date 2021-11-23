/*******************************************************************
@Class Name:FilterContactsControllerTest
@Description:Sprint 20.03 , P2OB-4620 ,Sprint 20.07 :P2OB-6382
@Author:SFO Team (Sravanthi)
@Comments:This class is test class for FilterContactsController.
*********************************************************************/
public without sharing class CustomRecordDetailController {
    
    @AuraEnabled
    public static SObject updateSObject(SObject objectRec){
        try{
            update objectRec;
        } catch (DmlException e){
            System.debug(e.getCause());
            throw new AuraHandledException(e.getMessage());
        }
        return objectRec;
    }
}