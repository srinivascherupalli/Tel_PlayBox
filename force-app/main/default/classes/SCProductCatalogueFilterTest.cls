/***********************************************************************************************************
Name          : SCProductCatalogueFilterTest
Created By    : Mahaboob Basha
Created Date  : Jun 12 2019
Description   : This is a test class to simulate and test the logic of SCProductCatalogueFilter
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        12-06-2019      Created
1.1         Mahaboob        12-06-2019      Added methods filterTest, filterTest1
, getIPSiteBandwidthTest
1.2         nagu            25-0702019      added ngUC test cases
1.3        Pravin K.        04-07-2020      testmethods against adaptive care(DPG-1878)
1.4        Monali M         31-08-2020      testmethods against TMDM(DPG-2228) 
2.0        shubhi V         5-11-2020    EDGE-176833
1.     Pawan Singh         09/08/2021       DIGI-5648    Updated offer name using variable NGUC_OFFER_NAME from Telstra_Collaboration to Adaptive Collaboration
2.		Payel Ganguly		22/09/2021		DIGI-18412   Updated for SDWAN Interconnect related changes
3.		Radhika Uppal		23/09/2021		DIGI-931	Updated for VeloCloud and SecureEdge offer changes
**********************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class SCProductCatalogueFilterTest {
    //EDGE-176833 shubhi start-------------------------------
  @TestSetup
  public static void testSetup(){    
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile where Name in ('System Administrator','PRM Community User - Australia')])
            profilesMap.put(profile.Name, profile);
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName in ('Sales_Ops','CEO')])
            rolesMap.put(role.DeveloperName, role);
        User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                                  emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid =profilesMap.get('System Administrator').id, country='United States',IsActive =true,                
                                  timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=rolesMap.get('CEO').id);
        insert uSysAdmin;
        System.runAs(uSysAdmin){  //EDGE-151595
            
            Account[] acc = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert acc; 
            acc[0].ispartner=true;
            update acc[0];
            
            Contact con = new Contact(LastName ='testCon',AccountId = acc[0].Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Engineering User');//Removing Telstra Collaboration Operations User as Test class was failing as a part of DIGI-18412
            insert con; 
            
            User[] partnerUser = PRMTestUtility.createPartnerUsers(1,new List<Profile>{profilesMap.get('PRM Community User - Australia')} ,new List<Contact>{con} ,false);
            partnerUser[0].alias='PART0820';
            insert partnerUser;
            
            PermissionSet ps = new PermissionSet();
            ps.Name = 'TestLabel';
            ps.Label = 'TestLabel';
            insert ps;
            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = ps.Id;
            sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'Partner_User'][0].Id;
            insert sea;
            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = partnerUser[0].id;
            psa.PermissionSetId = ps.Id;
            insert psa;
            Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account customACC : customerAccount){
                customACC.Customer_Status__c = 'Active';
            }
            insert customerAccount;
            
            List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),customerAccount.get(0).Id);
            for(Contact  customCon : customerContacts){
                customCon.Authority__c = 'Full Authority';
                customCon.Contact_Status__c = 'Active';
                customCon.MobilePhone = '+61123456789';
            }
            insert customerContacts;
           
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(customerAccount[0]);     
            opp.Product_Type__c = 'Modular';
            insert opp; 
            
            List<cscfga__Product_Basket__c> basketLst = new List<cscfga__Product_Basket__c>();
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = customerAccount[0].id;
            basket.csbb__Synchronised_with_Opportunity__c = true;
            basket.cscfga__Opportunity__c = opp.id;
            basket.csordtelcoa__Synchronised_with_Opportunity__c = true; // Added for nullpointer exception
            basketLst.add(basket);
              
            cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
            basket2.csbb__Account__c = customerAccount[0].id;
            basketLst.add(basket2);
            
            insert basketLst;
            
            Marketable_Offer__c mo = new Marketable_Offer__c(OfferDefinationName__c ='SIM',Name = 'SIM',Offer_ID__c = 'DMCAT_Offer_001251',isNonChargeable__c=true,Solution_Template__c='SIM');
      Insert mo;
            
            //EDGE-187319---START
            Profile profileRec = [Select id from Profile where Name = 'Migration BOH user'];
            User migrationBOHUser = new User(alias = 'BOHUser', email='migrationUser@noemail.com',
                                             emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
                                             localesidkey='en_US', profileid =profileRec.id, country='United States',IsActive =true,                
                                             timezonesidkey='America/Los_Angeles', username='migrationUser@noemail.com', userroleid=rolesMap.get('CEO').id);
            insert migrationBOHUser;
            
            Solution_Console_Filter__c solutionConsoleRec = new Solution_Console_Filter__c();
            solutionConsoleRec.Name = 'Adaptive_Mobility';
            solutionConsoleRec.Profile__c = 'Migration BOH user';
            solutionConsoleRec.Opportunity_Type__c = 'Migration';
            insert solutionConsoleRec;
            //EDGE-187319---END
        }
    }
  //EDGE-176833 end----------------------------------------------
    /************************************************************************************ */
  @isTest static  void filterTest() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, NULL);
        Test.stopTest();
        System.assertEquals(definitions, result);
    }
    
    /*************************************************************************************
  * Method Name : filterTest1
  * Description : Used to simulate and test the logic of filter method in SolutionHelper
  * Parameters  : NA
  * Return      : NA                      
  *************************************************************************************/
    @isTest static  void filterTest1() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':""}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(definitions, result);
    }
    
    /*************************************************************************************
  * Method Name : filterTest2
  * Description : Used to simulate and test the logic of filter method in SolutionHelper
  * Parameters  : NA
  * Return      : NA                      
  *************************************************************************************/
    @isTest static  void filterTest2() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(definitions, result);
    }
    
    /*************************************************************************************
  * Method Name : filterTest3
  * Description : Used to simulate and test the logic of filter method in SolutionHelper
  * Parameters  : NA
  * Return      : NA                      
  *************************************************************************************/
    @isTest static  void filterTest3() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(definitions, result);
    }
    
    /*************************************************************************************
  * Method Name : filterTest4
  * Description : Used to simulate and test the logic of filter method in SolutionHelper
  * Parameters  : NA
  * Return      : NA                      
  *************************************************************************************/
    @isTest static  void filterTest4() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(definitions, result);
    }
    
    /*************************************************************************************
* Method Name : filterTest5
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
    @isTest static  void filterTest5() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(definitions, result);
    }
    
    /*************************************************************************************
* Method Name : filterTest6
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
    @isTest static  void filterTest6() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(definitions, result);
    }
    
    /*************************************************************************************
* Method Name : filterTest7
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
    @isTest static  void filterTest7() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Connected Workplace'));
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
        definitions.add(definition);
        cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(true,result.size()>0);
    }
    
    /*************************************************************************************
* Method Name : filterTest7ngUC1
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
    @isTest static  void filterTest7ngUC1() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        //  cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Telstra Collaboration'));  DIGI-5648
        cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Adaptive Collaboration'));
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
        definitions.add(definition);
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        // csord__Solution__c sol = new csord__Solution__c(Name = 'Telstra Collaboration', csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        csord__Solution__c sol = new csord__Solution__c(Name = 'Adaptive Collaboration', csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        INSERT sol;
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = acc.Id;
        UPDATE basket;
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.debug('result::'+result);
        System.debug('filteredDefinitions::'+filteredDefinitions);
        System.assertEquals(filteredDefinitions, result);
    }
    
    /*************************************************************************************
* Method Name : filterTest8
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
    @isTest static  void filterTest8() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Test Sol'));
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
        definitions.add(definition);
    cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(definitions, result);
    }


    //Payel Added: DIGI-18412 : Test method for SDWANInterConnect
/*************************************************************************************
* Method Name : filterTest9SDWANInterCon
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
@isTest static  void filterTest9SDWANInterCon() {
    List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
    cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Interconnect – VMWare SDWAN VPN Solution'));
    List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
    List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
    definitions.add(definition);
    Account acc=[select id from Account where name='TEST_ACCOUNT0'];
    cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1];
    String params = '{"basketId"' + ':"' + basket.Id + '"}';
    cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c (Name = 'VeloCloud SDWAN-VPN Interconnect solution', product_Specification__c = System.Label.SDWAN_Interconnect_Offer ,cscfga__Active__c = true,csordtelcoa__Product_Type__c = 'Subscription',	cscfga__Description__c = 'VeloCloud SDWAN-VPN Interconnect solution');
    	INSERT pd;
        cssdm__Solution_Definition__c sd = new cssdm__Solution_Definition__c(Name = 'VeloCloud SDWAN-VPN Interconnect solution', cssdm__product_definition__c = pd.id);
        INSERT sd;
        csord__Solution__c sol = new csord__Solution__c(Name = 'VeloCloud SDWAN-VPN Interconnect solution', cssdm__product_basket__c = basket.Id, csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12',cssdm__solution_definition__c = sd.id);
        INSERT sol;
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c (Name = 'VeloCloud SDWAN-VPN Interconnect solution', cscfga__Product_Basket__c = basket.Id , cscfga__Product_Definition__c = pd.id);
    	INSERT pc;
        csord__Subscription__c sub = new csord__Subscription__c(Name = 'VeloCloud SDWAN-VPN Interconnect solution', Sub_Status__c='Active',csord__Account__c = acc.Id, csord__Identification__c = '12',csordtelcoa__Product_Configuration__c = pc.id);
    	INSERT sub;
    Test.startTest();
    SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
    result = scFilter.filter(definitions, params);
    Test.stopTest();
    System.assertEquals(definitions, result);
}

//Radhika Added: DIGI-931 : Test method for SecureEdge
/*************************************************************************************
* Method Name : filterTest10SecureEdge
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
@isTest static  void filterTest10SecureEdge() {
    List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
    cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'SecureEdge'));
    List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
    List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
    definitions.add(definition);
    Account acc=[select id from Account where name='TEST_ACCOUNT0'];
    cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1];
    String params = '{"basketId"' + ':"' + basket.Id + '"}';
    cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c (Name = 'SecureEdge', product_Specification__c = System.Label.SECUREEDGE_OFFER ,cscfga__Active__c = true,csordtelcoa__Product_Type__c = 'Subscription',	cscfga__Description__c = 'SecureEdge');
    INSERT pd;
    cssdm__Solution_Definition__c sd = new cssdm__Solution_Definition__c(Name = 'SecureEdge', cssdm__product_definition__c = pd.id);
    INSERT sd;
    csord__Solution__c sol = new csord__Solution__c(Name = 'SecureEdge', cssdm__product_basket__c = basket.Id, csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12',cssdm__solution_definition__c = sd.id);
    INSERT sol;
    cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c (Name = 'SecureEdge', cscfga__Product_Basket__c = basket.Id , cscfga__Product_Definition__c = pd.id);
    INSERT pc;
    csord__Subscription__c sub = new csord__Subscription__c(Name = 'SecureEdge', Sub_Status__c='Active',csord__Account__c = acc.Id, csord__Identification__c = '12',csordtelcoa__Product_Configuration__c = pc.id);
    INSERT sub;
    Test.startTest();
    SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
    result = scFilter.filter(definitions, params);
    Test.stopTest();
    System.assertEquals(definitions, result);
}
//Radhika Added: DIGI-931 : Test method for VeloCloud
/*************************************************************************************
* Method Name : filterTest11VeloCloud
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
@isTest static  void filterTest11VeloCloud() {
    List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
    cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'VeloCloud Tenancy'));
    List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
    List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
    definitions.add(definition);
    Account acc=[select id from Account where name='TEST_ACCOUNT0'];
    cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1];
    String params = '{"basketId"' + ':"' + basket.Id + '"}';
    cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c (Name = 'VeloCloud Tenancy', product_Specification__c = System.Label.VELOCLOUD_OFFER ,cscfga__Active__c = true,csordtelcoa__Product_Type__c = 'Subscription',	cscfga__Description__c = 'VeloCloud Tenancy');
    	INSERT pd;
        cssdm__Solution_Definition__c sd = new cssdm__Solution_Definition__c(Name = 'VeloCloud Tenancy', cssdm__product_definition__c = pd.id);
        INSERT sd;
        csord__Solution__c sol = new csord__Solution__c(Name = 'VeloCloud Tenancy', cssdm__product_basket__c = basket.Id, csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12',cssdm__solution_definition__c = sd.id);
        INSERT sol;
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c (Name = 'VeloCloud Tenancy', cscfga__Product_Basket__c = basket.Id , cscfga__Product_Definition__c = pd.id);
    	INSERT pc;
        csord__Subscription__c sub = new csord__Subscription__c(Name = 'VeloCloud Tenancy', Sub_Status__c='Active',csord__Account__c = acc.Id, csord__Identification__c = '12',csordtelcoa__Product_Configuration__c = pc.id);
    	INSERT sub;
    Test.startTest();
    SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
    result = scFilter.filter(definitions, params);
    Test.stopTest();
    System.assertEquals(definitions, result);
}
    
    /*************************************************************************************
* Method Name : filterTest8ngUC1
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
    @isTest static  void filterTest8ngUC1() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Test Sol'));
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
        definitions.add(definition);
        Account acc=[select id from Account where name='TEST_ACCOUNT0'];
        // csord__Solution__c sol = new csord__Solution__c(Name = 'Telstra Collaboration', csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12'); DIGI-5648
        csord__Solution__c sol = new csord__Solution__c(Name = 'Adaptive Collaboration', csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        INSERT sol;
    cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(definitions, result);
    }
    
    /*************************************************************************************
* Method Name : filterTest9
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
    @isTest static  void filterTest9() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        String params ='{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(definitions, result);
    }
    
    /*************************************************************************************
* Method Name : filterTestPS
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA     
*                 
*************************************************************************************/
    @isTest static  void filterTestPS_WithoutActiveSubscription() {  
        User u = [SELECT Id FROM User WHERE alias = 'PART0820' LIMIT 1];
        Account custAccount=[select id from Account where name='TEST_ACCOUNT0'];
    Account partnerAccount=[select id from Account where name='TEST_Partner_ACCOUNT0'];
        Marketable_Offer__c mo = new Marketable_Offer__c(OfferDefinationName__c ='T-MDM Professional Services',Name = 'T-MDM Professional Services',Offer_ID__c = 'OfferPS');
    Insert mo;
    PS_Solution_Filter__c psf1= new PS_Solution_Filter__c();
    psf1.Check_Active_Subscriptions__c=true;
    psf1.Check_Product_Config__c=true;
    psf1.Enable_for_Partner_Only__c=true;
    psf1.Hide_Default__c=false;
    psf1.Offer_Id__c='OfferPS';
    psf1.Product_Definition_Name__c='T-MDM Professional Services';
    psf1.Name='Test';
    insert psf1;
    Partner_of_Record__c POR = new Partner_of_Record__c(Customer__c=custAccount.Id,Partner__c=partnerAccount.Id,Status__c='Active'); 
        insert POR; 
        System.runAs(u){
            List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
            cssmgnt.SolutionComponent definition1 = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'T-MDM Professional Services'));
            List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
            definitions.add(definition1);
      cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
            String params = '{"basketId"' + ':"' + basket.Id + '"}';
            SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
            result = scFilter.filter(definitions, params);
            Test.startTest();
            System.assert(result.size()>0);
        }
    }
    
    @isTest static  void filterTestPS_WithActiveSubscription() { 
  
        PS_Solution_Filter__c psf1= new PS_Solution_Filter__c();
    psf1.Check_Active_Subscriptions__c=true;
    psf1.Check_Product_Config__c=true;
    psf1.Enable_for_Partner_Only__c=true;
    psf1.Hide_Default__c=false;
    psf1.Offer_Id__c='OfferPS';
    psf1.Product_Definition_Name__c='T-MDM Professional Services';
    psf1.Name='Test';
    insert psf1;
        Account acc=[select id from Account where name='TEST_ACCOUNT0'];

        Marketable_Offer__c mo = new Marketable_Offer__c(OfferDefinationName__c ='T-MDM Professional Services',Name = 'T-MDM Professional Services',Offer_ID__c = 'OfferPS');
    Insert mo;
            
    csord__Subscription__c sol = new csord__Subscription__c(Name = 'T-MDM Professional Services', Sub_Status__c='Active',csord__Account__c = acc.Id,MarketableOffer__c=mo.id,csord__Identification__c = '12');
    INSERT sol;
    
    User u = [SELECT Id FROM User WHERE alias = 'PART0820' LIMIT 1];
    
    System.runAs(u){
      
            List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
            cssmgnt.SolutionComponent definition1 = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'T-MDM Professional Services'));
            List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
            definitions.add(definition1);
      
      cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833

            String params = '{"basketId"' + ':"' + basket.Id + '"}';
             //EDGE-173035 start
            Marketable_Offer__c mo1 = new Marketable_Offer__c();
        mo1.OfferDefinationName__c ='T-MDM Professional Services' ;
        mo1.Name = 'Test MOdf';
        mo1.Offer_ID__c = 'DMCAT_Offer_000303';
    mo1.Contract_Type__c = 'BSA';
        insert mo1;
    
cscfga__Product_Configuration__c oldPC = new cscfga__Product_Configuration__c();
        oldPC.cscfga__Product_Basket__c = basket.id;
        oldPC.name='Connected Workplace Solution';
        oldPC.Type__c='New';
        //oldPC.cscfga__originating_offer__c=offername1.id;
        oldPC.Marketable_Offer__c = mo1.id;//Add Marketable_Offer__c for EDGE-126184 Changes 
        oldPC.ConfigurationType1__c = 'SolutionComponent';
        //productconfiglist.add(oldPC);
        insert oldPC;
            //EDGE-173035 end
            
            SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
            result = scFilter.filter(definitions, params);
            Test.startTest();            
            System.assert(result.size()==0);
            
        }
    }  
    
    
    /*************************************************************************************
* Method Name : filterTestMS
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA     
* EDGE-115836                 
*************************************************************************************/
    @isTest static  void filterTestMS_WithoutActiveSubscription() {  
        
        User u = [SELECT Id FROM User WHERE alias = 'PART0820' LIMIT 1];
        Account custAccount=[select id from Account where name='TEST_ACCOUNT0'];
    Marketable_Offer__c mo = new Marketable_Offer__c(OfferDefinationName__c ='Managed Service',Name = 'Managed Service',Offer_ID__c = 'OfferMS');
    Insert mo;
    PS_Solution_Filter__c psf1= new PS_Solution_Filter__c();
    psf1.Check_Active_Subscriptions__c=true;
    psf1.Check_Product_Config__c=true;
    psf1.Enable_for_Partner_Only__c=true;
    psf1.Hide_Default__c=false;
    psf1.Offer_Id__c='OfferMS';
    psf1.Product_Definition_Name__c='Managed Service';
    psf1.Name='Test';
    insert psf1;
        
        System.runAs(u){
            List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
            cssmgnt.SolutionComponent definition1 = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Managed Service'));
            List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
            definitions.add(definition1);
      
      cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833

            String params = '{"basketId"' + ':"' + basket.Id + '"}';
            
            SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
            result = scFilter.filter(definitions, params);
            Test.startTest();
            
            System.assert(result.size()>0);
            
        }
    } 
    
    @isTest static  void filterTestMS_WithActiveSubscription() {  
    User u = [SELECT Id FROM User WHERE alias = 'PART0820' LIMIT 1];
        Account custAccount=[select id from Account where name='TEST_ACCOUNT0'];
    Account partnerAccount=[select id from Account where name='TEST_Partner_ACCOUNT0'];
    Marketable_Offer__c mo = new Marketable_Offer__c(OfferDefinationName__c ='Managed Service',Name = 'Managed Service',Offer_ID__c = 'OfferMS');
        Insert mo;
    csord__Subscription__c sol = new csord__Subscription__c(Name = 'Managed Service', Sub_Status__c='Active',csord__Account__c = custAccount.Id,MarketableOffer__c=mo.id,csord__Identification__c = '12');
    INSERT sol;
    PS_Solution_Filter__c psf1= new PS_Solution_Filter__c();
    psf1.Check_Active_Subscriptions__c=true;
    psf1.Check_Product_Config__c=true;
    psf1.Enable_for_Partner_Only__c=true;
    psf1.Hide_Default__c=false;
    psf1.Offer_Id__c='OfferMS';
    psf1.Product_Definition_Name__c='Managed Service';
    psf1.Name='Test';
    insert psf1;
      
        System.runAs(u){
            List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
            cssmgnt.SolutionComponent definition1 = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Managed Service'));
            List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
            definitions.add(definition1);
      cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
            String params = '{"basketId"' + ':"' + basket.Id + '"}';
            SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
            result = scFilter.filter(definitions, params);
            Test.startTest();            
            System.assert(result.size()==0);
            
        }
    }   
    
    //Manish Added: DPG-902 : Test method for IoT
    /*************************************************************************************
* Method Name : filterTest9IoT
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
    @isTest static  void filterTest9IoT() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Internet Of Things'));
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
        definitions.add(definition);
        Account acc=[select id from Account where name='TEST_ACCOUNT0'];
    cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        csord__Solution__c sol = new csord__Solution__c(Name = 'Internet Of Things', cssdm__product_basket__c = basket.Id, csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        INSERT sol;
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(definitions, result);
    }
    
    //Prince Added: P2OB-11861 : Test method for BAU_SPC
    /*************************************************************************************
* Method Name : filterTest9BAU_SPC
* Description : Used to simulate and test the logic of filter method in SolutionHelper
* Parameters  : NA
* Return      : NA                      
*************************************************************************************/
    @isTest static  void filterTest9BAU_SPC() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Standard Product Solution'));
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
        definitions.add(definition);
        Account acc=[select id from Account where name='TEST_ACCOUNT0'];
    cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        csord__Solution__c sol = new csord__Solution__c(Name = 'Standard Product Solution', cssdm__product_basket__c = basket.Id, csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        INSERT sol;
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertNotEquals(definitions, result);
    }   
    
    @isTest static  void filterPartnerOffers_withoutPartnerPermision() {
                
    Test.startTest();

        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Professional Service'));
        cssmgnt.SolutionComponent definition1 = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Managed Service'));
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        definitions.add(definition1);
    
    Account acc=[select id from Account where name='TEST_ACCOUNT0'];
    
    List<Marketable_Offer__c> marketableofferlist=new List<Marketable_Offer__c>();
    Marketable_Offer__c mo = new Marketable_Offer__c(OfferDefinationName__c ='Managed Service',Name = 'Managed Service',Offer_ID__c = 'DMCAT_Offer_000854');
    marketableofferlist.add(mo);
    //Opportunity opp =[Select id,name from Opportunity where name = 'testopporunity'];

    Marketable_Offer__c mo1 = new Marketable_Offer__c(OfferDefinationName__c ='Professional Service',Name = 'Professional Service',Offer_ID__c = 'DMCAT_Offer_000936');
    marketableofferlist.add(mo1);
    
    Marketable_Offer__c mo2 = new Marketable_Offer__c(OfferDefinationName__c ='NextGenAdaptiveCareService',Name = 'Next Gen Mobility Adaptive Care',Offer_ID__c = 'DMCAT_Offer_001251');
    marketableofferlist.add(mo2);
    
    Marketable_Offer__c mo3 = new Marketable_Offer__c(OfferDefinationName__c ='MDM Tenancy',Name = 'Telstra Mobile Device Management - VMware',Offer_ID__c = 'DMCAT_Offer_000681');
    marketableofferlist.add(mo3);
    
    Marketable_Offer__c mo4 = new Marketable_Offer__c(OfferDefinationName__c ='NextGenAdaptiveCareService',Name = 'Next Gen Mobility Adaptive Care',Offer_ID__c = 'DMCAT_Offer_001251');
    marketableofferlist.add(mo4); //DIGI-5561 : Rajesh Punabaka
                        
        insert marketableofferlist;
            
    cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
  
    String params = '{"basketId"' + ':"' + basket.Id + '"}';
    
    
    PS_Solution_Filter__c psf1= new PS_Solution_Filter__c();
    psf1.Check_Active_Subscriptions__c=true;
    psf1.Check_Product_Config__c=true;
    psf1.Enable_for_Partner_Only__c=true;
    psf1.Hide_Default__c=false;
    psf1.Offer_Id__c='DMCAT_Offer_000854';
    psf1.Product_Definition_Name__c='Managed Service';
    psf1.Name='Test';
    insert psf1;
    
    PS_Solution_Filter__c psf2= new PS_Solution_Filter__c();
    psf2.Check_Active_Subscriptions__c=true;
    psf2.Check_Product_Config__c=true;
    psf2.Enable_for_Partner_Only__c=true;
    psf2.Offer_Id__c='DMCAT_Offer_000936';
    psf2.Product_Definition_Name__c='Professional Service';
    psf2.Name='Test1';
    insert psf2;
    
    PS_Solution_Filter__c psf3= new PS_Solution_Filter__c();
    psf3.Check_Active_Subscriptions__c=false;
    psf3.Check_Product_Config__c=false;
    psf3.Enable_for_Partner_Only__c=true;
    psf3.Offer_Id__c='DMCAT_Offer_001251';
    psf3.Product_Definition_Name__c='Next Gen Mobility Adaptive Care';
    psf3.Name='AdaptiveCare Service';
    insert psf3;
    
    PS_Solution_Filter__c psf4= new PS_Solution_Filter__c();
    psf4.Check_Active_Subscriptions__c=false;
    psf4.Check_Product_Config__c=false;
    psf4.Enable_for_Partner_Only__c=true;
    psf4.Offer_Id__c='DMCAT_Offer_000681';
    psf4.Product_Definition_Name__c='Telstra Mobile Device Management - VMware';
    psf4.Name='TMDM Service';
    insert psf4;
    
    SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
    result = scFilter.filter(definitions, params);
    system.debug('result'+result);
    
    //List<cssmgnt.SolutionComponent> emptysollist = new List<cssmgnt.SolutionComponent>();
    //System.assert(result.size()==0);
    System.assertNotEquals(result, null);
            
        Test.stopTest();
    }
    
    @isTest static  void filterPartnerOffers_withPartnerPermision() 
    {  
        Account acc=[select id from Account where name='TEST_ACCOUNT0'];
    Marketable_Offer__c mo = new Marketable_Offer__c(OfferDefinationName__c ='Professional Services-MDM Config',Name = 'Professional Services-MDM Config',Offer_ID__c = 'DMCAT_Offer_000750');
    Insert mo;
    csord__Subscription__c sol = new csord__Subscription__c(Name = 'Professional Services Solution', Sub_Status__c='Active',csord__Account__c = acc.Id,MarketableOffer__c=mo.id,csord__Identification__c = '12');
    INSERT sol;
        User u = [SELECT Id FROM User WHERE alias = 'PART0820' LIMIT 1];

        System.runAs(u){
            List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
            cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Professional Services'));
            cssmgnt.SolutionComponent definition1 = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Managed Service'));
            cssmgnt.SolutionComponent definition2 = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Professional Services'));
            List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
            definitions.add(definition);
            definitions.add(definition1);
            definitions.add(definition2);
           
            cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
      
            String params = '{"basketId"' + ':"' + basket.Id + '"}';
            
            SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
            result = scFilter.filter(definitions, params);
            Test.startTest();
            
            System.assert(result.size()>0);
            
        }
    }
    /*******************************************************************************************************
* Method Name : adaptiveCare_filterOffers_withoutPartnerPermision
* EDGE - DPG-1878
* Parameters  : NA
* Return      : NA
*******************************************************************************************************/
    @isTest static  void adaptiveCare_filterOffers_withoutPartnerPermision() {           
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Next Gen Mobility Adaptive Care'));
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        definitions.add(definition);
    Marketable_Offer__c mo2 = new Marketable_Offer__c(OfferDefinationName__c ='NextGenAdaptiveCareService',Name = 'Next Gen Mobility Adaptive Care',Offer_ID__c = 'DMCAT_Offer_001251');
    Insert mo2;
    cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
    String params = '{"basketId"' + ':"' + basket.Id + '"}';
    
    PS_Solution_Filter__c psf3= new PS_Solution_Filter__c();
    psf3.Check_Active_Subscriptions__c=false;
    psf3.Check_Product_Config__c=false;
    psf3.Enable_for_Partner_Only__c=true;
    psf3.Offer_Id__c='DMCAT_Offer_001251';
    psf3.Product_Definition_Name__c='Next Gen Mobility Adaptive Care';
    psf3.Name='AdaptiveCare Service';
    insert psf3;
    
    Test.startTest();
    SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
    result = scFilter.filter(definitions, params);
    system.debug('result'+result);
    Test.stopTest();
    //List<cssmgnt.SolutionComponent> emptysollist = new List<cssmgnt.SolutionComponent>();
    //System.assert(result.size()==0);
    System.assertnotequals(psf3,null);
       
    }
    /*******************************************************************************************************
* Method Name : adaptiveCare_filterOffers_withPartnerPermision
* EDGE - DPG-1878
* Parameters  : NA
* Return      : NA
*******************************************************************************************************/ 
    @isTest static  void adaptiveCare_filterOffers_withPartnerPermision() 
    {  
        User u = [SELECT Id FROM User WHERE alias = 'PART0820' LIMIT 1];
        Account acc=[select id from Account where name='TEST_ACCOUNT0'];
    Marketable_Offer__c mo = new Marketable_Offer__c(OfferDefinationName__c ='NextGenAdaptiveCareService',Name = 'Next Gen Mobility Adaptive Care',Offer_ID__c = 'DMCAT_Offer_001251');
    Insert mo;
    csord__Subscription__c sol = new csord__Subscription__c(Name = 'Next Gen Mobility Adaptive Care', Sub_Status__c='Active',csord__Account__c = acc.Id,MarketableOffer__c=mo.id,csord__Identification__c = '12');
    INSERT sol;
        System.runAs(u){
            List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
            cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Next Gen Mobility Adaptive Care'));
            List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
            definitions.add(definition);
      cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
            String params = '{"basketId"' + ':"' + basket.Id + '"}';
            Test.startTest();
            SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
            result = scFilter.filter(definitions, params);
           
            Test.stopTest();
            
            System.assert(result.size()>0);
            
        }
    }
    
    /*******************************************************************************************************
* Method Name : TMDM_filterOffers_withoutPartnerPermision
* EDGE - DPG-2228
* Parameters  : NA
* Return      : NA
*******************************************************************************************************/
    @isTest static  void TMDM_filterOffers_withoutPartnerPermision() {           
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Telstra Mobile Device Management - VMware'));
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        definitions.add(definition);
    Marketable_Offer__c mo2 = new Marketable_Offer__c(OfferDefinationName__c ='MDM Tenancy',Name = 'Telstra Mobile Device Management - VMware',Offer_ID__c = 'DMCAT_Offer_000681');
    Insert mo2;
    cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
    String params = '{"basketId"' + ':"' + basket.Id + '"}'; 
    PS_Solution_Filter__c psf3= new PS_Solution_Filter__c();
    psf3.Check_Active_Subscriptions__c=false;
    psf3.Check_Product_Config__c=false;
    psf3.Enable_for_Partner_Only__c=true;
    psf3.Offer_Id__c='DMCAT_Offer_000681';
    psf3.Product_Definition_Name__c='Telstra Mobile Device Management - VMware';
    psf3.Name='TMDM Service';
    insert psf3;
    
    Test.startTest();
    SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
    result = scFilter.filter(definitions, params);
    system.debug('result'+result);
    Test.stopTest();
    System.assertnotequals(psf3,null);
        
    }
  
        /*******************************************************************************************************
        * Method Name : TMDM_filterOffers_withPartnerPermision
        * EDGE - DPG-2228
        * Parameters  : NA
        * Return      : NA
        *******************************************************************************************************/ 
    @isTest static void TMDM_filterOffers_withPartnerPermision() 
    {  
    User u = [SELECT Id FROM User WHERE alias = 'PART0820' LIMIT 1];
        Account custAccount=[select id from Account where name='TEST_ACCOUNT0'];
        Marketable_Offer__c mo = new Marketable_Offer__c(OfferDefinationName__c ='MDM Tenancy',Name = 'Telstra Mobile Device Management - VMware',Offer_ID__c = 'DMCAT_Offer_000681');
        Insert mo;
        csord__Subscription__c sol = new csord__Subscription__c(Name = 'Telstra Mobile Device Management - VMware_700001346944', Sub_Status__c='Active',csord__Account__c = custAccount.Id,MarketableOffer__c=mo.id,csord__Identification__c = '12');
        INSERT sol;
        System.runAs(u){
            List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
            cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Telstra Mobile Device Management - VMware'));
            List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
            definitions.add(definition);
            cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
            String params = '{"basketId"' + ':"' + basket.Id + '"}';
            Test.startTest();
            SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
            result = scFilter.filter(definitions, params);
            Test.stopTest();
            System.assert(result.size()>0);
            //System.assertnotequals(sol,null);
        }
    }
  //EDGE-176833 start -----------------
    @isTest static void testNonCommercialPositive() 
    {  
        Account acc=[select id from Account where name='TEST_ACCOUNT0'];
    
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'SIM'));
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        definitions.add(definition);
        cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        
        Test.stopTest();
        
        System.assert(result.size()>0);
            
    }
  //EDGE-176833 end --------------------
  
    @isTest static  void testFilterForNonModular() {
        List<cssmgnt.SolutionComponent> result = new List<cssmgnt.SolutionComponent>();
        cssmgnt.SolutionComponent definition = new cssmgnt.SolutionComponent(new cssdm__Solution_Definition__c(Name = 'Standard Product Solution'));
        List<cssmgnt.SolutionComponent> definitions = new List<cssmgnt.SolutionComponent>();
        List<cssmgnt.SolutionComponent> filteredDefinitions = new List<cssmgnt.SolutionComponent>();
        definitions.add(definition);
        Opportunity testOpp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Name = 'TestOpp'];
        testOpp.Product_Type__c = 'Non Modular';
        update testOpp;
        cscfga__Product_Basket__c basket = [Select id from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1]; // edge-176833
        String params = '{"basketId"' + ':"' + basket.Id + '"}';
        Test.startTest();
        SCProductCatalogueFilter scFilter = new SCProductCatalogueFilter();
        result = scFilter.filter(definitions, params);
        Test.stopTest();
        System.assertEquals(true,result.size()>0);
    }
}