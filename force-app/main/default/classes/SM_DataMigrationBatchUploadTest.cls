/*********************************************************************************************************************************
 *Class Name      :   SM_DataMigrationBatchUploadTest
===============================================================================================================================
Sr.No.      Developer Name          Date            Change Description
1.          Pooja P Bhat            14/07/2020      New - Test class for Solution & OE Migration Scripts SM_DataMigrationBatchUpload
*********************************************************************************************************************************/

@isTest 
private class SM_DataMigrationBatchUploadTest {

    @Testsetup static void dataSetup() {
        //Creating Product Definition test data
        cscfga__Product_Definition__c def =  ProductTestFactory.buildProductDefinition('test','testplan');
        insert def;
        
        //Creating Basket test data
        List<cscfga__Product_Basket__c> basketList  =   new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket1   =   ProductTestFactory.buildEmptyBasket(); basketList.add(basket1);
        cscfga__Product_Basket__c basket2   =   ProductTestFactory.buildEmptyBasket(); basketList.add(basket2);
        cscfga__Product_Basket__c basket3   =   ProductTestFactory.buildEmptyBasket(); basketList.add(basket3);
        cscfga__Product_Basket__c basket4   =   ProductTestFactory.buildEmptyBasket(); basketList.add(basket4);
        cscfga__Product_Basket__c basket5   =   ProductTestFactory.buildEmptyBasket(); basketList.add(basket5);
        cscfga__Product_Basket__c basket6   =   ProductTestFactory.buildEmptyBasket(); basketList.add(basket6);
        cscfga__Product_Basket__c basket7   =   ProductTestFactory.buildEmptyBasket(); basketList.add(basket7);
        cscfga__Product_Basket__c basket8   =   ProductTestFactory.buildEmptyBasket(); basketList.add(basket8);
        cscfga__Product_Basket__c basket9   =   ProductTestFactory.buildEmptyBasket(); basketList.add(basket9);
        cscfga__Product_Basket__c basket10  =   ProductTestFactory.buildEmptyBasket(); basketList.add(basket10);
        insert basketList;

        //Creating Solution test data
        List<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        csord__Solution__c solution1    =   new csord__Solution__c(name ='test sol1', csord__Identification__c = 'test', cssdm__product_basket__c=basket1.id, csord__Status__c = 'New');
        solutionList.add(solution1);
        csord__Solution__c solution2    =   new csord__Solution__c(name ='test sol2', csord__Identification__c = 'test', cssdm__product_basket__c=basket2.id, csord__Status__c = 'New');
        solutionList.add(solution2);
        csord__Solution__c solution3    =   new csord__Solution__c(name ='test sol3', csord__Identification__c = 'test', cssdm__product_basket__c=basket3.id, csord__Status__c = 'New');
        solutionList.add(solution3);
        csord__Solution__c solution4    =   new csord__Solution__c(name ='test sol4', csord__Identification__c = 'test', cssdm__product_basket__c=basket4.id, csord__Status__c = 'New');
        solutionList.add(solution4);
        csord__Solution__c solution5    =   new csord__Solution__c(name ='test sol5', csord__Identification__c = 'test', cssdm__product_basket__c=basket5.id, csord__Status__c = 'New');
        solutionList.add(solution5);
        csord__Solution__c solution6    =   new csord__Solution__c(name ='test sol6', csord__Identification__c = 'test', cssdm__product_basket__c=basket6.id, csord__Status__c = 'New');
        solutionList.add(solution6);
        csord__Solution__c solution7    =   new csord__Solution__c(name ='test sol7', csord__Identification__c = 'test', cssdm__product_basket__c=basket7.id, csord__Status__c = 'New');
        solutionList.add(solution7);
        csord__Solution__c solution8    =   new csord__Solution__c(name ='test sol8', csord__Identification__c = 'test', cssdm__product_basket__c=basket8.id, csord__Status__c = 'New');
        solutionList.add(solution8);
        csord__Solution__c solution9    =   new csord__Solution__c(name ='test sol9', csord__Identification__c = 'test', cssdm__product_basket__c=basket9.id, csord__Status__c = 'New');
        solutionList.add(solution9);
        csord__Solution__c solution10   =   new csord__Solution__c(name ='test sol10', csord__Identification__c = 'test', cssdm__product_basket__c=basket10.id, csord__Status__c = 'New');
        solutionList.add(solution10);
        insert solutionList;

        //Creating Product Configuration test data
        List<cscfga__Product_Configuration__c> pcList   =   new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config1    =   ProductTestFactory.buildProductConfig(def.id);
        config1.cscfga__Product_Basket__c           =   basket1.id;
        config1.cssdm__solution_association__c      =   solution1.id;
        pcList.add(config1);
        cscfga__Product_Configuration__c config2    =   ProductTestFactory.buildProductConfig(def.id);
        config2.cscfga__Product_Basket__c           =   basket2.id;
        config2.cssdm__solution_association__c      =   solution2.id;
        pcList.add(config2);
        cscfga__Product_Configuration__c config3    =   ProductTestFactory.buildProductConfig(def.id);
        config3.cscfga__Product_Basket__c           =   basket3.id;
        config3.cssdm__solution_association__c      =   solution3.id;
        pcList.add(config3);
        cscfga__Product_Configuration__c config4    =   ProductTestFactory.buildProductConfig(def.id);
        config4.cscfga__Product_Basket__c           =   basket4.id;
        config4.cssdm__solution_association__c      =   solution4.id;
        pcList.add(config4);
        cscfga__Product_Configuration__c config5    =   ProductTestFactory.buildProductConfig(def.id);
        config5.cscfga__Product_Basket__c           =   basket5.id;
        config5.cssdm__solution_association__c      =   solution5.id;
        pcList.add(config5);
        cscfga__Product_Configuration__c config6    =   ProductTestFactory.buildProductConfig(def.id);
        config6.cscfga__Product_Basket__c           =   basket6.id;
        config6.cssdm__solution_association__c      =   solution6.id;
        pcList.add(config6);
        cscfga__Product_Configuration__c config7    =   ProductTestFactory.buildProductConfig(def.id);
        config7.cscfga__Product_Basket__c           =   basket7.id;
        config7.cssdm__solution_association__c      =   solution7.id;
        pcList.add(config7);
        cscfga__Product_Configuration__c config8    =   ProductTestFactory.buildProductConfig(def.id);
        config8.cscfga__Product_Basket__c           =   basket8.id;
        config8.cssdm__solution_association__c      =   solution8.id;
        pcList.add(config8);
        cscfga__Product_Configuration__c config9    =   ProductTestFactory.buildProductConfig(def.id);
        config9.cscfga__Product_Basket__c           =   basket9.id;
        config9.cssdm__solution_association__c      =   solution9.id;
        pcList.add(config9);
        cscfga__Product_Configuration__c config10   =   ProductTestFactory.buildProductConfig(def.id);
        config10.cscfga__Product_Basket__c          =   basket10.id;
        config10.cssdm__solution_association__c     =   solution10.id;
        pcList.add(config10);
        insert pcList;

        //Creating Product Configuration Request test data
        List<csbb__product_configuration_request__c> pcrList    =   new List<csbb__product_configuration_request__c>();
        csbb__product_configuration_request__c pcr1 =   ProductTestFactory.buildConfigRequest(basket1.id,config1.id);
        pcrList.add(pcr1);
        csbb__product_configuration_request__c pcr2 =   ProductTestFactory.buildConfigRequest(basket2.id,config2.id);
        pcrList.add(pcr2);
        csbb__product_configuration_request__c pcr3 =   ProductTestFactory.buildConfigRequest(basket3.id,config3.id);
        pcrList.add(pcr3);
        csbb__product_configuration_request__c pcr4 =   ProductTestFactory.buildConfigRequest(basket4.id,config4.id);
        pcrList.add(pcr4);
        csbb__product_configuration_request__c pcr5 =   ProductTestFactory.buildConfigRequest(basket5.id,config5.id);
        pcrList.add(pcr5);
        csbb__product_configuration_request__c pcr6 =   ProductTestFactory.buildConfigRequest(basket6.id,config6.id);
        pcrList.add(pcr6);
        csbb__product_configuration_request__c pcr7 =   ProductTestFactory.buildConfigRequest(basket7.id,config7.id);
        pcrList.add(pcr7);
        csbb__product_configuration_request__c pcr8 =   ProductTestFactory.buildConfigRequest(basket8.id,config8.id);
        pcrList.add(pcr8);
        csbb__product_configuration_request__c pcr9 =   ProductTestFactory.buildConfigRequest(basket9.id,config9.id);
        pcrList.add(pcr9);
        csbb__product_configuration_request__c pcr10=   ProductTestFactory.buildConfigRequest(basket10.id,config10.id);
        pcrList.add(pcr10);
        insert pcrList;
        
        //Creating Document TestData
        String documentBody     =  'SolutionId,Migrated To Heroku,Error Message (if Any)';
        for(csord__Solution__c oSln : solutionList) {
            documentBody += '\n' + oSln.Id + ',' + 'False';
        }
        Document Document       = new Document();
        document.Body           = Blob.valueOf(documentBody);
        document.ContentType    = 'application/vnd.ms-excel';
        document.Type           = 'csv';
        document.DeveloperName  = 'my_document';
        document.Name           = 'My Document';
        document.FolderId = [SELECT Id FROM Folder WHERE Name LIKE '%Shared%' LIMIT 1].Id;
        insert document;
    }   //End of method dataSetup()

    //Solution Id File Processing
    static testMethod void solutionMigFileUpload() {
        Set<Id> sSolutionIds    =   new Set<Id>();
        for(csord__Solution__c oSln : [SELECT Id FROM csord__Solution__c]) {
            sSolutionIds.add(oSln.Id);
        }
        System.assertEquals(sSolutionIds.size(), 10);
        
        Test.startTest();
    
        //Valid file name, Read the Soltion Id from File saved in document object
        Document oDocument      =   [SELECT Id,Name,Body FROM Document LIMIT 1];
        System.assertEquals(oDocument.Name, 'My Document');
        List<String> columnsVal =   oDocument.Body.toString().split('\n');  
        columnsVal.remove(0);
        for(String oStr : columnsVal) {
            System.assertNotEquals(oStr.split(',')[0].trim().length(),15);  //Checking 15character solution id is not passed 
            System.assertNotEquals(oStr.split(',')[1].trim(),'TRUE');       //Checking Migrated to Heroku flag is not set to True
        }
        SM_DataMigrationBatchUpload batchHerokuUploadStatusUpdate1 = new SM_DataMigrationBatchUpload(oDocument.Name);
        Database.executeBatch(batchHerokuUploadStatusUpdate1);
        
        //Invalid file name to cover the catch block in constructor SM_DataMigrationBatchUpload(String docuName)
        SM_DataMigrationBatchUpload batchHerokuUploadStatusUpdate2 = new SM_DataMigrationBatchUpload('Test Doc');
        Database.executeBatch(batchHerokuUploadStatusUpdate2);
        
        Test.stopTest();
    } //End of method solutionMigFileUpload()

    static testMethod void solutionMigSetIdUpload() {
        List<cscfga__Product_Basket__c> basketList = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c];
        Set<Id> sSolutionIds    =   new Set<Id>();
        for(csord__Solution__c oSln : [SELECT Id from csord__Solution__c]) {
            sSolutionIds.add(oSln.Id);
        }
        System.assertEquals(sSolutionIds.size(), 10);
        
        Test.startTest();
        
        //Read the Solution Id from the explicitly passed 'Set of Solution Ids'
        SM_DataMigrationBatchUpload batchHerokuUploadStatusUpdate = new SM_DataMigrationBatchUpload(sSolutionIds);
        Database.executeBatch(batchHerokuUploadStatusUpdate);
        Test.stopTest();
        
        System.assertNotEquals(basketList[0].csordtelcoa__Basket_Stage__c, '');
    } //End of method solutionMigSetIdUpload()

}   //End of class SM_DataMigrationBatchUploadTest