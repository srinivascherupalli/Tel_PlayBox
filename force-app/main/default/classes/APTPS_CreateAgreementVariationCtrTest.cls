@isTest
public with sharing class APTPS_CreateAgreementVariationCtrTest{
    
    static testMethod void APTPS_CreateAgreementVariationCtr(){
        
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
        
        List<Apttus__APTS_Agreement__c> agmtList = [Select id, recordtypeid, recordtype.name from Apttus__APTS_Agreement__c where id =:agmt.id or id=: childAgmt1.id or id=:childAgmt2.id];
       
        agmt.Apttus__Status_Category__c = 'In Effect';
        agmt.Apttus__Status__c = 'Activated';
        agmt.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 1, 11);
        agmt.Apttus__Contract_End_Date__c = Date.newInstance(2016, 5, 11);
        agmt.Apttus__Term_Months__c = 4;
        update agmt;
        
        PageReference pageRef = Page.APTPS_Init_CreateAgreementVariation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        Test.startTest();
        System.assertEquals(APTPS_Constants.IN_EFFECT_STATUS,agmt.Apttus__Status__c );
        APTPS_CreateAgreementVariationController controllertst = new APTPS_CreateAgreementVariationController();
        
        APTPS_CreateAgreementVariationController controller = new APTPS_CreateAgreementVariationController(new ApexPages.standardController(agmt));
        controller.getAgreements();
        controller.createListForAgreementsToBeAmended();
        
        Test.StopTest();
    }
    
    
    static testMethod void APTPS_CreateAgreementVariationCtr2(){
        
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
          System.assertEquals(APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS,childAgmt3.Apttus__Status__c);     
        PageReference pageRef = Page.APTPS_Init_CreateAgreementVariation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        Test.startTest();
        
        APTPS_CreateAgreementVariationController controllertst = new APTPS_CreateAgreementVariationController();
        
        APTPS_CreateAgreementVariationController controller = new APTPS_CreateAgreementVariationController(new ApexPages.standardController(agmt));
        controller.cancel();
        controller.getAgreements();
        controller.createListForAgreementsToBeAmended();
        
        Test.StopTest();
    }
    static testMethod void APTPS_CreateAgreementVariationCtr3(){
        
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
        System.assertEquals(APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS,childAgmt3.Apttus__Status__c);
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
        
        PageReference pageRef = Page.APTPS_Init_CreateAgreementVariation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        Test.startTest();
        
        APTPS_CreateAgreementVariationController controllertst = new APTPS_CreateAgreementVariationController();
        
        APTPS_CreateAgreementVariationController controller = new APTPS_CreateAgreementVariationController(new ApexPages.standardController(agmt));
        controller.cancel();
        controller.getAgreements();
        
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            if(agrGen.agreement.Apttus__Parent_Agreement__c == null){
                agrGen.selected  = true;
            }
            else{
                if(agrGen.agreement.id == childAgmt1.id){
                    agrGen.selected  = true;
                }
            }   
        }
        controller.createListForAgreementsToBeAmended();
        
        ApexPages.currentPage().getParameters().put('attachmentId', attach1.Id);
        controller.cloneAttachments();
        
        ApexPages.currentPage().getParameters().put('attachmentId', attach2.Id);
        controller.cloneAttachments();
        
        List<Id> tempList = new List<Id>();
        tempList.add(attach1.Id);
        tempList.add(attach2.Id);
        controller.attachmentAgreementMap.put(agmt.id, tempList);

        controller.enableAuthoringAsync();
        
        Test.StopTest();
    }
    static testMethod void APTPS_CreateAgreementVariationCtr4(){
        
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
        
        List<Apttus__APTS_Agreement__c> agmtList = [Select id, recordtypeid, recordtype.name from Apttus__APTS_Agreement__c where id =:agmt.id or id=: childAgmt1.id or id=:childAgmt2.id];
        
        childAgmt1.Apttus__Parent_Agreement__c = agmt.ID;
        childAgmt2.Apttus__Parent_Agreement__c = agmt.ID;
        agmt.Apttus__Status_Category__c = 'In Effect';
        agmt.Apttus__Status__c = 'Activated';
        agmt.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 1, 11);
        agmt.Apttus__Contract_End_Date__c = Date.newInstance(2016, 5, 11);
        agmt.Apttus__Term_Months__c = 4;
        update agmt;
        update childAgmt1;
        update childAgmt2;
               
        PageReference pageRef = Page.APTPS_Init_CreateAgreementVariation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        Test.startTest();
        
        APTPS_CreateAgreementVariationController controllertst = new APTPS_CreateAgreementVariationController();
        
        APTPS_CreateAgreementVariationController controller = new APTPS_CreateAgreementVariationController(new ApexPages.standardController(agmt));
        controller.cancel();
        controller.getAgreements();
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            if(agrGen.agreement.Apttus__Parent_Agreement__c == null){
                agrGen.selected  = false;
            }
            else{
                agrGen.selected  = true;
            }   
        }
        try{
            controller.createListForAgreementsToBeAmended();
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Parent agreement has to be selected for creating variation.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        Test.StopTest();
        
    }
    static testMethod void APTPS_CreateAgreementVariationCtr5(){
        
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
               
        PageReference pageRef = Page.APTPS_Init_CreateAgreementVariation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        Test.startTest();
        
        APTPS_CreateAgreementVariationController controllertst = new APTPS_CreateAgreementVariationController();
        
        APTPS_CreateAgreementVariationController controller = new APTPS_CreateAgreementVariationController(new ApexPages.standardController(agmt));
        controller.cancel();
        controller.getAgreements();
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected  = false;  
        }
        try{
            controller.createListForAgreementsToBeAmended();
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Please select atleast one record.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        Test.StopTest();
    }
    
   static testMethod void APTPS_CreateAgreementVariationCtrObligationTest(){
        
        //create admin Setting
        Apttus__APTS_Admin__c variationConfig = new Apttus__APTS_Admin__c();
        variationConfig.Name = 'APTS_VariationConfig';
        variationConfig.Apttus__Value__c = 'XML';
        variationConfig.Apttus__Code__c = '<VariationsConfig><ReparentedObjects><ChildObject><Name>APTPS_Related_Companies__c</Name><RelationField>APTPS_Agreement__c</RelationField></ChildObject><ChildObject><Name>Apttus_SRM__Issue__c</Name><RelationField>Apttus_SRM__Agreement__c</RelationField></ChildObject><ChildObject><Name>Fund__c</Name><RelationField>Agreement__c</RelationField></ChildObject></ReparentedObjects><ClonedObjects><ChildObject><Name>Apttus__AgreementLineItem__c</Name><RelationField>Apttus__AgreementId__c</RelationField><GrandChildReparented><Name>APTPS_Minimum_Spend_Entry__c</Name><RelationField>APTPS_Agreement_Line_Item__c</RelationField><ChildRelationship>Minimum_Spend__r</ChildRelationship></GrandChildReparented><GrandChildCloned><Name>APTPS_Component__c</Name><RelationField>Agreement_Line_Item__c</RelationField><ChildRelationship>Components__r</ChildRelationship></GrandChildCloned></ChildObject></ClonedObjects><ClearFields><ClearField><Name>Apttus_Approval__Term_Exception_Approval_Status__c</Name></ClearField><ClearField><Name>APTPS_Pricing_Approval_Needed__c</Name></ClearField><ClearField><Name>Apttus_Approval__Approval_Status__c</Name></ClearField><ClearField><Name>Apttus__Contract_Start_Date__c</Name></ClearField><ClearField><Name>Apttus__Contract_End_Date__c</Name></ClearField><ClearField><Name>Apttus__Term_Months__c</Name></ClearField><ClearField><Name>APTPS_Effective_End_Date__c</Name></ClearField><ClearField><Name>Apttus__Other_Party_Signed_By__c</Name></ClearField><ClearField><Name>Apttus__Other_Party_Signed_Date__c</Name></ClearField><ClearField><Name>Apttus__Company_Signed_By__c</Name></ClearField><ClearField><Name>Apttus__Company_Signed_Date__c</Name></ClearField><ClearField><Name>Apttus__Activated_By__c</Name></ClearField><ClearField><Name>Apttus__Activated_Date__c</Name></ClearField><ClearField><Name>Apttus__Special_Terms__c</Name></ClearField><ClearField><Name>APTPS_Obligations_Copied_After_Variation__c</Name></ClearField></ClearFields></VariationsConfig>';
        insert variationConfig;
        
        //create account
        Account acct = APTPS_TestClassData.accountRecord('Test Account12e2', '3217734598');
        
        //Create Agreement
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        
        
        Apttus_SRM__SRMObligation__c obligationRecord1 = APTPS_TestClassData.obligationRecord(agmt.id, acct.id);
        Apttus_SRM__SRMObligation__c obligationRecord2 = APTPS_TestClassData.obligationRecord(agmt.id, acct.id);
        Profile userProfile = [select Id, Name from profile where Name ='System Administrator'];
        User sysUser = APTPS_TestClassData.userRecord(userProfile.Id, 'test');
        Task taskRecord1 = APTPS_TestClassData.taskRecord(sysUser.Id, obligationRecord2.Id, 'Not Started');
        
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        
        List<Apttus__APTS_Agreement__c> agmtList = [Select id, recordtypeid, recordtype.name from Apttus__APTS_Agreement__c where id =:agmt.id or id=: childAgmt1.id or id=:childAgmt2.id];
       
        agmt.Apttus__Status_Category__c = 'In Effect';
        agmt.Apttus__Status__c = 'Activated';
        agmt.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 1, 11);
        agmt.Apttus__Contract_End_Date__c = Date.newInstance(2016, 5, 11);
        agmt.Apttus__Term_Months__c = 4;
        update agmt;
        
        PageReference pageRef = Page.APTPS_Init_CreateAgreementVariation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        Test.startTest();
        
        APTPS_CreateAgreementVariationController controllertst = new APTPS_CreateAgreementVariationController();
        
        APTPS_CreateAgreementVariationController controller = new APTPS_CreateAgreementVariationController(new ApexPages.standardController(agmt));
        controller.getAgreements();
        controller.createListForAgreementsToBeAmended();
       
        Apttus__APTS_Agreement__c objAgrgmnt = [Select Id, (SELECT id, Apttus__APTS_Contract_From__c FROM R00N50000001Xl0KEAS__r ORDER BY LastModifiedDate Limit 1) FROM Apttus__APTS_Agreement__c Where id=: agmt.Id];
        
        System.assert(objAgrgmnt != null, 'Shishir');
        System.assert(objAgrgmnt.R00N50000001Xl0KEAS__r != null, 'Shishir');
        Apttus__APTS_Related_Agreement__c[] variedRelatedAgreements = objAgrgmnt.R00N50000001Xl0KEAS__r;
        System.debug('Related Agreement ===> '+objAgrgmnt.R00N50000001Xl0KEAS__r);
       /* Apttus__APTS_Related_Agreement__c relAgmt = new Apttus__APTS_Related_Agreement__c(Apttus__APTS_Contract_To__c = agmt.id, name = 'Current Agreement', Apttus__APTS_Contract_From__c = childAgmt3.id);
        insert relAgmt;*/
        
       /* Apttus__APTS_Agreement__c variedAgreement = [select Id, Name, Apttus__Status_Category__c, Apttus__Status__c from Apttus__APTS_Agreement__c
                                                    where Id =: variedRelatedAgreements[0].Apttus__APTS_Contract_From__c];
        
        variedAgreement.Apttus__Status_Category__c = 'In Signatures';
        variedAgreement.Apttus__Status__c = 'Fully Signed';
        update variedAgreement;*/
        Test.StopTest();
    }
}