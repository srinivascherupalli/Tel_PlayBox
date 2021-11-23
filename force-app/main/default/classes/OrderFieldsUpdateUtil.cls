public with sharing class OrderFieldsUpdateUtil
{
    public static void changeOrderRecTypeAndStatus( List<csord__order__c> orderList, String status, Id recTypeId )
    {
        if (!orderList.isEmpty())
        {
            for(csord__Order__c orderInstance : orderList){
                if(status == 'MSISDN Required'){orderInstance.isMSISDNRequired__c = true; orderInstance.csord__Status2__c = 'MSISDN Required';
                }
                else if(status == 'IoT MSISDN Required'){ // DPG-1260 & DPG-697
                    orderInstance.IOTMSISDNRequired__c = true; // DPG-1260 & DPG-697
                    orderInstance.csord__Status2__c = status; // DPG-1260 & DPG-697
                }
                else{
                     orderInstance.csord__Status2__c = status;
                }
               
                orderInstance.RecordTypeId = recTypeId;
           
            }
            update orderList;
        }
         
    }
}