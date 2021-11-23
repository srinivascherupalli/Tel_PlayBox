/*
===============================================================================================================================
Class : TransitionReviewConfirmWrapperTest
Developer Name : Rohit
Test Class : TransitionReviewConfirmWrapperTest
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

=============================================================================================================================== 
*/

@isTest
private class TransitionReviewConfirmWrapperTest {
  @isTest static void testTransitionReviewConfirmWrapper(){
    TransitionReviewConfirmWrapper wrapper = new TransitionReviewConfirmWrapper();
    wrapper.siteId = '222141258';
    wrapper.offer = 'CWP';
    wrapper.legacyTechnology = 'Mobile';
    wrapper.orderType = 'New';
    wrapper.siteName = 'ABDC Test';
    wrapper.locality = 'Pune';
    wrapper.fNN = 'test';
    wrapper.state = 'test';
    system.assertNotEquals(wrapper, null);
  }
}