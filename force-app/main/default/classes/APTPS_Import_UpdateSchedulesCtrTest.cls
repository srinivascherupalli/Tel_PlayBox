/*****************************************************************
@Name: APTPS_Import_UpdateSchedulesCtrTest
@Author: Ruchika Patil 
@CreateDate: 20/06/2016 
@Description: This class is the Test class for APTPS_Import_UpdateSchedulesController
@UsedBy: APTPS_Import_UpdateSchedulesController
******************************************************************/ 
@IsTest
public with sharing class APTPS_Import_UpdateSchedulesCtrTest{
    /******************************************************************
    @Description:This method created a single Account record.
    *******************************************************************/ 
   static testMethod void APTPS_Import_UpdateSchedulesController(){
       string csvAsString;
    String[] csvFileLines;
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordTypeAndSubtype(acct.id, 'Schedule', 'Carriage', 'Fixed Voice', 
                                                                                                  'Fixed Voice Service Schedule');
       
        childAgmt1.Apttus__Parent_Agreement__c = agmt.id;
        update childAgmt1;
       List<APTPS_Agreement_Pricing_Data_Map__c> dataMaps = new List<APTPS_Agreement_Pricing_Data_Map__c>();
       APTPS_Agreement_Pricing_Data_Map__c dataMap = null;
       string[] csvRecordData = null;
       List<StaticResource> csvResource1 = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_AgreeementPricingDataMap'];
       
       Product2 prod1 = APTPS_TestClassData.productRecord('Business IP');
       Product2 prod2 = APTPS_TestClassData.productRecord('Wireless M2M Control Centre');
       
       Apttus__AgreementLineItem__c agreementLineItem = APTPS_TestClassData.agreementLineItemRecord(childAgmt1.Id, prod1.Id);
       
       APTPS_Component__c component1 = new APTPS_Component__c();
       component1.Agreement_Line_Item__c = agreementLineItem.Id;
       component1.APTPS_Attribute__c = 'Test Attribute';
       component1.Value__c = '10';
       
       insert component1;
       
       APTPS_Component__c component2 = new APTPS_Component__c();
       component2.Agreement_Line_Item__c = agreementLineItem.Id;
       component2.APTPS_Attribute__c = 'Test Attribute1';
       component2.Value__c = '11';
        insert component2;
       
       Fund__c fund1 = APTPS_TestClassData.fundRecord(agmt.id, 'Growth');
       Fund__c fund2 = APTPS_TestClassData.fundRecord(agmt.id, 'MBRS');
       Fund__c fund3 = APTPS_TestClassData.fundRecord(agmt.id, 'MOTIF');
       Fund__c fund4 = APTPS_TestClassData.fundRecord(agmt.id, 'Other');
       Fund__c fund5 = APTPS_TestClassData.fundRecord(agmt.id, 'TIF');
       
       Fund_Product__c fundProd1 = APTPS_TestClassData.fundProductRecord(fund1.id,prod1.id);
       Fund_Product__c fundProd2 = APTPS_TestClassData.fundProductRecord(fund2.id,prod1.id);
       Fund_Product__c fundProd3 = APTPS_TestClassData.fundProductRecord(fund3.id,prod1.id);
       Fund_Product__c fundProd4 = APTPS_TestClassData.fundProductRecord(fund4.id,prod1.id);
       Fund_Product__c fundProd5 = APTPS_TestClassData.fundProductRecord(fund5.id,prod1.id); 
       
       if(csvResource1.size() == 1)
       {
           Blob csvFileBody = csvResource1[0].body;
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
           
           for(Integer i = 1;i < csvFileLines.size();i++)
           {
               csvRecordData = csvFileLines[i].split(',', -1);

               dataMap = new APTPS_Agreement_Pricing_Data_Map__c();
               dataMap.APTPS_Tag_Type__c = csvRecordData[0];
               dataMap.APTPS_Product_Family__c = csvRecordData[1];
               dataMap.Related_Service_Schedule__c = csvRecordData[2];
               if(csvRecordData[3] != '')
               {
                   if(prod1.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod1.Id;
                   }
                   
                   if(prod2.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod2.Id;
                   }
                   
               }
               
               dataMap.Tag__c = csvRecordData[4];
               dataMap.APTPS_Translates_To_Field__c = csvRecordData[5];
               dataMap.Field_Type__c = csvRecordData[6];
               dataMap.APTPS_Fund_Type__c = csvRecordData[7];
               dataMap.APTPS_Field_Name__c = csvRecordData[8];
               dataMap.Object_Name__c = csvRecordData[9];   
               
               dataMaps.add(dataMap);
               
           }
           
           insert dataMaps;
       }
   
        PageReference pageRef = Page.APTPS_Init_ImportUpdateSchedules;
       
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
       
       Apttus__ComplySystemProperties__c sysProperties = new Apttus__ComplySystemProperties__c();
       sysProperties.Name = 'System Properties';
       sysProperties.APTPS_CALMs_Support_Email_Address__c = 'dummy@test.com';
       insert sysProperties;
        Test.startTest();
       
         
       
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_Import_UpdateSchedulesController controller = new APTPS_Import_UpdateSchedulesController();
        controller = new APTPS_Import_UpdateSchedulesController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.Id);
        system.assertEquals(agmt.name, controller.agreementName);
        
      List<StaticResource> csvResource = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportScheduleTestCSV'];
       
    
        system.assertEquals(1, csvResource.size());  
       
       
        //Normal scenario
                      
        //Checking if the result is returned or not
        if(csvResource.size() == 1)
        {
            controller.csvFileBody = csvResource[0].body;   
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
       
       
        PageReference cancelPageRef = controller.cancel();        
        system.assertEquals('/'+controller.parentAgreement.Id, cancelPageRef.getUrl());
        
       
        Test.stopTest();
    }
    
    
    static testMethod void APTPS_Import_UpdateSchedulesWarning(){
       string csvAsString;
    String[] csvFileLines;
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordTypeAndSubtype(acct.id, 'Schedule', 'Carriage', 'Fixed Voice', 
                                                                                                  'Fixed Voice Service Schedule');
       
        childAgmt1.Apttus__Parent_Agreement__c = agmt.id;
        update childAgmt1;
       List<APTPS_Agreement_Pricing_Data_Map__c> dataMaps = new List<APTPS_Agreement_Pricing_Data_Map__c>();
       APTPS_Agreement_Pricing_Data_Map__c dataMap = null;
       string[] csvRecordData = null;
       List<StaticResource> csvResource1 = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_AgreeementPricingDataMap'];
       
       Product2 prod1 = APTPS_TestClassData.productRecord('Business IP');
       Product2 prod2 = APTPS_TestClassData.productRecord('Wireless M2M Control Centre');
       
       if(csvResource1.size() == 1)
       {
           Blob csvFileBody = csvResource1[0].body;
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
           
           for(Integer i = 1;i < csvFileLines.size();i++)
           {
               csvRecordData = csvFileLines[i].split(',', -1);

               dataMap = new APTPS_Agreement_Pricing_Data_Map__c();
               dataMap.APTPS_Tag_Type__c = csvRecordData[0];
               dataMap.APTPS_Product_Family__c = csvRecordData[1];
               dataMap.Related_Service_Schedule__c = csvRecordData[2];
               if(csvRecordData[3] != '')
               {
                   if(prod1.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod1.Id;
                   }
                   
                   if(prod2.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod2.Id;
                   }
                   
               }
               
               dataMap.Tag__c = csvRecordData[4];
               dataMap.APTPS_Translates_To_Field__c = csvRecordData[5];
               dataMap.Field_Type__c = csvRecordData[6];
               dataMap.APTPS_Fund_Type__c = csvRecordData[7];
               dataMap.APTPS_Field_Name__c = csvRecordData[8];
               dataMap.Object_Name__c = csvRecordData[9];   
               
               dataMaps.add(dataMap);
               
           }
           
           		dataMap = new APTPS_Agreement_Pricing_Data_Map__c();
               dataMap.APTPS_Tag_Type__c = 'Schedule';
               dataMap.APTPS_Product_Family__c = 'Data and IP';
               dataMap.Related_Service_Schedule__c = 'Data Services';
               
               dataMap.Tag__c = 'BIP_F80_IPH_EONBN_Z5Z6_Rental';
               dataMap.APTPS_Translates_To_Field__c = 'Anything';
               dataMap.Field_Type__c = 'Decimal';
              
               
               dataMaps.add(dataMap);
           
           insert dataMaps;
       }
       
       
        PageReference pageRef = Page.APTPS_Init_ImportUpdateSchedules;
       
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
       
       Apttus__ComplySystemProperties__c sysProperties = new Apttus__ComplySystemProperties__c();
       sysProperties.Name = 'System Properties';
       sysProperties.APTPS_CALMs_Support_Email_Address__c = 'dummy@test.com';
       insert sysProperties;
        Test.startTest();
       
         
       
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_Import_UpdateSchedulesController controller = new APTPS_Import_UpdateSchedulesController();
        controller = new APTPS_Import_UpdateSchedulesController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.Id);
        system.assertEquals(agmt.name, controller.agreementName);
        
       //Checking Only Warning
       List<StaticResource> csvResource = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportScheduleTestCSVWarning'];
       system.assertEquals(1, csvResource.size());   
        if(csvResource.size() == 1)
        {
            controller.csvFileBody = csvResource[0].body;   
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
        
       
        PageReference cancelPageRef = controller.cancel();        
        system.assertEquals('/'+controller.parentAgreement.Id, cancelPageRef.getUrl());
        
     
        Test.stopTest();
    }
    
    
    static testMethod void APTPS_Import_UpdateSchedulesInvalidCIDN(){
        
       string csvAsString;
       String[] csvFileLines;
       Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
       Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
       List<APTPS_Agreement_Pricing_Data_Map__c> dataMaps = new List<APTPS_Agreement_Pricing_Data_Map__c>();
       APTPS_Agreement_Pricing_Data_Map__c dataMap = null;
       string[] csvRecordData = null;
       List<StaticResource> csvResource1 = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_AgreeementPricingDataMap'];
       Product2 prod1 = APTPS_TestClassData.productRecord('Business IP');
       Product2 prod2 = APTPS_TestClassData.productRecord('Wireless M2M Control Centre');
        
       if(csvResource1.size() == 1)
       {
           Blob csvFileBody = csvResource1[0].body;
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
           
           for(Integer i = 1;i < csvFileLines.size();i++)
           {
               csvRecordData = csvFileLines[i].split(',', -1);

               dataMap = new APTPS_Agreement_Pricing_Data_Map__c();
               dataMap.APTPS_Tag_Type__c = csvRecordData[0];
               dataMap.APTPS_Product_Family__c = csvRecordData[1];
               dataMap.Related_Service_Schedule__c = csvRecordData[2];
               if(csvRecordData[3] != '')
               {
                   if(prod1.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod1.Id;
                   }
                   
                   if(prod2.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod2.Id;
                   }
                   
               }
               
               dataMap.Tag__c = csvRecordData[4];
               dataMap.APTPS_Translates_To_Field__c = csvRecordData[5];
               dataMap.Field_Type__c = csvRecordData[6];
               dataMap.APTPS_Fund_Type__c = csvRecordData[7];
               dataMap.APTPS_Field_Name__c = csvRecordData[8];
               dataMap.Object_Name__c = csvRecordData[9];   
               
               dataMaps.add(dataMap);
               
           }
           
           insert dataMaps;
       }
       
       
       
        PageReference pageRef = Page.APTPS_Init_ImportUpdateSchedules;
       
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
       
     
        Test.startTest();
       
         
       
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_Import_UpdateSchedulesController controller = new APTPS_Import_UpdateSchedulesController();
        controller = new APTPS_Import_UpdateSchedulesController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.Id);
        system.assertEquals(agmt.name, controller.agreementName);
       
       
        List<StaticResource> csvResource = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportScheduleTestCSVInvalidCIDN'];
       
      
        system.assertEquals(1, csvResource.size());  
       
                      
        //Checking if the result is returned or not
        if(csvResource.size() == 1)
        {
            controller.csvFileBody = csvResource[0].body;   
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();        
       
       
       
        PageReference cancelPageRef = controller.cancel();        
        system.assertEquals('/'+controller.parentAgreement.Id, cancelPageRef.getUrl());
        
      
        Test.stopTest();
    }
    
    
    static testMethod void APTPS_Import_UpdateSchedulesInvalidField(){
       string csvAsString;
    String[] csvFileLines;
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordTypeAndSubtype(acct.id, 'Schedule', 'Carriage', 'Fixed Voice', 
                                                                                                  'Fixed Voice Service Schedule');
       
        childAgmt1.Apttus__Parent_Agreement__c = agmt.id;
        update childAgmt1;
       List<APTPS_Agreement_Pricing_Data_Map__c> dataMaps = new List<APTPS_Agreement_Pricing_Data_Map__c>();
       APTPS_Agreement_Pricing_Data_Map__c dataMap = null;
       string[] csvRecordData = null;
       List<StaticResource> csvResource1 = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_AgreeementPricingDataMap'];
       
       Product2 prod1 = APTPS_TestClassData.productRecord('Business IP');
       Product2 prod2 = APTPS_TestClassData.productRecord('Wireless M2M Control Centre');
       
      
       if(csvResource1.size() == 1)
       {
           Blob csvFileBody = csvResource1[0].body;
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
           
           for(Integer i = 1;i < csvFileLines.size();i++)
           {
               csvRecordData = csvFileLines[i].split(',', -1);

               dataMap = new APTPS_Agreement_Pricing_Data_Map__c();
               dataMap.APTPS_Tag_Type__c = csvRecordData[0];
               dataMap.APTPS_Product_Family__c = csvRecordData[1];
               dataMap.Related_Service_Schedule__c = csvRecordData[2];
               if(csvRecordData[3] != '')
               {
                   if(prod1.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod1.Id;
                   }
                   
                   if(prod2.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod2.Id;
                   }
                   
               }
               
               dataMap.Tag__c = csvRecordData[4];
               dataMap.APTPS_Translates_To_Field__c = csvRecordData[5];
               dataMap.Field_Type__c = csvRecordData[6];
               dataMap.APTPS_Fund_Type__c = csvRecordData[7];
               dataMap.APTPS_Field_Name__c = csvRecordData[8];
               dataMap.Object_Name__c = csvRecordData[9];   
               
               dataMaps.add(dataMap);
               
           }
           
           insert dataMaps;
       }
        
        
        PageReference pageRef = Page.APTPS_Init_ImportUpdateSchedules;
       
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
       
       Apttus__ComplySystemProperties__c sysProperties = new Apttus__ComplySystemProperties__c();
       sysProperties.Name = 'System Properties';
       sysProperties.APTPS_CALMs_Support_Email_Address__c = 'dummy@test.com';
       insert sysProperties;
        Test.startTest();
       
         
       
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_Import_UpdateSchedulesController controller = new APTPS_Import_UpdateSchedulesController();
        controller = new APTPS_Import_UpdateSchedulesController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.Id);
        system.assertEquals(agmt.name, controller.agreementName);
        
      
       //Checking Invalid FieldTYpe
       List<StaticResource> csvResource = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportScheduleTestCSVInvalidFieldType'];
       system.assertEquals(1, csvResource.size());   
        if(csvResource.size() == 1)
        {
            controller.csvFileBody = csvResource[0].body;   
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
       
        Test.stopTest();
    }
    
     static testMethod void APTPS_Import_UpdateSchedulesControllerNullPricingMap(){
       string csvAsString;
    String[] csvFileLines;
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordTypeAndSubtype(acct.id, 'Schedule', 'Carriage', 'Fixed Voice', 
                                                                                                  'Fixed Voice Service Schedule');
       
        childAgmt1.Apttus__Parent_Agreement__c = agmt.id;
        update childAgmt1;
       List<APTPS_Agreement_Pricing_Data_Map__c> dataMaps = new List<APTPS_Agreement_Pricing_Data_Map__c>();
       APTPS_Agreement_Pricing_Data_Map__c dataMap = null;
       string[] csvRecordData = null;
       List<StaticResource> csvResource1 = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_AgreeementPricingDataMap'];
       
       Product2 prod1 = APTPS_TestClassData.productRecord('Business IP');
       Product2 prod2 = APTPS_TestClassData.productRecord('Wireless M2M Control Centre');
       
       Apttus__AgreementLineItem__c agreementLineItem = APTPS_TestClassData.agreementLineItemRecord(childAgmt1.Id, prod1.Id);
       
       APTPS_Component__c component1 = new APTPS_Component__c();
       component1.Agreement_Line_Item__c = agreementLineItem.Id;
       component1.APTPS_Attribute__c = 'Test Attribute';
       component1.Value__c = '10';
       
       insert component1;
       
       APTPS_Component__c component2 = new APTPS_Component__c();
       component2.Agreement_Line_Item__c = agreementLineItem.Id;
       component2.APTPS_Attribute__c = 'Test Attribute1';
       component2.Value__c = '11';
        insert component2;
       
       Fund__c fund1 = APTPS_TestClassData.fundRecord(agmt.id, 'Growth');
       Fund__c fund2 = APTPS_TestClassData.fundRecord(agmt.id, 'MBRS');
       Fund__c fund3 = APTPS_TestClassData.fundRecord(agmt.id, 'MOTIF');
       Fund__c fund4 = APTPS_TestClassData.fundRecord(agmt.id, 'Other');
       Fund__c fund5 = APTPS_TestClassData.fundRecord(agmt.id, 'TIF');
       
       Fund_Product__c fundProd1 = APTPS_TestClassData.fundProductRecord(fund1.id,prod1.id);
       Fund_Product__c fundProd2 = APTPS_TestClassData.fundProductRecord(fund2.id,prod1.id);
       Fund_Product__c fundProd3 = APTPS_TestClassData.fundProductRecord(fund3.id,prod1.id);
       Fund_Product__c fundProd4 = APTPS_TestClassData.fundProductRecord(fund4.id,prod1.id);
       Fund_Product__c fundProd5 = APTPS_TestClassData.fundProductRecord(fund5.id,prod1.id); 
       
       if(csvResource1.size() == 1)
       {
           Blob csvFileBody = csvResource1[0].body;
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
           
           for(Integer i = 1;i < csvFileLines.size();i++)
           {
               csvRecordData = csvFileLines[i].split(',', -1);

               dataMap = new APTPS_Agreement_Pricing_Data_Map__c();
               dataMap.APTPS_Tag_Type__c = csvRecordData[0];
               dataMap.APTPS_Product_Family__c = csvRecordData[1];
               dataMap.Related_Service_Schedule__c = csvRecordData[2];
               if(csvRecordData[3] != '')
               {
                   if(prod1.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod1.Id;
                   }
                   
                   if(prod2.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod2.Id;
                   }
                   
               }
               
               dataMap.Tag__c = csvRecordData[4];
               dataMap.APTPS_Translates_To_Field__c = csvRecordData[5];
               dataMap.Field_Type__c = csvRecordData[6];
               dataMap.APTPS_Fund_Type__c = csvRecordData[7];
               dataMap.APTPS_Field_Name__c = csvRecordData[8];
               dataMap.Object_Name__c = csvRecordData[9];   
               
               dataMaps.add(dataMap);
               
           }
           
           insert dataMaps;
       }
   
        PageReference pageRef = Page.APTPS_Init_ImportUpdateSchedules;
       
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
       
       Apttus__ComplySystemProperties__c sysProperties = new Apttus__ComplySystemProperties__c();
       sysProperties.Name = 'System Properties';
       sysProperties.APTPS_CALMs_Support_Email_Address__c = 'dummy@test.com';
       insert sysProperties;
        Test.startTest();
       
         
       
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_Import_UpdateSchedulesController controller = new APTPS_Import_UpdateSchedulesController();
        controller = new APTPS_Import_UpdateSchedulesController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.Id);
        system.assertEquals(agmt.name, controller.agreementName);
        
      List<StaticResource> csvResource = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportScheduleTestCSV'];
       
    
        system.assertEquals(1, csvResource.size());  
       
       
        //Normal scenario
                      
        //Checking if the result is returned or not
        if(csvResource.size() == 1)
        {
            controller.csvFileBody = csvResource[0].body;   
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.agreementPricingMap = null;
        controller.importUpdateCSVFile();
       
       
        PageReference cancelPageRef = controller.cancel();        
        system.assertEquals('/'+controller.parentAgreement.Id, cancelPageRef.getUrl());
        
       
        Test.stopTest();
    }
    
    static testMethod void APTPS_Import_UpdateSchedulesControllerCreateGrowth(){
       string csvAsString;
    String[] csvFileLines;
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordTypeAndSubtype(acct.id, 'Schedule', 'Carriage', 'Fixed Voice', 
                                                                                                  'Fixed Voice Service Schedule');
       
        childAgmt1.Apttus__Parent_Agreement__c = agmt.id;
        update childAgmt1;
       List<APTPS_Agreement_Pricing_Data_Map__c> dataMaps = new List<APTPS_Agreement_Pricing_Data_Map__c>();
       APTPS_Agreement_Pricing_Data_Map__c dataMap = null;
       string[] csvRecordData = null;
       List<StaticResource> csvResource1 = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_AgreeementPricingDataMap'];
       
       Product2 prod1 = APTPS_TestClassData.productRecord('Business IP');
       Product2 prod2 = APTPS_TestClassData.productRecord('Wireless M2M Control Centre');
       
       Apttus__AgreementLineItem__c agreementLineItem = APTPS_TestClassData.agreementLineItemRecord(childAgmt1.Id, prod1.Id);
       
       APTPS_Component__c component1 = new APTPS_Component__c();
       component1.Agreement_Line_Item__c = agreementLineItem.Id;
       component1.APTPS_Attribute__c = 'Test Attribute';
       component1.Value__c = '10';
       
       insert component1;
       
       APTPS_Component__c component2 = new APTPS_Component__c();
       component2.Agreement_Line_Item__c = agreementLineItem.Id;
       component2.APTPS_Attribute__c = 'Test Attribute1';
       component2.Value__c = '11';
        insert component2;
       
       Fund__c fund2 = APTPS_TestClassData.fundRecord(agmt.id, 'MBRS');
       Fund__c fund3 = APTPS_TestClassData.fundRecord(agmt.id, 'MOTIF');
       Fund__c fund4 = APTPS_TestClassData.fundRecord(agmt.id, 'Other');
       Fund__c fund5 = APTPS_TestClassData.fundRecord(agmt.id, 'TIF');
       
       //Fund_Product__c fundProd1 = APTPS_TestClassData.fundProductRecord(fund1.id,prod1.id);
       Fund_Product__c fundProd2 = APTPS_TestClassData.fundProductRecord(fund2.id,prod1.id);
       Fund_Product__c fundProd3 = APTPS_TestClassData.fundProductRecord(fund3.id,prod1.id);
       Fund_Product__c fundProd4 = APTPS_TestClassData.fundProductRecord(fund4.id,prod1.id);
       Fund_Product__c fundProd5 = APTPS_TestClassData.fundProductRecord(fund5.id,prod1.id); 
       
       if(csvResource1.size() == 1)
       {
           Blob csvFileBody = csvResource1[0].body;
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
           
           for(Integer i = 1;i < csvFileLines.size();i++)
           {
               csvRecordData = csvFileLines[i].split(',', -1);

               dataMap = new APTPS_Agreement_Pricing_Data_Map__c();
               dataMap.APTPS_Tag_Type__c = csvRecordData[0];
               dataMap.APTPS_Product_Family__c = csvRecordData[1];
               dataMap.Related_Service_Schedule__c = csvRecordData[2];
               if(csvRecordData[3] != '')
               {
                   if(prod1.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod1.Id;
                   }
                   
                   if(prod2.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod2.Id;
                   }
                   
               }
               
               dataMap.Tag__c = csvRecordData[4];
               dataMap.APTPS_Translates_To_Field__c = csvRecordData[5];
               dataMap.Field_Type__c = csvRecordData[6];
               dataMap.APTPS_Fund_Type__c = csvRecordData[7];
               dataMap.APTPS_Field_Name__c = csvRecordData[8];
               dataMap.Object_Name__c = csvRecordData[9];   
               
               dataMaps.add(dataMap);
               
           }
           
           insert dataMaps;
       }
   
        PageReference pageRef = Page.APTPS_Init_ImportUpdateSchedules;
       
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
       
       Apttus__ComplySystemProperties__c sysProperties = new Apttus__ComplySystemProperties__c();
       sysProperties.Name = 'System Properties';
       sysProperties.APTPS_CALMs_Support_Email_Address__c = 'dummy@test.com';
       insert sysProperties;
        Test.startTest();
       
         
       
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_Import_UpdateSchedulesController controller = new APTPS_Import_UpdateSchedulesController();
        controller = new APTPS_Import_UpdateSchedulesController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.Id);
        system.assertEquals(agmt.name, controller.agreementName);
        
      List<StaticResource> csvResource = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportScheduleTestCSV'];
       
    
        system.assertEquals(1, csvResource.size());  
       
       
        //Normal scenario
                      
        //Checking if the result is returned or not
        if(csvResource.size() == 1)
        {
            controller.csvFileBody = csvResource[0].body;   
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
       
       
        PageReference cancelPageRef = controller.cancel();        
        system.assertEquals('/'+controller.parentAgreement.Id, cancelPageRef.getUrl());
        
       
        Test.stopTest();
    }
    
	static testMethod void APTPS_Import_UpdateSchedulesControllerActivatedSchdeule(){
       string csvAsString;
    String[] csvFileLines;
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordTypeAndSubtype(acct.id, 'Schedule', 'Carriage', 'Fixed Voice', 
                                                                                                  'Fixed Voice Service Schedule');
       
        childAgmt1.Apttus__Parent_Agreement__c = agmt.id;
        update childAgmt1;
		
		childAgmt1.Apttus__Status_Category__c = 'In Effect';
        childAgmt1.Apttus__Status__c = 'Activated';
        childAgmt1.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 1, 11);
        childAgmt1.Apttus__Contract_End_Date__c = Date.newInstance(2016, 5, 11);
        childAgmt1.Apttus__Term_Months__c = 4;
        update childAgmt1; 
		
		
       List<APTPS_Agreement_Pricing_Data_Map__c> dataMaps = new List<APTPS_Agreement_Pricing_Data_Map__c>();
       APTPS_Agreement_Pricing_Data_Map__c dataMap = null;
       string[] csvRecordData = null;
       List<StaticResource> csvResource1 = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_AgreeementPricingDataMap'];
       
       Product2 prod1 = APTPS_TestClassData.productRecord('Business IP');
       Product2 prod2 = APTPS_TestClassData.productRecord('Wireless M2M Control Centre');
       
       Apttus__AgreementLineItem__c agreementLineItem = APTPS_TestClassData.agreementLineItemRecord(childAgmt1.Id, prod1.Id);
       
       APTPS_Component__c component1 = new APTPS_Component__c();
       component1.Agreement_Line_Item__c = agreementLineItem.Id;
       component1.APTPS_Attribute__c = 'Test Attribute';
       component1.Value__c = '10';
       
       insert component1;
       
       APTPS_Component__c component2 = new APTPS_Component__c();
       component2.Agreement_Line_Item__c = agreementLineItem.Id;
       component2.APTPS_Attribute__c = 'Test Attribute1';
       component2.Value__c = '11';
        insert component2;
       
       Fund__c fund2 = APTPS_TestClassData.fundRecord(agmt.id, 'MBRS');
       Fund__c fund3 = APTPS_TestClassData.fundRecord(agmt.id, 'MOTIF');
       Fund__c fund4 = APTPS_TestClassData.fundRecord(agmt.id, 'Other');
       Fund__c fund5 = APTPS_TestClassData.fundRecord(agmt.id, 'TIF');
       
       //Fund_Product__c fundProd1 = APTPS_TestClassData.fundProductRecord(fund1.id,prod1.id);
       Fund_Product__c fundProd2 = APTPS_TestClassData.fundProductRecord(fund2.id,prod1.id);
       Fund_Product__c fundProd3 = APTPS_TestClassData.fundProductRecord(fund3.id,prod1.id);
       Fund_Product__c fundProd4 = APTPS_TestClassData.fundProductRecord(fund4.id,prod1.id);
       Fund_Product__c fundProd5 = APTPS_TestClassData.fundProductRecord(fund5.id,prod1.id); 
       
       if(csvResource1.size() == 1)
       {
           Blob csvFileBody = csvResource1[0].body;
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
           
           for(Integer i = 1;i < csvFileLines.size();i++)
           {
               csvRecordData = csvFileLines[i].split(',', -1);

               dataMap = new APTPS_Agreement_Pricing_Data_Map__c();
               dataMap.APTPS_Tag_Type__c = csvRecordData[0];
               dataMap.APTPS_Product_Family__c = csvRecordData[1];
               dataMap.Related_Service_Schedule__c = csvRecordData[2];
               if(csvRecordData[3] != '')
               {
                   if(prod1.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod1.Id;
                   }
                   
                   if(prod2.Name == csvRecordData[3])
                   {
                       dataMap.APTPS_Product__c = prod2.Id;
                   }
                   
               }
               
               dataMap.Tag__c = csvRecordData[4];
               dataMap.APTPS_Translates_To_Field__c = csvRecordData[5];
               dataMap.Field_Type__c = csvRecordData[6];
               dataMap.APTPS_Fund_Type__c = csvRecordData[7];
               dataMap.APTPS_Field_Name__c = csvRecordData[8];
               dataMap.Object_Name__c = csvRecordData[9];   
               
               dataMaps.add(dataMap);
               
           }
           
           insert dataMaps;
       }
   
        PageReference pageRef = Page.APTPS_Init_ImportUpdateSchedules;
       
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
       
       Apttus__ComplySystemProperties__c sysProperties = new Apttus__ComplySystemProperties__c();
       sysProperties.Name = 'System Properties';
       sysProperties.APTPS_CALMs_Support_Email_Address__c = 'dummy@test.com';
       insert sysProperties;
        Test.startTest();
       
         
       
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_Import_UpdateSchedulesController controller = new APTPS_Import_UpdateSchedulesController();
        controller = new APTPS_Import_UpdateSchedulesController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.Id);
        system.assertEquals(agmt.name, controller.agreementName);
        
      List<StaticResource> csvResource = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportScheduleTestCSV'];
       
    
        system.assertEquals(1, csvResource.size());  
       
       
        //Normal scenario
                      
        //Checking if the result is returned or not
        if(csvResource.size() == 1)
        {
            controller.csvFileBody = csvResource[0].body;   
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
       
       
        PageReference cancelPageRef = controller.cancel();        
        system.assertEquals('/'+controller.parentAgreement.Id, cancelPageRef.getUrl());
        
       
        Test.stopTest();
    }
}