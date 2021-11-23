@isTest
public class ChatTranscript_CCD_Sharing_Test{

    static testMethod void shareTranscriptToQueueTest(){
       
        User u=TestUtil.createUser('testuser@test.com.sample','alias','System Administrator');
        System.runAs(u){
      
            test.startTest();
          
            LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
            
            List<String> groups = label.CCD_GROUP.split(',');
                        
            LiveChatTranscript lct = new LiveChatTranscript();
            lct.LiveChatVisitorid = lcv.id;
            lct.OwnerId = u.Id;
            insert lct;
            
            Id ccdGroup = [SELECT id, Name,DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName In: groups Limit 1].Id;     

            String ButtonName ='Chat_Telstra Connect Concierge';
            
            ChatTranscript_CCD_Sharing.shareTranscriptToQueue(lct.Id, ButtonName);
            List<LiveChatTranscriptShare> shareRecords = [SELECT Id FROM LiveChatTranscriptShare WHERE ParentId =:lct.Id];
            
            System.assert(shareRecords.size() > 0);
           
            test.stopTest();
        }
     }
}