/*
===============================================================================================================================
Class : CS_ServiceSpecificationV3
Developer Name : Martand Atrey
Test Class : CS_ServiceSpecificationV3Test
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Ankit Goswami       07/04/2021    Associate Business calling to device
===============================================================================================================================
*/
public class CS_ServiceSpecificationV3 {
    public CS_ServiceSpecificationV3(){

    }
    
    public String serviceId;
    public List<ServiceSpecifications> specifications;


  public class ServiceSpecifications {  
        public String guid;
        public String code;
        public String productConfigurationId; //Added As part of EDGE-204030
      
  }  
  

  
}