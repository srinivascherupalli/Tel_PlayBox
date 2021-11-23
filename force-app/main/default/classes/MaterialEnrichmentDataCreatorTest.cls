/*
* @Author : Suyash/Sharmila 
* @Desc : Create Material Attachments on Product Configurations
*/
/****History of Updates 
 * 1. Suyash Chiplunkar DPG-4560 - Material Attachments not getting created when basket have multiple sites
****/

@isTest(SeeAllData=FALSE)
private class MaterialEnrichmentDataCreatorTest {
    
    @TestSetup
    private static void createTestData(){
        
        cscfga__Product_Definition__c prodDefinition = ProductTestFactory.buildProductDefinition('SDWAN ADAPT S1', 'Test Plan');
        
        prodDefinition.product_Specification__c = 'DMCAT_Offer_001343';
        prodDefinition.csordtelcoa__Product_Type__c = 'Subscription';
        prodDefinition.cscfga__Label__c = 'SDWAN ADAPT S1';
        prodDefinition.cscfga__Active__c = true;
        prodDefinition.cscfga__Allow_progress_from_incomplete_screens__c = true;
        INSERT prodDefinition;
        
        cscfga__Product_Definition__c velocloudProdDef = ProductTestFactory.buildProductDefinition('VeloCloud Tenancy', 'Test Plan');
        
        velocloudProdDef.product_Specification__c = 'DMCAT_Offer_001301';
        velocloudProdDef.csordtelcoa__Product_Type__c = 'Subscription';
        velocloudProdDef.cscfga__Label__c = 'DMCAT_Offer_001301';
        velocloudProdDef.cscfga__Active__c = true;
        velocloudProdDef.cscfga__Allow_progress_from_incomplete_screens__c = true;
        
        INSERT velocloudProdDef;
        
        //Attribute definition
        List<cscfga__Attribute_Definition__c> attributeDefinitionList = new List<cscfga__Attribute_Definition__c>();
        
        attributeDefinitionList.add(new cscfga__Attribute_Definition__c ( Name = 'Contract Term', cscfga__Data_Type__c = 'String', 
                                                                          cscfga__Type__c = 'Select List', cscfga__Default_Value__c = '24', 
                                                                          cscfga__Product_Definition__c = prodDefinition.Id,
                                                                          cscfga__Label__c = 'Contract Term', cscfga__Enable_null_option__c = true)
        );
                                   
        attributeDefinitionList.add(new cscfga__Attribute_Definition__c ( Name = 'LTE Mode', cscfga__Data_Type__c = 'String', 
                                              cscfga__Type__c = 'Select List', cscfga__Default_Value__c = 'NA', 
                                              cscfga__Product_Definition__c = prodDefinition.Id, 
                                              cscfga__Label__c = 'LTE Mode', cscfga__Enable_null_option__c = true)
        );
        
        attributeDefinitionList.add(new cscfga__Attribute_Definition__c ( Name = 'GUID', cscfga__Data_Type__c = 'String', 
                                                                          cscfga__Type__c = 'Display Value', cscfga__Label__c = 'GUID', cscfga__Enable_null_option__c = true, cscfga__Product_Definition__c = prodDefinition.Id)
        );
        
        attributeDefinitionList.add(new cscfga__Attribute_Definition__c ( Name = 'SolutionId', cscfga__Data_Type__c = 'String', 
                                                                          cscfga__Type__c = 'Display Value', cscfga__Label__c = 'SolutionId', cscfga__Enable_null_option__c = true, cscfga__Product_Definition__c = prodDefinition.Id)
        );
        
        INSERT attributeDefinitionList;
        
        //Account
        Account testAccount = new Account(Name = 'Burlington');
        INSERT testAccount;
        
        //Opportunity record type Id for Enterprise - Standard 
        Id enterpriseStdOpportunityRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();

        Opportunity testOpportunity = new Opportunity( Name = 'SDWAN ADAPT S1 Opportunity', RecordTypeId = enterpriseStdOpportunityRecId, StageName = 'Define', 
                                                       Probability = 10, Product_Domain__c = 'FIXED TELEPHONY',  Contract_Term__c = 24, 
                                                       Description__c = 'Test', CloseDate = date.today(), Product_Type__c = 'Modular');
        INSERT testOpportunity;
        
        //address
        cscrm__Address__c testAddress = new cscrm__Address__c(Name = 'Test Addr', Address_ID__c = '12345');
        INSERT testAddress;

        cscrm__Address__c testAddress1 = new cscrm__Address__c(Name = 'Test Addr1', Address_ID__c = '98765');
        INSERT testAddress1;
        
        //Site
        cscrm__Site__c testSite = new cscrm__Site__c( Name = 'Test Site', cscrm__Account__c = testAccount.Id, 
                                                  cscrm__Installation_Address__c = testAddress.Id, Legacy__c = TRUE);
        INSERT testSite;
        //DPG-4560
        cscrm__Site__c testSite1 = new cscrm__Site__c( Name = 'Test Site1', cscrm__Account__c = testAccount.Id, 
                                                  cscrm__Installation_Address__c = testAddress1.Id, Legacy__c = TRUE);
        INSERT testSite1;
        
        //Non-commercial schemanonComSchemaList
        List<csoe__Non_Commercial_Schema__c> nonComSchemaList= new List<csoe__Non_Commercial_Schema__c>();
        
        //device
        csoe__Non_Commercial_Schema__c deviceNonComSchema = new csoe__Non_Commercial_Schema__c(Name = 'Device', csoe__Description__c = 'Device',
                                                                                               csoe__Schema__c = '{"name": "Device", "description": "Device", "attributes":[{"showInUI": false, "required": false, "type": "String", "name" : "cspmb__type" }, { "showInUI": false, "required": false, "type": "String", "name": "Name" }, { "showInUI": false, "required":false, "type": "String", "name": "Vendor" }, { "showInUI": false, "required": false, "type":"String", "name": "cspmb__code"} ] }');
        nonComSchemaList.add(deviceNonComSchema);
        
        //License
        csoe__Non_Commercial_Schema__c licenseNonComSchema = new csoe__Non_Commercial_Schema__c( Name = 'License', csoe__Description__c = 'license', 
                                                                                                 csoe__Schema__c = '{"name": "License", "description": "License", "attributes": [ { "showInUI": false, "required": false, "type": "String", "name": "cspmb__type" }, { "showInUI": false, "required": false, "type": "String", "name": "Name" }, { "showInUI": false, "required": false, "type": "String", "name": "Vendor" }, { "showInUI": false, "required": false, "type": "String", "name": "cspmb__code" } ] }');
        nonComSchemaList.add(licenseNonComSchema);

        //Maintenance
        csoe__Non_Commercial_Schema__c maintenanceNonComSchema = new csoe__Non_Commercial_Schema__c( Name = 'Maintenance', csoe__Description__c = 'Maintenance', 
                                                                                                 csoe__Schema__c = '{"name": "Maintenance", "description": "License", "attributes": [ { "showInUI": false, "required": false, "type": "String", "name": "cspmb__type" }, { "showInUI": false, "required": false, "type": "String", "name": "Name" }, { "showInUI": false, "required": false, "type": "String", "name": "Vendor" }, { "showInUI": false, "required": false, "type": "String", "name": "cspmb__code" } ] }');
                                                                                                 
        nonComSchemaList.add(maintenanceNonComSchema);
         
        //Prisma
        csoe__Non_Commercial_Schema__c prismaNonComSchema = new csoe__Non_Commercial_Schema__c( Name = 'Prisma', csoe__Description__c = 'Prisma', 
                                                                                                 csoe__Schema__c = '{"name": "Prisma", "description": "Prisma", "attributes": [ { "showInUI": false, "required": false, "type": "String", "name": "cspmb__type" }, { "showInUI": false, "required": false, "type": "String", "name": "Name" }, { "showInUI": false, "required": false, "type": "String", "name": "Vendor" }, { "showInUI": false, "required": false, "type": "String", "name": "cspmb__code" } ] }');
        nonComSchemaList.add(prismaNonComSchema);
        
        INSERT nonComSchemaList;
        
        //Commercial Product Association
        List<csoe__Non_Commercial_Product_Association__c> nonCommProdAssociationList = new List<csoe__Non_Commercial_Product_Association__c>();
        nonCommProdAssociationList.add(new csoe__Non_Commercial_Product_Association__c(Name = 'Device NC Schema', csoe__Max__c = 1, csoe__Min__c = 0,
                                                                                       csoe__Non_Commercial_Schema__c = deviceNonComSchema.Id,
                                                                                       csoe__Commercial_Product_Definition__c = prodDefinition.Id));
        
        INSERT nonCommProdAssociationList;
        
        //Material Group
        cspmb__Material_Group__c materialGroup = new cspmb__Material_Group__c(Name = 'SDWAN ADAPT S1', cspmb__description__c = 'material Group for test prod');
        INSERT materialGroup; 
        
        //Commercial Product
        cspmb__Price_Item__c commercialProd = ProductTestFactory.buildPriceItem('SDWAN-Extra Large', 100, 50, 'Offer_Id__c');
        INSERT commercialProd;
        
        //Materials
        List<cspmb__Material__c> materialList = new List<cspmb__Material__c>();
        materialList.add(new cspmb__Material__c(Name = 'velocloud 610', Vendor__c = 'Velocloud', Non_Commercial_Schema__c = deviceNonComSchema.Id,
                                                cspmb__code__c = 'VF-JKL-15-TYR-15'));
                                                
        materialList.add(new cspmb__Material__c(Name = 'VeloCloud 500M License', Vendor__c = 'Velocloud', 
                                                Non_Commercial_Schema__c = licenseNonComSchema.Id, cspmb__code__c = 'VF-JKL-15-RGN-15'));
                                                
        materialList.add(new cspmb__Material__c(Name = 'VeloCloud 620 Maintenance', Vendor__c = 'Velocloud', 
                                                Non_Commercial_Schema__c = maintenanceNonComSchema.Id, cspmb__code__c = 'VF-ERT-15-WSAD-15'));
                                                
        materialList.add(new cspmb__Material__c(Name = '200Mbps', Vendor__c = 'Velocloud', 
                                                Non_Commercial_Schema__c = prismaNonComSchema.Id, cspmb__code__c = 'VF-XCV-15-RGN-15'));
        INSERT materialList;
        
        //Material Group and Material association
        List<cspmb__Material_Group_Material_Association__c> materialGroupMaterialAsso = new List<cspmb__Material_Group_Material_Association__c>();
        materialGroupMaterialAsso.add(new cspmb__Material_Group_Material_Association__c(cspmb__material__c = materialList[0].Id, 
                                                                                        cspmb__material_group__c = materialGroup.Id));
        materialGroupMaterialAsso.add(new cspmb__Material_Group_Material_Association__c(cspmb__material__c = materialList[1].Id, 
                                                                                        cspmb__material_group__c = materialGroup.Id));
        materialGroupMaterialAsso.add(new cspmb__Material_Group_Material_Association__c(cspmb__material__c = materialList[2].Id, 
                                                                                        cspmb__material_group__c = materialGroup.Id));
        materialGroupMaterialAsso.add(new cspmb__Material_Group_Material_Association__c(cspmb__material__c = materialList[3].Id, 
                                                                                        cspmb__material_group__c = materialGroup.Id));
        
        INSERT materialGroupMaterialAsso;
        
        
        //commercial product Material group association.
        cspmb__Commercial_Product_Material_Group_Assoc__c comProdAndMaterialGrpAssociation;
        comProdAndMaterialGrpAssociation = new cspmb__Commercial_Product_Material_Group_Assoc__c(cspmb__commercial_product__c = commercialProd.Id, 
                                                                                                 cspmb__material_group__c = materialGroup.Id);
        INSERT comProdAndMaterialGrpAssociation;
        
        //Product Basket
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c( Name = 'BT000-111-999', csbb__Account__c = testAccount.Id, 
                                                                          cscfga__Opportunity__c = testOpportunity.Id);
        INSERT basket;
        
        //Product configuration
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c(Name = 'SDWAN ADAPT S1', cscfga__Product_Basket__c = basket.Id,
                                                                                           cscfga__Product_Definition__c = prodDefinition.Id);
        
        INSERT prodConfig;
        //DPG-4560
        cscfga__Product_Configuration__c prodConfig1 = new cscfga__Product_Configuration__c(Name = 'SDWAN ADAPT S1', cscfga__Product_Basket__c = basket.Id,
                                                                                           cscfga__Product_Definition__c = prodDefinition.Id);
        
        INSERT prodConfig1;
        
        cscfga__Product_Configuration__c veloCloudProdConfig = new cscfga__Product_Configuration__c(Name = 'VeloCloud Tenancy', 
                                                                                                    cscfga__Product_Basket__c = basket.Id,
                                                                                                    cscfga__Product_Definition__c = velocloudProdDef.Id);
        
        INSERT veloCloudProdConfig;
        
        
        //JSON data for solution definition
        csutil__JSON_Data__c jsondata = new csutil__JSON_Data__c ( Name ='SD-WAN ADAPT S1 Solution', 
                                                                   csutil__value__c = '{ "attributes": [ { "showInUI": false, "required":   false, "type": "String", "name": "GUID" }, { "showInUI": false, "required": false, "type": "String", "name": "SolutionId" }, { "required": false, "showInUI": true, "readOnly": false, "name": "LTE Mode", "label": "LTE Mode", "options": [ { "value": "NA", "label": "NA" } ], "type": "Picklist", "value": "NA", "customCSSClasses": "", "referencedAttributes": "" }, { "required": false, "showInUI": true, "readOnly": false, "name": "Contract Term", "label": "Contract Term", "value": "24", "options": [ { "value": "12", "label": "12 Months" }, { "value": "24", "label": "24 Months" }, { "value": "36", "label": "36 Months" } ], "type": "Picklist", "customCSSClasses": "", "referencedAttributes": "" } ], "visible": true, "disabled": false, "name": "SD-WAN ADAPT S1", "description": "SD-WAN ADAPT S1 Solution" }');
        INSERT jsondata;
        
        //Solution definition
        cssdm__Solution_Definition__c solDefinition = new cssdm__Solution_Definition__c(Name = 'SD-WAN ADAPT S1 Solution', cssdm__type__c = 'Main', 
                                                                                        cssdm__product_definition__c = prodDefinition.Id, 
                                                                                        cssdm__min__c = 1, cssdm__sequence__c = 20, 
                                                                                        cssdm__schema__c = jsondata.Id,
                                                                                        cssdm__component_type__c = 'Example', cssdm__max__c = 1);
        INSERT solDefinition;
        
    }
    
    @isTest
    static void getDataTest() {
        
        Map<Id, Map<Id, List<cspmb__Material__c>>> m_commercialProduct2MaterialsBySchemaMap;
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, Object> returnMapUpdate = new Map<String, Object>();

        Test.startTest();
            List<cscfga__Product_Configuration__c> sdwanProdConfig = [SELECT Id,Name FROM cscfga__Product_Configuration__c WHERE Name = 'SDWAN ADAPT S1'];
            cspmb__Price_Item__c commercialProd = [SELECT Id,Name FROM cspmb__Price_Item__c];
            cscfga__Product_Basket__c basket = [SELECT Id,Name FROM cscfga__Product_Basket__c];
            //DPG-4560
            string inputString ='{"'+sdwanProdConfig[0].Id+'": "'+commercialProd.Id+'","'+ sdwanProdConfig[1].Id+'": "'+ commercialProd.Id +'"}';
            //string inputString ='{"'+sdwanProdConfig[0].Id+'": "'+commercialProd.Id+'"}';
            //string inputString ='{"'+prodConfig.Id+'": "asdfgreffgerttyGGH"}';
            Map<String, Object> inputMap = new Map<String, Object>();
            inputMap.put('getData', '');
            inputMap.put('CommercialProductMap', inputString);
            inputMap.put('basketId', basket.Id);
            
            returnMap = MaterialEnrichmentDataCreator.getData(inputMap);
          //
          returnMapUpdate = MaterialEnrichmentDataCreator.getData(inputMap);
        Test.stopTest();
            
        System.assertNotEquals( new List<Id>(MaterialEnrichmentDataCreator.m_config2cp.keySet())[0], 
                                [SELECT Id FROM cscfga__Product_Configuration__c WHERE Name = 'VeloCloud Tenancy'].Id);
                             
        System.assertEquals( new List<Id>(MaterialEnrichmentDataCreator.m_config2cp.keySet())[0], sdwanProdConfig[0].Id);
                             
        System.assertEquals(returnMap.containsKey('createOE'), true);
        
        List<Attachment> attachmentList = [SELECT Id, Name, ParentId FROM Attachment where ParentId  =: sdwanProdConfig[0].Id];
        System.assertEquals(attachmentList.size(), 1);
        //DPG-4560
        List<Attachment> attachmentList1 = [SELECT Id, Name, ParentId FROM Attachment where ParentId  =: sdwanProdConfig[1].Id];
        System.assertEquals(attachmentList1.size(), 1);
    }
}