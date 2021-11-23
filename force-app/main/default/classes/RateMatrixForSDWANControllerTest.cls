/*************************************************************************************************************************
* @Author       : Lalit Motiray
* @Created Date : 03 November  2020
* @Description  : RateMatrixForSDWANcontroller Test class //DPG - 3110
***************************************************************************************************************************/
@isTest
private class RateMatrixForSDWANControllerTest {
    
    @testSetup
    static void createTestData(){
        
        cspmb__Price_Item__c commercialProduct = new cspmb__Price_Item__c(Name = 'SD-WAN Adapt S1 – Extra Large', cspmb__Contract_Term__c = '12',
                                                                          cspmb__Price_Item_Code__c = 'SD-WAN Adapt S1 – Extra Large', 
                                                                          cspmb__Billing_Frequency__c = 'Monthly', Plan_Type__c = 'NA', 
                                                                          cspmb__One_Off_Charge__c = 250, cspmb__Recurring_Charge__c = 1200);   
        
        INSERT commercialProduct;
        
        cspmb__Material_Group__c materialGroup = new cspmb__Material_Group__c(Name = 'SD-WAN Adapt S1 – Extra Large');
        INSERT materialGroup;
        
        //Non-commercial schema
        List<csoe__Non_Commercial_Schema__c> nonCommercialSchemaList = new List<csoe__Non_Commercial_Schema__c>();
                

        //Maintenance non-commercial schema
        csoe__Non_Commercial_Schema__c maintenanceSchema = new csoe__Non_Commercial_Schema__c(Name = 'Maintenance', 
                                                                                              csoe__Schema__c = '{"name": "maintenance", "description": "maintenance",'+
                                                                                                                '"attributes": [{ "showInUI": false,"required": false,"type": "String","name": "Name"}]}'
                                                                                            );
                                                                                          
        nonCommercialSchemaList.add(maintenanceSchema);


        //License non-commercial schema
        csoe__Non_Commercial_Schema__c licenseSchema = new csoe__Non_Commercial_Schema__c(Name = 'License', 
                                                                                          csoe__Schema__c = '{"name": "License", "description": "License",'+
                                                                                                            '"attributes": [{"showInUI": false,"required": false,"type": "String","name": "Name"},'+
                                                                                                                           '{"showInUI": false,"required": false,"type": "String","name": "cspmb__code"}]}');
        nonCommercialSchemaList.add(licenseSchema);
        
        INSERT nonCommercialSchemaList;
        
        List<cspmb__Material__c> materialList = new List<cspmb__Material__c>();
        
        //Maintenance
        cspmb__Material__c maintenanceMaterial = new cspmb__Material__c(Name = 'VeloCloud 680 Maintenance', 
                                                                        Non_Commercial_Schema__c = maintenanceSchema.Id,  
                                                                        cspmb__code__c = 'VC-EDG-NDD-680-UPG-12P');
        materialList.add(maintenanceMaterial);

        //License
        cspmb__Material__c licenseMaterial = new cspmb__Material__c(Name = 'VeloCloud 2G Enterprise License', 
                                                                    Non_Commercial_Schema__c = licenseSchema.Id, 
                                                                    cspmb__code__c = 'VC-EDG-NDD-680-UPG-12P');
        materialList.add(licenseMaterial);
        
        INSERT materialList;
        
        List<cspmb__Material_Group_Material_Association__c> materialGrpMaterialAssociationList = new List<cspmb__Material_Group_Material_Association__c>();
        
        for(cspmb__Material__c materialRec :materialList){
            
            cspmb__Material_Group_Material_Association__c materialGrpMaterialAssociation;
            materialGrpMaterialAssociation = new cspmb__Material_Group_Material_Association__c(cspmb__material__c = materialRec.Id, 
                                                                                               cspmb__material_group__c = materialGroup.Id);
            
            materialGrpMaterialAssociationList.add(materialGrpMaterialAssociation);
        }
        
         
            
        INSERT materialGrpMaterialAssociationList;
        
        cspmb__Commercial_Product_Material_Group_Assoc__c commercialProdMaterialGroupAssociation; 
        commercialProdMaterialGroupAssociation = new cspmb__Commercial_Product_Material_Group_Assoc__c(cspmb__commercial_product__c = commercialProduct.Id,     
                                                                                                       cspmb__material_group__c = materialGroup.Id);
        
        INSERT commercialProdMaterialGroupAssociation;
    }
    
    
    @isTest
    static void getMaterialGroupsTest(){
        
        RateMatrixForSDWANController.Response response;
        Map<String,String> columnHeaderToValueMap;
        
        Test.startTest();
        
            cspmb__Price_Item__c commercialProduct = [SELECT Id, Name FROM cspmb__Price_Item__c LIMIT 1];
            
            //negative testting by passing null;
            response = RateMatrixForSDWANController.getMaterialGroups(null);
            
            
            //positive testing
            response = RateMatrixForSDWANController.getMaterialGroups(commercialProduct.Id);
            
            columnHeaderToValueMap = ( Map<String,String>)response.data;
            
            // TO increase the code coverage
            //new  RateMatrixForSDWANController.Response(false, 'To increase coverage');
            
        Test.stopTest();
        
        System.assertEquals(response.isSuccess, true);
        System.assertNotEquals(columnHeaderToValueMap.get('Maintenance'), 'VeloCloud 2G Enterprise License');
        System.assertEquals(columnHeaderToValueMap.get('License'), 'VeloCloud 2G Enterprise License');

    }
}