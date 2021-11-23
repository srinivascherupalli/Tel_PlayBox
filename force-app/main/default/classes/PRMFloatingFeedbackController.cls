/*
Version     Author                         Last Modified Date      Description
v1.0        Vivian Charlie (Team Hawaii)     02 Dec 2020           Initial Draft
*/
public with sharing class PRMFloatingFeedbackController {
    @AuraEnabled
    public static ContentVersion uploadFile(Id idParent, String strFileName, String base64Data) {
        system.debug('apex method called');
        // Decoding base64Data
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        // inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = strFileName;
        cv.PathOnClient = '/' + strFileName;
        cv.FirstPublishLocationId = idParent;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        insert cv;
        return cv;
    }
}