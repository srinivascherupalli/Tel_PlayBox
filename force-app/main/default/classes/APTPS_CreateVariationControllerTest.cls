@isTest
public with sharing class APTPS_CreateVariationControllerTest{
    
    static testMethod void APTPS_CreateVariationController(){
        
        //create admin Setting
        Apttus__APTS_Admin__c variationConfig = new Apttus__APTS_Admin__c();
        variationConfig.Name = 'APTS_VariationConfig';
        variationConfig.Apttus__Value__c = 'XML';
        variationConfig.Apttus__Code__c = '<VariationsConfig><ReparentedObjects><ChildObject><Name>APTPS_Related_Companies__c</Name><RelationField>APTPS_Agreement__c</RelationField></ChildObject><ChildObject><Name>Apttus_SRM__Issue__c</Name><RelationField>Apttus_SRM__Agreement__c</RelationField></ChildObject><ChildObject><Name>Fund__c</Name><RelationField>Agreement__c</RelationField></ChildObject></ReparentedObjects><ClonedObjects><ChildObject><Name>Apttus__AgreementLineItem__c</Name><RelationField>Apttus__AgreementId__c</RelationField><GrandChildReparented><Name>APTPS_Minimum_Spend_Entry__c</Name><RelationField>APTPS_Agreement_Line_Item__c</RelationField><ChildRelationship>Minimum_Spend__r</ChildRelationship></GrandChildReparented><GrandChildCloned><Name>APTPS_Component__c</Name><RelationField>Agreement_Line_Item__c</RelationField><ChildRelationship>Components__r</ChildRelationship></GrandChildCloned></ChildObject><ChildObject><Name>Apttus_SRM__SRMObligation__c</Name><RelationField>Apttus_SRM__AgreementId__c</RelationField><GrandChildReparented><Name>Apttus_SRM__Issue__c</Name><RelationField>Apttus_SRM__ObligationId__c</RelationField><ChildRelationship>Apttus_SRM__Issues__r</ChildRelationship></GrandChildReparented><GrandChildReparented><Name>Task</Name><RelationField>Whatid</RelationField><ChildRelationship>Tasks</ChildRelationship></GrandChildReparented></ChildObject></ClonedObjects><ClearFields><ClearField><Name>Apttus_Approval__Term_Exception_Approval_Status__c</Name></ClearField><ClearField><Name>APTPS_Pricing_Approval_Needed__c</Name></ClearField><ClearField><Name>Apttus_Approval__Approval_Status__c</Name></ClearField><ClearField><Name>Apttus__Contract_Start_Date__c</Name></ClearField><ClearField><Name>Apttus__Contract_End_Date__c</Name></ClearField><ClearField><Name>Apttus__Term_Months__c</Name></ClearField><ClearField><Name>APTPS_Effective_End_Date__c</Name></ClearField><ClearField><Name>Apttus__Other_Party_Signed_By__c</Name></ClearField><ClearField><Name>Apttus__Other_Party_Signed_Date__c</Name></ClearField><ClearField><Name>Apttus__Company_Signed_By__c</Name></ClearField><ClearField><Name>Apttus__Company_Signed_Date__c</Name></ClearField><ClearField><Name>Apttus__Activated_By__c</Name></ClearField><ClearField><Name>Apttus__Activated_Date__c</Name></ClearField><ClearField><Name>Apttus__Special_Terms__c</Name></ClearField></ClearFields></VariationsConfig>';
        insert variationConfig;
        
        //create account
        Account acct = APTPS_TestClassData.accountRecord('Test Account12e2', '3217734598');
        
        //Create Agreement
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt3 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        
        List<Apttus__APTS_Agreement__c> agmtList = [Select id, recordtypeid, recordtype.name from Apttus__APTS_Agreement__c where id =:agmt.id or id=: childAgmt1.id or id=:childAgmt2.id];
        
        childAgmt1.Apttus__Parent_Agreement__c = agmt.ID;
        childAgmt2.Apttus__Parent_Agreement__c = agmt.ID;
        childAgmt3.Apttus__Parent_Agreement__c = agmt.ID;
        agmt.Apttus__Status_Category__c = childAgmt1.Apttus__Status_Category__c = childAgmt2.Apttus__Status_Category__c =  'In Effect';
        agmt.Apttus__Status__c = childAgmt1.Apttus__Status__c = childAgmt2.Apttus__Status__c = 'Activated';
        childAgmt3.Apttus__Status_Category__c = 'Request';
        childAgmt3.Apttus__Status__c = 'Request';
        agmt.Apttus__Company_Signed_Date__c = childAgmt1.Apttus__Company_Signed_Date__c = childAgmt2.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 1, 11);
        agmt.Apttus__Contract_End_Date__c = childAgmt1.Apttus__Contract_End_Date__c = childAgmt2.Apttus__Contract_End_Date__c = Date.newInstance(2016, 5, 11);
        agmt.Apttus__Term_Months__c = childAgmt1.Apttus__Term_Months__c = childAgmt2.Apttus__Term_Months__c = 4;
        update agmt;
        update childAgmt1;
        update childAgmt2;
        update childAgmt3;
        
        Attachment attach1 = APTPS_TestClassData.attachmentRecord('acct-agmt_1', agmt.id); 
        Attachment attach2 = APTPS_TestClassData.attachmentRecord('acct-agmt_2', agmt.id);      
        
        Note noteA = new Note(Body = 'test Body', ParentId = agmt.id, Title = 'Test');
        insert noteA;
        
        Apttus__APTS_Related_Agreement__c relAgmt = new Apttus__APTS_Related_Agreement__c(Apttus__APTS_Contract_To__c = agmt.id, name = 'Current Agreement', Apttus__APTS_Contract_From__c = childAgmt3.id);
        insert relAgmt;
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Description = 'test';
        prod.Family = 'test';
        insert prod;
        Apttus__AgreementLineItem__c lineItem = APTPS_TestClassData.agreementLineItemRecord(agmt.ID, prod.ID);      
        
        APTPS_Component__c component = new APTPS_Component__c();
        component.Agreement_Line_Item__c = lineItem.ID;
        insert component;
        
        APTPS_Minimum_Spend_Entry__c minSpendEntry = new APTPS_Minimum_Spend_Entry__c(Name = 'testMSE', APTPS_Agreement_Line_Item__c = lineItem.ID);
        insert minSpendEntry;
        
        Apttus_SRM__Issue__c issue = APTPS_TestClassData.issueRecord(agmt.id, acct.id, '0 - Inherent Risk','Not Started');   

        PageReference pageRef = Page.APTPS_CreateVariation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', agmt.Id);
        
        Test.startTest();
        
        APTPS_CreateVariationController controller = new APTPS_CreateVariationController(new ApexPages.standardController(agmt));
        pageRef = controller.createVariation();
        Test.StopTest();
        System.assertNotEquals(null, pageRef);
    }
    static testMethod void APTPS_CreateVariationController2(){
        
        //create admin Setting
        Apttus__APTS_Admin__c variationConfig = new Apttus__APTS_Admin__c();
        variationConfig.Name = 'APTS_VariationConfig';
        variationConfig.Apttus__Value__c = 'XML';
        variationConfig.Apttus__Code__c = '<VariationsConfig><ReparentedObjects><ChildObject><Name>APTPS_Related_Companies__c</Name><RelationField>APTPS_Agreement__c</RelationField></ChildObject><ChildObject><Name>Apttus_SRM__Issue__c</Name><RelationField>Apttus_SRM__Agreement__c</RelationField></ChildObject><ChildObject><Name>Fund__c</Name><RelationField>Agreement__c</RelationField></ChildObject></ReparentedObjects><ClonedObjects><ChildObject><Name>Apttus__AgreementLineItem__c</Name><RelationField>Apttus__AgreementId__c</RelationField><GrandChildReparented><Name>APTPS_Minimum_Spend_Entry__c</Name><RelationField>APTPS_Agreement_Line_Item__c</RelationField><ChildRelationship>Minimum_Spend__r</ChildRelationship></GrandChildReparented><GrandChildCloned><Name>APTPS_Component__c</Name><RelationField>Agreement_Line_Item__c</RelationField><ChildRelationship>Components__r</ChildRelationship></GrandChildCloned></ChildObject><ChildObject><Name>Apttus_SRM__SRMObligation__c</Name><RelationField>Apttus_SRM__AgreementId__c</RelationField><GrandChildReparented><Name>Apttus_SRM__Issue__c</Name><RelationField>Apttus_SRM__ObligationId__c</RelationField><ChildRelationship>Apttus_SRM__Issues__r</ChildRelationship></GrandChildReparented><GrandChildReparented><Name>Task</Name><RelationField>Whatid</RelationField><ChildRelationship>Tasks</ChildRelationship></GrandChildReparented></ChildObject></ClonedObjects><ClearFields><ClearField><Name>Apttus_Approval__Term_Exception_Approval_Status__c</Name></ClearField><ClearField><Name>APTPS_Pricing_Approval_Needed__c</Name></ClearField><ClearField><Name>Apttus_Approval__Approval_Status__c</Name></ClearField><ClearField><Name>Apttus__Contract_Start_Date__c</Name></ClearField><ClearField><Name>Apttus__Contract_End_Date__c</Name></ClearField><ClearField><Name>Apttus__Term_Months__c</Name></ClearField><ClearField><Name>APTPS_Effective_End_Date__c</Name></ClearField><ClearField><Name>Apttus__Other_Party_Signed_By__c</Name></ClearField><ClearField><Name>Apttus__Other_Party_Signed_Date__c</Name></ClearField><ClearField><Name>Apttus__Company_Signed_By__c</Name></ClearField><ClearField><Name>Apttus__Company_Signed_Date__c</Name></ClearField><ClearField><Name>Apttus__Activated_By__c</Name></ClearField><ClearField><Name>Apttus__Activated_Date__c</Name></ClearField><ClearField><Name>Apttus__Special_Terms__c</Name></ClearField></ClearFields></VariationsConfig>';
        insert variationConfig;
        
        //create account
        Account acct = APTPS_TestClassData.accountRecord('Test Account12e2', '3217734598');
        
        //Create Agreement
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt3 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        
        List<Apttus__APTS_Agreement__c> agmtList = [Select id, recordtypeid, recordtype.name from Apttus__APTS_Agreement__c where id =:agmt.id or id=: childAgmt1.id or id=:childAgmt2.id];
        
        childAgmt1.Apttus__Parent_Agreement__c = agmt.ID;
        childAgmt2.Apttus__Parent_Agreement__c = agmt.ID;
        childAgmt3.Apttus__Parent_Agreement__c = agmt.ID;
        agmt.Apttus__Status_Category__c = childAgmt1.Apttus__Status_Category__c = childAgmt2.Apttus__Status_Category__c =  'In Effect';
        agmt.Apttus__Status__c = childAgmt1.Apttus__Status__c = childAgmt2.Apttus__Status__c = 'Activated';
        childAgmt3.Apttus__Status_Category__c = 'Request';
        childAgmt3.Apttus__Status__c = 'Request';
        agmt.Apttus__Company_Signed_Date__c = childAgmt1.Apttus__Company_Signed_Date__c = childAgmt2.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 1, 11);
        agmt.Apttus__Contract_End_Date__c = childAgmt1.Apttus__Contract_End_Date__c = childAgmt2.Apttus__Contract_End_Date__c = Date.newInstance(2016, 5, 11);
        agmt.Apttus__Term_Months__c = childAgmt1.Apttus__Term_Months__c = childAgmt2.Apttus__Term_Months__c = 4;
        update agmt;
        update childAgmt1;
        update childAgmt2;
        update childAgmt3;
        
        Attachment attach1 = APTPS_TestClassData.attachmentRecord('acct-agmt_1', childAgmt1.id); 
        Attachment attach2 = APTPS_TestClassData.attachmentRecord('acct-agmt_2', childAgmt1.id);      
        
        Note noteA = new Note(Body = 'test Body', ParentId = childAgmt1.id, Title = 'Test');
        insert noteA;
        
        Apttus__APTS_Related_Agreement__c relAgmt = new Apttus__APTS_Related_Agreement__c(Apttus__APTS_Contract_To__c = childAgmt1.id, name = 'Current Agreement', Apttus__APTS_Contract_From__c = childAgmt3.id);
        insert relAgmt;
        
        Product2 prod = new Product2();
        prod.Name = 'test';
        prod.Description = 'test';
        prod.Family = 'test';
        insert prod;
        Apttus__AgreementLineItem__c lineItem = APTPS_TestClassData.agreementLineItemRecord(childAgmt1.ID, prod.ID);      
        
        APTPS_Component__c component = new APTPS_Component__c();
        component.Agreement_Line_Item__c = lineItem.ID;
        insert component;
        
        APTPS_Minimum_Spend_Entry__c minSpendEntry = new APTPS_Minimum_Spend_Entry__c(Name = 'testMSE', APTPS_Agreement_Line_Item__c = lineItem.ID);
        insert minSpendEntry;
        
        Apttus_SRM__Issue__c issue = APTPS_TestClassData.issueRecord(childAgmt1.id, acct.id, '0 - Inherent Risk','Not Started');    
        
        PageReference pageRef = Page.APTPS_CreateVariation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', childAgmt1.Id);
        
        Test.startTest();
        
        APTPS_CreateVariationController controller = new APTPS_CreateVariationController(new ApexPages.standardController(childAgmt1));
        pageRef = controller.createVariation();
        
        Test.StopTest();
        System.assertNotEquals(null, pageRef);
    }
}