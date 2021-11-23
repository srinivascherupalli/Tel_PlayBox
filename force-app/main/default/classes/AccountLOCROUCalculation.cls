/*
AUTHOR : Anu Yadav
DESCRIPTION : This class handles the invocations from Account Trigger to Calculate LOC and ROU Field
*/

public with sharing class AccountLOCROUCalculation {

    public static void CalculateLOC(Map<ID,Account> oldAccountsMap, Account[] updatedAccounts){
            Map<String,Customer_Type__c> mapCustomerTypeCode= new Map<String,Customer_Type__c>();
            List<String> customerTypes = new List<String>();
            Set<Id>  accountIds= new Set<Id>();
            List<Account> accList = new List<Account>();
            for(Account acc: updatedAccounts){
                customerTypes.add(acc.Type);
            }
            for(Customer_Type__c ct : [Select Id,Name,Code__c,Customer_Type__c From Customer_Type__c Where Customer_Type__c IN: customerTypes]){
                mapCustomerTypeCode.put(ct.Customer_Type__c,ct);
            }
            for (Account acc : updatedAccounts){
                if(isNotNullAndBlank(acc.Type)){
                   if(acc.Customer_Status__c==Label.Acc_Customer_Status|| acc.Customer_Status__c==Label.Acc_Customer_Status_Acquired){ //EDGE-68099 Removed Hard Coding
                            if((acc.Type==Label.Acc_Residential|| acc.Type==Label.Acc_Type_SoleTrader) 
                               && (acc.Name != oldAccountsMap.get(acc.Id).Name
                                   || acc.Type != oldAccountsMap.get(acc.Id).Type)){
                                accountIds.add(acc.Id);
                                accList.add(acc);
                                CalculateLOCBySoleTrader(accountIds,accList,mapCustomerTypeCode);
                           }
                            else if((acc.Type==Label.Acc_Type_Company|| acc.Type==Label.Acc_Type_Organisation||acc.Type==Label.Acc_Type_Internal) //EDGE-68099 Removed Hard Coding
                                    &&(isNotNullAndBlank(acc.ABN__c))
                                    &&(acc.Name != oldAccountsMap.get(acc.Id).Name 
                                       || acc.Type != oldAccountsMap.get(acc.Id).Type
                                       ||acc.ABN__c != oldAccountsMap.get(acc.Id).ABN__c)){
                                String code = ((!mapCustomerTypeCode.isEmpty()) && mapCustomerTypeCode.get(acc.Type).Code__c != NULL) ? mapCustomerTypeCode.get(acc.Type).Code__c:''; 
                                acc.LOC__c = code+acc.ABN__c;
                          }
                        }
                }
                else{
                    acc.LOC__c = NULL;
               }
            }
         

     } 
    public static void CalculateLOCBySoleTrader(Set<Id> accountIds, List<Account> accList,Map<String,Customer_Type__c> mapCustomerTypeCode){
        List<Contact> contacts = new List<Contact>();
        if(!accountIds.isEmpty()){
            for(AccountContactRelation acr : [Select AccountId,ContactId,Contact.Id,Contact.Birthdate,Contact.FirstName,Contact.LastName,Contact.Driver_License_Id__c,Contact.Driver_Licence_State__c from AccountContactRelation where Roles='Legal Lessee' AND AccountId IN : accountIds] ){
               contacts.add(acr.contact);               
            }
        } 
        System.debug('contacts++'+contacts);
        for(Account a : accList){
            String code = ((!mapCustomerTypeCode.isEmpty()) && mapCustomerTypeCode.get(a.Type).Code__c != NULL) ? mapCustomerTypeCode.get(a.Type).Code__c:''; 
            String DOB,licence,firstName = NULL;
            for(Contact con :contacts){
                DateTime birthdate = (con.Birthdate != Null)? con.Birthdate : NULL;
                DOB = (birthdate == null)? null :birthdate.format('MM/dd/yyyy');
                licence = con.Driver_License_Id__c;
                if(con.Driver_License_Id__c != NULL){
                    firstName = (con.FirstName != null && con.FirstName.length()>8)? con.FirstName.substring(0,8):con.FirstName;
                }
                else{
                    firstName = (con.FirstName != null && con.FirstName.length()>17)? con.FirstName.substring(0,17):con.FirstName;
                }
            }
           a.LOC__c = (firstName == null || DOB == null) ?'':
                ((licence != NULL)?code+DOB+licence+firstName:code+DOB+firstName);
         }
      
        }
    
    private static boolean isNotNullAndBlank(String value){
        return (value != null && String.isNotBlank(value)) ? true : false;
    }
}