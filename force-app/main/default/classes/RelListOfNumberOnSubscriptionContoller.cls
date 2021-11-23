/*************************************************************************************************
Name : RelListOfNumberOnSubscriptionContoller
Test Class  : RelListOfNumberOnSubscriptionTest
Ch no 
1.  18/09/2020      Shubhi Vijayvergia   EDGE-173803(new )
2.  06/10/2021      Puneeth Kamath       DIGI-27409
**************************************************************************************************/
public with sharing class RelListOfNumberOnSubscriptionContoller {
    //added EDGE-219789 added Mobile__c
    @AuraEnabled
    public static List<Number__c> getNumbersOfRecord(String recordId){
        List<Number__c> numberList = new List<Number__c>();
        List<Number_Group__c> ngList = new List<Number_Group__c>();
        List<String> subNumberList = new List<String>();
        if(String.isNotBlank(recordId)){
            Schema.SObjectType token = Id.valueof(recordId).getsObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            String objName = dr.getname();
            List<csord__Subscription__c> subsInfoList = new List<csord__Subscription__c>();
            if(objName == 'csord__subscription__c'){
                subsInfoList.add(Model_Subscription.getSubscriptionNumer(recordId));
            }
            else if(objName == 'csord__Order__c'){
                subsInfoList = [select Id,csordtelcoa__Subscription_Number__c from csord__subscription__c where csord__Order__c =: recordId];
            }
            if(!subsInfoList.isEmpty()){
                for(csord__subscription__c subObj : subsInfoList){
                    subNumberList.add(subObj.csordtelcoa__Subscription_Number__c);
                }
                numberList = [select Id,name,Service_Number__c,Status__c,Subscription_number__c,Mobile__c from Number__c where Subscription_number__c=:subNumberList order by createddate DESC];
            }
            //macd non commercial order
            else if(subsInfoList.isEmpty() && objName == 'csord__Order__c'){
                numberList = [select Id,name,Service_Number__c,Status__c,Subscription_number__c,Mobile__c from Number__c where Number_Group__r.OrderId__c =: recordId];    
            }       
        }
        return numberList;
    }

}