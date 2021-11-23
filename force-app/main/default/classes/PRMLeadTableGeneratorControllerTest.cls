/*
Version    Last Modified Date    Author                    Description
1.0        16 Mar 2021           Vivian Charlie [Hawaii]   P2OB-13537 Getting Lead Recordtype by developername from Lead_Recordtype_Enterprise custom label
*/
@isTest
private class PRMLeadTableGeneratorControllerTest{
    private static testMethod void unitTest(){
        UserRole r = [Select DeveloperName, Id From UserRole where DeveloperName='Sales_Ops' limit 1]; 
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        id accRecordTypeIdpartner = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        id pconRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner Contact').getRecordTypeId();
        id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact layout').getRecordTypeId();
        id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();// get id by developername
        
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];

        User uSysAdmin = new User(alias = 'Con123', email = 'ContactTr8wrw98@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Cont987657awqas@noemail.com', userroleid = r.id);

        insert uSysAdmin;
        system.debug('uSysAdmin***********'+uSysAdmin);

        System.runAs(uSysAdmin){
            list<Account> acc = PRMTestUtility.createAccounts(1,accRecordTypeId);
            insert acc;
            
            list<Contact> con = PRMTestUtility.createContact(1, conRecordTypeId, acc[0].Id);
            con.addAll(PRMTestUtility.createContact(1, pconRecordTypeId,null));
            insert con;
        
            list<Account> partneracc = PRMTestUtility.createPartnerAccounts(1,accRecordTypeIdpartner,'Partner','Active',null);
            partneracc[0].PartnerPrincipalContact__c = con[0].id;
            insert partneracc;
            
            partneracc[0].isPartner = true;
            update partneracc;
            list<Lead> lstL = PRMTestUtility.createLeads(5, leadRecordtypeId, acc[0].Id, partneracc[0].Id, con[0].Id, 'MOBILES');
            for(Lead objL : lstL){
                objL.Trigger_Share_with_Partner__c = true;
            }
            insert lstL;
            
            PRMLeadTableGeneratorController obj = new PRMLeadTableGeneratorController();
            obj.partnerId = partneracc[0].Id;
            list<lead> lstL1 = obj.getlstLeads();
            system.assertEquals(lstL1.size(), 5);
        }
    }
}