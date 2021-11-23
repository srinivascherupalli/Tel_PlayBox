/*
    AUTHOR : Sajal Shah    
    DESCRIPTION : This class is used to check if there are any active one fund accounts and create a Telstra Enterprice Fund Allocation record
*/

public class FundBalanceTransfer {
    private static final C2O_ExceptionHandler.Capability CONST_CAPABILITY = C2O_ExceptionHandler.Capability.BSK;
    private static final String CONST_INTERFACENAME = 'FundBalanceTransfer';

    @AuraEnabled
    public static Map<String, String> CheckOneFundRecords(Id accountRecId){
        Map<String, String> response = new Map<String, String>();
        List<OneFund__c> activeOnefundAccounts = new List<OneFund__c>();
        try{
            activeOnefundAccounts = [SELECT Id, OneFund_Status__c, CIDN__c, CIDN__r.CIDN__c FROM OneFund__c WHERE CIDN__c = :accountRecId AND OneFund_Status__c = 'Active'];
            System.debug('---activeOnefundAccounts---'+activeOnefundAccounts);
            if(activeOnefundAccounts.isEmpty()){
                //START: Modified for DIGI-2094
                OneFund__c onefund = new OneFund__c();
                onefund.CIDN__c = accountRecId;
                onefund.Start_Date__c = Date.today();
                onefund.OneFund_Accrual_Frequency__c = 'Monthly';
                onefund.OneFund_Status__c = 'Active';
                insert onefund;
                List<OneFund__c> oneFundNewList = [SELECT Id, OneFund_Status__c, CIDN__c, CIDN__r.CIDN__c FROM OneFund__c WHERE CIDN__c = :accountRecId AND OneFund_Status__c = 'Active' LIMIT 1];
                response.put('message','One fund record inserted');
                response.put('Error', 'false'); 
                if(!oneFundNewList.isEmpty()){
                    response.put(EnvironmentVariable.get('onefund_okapi_cidn'), oneFundNewList[0].CIDN__r.CIDN__c);
                }
                else{
                    response.put(EnvironmentVariable.get('onefund_okapi_cidn'), '');
                }
                return response;
            }
            else{
                response = GetOneFundTransferToken.getOneFundAuthToken(activeOnefundAccounts[0].CIDN__r.CIDN__c);
            }
            //END for DIGI-2094
            if(response.get('Error') == 'false' && response.get(EnvironmentVariable.get('onefund_okapi_cidn')) == activeOnefundAccounts[0].CIDN__r.CIDN__c && response.get(EnvironmentVariable.get('onefund_okapi_message')).containsIgnoreCase('successful')){
                FundBalanceTransfer.createTelstraEnterpriceFundAllocation(response, activeOnefundAccounts[0].Id);
            }
            return response;
        }
        catch (Exception ex) {
            Map<String, Object> eLogMap = new Map<String, Object>();
            eLogMap.put('capability', CONST_CAPABILITY);
            eLogMap.put('interfaceName', CONST_INTERFACENAME);
            eLogMap.put('elementName', 'CheckOneFundRecords');
            eLogMap.put('referenceNumber', '');
            eLogMap.put('correlationId', '');
            eLogMap.put('errorDescription', ex.getMessage());
            eLogMap.put('businessDescription', 'read response of callback');
            C2O_Utilities.logException(eLogMap, false);
            return null;
        }
    }  
    
    @future
    public static void createTelstraEnterpriceFundAllocation(Map<String, String> response, Id activeOnefundAccountId){
        try{
            String oneFundAccId = String.valueOf(activeOnefundAccountId).subString(0,10);
            Double respFundBal = Double.valueOf(response.get(EnvironmentVariable.get('onefund_okapi_fundBalance')));
            Double respContriBal = Double.valueOf(response.get(EnvironmentVariable.get('onefund_okapi_contributionBalance')));
            Double cidn = Double.valueOf(response.get(EnvironmentVariable.get('onefund_okapi_cidn')));
            Id fundAllocationRecTypeId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByName().get('Fund Allocation').getRecordTypeId();

            OneFund_Transactions__c oneFundTransact = new OneFund_Transactions__c();
            oneFundTransact.RecordTypeId = fundAllocationRecTypeId;
            oneFundTransact.Sub_Type__c = 'Legacy Fund Transfer';
            oneFundTransact.Legacy_Fund_Type__c = 'Adaptive Mobility Fund Migration';
            oneFundTransact.Legacy_Fund_Account_Number__c= 'cidn';
            oneFundTransact.OneFund__c = activeOnefundAccountId;
            oneFundTransact.Transaction_Status__c = 'Active';
            oneFundTransact.Start_Date__c = Date.today();
            oneFundTransact.Transaction_Amount__c = (respFundBal + respContriBal)*0.91;
            insert oneFundTransact;
        }
        catch (Exception ex) {
            Map<String, Object> eLogMap = new Map<String, Object>();
            eLogMap.put('capability', CONST_CAPABILITY);
            eLogMap.put('interfaceName', CONST_INTERFACENAME);
            eLogMap.put('elementName', 'createTelstraEnterpriceFundAllocation');
            eLogMap.put('referenceNumber', '');
            eLogMap.put('correlationId', '');
            eLogMap.put('errorDescription', ex.getMessage());
            eLogMap.put('businessDescription', 'read response of callback');
            C2O_Utilities.logException(eLogMap, false);
        }
    }
}