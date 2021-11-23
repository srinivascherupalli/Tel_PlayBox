@isTest
public class ReplicatorLegacyAssetServiceTest {
    
    @testSetup static void setup() {
        ProductTestService.getNewAccount('Test Account'); 
    }
    
    static testMethod void getCustomerSites_withoutErrorTest() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
            List<String> demo=new List<String>();
            demo.add('111');
            demo.add('1143');
            ReplicatorGetServiceDataObject getServiceDTO = ReplicatorLegacyAssetService.getCustomerServices('1234', demo);
            System.debug('GetServiceDTO: ' + getServiceDTO);
            
            System.assert(getServiceDTO != null, 'Error occured during getService callout');
            System.assertEquals(getServiceDTO.CIDN, '1234');
            System.assertEquals(getServiceDTO.Site.get(0).ADBOR_Id, '111', 'Error, incorrect AdBoR Id');
            System.assertEquals(getServiceDTO.Site.get(1).ADBOR_Id, '1143', 'Error, incorrect AdBoR Id');
            
            //Product 
            System.assert(getServiceDTO.Site.get(0).productList != null, 'Error, response do not contain any products');
            List<ReplicatorGetServiceDataObject.ProductDTO> productList = new List<ReplicatorGetServiceDataObject.ProductDTO>(getServiceDTO.Site.get(0).productList);
            System.assertEquals(productList.size(), 1, 'Error, unexpected number of products in the response');
            ReplicatorGetServiceDataObject.ProductDTO product = productList.get(0);
            
            System.assertEquals(product.Product_Type, 'Business Essentials', 'Error, incorrect Product Type');
            System.assertEquals(product.Business_Owner, 'Business', 'Error, incorrect Business_Owner');
                      
            //Product Discount
            System.assert(product.discount != null, 'Error, response Product record missing discounts');
            List<ReplicatorGetServiceDataObject.DiscountDTO> prodDiscountList = new List<ReplicatorGetServiceDataObject.DiscountDTO>(product.discount);
            System.assertEquals(prodDiscountList.size(), 2, 'Error, unexpected number of discounts in the response Product');
            
            ReplicatorGetServiceDataObject.DiscountDTO prodDiscount = prodDiscountList.get(0);
            System.assertEquals(prodDiscount.Discount_Name, '', 'Error, incorrect Discount Name for Product Discount');
            System.assertEquals(prodDiscount.Discount_Term, '', 'Error, incorrect Discount Term for Product Discount');
            
            //Product Service 
            System.assert(product.service != null, 'Error, response Product record missing services');
            List<ReplicatorGetServiceDataObject.ServiceDTO> prodServiceList = new List<ReplicatorGetServiceDataObject.ServiceDTO>(product.service);
            System.assertEquals(2, prodServiceList.size(), 'Error, unexpected number of services in the response Product');
            
            ReplicatorGetServiceDataObject.ServiceDTO srvDTO= new ReplicatorGetServiceDataObject.ServiceDTO();
            for(ReplicatorGetServiceDataObject.ServiceDTO svDTO: prodServiceList) {
               /* if(svDTO.Service_Id.equals('233424')) {
                    srvDTO = svDTO;
                }*/
                if(('233424').equals(svDTO.Service_Id)){
                    srvDTO = svDTO;
                }
            }
            
            System.assertEquals(srvDTO.Bundle_Role, 'Linked', 'Error, unexpected Bundle_Role value in the Product Service record');
            
            //Service planCharacteristic
            List<ReplicatorGetServiceDataObject.PlanCharacteristicDTO> planDTOList = new List<ReplicatorGetServiceDataObject.PlanCharacteristicDTO>(srvDTO.planCharacteristic); 
            System.assertEquals(planDTOList.size(), 2, 'Error, Unexpected number of plans in the response Service');
                        
            
            //Product 
            System.assert(getServiceDTO.Site.get(1).productList != null, 'Error, response do not contain any products');
            List<ReplicatorGetServiceDataObject.ProductDTO> productList1 = new List<ReplicatorGetServiceDataObject.ProductDTO>(getServiceDTO.Site.get(1).productList);
            System.assertEquals(productList1.size(), 1, 'Error, unexpected number of products in the response');
            ReplicatorGetServiceDataObject.ProductDTO product1 = productList1.get(0);
            
            System.assertEquals(product1.Product_Type, 'PSTN', 'Error, incorrect Product Type');
            System.assertEquals(product1.Business_Owner, 'Business', 'Error, incorrect Enterprise Id');
                      
            //Product Discount
            System.assert(product1.discount != null, 'Error, response Product record missing discounts');
            List<ReplicatorGetServiceDataObject.DiscountDTO> prodDiscountList1 = new List<ReplicatorGetServiceDataObject.DiscountDTO>(product1.discount);
            System.assertEquals(prodDiscountList1.size(), 2, 'Error, unexpected number of discounts in the response Product');
            
            ReplicatorGetServiceDataObject.DiscountDTO prodDiscount1 = prodDiscountList1.get(0);
            System.assertEquals(prodDiscount1.Discount_Name, '', 'Error, incorrect Discount Name for Product Discount');
            System.assertEquals(prodDiscount1.Discount_Term, '', 'Error, incorrect Discount Term for Product Discount');
            
            //Product Service 
            System.assert(product1.service != null, 'Error, response Product record missing services');
            List<ReplicatorGetServiceDataObject.ServiceDTO> prodServiceList1 = new List<ReplicatorGetServiceDataObject.ServiceDTO>(product1.service);
            System.debug('prodServiceList1 : '+prodServiceList1);
            System.assertEquals(2, prodServiceList1.size(), 'Error, unexpected number of services in the response Product');
            
            ReplicatorGetServiceDataObject.ServiceDTO srvDTO1=new ReplicatorGetServiceDataObject.ServiceDTO();
            for(ReplicatorGetServiceDataObject.ServiceDTO svDTO1: prodServiceList1) {
                /*if(svDTO1.Service_Id.equals('555424')) {
                    srvDTO1 = svDTO1;
                }*/
                if(('555424').equals(svDTO1.Service_Id)){
                    srvDTO1 = svDTO1;
                }
            }
            
            System.assertEquals(srvDTO1.Bundle_Role, 'Linked', 'Error, unexpected Bundle_Role value in the Product Service record');
            
            //Service planCharacteristic
            List<ReplicatorGetServiceDataObject.PlanCharacteristicDTO> planDTOList1 = new List<ReplicatorGetServiceDataObject.PlanCharacteristicDTO>(srvDTO1.planCharacteristic); 
            System.assertEquals(planDTOList1.size(), 2, 'Error, Unexpected number of plans in the response Service');
            
        Test.stopTest();
    }
    
    /*static testMethod void getCustomerSites_withServiceExtension() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
            List<String> demo=new List<String>();
            demo.add('111');
            demo.add('1143');
            
            ReplicatorGetServiceDataObject getServiceDTO = ReplicatorLegacyAssetService.getCustomerServices('1234', demo);
            System.debug('GetServiceDTO: ' + getServiceDTO);
            
            System.assert(getServiceDTO != null, 'Error occured during getService callout');
            System.assertEquals(getServiceDTO.CIDN, '1234');
        
            
            System.assertEquals(getServiceDTO.Site.get(0).ADBOR_Id, '111', 'Error, incorrect AdBoR Id');
            System.assertEquals(getServiceDTO.Site.get(1).ADBOR_Id, '1143', 'Error, incorrect AdBoR Id');
            //Product 
            System.assert(getServiceDTO.Site.get(0).productList != null, 'Error, response do not contain any products');
            List<ReplicatorGetServiceDataObject.ProductDTO> productList = new List<ReplicatorGetServiceDataObject.ProductDTO>(getServiceDTO.Site.get(0).productList);
            System.assertEquals(productList.size(), 1, 'Error, unexpected number of products in the response');
            ReplicatorGetServiceDataObject.ProductDTO product = productList.get(0);
            
            System.assertEquals(product.Product_Type, 'Business Essentials', 'Error, incorrect Product Type');
            System.assertEquals(product.Business_Owner, 'Business', 'Error, incorrect Enterprise Id');
                      
            //Product Discount
            System.assert(product.discount != null, 'Error, response Product record missing discounts');
            List<ReplicatorGetServiceDataObject.DiscountDTO> prodDiscountList = new List<ReplicatorGetServiceDataObject.DiscountDTO>(product.discount);
            System.assertEquals(prodDiscountList.size(), 2, 'Error, unexpected number of discounts in the response Product');
            
            ReplicatorGetServiceDataObject.DiscountDTO prodDiscount = prodDiscountList.get(0);
            System.assertEquals(prodDiscount.Discount_Name, '', 'Error, incorrect Discount Name for Product Discount');
            System.assertEquals(prodDiscount.Discount_Term, '', 'Error, incorrect Discount Term for Product Discount');
            
            //Product Service 
            System.assert(product.service != null, 'Error, response Product record missing services');
            List<ReplicatorGetServiceDataObject.ServiceDTO> prodServiceList = new List<ReplicatorGetServiceDataObject.ServiceDTO>(product.service);
            System.assertEquals(2, prodServiceList.size(), 'Error, unexpected number of services in the response Product');

            List<String> expectedServiceIds = new List<String>{'233424','543433'};            
            List<String> serviceIds = new List<String>();
            for (ReplicatorGetServiceDataObject.ServiceDTO srvDTO : prodServiceList) {
                serviceIds.add(srvDTO.Service_Id);
            }
            System.debug('ServiceIds: ' + serviceIds);
            System.assert(expectedServiceIds.equals(serviceIds), 'Error, Incorrect list of service Ids');
            
            
            //Product 
            System.assert(getServiceDTO.Site.get(1).productList != null, 'Error, response do not contain any products');
            List<ReplicatorGetServiceDataObject.ProductDTO> productList1 = new List<ReplicatorGetServiceDataObject.ProductDTO>(getServiceDTO.Site.get(1).productList);
            System.assertEquals(productList1.size(), 1, 'Error, unexpected number of products in the response');
            ReplicatorGetServiceDataObject.ProductDTO product1 = productList1.get(0);
            
            System.assertEquals(product1.Product_Type, 'PSTN', 'Error, incorrect Product Type');
            System.assertEquals(product1.Business_Owner, 'Business', 'Error, incorrect Enterprise Id');
                      
            //Product Discount
            System.assert(product1.discount != null, 'Error, response Product record missing discounts');
            List<ReplicatorGetServiceDataObject.DiscountDTO> prodDiscountList1 = new List<ReplicatorGetServiceDataObject.DiscountDTO>(product1.discount);
            System.assertEquals(prodDiscountList1.size(), 2, 'Error, unexpected number of discounts in the response Product');
            
            ReplicatorGetServiceDataObject.DiscountDTO prodDiscount1 = prodDiscountList1.get(0);
            System.assertEquals(prodDiscount1.Discount_Name, '', 'Error, incorrect Discount Name for Product Discount');
            System.assertEquals(prodDiscount1.Discount_Term, '', 'Error, incorrect Discount Term for Product Discount');
            
            //Product Service 
            System.assert(product1.service != null, 'Error, response Product record missing services');
            List<ReplicatorGetServiceDataObject.ServiceDTO> prodServiceList1 = new List<ReplicatorGetServiceDataObject.ServiceDTO>(product1.service);
            System.debug('prodServiceList1: ' + prodServiceList1);
            System.assertEquals(2, prodServiceList1.size(), 'Error, unexpected number of services in the response Product');

            List<String> expectedServiceIds1 = new List<String>{'555424','0399000011','550','551'};            
            List<String> serviceIds1 = new List<String>();
            for (ReplicatorGetServiceDataObject.ServiceDTO srvDTO1 : prodServiceList1) {
                serviceIds1.add(srvDTO1.Service_Id);
            }
            System.debug('ServiceIds: ' + serviceIds1);
            System.assert(expectedServiceIds1.equals(serviceIds1), 'Error, Incorrect list of service Ids');
        Test.stopTest();    
    }*/
   
    static testMethod void getCustomerServices_withErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        List<String> demo=new List<String>();
            demo.add('111');
            demo.add('1143');
            ReplicatorGetServiceDataObject getServiceDTO  = ReplicatorLegacyAssetService.getCustomerServices('errorId', demo);
            System.debug('GetServiceDTO: ' + getServiceDTO);
            System.assert(getServiceDTO != null, 'Error occured during getService callout');
            System.assertEquals(getServiceDTO.Site.get(0).error_description, Label.Replicator_Technical_Error_Message, 'Error, unexpected error description');
        Test.stopTest();
    }
    
    static testMethod void getCustomerServices_with404ErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        List<String> demo=new List<String>();
            demo.add('111');
            demo.add('1143');
            ReplicatorGetServiceDataObject getServiceDTO = ReplicatorLegacyAssetService.getCustomerServices('errorId'+ IntegrationRecordHandlerUtil.ERROR_404_CODE, demo);
            System.debug('GetServiceDTO: ' + getServiceDTO);
            System.assert(getServiceDTO != null, 'Error occured during getService callout');
            System.assertEquals(getServiceDTO.Site.get(0).Error_Code, String.valueOf(IntegrationRecordHandlerUtil.ERROR_404_CODE), 'Error, unexpected error code');
        Test.stopTest();
    }
    
    static testMethod void getCustomerServices_with500ErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        List<String> demo=new List<String>();
            demo.add('111');
            demo.add('1143');
            ReplicatorGetServiceDataObject getServiceDTO = ReplicatorLegacyAssetService.getCustomerServices('errorId'+ IntegrationRecordHandlerUtil.ERROR_500_CODE, demo);
            System.debug('GetServiceDTO: ' + getServiceDTO);
            System.assert(getServiceDTO != null, 'Error occured during getService callout');
            System.assertEquals(getServiceDTO.Site.get(0).Error_Code, String.valueOf(IntegrationRecordHandlerUtil.ERROR_500_CODE), 'Error, unexpected error code');
        Test.stopTest();
    }

    static testMethod void getCustomerServices_with503ErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
        List<String> demo=new List<String>();
            demo.add('111');
            demo.add('1143');
            ReplicatorGetServiceDataObject getServiceDTO = ReplicatorLegacyAssetService.getCustomerServices('errorId'+ IntegrationRecordHandlerUtil.ERROR_503_CODE, demo);
            System.debug('GetServiceDTO: ' + getServiceDTO);
            System.assert(getServiceDTO != null, 'Error occured during getService callout');
            System.assertEquals(getServiceDTO.Site.get(0).Error_Code, String.valueOf(IntegrationRecordHandlerUtil.ERROR_503_CODE), 'Error, unexpected error code');
        Test.stopTest();
    }     
}