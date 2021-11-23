@isTest
private class GenerateQuoteHelperTest {
    @testsetup static void setup() {
            //Disabling triggers to resolve SOQL 101 Error
            Environment_Configurations__c setting = new Environment_Configurations__c();
            setting.No_Triggers__c=true;
            insert setting; 
            APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
            template.APXTConga4__Name__c = 'Quote';
            template.Sequence__c = 1;
            insert template;
            APXTConga4__Conga_Merge_Query__c query1 = new APXTConga4__Conga_Merge_Query__c();
            query1.APXTConga4__Name__c = 'BSChangesToExisting'; 
            insert query1;
            APXTConga4__Conga_Merge_Query__c query2 = new APXTConga4__Conga_Merge_Query__c();
            query2.APXTConga4__Name__c = 'BasketPricesFromPC1'; 
            insert query2;
            APXTConga4__Conga_Merge_Query__c query3 = new APXTConga4__Conga_Merge_Query__c();
            query3.APXTConga4__Name__c = 'BasketPricesFromPC2'; 
            insert query3;
            APXTConga4__Conga_Merge_Query__c query4 = new APXTConga4__Conga_Merge_Query__c();
            query4.APXTConga4__Name__c = 'BSCWPChanges'; 
            insert query4;
            APXTConga4__Conga_Merge_Query__c query5 = new APXTConga4__Conga_Merge_Query__c();
            query5.APXTConga4__Name__c = 'Opportunityabc'; 
            insert query5;          
            List<Account> accs = new List<Account>();
            List<Contact> contacts = new List<Contact>();
            Account acc = AccountTestFactory.buildAccount('Test Account Test1') ;
            acc.Customer_Status__c='Active';
            accs.add(acc);
            Account acc1 = AccountTestFactory.buildAccount('Test Account1 Test1') ;
            acc1.Customer_Status__c='Active';
            accs.add(acc1);
            insert accs;
            Contact contact1 = new Contact(
                AccountId = acc.id, 
                LastName = 'Green',
                FirstName = 'TestPh',
                Contact_Role__c = 'Consultant',
                MobilePhone = '0412345678',
                Email = 'GenerateQuote@tele2test.com'   
            );
            contacts.add(contact1);
            Contact contactFCR = new Contact(
                AccountId = acc1.id,
                LastName = 'LastGen',
                FirstName = 'FirstGen', 
                Contact_Role__c = 'Consultant',
                MobilePhone = '0412345678',
                Email = 'ttest1@tele2.com'   
            );
            contacts.add(contactFCR);
            insert contacts;
            //EDGE-41492 : Increase Code coverage - below 2 lines added
            AccountContactRelation ACR = new AccountContactRelation(AccountId=acc.id, ContactId=contactFCR.id, Roles='Legal Lessee' );
            insert ACR;
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            RecordType RT =[SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Defined' limit 1]; 
            opp.RecordTypeId = RT.Id; 
            insert opp;
            //EDGE-41492 : Increase Code coverage below 1 line added
            OpportunityContactRole ocr = new OpportunityContactRole(Role ='Business User',OpportunityId=opp.id ,Contactid = contactFCR.id ,Isprimary = True); insert ocr;
            cscfga__Product_Basket__c basket=ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'basket1';
            insert basket;
        //EDGE-165831 - spec code updates
        cscfga__Product_Definition__c prodDefinition = new cscfga__Product_Definition__c( Name = 'Test' + 'PD', cscfga__Description__c = 'Test Description', product_Specification__c = 'DMCAT_ProductOffering_000304',Snapshot_Object__c='basketsnapshot' );
        insert prodDefinition;
        //EDGE-141270
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c newPC = new cscfga__Product_Configuration__c();
        newPC.cscfga__Product_Basket__c = basket.id;
        newPC.name = 'IP Site';
        newPC.cscfga__Product_Definition__c=prodDefinition.id;
        newPC.Type__c = 'New';
        newPC.TotalGSTInclusiveTOC__c = 0.0;
        newPC.TotalGSTInclusiveTRC__c = 0.0;
        newPC.GSTExcl_Total_Onceoff_Charges__c = 0.0;
        //insert newPC;
        //EDGE-141270
        pcList.add(newPC);
        //EDGE-127780 Start 
        //EDGE-141270 AND EDGE-143435 Start

        //EDGE-165831 - updated offer id code

        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='Corporate Mobile Plus' ;
        moMob.Name = 'Corporate Mobile Plus';
        moMob.Offer_ID__c = 'DMCAT_Offer_000646';
        insert moMob;
        cscfga__Configuration_Offer__c offername1= new cscfga__Configuration_Offer__c();
        offername1.name='Connected Workplace';
        offername1.cscfga__Active__c=true;
        offername1.cscfga__Description__c='Connected Workplace Package';
        insert offername1;
        cscfga__Product_Configuration__c oldPC = new cscfga__Product_Configuration__c();
        oldPC.cscfga__Product_Basket__c = basket.id;
        oldPC.name='Connected Workplace Solution';
        oldPC.Type__c='New';
        oldPC.Marketable_Offer__c = moMob.id;
        oldPC.cscfga__originating_offer__c=offername1.id;
        oldPC.ConfigurationType1__c = 'SolutionComponent';
        insert oldPC;
        cscfga__Product_Configuration__c cnclPCngUC = new cscfga__Product_Configuration__c();
        cnclPCngUC.cscfga__Product_Basket__c = basket.id;
        //DIGI-3352 :Name change
        cnclPCngUC.name='Adaptive Collaboration Solution';
        cnclPCngUC.Type__c='Cancel';
        cnclPCngUC.csordtelcoa__Replaced_Product_Configuration__c=oldPC.id;
        cnclPCngUC.Marketable_Offer__c = moMob.id;//Add Marketable_Offer__c for EDGE-126184 Changes 
        cnclPCngUC.ConfigurationType1__c = 'SolutionComponent';
        //DIGI-3352 :Name change
        cnclPCngUC.cscfga__Product_Family__c = 'Adaptive Collaboration Solution';
        //insert cnclPCngUC;
        pcList.add(cnclPCngUC);
        //EDGE-132608 Start
        cscfga__Product_Configuration__c pcTC = new cscfga__Product_Configuration__c();
        pcTC.cscfga__Product_Basket__c = basket.id;
        pcTC.name='Business Calling';
        pcTC.Type__c='New';
        pcTC.Marketable_Offer__c = moMob.id;
        pcTC.cscfga__originating_offer__c=offername1.id;
        pcTC.cscfga__Product_Family__c = 'Business Calling';
        pcList.add(pcTC);
        //EDGE-132608 End
        //EDGE-148722 - Start
        cscfga__Product_Configuration__c pcNGEM = new cscfga__Product_Configuration__c();
        pcNGEM.cscfga__Product_Basket__c = basket.id;
        pcNGEM.name='APPLE IPHONE 11 PRO 256GB 4GX MIDNIGHT GREEN';
        pcNGEM.Type__c='New';
        pcNGEM.Marketable_Offer__c = moMob.id;
        pcNGEM.cscfga__originating_offer__c=offername1.id;
        pcNGEM.cscfga__Product_Family__c = 'Next Generation Mobile Device';
        pcList.add(pcNGEM);
        cscfga__Product_Configuration__c pcNGEM1 = new cscfga__Product_Configuration__c();
        pcNGEM1.cscfga__Product_Basket__c = basket.id;
        pcNGEM1.name='AppleCare+ Purchase';
        pcNGEM1.Type__c='New';
        pcNGEM1.Marketable_Offer__c = moMob.id;
        pcNGEM1.cscfga__originating_offer__c=offername1.id;
        pcNGEM1.cscfga__Product_Family__c = 'Mobile Device Care';
        pcList.add(pcNGEM1);
        cscfga__Product_Configuration__c cnclPCngem = new cscfga__Product_Configuration__c();
        cnclPCngem.cscfga__Product_Basket__c = basket.id;
        cnclPCngem.name='APPLE IPHONE 10 PRO 256GB 4GX MIDNIGHT GREEN';
        cnclPCngem.Type__c='Cancel';
        cnclPCngem.csordtelcoa__Replaced_Product_Configuration__c=oldPC.id;
        cnclPCngem.Marketable_Offer__c = moMob.id;//Add Marketable_Offer__c for EDGE-126184 Changes 
        cnclPCngem.ConfigurationType1__c = 'SolutionComponent';
        cnclPCngem.cscfga__Product_Family__c = 'Next Generation Mobile Device';
        pcList.add(cnclPCngem);
        //EDGE-148722 - End
        //EDGE-165326 - Start
        cscfga__Product_Configuration__c pcNGEMPlan = new cscfga__Product_Configuration__c();
        pcNGEMPlan.cscfga__Product_Basket__c = basket.id;
        pcNGEMPlan.name='Handheld-Enterprise Lite';
        pcNGEMPlan.Type__c='New';
        pcNGEMPlan.Marketable_Offer__c = moMob.id;
        pcNGEMPlan.cscfga__originating_offer__c=offername1.id;
        pcNGEMPlan.cscfga__Product_Family__c = 'Enterprise Mobility Plan';
        pcList.add(pcNGEMPlan);
        //EDGE-165326 - End


        //EDGE-155059 & EDGE-162542 Start
        cscfga__Product_Configuration__c pcNGEMPlanCancel = new cscfga__Product_Configuration__c();
        pcNGEMPlanCancel.cscfga__Product_Basket__c = basket.id;
        pcNGEMPlanCancel.name='Handheld-Enterprise Lite';
        pcNGEMPlanCancel.Type__c='Cancel';
        pcNGEMPlanCancel.Marketable_Offer__c = moMob.id;
        pcNGEMPlanCancel.cscfga__originating_offer__c=offername1.id;
        pcNGEMPlanCancel.cscfga__Product_Family__c = 'Enterprise Mobility Plan';
        pcList.add(pcNGEMPlanCancel);
       //EDGE-155059 & EDGE-162542 End


        insert pcList;
        //EDGE-141270 AND EDGE-143435 End
    cscfga__Product_Configuration__c MacPC1 = new cscfga__Product_Configuration__c();
        MacPC1.cscfga__Product_Basket__c = basket.id;
        MacPC1.name = 'Internet Solution';
        MacPC1.cscfga__Product_Definition__c=prodDefinition.id;
        MacPC1.Type__c = null;
        MacPC1.TotalGSTInclusiveTOC__c = 0.0;
        MacPC1.TotalGSTInclusiveTRC__c = 0.0;
        MacPC1.GSTExcl_Total_Onceoff_Charges__c = 0.0;
        MacPC1.cscfga__Product_Family__c = 'Internet Solution';
    MacPC1.csordtelcoa__Replaced_Product_Configuration__c = newPC.id;
        insert MacPC1;
        //EDGE-127780 End
        //EDGE-132157 Start
        Attachment transitionAttach = new Attachment();
        transitionAttach.name = 'TransitionJSONData.json';
        transitionAttach.ParentId = newPC.Id;
        transitionAttach.body = Blob.valueOf('Test');
        insert transitionAttach;
        system.debug('transitionAttach@@:: ' + transitionAttach);
        //system.debug('newPC.attach@@:: ' + newPC.attachments);
        //EDGE-132157 End
        cscfga__Product_Configuration__c macPC = new cscfga__Product_Configuration__c();
        macPC.cscfga__Product_Basket__c = basket.id;
        macPC.Type__c = 'Modify';
        macPC.cscfga__Parent_Configuration__c = newPC.id;
        macPC.cscfga__Product_Definition__c=prodDefinition.id;
        macPC.name = 'IP Site';
        macPC.TotalGSTInclusiveTOC__c = 0.0;
        macPC.TotalGSTInclusiveTRC__c = 0.0;
        macPC.GSTExcl_Total_Onceoff_Charges__c = 0.0;
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>{macPC};
        insert configList;
        csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c();
        pcr.csbb__Product_Basket__r=basket;pcr.csbb__Product_Basket__c=basket.id;pcr.csbb__Postcode__c ='55332211';pcr.csbb__Product_Configuration__c= newPC.id;pcr.csbb__Product_Configuration__r= newPC;
        insert pcr;
        System.debug('test:'+pcr.csbb__Product_Configuration__r.name);  
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for(cscfga__Product_Configuration__c config0:configList){
            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('RestorationTime', '4 hours', config0.id);
            attList.add(attr2);
            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Quantity', '300.00', config0.id);
            attList.add(attr3);
            cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('Site Name', 'SiteTest', config0.id);
            attList.add(attr4);
            cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('GSTInclusiveTOC', '0.0', config0.id);
            attList.add(attr5);
            cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('GSTInclusiveTRC', '0.0', config0.id);
            attList.add(attr6);
            cscfga__Attribute__c attr7 = ProductTestFactory.buildAttribute('UnitOfMeasure', 'Not Applicable', config0.id);
            attList.add(attr7);
            cscfga__Attribute__c attr8 = ProductTestFactory.buildAttribute('ServiceabilityLocation', 'Urban', config0.id);
            attList.add(attr8);
            cscfga__Attribute__c attr9 = ProductTestFactory.buildAttribute('ResponseTime', '2 hours', config0.id);
            attList.add(attr9);
            cscfga__Attribute__c attr10 = ProductTestFactory.buildAttribute('UnitPrice', '300.00', config0.id);
            attList.add(attr10);
            cscfga__Attribute__c attr11 = ProductTestFactory.buildAttribute('Site Address', 'SiteTest', config0.id);
            attList.add(attr11);
        }
        insert attList;
        /*
        // EDGE-154990 Test Data
        cscfga__Product_Basket__c basketTC = ProductTestFactory.buildEmptyBasket();
        basketTC.csbb__Account__c = acc.id;
        basketTC.cscfga__Opportunity__c = opp.id;
        basketTC.Name = 'basketNGUC';
        insert basketTC;
        Marketable_Offer__c moTC1 = new Marketable_Offer__c();
        moTC1.OfferDefinationName__c ='Telstra Collaboration Solution';
        moTC1.Name = 'Telstra Collaboration';
        moTC1.Offer_ID__c = 'DMCAT_Offer_000618';
        insert moTC1;
        cscfga__Product_Definition__c pdTC = new cscfga__Product_Definition__c( Name = 'Business Calling', cscfga__Description__c = 'Business Calling', product_Specification__c = 'DMCAT_ProductOffering_000304',Snapshot_Object__c='basketsnapshot' );
        insert pdTC;
        cscfga__Product_Configuration__c pcTC1 = new cscfga__Product_Configuration__c();        
        pcTC1.cscfga__Product_Basket__c = basketTC.id;
        pcTC1.name='Business Calling';
        pcTC1.Type__c='New';
        pcTC1.Marketable_Offer__c = moTC1.id;
        pcTC1.cscfga__Product_Family__c = 'Business Calling';
        pcTC1.cscfga__Product_Definition__c = pdTC.Id;        
        insert pcTC1;
        // Test Data
        // */
    }
     @isTest static void generateQuoteSuccess() {
            //testdata();
            List<String> nameOfTemplates = new list<String> {'Quote'};
            Map<String,String> mapOfTemplates = CustomButtonOpportunitySync.getTemplateId(nameOfTemplates,'template');
             String templateID = mapOfTemplates.get('Quote');
            Test.startTest();   
            cscfga__Product_Basket__c basket = [Select id,name,cscfga__Opportunity__c,csbb__Account__c from cscfga__Product_Basket__c basket limit 1];
            String URL= GenerateQuoteHelper.createQuote(templateID,basket.id);
            //EDGE-41492 : Increase Code coverage below 1 line added
            //GenerateQuoteHelper.fetchBasketSnapshot(basket.id);

Test.stopTest(); 	
            System.assert(URL!=null);
            //EDGE-127780 AND EDGE-141270 AND EDGE-143435 Start
            Quote showExistingService = [Select Existing_Services_Show__c,Changes_to_Existing__c from quote limit 1];
            system.debug('showExistingService@@::' + showExistingService);
            System.assert(showExistingService.Existing_Services_Show__c==true);
            Quote showChangestoExisting = [Select Changes_to_Existing__c from quote limit 1];
            system.debug('showChangestoExisting@@::' + showChangestoExisting);

          //  System.assert(showChangestoExisting.Changes_to_Existing__c==true);

            //EDGE-127780 AND EDGE-141270 AND EDGE-143435 END
            //EDGE-132157 Start  Transition_Services_Show__c
            //Quote showTransitionService = [Select Transition_Services_Show__c from quote limit 1];
            //system.debug('showTransitionService@@::' + showTransitionService);
            //System.assert(showTransitionService.Transition_Services_Show__c==false);
            //EDGE-132157 End
            //Test.stopTest();        
     }
    @isTest static void generateQuoteFailure() {
         String templateID = null;
         Test.startTest(); 
         cscfga__Product_Basket__c basket = [Select id,name,cscfga__Opportunity__c,csbb__Account__c from cscfga__Product_Basket__c basket limit 1];
         String URL= GenerateQuoteHelper.createQuote(templateID,basket.id);
        // EDGE-165831 - Negative Existing assert to check method output for retrofit changes .
         System.assert(URL==null);
         Test.stopTest();       
     }
    @isTest static void validateRelatedContactTest() {
        Test.startTest();                 
        Quote quo = new Quote();
        cscfga__Product_Basket__c basket = [Select id,name,cscfga__Opportunity__c,csbb__Account__c from cscfga__Product_Basket__c basket limit 1];
        Contact contact = [Select id,Email from Contact where FirstName='TestPh'];
        quo.Name = basket.Name;
        quo.Product_Basket__c = basket.Id;
        quo.opportunityid=basket.cscfga__Opportunity__c;
        quo.ExpirationDate =system.today()+30;
        quo.Conga_Status__c ='InProgress' ;
        quo.ContactId = contact.Id;
        quo.Conga_Request_Time__c = System.now();  
        insert quo;
            Contact contactFCR = [Select id,Email from Contact where FirstName='TestPh' limit 1];
            Functional_Contact_Role__c fcr = new Functional_Contact_Role__c();      
            fcr.ContactID__c = contactFCR.id;
            fcr.Role_Type__c = 'Contract Role';
            Insert fcr;
            quo.ContactId = NULL;
            update quo;
            GenerateQuoteHelper.fetchPrimaryContactQuote(basket);
            System.assert(quo.id!=null);
        Test.stopTest();        
    }
    @isTest static void EmailMessageTriggerTest() {
        Test.startTest();     
        Quote quo = new Quote();
        cscfga__Product_Basket__c basket = [Select id,name,cscfga__Opportunity__c,csbb__Account__c from cscfga__Product_Basket__c basket limit 1];
        Contact contact = [Select id,Email from Contact where FirstName='TestPh'];
        quo.Name = basket.Name;
        quo.Product_Basket__c = basket.Id;
        quo.opportunityid=basket.cscfga__Opportunity__c;
        quo.ExpirationDate =system.today()+30;
        quo.Conga_Status__c ='InProgress' ;
        quo.ContactId = contact.Id;
        quo.isAttachmentAvailable__c = true;
        quo.Conga_Request_Time__c = System.now();  
        insert quo;
            EmailMessage outGoingMail= new EmailMessage();
            outGoingMail.fromaddress='test@test.com';
            outGoingMail.toAddress = contact.Email;
            outGoingMail.subject = 'Opt Out Test Message';
            outGoingMail.TextBody= 'This is the message body BR-Interno.';
            outGoingMail.relatedToID=quo.id;
            insert outGoingMail;
            System.assert(quo.id!=null);
            Test.stopTest();        
    }
    //Below will cover negative for EDGE-132608 & EDGE-148728 as well
    @isTest static void NegativeTest() {
        GenerateQuoteHelper quoteHelper= new GenerateQuoteHelper();
         try { 
        quoteHelper.validateRelatedContact(null,null,null,null); /* Negative case: 1 */
         }
        catch (Exception e) {
        String message = e.getMessage();
        System.assert(e.getMessage().contains('ERROR'), 'message=' + e.getMessage());
      }
        Test.startTest();
        cscfga__Product_Basket__c basket = [Select id,name,cscfga__Opportunity__c,csbb__Account__c from cscfga__Product_Basket__c basket limit 1];

        //EDGE-165831 
        Account acc1=new Account(Name='acc1');
        insert acc1;
        Contact cnt= new Contact(AccountId = acc1.id, LastName = 'Last',FirstName = 'FirstNegatibe',Contact_Role__c = 'Consultant',MobilePhone = '0412345678',Email = 'test@tele2.com'   ); 

        insert cnt;
        Contact contact = [Select id,Email from Contact where FirstName='TestPh'];
        Quote quo = new Quote(Name = basket.Name,Product_Basket__c = basket.Id,opportunityid=basket.cscfga__Opportunity__c,ExpirationDate =system.today()+30,Conga_Status__c ='InProgress',ContactId = cnt.Id);
        Quote oldquo = new Quote(Name = basket.Name,Product_Basket__c = basket.Id,opportunityid=basket.cscfga__Opportunity__c,ExpirationDate =system.today()+30,Conga_Status__c ='InProgress',ContactId = contact.Id);
        insert new List<quote>{quo,oldquo};
        System.assert(quoteHelper.validateRelatedContact( new List<quote>{quo}, new Map<Id,quote>{quo.id=>quo},new List<quote>{oldquo},new Map<Id,quote>{quo.id=>oldquo})==null);
        Test.stopTest();
    }
    // EDGE-132608 & EDGE-148728 Start Positive Scenario
    @isTest static void generateQuoteTC(){
            List<String> nameOfTemplates = new list<String> {'Quote'};
            Map<String,String> mapOfTemplates = CustomButtonOpportunitySync.getTemplateId(nameOfTemplates,'template');
            String templateID = mapOfTemplates.get('Quote');
            Test.startTest();   
            cscfga__Product_Basket__c basket = [Select id,name,cscfga__Opportunity__c,csbb__Account__c from cscfga__Product_Basket__c basket limit 1];
            String URL= GenerateQuoteHelper.createQuote(templateID,basket.id);
          Quote showNewServices = [Select New_Services_Show__c from quote limit 1];
            Test.stopTest();
          //165831 - Existing assert to check method output.
          System.assert(URL!=null);      
            system.debug('showNewServices@@::' + showNewServices.New_Services_Show__c);
            System.assert(showNewServices.New_Services_Show__c==true);        
     }
     // EDGE-132608 & EDGE-148728 End
    @isTest static void generateQuoteTCTrans_Test() { 
        Account acc1 = AccountTestFactory.buildAccount('Test NGUC Trans') ;
        acc1.Customer_Status__c='Active'; 
        insert acc1;
        Contact contact1 = new Contact(AccountId = acc1.id,LastName = 'Last',FirstName = 'First',Contact_Role__c = 'Consultant',Email = 'test@tele2.com');
        insert contact1;
        Opportunity opp1   = ProductTestFactory.getOpportunityBasic(acc1);
        RecordType RT =[SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Defined' limit 1]; 
        opp1.RecordTypeId = RT.Id; 
        insert opp1;        
        cscfga__Product_Basket__c basketTC = ProductTestFactory.buildEmptyBasket();
        basketTC.csbb__Account__c = acc1.id;
        basketTC.cscfga__Opportunity__c = opp1.id;
        basketTC.Name = 'basketNGUC';
        insert basketTC;
        Marketable_Offer__c moTC1 = new Marketable_Offer__c();
        //DIGI-3352 :Name change
        moTC1.OfferDefinationName__c ='Adaptive Collaboration Solution';
        //DIGI-3352 :Name change
        moTC1.Name = 'Adaptive Collaboration';
        moTC1.Offer_ID__c = 'DMCAT_Offer_000618';
        insert moTC1;
        cscfga__Product_Definition__c pdTC = new cscfga__Product_Definition__c( Name = 'Business Calling', cscfga__Description__c = 'Business Calling', product_Specification__c = 'DMCAT_ProductOffering_000304',Snapshot_Object__c='basketsnapshot' );
        insert pdTC;
        cscfga__Product_Configuration__c pcTC = new cscfga__Product_Configuration__c();        
        pcTC.cscfga__Product_Basket__c = basketTC.id;
        pcTC.name='Business Calling';
        pcTC.Type__c='New';
        pcTC.Marketable_Offer__c = moTC1.id;
        pcTC.cscfga__Product_Family__c = 'Business Calling';
        pcTC.cscfga__Product_Definition__c = pdTC.Id;        
        insert pcTC;        
        List<String> nameOfTemplates = new list<String> {'Quote'};
        Map<String,String> mapOfTemplates = CustomButtonOpportunitySync.getTemplateId(nameOfTemplates,'template');
        String templateID = mapOfTemplates.get('Quote');
        Test.startTest();   
        String URL= GenerateQuoteHelper.createQuote(templateID,basketTC.id);
        Test.stopTest(); 
        System.assert(URL!=null);
        Quote showExistingService = [Select Existing_Services_Show__c,Changes_to_Existing__c from quote limit 1];
        //EDGE-154990 - Positive scenario
        System.assert(showExistingService.Existing_Services_Show__c==false);
    }
    //EDGE-154990 end
    //EDGE-148722 - Start
    @isTest static void generateQuoteNGEMCare(){
      List<String> nameOfTemplates = new list<String> {'Quote'};
      Map<String,String> mapOfTemplates = CustomButtonOpportunitySync.getTemplateId(nameOfTemplates,'template');
      String templateID = mapOfTemplates.get('Quote');
      Test.startTest();   
      cscfga__Product_Basket__c basket = [Select id,name,cscfga__Opportunity__c,csbb__Account__c from cscfga__Product_Basket__c basket limit 1];
      String URL= GenerateQuoteHelper.createQuote(templateID,basket.id);
      Quote showNewServices = [Select New_Services_Show__c from quote limit 1];
      Test.stopTest();
      System.assert(URL!=null);           
      system.debug('showNewServices@@::' + showNewServices.New_Services_Show__c);
      System.assert(showNewServices.New_Services_Show__c==true);        
    }
    //EDGE-155059 & EDGE-162542 Positive Case. This covers addition of product family 'Enterprise Mobility Plan' in cancelProductFamilies list.
    @isTest static void generateQuoteNGEMCancel(){
      List<String> nameOfTemplates = new list<String> {'Quote'};
      Map<String,String> mapOfTemplates = CustomButtonOpportunitySync.getTemplateId(nameOfTemplates,'template');
      String templateID = mapOfTemplates.get('Quote');
      Test.startTest();   
      cscfga__Product_Basket__c basket = [Select id,name,cscfga__Opportunity__c,csbb__Account__c from cscfga__Product_Basket__c basket limit 1];
      String URL= GenerateQuoteHelper.createQuote(templateID,basket.id);
      Quote showExistingService = [Select Existing_Services_Show__c from quote limit 1];
      Test.stopTest();
      System.assert(URL!=null);           
      system.debug('showExistingService@@::' + showExistingService.Existing_Services_Show__c);
      System.assert(showExistingService.Existing_Services_Show__c==true);        
    }
    //EDGE-155059 & EDGE-162542 Negative Case
    @isTest static void generateQuoteNGEMCancel_Negative(){
      List<String> nameOfTemplates = new list<String> {'Quote'};
      Map<String,String> mapOfTemplates = CustomButtonOpportunitySync.getTemplateId(nameOfTemplates,'template');
      String templateID = mapOfTemplates.get('Quote');
      Test.startTest();   
      cscfga__Product_Basket__c basket = [Select id,name,cscfga__Opportunity__c,csbb__Account__c from cscfga__Product_Basket__c basket limit 1];
      String URL= GenerateQuoteHelper.createQuote(templateID,null);

      Test.stopTest();
      System.assert(URL==null);           

    }
    //EDGE-148722 - Cancel
    //EDGE-165326 - Start
    //Below method covers Positive Scenario for NGEM Plan details for Contract & Negative scenario is already covered as part of NegativeTest()
    @isTest static void generateQuoteNGEMPlanPositive(){
        List<String> nameOfTemplates = new list<String> {'Quote'};
        Map<String,String> mapOfTemplates = CustomButtonOpportunitySync.getTemplateId(nameOfTemplates,'template');
        String templateID = mapOfTemplates.get('Quote');
        Test.startTest();   
        cscfga__Product_Basket__c basket = [Select id,name,cscfga__Opportunity__c,csbb__Account__c from cscfga__Product_Basket__c basket limit 1];
        String URL= GenerateQuoteHelper.createQuote(templateID,basket.id);
        Quote showNewServices = [Select New_Services_Show__c from quote limit 1];
        Test.stopTest();
        System.assert(URL!=null);           
        system.debug('showNewServices@@::' + showNewServices.New_Services_Show__c);
        System.assert(showNewServices.New_Services_Show__c==true);        
      }
      //EDGE-165326 - End
     @isTest static void generateQuoteForLegacyServices() {//EDGE-181453
            List<String> nameOfTemplates = new list<String> {'Quote'};
            Map<String,String> mapOfTemplates = CustomButtonOpportunitySync.getTemplateId(nameOfTemplates,'template');
            String templateID = mapOfTemplates.get('Quote');
            Test.startTest();   
            cscfga__Product_Basket__c basket = [Select id,name,cscfga__Opportunity__c,csbb__Account__c from cscfga__Product_Basket__c basket limit 1];
                Legacy_Service__c legSrvc = new Legacy_Service__c();
                legSrvc.Product_Basket__c = basket.id;
                legSrvc.Product_Type__c = 'Enterprise Mobility';
                legSrvc.Select__c = TRUE;
                legSrvc.Plan_Name__c = 'LegacyAMPlan';
                insert legSrvc;    
            APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
            template.APXTConga4__Name__c = 'Proposed affected services';
            template.Sequence__c = 5;
            insert template;         
            String URL= GenerateQuoteHelper.createQuote(templateID,basket.id);
            Test.stopTest();
            System.assert(URL!=null);
            Quote showChangestoExisting = [Select Changes_to_Existing__c from quote limit 1];
            system.debug('showChangestoExisting@@::' + showChangestoExisting);
            //System.assert(showChangestoExisting.Changes_to_Existing__c==true);
     }

}