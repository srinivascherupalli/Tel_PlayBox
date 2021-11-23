/*****************************************************************************
@Author:            Nitesh
@CreateDate:        2/08/2018
@ModifiedDate:      11 Jun 2020 
@Modified By:       Sandeep Soni, 
@Description:       This Class is created to creat test records.

*******************************************************************************/
@isTest
public with sharing class soc_TestUtility {
    
    /*
     * Method Name:     CreateAccount
     * I/O Parameter:   None
     * Description:     This method is creating Account records
    */ 
    public Static Account CreateAccount (){
        
        Account acc = new Account ();
        acc.name = 'TestAccount';
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        return acc;
    }
    
    /*
     * Method Name:     CreateOpportunity
     * I/O Parameter:   None
     * Description:     This method is creating opportunity records
    */        
    Public static Opportunity CreateOpportunity (){
        Account acc =CreateAccount ();
        Opportunity opp = new opportunity ();
        opp.name = 'TestOppty';
        opp.AccountId = acc.id ;
        opp.CloseDate = system.today();
        opp.Product_Domain__c = 'DATA & IP';
        opp.StageName = 'Assigned';
        opp.Description__c = 'test desc';
        opp.Billing_Solution__c = 'In Contract';
        opp.Contract_Type__c = 'Govt Official/Purchase Order';
        opp.Pricing_Method__c = 'Customised Pricing';
        insert opp;
        
        return opp;
        
    }
    /*
     * Method Name:     createOpportunityLineItem
     * I/O Parameter:   None
     * Description:     This method is creating opportunitylineitem records
    */    
    public static List<OpportunityLineItem> createOpportunityLineItem () {
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        List<Product2> lstProducts = new List<Product2>();
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        lstProducts.add(prd1);
                
        Product2 prd2 = new Product2 (Name='Test Product Entry 2',Description='Test Product Entry 2',productCode = 'PQR', isActive = true);
        lstProducts.add(prd2);
        
        Product2 prd3 = new Product2 (Name='Test Product Entry 3',Description='Test Product Entry 3',productCode = 'XYZ', isActive = true);
        lstProducts.add(prd3);
        insert lstProducts;
        
        List<PricebookEntry> lstPricebookEntries = new List<PricebookEntry>();        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=lstProducts[0].id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        lstPricebookEntries.add(pbe1);
        
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=lstProducts[1].id,Pricebook2ID=pricebookId,UnitPrice=80, isActive=true);
        lstPricebookEntries.add(pbe2);
        
        PricebookEntry pbe3 = new PricebookEntry (Product2ID=lstProducts[2].id,Pricebook2ID=pricebookId,UnitPrice=180, isActive=true);
        lstPricebookEntries.add(pbe3);
        
        insert lstPricebookEntries;
        
        opportunity opp = CreateOpportunity();
        
        List<OpportunityLineItem> lstOppLineItems = new List<OpportunityLineItem>();
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,Description='test,test,test,test',PriceBookEntryID=lstPricebookEntries[0].id, quantity=4,Domain__c='UNIFIED COMMUNICATIONS', totalprice=200);
        lstOppLineItems.add(lineItem1);
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=opp.id,Description='test1,test1,test1,test1',PriceBookEntryID=lstPricebookEntries[1].id, quantity=2,Domain__c='UNIFIED COMMUNICATIONS', totalprice=500);
        lstOppLineItems.add(lineItem2);
        
        OpportunityLineItem lineItem3 = new OpportunityLineItem (OpportunityID=opp.id,Description='test2,test2,test2,test2',PriceBookEntryID=lstPricebookEntries[2].id, quantity=7,Domain__c='Mobiles', totalprice=800);
        lstOppLineItems.add(lineItem3);
        
        insert lstOppLineItems;
        return lstOppLineItems;
    }
    /*
     * Method Name: createGroup
     * Description: This method is creating group. 
    */
    public static list<Group> createGroup (){
        list<Group> createGroup = new list<Group> ();
        set<string> devName = new set<string>{'SOC_Queue','soc_SIMPLEX_Level_1_Detail_Ordering','soc_MEDIUM_COMPLEX_Level_2_Detail_Orderi', 'soc_Complex_Level_3_Detail_Queue'};
            //list<string> grName = new list<string>();
            integer i =0;
        list<Group> grNameList = [select id, DeveloperNAME from group where DeveloperNAME in: devName ];
        for(group str : grNameList){
            if(devName.contains(str.DeveloperNAME)){
                devName.remove(str.DeveloperNAME);
            }
            
        }
        for(string str : devName){
            Group gp = new Group();
            gp.type='Queue';
            gp.DeveloperNAME=str;
            gp.Name = 'test'+i;
            createGroup.add(gp);
            i = i+1;
        }
        if(createGroup.size() > 0){
            insert createGroup;
        }
        
        return createGroup;
    }
    /*
     * Created By: Sandeep Soni
     * Created Date: 11 Jun 2020
     * Description:: This method is used for returning list of user, this is taking two parameter
     * count: count is showing the number of user records that want to create.
     * profileId: this is taking profile Id
    */
    public static List<User> createListUser(integer count, Id profileId){
        List<User> lstUser = new List<User>();
        for(integer i=0;i<count;i++){
            lstUser.add(new User(Email='telsta1'+count+'@test.com', 
                                 EmailEncodingKey='UTF-8', LastName='Test'+i, LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_AU', ProfileId = profileId, 
                                 TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863471',username='telsta1'+i+'@test.com.Test',alias = 'Use1T1'));
        }
        return lstUser;
    }
     /*
     * Created By: Sandeep Soni
     * Created Date: 11 Jun 2020
     * Description:: This method is used for returning list ofAccount, this is taking two parameter
     * count: count is showing the number of account records that want to create.
     * recordTypeId: this is taking Account Record Id
    */
    public static List<Account> createListAccount(integer count, Id recordTypeId){
        List<Account> lstAccount = new List<Account>();
        for(integer i=0;i<count;i++){
            lstAccount.add(new Account(name = 'TestClassEvent'+i,
                Customer_Status__c = 'ACTIVE',
                RecordTypeId = recordTypeId, CIDN__c ='ASDF123'+i));
        }
        return lstAccount;
    }
     /*
     * Created By: Sandeep Soni
     * Created Date: 11 Jun 2020
     * Description:: This method is used for returning list of Opportunity, this is taking three parameter
     * count: count is showing the number of records that we want to create.
     * recordTypeId: this is taking Opportunity Record Id
     * accountId: this is taking accountid.
    */
    public static List<Opportunity> createListOpportunity(Integer count, Id recordTypeId, Id accountId){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(integer i=0;i<count;i++){
            lstOpportunity.add(new Opportunity(AccountId=accountId,
                recordTypeId=recordTypeId,
                Name='TestOppCreateForEventCreate'+i,
                Proposal_Required_Date__c=System.today()+2,
                CloseDate=System.today()+10,
                StageName=System.Label.Opp_Stage_Develop,
                Description__c='Test'+i,
                Product_Domain__c='MOBILES',
                Shared_Opportunity__c=True));
        }
        return lstOpportunity;
    }
    
     /*
     * Created By: Sandeep Soni
     * Created Date: 11 Jun 2020
     * Description:: This method is used for returning list of Case, this is taking four parameter
     * count: count is showing the number of records that we want to create.
     * recordTypeId: this is taking Case Record Id
     * accountId: this is taking accountid.
     * oppId: this is taking OpportunityId.
    */
    public static List<Case> createListCase(Integer count, Id recordTypeId, Id accId, Id oppId){
        List<Case> lstCase = new List<Case>();
        for(integer i=0;i<count;i++){
            lstCase.add(new Case(Subject='Custom Deal Test'+i, RecordTypeId=recordTypeId,
                                  AccountId=accId,
                                  Description='Test',
                                  cusdl_Techscore__c =8,
                                  OpportunityId__c=oppId,
                                  cusdl_Opty_been_Identified_Qualifieds__c='test option',
                                  cusdl_The_Compelling_Events__c='test',
                                  cusdl_Win_Strategy_And_Why_Telstra__c='test',
                                  cusdl_Customer_s_current_environment__c='test option',
                                  cusdl_Technical_or_service_issues__c='test',
                                  cusdl_Key_Deliverables_and_Milestones__c='test',
                                  cusdl_Billing_Requirements__c='test option',
                                  cusdl_Third_Party_Engagement__c='test',
                                  cusdl_Carriage_and_standard_product__c=100,
                                  cusdl_Third_parties__c=100,
                                  cusdl_Once_off_costs__c=30,
                                  cusdl_Telstra_services__c=50,
                                  cusdl_Pricing_Type__c='firm',
                                  cusdl_Benchmarking_Requirements__c='Yes',
                                  cusdl_Details__c='test',
                                  cusdl_non_standard_contract_pricing_oct__c='OCT Pricing'));
        }
        return lstCase;
    }
     /*
     * Created By: Sandeep Soni
     * Created Date: 11 Jun 2020
     * Description:: This method is used for for returning list of CaseTeamMember, this is taking four parameter
     * count: count is showing the number of records that we want to create.
     * caseId: this is taking Case Id.
     * memberId: this is taking userId that will be make a member of caseteammember record.
     * roleId: This is teamroleId.
    */
    public static CaseTeamMember createCaseTeamMember(Integer count, Id caseId, Id memberId, Id roleId){
        CaseTeamMember ctm = new CaseTeamMember();
        ctm = new CaseTeamMember(ParentId = caseId, MemberId = memberId, TeamRoleId = roleId);
        return ctm;
    }
    /*
     * Created By: Sandeep Soni
     * Created Date: 11 Jun 2020
     * Description:: This method is used for returning list of CaseTeamMember, this is taking four parameter
     * count: count is showing the number of records that we want to create.
     * caseId: this is taking Case Id.
     * memberId: this is taking userId that will be make a member of caseteammember record.
     * roleId: This is teamroleId.
    */
    public static List<OpportunityTeamMember> createListOpportunityTeamMember(Integer count, Id oppId, Id memberId, String teamRoleName, String accessLevel){
        List<OpportunityTeamMember> lstOpportunityTeamMember = new List<OpportunityTeamMember>();
        for(integer i=0;i<count;i++){
            lstOpportunityTeamMember.add(new OpportunityTeamMember(OpportunityId = oppId, UserId = memberId , 
            TeamMemberRole = teamRoleName, OpportunityAccessLevel=accessLevel));
        }
        return lstOpportunityTeamMember;
    }
}