public class csvUploaderController {
    /*
     *  Legacy_Service__c
     * Product_Basket__c
     * Product_Type__c
     * Account__c
     * Service_Id__c
     * */
@AuraEnabled
    public static String saveFile(String base64Data,String basketId, Boolean nextFlag) {
        String response = csvUploaderHelper.saveFile(base64Data,basketId,nextFlag);
        return response;
    }
}