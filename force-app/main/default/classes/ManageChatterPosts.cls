/************************
Author: RaviTeja K
Description: Managing chatter posts for hyper links along with user mention in PRM as well
Usage: 
  used special symbols !,{record:, to manage hyperlinks and user mentions in post.
       

*****************************/

public class ManageChatterPosts {
     @InvocableMethod
     public static void PostChatterMessage(list<String> messages){
        String message=messages[0];
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();            
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();   
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        String Networkid=Network.getnetworkid();

        list<string> inputList=message.split('!'); 
        String recid=inputList[0].trim();
        String textmessage=inputList[1];
        String postmesage=inputList[1];    

        if(UserInfo.getUserType()=='Standard' && !Test.isRunningTest()){ 
                   ConnectApiHelper.postFeedItemWithMentions(Networkid, recid,postmesage);
        
        }else if(!Test.isRunningTest()){      
                   ConnectApiHelper.postFeedItemWithMentions(null, recid,postmesage);
               
           }
           
    }
      
}