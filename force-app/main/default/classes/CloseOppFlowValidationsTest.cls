@isTest
public class CloseOppFlowValidationsTest {
    
    @testsetup static void testdata() {
        List<user> userList = new List<user>();
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile where Name in ('System Administrator','PRM Community User - Australia','Migration BOH user')])
            profilesMap.put(profile.Name, profile);
        
        User migrationUser = new User(alias = 'migBoh', email='migrationBOHUser@test.com',
                                      emailencodingkey='UTF-8', lastname='BOHUser', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid =profilesMap.get('Migration BOH user').id, country='United States',IsActive =true,                
                                      timezonesidkey='America/Los_Angeles', username='migrationBOHUser02@test.com');
        userList.add(migrationUser);
        
        User admin = TestUtil.createUser('admin@test.com.LaTest','AdminLA',Label.Profile_SystemAdmin);
        User sales = TestUtil.createUser('sales@test.com.LaTest','SalesLA',Label.Profile_SalesEnterprise);
        sales.Phone = '0444444444';
        admin.Phone = '0444444444';
        userList.add(sales);
        userList.add(admin);
        insert userList;
        id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        Account customerAccount =new account();
        System.runAs(admin){
            customerAccount=TestUtil.createAccount('TestAccountCloseOppFlow');
            customerAccount.OwnerId=migrationUser.id;
            Insert customerAccount;
            List<Opportunity> opportunityList=new List<Opportunity>();
            Opportunity closeOppFlowOpp = TestUtil.createOpportunity(customerAccount.id);
            closeOppFlowOpp.recordTypeId=oppRecordTypeId;
            closeOppFlowOpp.Name='Test Close Flow Opportunity';
            closeOppFlowOpp.Proposal_Required_Date__c=System.today()+2;
            closeOppFlowOpp.CloseDate=System.today()+10;
            closeOppFlowOpp.StageName='Develop';
            closeOppFlowOpp.Description__c='Test';
            closeOppFlowOpp.Product_Domain__c='MOBILES';
            closeOppFlowOpp.Shared_Opportunity__c=True;
            closeOppFlowOpp.Product_Type__c = 'Non Modular';
            opportunityList.add(closeOppFlowOpp);
            
            
            insert opportunityList;
            
            
        }
        system.runAs(migrationUser){
            
            Opportunity migrationOpp = new Opportunity();
            migrationOpp.AccountId = customerAccount.Id;
            migrationOpp.recordTypeId=oppRecordTypeId;
            migrationOpp.Name = 'Migration Opportunity';
            migrationOpp.Product_Domain__c = 'Other';
            migrationOpp.StageName = 'Develop';
            migrationOpp.Product_Type__c = 'Modular';
            migrationOpp.CloseDate = System.Date.today();
            migrationOpp.Description__c = 'test';
            migrationOpp.Type = 'Migration';
            insert  migrationOpp;
            
            cscfga__Product_Basket__c migrationOppBasket = new cscfga__Product_Basket__c();
            migrationOppBasket.csbb__Account__c = customerAccount.Id;
            migrationOppBasket.Name = 'Migration Opportunity Basket';
            migrationOppBasket.cscfga__Opportunity__c = migrationOpp.Id;
            migrationOppBasket.Express_Flow__c = false;
            migrationOppBasket.Primary_Basket__c = True;
            migrationOppBasket.csbb__Synchronised_With_Opportunity__c = True;
            migrationOppBasket.csordtelcoa__Synchronised_with_Opportunity__c  = True;
            migrationOppBasket.csordtelcoa__Basket_Stage__c = 'Enriched';
            insert migrationOppBasket;
            
            
        }
    }
    @isTest static void CloseOppFlowOppLostUnder250() {
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        system.runas(usr){
            Account acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.RecordTypeId = accRecordTypeId;
            acc.Migrated_Customer__c = true;
            acc.Customer_status__c = 'ACTIVE';
            Insert acc;
            id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
            Opportunity opp=new Opportunity();
            opp.AccountId=acc.Id;
            opp.recordTypeId=oppRecordTypeId;
            opp.Name='TestCloseOppFlow';
            opp.Proposal_Required_Date__c=System.today()+2;
            opp.CloseDate=System.today()+10;
            opp.StageName='Develop';
            opp.Description__c='Test';
            opp.Product_Domain__c='MOBILES';
            opp.Shared_Opportunity__c=True;
            opp.Product_Type__c = 'Non Modular';
            insert opp;
            system.assertEquals(opp.Name,'TestCloseOppFlow');
            
            CloseOppFlowValidations.flowInputs fInpsCls = new CloseOppFlowValidations.flowInputs();
            fInpsCls.oppId = opp.id;
            fInpsCls.oppStageName = opp.StageName;
            fInpsCls.closureReason = 'Won';
            fInpsCls.oppAttachmentCountForNonModularWon = 0 ;
            fInpsCls.oppProductType = opp.Product_Type__c;
            fInpsCls.OppProductCountWon = 0;
            fInpsCls.OppRecordType = oppRecordTypeId;
            CloseOppFlowValidations.invokeLocalMethodWon(fInpsCls);
            
            list<CloseOppFlowValidations.flowInputs> lflowInput = new list<CloseOppFlowValidations.flowInputs>();
            lflowInput.add(fInpsCls);
            CloseOppFlowValidations.invokeThisFromFlowValidations(lflowInput);
            
            CloseOppFlowValidations.flowInputs fInpsCls3 = new CloseOppFlowValidations.flowInputs();
            fInpsCls3.closureReason = 'Lost';
            fInpsCls3.OppProductCount = '2';
            fInpsCls3.OppProductCountLost = '0';
            fInpsCls3.OppRecordType = oppRecordTypeId;
            //fInpsCls3.
            //CloseOppFlowValidations.invokeLocalMethodLost(fInpsCls3);
            list<CloseOppFlowValidations.flowInputs> lflowInput3 = new list<CloseOppFlowValidations.flowInputs>();
            lflowInput3.add(fInpsCls3);
            CloseOppFlowValidations.invokeThisFromFlowValidations(lflowInput3);
            
            
            //fInpsCls.
            opp.Product_Type__c = 'Modular';
            opp.In_Contract_MAC__c = 'Yes';
            update opp;
            
            system.assertEquals(opp.Product_Type__c,'Modular');
            system.assertEquals(opp.In_Contract_MAC__c,'Yes');
            
            CloseOppFlowValidations.flowInputs fInpsCls1 = new CloseOppFlowValidations.flowInputs();
            
            fInpsCls1.closureReason = 'Won';
            fInpsCls1.oppAttachmentCountForNonModularWon = 0 ;
            fInpsCls1.oppProductType = opp.Product_Type__c;
            fInpsCls1.OppProductCountWon = 0;
            fInpsCls1.OppId = opp.id;//EDGE-97613
            fInpsCls1.OppRecordType = oppRecordTypeId;
            CloseOppFlowValidations.invokeLocalMethodWon(fInpsCls1);
            list<CloseOppFlowValidations.flowInputs> lflowInput1 = new list<CloseOppFlowValidations.flowInputs>();
            lflowInput1.add(fInpsCls1);
            CloseOppFlowValidations.invokeThisFromFlowValidations(lflowInput1);
            
            /* id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
opp.recordTypeId = oppRecordTypeId; 
update opp;*/
            
            //Start of EDGE-97613
            List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
            cscfga__Product_Basket__c basket1 = ProductTestService.getNewBasketWithRealConfigVal(acc);
            basket1.Express_Flow__c = false;
            basket1.Primary_Basket__c = True;
            basket1.cscfga__Opportunity__c = opp.id;
            basket1.csbb__Synchronised_With_Opportunity__c = True;
            basket1.csordtelcoa__Synchronised_with_Opportunity__c  = True;
            basket1.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
            update basket1;
            System.assertNotEquals(null,basket1.id);
            basketList.add(basket1);
            
            
            /*cscfga__Product_Basket__c basket9 = ProductTestService.getNewBasketWithRealConfigVal(acc);
basket9.Express_Flow__c = false;
basket9.Primary_Basket__c = True;
basket9.cscfga__Opportunity__c = opp.id;
basket9.csbb__Synchronised_With_Opportunity__c = True;
basket9.csordtelcoa__Synchronised_with_Opportunity__c = True;
basket9.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
update basket9;
System.assertNotEquals(null,basket9.id);
basketList.add(basket9);*/
            
            
            // Configurations:
            
            /*cscfga__Product_Configuration__c PCOrig1 = ProductTestService.createProductConfiguration();
PCOrig1.cscfga__Product_Basket__c = basket9.id;
PCOrig1.cscfga__Description__c = 'test Description ';
PCOrig1.cscfga__Contract_Term__c = 36;
PCOrig1.cscfga__Configuration_Status__c = 'Valid';
PCOrig1.name = 'IP Site';
update PCOrig1;*/
            
            cscfga__Product_Configuration__c PCOrig = ProductTestService.createProductConfiguration();
            PCOrig.cscfga__Product_Basket__c = basket1.id;
            PCOrig.cscfga__Description__c = 'test Description ';
            PCOrig.cscfga__Contract_Term__c = 36;
            PCOrig.cscfga__Configuration_Status__c = 'Valid';
            PCOrig.name = 'IP Site';
            update PCOrig;
            
            //PCR
            csbb__Product_Configuration_Request__c pcrCl1 = new csbb__Product_Configuration_Request__c();
            // pcrCl.csbb__Product_Category__c = pc.id;
            pcrCl1.csbb__Product_Configuration__c = PCOrig.id;
            insert pcrCl1;
            
            /*csbb__Product_Configuration_Request__c pcrCl2 = new csbb__Product_Configuration_Request__c();
// pcrCl.csbb__Product_Category__c = pc.id;
pcrCl2.csbb__Product_Configuration__c = PCOrig1.id;
insert pcrCl2;*/
            
            AutoSync__e asEvent = new AutoSync__e(Basket_Id__c = basket1.id,SyncFlag__c=false);
            
            //End of EDGE-97613
            
            
            
            CloseOppFlowValidations.flowInputs fInpsCls2 = new CloseOppFlowValidations.flowInputs();
            
            //fInpsCls2.OppRecordType = 'Enterprise - Custom';
            fInpsCls2.OppRecordType = oppRecordTypeId;
            fInpsCls2.OppTaskStatus = 'Intiated';
            fInpsCls2.OppTaskSubject = 'Deal Handover Meeting Scheduled and Conducted';
            fInpsCls2.closureReason = 'Won';
            fInpsCls2.OppProductCountWon = 0;
            fInpsCls2.oppProductType = 'Modular';
            fInpsCls2.oppid = opp.id;
            list<CloseOppFlowValidations.flowInputs> lflowInput2 = new list<CloseOppFlowValidations.flowInputs>();
            lflowInput2.add(fInpsCls2);
            CloseOppFlowValidations.invokeThisFromFlowValidations(lflowInput2);
            
            CloseOppFlowValidations.flowInputs fInpsCls4 = new CloseOppFlowValidations.flowInputs();
            
            fInpsCls4.OppRecordType = 'Enterprise - Custom';
            //fInpsCls4.OppRecordType = oppRecordTypeId;
            fInpsCls4.OppTaskStatus = 'Intiated';
            fInpsCls4.oppStageName = 'NoProposeOrNegotiate';
            fInpsCls4.OppTaskSubject = 'Deal Handover Meeting Scheduled and Conducted';
            fInpsCls4.closureReason = 'Won';
            fInpsCls4.OppProductCountWon = 0;
            fInpsCls4.oppProductType = 'Modular';
            fInpsCls4.oppid = opp.id;
            list<CloseOppFlowValidations.flowInputs> lflowInput4 = new list<CloseOppFlowValidations.flowInputs>();
            lflowInput4.add(fInpsCls4);
            CloseOppFlowValidations.invokeThisFromFlowValidations(lflowInput4);
            Test.StopTest();
        }
        
        
    }
    
    /*******************************************************************
@Class Name     :   CloseOppFlowValidationsTest
@Sprint         :   20.14 (P2OB-10150)
@Author         :   Amar (Team SFO)
@CreateDate     :   10/27/2020
@Description    :   Alliance Check For Purple Opportunities. 
@References     :   CloseOppFlowValidations
@TestCoverage   :   CloseOppFlowValidations
*********************************************************************/
    
    @isTest static void allianceCheckForPurpleOpp() {
        
        test.startTest();
        Opportunity purpleOpp = [select Id, StageName,Product_Type__c, RecordTypeId, Purple_Opportunity__c FROM Opportunity WHERE Name = 'Test Close Flow Opportunity'];
        purpleOpp.External_Opportunity_Id__c = 'VM';
        update purpleOpp;
        Opportunity isPurpleOpp = [select Id, StageName,Product_Type__c, RecordTypeId, Purple_Opportunity__c FROM Opportunity WHERE Id =: purpleOpp.Id];
       system.assertEquals(isPurpleOpp.Purple_Opportunity__c,True);
        CloseOppFlowValidations.flowInputs fInpsClsPurpleOpp = new CloseOppFlowValidations.flowInputs();
        fInpsClsPurpleOpp.oppId = purpleOpp.id;
        fInpsClsPurpleOpp.oppStageName = purpleOpp.StageName;
        fInpsClsPurpleOpp.closureReason = 'Won';
        fInpsClsPurpleOpp.oppAttachmentCountForNonModularWon = 0 ;
        fInpsClsPurpleOpp.oppProductType = purpleOpp.Product_Type__c;
        fInpsClsPurpleOpp.OppProductCountWon = 0;
        fInpsClsPurpleOpp.OppRecordType = purpleOpp.RecordTypeId;
        fInpsClsPurpleOpp.isPurpleOpp = isPurpleOpp.Purple_Opportunity__c;
        fInpsClsPurpleOpp.oppAlliance = '';
        //fInpsClsPurpleOpp.userProfile = Label.Profile_SalesEnterprise;
        CloseOppFlowValidations.invokeLocalMethodWon(fInpsClsPurpleOpp);
        
        list<CloseOppFlowValidations.flowInputs> lflowInputPurpleOpp = new list<CloseOppFlowValidations.flowInputs>();
        lflowInputPurpleOpp.add(fInpsClsPurpleOpp);
        CloseOppFlowValidations.invokeThisFromFlowValidations(lflowInputPurpleOpp);
         test.stopTest();
        
    }
    @isTest static void migrationOpportunityValidationSkipTest(){
        Test.startTest();
        opportunity opp=[Select id,Name,Type,StageName,Product_Type__c,recordTypeId FROM opportunity WHERE Type='Migration' LIMIT 1]; 
        CloseOppFlowValidations.flowInputs fInpsCls = new CloseOppFlowValidations.flowInputs();
        fInpsCls.oppId = opp.id;
        fInpsCls.oppStageName = opp.StageName;
        fInpsCls.closureReason = 'Won';
        fInpsCls.oppAttachmentCountForNonModularWon = 0 ;
        fInpsCls.oppProductType = opp.Product_Type__c;
        fInpsCls.OppProductCountWon = 0;
        fInpsCls.OppRecordType = opp.recordTypeId;
        system.debug('opp type=='+opp.type);
        CloseOppFlowValidations.flowOutputs flops=  CloseOppFlowValidations.invokeLocalMethodWon(fInpsCls);  
        system.assertNotEquals(Label.CloseOppContractDocModularError, flops.OppContractAttach_ApexOut);
        test.stopTest();
    }
   /* @isTest static void migrationOpportunityValidationSkipNegativeTest(){
        Test.startTest();
        opportunity opp=[Select id,Name,Type,StageName,Product_Type__c,recordTypeId FROM opportunity WHERE Name='Migration Opportunity' LIMIT 1]; 
        opp.Type='MACs (Moves, Adds & Change)';
        CloseOppFlowValidations.flowInputs fInpsCls = new CloseOppFlowValidations.flowInputs();
        fInpsCls.oppId = opp.id;
        fInpsCls.oppStageName = opp.StageName;
        fInpsCls.closureReason = 'Won';
        fInpsCls.oppAttachmentCountForNonModularWon = 0 ;
        fInpsCls.oppProductType = opp.Product_Type__c;
        fInpsCls.OppProductCountWon = 0;
        fInpsCls.OppRecordType = opp.recordTypeId;
        update opp;
        CloseOppFlowValidations.flowOutputs flops=  CloseOppFlowValidations.invokeLocalMethodWon(fInpsCls);  
     system.assertEquals(Label.CloseOppContractDocModularError, 'flops.OppContractAttach_ApexOut');
        test.stopTest();
        
    } */
    
    // EDGE -204335
    @isTest static void Factivestatuscheck() {
            id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
            Account acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.RecordTypeId = accRecordTypeId;
            acc.Migrated_Customer__c = true;
            acc.Customer_status__c = 'ACTIVE';
            Insert acc;
            id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
            Opportunity opp=new Opportunity();
            opp.AccountId=acc.Id;
            opp.recordTypeId=oppRecordTypeId;
            opp.Name='TestCloseOppFlow';
            opp.Proposal_Required_Date__c=System.today()+2;
            opp.CloseDate=System.today()+10;
            opp.StageName='Develop';
            opp.Description__c='Test';
            opp.Product_Domain__c='MOBILES';
            opp.Shared_Opportunity__c=True;
            opp.Product_Type__c = 'Modular';
            insert opp;

            test.startTest();
            CloseOppFlowValidations.flowInputs fInpsCls = new CloseOppFlowValidations.flowInputs();
            fInpsCls.oppId = opp.id;
            fInpsCls.oppStageName = opp.StageName;
            fInpsCls.closureReason = 'Won';
            fInpsCls.oppAttachmentCountForNonModularWon = 0 ;
            fInpsCls.oppProductType = opp.Product_Type__c;
            fInpsCls.OppProductCountWon = 0;
            fInpsCls.OppRecordType = opp.recordTypeId;
            fInpsCls.PricingMethod = 'Delegated Pricing';
            CloseOppFlowValidations.flowOutputs flops=  CloseOppFlowValidations.invokeLocalMethodWon(fInpsCls);
            system.assertEquals(Label.NoActiveDelPriReq, flops.NoactivefaError_ApxOut);
            test.stopTest();    
        }
        @isTest static void oppClosurePrm(){

            list<Account> Acclist = [Select id, Name From Account limit 1];
            string accId = Acclist[0].id;
            id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
            Opportunity migrationOpp = new Opportunity();
            migrationOpp.AccountId = accId;
            migrationOpp.recordTypeId=oppRecordTypeId;
            migrationOpp.Name = 'Migration Opportunity';
            migrationOpp.Product_Domain__c = 'Other';
            migrationOpp.StageName = 'Develop';
            migrationOpp.Product_Type__c = 'Modular';
            migrationOpp.CloseDate = System.Date.today();
            migrationOpp.Description__c = 'test';
            migrationOpp.Type = 'Migration';
            insert  migrationOpp;
            
            cscfga__Product_Basket__c migrationOppBasket = new cscfga__Product_Basket__c();
            migrationOppBasket.csbb__Account__c = accId;
            migrationOppBasket.Name = 'Migration Opportunity Basket';
            migrationOppBasket.cscfga__Opportunity__c = migrationOpp.Id;
            migrationOppBasket.Express_Flow__c = false;
            migrationOppBasket.Primary_Basket__c = True;
            migrationOppBasket.csbb__Synchronised_With_Opportunity__c = True;
            migrationOppBasket.csordtelcoa__Synchronised_with_Opportunity__c  = True;
            migrationOppBasket.csordtelcoa__Basket_Stage__c = 'Enriched';
            insert migrationOppBasket;

            test.startTest();
            list<Opportunity> Opplist = [Select id, Name From Opportunity limit 1];
            string oppId = migrationOpp.id;
            CloseOppFlowValidations.insertOpportunityTransactionLogsPRM(oppId);
            test.stopTest();
        }
}