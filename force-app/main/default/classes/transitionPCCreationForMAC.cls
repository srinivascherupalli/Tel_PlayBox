/*********************************************************************************************************************************
 * Class Name      :   transitionPCCreationForMAC
 *Story             :   EDGE-78293  Create PB to attach Dummy PC for Legacy Transition Services
 *Developer         :   Rohit Tripathi
 **********************************************************************************************************************************/

public without sharing class transitionPCCreationForMAC {
    @InvocableMethod
    // Method to receive list of Service Ids from Process Builder , Create A Dummy PC and Attach to service Object
    public static void serviceIds(List < ID > ids) {
        List <cscfga__Product_Basket__c> basketIds = [select id ,csbb__Account__c from cscfga__Product_Basket__c where id in : ids ];
        
        List<cscfga__Product_Definition__c> prodDef = [Select id from cscfga__Product_Definition__c where name =: system.label.LegacyPD Limit 1];
        
        List <csord__Subscription__c> subsId = [select id  from csord__Subscription__c where csord__Account__c = : basketIds[0].csbb__Account__c and Name = : System.Label.Connected_Workplace];
        
        List < csord__Service__c > serviceList = [select id, csordtelcoa__Product_Configuration__c from csord__Service__c
            where csord__Subscription__c in: subsId and Name like '%Legacy%'];
        //EDGE-78293--> Null Check for serviceList 
        if (serviceList.size() > 0 && !serviceList.isEmpty()) {
        List < csord__Service__c > servicesTobeUpdated = new List < csord__Service__c > (); // List to store service records to be updated
        //Dummy PC Creation
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c();
        prodConfig.Name = 'IP Site_Legacy';
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        prodConfig.cscfga__Description__c = 'IP Site';
        prodConfig.Quantity_Product_Configuration__c = 1;
        prodConfig.cscfga__Recurrence_Frequency__c = 12;
        prodConfig.cscfga__Contract_Term__c = 36;
        prodConfig.cscfga__Contract_Term_Period__c = 12;
        prodConfig.Type__c = 'New';
        prodConfig.Bandwidth__c = '2';
        prodConfig.Commercial_Config__c = 'No';
        prodConfig.csordtelcoa__Hierarchy_Level__c = 1;
        prodConfig.cscfga__Index__c = 1;
        prodConfig.cscfga__Last_Screen_Index__c = 1;
        prodConfig.cscfga__Product_Basket__c =basketIds[0].Id ;
        prodConfig.cscfga__Product_Definition__c = prodDef[0].id;

        insert prodConfig;

        // For each Service record received from Process Builder attach the Dummy PC
        for (csord__Service__c serv: serviceList) {
            serv.csordtelcoa__Product_Configuration__c = prodConfig.Id;
            servicesTobeUpdated.add(serv);
        }
        try {
            if (servicesTobeUpdated.size() > 0 && !servicesTobeUpdated.isEmpty())
                update servicesTobeUpdated;
        } catch (Exception e) {
            system.debug('Exception Occured During PC Update' + e.getMessage());
        }
        }
    }
}