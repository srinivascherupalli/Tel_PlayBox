//EDGE-155277 Send Chatter Posts to Account Owner 
//when an active POR Partner user creates or close wons an oppty
public class POROpptyChatterPosts {
    @InvocableMethod
    public static void sendStatusChatter(List<String> chatterMsgStr){
        try{      
            list<string> lstStr = chatterMsgStr[0].split('#');
            ConnectApiHelper.postFeedItemWithMentions(null, lstStr[0], lstStr[1]);
        }
        catch(exception e){
            system.debug('Error occurred in class POROpptyChatterPosts::'+e.getMessage()+'####'+e.getLineNumber()); 
        }
    }
}