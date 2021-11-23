/*******************************************************************
@Class Name:LimitedAuthorityController
@Sprint :20.05  & P2OB-4922
@Author:SFO Team (Srikanth & Sravanthi)
@CreateDate: 01/04/2020
@Description:To Fetch all the  CIDNS in the Account heirarchy with given Contact record.
@References :LimitedAuthority(Lightning Component)
@TestCoverage : LimitedAuthorityControllerTest
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 updating API version to 50.
*********************************************************************/
public with sharing class LimitedAuthorityController {
    private static Map<id,Account> accRecordsMap= new Map<id,Account>();
    /****************************************************************************
    @Method Name:getCIDNs
    @Author: SFO/Srikanth & Sravanthi
    @Sprint :20.05  & P2OB-4922
    @CreateDate: 01/04/2020
    @Description: To retrieve all CIDNS in the Account heirarchy based on Parent_CIDN__c of the contacts account record.
    @References : LimitedAuthority(Lightning Component)
    Input parameters: Contact ID to fetch relevant Account.
    Output: List of String for CIDNS in the Account Hierarchy.
   
    ******************************************************************************/
    @AuraEnabled
    public static List<String> getCIDNs(Id contactId) {
        List<String> pCIDNValuesList = new List<String>();
        List<String> CIDNActNameList = new List<String>();
        try{
            Contact conRecord = [Select Id, AccountId, Account.CIDN__c,Account.Name from Contact where Id = :contactId LIMIT 1];
            if(String.isNotBlank(conRecord.Account.CIDN__c)){
                pCIDNValuesList.add(conRecord.Account.CIDN__c);
                accRecordsMap.put(conRecord.AccountId,conRecord.Account);
                if(!pCIDNValuesList.isEmpty()){
                    getAllChildCIDNs(pCIDNValuesList);
                }
            }
            
            if(accRecordsMap !=null && !accRecordsMap.isEmpty()){
                for(Account accountRecord : accRecordsMap.values()){
                    CIDNActNameList.add(accountRecord.CIDN__c + ' :: '+accountRecord.Name);
                }
            }
        }catch(Exception ex){
            System.debug('LimitedAuthorityController Exception ::: ' +ex.getMessage());
        }
        return CIDNActNameList;
    }
    /****************************************************************************
    @Method Name:getAllChildCIDNs
    @Author: SFO/Srikanth & Sravanthi
    @Sprint :20.05  & P2OB-4922
    @CreateDate: 01/04/2020
    @Description: To Fetch all CIDNS in the Account Heirarchy based on Account CIDN passed.
    Input parameters: List of String CIDN of Account of Contact Record. 
    Output: List of String for CIDNS in the Account Hierarchy.
   
    ******************************************************************************/
    private static void getAllChildCIDNs(List<String> CIDNList) {  
        List<String> currentCIDNsList = new List<String>();
        if(CIDNList !=null && CIDNList.size()>0){
            for(Account accountRecord : [select Id, CIDN__c,Name from Account where Parent_CIDN__c IN : CIDNList AND Parent_CIDN__c != null LIMIT 40000]){
                if(accountRecord.CIDN__c !=null){
                    accRecordsMap.put(accountRecord.id,accountRecord);
                    currentCIDNsList.add(accountRecord.CIDN__c);
                }
            }
        }
        if(!currentCIDNsList.isEmpty() ){
            getAllChildCIDNs(currentCIDNsList);
        }      
    }    
    
}