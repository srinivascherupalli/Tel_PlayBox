/*
EDGE -127943,EDGE-143860
Name: DynamicLookupComponent
Description: Fetching Lookup values and show in search box(reusable Lightning custom Lookup)
Author: Pradeep Bhumi 
Modified: Shresth Dixit(DPG-3510)
***************************************************************************************************
UpdatedVersion      UpdatedBy            Edge Number         Date
1                   Aman Soni            EDGE-207867         18/05/2021
***************************************************************************************************/
public with sharing class DynamicLookupController {
    
    /*-------------------------------------------------------- 
    EDGE-127943
    Method: fetchLookUpValues
    Description: Method to fetch search data for Lookup fields  
    Author:Pradeep
    Modified: Shresth Dixit(DPG-3510: Added extra parameter filter in method calling for fetchLookUpStockCheck,fetchLookUpValues)
    Modified: Aman Soni EDGE-207867(21.06)
    --------------------------------------------------------*/      
        @AuraEnabled(cacheable=true)
        public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName,String recordId,String identifier,Map<String,Object> resultSearchMap,String filter) 
        {
            List <sObject> returnList = new List <sObject> ();
            if (identifier == 'Contact.Name')
            {
                returnList = InvoiceCmpHandler.fetchLookUpValues(searchKeyWord,ObjectName,recordId);
              
            }
            else if (ObjectName == 'cspmb__Price_Item__c')
            {
                system.debug('resultSearchMap**' +resultSearchMap+ 'searchKeyWord&& ' +searchKeyWord+ 'filter^^ ' +filter);
                returnList = AdvancedStockCheckController.fetchLookUpStockCheck(searchKeyWord,ObjectName,identifier,resultSearchMap,filter);
            }
            //Added for EDGE-207867 by Aman Soni || Start
            else if(ObjectName == 'Case'){
                returnList = InvoiceCmpHandler.fetchCaseObjLookUpValues(searchKeyWord,ObjectName,recordId);
            }
            //Added for EDGE-207867 by Aman Soni || End
            
            return returnList;
        }
        
        /**********************************
        EDGE-148587
        Description: Method to get logged in User's profile
        Author: Manjunath Ediga
        ***********************************/  
        @AuraEnabled
        public static Boolean getUserInformation(){         
                Boolean isPartner = AdvancedStockCheckController.getUserInfo();
                return isPartner;       
        }
    }