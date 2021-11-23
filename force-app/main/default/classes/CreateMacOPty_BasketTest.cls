/*********************************************************************************************************************************
 *Class Name      :   CreateMacOPty_Basket

Test Class : CreateMacOPty_BasketTest
===============================================================================================================================
Ch.No.    Developer Name          Date          Story Description
8.  	  shubhi V              21/07/2020      EDGE-154023(new component)
*********************************************************************************************************************************
*/
@isTest
public class CreateMacOPty_BasketTest {
    @TestSetup static void dataSetup()
    {
        Account testAccount = AccountTestFactory.buildAccount('testAccount');
        insert testAccount;
        
        Contact con = AccountTestFactory.buildContact(testAccount,'test last name');
        insert con;
        
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    		User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
    }
    
    @isTest
    static void createmacOptyBasketTest(){
        Test.startTest();
        Account acc=[Select id from account];
        Contact con=[Select id from contact];
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        acc.ownerid=sales.id;
        update acc;
        System.runAs(sales){
           String basketId = CreateMacOPty_Basket.CreateMacOPtyAndBasket(con.id,acc.id);
           cscfga__Product_Basket__c basket=[Select id,csordtelcoa__Account__c from cscfga__Product_Basket__c where id=:basketId];
           System.assert(true,basket.csordtelcoa__Account__c==acc.id); 
        }       
        Test.stopTest();
    }
    @isTest
    static void checkisBillingAccountNegative(){
        Test.startTest();
        Account acc=[Select id,ownerid from account];
        Contact con=new Contact();        
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com']; 
       
        System.runAs(sales){
           String basketId = CreateMacOPty_Basket.CreateMacOPtyAndBasket(con.id,acc.id);
           System.assert(true,basketId==null); 
        }       
        Test.stopTest();
    }
    @IsTest static void getOpportunityMigrationTest(){
        Test.startTest();
        Account acc=[Select id,ownerid from account];
        User sales = [SELECT id,name,profileid FROM User Where username='salesunifieduser@testsales.com']; 
        Profile pf = [select id from profile where name ='Migration BOH user'];
        sales.profileid=pf.id;
        update sales;
        System.runAs(sales){
            opportunity opp=CreateMacOPty_Basket.getOpportunity(acc.Id);
            system.assertEquals('Migration', opp.Type);
        }
        Test.stopTest();
    }

}