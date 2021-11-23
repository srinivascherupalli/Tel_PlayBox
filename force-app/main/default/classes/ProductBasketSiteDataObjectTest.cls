/*
===============================================================================================================================
Class : ProductBasketSiteDataObjectTest
Developer Name : Rohit
Test Class : ProductBasketSiteDataObjectTest
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/

@isTest
private class ProductBasketSiteDataObjectTest {
  @isTest static void ProductBasketSiteDataObject(){
    ProductBasketSiteDataObject wrapper = new ProductBasketSiteDataObject();
    wrapper.pcrId= '222141258';
    wrapper.pcrName = 'CWP';
    wrapper.siteName = 'Mobile';
    wrapper.siteAddress = 'New';
    wrapper.adBorId = 'ABDC Test';
    wrapper.orderType= 'Pune';
	wrapper.locality= 'Pune';
	wrapper.state= 'Pune';
    system.assertNotEquals(wrapper, null);
  }
}