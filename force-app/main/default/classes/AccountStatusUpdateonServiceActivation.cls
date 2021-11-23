/**
* @Description :This Class will update the Acccount status to ACQUIRED
* @Author : Aishwarya Yeware
* @Date : 07/02/2018
* @Story : EDGE-4757
*/

public class AccountStatusUpdateonServiceActivation {
    Public static void updateAccountStatus(Account customerAccount)
    { 
        If(customerAccount != NULL && customerAccount.Customer_Status__c=='ACTIVE')
           customerAccount.Customer_Status__c='ACQUIRED';
    }
    

}