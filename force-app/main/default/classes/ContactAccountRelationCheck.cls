/*****************************************************************************
@Name: ContactAccountRelationCheck
@Author: SFO Team : Chhaveel
@CreateDate: 19/05/2021
@Description: This Class checks if Account and Contact associated with Opportunity are connected or not.
@creted as a part of P2OB-13775
@Test Class:  ContactAccountRelationCheckTest
*******************************************************************************/

public without sharing class ContactAccountRelationCheck {
    //using below boolean to send the values back to classes
    //True means relation exist and false means no relation
    public static boolean isContactFound = false;
    
/****************************************************************************
@Method Name	: isRelated
@Author			: SFO(SanFrancisco)/Chhaveel
@Sprint 		: 21.09[P2OB-13775]
@CreateDate		: 19/05/2021
@Description	: This Method is to check if contact and account are related or not 
********************************************************************************/       
    public static boolean isRelated(Id AccId, Id ConId){
        // Fetching all the ACR for specific contact
        List<AccountContactRelation> findContact = [SELECT Id, AccountId, ContactId FROM AccountContactRelation where contactId =: ConId];
        For(AccountContactRelation ACR : findContact)
        {            
            if(isContactFound != True){
                if(ACR.AccountId == AccID ){
                    isContactFound = True;
                    //returning true if the contact and Account are already related
                    return isContactFound;
                }
            }
        }
        return isContactFound;
    }
}