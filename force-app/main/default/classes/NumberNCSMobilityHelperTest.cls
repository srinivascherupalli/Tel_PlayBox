@isTest
public class NumberNCSMobilityHelperTest {
    @isTest
    public static void unittest_1(){
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000323';
        prodDef.cscfga__Active__c = true;
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        csoe__Non_Commercial_Schema__c cnse = new csoe__Non_Commercial_Schema__c();
        cnse.name = 'MobileNumberManagementv1';
        insert cnse;
        Attachment attachment = new Attachment();
        String encodedContentsString ='{"schema":{"attributes": [{ "showInUI": true, "required": false, "type": "String", "name": "MobileNumber" },{ "showInUI": true, "required": false, "type": "String", "name": "Status" },{ "showInUI": true, "required": false, "type": "String", "name": "listCode" }],"name": "MobileNumberManagementv1","description": "Mobile numbers"},"configurations":[{"guid":"4b31c4a1-d554-dec6-dfb0-b898ebf8cbf8","MobileNumber":"7282345560","Status":"RESERVED","listCode":"No Entry Line"},{"guid":"2ce0e784-c297-a502-07fa-2655664001f4","MobileNumber":"9282345560","Status":"UNRESERVED","listCode":"No Entry Line"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        attachment.Name = String.valueOf('MobileNumberManagementv1_schema.json');
        attachment.ParentId = config.Id; 
        insert attachment;
        List<NumberNCSMobilityDTO.Configuration> numberList = new List<NumberNCSMobilityDTO.Configuration>();
        NumberNCSMobilityDTO ncsdt=  NumberNCSMobilityDTO.parse(encodedContentsString);
        System.debug(ncsdt);
        numberList.addAll(ncsdt.configurations);
        List<String> deleteList = new List<String>();
        deleteList.add('7282345560');
        deleteList.add('9282345560');
        NumberNCSMobilityHelper ncsHelp = new NumberNCSMobilityHelper();
        ncsHelp.checkForExistingNCS(config.Id,'MobileNumberManagementv1_schema.json');
        ncsHelp.getNumbersFromNCS(config.Id);
        ncsHelp.updateExistingNCS(config.Id,'MobileNumberManagementv1',numberList);
        ncsHelp.createNewNCS(config.Id, 'MobileNumberManagementv1',numberList);
        ncsHelp.getTotalCountOfNumbers(config.Id);
        ncsHelp.populateConfigListToUpsert(numberList);
        ncsHelp.updateNCSForStatus(config.Id);
        ncshelp.updateExistingNCS(config.Id,'MobileNumberManagementv1',numberList,cnse);
        ncsHelp.createNewNCS(config.Id, 'MobileNumberManagementv1',numberList,cnse);
        ncsHelp.deleteExistingNCS(config.Id,'MobileNumberManagementv1',deleteList);
        System.assertEquals(ncsHelp.updateExistingNCS(config.Id,'MobileNumberManagementv1',numberList),'Success');
    }
    @isTest
    public static void testException(){
        NumberNCSMobilityHelper ncs = new NumberNCSMobilityHelper();
        ncs.checkForExistingNCS('a5O2O000000EOY5PO198',NULL);
        ncs.populateConfigListToUpsert(NULL);
        ncs.fetchNCSInstance('Mobile');
        System.assertNotEquals(ncs, NULL);
    }
}