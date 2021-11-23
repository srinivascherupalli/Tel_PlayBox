/****************************************************************************
@Author: Nilesh Dethe
@CreateDate: 28/07/2018
@Story: EDGE-30036
@Description: FCREndDatedMessageAlertControllerTest test covrage class for covering FCREndDatedMessageAlertController Class of lightning component FCREndDatedMessageAlert.
@Classes Covered: FCREndDatedMessageAlertController
@ChangeLog: v1: Created
********************************************************************************/
@isTest
public class FCREndDatedMessageAlertControllerTest {
	@testSetup static void setup() {
        Test.loadData(Account.sObjectType, 'FCR_Account');
        Test.loadData(Contact.sObjectType, 'FCR_Contact');
    }
    
    @isTest
    static void testisFCREndDatedHavingNonAuthACR(){
        FunctionalContactRoleTriggerHelper fcrHelper = new FunctionalContactRoleTriggerHelper();
        List<sobject> lstAcc=[Select id from account];
        List<sobject> lstCon=[Select id from contact];
        
        Test.startTest();

        cscrm__Site__c site1 = new cscrm__Site__c(cscrm__Account__c=lstAcc[0].Id,Name='test FCR Site1');
        Insert site1;
        system.assert(site1.Id != null);
        
        Functional_Contact_Role__c fcrSite1 = new Functional_Contact_Role__c();
        fcrSite1.ContactID__c = lstCon[1].Id;
        fcrSite1.SiteID__c = site1.Id;
        fcrSite1.RecordTypeId = fcrHelper.getFCRRecordTypeId('Site Role');
        Insert fcrSite1;
        system.assert([Select Id from Functional_Contact_Role__c].size() == 1);
        system.assert([select id from AccountContactRelation where accountid = :lstAcc[0].Id and contactid = :lstCon[1].id].size() == 1);
        
        fcrSite1.Relationship_End_Date__c = Date.today();
        Update fcrSite1;
        Functional_Contact_Role__c updSiteFcr = [Select Id,Relationship_End_Date__c from Functional_Contact_Role__c Where Id = :fcrSite1.id LIMIT 1];
        system.assert(updSiteFcr.Relationship_End_Date__c == Date.today());
        
        Boolean siteResp = FCREndDatedMessageAlertController.isFCREndDatedHavingActiveACR(updSiteFcr.Id);
        system.assert(siteResp);
        
        csord__Order__c order1 = new csord__Order__c(Name='fcr Test Order1',csord__Account__c=lstAcc[0].id,csord__Identification__c='test1');
        Insert order1;
        system.assert(order1.id != null);
        
        Functional_Contact_Role__c fcrOrder1 = new Functional_Contact_Role__c();
        fcrOrder1.ContactID__c = lstCon[1].Id;
        fcrOrder1.OrderID__c = order1.Id;
        fcrOrder1.RecordTypeId = fcrHelper.getFCRRecordTypeId('Basket/Order Role');
        Insert fcrOrder1;
        system.assert([Select Id from Functional_Contact_Role__c where id = :fcrOrder1.Id].size() == 1);
        system.assert([select id from AccountContactRelation where accountid = :lstAcc[0].Id and contactid = :lstCon[1].id].size() == 1);
        
        fcrOrder1.Relationship_End_Date__c = Date.today();
        Update fcrOrder1;
        Functional_Contact_Role__c updOrderFcr = [Select Id,Relationship_End_Date__c from Functional_Contact_Role__c Where Id = :fcrOrder1.id LIMIT 1];
        system.assert(updOrderFcr.Relationship_End_Date__c == Date.today());
        
        Boolean orderResp = FCREndDatedMessageAlertController.isFCREndDatedHavingActiveACR(updOrderFcr.Id);
        system.assert(orderResp);
        
        csord__Subscription__c subRole1 = new csord__Subscription__c(Name='Test FCR Sub1', csord__Account__c=lstAcc[0].id,csord__Identification__c='testSub1');
        Insert subRole1;
        system.assert(subRole1.id != null);
        
        Functional_Contact_Role__c fcrSub1 = new Functional_Contact_Role__c();
        fcrSub1.ContactID__c = lstCon[1].Id;
        fcrSub1.SubscriptionID__c = subRole1.Id;
        fcrSub1.RecordTypeId = fcrHelper.getFCRRecordTypeId('Subscription Role');
        Insert fcrSub1;
        system.assert([Select Id from Functional_Contact_Role__c where id = :fcrSub1.Id].size() == 1);
        system.assert([select id from AccountContactRelation where accountid = :lstAcc[0].Id and contactid = :lstCon[1].id].size() == 1);
        
        fcrSub1.Relationship_End_Date__c = Date.today();
        Update fcrSub1;
        Functional_Contact_Role__c updSubFcr = [Select Id,Relationship_End_Date__c from Functional_Contact_Role__c Where Id = :fcrSub1.id LIMIT 1];
        system.assert(updSubFcr.Relationship_End_Date__c == Date.today());
        
        Boolean subResp = FCREndDatedMessageAlertController.isFCREndDatedHavingActiveACR(updSubFcr.Id);
        system.assert(subResp);
        AccountContactRelation acr = [select id from AccountContactRelation where accountid = :lstAcc[0].Id and contactid = :lstCon[1].id];
        acr.Relationship_End_Date__c =  Date.today();
        update acr;
        Test.stopTest();
        Boolean subResp1 = FCREndDatedMessageAlertController.isFCREndDatedHavingActiveACR(updSubFcr.Id);
        system.assert(subResp1==false,'False');
        Functional_Contact_Role__c Fcr = [Select Id,Relationship_End_Date__c from Functional_Contact_Role__c Where Id = :fcrSub1.id LIMIT 1];
        fcr.Relationship_End_Date__c = null;
        update fcr;
        Boolean subResp2 = FCREndDatedMessageAlertController.isFCREndDatedHavingActiveACR(updSubFcr.Id);
        system.assert(subResp2==false,'False');
    }
}