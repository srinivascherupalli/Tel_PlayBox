/**
*  Description of the purpose of the classthe method.
*  @name BulkUploadSimSerialNumbersCtrl
*  @description               : This class is used  in BulkUploadSimSerialNumber LWC to validate the PhoneNumbers and update SimNumbers
*  @Jira Story Ref            : DIGI-1946
*  @CreateDate                : 15/10/2021 
*  @createdBy                 : Purushottama Sahu, Alexandria
**/
public class BulkUploadSimSerialNumbersCtrl {

    @AuraEnabled
    public static Map<String,List<String>> validateMobileNumbers(List<String> uploadedData){
       return BulkUploadSimSerialNumbersHelper.validateMobileNumbers(uploadedData);
    }
    
    @AuraEnabled
    public static void updateSimNumbers(List<String> uploadedData){
    BulkUploadSimSerialNumbersHelper.updateSimNumbers(uploadedData);
    }
      
}