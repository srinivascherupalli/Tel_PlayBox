@isTest
public class OrderMergeTest {
        static testMethod void singleOrderTest() {
        //Create Account
        Account acc = ProductTestService.getNewAccount('CWPAccount');
        
        //Create Orders
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        csord__Order__c order1 = ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c order2 = ProductTestService.getNewOrderForAccount(acc);
        order2.csord__Primary_Order__c = order1.id;
        csord__Order__c order3 = ProductTestService.getNewOrderForAccount(acc);
        order3.csord__Primary_Order__c = order1.id;
        orderList.add(order1);orderList.add(order2);orderList.add(order3);
        update orderList;
        
        //Create Subscriptions
        List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('Sub', acc.id, orderList[0].id, orderList[0].csord__Order_Request__c);
        csord__Subscription__c subs1 = ProductTestFactory.buildSubscription('Sub1', acc.id, orderList[0].id, orderList[0].csord__Order_Request__c);
        csord__Subscription__c subs2 = ProductTestFactory.buildSubscription('Sub2', acc.id, orderList[1].id, orderList[1].csord__Order_Request__c);
        csord__Subscription__c subs3 = ProductTestFactory.buildSubscription('Sub3', acc.id, orderList[2].id, orderList[2].csord__Order_Request__c);
        subList.add(subs);subList.add(subs1);subList.add(subs2);subList.add(subs3);
        insert subList;
        
        //Create services
        List<csord__Service__c> serList = new List<csord__Service__c>();
        csord__Service__c ser1 = ProductTestFactory.buildService('ser1', orderList[0].id, subList[0].id, orderList[0].csord__Order_Request__c);
        csord__Service__c ser2 = ProductTestFactory.buildService('ser2', orderList[0].id, subList[1].id, orderList[0].csord__Order_Request__c);
        csord__Service__c ser3 = ProductTestFactory.buildService('ser3', orderList[1].id, subList[2].id, orderList[1].csord__Order_Request__c);
        csord__Service__c ser4 = ProductTestFactory.buildService('ser4', orderList[1].id, subList[2].id, orderList[1].csord__Order_Request__c);
        csord__Service__c ser5 = ProductTestFactory.buildService('ser5', orderList[2].id, subList[3].id, orderList[2].csord__Order_Request__c);
        csord__Service__c ser6 = ProductTestFactory.buildService('ser6', orderList[2].id, subList[3].id, orderList[2].csord__Order_Request__c);
        serList.add(ser1);serList.add(ser2);serList.add(ser3);serList.add(ser4);serList.add(ser5);serList.add(ser6);
        insert serList;
        
        Test.startTest();
        List<Id> idList= new List<ID>{orderList[0].id,orderList[1].id,orderList[2].id};
        OrderMerge.singleOrder(idList); 
        Test.stopTest();
        List<csord__Order__c> ordrList=[Select id from csord__Order__c where id=:order1.id];
        System.assertEquals(order1.id, idList[0]);
                
    }
}