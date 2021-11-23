/*******************************************************************
@Class Name:SFO_AccountPortfolioHierarchy
@Sprint :20.10  & P2OB-6272 , 20.11  & P2OB-8414, P2OB-8415, P2OB-8416,20.12 &  P2OB-8608
@Author:SFO Team (Sri,Pallavi,Sravanthi)
@CreateDate: 15/09/2020
@References:  SFO_PortfolioManagementCaseHelper.portfolioManagementInvocableMethod
@description: To get all the child accounts for the parent/current account
@Related Test Class : SFO_PortfolioManagementCaseHelperTest
*********************************************************************/
public class SFO_AccountPortfolioHierarchy {
    public static Map<ID, Account> accRecordsMap = new Map<ID, Account>(); //to load the all child accounts of the CIDNS
    /*******************************************************************
@Method Name    :   getAllChildCIDNs
@Sprint         :   20.10  & P2OB-6272
@Author         :   SFO Team (Pallavi,Sravanthi)
@CreateDate     :   09/07/2020
@description    :   To get all the child accounts for the parent/current account
@References     :   SFO_PortfolioManagementCaseHelper.portfolioManagementInvocableMethod
@TestCoverage   :   SFO_PortfolioManagementCaseHelperTest
*********************************************************************/
    public static void getAllChildCIDNs(List<String> accCIDNList) {
        try{
            List<String> currentCIDNsList = new List<String>();
            for(Account accountRecord : [select Id, Name, Portfolio_Code__c, CIDN__c, Parent_CIDN__c, Ultimate_Parent_CIDN__c from Account where Parent_CIDN__c IN : accCIDNList AND Parent_CIDN__c != null LIMIT 40000]){
                if(accountRecord.CIDN__c !=null){
                    accRecordsMap.put(accountRecord.id,accountRecord);
                    currentCIDNsList.add(accountRecord.CIDN__c);
                }
            }
            system.debug('accRecordsMap values'+accRecordsMap);
            if(!currentCIDNsList.isEmpty() ){
                getAllChildCIDNs(currentCIDNsList);
            }      
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'getAllChildCIDNs Exception ::: ' +ex.getMessage());
        }
    }  
}