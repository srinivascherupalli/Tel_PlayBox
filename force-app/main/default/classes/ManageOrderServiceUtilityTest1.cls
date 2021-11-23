@isTest
public class ManageOrderServiceUtilityTest1 {

  @testsetup public static void dataSetup(){
        ManageOrderTestDataSetup.testdataSetup();
  }

 
    
   @isTest
  static void test_UCE(){
    Test.startTest();
      Map<Id, List<Id>> orderToReplacedSubscriptionsMap = new Map<Id, List<Id>>();
    List<csord__Order__c> orders = [SELECT Id from csord__Order__c];
    List<Id> orderIds = new List<Id>();
    for(csord__Order__c ord: orders){
      orderIds.add(ord.Id);
        
    }
     
      
    Map<Id, csord__Service__c> srvcMap = new Map<Id, csord__Service__c>();
    Map<Id, csord__Order__c> subOrderMap = ManageOrderServiceHelper.fetchAllOrders(orderIds);
    srvcMap = ManageOrderServiceHelper.getOderDetails(new List<Id>(subOrderMap.keySet()),orderToReplacedSubscriptionsMap);
    Test.stopTest();

    
    //decompose svcMap into individual component maps
    Map<Id, ManageOrderServiceUtility.AccountData> accountsMap = new Map<Id, ManageOrderServiceUtility.AccountData>();
    Map<Id, ManageOrderServiceUtility.OrderData> ordersMap = new Map<Id, ManageOrderServiceUtility.OrderData>();
    Map<Id, List<ManageOrderServicesDTO>> servicesMap = new Map<Id, List<ManageOrderServicesDTO>>();
    Map<Id, Map<Id, List<ManageOrderDataObject.PlaceDataObject>>> orderSitesMap = new Map<Id, Map<Id, List<ManageOrderDataObject.PlaceDataObject>>> ();
    Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> cfsMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();

    accountsMap     = ManageOrderServiceUtility.getAccountData(subOrderMap);
    ordersMap       = ManageOrderServiceUtility.getOrderData(subOrderMap);
    servicesMap     = ManageOrderServiceUtility.getServiceData(srvcMap);
    cfsMap          = ManageOrderServiceHelper.getOrderSpecs(subOrderMap,orderToReplacedSubscriptionsMap);
    orderSitesMap   = ManageOrderServiceUtility.getSitesData(srvcMap, servicesMap);
    //map CS & SFDC data into ManageOrder DTO
    
    ManageOrderDataObject.ProductOrder orderDTO = new ManageOrderDataObject.ProductOrder();
    ManageOrderServiceUtility.putOrderData(orderIds[0], orderDTO, ordersMap);
    ManageOrderServiceUtility.putAccountData(orderIds[0], orderDTO, accountsMap);
    Map<String,String> serviceCancelDateMap = ManageOrderServiceUtilityHelper.getRequestedServiceCancellationDate(orderIds);  
    Map<String, Contact> serviceDeliveryContactMap = ManageOrderServiceUtilityHelper.getDeliveryContactsForMobility(orderIds);
    String tranSientJSONStr = ' { "dataDTOList": [{"specGUID":"b5e53e03-1209-7828-546b-fc490a07c002","specCode":"DMCAT_ProductSpecification_000263_Fulfilment","offerID":"DMCAT_Offer_000303","changeType":"New","attributes":[{"value":"false","name":"INTROAM"},{"value":"NO_PREMIUM","name":"CALLRESTRICTION"}]}] }';
        Map<String,Map<String,String>> guidToTransientAttributesMap = ManageOrderServiceUtilityHelper.getTransientAttributesMap(tranSientJSONStr);
        ManageOrderServiceUtility.putServiceData(serviceCancelDateMap,ordersMap.get(orderIds[0]), orderDTO, servicesMap.get(orderIds[0]), cfsMap.get(orderIds[0]), orderSitesMap.get(orderIds[0]),serviceDeliveryContactMap,guidToTransientAttributesMap);
        
    System.assertNotEquals(orderDTO.externalId, null);
    System.assertEquals(orderDTO.version, 1);
    //assert account
    System.assertEquals(orderDTO.relatedParty[0].type, 'Competitor');
    System.assertEquals(orderDTO.relatedParty[0].name, 'test Account');
    System.assertEquals(orderDTO.relatedParty[0].role, 'customer');
    System.assertEquals(orderDTO.relatedParty[0].Id, 'CIDN1234');
    //assert order item/products
    if(orderDTO.orderItem.size() > 0){
        System.assertEquals(orderDTO.orderItem[0].id.split('\\|')[1], (servicesMap.get(orderIds[0]))[0].svcNumber);
        System.assertEquals(orderDTO.orderItem[0].version, 1);
        System.assertEquals(orderDTO.orderItem[0].requestedCompletionDate, null);
        System.assertEquals(orderDTO.orderItem[0].action, 'Create');
        //System.assertEquals(orderDTO.orderItem[0].Product.id, 'ef2af0e2-e668-a8e5-e889-ddc868fdbc11');
        System.assertEquals(orderDTO.orderItem[0].Product.action, 'add');
        //assert sites/contact
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].role, 'Installation');
        System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.street1, 'tst service');
        System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.id, null);
        //System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.href, '');
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.type, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.street1, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.street2, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.city, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.stateOrProvince, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.postCode, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.country, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.room, null);
        System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.apartment, null);
        System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].address.floor, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.buildingName, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetType, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetName, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetNr, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.streetSuffix, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.locality, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.town, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].address.county, null);
        System.assertNotEquals(orderDTO.orderItem[0].Product.place[0], null);
        /*System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].name, null);
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].type, 'Full Authority');
        System.assertEquals(orderDTO.orderItem[0].Product.place[0].contact[0].gender, null);
        System.assertNotEquals(orderDTO.orderItem[0].Product.place[0].contact[0].contactmedium[0], null);*/
    }
  }  
   
    
    
}