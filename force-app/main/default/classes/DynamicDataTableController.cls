public with sharing class DynamicDataTableController {
	@AuraEnabled
    public static Data_Table_Configuration__c getdataTable(String tableId) {
        system.debug('tableId>>>>'+tableId);
        Data_Table_Configuration__c objdata = new Data_Table_Configuration__c();
        List<Data_Table_Configuration__c> lstdata = new List<Data_Table_Configuration__c>();
        lstdata =  [Select Id,Header__c,Name,IsShowCSV__c,key_Value__c,Show_Header__c,Page_Size__c FROM Data_Table_Configuration__c 
               				WHERE Name=: tableId limit 1];
        if(!lstdata.isEmpty()){
            objdata = lstdata[0];
        }
        return objdata;
    }

    @AuraEnabled
    public static boolean resetErrorCheckBoxOnNumbers(Object numberListObject){
        boolean result = false;
        system.debug('numberListObject '+JSON.serializePretty(numberListObject));
      
            List<Object> errorRecList = (List<Object>)numberListObject;
            set<String> errorRecId = new set<String>();
            for(Object obj : errorRecList){
                Map<String,Object> eachRecMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                if(eachRecMap.containskey('status') && eachRecMap.get('status')=='Error' && eachRecMap.containskey('recordId') && eachRecMap.get('recordId')!=''){
                    errorRecId.add(String.valueof(eachRecMap.get('recordId')));
                }
            }
            system.debug('errorRecId '+errorRecId);
            List<Number__c> numberListWithError =  [SELECT id,Product_Configuration__c,Basket__c,SimAvailabilityType__c,
            SIM_Type__c,Sim_Serial_Number__c, Type__c ,Plan_Type__c,Error_in_assigning_plan__c
            FROM Number__c WHERE Id IN : errorRecId];
            for(Number__c num : numberListWithError){
                num.Error_in_assigning_plan__c = false;
            }
            if(numberListWithError.size() > 0){
                update numberListWithError;
            }
        
        if(numberListObject!=null){
            result = true;
        }
        return result;
    }
}