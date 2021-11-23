/*************************************************************************************************
Name : PpvResponseDTOTest
Description : Response DTO for PPV tool
Author: Aishwarya
Story: EDGE-90327
***************************************************************************************************/
@isTest
  public class PpvResponseDTOTest {
     /*------------------------------------------------------------ 
    Author: Aishwarya
    US: EDGE-90327
    Description: parse json response for PPV Success
    ------------------------------------------------------------*/
            @isTest
            public static void ppvResponseParse(){
				String json='{"status":202,"code":202,"responseCode":"MPPV-ACCEPTED","correlationId":"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","timeStamp":"2019-02-27T00:22:19.737Z","path":"/generate-code","method":"POST","data":{"externalId":"abc1234","resourceId":"145sdhju176-wh2327-9474f-f56g5"}}';
				Test.startTest();
                PpvResponseDTO ppvRes= PpvResponseDTO.parse(json);
                Test.stopTest();
                 System.assert(ppvRes.status ==202);
				  System.assert(ppvRes.code ==202);
				  System.assert(ppvRes.responseCode =='MPPV-ACCEPTED');
                System.assert(ppvRes.correlationId =='58fb5c78-77ed-4f58-97e3-6e0ae3ce498e');
				 System.assert(ppvRes.timestamp =='2019-02-27T00:22:19.737Z');
				 System.assert(ppvRes.path =='/generate-code');
				 System.assert(ppvRes.method =='POST');
               System.assert(ppvRes.data.externalId =='abc1234');
                System.assert(ppvRes.data.resourceId =='145sdhju176-wh2327-9474f-f56g5');
              
            }
        }