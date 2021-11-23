/****************************************************************************************************************************************************
Main Class : CustomButtonSubmitOrder
Test Class : CustomButtonSubmitOrderTest
=====================================================================================================================================================
Sr.No.    Developer Name      Date            Story                       Description
1.        Akanksha Jain		  6-10-2020		  EDGE-182456 				  Get account contact relation on product basket
=====================================================================================================================================================
******************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class getACROnProdBasketTest {
	  @TestSetup
      private static void testSetup(){
       	Account acc=TestUtil.createAccount('Test Account');
        insert acc;
        System.assertNotEquals(null,acc);
          
        Account acc1  = TestUtil.createAccount('Test Account1'); 
        insert acc1;
        
        Contact con = new Contact(LastName = 'ConTest');
        con.AccountId=acc.id;
        insert con;
         
        AccountContactRelation ACR = new AccountContactRelation();
        ACR.ContactId = con.Id;
        ACR.AccountId = acc1.Id;
        ACR.Roles = 'Full Authority';
        insert ACR;
     }
    @isTest
     public static void fetchLookUpValues()
     {
        Account acc = [Select Id From Account where Name = 'Test Account1'];
         Map<String, String> params = new Map<String, String>{'id'=>'','orderByCriteria' =>''};
        Test.startTest();
        String queryRes = getACROnProdBasket.query(params,acc.ID);
        Test.stopTest();   
       System.assert(queryRes != null);
    }
}