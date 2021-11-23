/**
*  Description of the purpose of the classthe method.
*  @name BulkUploadSimSerialNumbersHelper
*  @description               : This class is used  in BulkUploadSimSerialNumber LWC to validate the PhoneNumbers and update SimNumbers
*  @Jira Story Ref            : DIGI-1946
*  @CreateDate                : 15/10/2021 
*  @createdBy                 : Purushottama Sahu, Alexandria
**/
public class BulkUploadSimSerialNumbersHelper {

    public static Map<String,List<String>> validateMobileNumbers(List<String> uploadedData){
        
        Map<String,List<String>> basketMap = new Map<String,List<String>>();
        for(String data: uploadedData){
            List<String> parseData= data.split(',');
            if(parseData.size()==3)
            {
            if(basketMap.containsKey(parseData[2])){
                basketMap.get(parseData[2]).add(parseData[0]);
            }else
            basketMap.put(parseData[2], new List<String>{parseData[0]});
            }
        }
        if (basketMap != null && !basketMap.isEmpty()){
        for(Number__c numRec:[SELECT id,Basket__r.Name,Service_Number__c FROM Number__c WHERE Basket__r.Name IN :basketMap.keySet() AND Service_Number__c IN :basketMap.values()[0] AND Product_Configuration__c != null]){
			List<String> NumList= basketMap.get(numRec.Basket__r.Name);  
            Integer index =NumList.indexOf(numRec.Service_Number__c);
            NumList.remove(index);
            basketMap.put(numRec.Basket__r.Name,NumList);
        }
        }
       return basketMap;
    }
    
    public static void updateSimNumbers(List<String> uploadedData){
        Savepoint sp = Database.setSavepoint();
        Map<String,String> numberSIMMap = new Map<String,String>();
        List<Number__c> updateNumList = new List<Number__c>();
        
        try{
        for(String data: uploadedData){
            List<String> parseData= data.split(',');
            numberSIMMap.put(parseData[0], parseData[1]);
        }
        Logger2 logger = Logger2.getLogger('BulkupdateSimNumbers');
        String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
        DateTime startTime = DateTime.now(); 
        for(Number__c numRec:[SELECT id,Basket__r.Name,Service_Number__c FROM Number__c WHERE Service_Number__c IN :numberSIMMap.keySet()]){
			numRec.Sim_Serial_Number__c=numberSIMMap.get(numRec.Service_Number__c) ;
			updateNumList.add(numRec);
        }
        
        if(updateNumList.size() > 0){
            update updateNumList;
        }
        DateTime endTime = DateTime.now();
        Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
        logger.logMessages('', '', '', '', String.valueOf(updateNumList.size()), 
                               '', '200', correlationId, '','','Update','',requestTime ,'',true, false);
            
        }catch(Exception ex){
            Database.rollback(sp);
            String ErrorMsg='Exception ocured at line number'+ex.getLineNumber()+' due to'+ex.getMessage();
            system.debug(ErrorMsg);
            throw new AuraHandledException(ErrorMsg);
        }   
        
    }
}