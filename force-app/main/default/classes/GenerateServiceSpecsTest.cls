@IsTest
public class GenerateServiceSpecsTest {
    
    @IsTest  Public static void getAttributesTest(){
        GenerateServiceSpecs.ServiceSpecificationsStructure serSpecs=new GenerateServiceSpecs.ServiceSpecificationsStructure();
        
        serSpecs.version='1';
        serSpecs.status='Status';
        serSpecs.startDate=String.valueOf(system.today());
        serSpecs.productConfigurationId=null;
        serSpecs.name='serviceSpecs';
        serSpecs.InstanceId='test12345';
        serSpecs.code='code';
        
        List<CS_SpecificationDTO.SimpleAttributes> attributList=new List<CS_SpecificationDTO.SimpleAttributes>();
        CS_SpecificationDTO.SimpleAttributes attribute1=new CS_SpecificationDTO.SimpleAttributes();
        attribute1.name='MobileHandsetManufacturer';
        attribute1.value='Test';
        attributList.add(attribute1);
        
        CS_SpecificationDTO.SimpleAttributes attribute2=new CS_SpecificationDTO.SimpleAttributes();
        attribute2.name='MobileHandsetModel';
        attribute2.value='test';
        attributList.add(attribute2); 
        Test.startTest();
        GenerateServiceSpecs.getAttributes(attributList);
        String guid=  GenerateServiceSpecs.getGuid();
        Test.stopTest();
        system.assertNotEquals('', guid);
    } 
}