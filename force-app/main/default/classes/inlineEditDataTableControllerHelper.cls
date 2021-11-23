/**
 * @description       : 
 * @author            : Abhishek Mallick
 * @group             : 
 * @last modified on  : 05-19-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-19-2021   Abhishek Mallick  Initial Version
**/
public class inlineEditDataTableControllerHelper {
    
/************************************************************************************
 * Developer: Abhishek Mallick
 * User Story: EDGE-207158
 * Team: Osaka
 * Description: This method upates Nickname for Subscription Order based on Uploaded
 * 				file.     
**************************************************************************************/    
    @AuraEnabled
    public static String updateNickName(String base64Data){
        String result;
        try{
            Map<String,String> subNameAndNickName = new Map<String,String>();
            String data= JSON.deserializeUntyped(base64Data).toString();
            List<csord__Subscription__c> subscriptionInsertList = new List<csord__Subscription__c>();
            List<String> lstCSVLines = data.split('\n');
            system.debug('lstCSVLines>>>'+lstCSVLines);
            system.debug('lstCSVLines.size>>>'+lstCSVLines.size());
            List<String> lstcolumnHeaders = lstCSVLines[0].split(',');
            
            system.debug('lstCSVLines>>>>>'+lstCSVLines.size());
            for(Integer i = 1; i < lstCSVLines.size(); i++){
                String csvLine = lstCSVLines[i];
                system.debug('csvLine>>>'+csvLine);
                //Reading column data from CSV
                List<String> csvRowData = new List<String>();
                for(String column : csvLine.split(',')){
                    column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                    system.debug('column>>>'+column);
                    csvRowData.add(column);
                }
                //Map of Subscription Number and Nickname from uploaded CSV.
                subNameAndNickName.put(csvRowData[1],csvRowData[4]);
                System.debug('Map of Sub Number and Nickname'+subNameAndNickName.keyset());
            }
            
            subscriptionInsertList = [Select id,Nickname__c,csordtelcoa__Subscription_Number__c from csord__Subscription__c
                                      where csordtelcoa__Subscription_Number__c in :subNameAndNickName.keyset()];
            System.debug('Subscrition List::'+subscriptionInsertList);
            if(!subscriptionInsertList.isEmpty() && subscriptionInsertList != Null){
                for(csord__Subscription__c subRec : subscriptionInsertList){
                    if(subNameAndNickName.containsKey(subRec.csordtelcoa__Subscription_Number__c)){
                        subRec.Nickname__c = subNameAndNickName.get(subRec.csordtelcoa__Subscription_Number__c);
                    }
                }
                update subscriptionInsertList;
                result = Label.UploadFileSuccessMessage;
            }
        }
        
        catch(Exception ex){
            System.debug('Exception Occured during update' + ex);
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            result = Label.UploadFileFailedMessage;
        }
        return result;
    }
 //End of EDGE-207158 by Abhishek(Osaka)
}