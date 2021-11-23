@isTest
public class MLECustomControllerTest {

    @isTest
    private static void getBasketData_WillReturnPDs_WhenThereIsNoScreenFlows() {
        Test.startTest();
        Account acc = AccountTestFactory.buildAccount('Test Name');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        Test.stopTest();

        MLECustomController.getBasketData(basket.id);
        System.assertEquals(1, ((Map<String, String>)MLECustomController.payload.get(MLECustomController.PDS)).size());
    }

    @isTest
    private static void getPorductDefinitionsForBasket_WillReturnEmpty_WhenBasketIsEmpty() {
        Test.startTest();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        insert basket;
        Test.stopTest();

        MLECustomController.getPorductDefinitionsForBasket(basket.id);
        System.assertEquals(0, MLECustomController.pdIdAndNameMap.size());
    }

    @isTest
    private static void getPorductDefinitionsForBasket_WillReturnProductData_WhenBasketIsNotEmpty() {
        Test.startTest();
        Account acc = AccountTestFactory.buildAccount('Test Name');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        Test.stopTest();

        MLECustomController.getPorductDefinitionsForBasket(basket.id);
        System.assertEquals(1, MLECustomController.pdIdAndNameMap.size());
    }

    @isTest
    private static void getScreenFlowsForProductDefinitions_WillReturnScreenFlowsForThePD_WhenSFsAreExists() {
        Test.startTest();
        Account acc = AccountTestFactory.buildAccount('Test Name');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        Test.stopTest();

        MLECustomController.getBasketData(basket.id);
        System.assertEquals(1, ((Map<String, String>)MLECustomController.payload.get(MLECustomController.PDS)).size());
        System.assertEquals(1, ((Map<String, List<ScreenFlowDTO>>)MLECustomController.payload.get(MLECustomController.SFS)).size());
        Map<String, List<ScreenFlowDTO>> sfMap = (Map<String, List<ScreenFlowDTO>>)MLECustomController.payload.get(MLECustomController.SFS);
        for(String kk :  sfMap.keySet()) {
            System.assertEquals(2, sfMap.get(kk).size());
        }
    }
}