/*************************************************************************************************
Name : PpvRequestDTOTest
Description : Request DTO for PPV tool
Author: Aishwarya
Story: EDGE-90327
***************************************************************************************************/
@isTest
  public class PpvRequestDTOTest {
     /*------------------------------------------------------------ 
    Author: Aishwarya
    US: EDGE-90327
    Description: parse json response for PPV Success
    ------------------------------------------------------------*/
            @isTest
            public static void testParsesuccess(){
                String json='{"correlationId":"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","timestamp":"2019-01-16T23:06:26.064Z","data":{"externalId":"AB1234567890","portNumber":"61400111222","prePaidBrand":"N"}}';
				
				Test.startTest();
                PpvRequestDTO ppvReq= PpvRequestDTO.parse(json);
                Test.stopTest();
                
                System.assert(ppvReq.correlationId =='58fb5c78-77ed-4f58-97e3-6e0ae3ce498e');
				 System.assert(ppvReq.timestamp =='2019-01-16T23:06:26.064Z');
               System.assert(ppvReq.data.externalId =='AB1234567890');
                
                System.assert(ppvReq.data.portNumber =='61400111222');
                System.assert(ppvReq.data.prePaidBrand =='N');      
                
            }
        }