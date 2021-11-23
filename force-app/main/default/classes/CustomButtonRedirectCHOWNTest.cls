/*************************************************************************************************
Name : CustomButtonRedirectCHOWN
TestClass:CustomButtonRedirectCHOWNTest
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.        Shubhi V            22-Feb-2021       EDGE-152457(new chown)
===============================================================================================================================
***************************************************************************************************/
@isTest
public class CustomButtonRedirectCHOWNTest {
    @TestSetup
	public static void testSetup(){
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        List<User> listOfUsers = new List<User>();
        Profile pf  = [select id from profile where name = 'Assurance Service Agent'];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'saleEnt', Email='SalesEnterpriseUnified@test.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName=uniquename+'testpermissionsetuser@test.com');
        listOfUsers.add(u);

        User asauser = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                                  lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                                  profileid = pf.id,
                                  timezonesidkey='Australia/Sydney',
                                  username=uniquename+'_salesunifieduser@testsales.com',phone='+121231231234');
        listOfUsers.add(asauser);
        Insert listOfUsers;
        System.runAs(u){
            
        	List<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('OneFund_Admin')];
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for(PermissionSet ps: psList){
                PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = asauser.id, PermissionSetId = ps.Id);
                psaList.add(psa);
            }   
            if(!psaList.isEmpty()){
                insert psaList; 
            }
       	}
        //////////////////////////////
		//Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211231');
		List<Account> accList=new List<Account>();
        Account incomingAcc = AccountTestFactory.buildAccount ('Incoming');
        Account outgoingAcc = AccountTestFactory.buildAccount ('Outgoing');
        insert (new List<Account>{incomingAcc,outgoingAcc});
        
		List<Opportunity> oppList=new List<Opportunity>();
        Opportunity INopp = ProductTestFactory.getOpportunityBasic(incomingAcc);
        Opportunity Outopp = ProductTestFactory.getOpportunityBasic(outgoingAcc);
        insert (new List<Opportunity>{INopp,Outopp});
        
        list<cscfga__Product_Basket__c> prodBasList= new list<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c prodBas1= new cscfga__Product_Basket__c();
        prodBas1.BasketType__c = 'Outgoing';
        prodBas1.csbb__Account__c=outgoingAcc.id;
        prodBasList.add(prodBas1); 
        cscfga__Product_Basket__c prodBas2= new cscfga__Product_Basket__c();
        prodBas2.BasketType__c = 'Incoming';
        prodBas2.csbb__Account__c=incomingAcc.id;
        prodBasList.add(prodBas2); 
        insert prodBasList;
        prodBas2.csordtelcoa__Previous_Product_Basket__c=prodBas1.id;
        update prodBas2;
        /////////////////////////
        
    }
    
    @isTest
     static void redirectOutgoingTest(){
        Test.startTest();
        User asauser = [SELECT id,name FROM User Where Email='SalesEnterpriseUnified@test.com'];
         System.runAs(asauser){
        	cscfga__Product_Basket__c productBasket=[Select id,Project_Complexity__c,csbb__Account__c from cscfga__Product_Basket__c where BasketType__c = 'Outgoing' limit 1];
        	CustomButtonRedirectCHOWN rdchown=new CustomButtonRedirectCHOWN();
             String returnString=rdchown.performAction(productBasket.id);
        	System.assertEquals(returnString.contains(productBasket.csbb__Account__c), true);
        }
        Test.stopTest();
    }
    @isTest
     static void redirectIncomingTest(){
        Test.startTest();
        User asauser = [SELECT id,name FROM User Where Email='SalesEnterpriseUnified@test.com'];
         System.runAs(asauser){
        	cscfga__Product_Basket__c productBasket=[Select id,csbb__Account__c,csordtelcoa__Previous_Product_Basket__r.csbb__Account__c from cscfga__Product_Basket__c where  BasketType__c = 'Incoming' limit 1];
        	CustomButtonRedirectCHOWN rdchown=new CustomButtonRedirectCHOWN();
             String returnString=rdchown.performAction(productBasket.id);
        	System.assertEquals(returnString.contains(productBasket.csordtelcoa__Previous_Product_Basket__r.csbb__Account__c), true);
        }
        Test.stopTest();
    }
    @isTest
     static void redirectIncomingNegative(){
        Test.startTest();
        User asauser = [SELECT id,name FROM User Where Email='SalesEnterpriseUnified@test.com'];
         System.runAs(asauser){
             CustomButtonRedirectCHOWN rdchown=new CustomButtonRedirectCHOWN();
        	String returnString=rdchown.performAction('');
        	System.assertEquals(returnString.contains('Error'),true);
        }
        Test.stopTest();
    }

}