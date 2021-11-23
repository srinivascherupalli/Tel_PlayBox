/*
===============================================================================================================================
Class : ReactivateServiceWrapperTest
Developer Name : shubhi
EDGE-185011
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1.        shubhi              26.11.2020        EDGE-185011(new)
===============================================================================================================================
*/
@isTest
private class ReactivateServiceWrapperTest {
  @isTest static void testReactivateServiceWrapper(){
    ReactivateServiceWrapper wrapper = new ReactivateServiceWrapper();
    wrapper.serviceNumber = '1234567';
    wrapper.subscriptionName = 'test';
    wrapper.subscriptionNumber = null;
    wrapper.disconnectedDate = date.today();
    wrapper.AddonDescription = '';
    //wrapper.AddonOption = '';
    wrapper.id = 'test';
    List<ReactivateServiceWrapper> addondetails=new List<ReactivateServiceWrapper>();
    ReactivateServiceWrapper childwrapper = new ReactivateServiceWrapper();
    childwrapper.AddonDescription ='IDD';
    addondetails.add(childwrapper);
    wrapper.addondetails=new List<ReactivateServiceWrapper>();
    addondetails.addAll(addondetails);
    system.assertEquals(wrapper.serviceNumber, '1234567');
  }
}