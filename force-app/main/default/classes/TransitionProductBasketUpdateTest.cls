@isTest
public class TransitionProductBasketUpdateTest {

 
     static testMethod void  testCWPProdBasCreation()
    {
        List<ReplicatorGetServiceDataObject.SiteDTO> getSiteDTO = new List<ReplicatorGetServiceDataObject.SiteDTO>();
        List<ReplicatorGetServiceDataObject.ProductDTO> productDTOList = new List<ReplicatorGetServiceDataObject.ProductDTO>();
        List<ReplicatorGetServiceDataObject.ProductDTO> productDTOList1 = new List<ReplicatorGetServiceDataObject.ProductDTO>();
        List<ReplicatorGetServiceDataObject.ServiceDTO> serviceList = new  List<ReplicatorGetServiceDataObject.ServiceDTO>();
        List<ReplicatorGetServiceDataObject.ServiceDTO> serviceList1 = new  List<ReplicatorGetServiceDataObject.ServiceDTO>();
        List<ReplicatorGetServiceDataObject.ServiceCharacteristicDTO> serviceCharList = new  List<ReplicatorGetServiceDataObject.ServiceCharacteristicDTO>();   
          List<ReplicatorGetServiceDataObject.ServiceRelationshipDTO> servicerelList = new  List<ReplicatorGetServiceDataObject.ServiceRelationshipDTO>();   
          	List<ReplicatorGetServiceDataObject.ServiceExtensionDTO> serviceextList = new  List<ReplicatorGetServiceDataObject.ServiceExtensionDTO>();   
                ReplicatorGetServiceDataObject.ServiceCharacteristicDTO schar = new ReplicatorGetServiceDataObject.ServiceCharacteristicDTO();
				schar.name = 'Zone';
				schar.value = '1';
				
				ReplicatorGetServiceDataObject.ServiceCharacteristicDTO schar1 = new ReplicatorGetServiceDataObject.ServiceCharacteristicDTO();
				schar1.name = 'Type';
				schar1.value = 'Fixed Seat';
				
				serviceCharList.add(schar);
				serviceCharList.add(schar1);
				
                ReplicatorGetServiceDataObject.ServiceExtensionDTO se= new ReplicatorGetServiceDataObject.ServiceExtensionDTO();
                se.Services_From = '003100';
                se.Services_To = '003149';
                serviceextList.add(se);
                ReplicatorGetServiceDataObject.ServiceExtensionDTO se1= new ReplicatorGetServiceDataObject.ServiceExtensionDTO();
                se1.Services_From = '003151';
                se1.Services_To = '003200';
                serviceextList.add(se1);
                ReplicatorGetServiceDataObject.ServiceExtensionDTO se2= new ReplicatorGetServiceDataObject.ServiceExtensionDTO();
                se2.Services_From = '003275';
                se2.Services_To = '003300';
                serviceextList.add(se2);
                
                ReplicatorGetServiceDataObject.ServiceRelationshipDTO sr = new ReplicatorGetServiceDataObject.ServiceRelationshipDTO();
                sr.serviceExtension = serviceextList;
                servicerelList.add(sr);
          
 				ReplicatorGetServiceDataObject.ServiceDTO  service1 = new ReplicatorGetServiceDataObject.ServiceDTO();
				service1.Service_Id = '003150';
                service1.serviceRelationship = servicerelList;
				service1.serviceCharacteristic = serviceCharList;
				ReplicatorGetServiceDataObject.ServiceDTO  service2 = new ReplicatorGetServiceDataObject.ServiceDTO();
				service2.Service_Id = '0031501';
				service2.serviceCharacteristic = serviceCharList;
				ReplicatorGetServiceDataObject.ServiceDTO  service3 = new ReplicatorGetServiceDataObject.ServiceDTO();
				service3.Service_Id = '0031502';
				service3.serviceCharacteristic = serviceCharList;
				ReplicatorGetServiceDataObject.ServiceDTO  service4 = new ReplicatorGetServiceDataObject.ServiceDTO();
				service4.Service_Id = '0031503';
				service4.serviceCharacteristic = serviceCharList;
			
				serviceList.add(service1);
				serviceList.add(service3);
				serviceList1.add(service2);
				serviceList1.add(service4);
          
            ReplicatorGetServiceDataObject.ProductDTO pd1 = new ReplicatorGetServiceDataObject.ProductDTO();
            ReplicatorGetServiceDataObject.ProductDTO pd2 = new ReplicatorGetServiceDataObject.ProductDTO();
          
            pd1.service = serviceList;
            pd1.Product_Type = 'PSTN';
            pd2.service = serviceList1;
            pd2.Product_Type = 'ISDN';
                
            productDTOList.add(pd1);
            productDTOList1.add(pd2);
            
            ReplicatorGetServiceDataObject.SiteDTO sitedt1 = new ReplicatorGetServiceDataObject.SiteDTO();
            ReplicatorGetServiceDataObject.SiteDTO sitedt2 = new ReplicatorGetServiceDataObject.SiteDTO();
            
            sitedt1.ADBOR_Id = 'AddressID-1Test';
            sitedt1.productList = productDTOList;
            
            sitedt2.ADBOR_Id = 'AddressID-2Test';
            sitedt2.productList = productDTOList;
        
            getSiteDTO.add(sitedt1);
            getSiteDTO.add(sitedt2); 
            
            ReplicatorGetServiceDataObject rsd = new ReplicatorGetServiceDataObject();
            rsd.Site = getSiteDTO;
            rsd.CIDN = 'Test Trans';

        
            Account acc = AccountTestFactory.buildAccount('Test Name');
            acc.CIDN__c = 'Test Trans';
            insert acc;
            cscrm__Address__c address = AccountTestFactory.buildAddress('AddressID-1Test');
            insert address;
            cscrm__Address__c address1 = AccountTestFactory.buildAddress('AddressID-2Test');
            insert address1;
            
            List<Contact> contactInsertList = new List<Contact>();
           
            Contact pc = AccountTestFactory.buildContact(acc, 'testPC', 'testabc122@test.com');
            contactInsertList.add(pc);
            Contact sc = AccountTestFactory.buildContact(acc, 'testSC', 'estabc13222@testdom.com');
            contactInsertList.add(sc);
            
            Contact pc1 = AccountTestFactory.buildContact(acc, 'testPC1', 'testabc122@test1.com');
            contactInsertList.add(pc1);
            Contact sc1 = AccountTestFactory.buildContact(acc, 'testSC1', 'estabc13222@testdom1.com');
            contactInsertList.add(sc1);
        
            insert contactInsertList;

            cscrm__Site__c site = AccountTestFactory.buildSite(address.id, acc.id);
            site.Primary_Contact__c = pc.id;
            site.Secondary_Contact__c = sc.id;            
            insert site;
            
            cscrm__Site__c site1 = AccountTestFactory.buildSite(address1.id, acc.id);
            site.Primary_Contact__c = pc1.id;
            site.Secondary_Contact__c = sc1.id;            
            insert site1;
             cscfga__Product_Category__c pcategory = ProductTestFactory.buildProductCategory();
             pcategory.name = 'Modular Products';
             insert pcategory;
             
                        
             Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
             insert opp;
             System.assertNotEquals(null,opp);

             cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c ();
             basket.cscfga__Opportunity__c = opp.Id;
             insert basket;
             
             
             Test.startTest();      
             PageReference pg = TransitionProductBasketUpdate.createTransitionBasket(rsd,basket.id);
             Test.stopTest();
             System.assertNotEquals(null,pg);
             
             
    }
}