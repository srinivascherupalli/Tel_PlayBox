/*
===============================================================================================================================
Class : ShowSubscriptionsOnMACButtonController
Developer Name : SubWrapper
Test Class : ShowSubscriptionsOnMACButtonControllerrTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1.        Shubhi Vijayvergia  21/3/2018     Edge-53882 MAC page for Sim Replacement for Assurance service agent Profile
===============================================================================================================================
*/
@isTest
private class SubWrapperTest {
    @isTest static void testSubWrapper(){
        SubWrapper wrapper = new SubWrapper();
        wrapper.SubscriptionID = null;
        wrapper.subscriptionName = 'test';
        wrapper.SiteID = null;
        wrapper.siteAddress = 'test';
        wrapper.subscriptionNumber = 'test';
        wrapper.status = 'test';
        wrapper.createdBy = 'test';
        wrapper.disableRow = true;
        wrapper.createdDate = 'test';
        wrapper.totalRC = 'test';
        wrapper.totalOC = 'test';
        wrapper.isCWP = true;
        wrapper.ServiceId=null;
        wrapper.accessType=null;
        wrapper.productDefinitionName='Mobility';
        wrapper.SimDispatchedRequired=true;
        wrapper.DeliveryContact='DeliveryContact';
        wrapper.DeliveryAddress='DeliveryAddress';
        wrapper.DeliveryContactID='1234567890';
        wrapper.DeliveryAddressID='1234567890';
        wrapper.SimSerialNumber='SimSerialNumber';
        wrapper.IsSimSerialNumber = true;
        wrapper.IsDeliveryDetailsDisabled = true;
        wrapper.isBillStopped=false;
        wrapper.suspensionReason='NA';
        wrapper.billingAccount='BA-456892';
        wrapper.MarketOffer='NA';
        wrapper.ExistingSIMType=''; //EDGE-165020
        wrapper.RequestedSIMType='';//EDGE-165020  
        wrapper.ProductOffer=''; //EDGE-165020
        wrapper.firstActivationDate=''; //EDGE-205597
        wrapper.totalRCVal=0.0; //EDGE-205598
        wrapper.createdDateVal=System.now(); //EDGE-205598  
        wrapper.serviceNumber='testService'; //DIGI-13386
        system.assertNotEquals(wrapper, null);
    }
}