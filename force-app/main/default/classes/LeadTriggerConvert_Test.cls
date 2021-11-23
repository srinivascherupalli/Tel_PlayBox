/*
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of  Removing Commented Code, debug Statements and updating API version to 50.
						P2OB-9943/P2OB-6772 Modified for test coverage.
                        16/03/2021 S21.04/P2OB-12075 by Pallavi B , Team SFO
                        As part of Tech Debt (Removed References for the Label of Enterprise Record Type)  
                        To check code coverage for lead as part of S21.15 
                        

*/
@isTest
public without sharing class LeadTriggerConvert_Test{
    
    @testSetup
    static void setup()
    {    
        id p1 = [select id from profile where name='System Administrator'].id;
        UserRole r = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
        User uSysAdmin = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p1, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username='b2btestewwr@noemail.com',userroleid=r.id);
        insert uSysAdmin;   
         // Query your permission set name 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Allow_All_Lead_Type_Selection'];
       
        // Assigning the Permission Set to the above user as part of P2OB-8984 to allow acess to 'cal me now' and ' MQL Threshold' values.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = uSysAdmin.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        System.runAs(uSysAdmin){ 
        Test.startTest();
        Account ac=new Account(Name='TESTAccount',Migrated_Customer__c=true, Customer_Status__c = 'Active');
        insert ac;
        List<campaign> campaignList = new List<campaign>();
        Id campRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        for(Integer i=0;i<5;i++)
        { 
            campaign cmp=new Campaign(Name='Test Campaign'+i,Status='Planned',Type='Advertisement',RecordTypeId=campRecordTypeId);
            campaignList.add(cmp);            
        }
        insert campaignList;
        List<lead> testLeadlist = new List<lead>();
        for(Integer i=0;i<5;i++)
        {            
            lead leadTest=new lead(lastname='acbc'+i,firstname='frst'+i,company='telstra test inc.'+i,recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                                   phone='031245678',Lead_Type__c='Call Me Now',CIDN__c='123445',Job_Description__c='Accounting',Job_Function__c='Chief Customer Officer',Status='In Progress');
            
            //Fix for Validation rule : InvalidOrNoEmailValidation Failer
            leadTest.Email = 'TestLeadEmail'+i+'@team.telstra.com';
            
            testLeadlist.add(leadTest);
            
        }   
        
        lead leadTestDescription=new lead(lastname='acbc',firstname='frst',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(),//Replaced with Developer Name of Enterprise Lead Record Type
                                          phone='031245678',Lead_Type__c='Call Me Now',CIDN__c='123445',Job_Description__c='Accounting',Status='In Progress');
        	leadTestDescription.Email = 'TestLeadEmailx@team.telstra.com';
        lead leadTestFunction=new lead(lastname='acbc',firstname='frst',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                                       phone='031245678',Lead_Type__c='Call Me Now',CIDN__c='123445',Job_Function__c='Chief Customer Officer',Status='In Progress');
        	leadTestFunction.Email = 'TestLeadEmaily@team.telstra.com';
        testLeadlist.add(leadTestDescription);
        testLeadlist.add(leadTestFunction);
        
        insert testLeadlist;
        List<Contact> testcontactlist = new List<Contact>();
        for(Integer i=0;i<5;i++)
        { 
            Contact target=TestUtil.createContact(ac.id,'Nishaash'+i, 'abcwwe'+i);
            testcontactlist.add(target);
        }
        Id recordtypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
        List<Opportunity> testOpplist = new List<Opportunity>();
        for(Integer i=0;i<5;i++){
            Opportunity newOpp=new Opportunity();
            newOpp.AccountId=ac.Id;
            newOpp.Name='Test'+i ;
            newOpp.closedate=System.today();
            newOpp.Proposal_Required_Date__c=System.today();
            newOpp.StageName='Propose';
            newOpp.RecordTypeId=recordtypeID;            
            testOpplist.add(newOpp);
        }
        insert testOpplist;
        List<CampaignInfluence> testcamInflist = new List<CampaignInfluence>();
        for(Integer i=0;i<5;i++){
            CampaignInfluence ci=new CampaignInfluence();
            ci.CampaignId=campaignList.get(i).id;
            ci.OpportunityId=testOpplist.get(i).id;
            ci.Influence=100.00;
            ci.ModelId=System.Label.SecondaryCampaignSourceModel;
            testcamInflist.add(ci);
        }
        insert testcamInflist;
        List<CampaignMember> testcampaignlist = new List<CampaignMember>();
        for(Integer i=0;i<5;i++){
            CampaignMember mem = new CampaignMember (campaignid=campaignList.get(i).id, leadid=testLeadlist.get(i).id);
            testcampaignlist.add(mem);
        }
        insert testcampaignlist;
            Test.stopTest();
        }}
    
    static testMethod void campaignMemberCreate1() {
        try{
            Test.startTest();
            
            campaign cmp1 = [SELECT id FROM campaign WHERE Name='Test Campaign1' Limit 1];
            lead l1 = [SELECT id,isConverted FROM lead WHERE lastname='acbc1' and Job_Description__c='Accounting' Limit 1];
            
            
            LeadTriggerHelper.isRec=false;
            
            
            CampaignMember mem2=[SELECT id FROM CampaignMember WHERE campaignid =: cmp1.id Limit 1];
            Account ac1=[SELECT id FROM Account WHERE Name='TESTAccount' Limit 1];
            Contact con1= TestUtil.createContact(ac1.id,'First', 'last');
            Opportunity newOpp1=[SELECT id FROM Opportunity WHERE Name='Test1' Limit 1];
            CampaignInfluence ci1=[SELECT id FROM CampaignInfluence WHERE OpportunityId=:newOpp1.id Limit 1];
            
            LeadTriggerHelper.isRec=false;
            Database.LeadConvert leadconvert= new Database.LeadConvert();
            leadconvert.setLeadId(l1.id); 
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            leadconvert.setConvertedStatus(convertStatus.MasterLabel);
            leadconvert.setDoNotCreateOpportunity(false);  
            leadconvert.setAccountId(ac1.id);
            leadconvert.setOpportunityId(newOpp1.id);
            leadconvert.setContactId(con1.Id);
            Database.LeadConvertResult lcr = Database.convertLead(leadconvert);
            l1.phone='78945612';
            System.assert(lcr.isSuccess());
            System.assertEquals(l1.isConverted,False);

            Update l1;
            
            
            
            campaign cmp2 = [SELECT id FROM campaign WHERE Name='Test Campaign2' Limit 1];
            campaign cmp3 = [SELECT id FROM campaign WHERE Name='Test Campaign3' Limit 1];
            lead l2 = [SELECT id FROM lead WHERE lastname='acbc2' Limit 1];
            
            update l2;
            CampaignMember mem3=[SELECT id FROM CampaignMember WHERE campaignid =: cmp2.id Limit 1];
           
            Account ac2=[SELECT id FROM Account WHERE Name='TESTAccount' Limit 1];
            Contact con2= TestUtil.createContact(ac2.id,'Firsts', 'lasts');
            Opportunity newOpp2=[SELECT id FROM Opportunity WHERE Name='Test2' Limit 1];
            CampaignInfluence ci2=[SELECT id FROM CampaignInfluence WHERE OpportunityId=:newOpp2.id Limit 1];
            
            
            LeadTriggerHelper.isRec=false;
            Database.LeadConvert leadconvert1= new Database.LeadConvert();
            leadconvert1.setLeadId(l2.id);
            leadconvert1.setConvertedStatus(convertStatus.MasterLabel);
            leadconvert1.setDoNotCreateOpportunity(false);  
            leadconvert1.setAccountId(ac1.id);
            leadconvert1.setOpportunityId(newOpp1.id);
            leadconvert1.setContactId(con2.Id);
            Database.LeadConvertResult lcr1 = Database.convertLead(Leadconvert1,true);
            system.assert(lcr1.isSuccess());
            l2.phone='78945612';
            LeadTriggerHelper.isRec=false;
            Update l2;
            
            Test.stopTest();
            CampaignInfluence[] sfCamp = [ 
                SELECT campaignId, ContactId, OpportunityId 
                FROM CampaignInfluence 
                WHERE campaignId = :cmp1.Id        ];         
            
            System.assert(sfCamp != null);
        }
        catch(Exception ex){
            system.debug('------------->'+ex.getMessage());
        }
    } 
    static testMethod void campaignMemberCreate2() {
        try{
            
            List<Lead> leadList=new List<Lead>();
            List<campaign> camList=new List<campaign>();
            Id campRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            campaign cmp=new Campaign(Name='Test Campaign',Status='Planned',Type='Advertisement',RecordTypeId=campRecordTypeId);
            camList.add(cmp);            
            campaign cmp1=new Campaign(Name='Test Campaign1',Status='Planned',Type='Advertisement',RecordTypeId=campRecordTypeId);
            camList.add(cmp1);
            insert camList;
            //Leads Test Data
            lead leadTest=new lead(lastname='acbc',firstname='frst',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(),//Replaced with Developer Name of Enterprise Lead Record Type
                                   phone='031245678',Email='leadTest1@email.com',Lead_Type__c='Call Me Now',CIDN__c='123445',Job_Description__c='Accounting',Job_Function__c='Chief Customer Officer',Status='In Progress');
            lead leadTest1=new lead(lastname='acbc1',firstname='frst1',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(),//Replaced with Developer Name of Enterprise Lead Record Type
                                    phone='0312456781',Email='leadTest2@email.com',Lead_Type__c='Call Me Now',CIDN__c='123445',Job_Description__c='Accounting',Job_Function__c='Chief Customer Officer',Status='In Progress');
            
            lead leadTest2=new lead(lastname='acbc2',firstname='frst2',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(),//Replaced with Developer Name of Enterprise Lead Record Type
                                    phone='0312456781',Email='leadTest3@email.com',Lead_Type__c='Call Me Now',CIDN__c='123445',Job_Description__c='Accounting',Job_Function__c='Chief Customer Officer',Status='In Progress');
            lead leadTest4=new lead(lastname='acbc4',firstname='frst4',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(),//Replaced with Developer Name of Enterprise Lead Record Type
                                    phone='0312456781',Email='leadTest4@email.com',Lead_Type__c='Call Me Now',CIDN__c='123445',Job_Description__c='Accounting',Job_Function__c='Chief Customer Officer',Status='In Progress');
            
            leadList.add(leadTest);
            leadList.add(leadTest1);
            leadList.add(leadTest2);
            leadList.add(leadTest4);
            insert leadList;
            CampaignMember mem = new CampaignMember (campaignid=camList.get(0).id, leadid=leadTest.id,status='sent');
            insert mem;
            Account ac=new Account(Name='TESTAccount',Migrated_Customer__c=true, Customer_Status__c = 'Active');
            insert ac;
            Contact target=TestUtil.createContact(ac.id,'Nishaash', 'abcwwe');
            List<Opportunity> oppList = new List<Opportunity>();
            Id recordtypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
            Opportunity newOpp=new Opportunity();
            newOpp.AccountId=ac.Id;
            newOpp.Name='Test' ;
            newOpp.closedate=System.today();
            newOpp.Proposal_Required_Date__c=System.today();
            newOpp.StageName='Propose';
            newOpp.RecordTypeId=recordtypeID;
            oppList.add(newOpp);
            Opportunity newOpp1=new Opportunity();
            newOpp1.AccountId=ac.Id;
            newOpp1.Name='Test1' ;
            newOpp1.closedate=System.today();
            newOpp1.Proposal_Required_Date__c=System.today();
            newOpp1.StageName='Propose';
            newOpp1.RecordTypeId=recordtypeID; 
            oppList.add(newOpp1);
            Insert oppList;
            Test.startTest();
            CampaignInfluence ci=new CampaignInfluence();
            ci.CampaignId=camList.get(0).id;
            ci.OpportunityId=newOpp.id;
            ci.Influence=100.00;
            ci.ModelId=System.Label.SecondaryCampaignSourceModel;
            insert ci;
            LeadTriggerHelper.isRec=false;
            Database.LeadConvert leadconvert= new Database.LeadConvert();
            leadconvert.setLeadId(leadTest.id); 
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            leadconvert.setConvertedStatus(convertStatus.MasterLabel);
            leadconvert.setDoNotCreateOpportunity(false); 
            leadconvert.setAccountId(ac.id);
            leadconvert.setOpportunityId(newOpp.id);
            leadconvert.setContactId(target.Id);
            Database.LeadConvertResult lcr = Database.convertLead(leadconvert,true);            
            System.assert(lcr.isSuccess());
            leadTest.phone='78945612';
            LeadTriggerHelper.isRec=false;
            Update leadTest;
            //------------------------------------new con,exist opp
            
            
                    
          
            Contact target1=TestUtil.createContact(ac.id,'Nishaash1', 'abcwwe1');
            
            
            CampaignInfluence ci1=new CampaignInfluence();
            ci1.CampaignId=camList.get(1).id;
            ci1.OpportunityId=newOpp1.id;
            ci1.Influence=100.00;
            ci1.ModelId=System.Label.SecondaryCampaignSourceModel;
            LeadTriggerHelper.isRec=false;
            Database.LeadConvert leadconvert1= new Database.LeadConvert();
            leadconvert1.setLeadId(leadTest1.id); 
            LeadStatus convertStatus1 = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            leadconvert1.setConvertedStatus(convertStatus1.MasterLabel);
            leadconvert1.setDoNotCreateOpportunity(false);  
            leadconvert1.setAccountId(ac.id);
            leadconvert1.setOpportunityId(newOpp.id);
            leadconvert1.setContactId(target1.Id);
            Database.LeadConvertResult lcr1 = Database.convertLead(leadconvert1,true);            
            System.assert(lcr1.isSuccess());
            leadTest1.phone='78945612';
            LeadTriggerHelper.isRec=false;
            Update leadTest1;
            //------------------------------------exist con,exist opp
            

            
            CampaignMember mem2 = new CampaignMember (campaignid=camList.get(1).id, leadid=leadTest2.id,status='sent');
            CampaignMember mem3 = new CampaignMember (campaignid=camList.get(0).id, leadid=leadTest2.id,status='sent');
            insert mem2;
            insert mem3;
            Contact target2=TestUtil.createContact(ac.id,'Nishaash2', 'abcwwe2');
            CampaignInfluence ci2=new CampaignInfluence();
            ci2.CampaignId=camList.get(1).id;
            ci2.OpportunityId=newOpp.id;
            ci2.Influence=100.00;
            ci2.ModelId=System.Label.SecondaryCampaignSourceModel;
            Database.LeadConvert leadconvert2= new Database.LeadConvert();
            leadconvert2.setLeadId(leadTest2.id); 
            LeadStatus convertStatus2 = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            leadconvert2.setConvertedStatus(convertStatus2.MasterLabel);
            leadconvert2.setAccountId(ac.id);
            Database.LeadConvertResult lcr2 = Database.convertLead(leadconvert2,true); 
            System.assert(lcr2.isSuccess());
            leadTest2.phone='78945612';
            LeadTriggerHelper.isRec=false;
            Update leadTest2;
            
            //------------------------------------exist con,exist opp
            
            

            
            Contact target4=TestUtil.createContact(ac.id,'Nishaash4', 'abcwwe4');
            List<CampaignMember> camMemList= new List<CampaignMember>();
            CampaignMember mem4 = new CampaignMember (campaignid=camList.get(1).id, leadid=leadTest4.id,status='sent',ContactId=target2.id);
            CampaignMember mem5 = new CampaignMember (campaignid=camList.get(0).id, leadid=leadTest4.id,status='sent',ContactId=target2.Id);

            camMemList.add(mem4);
            camMemList.add(mem5);
            insert camMemList;
            List<CampaignInfluence> campaignInfluenceList= new List<CampaignInfluence>();
            campaignInfluence ci22=new CampaignInfluence();
            ci22.CampaignId=camList.get(1).id;
            ci22.OpportunityId=newOpp.id;
            ci22.Influence=100.00;
            ci22.ModelId=System.Label.SecondaryCampaignSourceModel;
            campaignInfluenceList.add(ci22);
            campaignInfluence ci23=new CampaignInfluence();
            ci23.CampaignId=camList.get(0).id;
            ci23.OpportunityId=newOpp.id;
            ci23.Influence=100.00;
            ci23.ModelId=System.Label.SecondaryCampaignSourceModel;
            campaignInfluenceList.add(ci23);
            insert campaignInfluenceList;
            campaignInfluence ci4=new CampaignInfluence();
            ci4.CampaignId=camList.get(1).id;
            ci4.OpportunityId=newOpp.id;
            ci4.Influence=100.00;
            ci4.ModelId=System.Label.SecondaryCampaignSourceModel;
            Database.LeadConvert leadconvert4= new Database.LeadConvert();
            leadconvert4.setLeadId(leadTest4.id); 
            LeadStatus convertStatus4 = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            leadconvert4.setConvertedStatus(convertStatus2.MasterLabel);
            leadconvert4.setDoNotCreateOpportunity(false);
            leadconvert4.setAccountId(ac.id);
            leadconvert4.setOpportunityId(newOpp.id);
            leadconvert4.setContactId(target1.Id);
            Database.LeadConvertResult lcr4 = Database.convertLead(leadconvert4,true); 
            System.assert(lcr4.isSuccess());
            leadTest4.phone='78945612';
            LeadTriggerHelper.isRec=false;
            Update leadTest4;
            
            Test.stopTest();
            
            
        }
        catch(Exception ex){
            system.debug('------------->'+ex.getMessage());
        }
    }
    
    
    
    static testMethod void campaignMemberCreate3() { 
        Test.startTest();
        campaign cmp2 = [SELECT id FROM campaign WHERE Name='Test Campaign2' Limit 1];
        CampaignInfluence[] sfCamp = [ 
            SELECT campaignId, ContactId, OpportunityId 
            FROM CampaignInfluence 
            WHERE campaignId = :cmp2.Id        ];        
        delete sfCamp;
        System.assert(sfCamp != null);
        Test.stopTest();
    }

}