/******************************************************************
Story ID     : EDGE-206201
Description  : Logic to populate Account__c field based on CIDN
Test Class   : ServiceAddOnTriggerTest
Created Data : 16-Mar-2021
*******************************************************************/

public class ServiceAddOnTriggerHandler {
    public static void populateAccountId(List<Service_Add_On__c> triggerNewVal){
        List<String> cidnIDs = new List<String>(); //to Store the service add CIDN values
        Map<String, Id> accCIDNMap = new Map<String, Id>(); //to store service add On - CIDN and related account ID
        
        //Capturing CIDN's
        for(Service_Add_On__c  sadd : triggerNewVal) {
            if(sadd.CIDN__c != null ){
                cidnIDs.add(sadd.CIDN__c);        
            }            
        }
        
        //Creating Map
        if(cidnIDs.size() > 0){
            for(Account acc : [SELECT Id,CIDN__c FROM Account WHERE CIDN__c IN: cidnIDs]){
                accCIDNMap.put(acc.CIDN__c, acc.id);
            }    
        }        
        
        //inserting account value in service Add on
        for(Service_Add_On__c  serAdd : triggerNewVal){
            if(accCIDNMap.containsKey(serAdd.CIDN__c)){
                serAdd.Account__c = accCIDNMap.get(serAdd.CIDN__c);
            }    
            //EDGE-212220 - Translation of HRO to MRO
            if(serAdd.Contract_Type__c != null && serAdd.Contract_Type__c == 'HRO' && serAdd.Transaction_Type__c == 'Migration' && serAdd.Device_Type__c != 'Accessory' ){
                serAdd.Contract_Type__c = 'MRO';
            }
             //DPG-5213: Fix for ARO for Device Type Accessory
            else if(serAdd.Contract_Type__c != null && serAdd.Contract_Type__c == 'HRO' && serAdd.Transaction_Type__c == 'Migration' && serAdd.Device_Type__c == 'Accessory' ){
                serAdd.Contract_Type__c = 'ARO';
            }
        } 
    }
}