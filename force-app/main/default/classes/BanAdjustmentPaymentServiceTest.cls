/*************************************************************************************************
EDGE -104930
Name: BanAdjustmentPaymentServiceTest
Description: Test class for BanAdjustmentPaymentService
Author:Mahima 
***************************************************************************************************/
@IsTest
public class BanAdjustmentPaymentServiceTest {
    
    /**********************************
    EDGE-104930 
    Description: Success Test for getCreditAdjustListServiceTest
    Author: Mahima
    ************************************/
    @isTest
    static void getCreditAdjustListServiceTest()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new BANAdjustmentServiceMock(200));
        AdjustmentsResponseDTO responseDTO=BanAdjustmentPaymentService.getCreditAdjustListService('2019-01-01','2019-08-19', '7364723');
        system.assertEquals(responseDTO.adjustments.size()>0, true);
        test.stopTest();
    }
    
    /**********************************
    EDGE-104930 
    Description: Error Test for GetCreditAdjustListServiceTest
    Author: Mahima
    ************************************/
    @isTest
    static void getCreditAdjustListServiceTest2()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new BANAdjustmentServiceMock(422));
        AdjustmentsResponseDTO responseDTO=BanAdjustmentPaymentService.getCreditAdjustListService('2019-01-01','2019-08-19', '7364723');
        system.assertEquals(responseDTO.errors.size()>0, true);
        test.stopTest();
    }
    

}