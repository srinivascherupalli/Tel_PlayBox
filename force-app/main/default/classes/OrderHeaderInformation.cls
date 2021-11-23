public with sharing class OrderHeaderInformation { //added with sharing for vulnerability
    public static void updateOrderHeaderInformation( List<Id> orderIdList)
    {
        List<csord__Service__c> serviceList = new List<csord__Service__c>();
        Map<String,csord__Service__c> serviceMap = new Map<String,csord__Service__c>();
        serviceList = [SELECT id, csord__Order__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Maxim_Opportunity_ID__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Hot_Cutover__c ,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Hot_Cutover_Comments__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Service_Number__c,
			csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.name,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Billing_Account__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Project_Complexity__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.PM_Required__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Project_ID__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Project_Manager_User_ID__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Project_Manager_Contact_Number__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Project_Manager_Email__c,
			csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.name,
            csord__Order__r.csord__Primary_Order__c
        FROM csord__Service__c where csord__Order__c IN :orderIdList OR csord__Order__r.csord__Primary_Order__c IN: orderIDList];
        for(csord__Service__c servObj:serviceList)
        {
            if(servObj.csord__Order__r.csord__Primary_Order__c ==null)
            {
                serviceMap.put(servObj.csord__Order__c,servObj);
            }    
            else if(servObj.csord__Order__r.csord__Primary_Order__c != null)
            {
                serviceMap.put(servObj.csord__Order__r.csord__Primary_Order__c,servObj);
            }
        }

        List<csord__Order__c> orderList = new List<csord__Order__c>();
        List<csord__Order__c> orderListforUpdate = new List<csord__Order__c>();

        orderList = [SELECT id, Opportunity_ID__c,Billing_Account__c from csord__Order__c where id IN:serviceMap.keySet()];

        for( csord__Order__c orderObj : orderList )
        {
            csord__Service__c serObj = serviceMap.get(orderObj.id);
                orderObj.Opportunity_ID__c = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Maxim_Opportunity_ID__c;
                orderObj.Hot_Cutover__c = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Hot_Cutover__c;
                orderObj.Hot_Cutover_Comments__c = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Hot_Cutover_Comments__c;
                orderObj.Service_Number__c = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Service_Number__c;
                orderObj.name = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.name;
                orderObj.Billing_Account__c = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Billing_Account__c;
                orderObj.Project_Complexity__c = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Project_Complexity__c;
                orderObj.PM_Required__c = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.PM_Required__c;
                orderObj.Project_ID__c = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Project_ID__c;
                orderObj.Project_Manager_User_ID__c = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Project_Manager_User_ID__c;
                orderObj.Project_Manager_Contact_Number__c = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Project_Manager_Contact_Number__c;
                orderObj.Project_Manager_Email__c = serObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Project_Manager_Email__c;
                orderListforUpdate.add(orderObj);
        }
        if( !orderListforUpdate.isEmpty())
        {
            update orderListforUpdate;
        }
    }

}