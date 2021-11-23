/*
 * Author : Team Hawaii: Ritika Jaiswal
 * Description : Test class for PRMMassEmailPlugin
 * Jira : P2OB - 8405
 * Created Date : 16-July-2020
*/
@isTest
public class PRMMassEmailPlugin_Test{
    
    @testsetup static void testsetUpData(){     
    	Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile where name in ('PRM Community User - Australia','System Administrator')])
            profilesMap.put(profile.Name, profile);
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName=:'Sales_Ops' ])
            rolesMap.put(role.DeveloperName, role);
        //P2OB - 8405 :Creation of admin user
        User[] adminUser = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('System Administrator')} , rolesMap.get('Sales_Ops'));
        insert adminUser;
        Account[] partnerAccount;List<Contact> contacts;List<User> partnerUsers;
        //P2OB - 8405 :Creation of partner account
        System.runAs(adminUser[0]){
        partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
        insert partnerAccount;
        }
        //P2OB - 8405 :Creation of partner contacts
        System.runAs(adminUser[0]){
        id rtypeId2 = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();
        contacts = PRMTestUtility.createContact(5,rtypeId2,partnerAccount[0].Id);
        insert contacts;
        }
        //P2OB - 8405 :Creation of email templates and partner user
        System.runAs(adminUser[0]){
        EmailTemplate etemplate = new EmailTemplate (developerName = 'test_prm_emails_failure_Test',folderId=UserInfo.getUserId() , TemplateType= 'Text', Name = 'PRMMassEmailPlugin_Test',isActive = true,Subject = 'TestEmail');
        insert etemplate;    
        string templateText = '<messaging:emailTemplate subject="{!relatedTo.Name}" recipientType="User" relatedToType="User"><messaging:htmlEmailBody ><ul><li>test content</li></ul></messaging:htmlEmailBody></messaging:emailTemplate>';
        EmailTemplate template = new EmailTemplate(DeveloperName = 'TestEmailVFTemplate', TemplateType= 'Visualforce', FolderId = UserInfo.getUserId(),
        Name = 'TestEmailVFTemplate',
        IsActive = true);
        template.Markup=templateText;
        insert template;       
        partnerUsers = PRMTestUtility.createPartnerUsers(5, new List<Profile>{profilesMap.get('PRM Community User - Australia')}, contacts,false);
        insert partnerUsers;
        } 
    
    }
    
    //P2OB - 8405 : Test Method for success of mass-email to a list of users
    public static testMethod void test_prm_emails_success(){        
        Test.startTest();
        List<User> partnerUsers = [select id,email,contactId from user where email like 'test@noemail45345555.com%' limit 5];
        System.debug('***partnerUsers:'+partnerUsers);
        //P2OB-8405 : Call to PRMMassEmailPlugin with list of users as input
        PRMMassEmailPlugin.FlowInputParameter finput = new PRMMassEmailPlugin.FlowInputParameter();
        finput.invokedby_FlowInterviewGuid = 'f1';
        finput.sobjectList =  partnerUsers;
        finput.EmailTemplateAPIName = 'TestEmailVFTemplate';         
        finput.orgWidEmailAddress='do-not-reply-phoenix@team.telstra.com';
        List<PRMMassEmailPlugin.FlowOutputParameter> outputList = PRMMassEmailPlugin.sendMassEmail(new List<PRMMassEmailPlugin.FlowInputParameter>{finput});
        //P2OB-8405 : Assertion to verify the output and results
        System.assert(outputList.size()>0 && outputList[0].isResultSuccess);
        Test.stopTest(); 
    }
    
    //P2OB - 8405 : Test Method for failure of mass-email 
    public static testMethod void test_prm_emails_failure(){
        List<User> partnerUsers = [select id,email,contactId from user where email like 'test@noemail45345555.com%' limit 5];
        Test.startTest();   
        PRMMassEmailPlugin.FlowInputParameter finput = new PRMMassEmailPlugin.FlowInputParameter();
        finput.invokedby_FlowInterviewGuid = 'f2';
        finput.sobjectList =  partnerUsers;         
        finput.EmailTemplateAPIName = 'test_prm_emails_failure_Test';          
        finput.orgWidEmailAddress='do-not-reply-phoenix@team.telstra.com';
        List<PRMMassEmailPlugin.FlowOutputParameter> outputList = PRMMassEmailPlugin.sendMassEmail(new List<PRMMassEmailPlugin.FlowInputParameter>{finput});
        //P2OB-8405 : Assertion to verify the output
        System.assert(outputList.size() > 0);
        Test.stopTest(); 
        
    }
    
 }