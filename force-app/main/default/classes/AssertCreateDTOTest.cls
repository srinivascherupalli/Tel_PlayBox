/********************************************************
Class Name      :   AssertCreateDTOTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Shubhi     			  10/10/2019    Test class fixes for qa1 and qa2

**********************************************************
*/

@isTest
public class AssertCreateDTOTest {
    
    @isTest static void TestMethodDto()
    {
        AssetCreateDTO assetDTo=new AssetCreateDTO();
        assetDTo.accountID='Test1234';
        assetDTo.name='Test1234';
        assetDTo.specCode='Test1234';
        assetDTo.description='Test1234';
        assetDTo.SKU='Test1234';
        assetDTo.assetStatus='Test1234';
        assetDTo.serviceId='Test1234';
        assetDTo.subcriptionId='Test1234';
        assetDTo.offerId='Test1234';
        assetDTo.assetUUID='Test1234';
        assetDTo.ownership='Test1234';
        assetDTo.assetInstanceId='Test1234';  
		assetDTo.quantity=1;
        assetDTo.deviceQuantity=1;
        system.assert(assetDTo!=null);
    }
}