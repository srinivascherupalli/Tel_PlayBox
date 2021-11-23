/******************************************************************************************************
*Class Name     : MCRUpdateUtility
*Decription     : This class is to update the source Account Name. It is called from Update_CHOWN_Opportunity_on_migration process
*Test Class     : MCRUpdateUtilityTest

Sr.No.      Developer Name          Date            Story           Description
1.            Gokul        22/2/21            EDGE-219537    This class is to update the source Account Name.It is called from Update_CHOWN_Opportunity_on_migration process
********************************************************************************************************/

public with sharing class MCRUpdateUtility {
    static String CONST_INTERFACENAME = 'MCRUpdateUtility';
    static String correlationId = GuidUtil.NewGuid();
    //EDGE-219537 - This method will get called from Update_CHOWN_Opportunity_on_migration Process builder on creation of MCR
    @InvocableMethod
    public static void updateSourceAccount(list<Migration_Change_Request__c> mcrList){
        set<Id> accIds = new set<Id>();
        set<Id> mcrIds = new set<Id>();
        try{

            list<Migration_Change_Request__c> mcrUpdateList = new list<Migration_Change_Request__c>();
            for(Migration_Change_Request__c mcr : mcrList){
                accids.add(mcr.account_id__c );  
                mcrIds.add(mcr.id);  
            }
            map<Id,account> accMap = new map<Id,account>([select id,name from account where id IN : accids]);
            for(Migration_Change_Request__c mcr : [select id,account_id__c,Source_Account_Name__c from Migration_Change_Request__c where id IN :mcrIds ]){
                if(accMap.containskey(mcr.account_id__c)){
                    mcr.Source_Account_Name__c =   accMap.get(mcr.account_id__c).name; 
                    mcrUpdateList.add(mcr);
                }      
            }
            if(!mcrUpdateList.isEmpty()){
                update mcrUpdateList;    
            }
        }catch(Exception e) {
            GenericUtilityClass.logException(CONST_INTERFACENAME,'updateSourceAccount','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured while posting chatter notification',C2O_ExceptionHandler.Capability.ORD); 
        }
        
    }
}