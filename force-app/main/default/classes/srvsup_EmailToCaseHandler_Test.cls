/*****************************************************************************
@Author: Kritika Bhati
@CreateDate: 6-June-2019
@ModifiedByandDate: <Please mention All modifications here>
@Description: This class is test class for srvsup_EmailToCaseHandler. 
@References
Epic :EDGE-75536: Email To Case Creation (No auto forward) for Sales, Certitude, Service
@ModifiedByandDate: <18th May 2020> |Karan Jugtawat((Team Jaipur) | P2OB-6050

*******************************************************************************/
@isTest(seeAllData=false)
public class srvsup_EmailToCaseHandler_Test {
    @testSetup
    public static void createData(){
       Account acc = new Account(Name = 'ÁBC Co.');      
       insert acc;
        
       Contact con = new Contact(LastName = 'Smith', Email = 'test@gmail.com', AccountId = acc.Id, Contact_Status__c = 'active');	 
       insert con;       
        
    }
    @isTest
    public static void createCaseFromEmail(){ // Service Support Email address
    	// Create a new email and envelope object (Mandatory)
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                
        // Create the email body
        email.plainTextBody = 'This should become a note : test@gmail.com';
        email.fromAddress ='ServiceSupport@team.telstra.com';
        String contactEmail = 'test@team.telstra.com';
        email.ccAddresses = new String[] {'Test Domain <' + contactEmail + '>'};
        email.subject = 'Dummy Subject';
        env.fromAddress = Label.srvsup_Service_Support;
        
        // add an Binary attachment

        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

 
      // add an Text atatchment
 
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
     
        srvsup_EmailToCaseHandler etc = new srvsup_EmailToCaseHandler();
        Test.startTest();
        // pass email & enveloper object as parameters here
        Messaging.InboundEmailResult result = etc.handleInboundEmail(email, env);
        Test.stopTest();
        
        List<Case> csList = [Select Id from Case where Contact.LastName = 'Smith'];
        System.assert(csList.size()!= null);
    }
    // When no contact is found with the email id that is in the Body
    @isTest
    public static void createCaseFromEmailNoContact(){// Sales Support Email Address 
        // Create a new email and envelope object (Mandatory)
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                
        // Create the email body
        email.plainTextBody = 'This should become a note: abc@gmail.com';
        email.fromAddress ='SalesSupport@team.telstra.com';
        String contactEmail = 'test2@team.telstra.com';
        email.ccAddresses = new String[] {'Test Domain <' + contactEmail + '>'};
        email.subject = 'Dummy Subject';
        env.fromAddress = Label.salesup_Sales_Support;
        
        srvsup_EmailToCaseHandler etc = new srvsup_EmailToCaseHandler();
        Test.startTest();
        // pass email & enveloper object as parameters here
        Messaging.InboundEmailResult result = etc.handleInboundEmail(email, env);
        Test.stopTest();
        List<Case> csList = [Select Id from Case where ContactId = null];
        System.assertEquals(1, csList.size());
    }
    
    @isTest
    public static void createCaseFromEmailCPE(){ // CPE Purple Order Request Email
    	// Create a new email and envelope object (Mandatory)
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                
        // Create the email body
        email.plainTextBody = 'This should become a note : test@gmail.com';
        //email.fromAddress ='purplesalessupport@team.telstra.com';
        String contactEmail = 'test@team.telstra.com';
        email.ccAddresses = new String[] {'Test Domain <' + contactEmail + '>'};
        email.subject = 'Dummy Subject';
        email.fromAddress = Label.cpe_Purple_Order_Request_Email;
        env.fromAddress = Label.cpe_Purple_Order_Request_Email;
        
        // add an Binary attachment

        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

 
      // add an Text atatchment
 
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
     
        srvsup_EmailToCaseHandler etc = new srvsup_EmailToCaseHandler();  
        // pass email & enveloper object as parameters here
        Test.startTest();
        Messaging.InboundEmailResult result = etc.handleInboundEmail(email, env);        
        //etc.handleInboundEmail(email, env);
        List<Case> csList = [Select Id from Case where Contact.LastName = 'Smith'];
        System.assertEquals(1, csList.size());
        Test.stopTest();
		
    }
    
    @isTest
    public static void createCaseFromEmailCPE1(){ // CPE Purple Quote Request Email
    	// Create a new email and envelope object (Mandatory)
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                
        // Create the email body
        email.plainTextBody = 'This should become a note : test@gmail.com';
        //email.fromAddress ='purplesalessupport@team.telstra.com';
        String contactEmail = 'test1@team.telstra.com';
        email.ccAddresses = new String[] {'Test Domain <' + contactEmail + '>'};
        email.subject = 'Dummy Subject';
        email.fromAddress =Label.cpe_Purple_Quote_Request_Email;
        system.debug('testEmail=='+Label.cpe_Purple_Quote_Request_Email);
        env.fromAddress = Label.cpe_Purple_Quote_Request_Email;
        
        // add an Binary attachment

        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

 
      // add an Text atatchment
 
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
     
        
        srvsup_EmailToCaseHandler etc = new srvsup_EmailToCaseHandler();  
        // pass email & enveloper object as parameters here
        Test.startTest();
        Messaging.InboundEmailResult result = etc.handleInboundEmail(email, env);
        //etc.handleInboundEmail(email, env);
        List<Case> csList = [Select Id from Case where Contact.LastName = 'Smith'];
        System.assertEquals(1, csList.size());
        Test.stopTest();
		
    }
    @isTest
    public static void createCaseFromEmailCPE2(){
    	// Create a new email and envelope object (Mandatory)
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                
        // Create the email body
        email.plainTextBody = 'This should become a note : test@gmail.com';
        //email.fromAddress ='purplesalessupport@team.telstra.com';
        String contactEmail = 'test@team.telstra.com';
        email.ccAddresses = new String[] {'Test Domain <' + contactEmail + '>'};
        email.subject = 'Dummy Subject';
        //env.fromAddress = 'purplesalessupport@team.telstra.com';
        
        // add an Binary attachment

        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

 
      // add an Text atatchment
 
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
     
        email.fromAddress =Label.cpe_Service_Desk_Email;
        env.fromAddress = Label.cpe_Service_Desk_Email;
        srvsup_EmailToCaseHandler etc = new srvsup_EmailToCaseHandler();  
        // pass email & enveloper object as parameters here
        Test.startTest();
        Messaging.InboundEmailResult result = etc.handleInboundEmail(email, env);
        List<Case> csList = [Select Id from Case where Contact.LastName = 'Smith'];
        System.assertEquals(1, csList.size());
        
        /*
        String caseId = csList[0].Id;
        string Case_ThreadID = 'ref:_'  + UserInfo.getOrganizationId().left(4)  + '0'  + UserInfo.getOrganizationId().mid(11,4) + '._'  + caseId.left(4) + '0'  + caseId.mid(10,5) + ':ref';
        
        email.plainTextBody = Case_ThreadID;
        email.fromAddress =Label.mm_mobile_Support_email;
        env.fromAddress = Label.mm_mobile_Support_email;
        etc.handleInboundEmail(email, env);
        //List<Case> cpeCase = [Select Id From Case];
        */
        Test.stopTest();
		       
    }
  
}