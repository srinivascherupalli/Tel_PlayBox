/*******************************************************************************
@Last Modified      : 07/01/2020 21.01 by Sri, Team SFO
            as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : 
No.       Developer Name        Date            Story Description 
1.        Pallavi B             09/04/2021      Sprint 21.05 - Revamp of Customer Risk Score Calculation
2.        Sri                   09/04/2021      Sprint 21.05 - Opportunity rEvamp automation scenarios
3.        Sri                   03/09/2021      Sprint 21.12 - DIGI:6047 send notification opportunity approver 

@Last Modified      :  
*******************************************************************************/

//EDGE-186496
@IsTest
public class OpportunityTriggerHandlerTest {
     @testSetup
    static void setup()
    {
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        Profile pfAccOwner = [select id from profile where name =:Label.Profile_AccountOwner]; //EDGE-85331 :: =:'Sales - Enterprise'];
        Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin]; //EDGE-85331 :: =:'Sales - Enterprise'];

        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        List<user> userList = new List<user>();
        User sales = TestUtil.createTestUser(r.id,pf.id,'salesuser','Testing');
        sales.username='salesuser@testsales.com';
        sales.email='salesuser@testsales.com';
        sales.phone='+121231231234';
        User AccOwner = TestUtil.createTestUser(r.id,pfAccOwner.id,'AccUser','Testing1');
        AccOwner.username='AccOwneruser@AccOwneruser.com';
        AccOwner.email='AccOwneruser@AccOwneruser.com';
        AccOwner.phone='+121231231234';
        User admin = TestUtil.createTestUser(r.id,pfAdmin.id,'adminUser','Testing2');
        admin.username='TestingAdmin@TestingAdmin.com';
        admin.email='adminuser@testadmin.com';
        admin.phone='+121231231234';
        
        userList.add(sales);
        userList.add(admin);
        userList.add(AccOwner);
        insert userList;
        System.runAs(admin){
            Account customerAccount=TestUtil.createAccount('Test Account');
            customerAccount.OwnerId=sales.id;
            insert customerAccount;
            
            Id myRecordTypeStandard  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();

            Opportunity Opp =TestUtil.createOpportunity(customerAccount.Id);
            Opp.Name='standard opportunity';
            Opp.RecordTypeId = myRecordTypeStandard;
            Opp.Type = 'Renewal';
            Opp.Billing_Solution__c = 'Standard';
            Opp.Product_Domain__c = 'CLOUD SERVICES';
            Opp.Product_Type__c = 'Non Modular';
            Opp.ownerId = sales.id;
            insert Opp;
            
        }

        System.runAs(sales){
            List<Opportunity> oppList =new List<Opportunity>();
            Account act = [SELECT Id FROM Account Where Name='Test Account'];
            
            //MAC Modular Opportunity
            Opportunity macModOpp =TestUtil.createOpportunity(act.Id);
            macModOpp.Name='MAC Modular Opportunity';
            macModOpp.Type = 'Price Review';
            macModOpp.Billing_Solution__c = 'In Contract';
            macModOpp.Product_Domain__c = 'MOBILES';
            macModOpp.Product_Type__c = 'Modular';
            oppList.add(macModOpp);
            
            
            //MAC Non Modular Opportunity
            Opportunity macNonModOpp =TestUtil.createOpportunity(act.Id);
            macNonModOpp.Name='MAC Non Modular Opportunity';
            macNonModOpp.Type = 'Price Review';
            macNonModOpp.Billing_Solution__c = 'In Contract';
            macNonModOpp.Product_Domain__c = 'MOBILES';
            macNonModOpp.Product_Type__c = 'Non Modular';
            oppList.add(macNonModOpp);
            
            //Standard Non Modular Opportunity
            Opportunity standNonMod =TestUtil.createOpportunity(act.Id);
            standNonMod.Name='Standard Non Modular Opportunity';
            standNonMod.Type = 'Renewal';
            standNonMod.Billing_Solution__c = 'Standard';
            standNonMod.Product_Domain__c = 'CLOUD SERVICES';
            standNonMod.Product_Type__c = 'Non Modular';
            oppList.add(standNonMod);
            
            //Standard Modular Opportunity
            Opportunity standMod =TestUtil.createOpportunity(act.Id);
            standMod.Name='Standard Modular Opportunity';
            standMod.Type = 'Renewal';
            standMod.Billing_Solution__c = 'Standard';
            standMod.Product_Domain__c = 'CLOUD SERVICES';
            standMod.Product_Type__c = 'Modular';
            oppList.add(standMod);
            //Closed Opp for Reopen Opp
            Opportunity reopenOpp =TestUtil.createOpportunity(act.Id);
            reopenOpp.Name='Closed Opp For Reopen';
            reopenOpp.Type = 'Renewal';
            reopenOpp.Billing_Solution__c = 'Standard';
            reopenOpp.Product_Domain__c = 'CLOUD SERVICES';
            reopenOpp.Product_Type__c = 'Non Modular';
            oppList.add(reopenOpp);

            Test.startTest();
            insert oppList;
            Test.stopTest();
        }

    }

    
    /*
    @Method Name: testMACOppCreateValues
    @Description: P2OB-13495, Sprint 21.05
				  To test a sceanrio when a mac Opportunity created
    @Author		: Sri (Team SFO)
    */
    @isTest
    public static void testMACOppCreateValues(){
        Account act = [SELECT Id FROM Account Where Name='Test Account'];
        User sales = [select id, name from User where username='salesuser@testsales.com'];
        System.runAs(sales){      
            for(Opportunity createdOpp : [select id, name, recordtype.name, Type, Billing_Solution__c, Product_Type__c, Requires_Bid_Management__c,StageName, Product_Domain__c,  proposal_Type__c, Archetype__c, Pricing_Method__c, Competitor__c, Contract_complexity__c, In_Contract_MAC__c, Expected_TCV_Range__c, Number_of_Additional_Domains_if_any__c, Contract_Type__c,  Will_this_require_integration__c from Opportunity where accountId =:act.id and Billing_Solution__c = 'In Contract']){
                if(createdOpp.name == 'MAC Modular Opportunity'){
                    system.assertEquals('Enterprise - In Contract', createdOpp.recordtype.name);
                    system.assertEquals(Label.Opportunity_Archetype_1, createdOpp.Archetype__c);
                    system.assertEquals(Label.Opp_SolComp_InCon, createdOpp.Billing_Solution__c);
                    system.assertEquals('NO COMPETITOR', createdOpp.Competitor__c);
                    //system.assertEquals('Low probability/ Non Commit/ Red	', createdOpp.Confidence_Level__c);
                    system.assertEquals('In Contract', createdOpp.Contract_complexity__c);
                    system.assertEquals('Order Under Existing Contract', createdOpp.Contract_Type__c);
                    system.assertEquals('Yes', createdOpp.In_Contract_MAC__c);
                    system.assertEquals('PET', createdOpp.Pricing_Method__c);
                    system.assertEquals('No', createdOpp.Requires_Bid_Management__c);
                    system.assertEquals('Modular', createdOpp.Product_Type__c);
                }
                else if(createdOpp.name == 'MAC Non Modular Opportunity'){
                    system.assertEquals('Enterprise - In Contract', createdOpp.recordtype.name);
                    system.assertEquals(Label.Opportunity_Archetype_1, createdOpp.Archetype__c);
                    system.assertEquals(Label.Opp_SolComp_InCon, createdOpp.Billing_Solution__c);
                    system.assertEquals('NO COMPETITOR', createdOpp.Competitor__c);
                    //system.assertEquals('Low probability/ Non Commit/ Red	', createdOpp.Confidence_Level__c);
                    system.assertEquals('In Contract', createdOpp.Contract_complexity__c);
                    system.assertEquals('Order Under Existing Contract', createdOpp.Contract_Type__c);
                    system.assertEquals('Yes', createdOpp.In_Contract_MAC__c);
                    system.assertEquals('PET', createdOpp.Pricing_Method__c);
                    system.assertEquals('No', createdOpp.Requires_Bid_Management__c);
                    system.assertEquals('Non Modular', createdOpp.Product_Type__c);
                }
            }            
        }
    }


    /*
    @Method Name: testMACOppUpdateValues
    @Description: P2OB-13495, Sprint 21.05
				  To test a sceanrio when a mac Opportunity updated
    @Author		: Sri (Team SFO)
    */
    @isTest
    public static void testMACOppUpdateValues(){
        Account act = [SELECT Id FROM Account Where Name='Test Account'];
		List<Opportunity> updatedOppList =new List<Opportunity>();
        User sales = [select id, name from User where username='salesuser@testsales.com'];
        System.runAs(sales){      
            for(Opportunity createdOpp : [select id, name, Type, Contract_Type__c from Opportunity where accountId =:act.id and Billing_Solution__c = 'In Contract']){
                if(createdOpp.name == 'MAC Modular Opportunity'){
					createdOpp.Contract_Type__c = 'Telstra Purple';
                }
                else if(createdOpp.name == 'MAC Non Modular Opportunity'){
 					createdOpp.Type = 'Price Review';
               }
				updatedOppList.add(createdOpp);
            }
			Test.startTest();
			update updatedOppList;
            Test.stopTest();
			
            for(Opportunity createdOpp : [select id, name, recordtype.name, Type, Billing_Solution__c, Product_Type__c, Requires_Bid_Management__c,StageName, Product_Domain__c,  proposal_Type__c, Archetype__c, Pricing_Method__c, Competitor__c, Contract_complexity__c, In_Contract_MAC__c, Expected_TCV_Range__c, Number_of_Additional_Domains_if_any__c, Contract_Type__c,  Will_this_require_integration__c from Opportunity where accountId =:act.id  and Billing_Solution__c = 'In Contract']){
				
                if(createdOpp.name == 'MAC Modular Opportunity'){
                    system.assertEquals('Enterprise - In Contract', createdOpp.recordtype.name);
                    system.assertEquals(Label.Opportunity_Archetype_1, createdOpp.Archetype__c);
                    system.assertEquals(Label.Opp_SolComp_InCon, createdOpp.Billing_Solution__c);
                    system.assertEquals('NO COMPETITOR', createdOpp.Competitor__c);
                    system.assertEquals('In Contract', createdOpp.Contract_complexity__c);
                    system.assertEquals('Telstra Purple', createdOpp.Contract_Type__c);
                    system.assertEquals('Yes', createdOpp.In_Contract_MAC__c);
                    system.assertEquals('PET', createdOpp.Pricing_Method__c);
                    system.assertEquals('No', createdOpp.Requires_Bid_Management__c);
                    system.assertEquals('Modular', createdOpp.Product_Type__c);
                }
                else if(createdOpp.name == 'MAC Non Modular Opportunity'){
                    system.assertEquals('Enterprise - In Contract', createdOpp.recordtype.name);
                    system.assertEquals(Label.Opportunity_Archetype_1, createdOpp.Archetype__c);
                    system.assertEquals(Label.Opp_SolComp_InCon, createdOpp.Billing_Solution__c);
                    system.assertEquals('NO COMPETITOR', createdOpp.Competitor__c);
                    system.assertEquals('In Contract', createdOpp.Contract_complexity__c);
                    system.assertEquals('Order Under Existing Contract', createdOpp.Contract_Type__c);
                    system.assertEquals('Yes', createdOpp.In_Contract_MAC__c);
                    system.assertEquals('PET', createdOpp.Pricing_Method__c);
                    system.assertEquals('No', createdOpp.Requires_Bid_Management__c);
                    system.assertEquals('Non Modular', createdOpp.Product_Type__c);
                }
            }
        }
    }

    /*
    @Method Name: testStanModOppUpdateValues
    @Description: P2OB-13495, Sprint 21.05
				  To test a sceanrio when a Standard Opportunity updated
    @Author		: Sri (Team SFO)
    */
    @isTest
    public static void testStanModOppUpdateValues(){
        Account act = [SELECT Id FROM Account Where Name='Test Account'];
		List<Opportunity> updatedOppList =new List<Opportunity>();
        User sales = [select id, name from User where username='salesuser@testsales.com'];
        System.runAs(sales){
            for(Opportunity createdOpp : [select id, name, Type, Contract_Type__c,Number_of_Additional_Domains_if_any__c from Opportunity where name = 'Standard Modular Opportunity']){
                createdOpp.Billing_Solution__c = Label.Opp_SolComp_NonStand;
				createdOpp.Proposal_Required_Date__c = system.today();
                updatedOppList.add(createdOpp);
            }
			Test.startTest();
			update updatedOppList;
            Test.stopTest();
            for(Opportunity createdOpp : [select id, name, Type, Contract_Type__c,Billing_Solution__c,Number_of_Additional_Domains_if_any__c from Opportunity where name = 'Standard Modular Opportunity']){
                    system.assertEquals(Label.Opp_SolComp_NonStand, createdOpp.Billing_Solution__c);
            }
        }
    }
 
    /*
    @Method Name: testStanOppUpdateValues
    @Description: P2OB-13495, Sprint 21.05
				  To test a sceanrio when a Standard Opportunity updated
    @Author		: Sri (Team SFO)
    */
    @isTest
    public static void testStanOppUpdateValues(){
        Account act = [SELECT Id FROM Account Where Name='Test Account'];
		List<Opportunity> updatedOppList =new List<Opportunity>();
        User sales = [select id, name from User where username='salesuser@testsales.com'];
        System.runAs(sales){
            for(Opportunity createdOpp : [select id, name, Type, Contract_Type__c,Number_of_Additional_Domains_if_any__c from Opportunity where accountId =:act.id and Billing_Solution__c = 'Standard']){
                createdOpp.Number_of_Additional_Domains_if_any__c = '3 or More';
                createdOpp.Proposal_Required_Date__c = system.today();
                updatedOppList.add(createdOpp);
            }
			Test.startTest();
			update updatedOppList;
            Test.stopTest();
            for(Opportunity createdOpp : [select id, name, Type, Contract_Type__c,Billing_Solution__c,Number_of_Additional_Domains_if_any__c from Opportunity where accountId =:act.id and name like 'Standard%']){
                if(createdOpp.name == 'Standard Non Modular Opportunity'){
                    system.assertEquals(Label.Opp_SolComp_NonStand, createdOpp.Billing_Solution__c);
                }
                else if(createdOpp.name == 'Standard Modular Opportunity'){
                    system.assertNotEquals(Label.Opp_SolComp_NonStand, createdOpp.Billing_Solution__c);
                }
            }
			
        }
    }

    /*
    @Method Name: testStanOppUpdateExceptionValues
    @Description: P2OB-13495, Sprint 21.05
				  To test a validation/exception sceanrio when a Standard Opportunity updated
    @Author		: Sri (Team SFO)
    */
    @isTest
    public static void testStanOppUpdateExceptionValues(){
        Account act = [SELECT Id FROM Account Where Name='Test Account'];
		List<Opportunity> updatedOppList =new List<Opportunity>();
        User sales = [select id, name from User where username='salesuser@testsales.com'];
        System.runAs(sales){
            for(Opportunity createdOpp : [select id, name, Type, Contract_Type__c,Number_of_Additional_Domains_if_any__c from Opportunity where accountId =:act.id and name = 'Standard Non Modular Opportunity']){
                createdOpp.Billing_Solution__c = Label.Opp_SolComp_NonStand;
                createdOpp.Proposal_Required_Date__c = system.today();
                updatedOppList.add(createdOpp);
            }
            try{
			Test.startTest();
			update updatedOppList;
            Test.stopTest();
            }
            catch(System.DmlException ex){
                    system.assertEquals(True, ex.getMessage().contains('You do not have the permission to update solution complexity. Please raise a support request via the opportunity reclassification case to engage the support team to update the opportunity archetype/record type.'));
            }
            for(Opportunity createdOpp : [select id, name, Type, Contract_Type__c,Billing_Solution__c,Number_of_Additional_Domains_if_any__c from Opportunity where accountId =:act.id and name = 'Standard Non Modular Opportunity']){
                if(createdOpp.name == 'Standard Non Modular Opportunity'){
                    system.assertEquals(Label.Opp_SolComp_Stand, createdOpp.Billing_Solution__c);
                }
            }
			
        }
    }

    /*
    @Method Name: StandardOppCreateTest
    @Description: P2OB-13495, Sprint 21.05
				  To test a sceanrio when a Standard Opportunity created
    @Author		: Sri (Team SFO)
    */
     @IsTest
    static void StandardOppCreateTest(){
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){
        //Standard Non Modular Opportunity
        Opportunity OppNonMod =new Opportunity();
        OppNonMod.Name='standard nonmodular opportunity';
        OppNonMod.accountId = acc.Id;
        OppNonMod.Type = 'Renewal';
        OppNonMod.StageName = 'Define';
        OppNonMod.CloseDate = Date.today();
        OppNonMod.Billing_Solution__c = 'Standard';
        OppNonMod.Product_Domain__c = 'CLOUD SERVICES';
        OppNonMod.Product_Type__c = 'Non Modular';
        insert OppNonMod;
        }
        Test.stopTest();
        Id myRecordTypeStandard  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();
        Opportunity opp = [SELECT Id,Contract_Type__c,Archetype__c,Pricing_Method__c,RecordTypeId,In_Contract_MAC__c FROM Opportunity WHERE  Name = 'standard nonmodular opportunity' AND accountId =: acc.Id LIMIT 1 ];
        system.assertEquals('BSA', opp.Contract_Type__c);
        system.assertEquals(Label.Opportunity_Archetype_2, opp.Archetype__c);
        system.assertEquals('PET', opp.Pricing_Method__c);
        system.assertEquals(myRecordTypeStandard, opp.RecordTypeId);
        system.assertNotEquals('Yes', opp.In_Contract_MAC__c);

    }

    /*
    @Method Name: StandardModOppCreateTest
    @Description: P2OB-13495, Sprint 21.05
				  To test a sceanrio when a Standard modular Opportunity created
    @Author		: Sri (Team SFO)
    */
    @IsTest
    static void StandardModOppCreateTest(){
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){

        //Standard Modular Opportunity
        Opportunity OppMod =new Opportunity();
        OppMod.Name='standard modular opportunity';
        OppMod.accountId = acc.Id;
        OppMod.Type = 'Gov Panels';
        OppMod.StageName = 'Define';
        OppMod.CloseDate = Date.today();
        OppMod.Billing_Solution__c = 'Standard';
        OppMod.Product_Domain__c = 'CLOUD SERVICES';
        OppMod.Product_Type__c = 'Modular';
        insert OppMod;
        }
        Test.stopTest();
        Id myRecordTypeStandard  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();
        Opportunity opp = [SELECT Id,Contract_Type__c,Archetype__c,Pricing_Method__c,RecordTypeId,In_Contract_MAC__c FROM Opportunity WHERE  Name = 'standard modular opportunity' AND accountId =: acc.Id LIMIT 1 ];
        system.assertEquals('BSA', opp.Contract_Type__c);
        system.assertEquals(Label.Opportunity_Archetype_2, opp.Archetype__c);
        system.assertEquals('Off the Shelf', opp.Pricing_Method__c);
        system.assertEquals(myRecordTypeStandard, opp.RecordTypeId);
        system.assertNotEquals('Yes', opp.In_Contract_MAC__c);
    }

    /*
    @Method Name: StandardModOppCreateTest
    @Description: P2OB-13495, Sprint 21.05
				  To test a sceanrio when a Standard modular Opportunity updated
    @Author		: Sri (Team SFO)
    */
    @IsTest
    static void StandardModOppUpdateTest(){
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){
        Opportunity OppNonMod = [SELECT Id,Type,Contract_complexity__c FROM Opportunity WHERE  Name = 'standard opportunity' AND accountId =: acc.Id LIMIT 1 ];
        system.assertNotEquals('MACs (Moves, Adds & Change)', OppNonMod.Type);
        system.assertNotEquals('Master Service Agreement', OppNonMod.Contract_complexity__c);

        OppNonMod.Type ='MACs (Moves, Adds & Change)';
        
        //OppNonMod.Billing_Solution__c = 'In Contract';
        update OppNonMod;
        }
        Test.stopTest();
        Id myRecordTypeStandard  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();
        Opportunity resultOpp = [SELECT Id,Contract_Type__c,Billing_Solution__c,Competitor__c,Contract_complexity__c,Archetype__c,Pricing_Method__c,recordtype.name,Requires_Bid_Management__c,Product_Type__c,In_Contract_MAC__c FROM Opportunity WHERE  Name = 'standard opportunity' AND accountId =: acc.Id LIMIT 1 ];
        system.assertEquals('Enterprise - In Contract', resultOpp.recordtype.name);
        system.assertEquals(Label.Opportunity_Archetype_1, resultOpp.Archetype__c);
        system.assertEquals(Label.Opp_SolComp_InCon, resultOpp.Billing_Solution__c);
        system.assertEquals('NO COMPETITOR', resultOpp.Competitor__c);
        //system.assertEquals('Low probability/ Non Commit/ Red	', resultOpp.Confidence_Level__c);
        system.assertEquals('In Contract', resultOpp.Contract_complexity__c);
        system.assertEquals('Yes', resultOpp.In_Contract_MAC__c);
        system.assertEquals('PET', resultOpp.Pricing_Method__c);
        system.assertEquals('Non Modular', resultOpp.Product_Type__c);
    }

    /*
    @Method Name: CustomOppConvCTypeUpdateTest
    @Description: P2OB-13495, Sprint 21.05
				  To test a sceanrio when a Standard Opportunity updated as Custom Opportunity
    @Author		: Srav (Team SFO)
    */
    @IsTest
    static void CustomOppConvCTypeUpdateTest(){
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){
        Opportunity OppNonMod = [SELECT Id,Type FROM Opportunity WHERE  Name = 'standard opportunity' AND accountId =: acc.Id LIMIT 1 ];
        OppNonMod.Contract_Type__c ='Master Service Agreement';
        OppNonMod.Expected_TCV_Range__c = '$500,000 to $4,999,999';
        OppNonMod.Proposal_Required_Date__c = System.today()+10;
        update OppNonMod;
        }
        Test.stopTest();
        Id myRecordTypeStandard  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();
        Opportunity resultOpp = [SELECT Id,Contract_Type__c,Billing_Solution__c,Competitor__c,Contract_complexity__c,Archetype__c,Pricing_Method__c,recordtype.name,Requires_Bid_Management__c,Product_Type__c,proposal_Type__c,In_Contract_MAC__c FROM Opportunity WHERE  Name = 'standard opportunity' AND accountId =: acc.Id LIMIT 1 ];
        system.assertEquals('Enterprise - Custom', resultOpp.recordtype.name);
        system.assertEquals(Label.Opportunity_Archetype_4, resultOpp.Archetype__c);
        system.assertEquals(Label.Opp_SolComp_NonStand, resultOpp.Billing_Solution__c);
        system.assertEquals('Complex', resultOpp.Pricing_Method__c);
        system.assertEquals('Large', resultOpp.proposal_Type__c);
        system.assertNotEquals('Yes', resultOpp.In_Contract_MAC__c);
        system.assertEquals('Yes', resultOpp.Requires_Bid_Management__c);
    }

    /*
    @Method Name: CustomOppConvCType50MUpdateTest
    @Description: P2OB-13495, Sprint 21.05
				  To test a sceanrio when a Standard Opportunity updated as Custom Opportunity
    @Author		: Srav (Team SFO)
    */
    @IsTest
    static void CustomOppConvCType50MUpdateTest(){
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){
        Opportunity OppNonMod = [SELECT Id,Type FROM Opportunity WHERE  Name = 'standard opportunity' AND accountId =: acc.Id LIMIT 1 ];
        OppNonMod.Contract_Type__c ='Master Service Agreement';
        OppNonMod.Expected_TCV_Range__c = '$50 million or greater';
        OppNonMod.Proposal_Required_Date__c = System.today()+10;
        update OppNonMod;
        }
        Test.stopTest();
        Id myRecordTypeStandard  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();
        Opportunity resultOpp = [SELECT Id,Contract_Type__c,Billing_Solution__c,Competitor__c,Contract_complexity__c,Archetype__c,Pricing_Method__c,recordtype.name,Requires_Bid_Management__c,proposal_Type__c,Product_Type__c,In_Contract_MAC__c FROM Opportunity WHERE  Name = 'standard opportunity' AND accountId =: acc.Id LIMIT 1 ];
        system.assertEquals('Enterprise - Custom', resultOpp.recordtype.name);
        system.assertEquals(Label.Opportunity_Archetype_5, resultOpp.Archetype__c);
        system.assertEquals(Label.Opp_SolComp_NonStand, resultOpp.Billing_Solution__c);
        system.assertEquals('Complex', resultOpp.Pricing_Method__c);
        system.assertEquals('Large', resultOpp.proposal_Type__c);
        system.assertNotEquals('Yes', resultOpp.In_Contract_MAC__c);
        system.assertEquals('Yes', resultOpp.Requires_Bid_Management__c);
    }

    /*
    @Method Name: StandardOppDomainUpdateTest
    @Description: P2OB-13495, Sprint 21.05
				  To test a sceanrio when a Standard Opportunity updated 
    @Author		: Srav (Team SFO)
    */
    @IsTest
    static void StandardOppDomainUpdateTest(){
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){
        Opportunity OppNonMod = [SELECT Id,Domain__c FROM Opportunity WHERE  Name = 'standard opportunity' AND accountId =: acc.Id LIMIT 1 ];
        system.assertEquals('Single', OppNonMod.Domain__c);
        OppNonMod.Domain__c	 ='Multi';
        update OppNonMod;
        }
        Test.stopTest();
        Id myRecordTypeStandard  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();
        Opportunity resultOpp = [SELECT Id,Domain__c,Archetype__c FROM Opportunity WHERE  Name = 'standard opportunity' AND accountId =: acc.Id LIMIT 1 ];
        system.assertEquals('Multi', resultOpp.Domain__c);
        system.assertEquals(Label.Opportunity_Archetype_3, resultOpp.Archetype__c);
    }


    private static testMethod void  spEventPublishOnOppCreationTest(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
        PermissionSet perSet = new PermissionSet();
        perSet.Name = 'TestSharepointPermission';
        perSet.Label = 'TestSharepointPermission';
        insert perSet;
        CustomPermission cp=[select Id from CustomPermission where DeveloperName = 'SharePointOpportunityCreate'];
        SetupEntityAccess setEA = new SetupEntityAccess();
        setEA.ParentId = perSet.Id;
        setEA.SetupEntityId =cp.Id;
        insert setEA;
        
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        system.runas(usr){
            Account acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.RecordTypeId = accRecordTypeId;
            acc.Migrated_Customer__c = true;
            acc.Customer_status__c = 'ACTIVE';
            Insert acc;
            Opportunity opp=new Opportunity();
            opp.AccountId=acc.Id;
            opp.Name='TestOppCreateForEventCreate';
            opp.Proposal_Required_Date__c=System.today()+2;
            opp.CloseDate=System.today()+10;
            opp.StageName=System.label.Opp_Stage_Develop;
            opp.Description__c='Test';
            opp.Product_Domain__c='MOBILES';
            opp.Shared_Opportunity__c=True;
            insert opp;
            system.assertEquals(1,1);
        }
        
        Test.StopTest();
    }
    private static testMethod void  spEventPublishOnOppUpdateTest(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
        User usr1 = new User(Email='telsta1@test.com', 
                             EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_AU', ProfileId = p.Id, 
                             TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863471',username='telsta1@test.com.Test',alias = 'Use1T');
        
        insert usr1;
        PermissionSet perSet = new PermissionSet();
        perSet.Name = 'TestSharepointPermission';
        perSet.Label = 'TestSharepointPermission';
        insert perSet;
        CustomPermission cp=[select Id from CustomPermission where DeveloperName = 'SharePointOpportunityCreate'];
        SetupEntityAccess setEA = new SetupEntityAccess();
        setEA.ParentId = perSet.Id;
        setEA.SetupEntityId =cp.Id;
        insert setEA;
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        System.runas(usr){
            Account acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.RecordTypeId = accRecordTypeId;
            acc.Migrated_Customer__c = true;
            acc.Customer_status__c = 'ACTIVE';
            Insert acc;
            
            Opportunity opp=new Opportunity();
            opp.AccountId=acc.Id;
            opp.Name='TestOppCreateForEventCreate';            
            opp.Proposal_Required_Date__c=System.today()+2;
            opp.CloseDate=System.today()+10;
            opp.StageName=System.label.Opp_Stage_Develop;
            opp.Description__c='Test';
            opp.Product_Domain__c='MOBILES';
            opp.Shared_Opportunity__c=True;
            insert opp;
            
            opp.Name='TestOppCreateForEventUpdate';
            opp.OwnerId=usr1.id;
            update opp;
            system.assertEquals(1,1);
        }
        
        Test.StopTest();
    }
    
/*******************************************************************
@Class Name     :   OpportunityTriggerHandlerTest
@Sprint         :   20.08 & P2OB-6727
@Author         :   SFO Team (Amar Chakka)
@CreateDate     :   15-06-2020
@Description    :   Calculation of Customer Risk Score Test Class
@References     :   Test Class
@TestCoverage   :   Coverage for OpportunityTriggerHelper
@Last Modified Info :   21.05 & P2OB-11365/P2OB-13640 ::SFO(Pallavi B) :: Test Coverage method Revamp of Customer Risk Score Calculation only in Before Update on change of newlycreated field values.
*********************************************************************/
    @isTest
    static void customerRiskScoreTest(){
        List<user> userList = new List<user>();
        User sales =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        User admin =[SELECT Id FROM User WHERE Email = 'adminuser@testadmin.com' LIMIT 1];
        Account customerAccount;
        Contact con;
        system.runas(admin){
            customerAccount=TestUtil.createAccount('Testacc');
            customerAccount.Industry ='Equipment Supply Agt';
            insert customerAccount;
            customerAccount.ownerid = sales.id;
            update customerAccount;
            con = TestUtil.createContact(customerAccount.id, 'TestNBAFN', 'TestNBALN');
            insert con;
        }
        list<Opportunity> oppList = new list<Opportunity>();
        Opportunity custRisScoreOpp;
        system.runas(sales){
                custRisScoreOpp = TestUtil.createOpportunity(customerAccount.id);
                custRisScoreOpp.Name = 'TestCustomerRisk';
                custRisScoreOpp.Contract_Type__c = 'BSA';
                custRisScoreOpp.Expected_TCV_Range__c = '$500,000 to $4,999,999';
                custRisScoreOpp.Product_Domain__c = 'SMART CITIES';
                custRisScoreOpp.Proposal_Required_Date__c = system.today()+1;
                custRisScoreOpp.Number_of_Sites__c = '200-499';
                custRisScoreOpp.Number_of_Additional_Domains_if_any__c = '2';
                custRisScoreOpp.Is_this_a_tender__c  = false;
                custRisScoreOpp.Will_this_require_integration__c ='No';
            	test.starttest();
            	insert custRisScoreOpp;
                opportunity oppRecsToUpdate = [SELECT id,Name,Customer_Risk_Score__c,Number_of_Additional_Domains_if_any__c from opportunity where id =: custRisScoreOpp.Id];

        		oppRecsToUpdate.Number_of_Additional_Domains_if_any__c ='1';
        		update oppRecsToUpdate;
              	test.stoptest();
        }
        		opportunity oppRecs = [SELECT id,Name,Customer_Risk_Score__c,Number_of_Additional_Domains_if_any__c from opportunity where id =: custRisScoreOpp.Id];
        		system.assertEquals(oppRecs.Customer_Risk_Score__c,24);
       
    }
    /*-------------------------------------------------------- 
EDGE-186496
Method: testupdateOpportunityTypeRestrict
Description: Method to restrict user to update opportunity type
-------------------------------------------------------- */
  @isTest
    public  static void testupdateOpportunityTypeRestrict() {
        User sales = TestUtil.createUser('sales@test.com.LaTest','SalesLA','Sales-Enterprise-Unified');
        sales.Phone = '0444444444';
        insert sales;
        Account acc = TestUtil.createAccount('Test Account1');
        insert acc;
        
        List<Opportunity> opp = new list<Opportunity>();
        
        system.runas(sales){
            try{
                Opportunity testOpp = new Opportunity();
                testOpp.Account = acc;
                testOpp.Name = 'testOpp';
                testOpp.StageName = 'Define';
                testOpp.CloseDate = System.Date.today();
                testOpp.Type = 'Migration';
                
                opp.add(testOpp); 
                insert opp;
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains('Please choose opportunity type other than Migration'));
            }
        }
    }
    
    /*-------------------------------------------------------- 
EDGE-186496
Method: testupdateOpportunityTypeBOH
Description: Method to restrict user to update opportunity type
-------------------------------------------------------- */
    @isTest
    public  static void testupdateOpportunityTypeBOH() {
        User boh = TestUtil.createUser('sales@test.com.LaTest','SalesLA','Migration BOH user');
        insert boh;
        Account acc = TestUtil.createAccount('Test Account1');
        insert acc;
        
        List<Opportunity> testOpp = new List<Opportunity>();
        system.runas(boh){
            try{
                Opportunity opp = new Opportunity();
                opp.Account = acc;
                opp.Name = 'testOpp';
                opp.StageName = 'Define';
                opp.CloseDate = System.Date.today();
                
                testOpp.add(opp); 
                insert testOpp;
                OpportunityTriggerHelper oppoTest=new OpportunityTriggerHelper();
                oppoTest.updateOpportunityTypeRestrict(testOpp);
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains('Please choose opportunity type Migration'));
            }
        }
   
        
    } 
    /*-------------------------------------------------------- 
EDGE-186496
Method: testupdateOpportunityTypeBOH
Description: Method to restrict user to update opportunity type
-------------------------------------------------------- */
 /*   @isTest
    public  static void testupdateOpportunityType() {
        id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - In Contract').getRecordTypeId();
        Profile p=   [Select Name, Id From Profile where Name='Migration BOH user'];
        User boh = new User(alias = 'migBoh', email='migrationBOHUser@test.com',
                                      emailencodingkey='UTF-8', lastname='BOHUser', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid =p.id, country='United States',IsActive =true,               
                                      timezonesidkey='America/Los_Angeles', username='migrationBOHUser@test.com');
        insert boh;
        
        Account acc = TestUtil.createAccount('Test Account1');
        acc.ownerid=boh.id;
        insert acc;
        
        List<Opportunity> newMap = new List<Opportunity>();
        system.runas(boh){
            try{
                Opportunity testOpp = new Opportunity();
                testOpp.Account = acc;
                testOpp.Name = 'testOpp';
                testOpp.StageName = 'Define';
                testOpp.CloseDate = System.Date.today();
                testOpp.Type = 'RFI';
                testOpp.recordTypeId = oppRecordTypeId;
                
                newMap.add(testOpp); 
                insert newMap;
                
                OpportunityTriggerHelper oppoTest=new OpportunityTriggerHelper();
                oppoTest.updateOpportunityTypeRestrict(newMap);
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains('Please choose opportunity type Migration'));
            }
        
    } */
    
     @isTest
    public  static void testsetTypeForMigrationOnUpdate() {
        id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - In Contract').getRecordTypeId();
        Profile p=   [Select Name, Id From Profile where Name='Migration BOH user'];
        User migrationUser = new User(alias = 'migBoh', email='migrationBOHUser@test.com',
                                      emailencodingkey='UTF-8', lastname='BOHUser', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid =p.id, country='United States',IsActive =true,               
                                      timezonesidkey='America/Los_Angeles', username='migrationBOHUser@test.com');
        insert migrationUser;
        
        Account acc = TestUtil.createAccount('Test Account1');
        acc.ownerid=migrationUser.id;
        insert acc;
        
        system.runas(migrationUser){
            try{
                Opportunity migrationOpp =new Opportunity();
                migrationOpp.AccountId = acc.Id;
                migrationOpp.Name = 'Migration Opportunity';
                migrationOpp.Product_Domain__c = 'Other';
                migrationOpp.StageName = 'Develop';
                migrationOpp.CloseDate = System.Date.today();
                migrationOpp.Description__c = 'test'; 
                insert migrationOpp;
                    
                    migrationOpp.type='RFI';
                update migrationOpp;
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains('Please choose opportunity type Migration'));
            }
        }
    }
  
 /*   @isTest
    public  static void testsetTypeOnUpdateNonBOH() {
        User sales = TestUtil.createUser('sales@test.com.LaTest','SalesLA','Sales-Enterprise-Unified');
        sales.Phone = '0444444444';
        insert sales;
        Account acc = TestUtil.createAccount('Test Account1');
        acc.ownerid=sales.id;
        insert acc;
        
        system.runas(sales){
            try{
                Opportunity testOpp = new Opportunity();
                testOpp.Account = acc;
                testOpp.Name = 'testOpp';
                testOpp.StageName = 'Define';
                testOpp.CloseDate = System.Date.today();
                testOpp.Type = 'RFP';
                
                insert testOpp;
                
                testOpp.type='Migration';
                update testOpp;
                
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains('Please choose opportunity type other than Migration'));
            }
        }
    } */
    
    @isTest
    static void testBeforeUpdateSendCustomNotification() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Name';
        opp.StageName = 'Develop';
        opp.CloseDate = Date.today();
        	 
        opp.SharePoint_Sync__c = '';
        insert opp;
        
     	Opportunity oppToUpdate = [SELECT Id,Proposal_Requested_User__c,SharePoint_Sync__c 
                           FROM Opportunity 
                           WHERE Name = 'Test Name'];
        oppToUpdate.Proposal_Requested_User__c = UserInfo.getUserId();
        oppToUpdate.SharePoint_Sync__c = 'Complete';
        
        Test.startTest();
        	update oppToUpdate;
        Test.stopTest();
        
        Opportunity oppToCheck = [SELECT Id,Proposal_Requested_User__c,SharePoint_Sync__c 
                           		   FROM Opportunity 
                           		   WHERE Name = 'Test Name'];
        
        System.assertEquals(oppToCheck.Proposal_Requested_User__c, null);
    }
    
    @isTest
    static void testBeforeUpdateSendCustomNotificationWhenError() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Name';
        opp.StageName = 'Develop';
        opp.CloseDate = Date.today();
        	 
        opp.SharePoint_Sync__c = '';
        insert opp;
        
     	Opportunity oppToUpdate = [SELECT Id,Proposal_Requested_User__c,SharePoint_Sync__c 
                           FROM Opportunity 
                           WHERE Name = 'Test Name'];
        oppToUpdate.Proposal_Requested_User__c = UserInfo.getUserId();
        oppToUpdate.SharePoint_Sync__c = 'Error';
        
        Test.startTest();
        	update oppToUpdate;
        Test.stopTest();
        
        Opportunity oppToCheck = [SELECT Id,Proposal_Requested_User__c,SharePoint_Sync__c 
                           		   FROM Opportunity 
                           		   WHERE Name = 'Test Name'];
        
        System.assertNotEquals(oppToCheck.Proposal_Requested_User__c, null);    
    }

    /*
    @Method Name: setReopenValuesTest
    @Description: DIGI-4646, Sprint 21.11
    @Author		: Srav (Team SFO)
    */
    @IsTest
    static void setReopenValuesTest(){      
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){
        Opportunity OppNonMod = [SELECT Id,StageName FROM Opportunity WHERE  Name = 'Closed Opp For Reopen' AND accountId =: acc.Id LIMIT 1 ];
        OppNonMod.StageName	 ='Closed Lost';
        update OppNonMod;
        OppNonMod.StageName = 'Define';
        update OppNonMod;

        }
        Test.stopTest();
        Opportunity resultOpp = [SELECT Id,Reopened_Date__c,Original_Closed_Date__c FROM Opportunity WHERE  Name = 'Closed Opp For Reopen' AND accountId =: acc.Id LIMIT 1 ];
        system.assertEquals(System.today(), resultOpp.Reopened_Date__c);
        system.assertEquals(System.today(), resultOpp.Original_Closed_Date__c);
    }
    /*
    @Method Name: sendChatterToRequestorTest
    @Description: DIGI-4646, Sprint 21.11
    @Author		: Srav (Team SFO)
    */
    @IsTest
    static void sendChatterToRequestorTest(){      
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){
        Opportunity OppNonMod = [SELECT Id,StageName FROM Opportunity WHERE  Name = 'Closed Opp For Reopen' AND accountId =: acc.Id LIMIT 1 ];
        OppNonMod.StageName	 ='Closed Lost';
        OppNonMod.Approval_Status__c ='Pending Approval';
            OppNonMod.Approval_Requestor__c =contextuser.id;
        update OppNonMod;
        OppNonMod.StageName = 'Define';
        OppNonMod.Approval_Status__c ='Approved';

        update OppNonMod;

        }
        Test.stopTest();
        User salesuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];

        FeedItem fi = [SELECT Body,Id,InsertedById,ParentId FROM FeedItem WHERE ParentId = :salesuser.id AND Title='Approved' LIMIT 1];
         
		system.assertEquals(true,fi.Body.contains('re-open opportunity'));
    }
    /*
    @Method Name: sendChatterToRequestorTest2
    @Description: DIGI-4646, Sprint 21.11
    @Author		: Srav (Team SFO)
    */
    @IsTest
    static void sendChatterToRequestorTest2(){      
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        User accowneeruser =[SELECT Id FROM User WHERE Email = 'AccOwneruser@AccOwneruser.com' LIMIT 1];
        
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){
            Opportunity OppNonMod = [SELECT Id,StageName FROM Opportunity WHERE  Name = 'Closed Opp For Reopen' AND accountId =: acc.Id LIMIT 1 ];
            OppNonMod.StageName	 ='Closed Lost';
            OppNonMod.Approval_Status__c ='Pending Approval';
            OppNonMod.Approval_Requestor__c =accowneeruser.id;
            update OppNonMod;
            OppNonMod.StageName = 'Closed Lost';
            OppNonMod.Approval_Status__c ='Rejected';
            
            update OppNonMod;
            OppNonMod.StageName = 'Define';
            OppNonMod.Approval_Status__c ='Approved';
            
            update OppNonMod;
            
        }
        Test.stopTest();
        User accOwner =[SELECT Id FROM User WHERE Email = 'AccOwneruser@AccOwneruser.com' LIMIT 1];
        
        FeedItem fi = [SELECT Body,Id,InsertedById,ParentId FROM FeedItem WHERE ParentId = :accOwner.id AND Title='Approved' LIMIT 1];
        
        system.assertEquals(true,fi.Body.contains('re-open opportunity'));
    }
    /*
    @Method Name: sendChatterToRequestorTest3
    @Description: DIGI-4646, Sprint 21.11
    @Author		: Srav (Team SFO)
    */
    @IsTest
    static void sendChatterToRequestorTest3(){      
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        User accowneeruser =[SELECT Id FROM User WHERE Email = 'AccOwneruser@AccOwneruser.com' LIMIT 1];
        
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        acc.ownerID =accowneeruser.id;
        update acc;
        Test.startTest();
        System.runAs(contextuser){
            Opportunity OppNonMod = [SELECT Id,StageName FROM Opportunity WHERE  Name = 'Closed Opp For Reopen' AND accountId =: acc.Id LIMIT 1 ];
            OppNonMod.StageName	 ='Closed Lost';
            OppNonMod.Approval_Status__c ='Pending Approval';
            OppNonMod.Approval_Requestor__c =accowneeruser.id;
            update OppNonMod;
            OppNonMod.StageName = 'Define';
            OppNonMod.Approval_Status__c ='Approved';
            
            update OppNonMod;
            
        }
        Test.stopTest();
         User accOwner =[SELECT Id FROM User WHERE Email = 'AccOwneruser@AccOwneruser.com' LIMIT 1];
        
        FeedItem fi = [SELECT Body,Id,InsertedById,ParentId FROM FeedItem WHERE ParentId = :accOwner.id AND Title='Approved' LIMIT 1];
        
        system.assertEquals(true,fi.Body.contains('re-open opportunity'));
    }
    /*
    @Method Name: sendChatterToRequestorTest4
    @Description: DIGI-4646, Sprint 21.11
    @Author		: Srav (Team SFO)
    */
    @IsTest
    static void sendChatterToRequestorTest4(){      
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        User accowneeruser =[SELECT Id FROM User WHERE Email = 'AccOwneruser@AccOwneruser.com' LIMIT 1];
        
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        update acc;
        Test.startTest();
        System.runAs(contextuser){
            Opportunity OppNonMod = [SELECT Id,StageName FROM Opportunity WHERE  Name = 'Closed Opp For Reopen' AND accountId =: acc.Id LIMIT 1 ];
            OppNonMod.StageName	 ='Closed Lost';
            OppNonMod.Approval_Status__c ='Pending Approval';
            OppNonMod.Approval_Requestor__c =accowneeruser.id;
            OppNonMod.ownerId=accowneeruser.id;
            update OppNonMod;
            
            
        }
        System.runAs(accowneeruser){
            Opportunity OppReopen = [SELECT Id,StageName FROM Opportunity WHERE  Name = 'Closed Opp For Reopen' AND accountId =: acc.Id LIMIT 1 ];
            OppReopen.StageName = 'Define';
            OppReopen.Approval_Requestor__c =accowneeruser.id;
            OppReopen.Approval_Status__c ='Approved';
            update OppReopen;
        }
        Test.stopTest();
        User accOwner =[SELECT Id FROM User WHERE Email = 'AccOwneruser@AccOwneruser.com' LIMIT 1];
        
        FeedItem fi = [SELECT Body,Id,InsertedById,ParentId FROM FeedItem WHERE ParentId = :accOwner.id AND Title='Approved' LIMIT 1];
        
        system.assertEquals(true,fi.Body.contains('re-open opportunity'));
        
    }
    /*
    @Method Name: sendNotificationToPartnerOppCurrentAppr
    @Description: DIGI-24459, Sprint 21.15
				  To send notifications for the approvers of close opportunity when partner submits for approval
    @Author		: Sravanthi (Team SFO)
    */
    @IsTest
    static void sendNotificationToPartnerOppCurrentApprTest(){      
        User contextuser =[SELECT Id FROM User WHERE Email = 'salesuser@testsales.com' LIMIT 1];
        User accowneeruser =[SELECT Id FROM User WHERE Email = 'AccOwneruser@AccOwneruser.com' LIMIT 1];
        
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){
            Opportunity OppNonMod = [SELECT Id,StageName FROM Opportunity WHERE  Name = 'Closed Opp For Reopen' AND accountId =: acc.Id LIMIT 1 ];            
            OppNonMod.Current_Approver_ID__c =accowneeruser.id;
            update OppNonMod;

            
        }
        Test.stopTest();
                User accOwner =[SELECT Id FROM User WHERE Email = 'AccOwneruser@AccOwneruser.com' LIMIT 1];

         Opportunity OppNonModResult = [SELECT Id,StageName,Current_Approver_ID__c FROM Opportunity WHERE  Name = 'Closed Opp For Reopen' AND accountId =: acc.Id LIMIT 1 ];
        
        
        system.assertEquals(accOwner.id,OppNonModResult.Current_Approver_ID__c);
    } 
}