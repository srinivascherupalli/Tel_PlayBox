@isTest
public class SendCaseWebFormEmailService_test{
    @isTest static void sendEmailattachtest() {
 
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        insert cas;
        
        attachment att = new attachment();
        att.Name = 'Test attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        att.Body = bodyBlob;
        att.ParentId = cas.Id;
        insert att;
        List<attachment> finalAttachmentList = [select id, name from Attachment where parentId =:cas.Id];
        list<id> ids = new list<id>();
        ids.add(att.id);
        
        string outGoingEmail = 'bathula.reddy@infosys.com';
        string inComingEmail = 'bathula.reddy@infosys.com';
        
        SendCaseWebFormEmailService.flowInput input;
        input = new SendCaseWebFormEmailService.flowInput();
        input.outGoingEmail = outGoingEmail;
        input.inComingEmail = inComingEmail;
        input.currentCaseId = cas.Id;
        input.docid = ids;
        list<SendCaseWebFormEmailService.flowInput> inputList = new list<SendCaseWebFormEmailService.flowInput>();
        
        inputList.add(input);
        SendCaseWebFormEmailService.sendEmailtoCustomers(inputList);
        //SendCaseWebFormEmailService ser = new SendCaseWebFormEmailService(inputList);
        integer invocation = limits.getEmailInvocations();
        
        system.assertEquals(1, finalAttachmentList.size());
        
    }
}