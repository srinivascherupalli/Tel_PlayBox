@isTest
public class SM_DataMigrationBatchAttUpdateAMTest {
	@Testsetup static void dataSetup() {
        //Creating Marketable offer test data
        Marketable_Offer__c marketableOffer = new Marketable_Offer__c();
        marketableOffer.OfferDefinationName__c = 'Adaptive Mobility';
        marketableOffer.Offer_ID__c = 'DMCAT_Offer_001233';
        marketableOffer.Name = 'Adaptive Mobility';
        insert marketableOffer;
        //Creating Product Definition test data
        cscfga__Product_Definition__c def =  ProductTestFactory.buildProductDefinition('Adaptive Mobility Solution','testplan');
        insert def;

        //Creating Attribute Definition test data
        List<cscfga__Attribute_Definition__c> lstAttributeDef = new List<cscfga__Attribute_Definition__c>();
        cscfga__Attribute_Definition__c ad3 = ProductTestFactory.buildAttributeDefinition('GUID', def.Id);
        lstAttributeDef.add(ad3);
        insert lstAttributeDef;    
        
        //Creating Basket test data
        List<cscfga__Product_Basket__c> basketList  =   new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket1   =   ProductTestFactory.buildEmptyBasket(); basket1.csordtelcoa__Basket_Stage__c = 'Commercial Configuration'; basketList.add(basket1);
        cscfga__Product_Basket__c basket2   =   ProductTestFactory.buildEmptyBasket(); basket2.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';basketList.add(basket2);
        cscfga__Product_Basket__c basket3   =   ProductTestFactory.buildEmptyBasket(); basket3.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';basketList.add(basket3);
        cscfga__Product_Basket__c basket4   =   ProductTestFactory.buildEmptyBasket(); basket4.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';basketList.add(basket4);
        cscfga__Product_Basket__c basket5   =   ProductTestFactory.buildEmptyBasket(); basket5.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';basketList.add(basket5);
        cscfga__Product_Basket__c basket6   =   ProductTestFactory.buildEmptyBasket(); basket6.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';basketList.add(basket6);
        cscfga__Product_Basket__c basket7   =   ProductTestFactory.buildEmptyBasket(); basket7.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';basketList.add(basket7);
        cscfga__Product_Basket__c basket8   =   ProductTestFactory.buildEmptyBasket(); basket8.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';basketList.add(basket8);
        cscfga__Product_Basket__c basket9   =   ProductTestFactory.buildEmptyBasket(); basket9.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';basketList.add(basket9);
        cscfga__Product_Basket__c basket10  =   ProductTestFactory.buildEmptyBasket(); basket10.csordtelcoa__Basket_Stage__c= 'Commercial Configuration';basketList.add(basket10);
        insert basketList;

        //Creating Solution test data
        List<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        csord__Solution__c solution1    =   new csord__Solution__c(name ='Adaptive Mobility1', csord__Identification__c = 'test', cssdm__product_basket__c=basket1.id, csord__Status__c = 'New');
        solutionList.add(solution1);
        csord__Solution__c solution2    =   new csord__Solution__c(name ='Adaptive Mobility2', csord__Identification__c = 'test', cssdm__product_basket__c=basket2.id, csord__Status__c = 'New');
        solutionList.add(solution2);
        csord__Solution__c solution3    =   new csord__Solution__c(name ='Adaptive Mobility3', csord__Identification__c = 'test', cssdm__product_basket__c=basket3.id, csord__Status__c = 'New');
        solutionList.add(solution3);
        csord__Solution__c solution4    =   new csord__Solution__c(name ='Adaptive Mobility4', csord__Identification__c = 'test', cssdm__product_basket__c=basket4.id, csord__Status__c = 'New');
        solutionList.add(solution4);
        csord__Solution__c solution5    =   new csord__Solution__c(name ='Adaptive Mobility5', csord__Identification__c = 'test', cssdm__product_basket__c=basket5.id, csord__Status__c = 'New');
        solutionList.add(solution5);
        csord__Solution__c solution6    =   new csord__Solution__c(name ='Adaptive Mobility6', csord__Identification__c = 'test', cssdm__product_basket__c=basket6.id, csord__Status__c = 'New');
        solutionList.add(solution6);
        csord__Solution__c solution7    =   new csord__Solution__c(name ='Adaptive Mobility7', csord__Identification__c = 'test', cssdm__product_basket__c=basket7.id, csord__Status__c = 'New');
        solutionList.add(solution7);
        csord__Solution__c solution8    =   new csord__Solution__c(name ='Adaptive Mobility8', csord__Identification__c = 'test', cssdm__product_basket__c=basket8.id, csord__Status__c = 'New');
        solutionList.add(solution8);
        csord__Solution__c solution9    =   new csord__Solution__c(name ='Adaptive Mobility9', csord__Identification__c = 'test', cssdm__product_basket__c=basket9.id, csord__Status__c = 'New');
        solutionList.add(solution9);
        csord__Solution__c solution10   =   new csord__Solution__c(name ='Adaptive Mobility10', csord__Identification__c = 'test', cssdm__product_basket__c=basket10.id, csord__Status__c = 'New');
        solutionList.add(solution10);
        insert solutionList;

        //Creating Product Configuration test data
        List<cscfga__Product_Configuration__c> pcList   =   new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config1    =   ProductTestFactory.buildProductConfig(def.id);
        config1.cscfga__Product_Basket__c           =   basket1.id;
        config1.cssdm__solution_association__c      =   solution1.id;
        config1.Marketable_Offer__c                 =   marketableOffer.id;
        pcList.add(config1);
        cscfga__Product_Configuration__c config2    =   ProductTestFactory.buildProductConfig(def.id);
        config2.cscfga__Product_Basket__c           =   basket2.id;
        config2.cssdm__solution_association__c      =   solution2.id;
        config2.Marketable_Offer__c                 =   marketableOffer.id;
        pcList.add(config2);
        cscfga__Product_Configuration__c config3    =   ProductTestFactory.buildProductConfig(def.id);
        config3.cscfga__Product_Basket__c           =   basket3.id;
        config3.cssdm__solution_association__c      =   solution3.id;
        config3.Marketable_Offer__c                 =   marketableOffer.id;
        pcList.add(config3);
        cscfga__Product_Configuration__c config4    =   ProductTestFactory.buildProductConfig(def.id);
        config4.cscfga__Product_Basket__c           =   basket4.id;
        config4.cssdm__solution_association__c      =   solution4.id;
        config4.Marketable_Offer__c                 =   marketableOffer.id;
        pcList.add(config4);
        cscfga__Product_Configuration__c config5    =   ProductTestFactory.buildProductConfig(def.id);
        config5.cscfga__Product_Basket__c           =   basket5.id;
        config5.cssdm__solution_association__c      =   solution5.id;
        config5.Marketable_Offer__c                 =   marketableOffer.id;
        pcList.add(config5);
        cscfga__Product_Configuration__c config6    =   ProductTestFactory.buildProductConfig(def.id);
        config6.cscfga__Product_Basket__c           =   basket6.id;
        config6.cssdm__solution_association__c      =   solution6.id;
        config6.Marketable_Offer__c                 =   marketableOffer.id;
        pcList.add(config6);
        cscfga__Product_Configuration__c config7    =   ProductTestFactory.buildProductConfig(def.id);
        config7.cscfga__Product_Basket__c           =   basket7.id;
        config7.cssdm__solution_association__c      =   solution7.id;
        config7.Marketable_Offer__c                 =   marketableOffer.id;
        pcList.add(config7);
        cscfga__Product_Configuration__c config8    =   ProductTestFactory.buildProductConfig(def.id);
        config8.cscfga__Product_Basket__c           =   basket8.id;
        config8.cssdm__solution_association__c      =   solution8.id;
        config8.Marketable_Offer__c                 =   marketableOffer.id;
        pcList.add(config8);
        cscfga__Product_Configuration__c config9    =   ProductTestFactory.buildProductConfig(def.id);
        config9.cscfga__Product_Basket__c           =   basket9.id;
        config9.cssdm__solution_association__c      =   solution9.id;
        config9.Marketable_Offer__c                 =   marketableOffer.id;
        pcList.add(config9);
        cscfga__Product_Configuration__c config10   =   ProductTestFactory.buildProductConfig(def.id);
        config10.cscfga__Product_Basket__c          =   basket10.id;
        config10.cssdm__solution_association__c     =   solution10.id;
        config10.Marketable_Offer__c                 =   marketableOffer.id;
        pcList.add(config10);
        insert pcList;

        //Creating Attribute test data
        List<cscfga__Attribute__c> attributeList    =   new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att1   =   ProductTestFactory.buildAttribute('GUID', 'dce296a0-b07a-b969-3613-7b79fbc53cf1', config1.Id);
        cscfga__Attribute__c att2   =   ProductTestFactory.buildAttribute('GUID', 'dce296a0-b07a-b969-3613-7b79fbc53cf2', config2.Id);
        cscfga__Attribute__c att3   =   ProductTestFactory.buildAttribute('GUID', 'dce296a0-b07a-b969-3613-7b79fbc53cf3', config3.Id);
        cscfga__Attribute__c att4   =   ProductTestFactory.buildAttribute('GUID', 'dce296a0-b07a-b969-3613-7b79fbc53cf4', config4.Id);
        cscfga__Attribute__c att5  =   ProductTestFactory.buildAttribute('GUID', 'dce296a0-b07a-b969-3613-7b79fbc53cf5', config5.Id);
        cscfga__Attribute__c att6  =   ProductTestFactory.buildAttribute('GUID', 'dce296a0-b07a-b969-3613-7b79fbc53cf6', config6.Id);
        cscfga__Attribute__c att7  =   ProductTestFactory.buildAttribute('GUID', 'dce296a0-b07a-b969-3613-7b79fbc53cf7', config7.Id);
        cscfga__Attribute__c att8  =   ProductTestFactory.buildAttribute('GUID', 'dce296a0-b07a-b969-3613-7b79fbc53cf8', config8.Id);
        cscfga__Attribute__c att9  =   ProductTestFactory.buildAttribute('GUID', 'dce296a0-b07a-b969-3613-7b79fbc53cf9', config9.Id);
        cscfga__Attribute__c att10  =   ProductTestFactory.buildAttribute('GUID', 'dce296a0-b07a-b969-3613-7b79fbc53cf10', config10.Id);
        attributeList.add(att1);
        attributeList.add(att2);
        attributeList.add(att3);
        attributeList.add(att4);
        attributeList.add(att5);
        attributeList.add(att6);
        attributeList.add(att7);
        attributeList.add(att8);
        attributeList.add(att9);
        attributeList.add(att10);
        insert attributeList;
    }   //End of method dataSetup()

    static testMethod void dataMigrationBatchAttributeUpdateAM() {
        Test.startTest();
        Map<String,String> attrDetails = new Map<String,String>();
		attrDetails.put('Offer Name','Adaptive Mobility');
        SM_DataMigrationBatchAttibuteUpdateAM batchUpdateAM = new SM_DataMigrationBatchAttibuteUpdateAM('Adaptive Mobility',attrDetails,'OfferName__c = \'Adaptive Mobility\'');
        Database.executeBatch(batchUpdateAM);

        Test.stopTest();

        List<Document> documentList = [SELECT Id,Name,Body FROM Document WHERE Name = 'SM_DataMigrationAttributeUpdateAM'];
        System.assertEquals(1, documentList.size());
    }
    static testMethod void dataMigrationforSolution() {
        Test.startTest();
        List<Id> solutionIds = new List<Id>();
        for(csord__Solution__c sol:[SELECT Id, cssdm__product_basket__c, cssdm__product_basket__r.csordtelcoa__Basket_Stage__c FROM csord__Solution__c]){
            solutionIds.add(sol.Id);
        }
        SM_DataMigrationBatchAttibuteUpdateAM batchUpdateAM = new SM_DataMigrationBatchAttibuteUpdateAM(solutionIds);
        Database.executeBatch(batchUpdateAM);

        Test.stopTest();

        List<Document> documentList = [SELECT Id,Name,Body FROM Document WHERE Name = 'SM_DataMigrationAttributeUpdateAM'];
        System.assertEquals(1, documentList.size());
    }
    static testMethod void dataMigrationwithOutWhereClause() {
        Test.startTest();
        List<Id> solutionIds = new List<Id>();
        for(csord__Solution__c sol:[SELECT Id, cssdm__product_basket__c, cssdm__product_basket__r.csordtelcoa__Basket_Stage__c FROM csord__Solution__c]){
            solutionIds.add(sol.Id);
        }
        Map<String,String> attrDetails = new Map<String,String>();
		attrDetails.put('Offer Name','Adaptive Mobility');
        SM_DataMigrationBatchAttibuteUpdateAM batchUpdateAM = new SM_DataMigrationBatchAttibuteUpdateAM('Adaptive Mobility',attrDetails,'');
        Database.executeBatch(batchUpdateAM);

        Test.stopTest();

        List<Document> documentList = [SELECT Id,Name,Body FROM Document WHERE Name = 'SM_DataMigrationAttributeUpdateAM'];
        System.assertEquals(1, documentList.size());
    }
}