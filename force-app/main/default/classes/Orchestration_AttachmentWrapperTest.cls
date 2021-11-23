@isTest
public class Orchestration_AttachmentWrapperTest {
    @isTest
    static void testWrapper() {
        List<account> accountList = Orchestration_TestUtility.buildAccount(true, 1);
        List<csord__Order_Request__c> orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        List<csord__Order__c> orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true, 2);
        list<cscfga__Product_Configuration__c> productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
        list<csord__Solution__c> solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        List<csord__Subscription__c> subscriptionList = Orchestration_TestUtility.buildSubscription(true, 1, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        List<csord__Service__c> servlist = Orchestration_TestUtility.buildService(true, 1, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        Attachment attch = new Attachment();
        attch.body = Blob.valueOf(
            '{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-2911-eb71-8e13-bd04b7f9824a","additionalAttributes" : {"ServiceId" : "61402022091","IPWirelessProductInstanceID" : "9127db1b-b9f7-4b69-d55b-f856689c1b7e"},"endDate":"","description":"CWP CFS Specification","code":"DMCAT_ProductSpecification_000263","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"' +
            '","legacyAttributes":[]}'
        );
        attch.parentId = servlist[0].Id;
        attch.name = 'testing';

        insert attch;

        Test.startTest();

        Orchestration_AttachmentWrapper response = new Orchestration_AttachmentWrapper(attch.Id, attch.body);
        response = new Orchestration_AttachmentWrapper(attch.Id, attch.Name, attch.body, attch.parentId);
        response = new Orchestration_AttachmentWrapper(attch.Id, attch.Name, attch.body);

        System.assert(response != null);
        Test.stopTest();
    }
}