@isTest
public class CS_ServiceSpecificationV3Test {
    @isTest 
    static void test1(){
        CS_ServiceSpecificationV3 a = new CS_ServiceSpecificationV3();
        a.serviceId = 'test';
        a.specifications = new List<CS_ServiceSpecificationV3.ServiceSpecifications>();
        CS_ServiceSpecificationV3.ServiceSpecifications ss = new CS_ServiceSpecificationV3.ServiceSpecifications();
        ss.guid = 'test';
        ss.code = 'test';
         ss.productConfigurationId = 'test';//Added As part of EDGE-204030
         a.specifications.add(ss);
        System.assertEquals(a.specifications[0].guid, 'test');
    }
}