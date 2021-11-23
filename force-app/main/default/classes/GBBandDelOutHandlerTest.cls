/********************************************************************
EDGE        : 118371, 114439
Controller  : GBBandDelOutHandler
Test Class  : GBBandDelOutHandlerTest
Description : GBB Scale and Delegation outcome button
Author      : Rishabh Dhamu
===============================================================================================================================
* ModifiedBy     ModifiedDate     Edge          Description
* Vishal Arbune  18/03/2021       EDGE-203940   <FA Delegation> As a Deal Approver I should be able to Re-score a Deal
*******************************************************************/
@isTest
public class GBBandDelOutHandlerTest {
    
    @isTest
    static void GBBandDelOutHandlerTestMethod() {
        
        List<Delegated_Pricing_Request__c> insertDPRList = new List<Delegated_Pricing_Request__c>();
        
        Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'Customized Pricing',
                                                                            Deal_Status__c = 'Draft');
        insertDPRList.add(dpr);
        
        Delegated_Pricing_Request__c dpr1 = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'Account Executive',
                                                                             Deal_Status__c = 'Draft');
        insertDPRList.add(dpr1);
        Delegated_Pricing_Request__c dpr2 = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'No Discount Offerable',
                                                                             Deal_Status__c = 'Draft');
        insertDPRList.add(dpr2);
        Delegated_Pricing_Request__c dpr3 = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = '',
                                                                             Deal_Status__c = 'Draft');
        insertDPRList.add(dpr3);
        
        
        insert insertDPRList;
        
        DPR_Offer__c dprOffer = new DPR_Offer__c(ActualOfferPrice__c = 100, 
                                                 PoorMinimalValue__c = 200, 
                                                 MinimalMarginalValue__c = 300, 
                                                 MarginalGoodValue__c = 400,
                                                 GoodBetterValue__c = 500,
                                                 BetterBestValue__c = 600,
                                                 BestMaxValue__c = 700,
                                                 Delegated_Pricing_Request__c = dpr.id);
        insert dprOffer;
        
        List<String> planId = new List<String>();
        
        dprOffer.ActualOfferPrice__c = 350;
        update dprOffer;
        
        DPR_Offer_Line_Item__c DPRoli = new DPR_Offer_Line_Item__c(Delegated_Pricing_Request__c = dpr.id,
                                                                   DPR_Offer__c = dprOffer.id,
                                                                   DPR_Offer_Line_Item_Type__c = 'Plan',
                                                                   Name = 'Standard');
        insert DPRoli;
        
        String pId = DPRoli.id;
            
        //planId.add(pId);
        
        DPR_Delegation_Outcome__c delOut = new DPR_Delegation_Outcome__c(Category__c = 'Mobility', 
                                                                         Label_Name__c = 'Mobility GBB',
                                                                         Sort_Order__c = 1,
                                                                         Actual_Display__c = '16.50(Poor)', 
                                                                         Delegation_Required__c = 'Customized Pricing',
                                                                         AE_Expected_Display__c = 'Poor',
                                                                         SS_Expected_Display__c = 'Marginal',
                                                                         SM_Expected_Display__c = 'Marginal',
                                                                         SGM_Expected_Display__c = 'Marginal',
                                                                         Pricing_Expected_Display__c = 'Marginal',
                                                                         Delegated_Pricing_Request__c = dpr.id);
        insert delOut;
        DPR_Delegation_Outcome__c delOut1 = new DPR_Delegation_Outcome__c(Category__c = 'Mobility', 
                                                                          Label_Name__c = 'Mobility GBB',
                                                                          Sort_Order__c = 1,
                                                                          Actual_Display__c = '16.50(Poor)', 
                                                                          Delegation_Required__c = 'Customized Pricing',
                                                                          AE_Expected_Display__c = 'Poor',
                                                                          SS_Expected_Display__c = 'Marginal',
                                                                          SM_Expected_Display__c = 'Marginal',
                                                                          SGM_Expected_Display__c = 'Marginal',
                                                                          Pricing_Expected_Display__c = 'Marginal',
                                                                          Delegated_Pricing_Request__c = dpr2.id);
        insert delOut1;
        DPR_Delegation_Outcome__c delOut2 = new DPR_Delegation_Outcome__c(Category__c = 'Mobility', 
                                                                          Label_Name__c = 'Mobility GBB',
                                                                          Sort_Order__c = 1,
                                                                          Actual_Display__c = '16.50(Poor)', 
                                                                          Delegation_Required__c = 'Customized Pricing',
                                                                          AE_Expected_Display__c = 'Poor',
                                                                          SS_Expected_Display__c = 'Marginal',
                                                                          SM_Expected_Display__c = 'Marginal',
                                                                          SGM_Expected_Display__c = 'Marginal',
                                                                          Pricing_Expected_Display__c = 'Marginal',
                                                                          Delegated_Pricing_Request__c = dpr3.id);
        insert delOut2;       
        
    
        Account acc = new Account();
        acc.name = 'testGBDEL';
        insert acc;
        contact con = new contact();
        con.LastName = 'conLast';
        con.AccountId = acc.id;
        con.Pref_Comm_Method__c = 'eMail';
        con.Authority__c = 'full Authority';
        insert con;

        
        String dprID = String.valueOf(dpr.id);
        String dprID1 = String.valueOf(dpr1.id);
        String dprID2 = String.valueOf(dpr2.id);
        String dprID3 = String.valueOf(dpr3.id);
       
        String dprOfferId = String.valueOf(dprOffer.id);
        
        List<profile> profileList = new list<profile>();
        Map<string,id> profileMap = new Map<string,id>();
        list<string> pfNameList = new list<string>{'Sales-Enterprise-Unified','Pricing Admin','PRM Community User - Australia'};        
            
            profileList = [SELECT Id,Name FROM Profile where Name IN :pfNameList];
        
        if(profileList != null && ProfileList.size()>0){
            for(profile p :profileList ){
                profileMap.put(p.Name,p.Id);
            }
        }
        
         User u2 = new User(
            ProfileId = profileMap.get('Sales-Enterprise-Unified'),
            LastName = 'last',
            Email = 'puser002@amamama.com',
            Username = 'puser002@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'aliasA',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Delegation_Role__c = 'Sales Specialist',
            phone='+121231231234'
            
        ); 
        //insert u2;
        
        
         User u5 = new User(
            ProfileId = profileMap.get('Pricing Admin'),
            LastName = 'last',
            Email = 'puser005@amamama.com',
            Username = 'puser005@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'aliasD',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
             phone='+121231231234'
            
        ); 
       // insert u5;
       
        
        List<User> userListDemo = new List<User>();
       //userListDemo.add(u1);
        userListDemo.add(u2);
        //userListDemo.add(u3);
        //userListDemo.add(u4);
        userListDemo.add(u5);
        //userListDemo.add(u6);
        insert userListDemo;
        
        //EDGE-203940
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity oppRecord = new Opportunity();
        oppRecord.Product_Domain__c = 'FIXED TELEPHONY';
        oppRecord.Name = 'FIXED TELEPHONY';
        oppRecord.Description__c = 'FIXED TELEPHONY';
        oppRecord.Pricing_Method__c = 'Delegated Pricing';
        oppRecord.Product_Type__c = 'Modular';
        oppRecord.CloseDate = system.today();
        oppRecord.StageName = 'Open';
        oppRecord.AccountId = a.Id;
        insert oppRecord;

        Delegated_Pricing_Request__c insertDPR = new Delegated_Pricing_Request__c();
        insertDPR.Description__c = 'Test';
        insertDPR.Opportunity__c = oppRecord.id; 
        insertDPR.isPrimary__c = False;
        insertDPR.Mark_as_Variation__c = False;
        insertDPR.Parent_DPR__c = 'Test';
        insertDPR.Final_Delegation_Outcome__c = 'Sales Specialist';
        //insertDPR.Total_Contract_Value__c=0;
        insert insertDPR;
        
        List<csconta__Frame_Agreement__c> famSet = new List<csconta__Frame_Agreement__c>();
        csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=oppRecord.id; 
        fam.csconta__Status__c = 'Draft';
        fam.is_deal_escalated__c = false;
        fam.Delegated_Pricing_Request__c= dprID1;
        fam.Contract_Acceptance_Date__c=DateTime.now(); 
        //insert fam;
        famSet.add(fam);
        
        csconta__Frame_Agreement__c fam1=new csconta__Frame_Agreement__c();
        fam1.Opportunity__c=oppRecord.id; 
        fam1.csconta__Status__c = 'Draft';
        fam1.is_deal_escalated__c = false;
        fam1.Delegated_Pricing_Request__c= dprID2;
        fam1.Contract_Acceptance_Date__c=DateTime.now(); 
        //insert fam1;
        famSet.add(fam1);
        
        csconta__Frame_Agreement__c fam2=new csconta__Frame_Agreement__c();
        fam2.Opportunity__c=oppRecord.id; 
        fam2.csconta__Status__c = 'Draft';
        fam2.is_deal_escalated__c = false;
        fam2.Delegated_Pricing_Request__c= dprID3;
        fam2.Contract_Acceptance_Date__c=DateTime.now(); 
        //insert fam2;
        famSet.add(fam2);
        
        csconta__Frame_Agreement__c fam3=new csconta__Frame_Agreement__c();
        fam3.Opportunity__c=oppRecord.id; 
        fam3.csconta__Status__c = 'Draft';
        fam3.is_deal_escalated__c = false;
        fam3.Delegated_Pricing_Request__c= dprID;
        fam3.Contract_Acceptance_Date__c=DateTime.now(); 
        //insert fam3;
        famSet.add(fam3);
        insert famSet;
        Test.startTest();
        System.RunAs(u2){
            //First Method Call
            DPR_Offer__c dprOfferList = GBBandDelOutHandler.getDPROfferDetails(dprID);
            System.assertEquals(350, dprOfferList.ActualOfferPrice__c);
            
            //Second Method Call
            List<String> newList = GBBandDelOutHandler.getFinalDelegationOutcome(dprID1);
            System.assertEquals('Account Executive', newList[0]);
            System.assertEquals('success', newList[1]);
            
            //Third Method Call
            List<DPR_Delegation_Outcome__c> delOutList = GBBandDelOutHandler.getDelegationOutcomeTable(dprID);
            System.assertEquals(1, delOutList.size());
            
            //Fourth Method Call
            List<User> UserList = GBBandDelOutHandler.getDelegationUserList(dprID);
            
            List<Integer> intList =  GBBandDelOutHandler.getDelegationUserListHirerchy(dprID);
            
            DPR_Offer_Line_Item__c DPRoliList = GBBandDelOutHandler.getDPRPlanDetails(pId);
            
        }
        Test.stopTest();
    }
    
     @isTest
     
    static void GBBandDelOutHandlerPaternerTest() {
                
        List<Delegated_Pricing_Request__c> insertDPRList1 = new List<Delegated_Pricing_Request__c>();
        
        
         Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'Customized Pricing',
                                                                            Deal_Status__c = 'Draft');
        insertDPRList1.add(dpr);
        
        Delegated_Pricing_Request__c dpr4 = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'Partner',
                                                                             Deal_Status__c = 'Draft');
        insertDPRList1.add(dpr4);
        
        insert insertDPRList1;
    
    
    DPR_Offer__c dprOffer = new DPR_Offer__c(ActualOfferPrice__c = 100, 
                                                 PoorMinimalValue__c = 200, 
                                                 MinimalMarginalValue__c = 300, 
                                                 MarginalGoodValue__c = 400,
                                                 GoodBetterValue__c = 500,
                                                 BetterBestValue__c = 600,
                                                 BestMaxValue__c = 700,
                                                 Delegated_Pricing_Request__c = dpr.id);
        insert dprOffer;
        
         List<String> planId = new List<String>();
        
        dprOffer.ActualOfferPrice__c = 350;
        update dprOffer;
        
        DPR_Offer_Line_Item__c DPRoli = new DPR_Offer_Line_Item__c(Delegated_Pricing_Request__c = dpr.id,
                                                                   DPR_Offer__c = dprOffer.id,
                                                                   DPR_Offer_Line_Item_Type__c = 'Plan',
                                                                   Name = 'Standard');
        insert DPRoli;
        
         String pId = DPRoli.id;
            
        //planId.add(pId);
        List<DPR_Delegation_Outcome__c> delList = new List<DPR_Delegation_Outcome__c>();
        
        
        
        DPR_Delegation_Outcome__c delOut = new DPR_Delegation_Outcome__c(Category__c = 'Mobility', 
                                                                         Label_Name__c = 'Mobility GBB',
                                                                         Sort_Order__c = 1,
                                                                         Actual_Display__c = '16.50(Poor)', 
                                                                         Delegation_Required__c = 'Customized Pricing',
                                                                         AE_Expected_Display__c = 'Poor',
                                                                         SS_Expected_Display__c = 'Marginal',
                                                                         SM_Expected_Display__c = 'Marginal',
                                                                         SGM_Expected_Display__c = 'Marginal',
                                                                         Pricing_Expected_Display__c = 'Marginal',
                                                                         Delegated_Pricing_Request__c = dpr.id);
        delList.add(delOut);
        
         insert delList;
         

           

        String dprID4 = String.valueOf(dpr4.id);
       
        String dprID = String.valueOf(dpr.id);

        String dprOfferId = String.valueOf(dprOffer.id);
        
        
                List<profile> profileList = new list<profile>();
        Map<string,id> profileMap = new Map<string,id>();
        list<string> pfNameList = new list<string>{'PRM Community User - Australia'};        
            
            profileList = [SELECT Id,Name FROM Profile where Name IN :pfNameList];
        
        if(profileList != null && ProfileList.size()>0){
            for(profile p :profileList ){
                profileMap.put(p.Name,p.Id);
            }
        }
         
       Profile sysAdminProfile = [Select Id from Profile where name = 'System Administrator'];
       User thisUser = [ select Id from User where UserRoleId != null and IsPortalEnabled = false and IsActive = true and ProfileId =: sysAdminProfile.Id limit 1];
       //User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
       System.runAs (thisUser ) {
        Account acc = new Account();
        acc.name = 'testGBDEL';
        insert acc;
        contact con = new contact();
        con.LastName = 'conLast';
        con.AccountId = acc.id;
        con.Pref_Comm_Method__c = 'eMail';
        con.Authority__c = 'full Authority';
        insert con;
        UserRole r = [Select id from userrole where portaltype = 'Partner' Limit 1];
       
        
        User u1 = new User(
            ProfileId = profileMap.get('PRM Community User - Australia'),
            LastName = 'last1',
            Email = 'partneruseramykelle1r@gmail.com.invalid',
            Username = 'partneruseramykeller1@gmail.com.prm.copadoci02' + System.currentTimeMillis(),
            CompanyName = 'TEST12',
            Title = 'title12',
            Alias = 'aliasACD',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Delegation_Role__c = 'partner',
            phone='+121231231245',
            ContactId = con.id,
            CommunityNickname = 'testUser12323'
            //UserRoleId = UserMap.get('FDRPIMSPCUAPartnerUser')
            //UserRoleId = r.Id
            //UserType ='PowerPartner'
        );
        List<User> userListDemoList = new List<User>();
        userListDemoList.add(u1);
        system.debug('userListDemoList'+userListDemoList);
        insert userListDemoList;
        
        //EDGE-203940
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity oppRecord = new Opportunity();
        oppRecord.Product_Domain__c = 'FIXED TELEPHONY';
        oppRecord.Name = 'FIXED TELEPHONY';
        oppRecord.Description__c = 'FIXED TELEPHONY';
        oppRecord.Pricing_Method__c = 'Delegated Pricing';
        oppRecord.Product_Type__c = 'Modular';
        oppRecord.CloseDate = system.today();
        oppRecord.StageName = 'Open';
        oppRecord.AccountId = a.Id;
        insert oppRecord;

        Delegated_Pricing_Request__c insertDPR = new Delegated_Pricing_Request__c();
        insertDPR.Description__c = 'Test';
        insertDPR.Opportunity__c = oppRecord.id; 
        insertDPR.isPrimary__c = False;
        insertDPR.Mark_as_Variation__c = False;
        insertDPR.Parent_DPR__c = 'Test';
        insertDPR.Final_Delegation_Outcome__c = 'Sales Specialist';
        //insertDPR.Total_Contract_Value__c=0;
        insert insertDPR;
        
        csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=oppRecord.id; 
        fam.csconta__Status__c = 'Draft';
        fam.is_deal_escalated__c = false;
        fam.Delegated_Pricing_Request__c= dprID4;
        fam.Contract_Acceptance_Date__c=DateTime.now(); 
        insert fam;
        
        
        System.RunAs(u1){
            //First Method Call
            DPR_Offer__c dprOfferList = GBBandDelOutHandler.getDPROfferDetails(dprID);
            System.assertEquals(350, dprOfferList.ActualOfferPrice__c);
            
            //Second Method Call
            List<String> newList = GBBandDelOutHandler.getFinalDelegationOutcome(dprID4);
             system.debug('dprID4-->'+newList);
            System.assertEquals('Partner', newList[0]);
            //System.assertEquals('success', newList[1]);
            
            //Third Method Call
            List<DPR_Delegation_Outcome__c> delOutList = GBBandDelOutHandler.getDelegationOutcomeTable(dprID);
            System.assertEquals(1, delOutList.size());
            
            //Fourth Method Call
            List<User> UserList = GBBandDelOutHandler.getDelegationUserList(dprID4);
            
            List<Integer> intList =  GBBandDelOutHandler.getDelegationUserListHirerchy(dprID);
            
            DPR_Offer_Line_Item__c DPRoliList = GBBandDelOutHandler.getDPRPlanDetails(pId);
            
        
    }
    }
    
    }
    
    
    @isTest
    static void GBBandDelOutHandlerAcceptContractTestMethod() {
        Account newAcc = new Account(Name = 'Test',Customer_Status__c = 'ACTIVE');
        insert newAcc;
        
        Opportunity opp = new Opportunity();
        opp.CloseDate=date.today().addMonths(2);
        opp.Name='test opp';
        opp.StageName='Draft';
        opp.Accountid= newAcc.id;
        opp.RetiedAccOpp__c=True;
        insert opp;
        
        cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c(Name = 'Mobility',
                                                                  cspmb__Billing_Frequency__c = 'Monthly',
                                                                  cspmb__Effective_Start_Date__c = date.parse('10/09/2019'),
                                                                  cspmb__Effective_End_Date__c = date.parse('31/12/2099'),
                                                                  Offer_Id__c = 'DMCAT_Offer_000646',
                                                                  Package_Name__c = 'Corporate Mobile Plus',
                                                                  Plan__c = 'Standard',
                                                                  Type__c = 'Voice and Data');
        insert priceItem;
        
        cspmb__Discount_Level__c disLevel = new cspmb__Discount_Level__c(Name = 'MMC Discount',
                                                                         Business_ID__c = 'DMCAT_Discount_000961',
                                                                         Discount_Application_Point__c = 'Billing Pre-Itemization',
                                                                         cspmb__Discount_Increment__c = '1',
                                                                         cspmb__Discount_Type__c = 'Amount',
                                                                         Is_Delegated__c = true,
                                                                         is_Unlimited__c = true,
                                                                         cspmb__Maximum_Discount_Value__c = 54.6,
                                                                         cspmb__Minimum_Discount_Value__c = 1,
                                                                         Discount_Identifier__c = 91,
                                                                         Description__c = 'Discount applied to International Direct Dial Calling Pack',
                                                                         Plan__c = 'Standard',
                                                                         Account__c = newAcc.id);
        insert disLevel;
        
        cspmb__Discount_Level__c disLevel1 = new cspmb__Discount_Level__c(Name = 'MMC Discount',
                                                                         Business_ID__c = 'DMCAT_Discount_000961',
                                                                         Discount_Application_Point__c = 'Billing Pre-Itemization',
                                                                         cspmb__Discount_Increment__c = '1',
                                                                         cspmb__Discount_Type__c = 'Amount',
                                                                         Is_Delegated__c = true,
                                                                         is_Unlimited__c = true,
                                                                         cspmb__Maximum_Discount_Value__c = 54.6,
                                                                         cspmb__Minimum_Discount_Value__c = 1,
                                                                         Discount_Identifier__c = 91,
                                                                         Description__c = 'Discount applied to International Direct Dial Calling Pack',
                                                                         Plan__c = 'Standard');
        insert disLevel1;
        
        cspmb__Discount_Association__c disAss = new cspmb__Discount_Association__c(cspmb__Discount_Level__c = disLevel.id,
                                                                                   cspmb__Price_Item__c = priceItem.id);
        insert disAss;
        
        Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'Customized Pricing',
                                                                            Deal_Status__c = 'Draft',
                                                                            Opportunity__c = opp.Id);
        insert dpr;
        
        DPR_Offer__c dprOffer = new DPR_Offer__c(Delegated_Pricing_Request__c = dpr.id);
        insert dprOffer;
        
        DPR_Offer_Line_Item__c DPRoli = new DPR_Offer_Line_Item__c(Delegated_Pricing_Request__c = dpr.id,
                                                                   DPR_Offer__c = dprOffer.id,
                                                                   DPR_Offer_Line_Item_Type__c = 'Plan',
                                                                   Name = 'Standard');
        insert DPRoli;
        
        DPR_Offer_Line_Item__c DPRoli1 = new DPR_Offer_Line_Item__c(Delegated_Pricing_Request__c = dpr.id,
                                                                    DPR_Offer__c = dprOffer.id,
                                                                    DPR_Offer_Line_Item_Type__c = 'Discount',
                                                                    Name = 'MMC Discount',
                                                                    cspmb_Price_Item__c = priceItem.id,
                                                                    Parent_DPR_Offer_Line_Item_Id__c = DPRoli.id,
                                                                    DPR_Offer_Line_Item_Value__c = 5);
        insert DPRoli1;
        
        GBBandDelOutHandler.acceptContract(dpr.id);
        
        List<cspmb__Discount_Level__c> testDisLevel = [select Id, Name from cspmb__Discount_Level__c
                                                       where Name='MMC Discount' and Plan__c = 'Standard'
                                                       and Account__c =: newAcc.id];
        System.assertEquals(1, testDisLevel.size());
        
    }
    
    @isTest
    static void GBBandDelOutHandlerCloneDPRTestMethod() {
        Account newAcc = new Account(Name = 'Test',Customer_Status__c = 'ACTIVE');
        insert newAcc;
        
        Opportunity opp = new Opportunity();
        opp.CloseDate=date.today().addMonths(2);
        opp.Name='test opp';
        opp.StageName='Draft';
        opp.Accountid= newAcc.id;
        opp.RetiedAccOpp__c=True;
        insert opp;
        
        cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c(Name = 'Mobility',
                                                                  cspmb__Billing_Frequency__c = 'Monthly',
                                                                  cspmb__Effective_Start_Date__c = date.parse('10/09/2019'),
                                                                  cspmb__Effective_End_Date__c = date.parse('31/12/2099'),
                                                                  Offer_Id__c = 'DMCAT_Offer_000646',
                                                                  Package_Name__c = 'Corporate Mobile Plus',
                                                                  Plan__c = 'Standard',
                                                                  Type__c = 'Voice and Data');
        Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'Customized Pricing',
                                                                            Deal_Status__c = 'Draft',
                                                                            Opportunity__c = opp.Id);
        insert dpr;
        
        String oldDPRId = dpr.Id;
        
        DPR_Offer__c dprOffer = new DPR_Offer__c(Delegated_Pricing_Request__c = dpr.id);
        insert dprOffer;
        
        DPR_Offer_Line_Item__c DPRoli = new DPR_Offer_Line_Item__c(Delegated_Pricing_Request__c = dpr.id,
                                                                   DPR_Offer__c = dprOffer.id,
                                                                   DPR_Offer_Line_Item_Type__c = 'Plan',
                                                                   Name = 'Standard', List_Price__c = 2,
                                                                   Quantity__c = 5,Recontracting_Quantity__c = 2,
                                                                   Unique_Key_to_Update__c = dprOffer.Id);
        insert DPRoli;
        
        DPR_Offer_Line_Item__c DPRoli1 = new DPR_Offer_Line_Item__c(Delegated_Pricing_Request__c = dpr.id,
                                                                    DPR_Offer__c = dprOffer.id,
                                                                    DPR_Offer_Line_Item_Type__c = 'Discount',
                                                                    Name = 'MMC Discount',
                                                                    cspmb_Price_Item__c = priceItem.id,
                                                                    Parent_DPR_Offer_Line_Item_Id__c = DPRoli.id,
                                                                    DPR_Offer_Line_Item_Value__c = 5,
                                                                    Unique_Key_to_Update__c = dprOffer.Id);
        insert DPRoli1;
        
        String newDPRId = GBBandDelOutHandler.dprClone(dpr.id);
        
        System.AssertNotEquals(newDPRId,oldDPRId);
    }
}