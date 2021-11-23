/*************************************************************************************************
Name : sobjectFactory 
Description :  Generic class to insert any object using unit of work taking record/records of particular object type
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Shubhi             28-Oct-2020   EDGE-182452(new)
===============================================================================================================================
***************************************************************************************************/
@isTest
public class SobjectFactoryTest {
    @testSetup 
    public static void setup(){
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username=uniquename+'_salesunifieduser@testsales.com',phone='+121231231234');
       	insert sales;
        Account testAccount = AccountTestFactory.buildAccount('testAccount');
        //testAccount.ownerid=sales.id;
        insert testAccount;
    }
    @isTest
    public static void testinsertSobject(){  
        Test.startTest();
        User crmuser = [select id from user where email='salesuser@testsales.com' limit 1];
        Account custAccount=[select id,ownerid from Account where name='testAccount' limit 1];
        Id accId = custAccount.Id;  
   		custAccount.OwnerId=crmuser.id;
        update custAccount;
   		System.runAs(crmuser){
          String basketId = NonCommercialOrder.CreateNonCommercialBasket(accId);
          cscfga__Product_Basket__c basket=[select id,BasketType__c from cscfga__Product_Basket__c limit 1];
          System.assertEquals(Label.Non_Commercial,basket.BasketType__c);      
        }
        Test.stopTest();
    }
    @isTest
    public static void testinsertSobjectNegative(){  
        Test.startTest();
        Id accId ;  
        User crmuser = [select id from user where email='salesuser@testsales.com' limit 1];
        System.runAs(crmuser){
          String basketId = NonCommercialOrder.CreateNonCommercialBasket(accId);
          System.assertEquals('',basketId);      
        }
        Test.stopTest();
    }
    @isTest
    public static void testinsertSobjectCatch(){
        Test.startTest();
        User crmuser = [select id from user where email='salesuser@testsales.com' limit 1];
        Account custAccount=[select id,ownerid from Account where name='testAccount' limit 1];
        Id accId = custAccount.Id;
   		System.runAs(crmuser){
            try{
                String basketId = NonCommercialOrder.CreateNonCommercialBasket(accId);
         	 	cscfga__Product_Basket__c basket=[select id,BasketType__c from cscfga__Product_Basket__c limit 1];
          		System.assertEquals(Label.Non_Commercial,basket.BasketType__c);
            }catch(exception e){
                System.debug('exception'+e);
            }
        }
        Test.stopTest();
    }

      @isTest
    public static void testinsertListSobject(){  
        Test.startTest();
         list<Account> testAccountList= new  list<Account>();
         Account testAccount = AccountTestFactory.buildAccount('testAccount');
         Account testAccount1 = AccountTestFactory.buildAccount('testAccount');
         testAccountList.add(testAccount);
         testAccountList.add(testAccount1);
          string returnValue= SobjectFactory.insertSobjectList(testAccountList);
          System.assertEquals('Success',returnValue);      
        Test.stopTest();
    }

}