@isTest
private class CS_SubscriptionDataMapperTest {
    
    private static testMethod void testSubscriptionDataMapperMethod() {     
    
    Account acc = new Account();
    acc.Name = 'TestAccount';
    acc.CIDN__C = '12345678';
    Insert acc;
    
    Contact con = new Contact();
    con.Accountid = acc.id;
    con.lastname = 'Test';
    con.Contact_Status__c = 'Active';
    con.Pref_Comm_Method__c = 'email';
    con.email = 'test@test.com';
    con.lastVerifiedDate__c = system.today();
    insert con;
    
    cscrm__Account_Contact_Relationship__c accCon = new cscrm__Account_Contact_Relationship__c();
    accCon.cscrm__Contact__c = con.id;
    accCon.cscrm__Account__c = acc.id;
    accCon.Site_Contact_Role__c = 'sales';
    accCon.cscrm__Active__c = true;
    accCon.Contact_Type__c = 'Full Authority';
    insert accCon;
    
    cscrm__Address__c addr = new cscrm__Address__c();
    addr.name = 'Test Address';
    insert addr;
    
    
    cscrm__Site__c site = new cscrm__Site__c();
    site.Name = 'Test Site';
    site.cscrm__Installation_Address__c = addr.id;
    site.cscrm__Account__c = acc.id;
    site.Status__c = 'Active';
    insert site;
    
    csord__Subscription__c subscription = new csord__Subscription__c();
    subscription.csord__Account__c = acc.id;
   
    //START :Changes for EDGE-106634
    subscription.csord__Status__c = 'Active';
    subscription.name = 'IP Site';
    //END :Changes for EDGE-106634
    subscription.Site__c = site.id;
    subscription.csord__Identification__c = 'Subscription_a3T2O0000009VyYUAU_0';
    insert subscription;
    
    csord__Service__c serv = new csord__Service__c();
    serv.Name = 'Test Service';
    serv.csord__Subscription__c = subscription.id;
    serv.csord__Status__c = 'Connected';
    serv.csord__Identification__c = 'test';
    insert serv;
     //START :Changes for EDGE-106634
    Attachment attK = new Attachment();
    attK.Body = Blob.valueOf('{"specifications":[{"version":"1"}]}');
    attK.Name = 'ServiceSpecifications.json';
    attK.ParentId = serv.Id;
    insert attK;
    //END :Changes for EDGE-106634
        
    List<CS_SubscriptionDataMapper.subscription> subscriptions_result = CS_SubscriptionDataMapper.getSubscriptions(acc.id, subscription.name, subscription.csord__Status__c);
    GetServicesResponse services_result = CS_SubscriptionDataMapper.getServicesForSubscription(subscription.id, '12345678');
    system.assert(subscriptions_result != null && services_result != null);
    }
}