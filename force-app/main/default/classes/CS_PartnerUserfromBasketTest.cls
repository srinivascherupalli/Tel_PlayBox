/*****************************************************************
@Name: CS_PartnerUserfromBasketTest
@Author: RaviTeja K
@CreateDate: 31/01/2020 
@Description: This is the Test class for CS_PartnerUserfromBasket
******************************************************************/ 
@isTest
public class CS_PartnerUserfromBasketTest {
    @testsetup static void CS_PartnerUserfromBasketTestDataSetup()
    {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
         profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
               User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
           id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
        insert uSysAdmin;
        
          System.runAs(uSysAdmin){  
            
            list<account> acclist= new list<account>();
                                     id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Opp_RecordType_Enterprise).getRecordTypeId();
                                     id PartnerrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            Contact contact = new Contact(
            LastName = 'Last', FirstName = 'First', Contact_Role__c = 'Consultant', OTP_Mobile_Phone_Number__c = '+612345678', Email = 'test@tele2.com', Contact_Status__c = 'Active');
            EnvironmentalSettings.isTriggerDisabled('ContactTrigger');
            Insert contact;
            
            account partneracc = new Account();
            partneracc.RecordTypeId = PartnerrecordTypeId ;
            partneracc.Name='Partner acc';
            partneracc.Account_Status__c = 'Active';
            partneracc.Customer_Trading_Name__c = 'Test';
            partneracc.ABN__c='aaaa';
            partneracc.ACN__c='ccc';
            partneracc.State_Coverage__c = 'VIC';
            partneracc.Partner_Type__c='Partner';
            partneracc.Website = 'www.vsygqwoci.com';
            partneracc.Phone='0412354323';
            partneracc.Overall_Accreditation__c='Platinum';
            partneracc.Mobility_Accreditation__c='Platinum';
            partneracc.Cloud_Accreditation__c='Platinum';
            partneracc.Data_Security_Accreditation__c='Platinum';
            partneracc.Collaboration_Accreditation__c='Platinum';
            partneracc.PartnerPrincipalContact__c = Contact.id;
                 
             Account EnterPriseacc = AccountTestFactory.buildAccount('Test Enterprise');
             EnterPriseacc.Customer_Status__c = 'ACTIVE';    
             EnterPriseacc.recordTypeId=recordTypeId;
             
             acclist.add(Partneracc);
             acclist.add(EnterPriseacc);
             insert acclist;               
                         
             Contact con = new Contact(LastName ='testCon',AccountId = Partneracc.Id,Partner_Role__c='MDM Operations User', Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG');
             insert con;  
             
             Partneracc.ispartner=true;
             update Partneracc;
             
             list<user> userlist= new list<user>();
             User pdua = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', Profileid = prmAdmin , country='United States',IsActive =true,
                                    timezonesidkey='America/Los_Angeles', FederationIdentifier='P34533',username='b2btestewwrpdua@noemail.com',contactid=con.id);
             insert pdua ;
    }
    }
    
  static testmethod void doLookupSearchTest()
    {
            account partneracc=[select id from account where name='Partner acc' limit 1];
            account EnterPriseacc=[select id from account where name='Test Enterprise' limit 1];
               
              Opportunity opp = ProductTestFactory.getOpportunityBasic(EnterPriseacc);
              opp.partneraccountid=partneracc.id;
              insert opp;
              
                    cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(EnterPriseacc);
                    basket.cscfga__opportunity__c=opp.id;
                    update basket;
                    Map<String, String> searchFields= new Map<String, String>();
                    searchFields.put('basketId',basket.Id);
                    searchFields.put('OfferName','T-MDM Professional Services');
                            CS_PartnerUserfromBasket usrFromAccBas = new CS_PartnerUserfromBasket();

                    string str = usrFromAccBas.getRequiredAttributes();
                List<User> lstuser = (List<User>)usrFromAccBas.doLookupSearch(searchFields, null, null, null, null);
                system.assert(lstuser.size()>0);
     }
     
     static testmethod void doLookupSearchTestNegativecase()
    {
            account partneracc=[select id from account where name='Partner acc' limit 1];
            account EnterPriseacc=[select id from account where name='Test Enterprise' limit 1];
               
              Opportunity opp = ProductTestFactory.getOpportunityBasic(EnterPriseacc);
              opp.partneraccountid=partneracc.id;
              insert opp;
              
                    cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(EnterPriseacc);
                    basket.cscfga__opportunity__c=opp.id;
                    update basket;
                    Map<String, String> searchFields= new Map<String, String>();
                    searchFields.put('basketId',basket.Id);
                    searchFields.put('OfferName','Test');
                            CS_PartnerUserfromBasket usrFromAccBas = new CS_PartnerUserfromBasket();

                    string str = usrFromAccBas.getRequiredAttributes();
                List<User> lstuser = (List<User>)usrFromAccBas.doLookupSearch(searchFields, null, null, null, null);
                system.assert(lstuser==null);
     }
            
   }