/**************************************************************************************
 * Author      : Vishal Arbune
 * Class Name  : FundBalanceAmountHelper 
 * Description : To fetch total fund balance from associated OneFund object. 
 * Story       : EDGE-113083 - Show available OneFund balance from CIDN at the time of basket creation
 **************************************************************************************/
global with sharing class FundBalanceAmountHelper implements cssmgnt.RemoteActionDataProvider  {
    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap) {
       
        Map<String, Object> returnMap = new Map<String, Object>();

        Set<String> inputKey = inputMap.keySet();
        for (String k :inputKey) {
            if (k == 'GetBasket') {
                String basketId = (String)inputMap.get('GetBasket');    
                Double res = getCurrentFundBalanceAmt(basketId);   
                returnMap.put('GetBasket', res);
            }
        }
        return returnMap;
    }

    global static Double getCurrentFundBalanceAmt(String basketId){
        Set<id> accountId = new Set<id>();
        List<string> parentCidnId = new List<string>();
        List<string> uCidnId = new List<string>();
        Set<id> pCidnDetails = new Set<id>();
        Set<id> uCidnDetails = new Set<id>();

        if(basketId.length() > 0){
        List<cscfga__Product_Basket__c> pbList = [select id, Name, Account_Id__c from cscfga__Product_Basket__c where Name =: basketId];
        for(cscfga__Product_Basket__c pb : pbList){
            accountId.add(pb.Account_Id__c);                
            }
        }                        
        
         
        Double currentFundAmount = 0.00;
        Boolean ucidnFlag = false;
        String accountLavel = '';
        List<Account> parentCidn = new List<Account>();
            currentFundAmount = calculateCurrentFundAmount(accountId); 

            
            //At Parent CIDN Level              
            if(currentFundAmount == 0.0){
                parentCidn = [select Parent_CIDN__c, Ultimate_Parent_CIDN__c From Account where id IN : accountId]; 
                
                for(Account acc : parentCidn){
                    parentCidnId.add(acc.Parent_CIDN__c);
                    uCidnId.add(acc.Ultimate_Parent_CIDN__c);                                                 
                }        
            
                if(!parentCidnId.contains(null)){
                    pCidnDetails = getAccountId(parentCidnId);
                }

                currentFundAmount = calculateCurrentFundAmount(pCidnDetails);                

                if(currentFundAmount == 0.0){
                    ucidnFlag = true;
                }
            }             
            if(ucidnFlag){ 
                if(!uCidnId.contains(null)){
                    uCidnDetails = getAccountId(uCidnId);                
                }              
                currentFundAmount = calculateCurrentFundAmount(uCidnDetails);                
            }        
        return currentFundAmount;     
    }
    
    public static Double calculateCurrentFundAmount(Set<Id> cidn){
        Double currentFundAmount = 0.00;
        Id flexibleRecordId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();
		Id committedRecordId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Committed').getRecordTypeId();
        if(cidn != null || cidn.size() > 0){
            List<OneFund__c> fund = [select id,RecordTypeId, OneFund_Type__c, Available_OneFund__c, (Select Expiry_Date__c from OneFund_Transactions__r) from OneFund__c where CIDN__c IN : cidn]; 

            for(OneFund__c fun : fund){
            if((fun.RecordTypeId == flexibleRecordId || fun.RecordTypeId == committedRecordId) && (fun.Available_OneFund__c != 0.00)){
                                currentFundAmount = currentFundAmount + fun.Available_OneFund__c;                         
                    }
                }
            }      
        return currentFundAmount;  
    }

    public static Set<id> getAccountId(List<string> cidnLevel){ 
        Set<id> parentAccountId = new Set<id>();       

        List<Account> accountDetails = [select id From Account where CIDN__c IN : cidnLevel];                 
        for(Account acc : accountDetails){
            parentAccountId.add(acc.id);
        } 		
        return parentAccountId;
    }
}