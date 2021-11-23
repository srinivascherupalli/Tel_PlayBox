/* Description: Test class that covers AppointmentBOMSitePage EDGE-66462
       Author: Pradeep/Aishwarya/Ila/Jawahar
     */

    @isTest
    public class AppointmentBOMSitePageHandlerTestClass {

         public testmethod static void unitTest1(){
            //account
            Account acc = AccountTestFactory.buildAccount('TestAccount');
            insert acc;
            cscrm__Address__c address = new cscrm__Address__c();
             address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
             address.Address_ID__c = '1010101010';
             address.cscrm__Account__c = acc.id; 
             upsert address;
             
             cscrm__Site__c site = new cscrm__Site__c();
             site.cscrm__Account__c = acc.id;
             site.cscrm__Installation_Address__c = address.id;
             site.name = 'Sydney harbour house';
             site.Composite_Key__c = '1211010101010';
             upsert site;
            //order
            csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
            csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
            order.csord__Primary_Order__c= testorder2.id;
            order.isMSISDNReserved__c = true;   
            update order;
          
            
            //subscription and service
            csord__Subscription__c sub = [select id,site__c,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c = :testorder2.id];
            sub.site__c=site.id;
            update sub;
            csord__Service__c serv =[select id, Appointment_Required__c,csord__Subscription__c from csord__Service__c where csord__Subscription__c =: sub.id];
            serv.Appointment_Required__c='true'; 
            update serv;  
             
             List<Required_Appointment__c> lstReq= new List<Required_Appointment__c>();
             Required_Appointment__c req= new Required_Appointment__c(Generate_Appointment_Order__c=order.id,Generate_Appointment_Subscription__c=sub.id, Appointment_Category__c='TELSTRA');
             lstReq.add(req);
             insert lstReq;
            List<Appointment__c> applst= new List<Appointment__c>();
            //appointment
            Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
            applst.add(appt);
            Appointment__c appt1= new Appointment__c(SlotId__c='123456',Category__c='Test1',Subscription__c=sub.id,StartDate__c=System.today(),Status__c ='Partial Complete');
            applst.add(appt1);
            Appointment__c appt2= new Appointment__c(SlotId__c='123457',Category__c='Test1',Subscription__c=sub.id,StartDate__c=System.today(),Status__c ='Complete', Reschdeule_required__c=true,Suggested_Start_Date__c=System.today());
            applst.add(appt2);
            
            insert applst;
            Contact con= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
            insert con;
            List<Functional_Contact_Role__c> fcrlst=new List<Functional_Contact_Role__c>();
            Functional_Contact_Role__c fcr1= new Functional_Contact_Role__c(Role__c='Primary Site Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
            fcrlst.add(fcr1);
            
            Functional_Contact_Role__c fcr2= new Functional_Contact_Role__c(Role__c='Technical Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
            fcrlst.add(fcr2);
            insert fcrlst;
                    
            PageReference pageRef = new PageReference('apex/AppointmentSitePage?id='+testorder2.id);
            Test.setCurrentPage(pageRef); 
            AppointmentBOMSitePageHandler appSpage = new AppointmentBOMSitePageHandler();
            appSpage.SubscriptionId=sub.id;
            appSpage.hasMessageString='true';
            appSpage.AccList=NULL;
            appSpage.displayPopUp=true;
            appSpage.selectedAction='abc';
            appSpage.selectedActionVF='View Details';
            appSpage.displayBookAppointment=true;
            appSpage.displaySaveButton=true;
            appSpage.selectedSite='sa';
            appSpage.bookAppointmentURL='asas';
            //List<csord__Subscription__c> subList =new List<csord__Subscription__c>();
            //subList.add(sub);
            appspage.subDetailsList=new List<csord__Subscription__c>();
            appspage.subDetailsList.add(sub);
            PageReference pageRef1 = new PageReference('apex/AppointmentSitePage?id='+order.id);
            Test.setCurrentPage(pageRef); 
            AppointmentBOMSitePageHandler appSpage1 = new AppointmentBOMSitePageHandler();
            Test.startTest();
            appSpage.closePopup();
            appSpage.setBookAppointmentParams();
            appSpage.setPrimaryOrderID();
            appSpage.getAppDetails();
            appSpage.clearAllOnNoneAction();
            appSpage.pollAppointmentStatus();
               //appSpage.showPopup();
               //appSpage.CancelPopup();
            appSpage.OKPopup();
            appSpage.reRenderApptDetails();
            appSpage.createError(ApexPages.Severity.ERROR,'Appointment should be scheduled for all the sites to proceed.'); 
             // appSpage.hasMessages=true;
             // appSpage.errorMessage='Test 1234';
             // appSpage.alertType='Test 1234';
            PageReference pageRef2 = new PageReference('/'+testorder2.id);
            appSpage.setPrimaryOrderStatus();
            System.assertEquals('View Details', appSpage.selectedActionVF);
            String parsstring='Test12345677';
            AppointmentBOMSitePageHandler.RequiredAppointmentWrapper reqData= new AppointmentBOMSitePageHandler.RequiredAppointmentWrapper();
            Test.stopTest();
        }
        public testmethod static void unitTest2(){
            //account
            Account acc = AccountTestFactory.buildAccount('TestAccount');
            insert acc;
            cscrm__Address__c address = new cscrm__Address__c();
             address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
             address.Address_ID__c = '1010101010';
             address.cscrm__Account__c = acc.id; 
             upsert address;
             
             cscrm__Site__c site = new cscrm__Site__c();
             site.cscrm__Account__c = acc.id;
             site.cscrm__Installation_Address__c = address.id;
             site.name = 'Sydney harbour house';
             site.Composite_Key__c = '1211010101010';
             upsert site;
            //order
            csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
            csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
            order.csord__Primary_Order__c= testorder2.id;     
            update order;
            //subscription and service
            csord__Subscription__c sub = [select id,site__c,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c = :testorder2.id];
            csord__Service__c serv =[select id, Appointment_Required__c,csord__Subscription__c from csord__Service__c where csord__Subscription__c =: sub.id];
            serv.Appointment_Required__c='true'; 
            update serv;  
            
            PageReference pageRef = new PageReference('apex/AppointmentSitePage?id='+testorder2.id);
            Test.setCurrentPage(pageRef); 
            AppointmentBOMSitePageHandler appSpage = new AppointmentBOMSitePageHandler();
            appSpage.hasMessageString='true';
            appSpage.AccList=NULL;
            appSpage.displayPopUp=true;
            appSpage.selectedAction='abc';
            appSpage.selectedActionVF='View Details';
            appSpage.displayBookAppointment=true;
            appSpage.displaySaveButton=true;
            appSpage.selectedSite='sa';
            appSpage.bookAppointmentURL='asas';
            //List<csord__Subscription__c> subList =new List<csord__Subscription__c>();
            //subList.add(sub);
            appspage.subDetailsList=new List<csord__Subscription__c>();
            appspage.subDetailsList.add(sub);
            PageReference pageRef1 = new PageReference('apex/AppointmentSitePage?id='+order.id);
            Test.setCurrentPage(pageRef); 
            AppointmentBOMSitePageHandler appSpage1 = new AppointmentBOMSitePageHandler();
            Test.startTest();
            appSpage.closePopup();
            appSpage.setBookAppointmentParams();
            appSpage.setPrimaryOrderID();
            appSpage.getAppDetails();
            appSpage.clearAllOnNoneAction();
            appSpage.pollAppointmentStatus();
               //appSpage.showPopup();
               //appSpage.CancelPopup();
            appSpage.OKPopup();
            appSpage.reRenderApptDetails();
            appSpage.createError(ApexPages.Severity.ERROR,'Appointment should be scheduled for all the sites to proceed.'); 
            PageReference pageRef2 = new PageReference('/'+testorder2.id);
            appSpage.setPrimaryOrderStatus();
            System.assertEquals('View Details', appSpage.selectedActionVF);
            Test.stopTest();
        }
        
        public testmethod static void unitTest3(){
             //account
            Account acc = AccountTestFactory.buildAccount('TestAccount');
            insert acc;
            cscrm__Address__c address = new cscrm__Address__c();
             address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
             address.Address_ID__c = '1010101010';
             address.cscrm__Account__c = acc.id; 
             upsert address;
             
             cscrm__Site__c site = new cscrm__Site__c();
             site.cscrm__Account__c = acc.id;
             site.cscrm__Installation_Address__c = address.id;
             site.name = 'Sydney harbour house';
             site.Composite_Key__c = '1211010101010';
             upsert site;
            //order
            csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
            csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
            order.csord__Primary_Order__c= testorder2.id;     
            update order;
            
            cscfga__Configuration_Offer__c originatingOffer = new cscfga__Configuration_Offer__c(name ='Test Originating offer');
            insert originatingOffer;
            
            cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
            productConfig.Offer_Reference__c = originatingOffer.id;
            productConfig.Type__c = 'Cancel';
            insert productConfig;
            
            csord__Subscription__c subs=new csord__Subscription__c();
            subs.name  = 'test subs';
            subs.csord__Identification__c = 'test identity';
            subs.Site__c = site.Id;
            subs.csord__Status__c='Subscription Created';
            subs.csordtelcoa__Subscription_Number__c = 'SN-000003199';
            subs.csord__Order__c = Testorder2.id;
            subs.csordtelcoa__Product_Configuration__c = productConfig.id;
            subs.Serviceability_Location__c = 'Urban';
            insert subs;
            PageReference pageRef = new PageReference('apex/AppointmentSitePage?id='+subs.id);
            Test.setCurrentPage(pageRef); 
            AppointmentBOMSitePageHandler appo=new AppointmentBOMSitePageHandler();
            Test.startTest();
        for(csord__Subscription__c sub : [select id, Site__r.Display_Name__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__r.Type__c,site__r.Address__c,Serviceability_Location__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where name = 'test subs' LIMIT 1]){
                appo.generateAppointmentBOMQ();
        } 
            Test.stopTest();
            System.assertNotEquals(subs, NULL);
        }
        
        public testmethod static void unitTest4(){
            
            Account acc=new Account();
            acc.Name='testacc';
            acc.CIDN__c='987654321';
            acc.ABN__c='1235';
            acc.Customer_Status__c='ACTIVE';
            insert acc;
            csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
            testorder2.csord__Status2__c = 'MSISDN Required';   
            update testorder2;
            System.assertNotEquals(testorder2, NULL);
            //order.csord__Primary_Order__c= testorder2.id; 
            PageReference pageRef2 = new PageReference('apex/AppointmentSitePage?id='+testorder2.id);
            Test.setCurrentPage(pageRef2);
            AppointmentBOMSitePageHandler appHandler = new AppointmentBOMSitePageHandler();
            test.startTest();
            appHandler.checkPrimaryOrderStatus(testorder2.id);
            Boolean test1=appHandler.hasMessages;
            string test2=appHandler.errorMessage;
            string test3=appHandler.alertType;
            Test.stoptest();
        }
    }