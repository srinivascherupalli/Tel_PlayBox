/**
 * Created by tihomir.baljak on 9/20/2019.
 */

@IsTest
private class UpdateParentTriggerRtsHandlerTest {

    static testmethod void UpdateParentTriggerRtsHandlerSucess() {
        Test.startTest();
        UpdateParentTriggerRtsHandler handler = new UpdateParentTriggerRtsHandler();
        List<CSPOFA__Orchestration_Step__c> testData = new List<CSPOFA__Orchestration_Step__c>();

        csord__Solution__c solution = new csord__Solution__c();
        solution.csord__Identification__c = '0';
        insert solution;

        cscfga__Product_Configuration__c pdMain = new cscfga__Product_Configuration__c();
        pdMain.Type__c = 'Cancel';
        insert pdMain;
        cscfga__Product_Configuration__c pdChild = new cscfga__Product_Configuration__c();
        insert pdChild;
        cscfga__Product_Configuration__c pdChild1 = new cscfga__Product_Configuration__c();
        insert pdChild1;

        cscfga__Attribute__c attributeMain = new cscfga__Attribute__c();
        attributeMain.cscfga__Product_Configuration__c = pdMain.id;
        attributeMain.Name = 'isMainComponent';
        attributeMain.cscfga__Value__c = 'Yes';
        insert attributeMain;


        csord__Subscription__c subsMain = new csord__Subscription__c();
        subsMain.Trigger_RTS__c = false;
        subsMain.cssdm__solution_association__c = solution.id;
       // subsMain.toBeCancelled__c = 'true'; //calculation from PD
        subsMain.csordtelcoa__Product_Configuration__c = pdMain.id;
        subsMain.csord__Identification__c = '1';
        insert subsMain;

        csord__Subscription__c subsChild = new csord__Subscription__c();
        subsChild.Trigger_RTS__c = true;
        subsChild.cssdm__solution_association__c = solution.id;
        subsChild.csordtelcoa__Product_Configuration__c = pdChild.id;
        subsChild.csord__Identification__c = '2';
        insert subsChild;

        csord__Subscription__c subsChild1 = new csord__Subscription__c();
        subsChild1.Trigger_RTS__c = true;
        subsChild1.cssdm__solution_association__c = solution.id;
        subsChild1.csordtelcoa__Product_Configuration__c = pdChild1.id;
        subsChild1.csord__Identification__c = '3';
        insert subsChild1;


        CSPOFA__Orchestration_Process_Template__c ot = new CSPOFA__Orchestration_Process_Template__c();
        insert ot;

        CSPOFA__Orchestration_Process__c process  = new CSPOFA__Orchestration_Process__c();
        process.csordtelcoa__Subscription__c = subsChild.id;
        process.CSPOFA__Orchestration_Process_Template__c = ot.id;
        insert process;

        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.CSPOFA__Orchestration_Process__c = process.id;
        testData.add(step);
        insert step;

        List<sObject> res = handler.process(testData);

        List<csord__Subscription__c> mainRecord=[Select id,  Trigger_RTS__c from csord__Subscription__c where Id=:subsMain.id];
        Test.stopTest();
        List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>) res;

        for (CSPOFA__Orchestration_Step__c step1 : stepList) {
            System.assertEquals(step1.CSPOFA__Status__c, Constants.orchestrationProcessComplete);
        }

        System.assertNotEquals(NULL, mainRecord);
        System.assertEquals(1, mainRecord.size());
        System.assertEquals(true , mainRecord[0].Trigger_RTS__c);
    }

    static testmethod void UpdateParentTriggerRtsHandlerFail1() {
        Test.startTest();
        UpdateParentTriggerRtsHandler handler = new UpdateParentTriggerRtsHandler();
        List<CSPOFA__Orchestration_Step__c> testData = new List<CSPOFA__Orchestration_Step__c>();

        csord__Solution__c solution = new csord__Solution__c();
        solution.csord__Identification__c = '0';
        insert solution;

        csord__Solution__c solution1 = new csord__Solution__c();
        solution1.csord__Identification__c = '0';
        insert solution1;

        cscfga__Product_Configuration__c pdMain = new cscfga__Product_Configuration__c();
        pdMain.Type__c = 'Cancel';
        insert pdMain;
        cscfga__Product_Configuration__c pdChild = new cscfga__Product_Configuration__c();
        insert pdChild;
        cscfga__Product_Configuration__c pdChild1 = new cscfga__Product_Configuration__c();
        insert pdChild1;

        cscfga__Attribute__c attributeMain = new cscfga__Attribute__c();
        attributeMain.cscfga__Product_Configuration__c = pdMain.id;
        attributeMain.Name = 'isMainComponent';
        attributeMain.cscfga__Value__c = 'Yes';
        insert attributeMain;


        csord__Subscription__c subsMain = new csord__Subscription__c();
        subsMain.Trigger_RTS__c = false;
        subsMain.cssdm__solution_association__c = solution1.id;
        // subsMain.toBeCancelled__c = 'true'; //calculation from PD
        subsMain.csordtelcoa__Product_Configuration__c = pdMain.id;
        subsMain.csord__Identification__c = '1';
        insert subsMain;

        csord__Subscription__c subsChild = new csord__Subscription__c();
        subsChild.Trigger_RTS__c = true;
        subsChild.cssdm__solution_association__c = solution.id;
        subsChild.csordtelcoa__Product_Configuration__c = pdChild.id;
        subsChild.csord__Identification__c = '2';
        insert subsChild;

        csord__Subscription__c subsChild1 = new csord__Subscription__c();
        subsChild1.Trigger_RTS__c = true;
        subsChild1.cssdm__solution_association__c = solution.id;
        subsChild1.csordtelcoa__Product_Configuration__c = pdChild1.id;
        subsChild1.csord__Identification__c = '3';
        insert subsChild1;


        CSPOFA__Orchestration_Process_Template__c ot = new CSPOFA__Orchestration_Process_Template__c();
        insert ot;

        CSPOFA__Orchestration_Process__c process  = new CSPOFA__Orchestration_Process__c();
        process.csordtelcoa__Subscription__c = subsChild.id;
        process.CSPOFA__Orchestration_Process_Template__c = ot.id;
        insert process;

        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.CSPOFA__Orchestration_Process__c = process.id;
        testData.add(step);
        insert step;

        List<sObject> res = handler.process(testData);

        List<csord__Subscription__c> mainRecord=[Select id,  Trigger_RTS__c from csord__Subscription__c where Id=:subsMain.id];
        Test.stopTest();
        List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>) res;

        for (CSPOFA__Orchestration_Step__c step1 : stepList) {
            System.assertEquals(step1.CSPOFA__Status__c, Constants.orchestrationProcessComplete);
        }

        System.assertNotEquals(NULL, mainRecord);
        System.assertEquals(1, mainRecord.size());
        System.assertEquals(false , mainRecord[0].Trigger_RTS__c);
    }

    static testmethod void UpdateParentTriggerRtsHandlerFail2() {
        Test.startTest();
        UpdateParentTriggerRtsHandler handler = new UpdateParentTriggerRtsHandler();
        List<CSPOFA__Orchestration_Step__c> testData = new List<CSPOFA__Orchestration_Step__c>();

        csord__Solution__c solution = new csord__Solution__c();
        solution.csord__Identification__c = '0';
        insert solution;

        cscfga__Product_Configuration__c pdMain = new cscfga__Product_Configuration__c();
        pdMain.Type__c = 'Cancel';
        insert pdMain;
        cscfga__Product_Configuration__c pdChild = new cscfga__Product_Configuration__c();
        insert pdChild;
        cscfga__Product_Configuration__c pdChild1 = new cscfga__Product_Configuration__c();
        insert pdChild1;

        cscfga__Attribute__c attributeMain = new cscfga__Attribute__c();
        attributeMain.cscfga__Product_Configuration__c = pdMain.id;
        attributeMain.Name = 'isMainComponent';
        attributeMain.cscfga__Value__c = 'No';
        insert attributeMain;


        csord__Subscription__c subsMain = new csord__Subscription__c();
        subsMain.Trigger_RTS__c = false;
        subsMain.cssdm__solution_association__c = solution.id;
        // subsMain.toBeCancelled__c = 'true'; //calculation from PD
        subsMain.csordtelcoa__Product_Configuration__c = pdMain.id;
        subsMain.csord__Identification__c = '1';
        insert subsMain;

        csord__Subscription__c subsChild = new csord__Subscription__c();
        subsChild.Trigger_RTS__c = true;
        subsChild.cssdm__solution_association__c = solution.id;
        subsChild.csordtelcoa__Product_Configuration__c = pdChild.id;
        subsChild.csord__Identification__c = '2';
        insert subsChild;

        csord__Subscription__c subsChild1 = new csord__Subscription__c();
        subsChild1.Trigger_RTS__c = true;
        subsChild1.cssdm__solution_association__c = solution.id;
        subsChild1.csordtelcoa__Product_Configuration__c = pdChild1.id;
        subsChild1.csord__Identification__c = '3';
        insert subsChild1;


        CSPOFA__Orchestration_Process_Template__c ot = new CSPOFA__Orchestration_Process_Template__c();
        insert ot;

        CSPOFA__Orchestration_Process__c process  = new CSPOFA__Orchestration_Process__c();
        process.csordtelcoa__Subscription__c = subsChild.id;
        process.CSPOFA__Orchestration_Process_Template__c = ot.id;
        insert process;

        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.CSPOFA__Orchestration_Process__c = process.id;
        testData.add(step);
        insert step;

        List<sObject> res = handler.process(testData);

        List<csord__Subscription__c> mainRecord=[Select id,  Trigger_RTS__c from csord__Subscription__c where Id=:subsMain.id];
        Test.stopTest();
        List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>) res;

        for (CSPOFA__Orchestration_Step__c step1 : stepList) {
            System.assertEquals(step1.CSPOFA__Status__c, Constants.orchestrationProcessComplete);
        }

        System.assertNotEquals(NULL, mainRecord);
        System.assertEquals(1, mainRecord.size());
        System.assertEquals(false , mainRecord[0].Trigger_RTS__c);
    }

    static testmethod void UpdateParentTriggerRtsHandlerFail3() {
        Test.startTest();
        UpdateParentTriggerRtsHandler handler = new UpdateParentTriggerRtsHandler();
        List<CSPOFA__Orchestration_Step__c> testData = new List<CSPOFA__Orchestration_Step__c>();

        csord__Solution__c solution = new csord__Solution__c();
        solution.csord__Identification__c = '0';
        insert solution;

        cscfga__Product_Configuration__c pdMain = new cscfga__Product_Configuration__c();
        pdMain.Type__c = 'Modify';
        insert pdMain;
        cscfga__Product_Configuration__c pdChild = new cscfga__Product_Configuration__c();
        insert pdChild;
        cscfga__Product_Configuration__c pdChild1 = new cscfga__Product_Configuration__c();
        insert pdChild1;

        cscfga__Attribute__c attributeMain = new cscfga__Attribute__c();
        attributeMain.cscfga__Product_Configuration__c = pdMain.id;
        attributeMain.Name = 'isMainComponent';
        attributeMain.cscfga__Value__c = 'Yes';
        insert attributeMain;


        csord__Subscription__c subsMain = new csord__Subscription__c();
        subsMain.Trigger_RTS__c = false;
        subsMain.cssdm__solution_association__c = solution.id;
        // subsMain.toBeCancelled__c = 'true'; //calculation from PD
        subsMain.csordtelcoa__Product_Configuration__c = pdMain.id;
        subsMain.csord__Identification__c = '1';
        insert subsMain;

        csord__Subscription__c subsChild = new csord__Subscription__c();
        subsChild.Trigger_RTS__c = true;
        subsChild.cssdm__solution_association__c = solution.id;
        subsChild.csordtelcoa__Product_Configuration__c = pdChild.id;
        subsChild.csord__Identification__c = '2';
        insert subsChild;

        csord__Subscription__c subsChild1 = new csord__Subscription__c();
        subsChild1.Trigger_RTS__c = true;
        subsChild1.cssdm__solution_association__c = solution.id;
        subsChild1.csordtelcoa__Product_Configuration__c = pdChild1.id;
        subsChild1.csord__Identification__c = '3';
        insert subsChild1;


        CSPOFA__Orchestration_Process_Template__c ot = new CSPOFA__Orchestration_Process_Template__c();
        insert ot;

        CSPOFA__Orchestration_Process__c process  = new CSPOFA__Orchestration_Process__c();
        process.csordtelcoa__Subscription__c = subsChild.id;
        process.CSPOFA__Orchestration_Process_Template__c = ot.id;
        insert process;

        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.CSPOFA__Orchestration_Process__c = process.id;
        testData.add(step);
        insert step;

        List<sObject> res = handler.process(testData);

        List<csord__Subscription__c> mainRecord=[Select id,  Trigger_RTS__c from csord__Subscription__c where Id=:subsMain.id];
        Test.stopTest();
        List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>) res;

        for (CSPOFA__Orchestration_Step__c step1 : stepList) {
            System.assertEquals(step1.CSPOFA__Status__c, Constants.orchestrationProcessComplete);
        }

        System.assertNotEquals(NULL, mainRecord);
        System.assertEquals(1, mainRecord.size());
        System.assertEquals(false , mainRecord[0].Trigger_RTS__c);
    }

    static testmethod void UpdateParentTriggerRtsHandlerFail4() {
        Test.startTest();
        UpdateParentTriggerRtsHandler handler = new UpdateParentTriggerRtsHandler();
        List<CSPOFA__Orchestration_Step__c> testData = new List<CSPOFA__Orchestration_Step__c>();

        csord__Solution__c solution = new csord__Solution__c();
        solution.csord__Identification__c = '0';
        insert solution;

        cscfga__Product_Configuration__c pdMain = new cscfga__Product_Configuration__c();
        pdMain.Type__c = 'Cancel';
        insert pdMain;
        cscfga__Product_Configuration__c pdChild = new cscfga__Product_Configuration__c();
        insert pdChild;
        cscfga__Product_Configuration__c pdChild1 = new cscfga__Product_Configuration__c();
        insert pdChild1;

        cscfga__Attribute__c attributeMain = new cscfga__Attribute__c();
        attributeMain.cscfga__Product_Configuration__c = pdMain.id;
        attributeMain.Name = 'isMainComponent';
        attributeMain.cscfga__Value__c = 'Yes';
        insert attributeMain;


        csord__Subscription__c subsMain = new csord__Subscription__c();
        subsMain.Trigger_RTS__c = false;
        subsMain.cssdm__solution_association__c = solution.id;
        // subsMain.toBeCancelled__c = 'true'; //calculation from PD
        subsMain.csordtelcoa__Product_Configuration__c = pdMain.id;
        subsMain.csord__Identification__c = '1';
        insert subsMain;

        csord__Subscription__c subsChild = new csord__Subscription__c();
        subsChild.Trigger_RTS__c = true;
        subsChild.cssdm__solution_association__c = solution.id;
        subsChild.csordtelcoa__Product_Configuration__c = pdChild.id;
        subsChild.csord__Identification__c = '2';
        insert subsChild;

        csord__Subscription__c subsChild1 = new csord__Subscription__c();
        subsChild1.Trigger_RTS__c = false;
        subsChild1.cssdm__solution_association__c = solution.id;
        subsChild1.csordtelcoa__Product_Configuration__c = pdChild1.id;
        subsChild1.csord__Identification__c = '3';
        insert subsChild1;


        CSPOFA__Orchestration_Process_Template__c ot = new CSPOFA__Orchestration_Process_Template__c();
        insert ot;

        CSPOFA__Orchestration_Process__c process  = new CSPOFA__Orchestration_Process__c();
        process.csordtelcoa__Subscription__c = subsChild.id;
        process.CSPOFA__Orchestration_Process_Template__c = ot.id;
        insert process;

        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.CSPOFA__Orchestration_Process__c = process.id;
        testData.add(step);
        insert step;

        List<sObject> res = handler.process(testData);

        List<csord__Subscription__c> mainRecord=[Select id,  Trigger_RTS__c from csord__Subscription__c where Id=:subsMain.id];
        Test.stopTest();
        List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>) res;

        for (CSPOFA__Orchestration_Step__c step1 : stepList) {
            System.assertEquals(step1.CSPOFA__Status__c, Constants.orchestrationProcessComplete);
        }

        System.assertNotEquals(NULL, mainRecord);
        System.assertEquals(1, mainRecord.size());
        System.assertEquals(false , mainRecord[0].Trigger_RTS__c);
    }
}