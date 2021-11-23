@isTest
    public class UpdateParentSpecSpecAttachmentsTest {

        static testMethod void processTest(){
            
            Account acc=new Account();
            acc.Name='Test Account';
            acc.CIDN__c='987654321';
            acc.ABN__c='1235';
            acc.Customer_Status__c='ACTIVE';
            insert acc;       
            
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            //basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'basket1';
            insert basket;
            
            cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
            config.cscfga__Product_Basket__c = basket.id;
            config.cscfga__Description__c = 'test Description ';
            config.cscfga__Contract_Term__c = 36;
            config.cscfga__Configuration_Status__c = 'Valid';
            
            List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>{config};
                update configList;
           
            csord__Order_Request__c orderReq = new csord__Order_Request__c();
            orderReq.name = 'OR-12121';
            orderReq.csord__Module_Name__c = 'TestReq';
            orderReq.csord__Module_Version__c = '12';
            insert orderReq;
            
            csord__Order__c  pord = new csord__Order__c();
            pord.name = 'TestOrder';
            pord.csord__Account__c = acc.id;
            pord.csord__Status2__c = 'Created';
            pord.csord__Order_Request__c = orderReq.Id;
            pord.csord__Identification__c = 'IDE1322';
            pord.stage__c = 'Being Fulfilled';  
            pord.isMSISDNReserved__c= true;    
            pord.RecordType= [SELECT id  FROM RecordType WHERE DeveloperName = 'MSISDN_Reserved'];      
            insert pord;
            
            
            csord__Order__c  ord = new csord__Order__c();
            ord.name = 'TestOrder';
            ord.csord__Primary_Order__c=pord.id;
            ord.csord__Account__c = acc.id;
            ord.csord__Status2__c = 'Created';
            ord.csord__Order_Request__c = orderReq.Id;
            ord.csord__Identification__c = 'IDE1322';
            ord.stage__c = 'Being Fulfilled';       
            insert ord;
                    
            
            csord__Subscription__c subs = new csord__Subscription__c();
            subs.name = 'TestOrder';
            subs.csord__Account__c = acc.id;
            subs.csord__Order__c = ord.id;
            subs.csord__Identification__c = 'IDE1322';
            subs.csord__Order_Request__c = orderReq.id;
            insert subs;
            
            csord__Service__c ser = new csord__Service__c();
            ser.name = 'TestOrder';
            ser.csord__Order__c = ord.id;
            ser.csord__Subscription__c = subs.id;
            ser.csord__Identification__c =  'IDE1322';
            ser.csord__Order_Request__c = orderReq.id;
            ser.Model__c = 'TestOrder';
               ser.csordtelcoa__Product_Configuration__c = config.id;
            ser.TechnologyType__c = 'Mobile Access';
            insert ser;


            CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
            orchProcessTemplate.Name='Order Prerequisite Process';
            orchProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
            orchProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
            insert orchProcessTemplate;
            
          
            CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
            orchProcess.Name = 'Test Orch Process';
            orchProcess.Order__c= pord.Id;
            orchProcess.has_Inactive_Children__c = 'NA';
            orchProcess.CSPOFA__Orchestration_Process_Template__c = orchProcessTemplate.Id;
            insert orchProcess;
            
            
        
            CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
            step.CSPOFA__Orchestration_Process__c = orchProcess.Id;
            
            
            List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
            steps.add(step);
            
             Attachment att1 = new Attachment();
            att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-2911-eb71-8e13-bd04b7f9824a","additionalAttributes" : {"ServiceId" : "61402022091","IPWirelessProductInstanceID" : "9127db1b-b9f7-4b69-d55b-f856689c1b7e"},"endDate":"","description":"CWP CFS Specification","code":"DMCAT_ProductSpecification_000263","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+ser.Id+'","legacyAttributes":[]}');
            
            att1.Name = 'ServiceSpecifications.json';
            att1.ParentId = ser.Id;
            insert att1;
            
            Test.startTest();
            UpdateParentSpecSpecAttachments  submitOrder = new UpdateParentSpecSpecAttachments();
            List<SObject> result1 = submitOrder.process((List<SObject>)steps);
           Test.stopTest();
            System.assertEquals(result1,submitOrder.process((List<SObject>)steps));
        }   
    }