/* EDGE-201628 -Alexandria - 26/02/2021 
- Helper to display the Account Program Banner */
public without sharing class AccountProgramHelper {

    
    @AuraEnabled(cacheable = true)
    //START: Modified for EDGE-213096
    public Static Program_Account__c checkaccountProgramdetails(String accId)
    {
        //String Digital_Products_Start;
        List<Program_Account__c> accprod= new List<Program_Account__c>();
        accprod =[SELECT Id,Digital_Products_Start_Date__c, RecordType.DeveloperName, Digital_Program_Type__c, Status__c 
                                    FROM Program_Account__c 
                                    WHERE (Account__c=:accId AND Enable_to_digital_products__c=TRUE AND RecordType.DeveloperName='General' AND (Digital_Program_Type__c='Transition' OR Digital_Program_Type__c='Migration')) 
                                    ORDER BY Digital_Products_Start_Date__c DESC NULLS LAST LIMIT 1];
        //Program_Account__c accprod =[SELECT Id,Digital_Products_Start_Date__c FROM Program_Account__c WHERE Account__c='0012O000002ZqVsQAK' AND Enable_to_digital_products__c=TRUE ORDER BY Digital_Products_Start_Date__c ASC LIMIT 1 ];
        if(!accprod.isEmpty())
        {
        //   Datetime dt = (Datetime) accprod.Digital_Products_Start_Date__c; 
        //  Date d = dt.format('MM/dd/yyyy');
            //Digital_Products_Start= string.valueof(accprod.Digital_Products_Start_Date__c);
            return accprod[0];
        }
         
        //System.debug('accprod[0]'+accprod[0]); 
        //System.debug('Digital_Products_Start'+Digital_Products_Start);        
        return null;
        //END: EDGE-213096
    }
    
}