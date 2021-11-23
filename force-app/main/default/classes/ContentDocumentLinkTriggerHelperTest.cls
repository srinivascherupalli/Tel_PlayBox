/*
Name        Date           Description
Divya   12/15/2020  Test Class for ContentDocumentLinkTriggerHelper
*/
@isTest
public class ContentDocumentLinkTriggerHelperTest {
         /*-------------------------------------------------------- 
EDGE-170431
Description: test method to attach the order form file to PS
Author:Divya Chilakabathini
--------------------------------------------------------*/
    @istest
    Private static  void contractOrderForm(){  
        
        list<id> conList = new List<id>();
        Id agreementRecordType = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        
        Account acc = TestDataFactory.generateAccount();
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        update acc;
        
        //CREATE CONTACT 
        Contact contact = TestDataFactory.generateContact('TestPricing',acc.Id,'Active','TestDelegate',System.today(),'eMail');
        insert contact;
        contact.Email = 'test@tele2.com';
        update contact;
        
        // Creating Opportunity Reocrd
        Opportunity sobj = ApttusTestDataFactory.buildOpportunity1(acc);
        
        List<ContentDocumentLink> conDocLink = new List<ContentDocumentLink>();
        cscfga__Product_Basket__c basket = ApttusTestDataFactory.buildProductBasket(acc,sobj);
        insert basket;
        
        ContractJunction__c oldContract=ApttusTestDataFactory.buildContractt(basket.csbb__Account__c,sobj.id,basket.id);
        
        
        Apttus__APTS_Agreement__c agt = ApttusTestDataFactory.buildAgg(acc.id,oldContract.id,basket.id,agreementRecordType);
        agt.Apttus__Status_Category__c = 'Cancelled';
        update agt;
         
        oldContract.Related_Price_Schedule__c = agt.Id;
        update oldContract;
        Test.StartTest();
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Order Form',
            PathOnClient = 'Order Form.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> cc = new List<ContentDocumentLink>();
        ContentDocumentLink cJ = new ContentDocumentLink();
        cJ.LinkedEntityId = oldContract.Id;        
        cJ.ContentDocumentId = documents1[0].Id;
        cJ.shareType = 'V';
        cc.add(cj);
        insert cc; 
        
        
        ContentDocumentLinkTriggerHelper.attachOrderFormFilePS(cc);
        //Apttus__APTS_Agreement__c ag = [SELECT ID,Name, Related_Contract__c,(SELECT ID, ContentDocumentId,ContentDocument.Title,ContentDocument.FileExtension, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLinks) FROM Apttus__APTS_Agreement__c WHERE Related_Contract__c=:oldContract.id AND Id=:agt.id limit 1];
        for(Apttus__APTS_Agreement__c ag : [SELECT ID,Name, Related_Contract__c,(SELECT ID, ContentDocumentId,ContentDocument.Title,ContentDocument.FileExtension, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLinks limit 5) FROM Apttus__APTS_Agreement__c WHERE Related_Contract__c=:oldContract.id AND Id=:agt.id limit 1]){
            System.debug('ag.ContentDocumentLinks.size()='+ag.ContentDocumentLinks.size());
        }
        //system.debug('ag::'+ag.ContentDocumentLinks.size());
        //system.assert(ag.ContentDocumentLinks.size()>0);
        Test.StopTest();
        
    }
        @istest
    Private static  void contractOrderFormNegative(){  
        
        list<id> conList = new List<id>();
        Id agreementRecordType = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        
        Account acc = TestDataFactory.generateAccount();
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        update acc;
        
        //CREATE CONTACT 
        Contact contact = TestDataFactory.generateContact('TestPricing',acc.Id,'Active','TestDelegate',System.today(),'eMail');
        insert contact;
        contact.Email = 'test@tele2.com';
        update contact;
        
        // Creating Opportunity Reocrd
        Opportunity sobj = ApttusTestDataFactory.buildOpportunity1(acc);
        
        List<ContentDocumentLink> conDocLink = new List<ContentDocumentLink>();
        cscfga__Product_Basket__c basket = ApttusTestDataFactory.buildProductBasket(acc,sobj);
        insert basket;
        
        ContractJunction__c oldContract=ApttusTestDataFactory.buildContractt(basket.csbb__Account__c,sobj.id,basket.id);
        
        
        Apttus__APTS_Agreement__c agt = ApttusTestDataFactory.buildAgg(acc.id,oldContract.id,basket.id,agreementRecordType);
        
        
        oldContract.Related_Price_Schedule__c = agt.Id;
        update oldContract;
        Test.StartTest();
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Order Form',
            PathOnClient = 'Order Form.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> cc = new List<ContentDocumentLink>();
        ContentDocumentLink cJ = new ContentDocumentLink();
        cJ.LinkedEntityId = oldContract.Id;        
        cJ.ContentDocumentId = documents1[0].Id;
        cJ.shareType = 'V';
        cc.add(cj);
        insert cc; 
        
        ContentDocumentLinkTriggerHelper.attachOrderFormFilePS(cc);
        System.debug('');
        Apttus__APTS_Agreement__c ag = [SELECT ID,Name, Related_Contract__c,(SELECT ID, ContentDocumentId,ContentDocument.Title,ContentDocument.FileExtension, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLinks) FROM Apttus__APTS_Agreement__c WHERE Related_Contract__c=:oldContract.id AND Id=:agt.id];
        system.debug('ag::'+ag.ContentDocumentLinks.size());
        system.assert(ag.ContentDocumentLinks.size()==0);
        Test.StopTest();
        
    }
}