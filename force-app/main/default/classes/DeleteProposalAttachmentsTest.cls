/*****************************************************************************
@Name : DeleteProposalAttachmentsTest
@Description : This is test class for apex class DeleteProposalAttachments 
@Created by : Ravi Dodiya as part of P2OB-14470.Sprint 21.07.
*******************************************************************************/
@isTest
public class DeleteProposalAttachmentsTest {

    
    static testMethod void DeleteAttachmentPositiveTest(){
        User calmsUser = [Select Id from User where Username like 'calms.integration@team.telstra.com%' limit 1 ];
        // Insert Attachment as Calm Integration User
        System.runAs(calmsUser){
            
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
           
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
        
        Attachment att = new Attachment();
        att.ParentId = opp.Id;
        att.Name = 'Parent is Opportunity';
        att.Body = Blob.valueOf('Unit Test Attachment Body');
        insert att;
        }
        
        // Create User to Delete Attachment  
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       
        User u = new User(Alias = 'standt', Email='TestUser1@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',     UserName='TestUserfhakj1@testorg.com');
        insert u;
       	
        // Query your permission set name which has the Custom Permission : Delete_Proposal_Attachments.
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SharePoint_Integration'];
        
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
       
        // Run your code with inserted user.
        System.runAs(u)
        {
            Attachment attDelete = [Select Id from Attachment where Name = 'Parent is Opportunity' limit 1];
            Boolean result = DeleteProposalAttachments.DeleteProposalAttachments(attDelete.Id);
            system.assertEquals(True,result);
        }
    }
    	/*	
    	 * User has permission to Delete Attachment
    	 * But Attachment parent object is not opportunity
		*/
        static testMethod void DeleteAttachmentNegativeTest1(){
        User calmsUser = [Select Id from User where Username like 'calms.integration@team.telstra.com%' limit 1 ];
        
        // Insert Attachment as Calm Integration User
        System.runAs(calmsUser){
            
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
           
        
        Attachment att = new Attachment();
        att.ParentId = acc.Id;
        att.Name = 'Parent is NOT Opportunity';
        att.Body = Blob.valueOf('Unit Test Attachment Body');
        insert att;
        }
        // Create User to Delete Attachment 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       
        User u = new User(Alias = 'standt', Email='TestUser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',     UserName='TestUserhskah@testorg.com');
        insert u;
       
        // Query your permission set name which has the Custom Permission : Delete_Proposal_Attachments.
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SharePoint_Integration'];
       
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
       
        // Run your code with inserted user.
        System.runAs(u)
        {
            Attachment attDelete = [Select Id from Attachment where Name = 'Parent is NOT Opportunity' limit 1];
            Boolean result = DeleteProposalAttachments.DeleteProposalAttachments(attDelete.Id);
            system.assertEquals(false,result);
        }
    }

    	/*	
    	 * User has permission to Delete Attachment
    	 * But Attachment is not created by Calms User
		*/
        static testMethod void DeleteAttachmentNegativeTest2(){
            
        // Create Non Calm User 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       
        User noncalmsUser = new User(Alias = 'standt', Email='TestUser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',     UserName='TestUserhskahfaf@testorg.com');
        insert noncalmsUser;
        
        // Insert Attachment as Non Calm Integration User
        System.runAs(noncalmsUser){
            
                Account acc = AccountTestFactory.buildAccount('Test Account') ;
                acc.Customer_Status__c = 'ACTIVE';
                insert acc;
                   
                Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
                opp.StageName = 'Define';
                insert opp;
                
                Attachment att = new Attachment();
                att.ParentId = opp.Id;
                att.Name = 'Parent is Opportunity';
                att.Body = Blob.valueOf('Unit Test Attachment Body');
                insert att;

        }


        // Create User to Delete Attachment 
        Profile pu = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       
        User u = new User(Alias = 'standt', Email='TestUser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = pu.Id,
                          TimeZoneSidKey='America/Los_Angeles',     UserName='TestUserhskah@testorg.com');
        insert u;
       
        // Query your permission set name which has the Custom Permission : Delete_Proposal_Attachments.
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SharePoint_Integration'];
       
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
       
        // Run your code with inserted user.
        System.runAs(u)
        {
            Attachment attDelete = [Select Id from Attachment where Name = 'Parent is Opportunity' limit 1];
            Boolean result = DeleteProposalAttachments.DeleteProposalAttachments(attDelete.Id);
            system.assertEquals(false,result);
        }
    }
    	/*	
    	 * User Doesn't have permission to Delete Attachment
		*/
        static testMethod void DeleteAttachmentNegativeTest3(){
        User calmsUser = [Select Id from User where Username like 'calms.integration@team.telstra.com%' limit 1 ];
        
        // Insert Attachment as Calm Integration User
        System.runAs(calmsUser){
            
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
           
        
        Attachment att = new Attachment();
        att.ParentId = acc.Id;
        att.Name = 'Parent is Opportunity';
        att.Body = Blob.valueOf('Unit Test Attachment Body');
        insert att;
        }
        // Create User to Delete Attachment 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       
        User u = new User(Alias = 'standt', Email='TestUser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',     UserName='TestUsenflafl@testorg.com');
        insert u;
       
       
        // Run your code with inserted user.
        System.runAs(u)
        {
            Attachment attDelete = [Select Id from Attachment where Name = 'Parent is Opportunity' limit 1];
            Boolean result = DeleteProposalAttachments.DeleteProposalAttachments(attDelete.Id);
            system.assertEquals(false,result);
        }
    }

}