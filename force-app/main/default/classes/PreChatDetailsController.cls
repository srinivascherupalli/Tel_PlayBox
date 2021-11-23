/**
*   Purpose         :   This class is used to fetch Pre Chat form data
*
*   Author          :   Pratap Garani (Wipro)
*
*   Date            :   10/30/2020
*
*   Current Version :   V_1.0
*
*   Revision Log    :   V_1.0 - DPA-1977 - Created
**/

public class PreChatDetailsController {

    @AuraEnabled(cacheable=true)
	public static LiveChatTranscript getPreChatData(String currentRecordId){
		LiveChatTranscript lctData = [SELECT ID, PreChat_Email__c, PreChat_FirstName__c, PreChat_LastName__c, PreChat_Phone_Number__c, Company_Name__c FROM LiveChatTranscript where Id=:currentRecordId][0];
		return lctData;
	}

}