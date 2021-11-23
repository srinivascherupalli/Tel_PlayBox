/*******************************************************************
Created By          :   Team Hawaii (Paresh)
Created Date        :   23/9/2019
Desc                :   This Class is test class for 'PRMCaseDetail' 

DUPLICATE_USERNAME Fixes - Hawaii - 02-09-2020
Modified Date & Des :   (P2OB-12617)16/2/2021: Modified testGetCaseFieldList method pass additional parameters
***********************************************************************/
@isTest
public class PRMCaseDetailTest {
    
    @testSetup static void setup() {
        
        Map<String,Profile> profileMap = new Map<String,Profile>();
        Profile[] partnerProfile = [Select id,Name from Profile where Name IN ('PRM Community User - Australia','System Administrator')];
        for(Profile prof : partnerProfile){
            profileMap.put(prof.Name,prof);
        }
        
        UserRole userRole = [Select id,Name from UserRole where Name = 'CEO']; 
        
        Test.startTest();
        
        // DUPUPLICATE_USERNAME - Hawaii - 02-09-2020
        List<User> adminUserList = PRMTestUtility.createInternalUsers(2, new List<Profile>{profileMap.get('System Administrator')}, userRole) ;
        insert adminUserList;
        
        system.runas(adminUserList[0]){
           
           List<Account> accList = new List<Account>(); 
           // DUPUPLICATE_USERNAME - Hawaii - 02-09-2020
            Id accountPartnerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
           Account acc = new Account();
                acc.Name = 'Test Accountdit';
                acc.Partner_Type__c='Channel';
                acc.Customer_Status__c='ACTIVE';
                acc.Migrated_Customer__c=true;
                acc.RecordTypeId = accountPartnerRecTypeId;
                accList.add(acc);
           insert accList;
            
           // Test class fixes - Hawaii - 02-09-2020
           Id partnerRecord = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner_Contact').getRecordTypeId();
           List<Contact> conList = PRMTestUtility.createContact(1,partnerRecord,accList[0].Id);
           insert conList;
            
            accList[0].isPartner = True;
            accList[0].PartnerPrincipalContact__c = conList[0].id;
            update accList;
            
            // DUPLICATE_USERNAME - Hawaii - 02-09-2020
            List<User> userList = PRMTestUtility.createPartnerUsers(1, new List<Profile>{profileMap.get('PRM Community User - Australia')}, conList,true);
            insert userList;
            
            system.runas(adminUserList[1]){
                PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PRM_Pilot_User_Permission'];
                insert new PermissionSetAssignment(AssigneeId = userList[0].id, PermissionSetId = ps.Id);
            }
        }
        Test.stopTest();
    }
    
    public static testMethod void testcheckUserCustomPermission(){
        Test.startTest();
        User[] partnerUser = [Select id,username from User where email='test@noemail45345555.com0' AND lastname='Testing'];
        system.runas(partnerUser[0]){
           Boolean isTrue = PRMCaseDetail.checkUserCustomPermission();
           system.assertEquals(isTrue,True);
        }
        Test.stopTest();
    }
    
    public static testMethod void testGetCaseFieldList(){
        Test.startTest();
        User[] partnerUser = [Select id,username from User where email='test@noemail45345555.com0' AND lastname='Testing'];
        Account acc = [SELECT id FROM Account WHERE Name = 'Test Accountdit' LIMIT 1];//P2OB-6277 : Account mandatory for channel care cases removed UI layout validation and kept validation rule
        Id partnerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
        system.runas(partnerUser[0]){
            Case[] caseList = new List<Case>();
                Case newCase = new Case();
                newCase.RecordTypeId = partnerRecTypeId;
                newCase.soc_SFD_Product_Status__c = 'New';
                newCase.Origin = 'Phone';
                newCase.Subject = 'Test Subject';
                newCase.Description = 'Test Description';
                newCase.Work_Required_PRM__c = 'Modification';
                newCase.Category_PRM__c = 'Ordering';
                newCase.Support_Type_PRM__c = 'Non SFD Order Request';
                newCase.AccountID=acc.id;//P2OB-6277 : Account mandatory for channel care cases removed UI layout validation and kept validation rule
                caseList.add(newCase);
            insert caseList;
            String jsonStructure = '[{"metadataField" :"Support_Type_PRM__c", "objectField" :"Support_Type_PRM__c","Value":"1"},{"metadataField" :"Category_PRM__c", "objectField" :"Category_PRM__c","Value":"1"},{"metadataField" :"Work_Required_PRM__c", "objectField" :"Work_Required_PRM__c","Value":"1"},{"metadataField" :"ss_Type__c", "objectField" :"ss_Type__c","Value":"2"},{"metadataField" :"ss_Category__c", "objectField" :"ss_Category__c","Value":"2"},{"metadataField" :"ss_Work_Required__c", "objectField" :"ss_Work_Required__c","Value":"2"}]';
            Map<String,List<String>> stringMap = PRMCaseDetail.getCaseFieldList(caseList[0].Id,'Case','PRM_Case_Detail_Config__mdt',jsonStructure);
            system.assertEquals(stringMap.size(),3);
        }
        Test.stopTest();
    }
}