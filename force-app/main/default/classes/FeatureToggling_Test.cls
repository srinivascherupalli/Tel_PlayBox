/*****************************************************************************
@Name: FeatureToggling_Test
@Author: Murali Nunna
@CreateDate: 05/07/2018
@Description: This Class is the test class for FeatureToggling class
@Latest Modification Description :
	 	existing user creation removed & TestUtil.createTestUser added for User creation because of 
        FDR & Prod Test class failures because of DUPLICATE_USERNAME error during a deployment
        So SFO Added blow usercreation method for unique username on date 02/09/2020 (Sprint 20.12)
*******************************************************************************/

@isTest
public class FeatureToggling_Test {
    // 1st record of metadata-->Active Flag ALL,Sales Enterprise B2B profile  and 
    // permissionset is Allow Send Announcement Emails
    // Always return TRUE
    Public static testMethod void testSysAdminfeaturetoggle1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Enterprise B2B']; 
        User u = TestUtil.createTestUser(null,p.id,'testSysAdmin','featuretoggle1');
        u.Phone = '0445678001';
        insert u;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'SyncOpportunity'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        //User testUser = [select id, name, isActive,Alias from User where isactive = true AND Alias =:'mnunn'];
        string hName = 'ALL';        
        /*Feature_Flags__mdt featureFlag=[SELECT Active__c,DeveloperName,Id,
                                        Permission_Set__c,
                                        Profile__c FROM Feature_Flags__mdt WHERE DeveloperName=:hName];
		*/
        system.runAs(u)
        {
            Test.startTest();            
            Boolean value=FeatureToggling.featureUtility(hName);
            system.debug('<Login with System Administrator & flag is---> ALL--& Active---->1'+value);
            Test.stopTest();
            system.assertEquals(True, value);
            
        }
        
    }
    
    //5th record Active,Flag NONE profile,permission set Diamond_Campaign,
    // return true
    Public static testMethod void testSalesEnterfeaturetoggle5(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales - Enterprise']; 
        User u = TestUtil.createTestUser(null,p.id,'testSalesEnter','featuretoggle5');
        u.Phone = '0445678001';
        insert u;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Diamond_Campaign'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        //User testUser = [select id, name, isActive,Alias from User where isactive = true AND Alias =:'kkish'];
        string hName = 'NONE';        
        /*Feature_Flags__mdt featureFlag=[SELECT Active__c,DeveloperName,Id,
                                        Permission_Set__c,
                                      Profile__c FROM Feature_Flags__mdt WHERE DeveloperName=:hName];
        */
		system.runAs(u)
        {
            Test.startTest();            
            Boolean value=FeatureToggling.featureUtility(hName);
            system.debug('<Login with Sales - Enterprise ang Flag is -->NONE--&-- Active---------->2'+value);
            Test.stopTest();
            system.assertEquals(True, value);
            
        }
        
    }
    
    //4th record Active,Flag NONE profile,permission set SyncOpportunity,
    //return true
    Public static testMethod void testSalesEnterfeaturetoggle4th(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales - Enterprise']; 
        User u = TestUtil.createTestUser(null,p.id,'testSalesEnter','featuretoggle4th');
        u.Phone = '0445678001';
        insert u;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'SyncOpportunity'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        //User testUser = [select id, name, isActive,Alias from User where isactive = true AND Alias =:'kkish'];
        string hName = '';        
        /*Feature_Flags__mdt featureFlag=[SELECT Active__c,DeveloperName,Id,
                                        Permission_Set__c,
                                        Profile__c FROM Feature_Flags__mdt WHERE DeveloperName=:hName];
        */
        system.runAs(u)
        {
            Test.startTest();            
            Boolean value=FeatureToggling.featureUtility(hName);
            system.debug('<Login with Sales - Enterprise ang Flag is -->NONE--&-- Active---------->3'+value);
            Test.stopTest();
            system.assertEquals(False, value);
            
        }
        
    }
    
    //3rd record Active ,Flag Dummyservice profile Sales - Enterprise, permission set empty or null
    // return true
    Public static testMethod void testSalesEnterprisefeaturetoggle3rd(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales - Enterprise']; 
        User u = TestUtil.createTestUser(null,p.id,'testSalesEnterprise','featuretoggle4th');
        u.Phone = '0445678001';
        insert u;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Diamond_Campaign'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        //insert psa;
        //User testUser = [select id, name, isActive,Alias from User where isactive = true AND Alias =:'kkish'];
        string hName = 'DummyService';        
        /*Feature_Flags__mdt featureFlag=[SELECT Active__c,DeveloperName,Id,
                                        Permission_Set__c,
                                        Profile__c FROM Feature_Flags__mdt WHERE DeveloperName=:hName];
        */
        system.runAs(u)
        {
            Test.startTest();
            Boolean value=FeatureToggling.featureUtility(hName);
            Test.stopTest();
            system.debug('<Login with Sales - Enterprise & Flag is -->DummyService & Active----------->4'+value);
            system.assertEquals(True, value);
        }
        
    }
    
    //2nd record Not Active,Sales Enterprise B2B profile,empty permission set
    // return false
    Public static testMethod void testSysAdminfeaturetoggle2nd(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Enterprise B2B']; 
        User u = TestUtil.createTestUser(null,p.id,'testSysAdmin','featuretoggle2nd');
        u.Phone = '0445678001';
        insert u;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Diamond_Campaign'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        //insert psa;
        //User testUser = [select id, name, isActive,Alias from User where isactive = true AND Alias =:'svela'];
        string hName = 'DummyService';
        /*Feature_Flags__mdt featureFlag=[SELECT Active__c,DeveloperName,Id,
                                        Permission_Set__c,
                                        Profile__c FROM Feature_Flags__mdt WHERE DeveloperName=:hName];
        */
        system.runAs(u)
        {
            Test.startTest();
            Boolean value=FeatureToggling.featureUtility(hName);
            Test.stopTest();
            system.debug('<Login with Sales Enterprise B2B & Flag is -->DummyServiceSalesEnter & NOT Active----->5'+value);
            system.assertEquals(False, value);
        }
        
    }
    //6th record Active,NONE profile,permission set Diamond_Campaign,
    // return true
    Public static testMethod void testSalesEnterfeaturetoggle6th(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales - Enterprise']; 
        User u = TestUtil.createTestUser(null,p.id,'testSalesEnterfeature','featuretoggle6th');
        u.Phone = '0445678001';
        insert u;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Diamond_Campaign'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        //User testUser = [select id, name, isActive,Alias from User where isactive = true AND Alias =:'kkish'];
        string hName = 'profile';        
        /*Feature_Flags__mdt featureFlag=[SELECT Active__c,DeveloperName,Id,
                                        Permission_Set__c,
                                      Profile__c FROM Feature_Flags__mdt WHERE DeveloperName=:hName];
        */
		system.runAs(u)
        {
            Test.startTest();            
            Boolean value=FeatureToggling.featureUtility(hName);
            system.debug('<Login with Sales - Enterprise ang Flag is -->NONE--&-- Active---------->6'+value);
            Test.stopTest();
            system.assertEquals(False, value);
            
        }
        
    }
    //7th record Active,NONE profile,permission set Diamond_Campaign,
    // return false
    Public static testMethod void testSalesEnterfeaturetoggle7th(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales - Enterprise']; 
        User u = TestUtil.createTestUser(null,p.id,'testSalesEnter','featuretoggle7th');
        u.Phone = '0445678001';
        insert u;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Diamond_Campaign'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        //User testUser = [select id, name, isActive,Alias from User where isactive = true AND Alias =:'kkish'];
        string hName = 'profile';        
        /*Feature_Flags__mdt featureFlag=[SELECT Active__c,DeveloperName,Id,
                                        Permission_Set__c,
                                      Profile__c FROM Feature_Flags__mdt WHERE DeveloperName=:hName];
        */
		system.runAs(u)
        {
            Test.startTest();            
            Boolean value=FeatureToggling.featureUtility(hName);
            system.debug('<Login with Sales - Enterprise ang Flag is -->NONE--&-- Active---------->7'+value);
            Test.stopTest();
            system.assertEquals(False, value);
            
        }
        
    }
    
    //8th record Active,Sales Manager - Enterprise profile,permission set Diamond_Campaign,
    // return True
    Public static testMethod void testSalesEnterfeaturetoggle8th(){
        // As part of Sales Enterpise Offshore and Sales Manager Enterprise Offshore removal changed the Query(EDGE-25260).
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Manager - Enterprise']; 
        User u = TestUtil.createTestUser(null,p.id,'testSalesEnterfeature','featuretoggle7th');
        u.Phone = '0445678001';
        insert u;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Diamond_Campaign'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        //User testUser = [select id, name, isActive,Alias from User where isactive = true AND Alias =:'kkish'];
        string hName = 'DummySalesME';        
        /*Feature_Flags__mdt featureFlag=[SELECT Active__c,DeveloperName,Id,
                                        Permission_Set__c,
                                      Profile__c FROM Feature_Flags__mdt WHERE DeveloperName=:hName];
        */
		system.runAs(u)
        {
            Test.startTest();            
            Boolean value=FeatureToggling.featureUtility(hName);
            system.debug('<Login with Sales - Enterprise ang Flag is -->NONE--&-- Active---------->8'+value);
            Test.stopTest();
            system.assertEquals(True, value);
            
        }
        
    }
}