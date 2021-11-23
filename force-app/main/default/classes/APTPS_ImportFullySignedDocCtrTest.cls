/*****************************************************************
@Name: APTPS_ImportFullySignedDocCtrTest
@Author: Ruchika Patil 
@CreateDate: 21/06/2016 
@Description: This is the Test class for APTPS_ImportFullySignedDocController
@UsedBy: APTPS_ImportFullySignedDocController 
******************************************************************/ 
@isTest
public with sharing class APTPS_ImportFullySignedDocCtrTest{
    /******************************************************************
    @Description: 
    *******************************************************************/  
    static testMethod void APTPS_ImportFullySignedDocController(){
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        Apttus__APTS_Agreement__c childAgmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        
        //List<Apttus__APTS_Agreement__c> agmtList = [Select id, recordtypeid, recordtype.name from Apttus__APTS_Agreement__c where id =:agmt.id or id=: childAgmt.id];
        Attachment agmtAttachment = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date1', agmt.id);     
        Attachment childAgmtAttachment = APTPS_TestClassData.attachmentRecord('acct-childAgmt_Original_date1', childAgmt.id);  
        Attachment importedDocument = APTPS_TestClassData.attachmentRecord('Fully Signed Document', agmt.id);      
        
        childAgmt.Apttus__Parent_Agreement__c = agmt.id;
        agmt.Apttus__Status_Category__c = childAgmt.Apttus__Status_Category__c = 'In Signatures';
        agmt.Apttus__Status__c = childAgmt.Apttus__Status__c = 'Other Party Signatures';
        //agmt.Apttus__Company_Signed_Date__c = childAgmt.Apttus__Company_Signed_Date__c = Date.today();
       
        update agmt;
        update childAgmt; 
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_ImportFullySignedDocController controller = new APTPS_ImportFullySignedDocController(stdCon);
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementActivation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', agmt.Id);
        //when we have id added
        controller = new APTPS_ImportFullySignedDocController(stdCon);
        
        system.assertEquals(agmt.id, controller.parentAgreement.id);
        system.assertEquals(agmt.Name, controller.agreementName);
        controller.getAgreements();
        
        Id recordtypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        system.assertEquals(recordtypeID, controller.bsaRecordtypeid);
        recordtypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
        system.assertEquals(recordtypeID, controller.panelRecordtypeid);
        
         for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected = true;
        }
        
        //When Company signed date and Document, both are not updated.
        PageReference importPageRef = controller.import();
        ApexPages.Message[] pageMessages1 = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages1.size());
        system.assertEquals(null, importPageRef);
        
        //When Comapny signed date is filled but no document attached.
        controller.parentAgreement.Apttus__Company_Signed_Date__c =  System.Today();
        importPageRef = controller.import();
        ApexPages.Message[] pageMessages2 = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages2.size());
        system.assertEquals(null, importPageRef);
        
        //When company signed date is not filled but document is attached.
        controller.parentAgreement.Apttus__Company_Signed_Date__c = null;
        controller.fileName = importedDocument.name;
        controller.importedAttachment = importedDocument.body;
        importPageRef = controller.import();
        ApexPages.Message[] pageMessages3 = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages3.size());
        system.assertEquals(null, importPageRef);
        
        //When both COmpany signed date and document are attached.
        controller.myDoc.name = importedDocument.name;
        controller.myDoc.body = importedDocument.body;
        controller.parentAgreement.Apttus__Company_Signed_Date__c =  System.Today();
        importPageRef = controller.import();
        //system.assertEquals('/'+agmt.Id, importPageRef.getUrl());
              
        Test.stopTest();
  
        
    }
    
}