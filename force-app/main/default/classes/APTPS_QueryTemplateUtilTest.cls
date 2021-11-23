@isTest
private class APTPS_QueryTemplateUtilTest {
    static TestMethod void TestMethod1() {
        //Boolean isQualified = true;
        Apttus__QueryTemplate__c qtc = new Apttus__QueryTemplate__c();
        qtc.Apttus__Active__c = true;
        qtc.Apttus__SObjectLabel__c= 'Agreement Template';
        qtc.Apttus__Type__c = 'Agreement Template Filter';
        qtc.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        qtc.Apttus__Sequence__c = 1;
        insert qtc;
        System.assertEquals('Apttus__APTS_Template__c',qtc.Apttus__SObjectType__c);
        Apttus__QueryTemplateQualifier__c qtcq = new Apttus__QueryTemplateQualifier__c();
        qtcq.Apttus__CompOper__c = 'equal to';
        qtcq.Apttus__Field__c = 'Name';
        qtcq.Apttus__SObjectLabel__c = 'Agreement';
        qtcq.Apttus__QueryTemplate__c = qtc.ID;
        qtcq.Apttus__Sequence__c = 1;
        qtcq.Apttus__SObjectType__c = 'Apttus__APTS_Agreement__c';
        
        insert qtcq;
        
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1233338898');
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id,'SA');
        
        APTPS_QueryTemplateUtil qtu1 = new APTPS_QueryTemplateUtil();
        qtu1.matchExpression('asdas','not equal to', 'sadass');
        qtu1.getTemplateByQueryTemplates(agmt.ID);
        qtu1.getAllTemplatesByQueryTemplates(agmt.ID);
        APTPS_QueryTemplateUtil qtu2 = new APTPS_QueryTemplateUtil();
        qtu2.matchExpression('asdas','less than', 'sadass');
        APTPS_QueryTemplateUtil qtu3 = new APTPS_QueryTemplateUtil();
        qtu3.matchExpression('asdas','less than or equal to', 'sadass');
        APTPS_QueryTemplateUtil qtu4 = new APTPS_QueryTemplateUtil();
        qtu4.matchExpression('asdas','greater than', 'sadass');
        APTPS_QueryTemplateUtil qtu5 = new APTPS_QueryTemplateUtil();
        qtu5.matchExpression('asdas','greater than or equal to', 'sadass');
        APTPS_QueryTemplateUtil qtu6 = new APTPS_QueryTemplateUtil();
        qtu6.matchExpression('asdas','in', 'sadass');
        APTPS_QueryTemplateUtil qtu7 = new APTPS_QueryTemplateUtil();
        qtu7.matchExpression('asdas','not in', 'sadass');
        APTPS_QueryTemplateUtil qtu8 = new APTPS_QueryTemplateUtil();
        qtu8.matchExpression('asdas','like', 'sadass');
        APTPS_QueryTemplateUtil qtu9 = new APTPS_QueryTemplateUtil();
        qtu9.matchExpression('asdas','not like', 'sadass');
        APTPS_QueryTemplateUtil qtu10 = new APTPS_QueryTemplateUtil();
        qtu10.matchExpression('asdas','includes', 'sadass');
        APTPS_QueryTemplateUtil qtu11 = new APTPS_QueryTemplateUtil();
        qtu11.matchExpression('asdas','excludes', 'sadass');
        APTPS_QueryTemplateUtil qtu12 = new APTPS_QueryTemplateUtil();
        qtu12.matchExpression('asdas','starts with', 'sadass');
        APTPS_QueryTemplateUtil qtu13 = new APTPS_QueryTemplateUtil();
        qtu13.matchExpression('asdas','contains', 'sadass');
        APTPS_QueryTemplateUtil qtu14 = new APTPS_QueryTemplateUtil();
        qtu14.matchExpression('asdas','does not contain', 'sadass');
        APTPS_QueryTemplateUtil qtu15 = new APTPS_QueryTemplateUtil();
        qtu15.matchExpression('asdas', null, null);
        APTPS_QueryTemplateUtil qtu156 = new APTPS_QueryTemplateUtil();
        qtu156.matchExpression('asdas', null, 'asdasd');
        
    }
    static TestMethod void TestMethod2() {
        Boolean isQualified = true;
        Apttus__QueryTemplate__c qtc = new Apttus__QueryTemplate__c();
        qtc.Apttus__Active__c = true;
        qtc.Apttus__SObjectLabel__c= 'Agreement Template';
        qtc.Apttus__Type__c = 'Agreement Template Filter';
        qtc.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        qtc.Apttus__Sequence__c = 1;
        insert qtc;
        Apttus__QueryTemplate__c qtc1 = new Apttus__QueryTemplate__c();
        qtc1.Apttus__Active__c = true;
        qtc1.Apttus__SObjectLabel__c= 'Agreement Template1';
        qtc1.Apttus__Type__c = 'Agreement Template Filter';
        qtc1.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        qtc1.Apttus__Sequence__c = 1;
        insert qtc1;
        List<Apttus__QueryTemplate__c> lsttemplate = new List<Apttus__QueryTemplate__c>();
        lsttemplate.add(qtc1);
        update lsttemplate; 
        System.assertEquals('Apttus__APTS_Template__c',qtc1.Apttus__SObjectType__c);
        Apttus__QueryTemplateQualifier__c qtcq = new Apttus__QueryTemplateQualifier__c();
        qtcq.Apttus__CompOper__c = 'equal to';
        qtcq.Apttus__Field__c = 'Name';
        qtcq.Apttus__SObjectLabel__c = 'Agreement';
        qtcq.Apttus__QueryTemplate__c = qtc1.ID;
        qtcq.Apttus__Sequence__c = 1;
        qtcq.Apttus__SObjectType__c = 'Apttus__APTS_Agreement__c';
        
        insert qtcq;
        
        // Boolean isQualified = true;
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1233338898');
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id,'SA');
        
        APTPS_QueryTemplateUtil qtu1 = new APTPS_QueryTemplateUtil();
        qtu1.matchExpression('asdas','not equal to', 'sadass');
        qtu1.getTemplateByQueryTemplates(agmt.ID);
        qtu1.getAllTemplatesByQueryTemplates(agmt.ID);
        APTPS_QueryTemplateUtil qtu2 = new APTPS_QueryTemplateUtil();
        qtu2.matchExpression('asdas','less than', 'sadass');
        APTPS_QueryTemplateUtil qtu3 = new APTPS_QueryTemplateUtil();
        qtu3.matchExpression('asdas','less than or equal to', 'sadass');
        APTPS_QueryTemplateUtil qtu4 = new APTPS_QueryTemplateUtil();
        qtu4.matchExpression('asdas','greater than', 'sadass');
        APTPS_QueryTemplateUtil qtu5 = new APTPS_QueryTemplateUtil();
        qtu5.matchExpression('asdas','greater than or equal to', 'sadass');
        APTPS_QueryTemplateUtil qtu6 = new APTPS_QueryTemplateUtil();
        qtu6.matchExpression('asdas','in', 'sadass');
        APTPS_QueryTemplateUtil qtu7 = new APTPS_QueryTemplateUtil();
        qtu7.matchExpression('asdas','not in', 'sadass');
        APTPS_QueryTemplateUtil qtu8 = new APTPS_QueryTemplateUtil();
        qtu8.matchExpression('asdas','like', 'sadass');
        APTPS_QueryTemplateUtil qtu9 = new APTPS_QueryTemplateUtil();
        qtu9.matchExpression('asdas','not like', 'sadass');
        APTPS_QueryTemplateUtil qtu10 = new APTPS_QueryTemplateUtil();
        qtu10.matchExpression('asdas','includes', 'sadass');
        APTPS_QueryTemplateUtil qtu11 = new APTPS_QueryTemplateUtil();
        qtu11.matchExpression('asdas','excludes', 'sadass');
        APTPS_QueryTemplateUtil qtu12 = new APTPS_QueryTemplateUtil();
        qtu12.matchExpression('asdas','starts with', 'sadass');
        APTPS_QueryTemplateUtil qtu13 = new APTPS_QueryTemplateUtil();
        qtu13.matchExpression('asdas','contains', 'sadass');
        APTPS_QueryTemplateUtil qtu14 = new APTPS_QueryTemplateUtil();
        qtu14.matchExpression('asdas','does not contain', 'sadass');
        APTPS_QueryTemplateUtil qtu15 = new APTPS_QueryTemplateUtil();
        qtu15.matchExpression('asdas', null, null);
        APTPS_QueryTemplateUtil qtu156 = new APTPS_QueryTemplateUtil();
        qtu156.matchExpression('asdas', null, 'asdasd');
        
    }
static TestMethod void TestMethodTRY() {
        Boolean isQualified = true;
        Apttus__QueryTemplate__c qtc = new Apttus__QueryTemplate__c();
        qtc.Apttus__Active__c = true;
        qtc.Apttus__SObjectLabel__c= 'Agreement Template';
        qtc.Apttus__Type__c = 'Agreement Template Filter';
        qtc.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        qtc.Apttus__Sequence__c = 1;
        insert qtc;
        Apttus__QueryTemplate__c qtc1 = new Apttus__QueryTemplate__c();
        qtc1.Apttus__Active__c = true;
        qtc1.Apttus__SObjectLabel__c= 'Agreement Template1';
        qtc1.Apttus__Type__c = 'Agreement Template Filter';
        qtc1.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        qtc1.Apttus__Sequence__c = 1;
        insert qtc1;
        List<Apttus__QueryTemplate__c> lsttemplate = new List<Apttus__QueryTemplate__c>();
        lsttemplate.add(qtc1);
        update lsttemplate; 
        Apttus__QueryTemplateQualifier__c qtcq = new Apttus__QueryTemplateQualifier__c();
        qtcq.Apttus__CompOper__c = 'equal to';
        qtcq.Apttus__Field__c = 'Name';
        qtcq.Apttus__SObjectLabel__c = 'Agreement';
        qtcq.Apttus__QueryTemplate__c = qtc1.ID;
        qtcq.Apttus__Sequence__c = 1;
        qtcq.Apttus__SObjectType__c = 'Apttus__APTS_Agreement__c';
        
        insert qtcq;
         Apttus__APTS_Template__c template1 = new Apttus__APTS_Template__c();
        System.assertEquals('Apttus__APTS_Template__c',qtc.Apttus__SObjectType__c);         
        template1.Name = 'Aptpstemplate';
        template1.Apttus__IsActive__c = true;
        template1.Apttus__Type__c = 'Agreement';
        template1.Apttus__Agreement_Types__c ='Default';
        
         System.assertEquals('Aptpstemplate',template1.Name);
        Insert template1;
        Apttus__QueryTemplate__c Qtemplate = new Apttus__QueryTemplate__c();
        //Qtemplate. ='';
        Qtemplate.Apttus__Active__c = true;
        Qtemplate.Apttus__SObjectLabel__c='Agreement Template';
        Qtemplate.Apttus__Type__c ='Agreement Template Filter';
        Qtemplate.Apttus__Sequence__c =1.0;
    
        Insert Qtemplate;
        
        Apttus__QueryTemplateFilter__c Qtemplatefltr = new Apttus__QueryTemplateFilter__c();
        Qtemplatefltr.Apttus__QueryTemplate__c = Qtemplate.id;
        Qtemplatefltr.Apttus__Field__c ='Apttus__Type__c';
        Qtemplatefltr.Apttus__CompOper__c ='equal to';
        Qtemplatefltr.Apttus__BooOper__c ='AND';
      Qtemplatefltr.Apttus__Value__c='agmt.Apttus__Account__c';
        //Qtemplate.Apttus__SObjectLabel__c = 'Agreement Template'; 
        //Qtemplate.Apttus__Type__c = 'Agreement Template Filter';
        //Qtemplate.Name = 'Testtemplate'; 
        Qtemplatefltr.Apttus__Sequence__c =1.0;
        Insert Qtemplatefltr;
        // Boolean isQualified = true;
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1233338898');
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id,'SA');
        
        APTPS_QueryTemplateUtil qtu1 = new APTPS_QueryTemplateUtil();
        qtu1.matchExpression('asdas','not equal to', 'sadass');
        qtu1.getTemplateByQueryTemplates(agmt.ID);
        qtu1.getAllTemplatesByQueryTemplates(agmt.ID);
        APTPS_QueryTemplateUtil qtu2 = new APTPS_QueryTemplateUtil();
        qtu2.matchExpression('asdas','less than', 'sadass');
        APTPS_QueryTemplateUtil qtu3 = new APTPS_QueryTemplateUtil();
        qtu3.matchExpression('asdas','less than or equal to', 'sadass');
        APTPS_QueryTemplateUtil qtu4 = new APTPS_QueryTemplateUtil();
        qtu4.matchExpression('asdas','greater than', 'sadass');
        APTPS_QueryTemplateUtil qtu5 = new APTPS_QueryTemplateUtil();
        qtu5.matchExpression('asdas','greater than or equal to', 'sadass');
        APTPS_QueryTemplateUtil qtu6 = new APTPS_QueryTemplateUtil();
        qtu6.matchExpression('asdas','in', 'sadass');
        APTPS_QueryTemplateUtil qtu7 = new APTPS_QueryTemplateUtil();
        qtu7.matchExpression('asdas','not in', 'sadass');
        APTPS_QueryTemplateUtil qtu8 = new APTPS_QueryTemplateUtil();
        qtu8.matchExpression('asdas','like', 'sadass');
        APTPS_QueryTemplateUtil qtu9 = new APTPS_QueryTemplateUtil();
        qtu9.matchExpression('asdas','not like', 'sadass');
        APTPS_QueryTemplateUtil qtu10 = new APTPS_QueryTemplateUtil();
        qtu10.matchExpression('asdas','includes', 'sadass');
        APTPS_QueryTemplateUtil qtu11 = new APTPS_QueryTemplateUtil();
        qtu11.matchExpression('asdas','excludes', 'sadass');
        APTPS_QueryTemplateUtil qtu12 = new APTPS_QueryTemplateUtil();
        qtu12.matchExpression('asdas','starts with', 'sadass');
        APTPS_QueryTemplateUtil qtu13 = new APTPS_QueryTemplateUtil();
        qtu13.matchExpression('asdas','contains', 'sadass');
        APTPS_QueryTemplateUtil qtu14 = new APTPS_QueryTemplateUtil();
        qtu14.matchExpression('asdas','does not contain', 'sadass');
        APTPS_QueryTemplateUtil qtu15 = new APTPS_QueryTemplateUtil();
        qtu15.matchExpression('asdas', null, null);
        APTPS_QueryTemplateUtil qtu156 = new APTPS_QueryTemplateUtil();
        qtu156.matchExpression('asdas', null, 'asdasd');
        
    }
    static TestMethod void TestMethodTRY1() {
        Boolean isQualified = true;
        Apttus__QueryTemplate__c qtc = new Apttus__QueryTemplate__c();
        qtc.Apttus__Active__c = true;
        qtc.Apttus__SObjectLabel__c= 'Agreement Template';
        qtc.Apttus__Type__c = 'Agreement Template Filter';
        qtc.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        qtc.Apttus__Sequence__c = 1;
        insert qtc;
        System.assertEquals('Apttus__APTS_Template__c',qtc.Apttus__SObjectType__c);
        Apttus__QueryTemplate__c qtc1 = new Apttus__QueryTemplate__c();
        qtc1.Apttus__Active__c = true;
        qtc1.Apttus__SObjectLabel__c= 'Agreement Template1';
        qtc1.Apttus__Type__c = 'Agreement Template Filter';
        qtc1.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        qtc1.Apttus__Sequence__c = 1;
        insert qtc1;
        List<Apttus__QueryTemplate__c> lsttemplate = new List<Apttus__QueryTemplate__c>();
        lsttemplate.add(qtc1);
        update lsttemplate; 
        Apttus__QueryTemplateQualifier__c qtcq = new Apttus__QueryTemplateQualifier__c();
        qtcq.Apttus__CompOper__c = 'equal to';
        qtcq.Apttus__Field__c = 'Name';
        qtcq.Apttus__SObjectLabel__c = 'Agreement';
        qtcq.Apttus__QueryTemplate__c = qtc1.ID;
        qtcq.Apttus__Sequence__c = 1;
        qtcq.Apttus__SObjectType__c = 'Apttus__APTS_Agreement__c';
        
        insert qtcq;
         Apttus__APTS_Template__c template1 = new Apttus__APTS_Template__c();
                 
        template1.Name = 'Aptpstemplate';
        template1.Apttus__IsActive__c = true;
        template1.Apttus__Type__c = 'Agreement';
        template1.Apttus__Agreement_Types__c ='Default';
        
         
        Insert template1;
        Apttus__QueryTemplate__c Qtemplate = new Apttus__QueryTemplate__c();
        //Qtemplate. ='';
        Qtemplate.Apttus__Active__c = true;
        Qtemplate.Apttus__SObjectLabel__c='Agreement Template';
        Qtemplate.Apttus__Type__c ='Agreement Template Filter';
        Qtemplate.Apttus__Sequence__c =1.0;
    
        Insert Qtemplate;
        
        Apttus__QueryTemplateFilter__c Qtemplatefltr = new Apttus__QueryTemplateFilter__c();
        Qtemplatefltr.Apttus__QueryTemplate__c = Qtemplate.id;
        Qtemplatefltr.Apttus__Field__c ='Apttus__Type__c';
        Qtemplatefltr.Apttus__CompOper__c ='equal to';
        Qtemplatefltr.Apttus__BooOper__c ='OR';
      Qtemplatefltr.Apttus__Value__c='agmt.Apttus__Account__c';
        //Qtemplate.Apttus__SObjectLabel__c = 'Agreement Template'; 
        //Qtemplate.Apttus__Type__c = 'Agreement Template Filter';
        //Qtemplate.Name = 'Testtemplate'; 
        Qtemplatefltr.Apttus__Sequence__c =1.0;
        Insert Qtemplatefltr;
        // Boolean isQualified = true;
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1233338898');
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id,'SA');
        
        APTPS_QueryTemplateUtil qtu1 = new APTPS_QueryTemplateUtil();
        qtu1.matchExpression('asdas','not equal to', 'sadass');
        qtu1.getTemplateByQueryTemplates(agmt.ID);
        qtu1.getAllTemplatesByQueryTemplates(agmt.ID);
        APTPS_QueryTemplateUtil qtu2 = new APTPS_QueryTemplateUtil();
        qtu2.matchExpression('asdas','less than', 'sadass');
        APTPS_QueryTemplateUtil qtu3 = new APTPS_QueryTemplateUtil();
        qtu3.matchExpression('asdas','less than or equal to', 'sadass');
        APTPS_QueryTemplateUtil qtu4 = new APTPS_QueryTemplateUtil();
        qtu4.matchExpression('asdas','greater than', 'sadass');
        APTPS_QueryTemplateUtil qtu5 = new APTPS_QueryTemplateUtil();
        qtu5.matchExpression('asdas','greater than or equal to', 'sadass');
        APTPS_QueryTemplateUtil qtu6 = new APTPS_QueryTemplateUtil();
        qtu6.matchExpression('asdas','in', 'sadass');
        APTPS_QueryTemplateUtil qtu7 = new APTPS_QueryTemplateUtil();
        qtu7.matchExpression('asdas','not in', 'sadass');
        APTPS_QueryTemplateUtil qtu8 = new APTPS_QueryTemplateUtil();
        qtu8.matchExpression('asdas','like', 'sadass');
        APTPS_QueryTemplateUtil qtu9 = new APTPS_QueryTemplateUtil();
        qtu9.matchExpression('asdas','not like', 'sadass');
        APTPS_QueryTemplateUtil qtu10 = new APTPS_QueryTemplateUtil();
        qtu10.matchExpression('asdas','includes', 'sadass');
        APTPS_QueryTemplateUtil qtu11 = new APTPS_QueryTemplateUtil();
        qtu11.matchExpression('asdas','excludes', 'sadass');
        APTPS_QueryTemplateUtil qtu12 = new APTPS_QueryTemplateUtil();
        qtu12.matchExpression('asdas','starts with', 'sadass');
        APTPS_QueryTemplateUtil qtu13 = new APTPS_QueryTemplateUtil();
        qtu13.matchExpression('asdas','contains', 'sadass');
        APTPS_QueryTemplateUtil qtu14 = new APTPS_QueryTemplateUtil();
        qtu14.matchExpression('asdas','does not contain', 'sadass');
        APTPS_QueryTemplateUtil qtu15 = new APTPS_QueryTemplateUtil();
        qtu15.matchExpression('asdas', null, null);
        APTPS_QueryTemplateUtil qtu156 = new APTPS_QueryTemplateUtil();
        qtu156.matchExpression('asdas', null, 'asdasd');
        
    }
}