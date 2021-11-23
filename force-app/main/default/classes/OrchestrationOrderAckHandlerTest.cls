@isTest
private class OrchestrationOrderAckHandlerTest {
	
	@TestSetup static void dataSetup() {
		csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Pending';
        //subs.csord__Order__c = ord.id;
        insert subs;
        
        List<csord__Service__c> servs = new List<csord__Service__c>();
		csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csord__Subscription__c = subs.Id;
        serv1.csord__Status__c = 'Pending';
        servs.add(serv1);

        insert servs;

        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Disconnect Pending","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Cancellation Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+serv1.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv1.Id;
        atts.add(att1);
        insert atts;


	}


	static testMethod void serviceProcessTest() {
       	
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c orchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        List<csord__Service__c> subs = [SELECT Id, Name, csord__Status__c from csord__Service__c];
        orchProcess.csordtelcoa__Service__c = subs[0].Id;
        update orchProcess;
        
        system.debug('step'+orchProcess);
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(orchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
		system.debug('step'+step);

        Test.startTest();
        OrchestrationOrderAcknowledgementHandler.UpdateServiceStatusInProgress orderClass = new OrchestrationOrderAcknowledgementHandler.UpdateServiceStatusInProgress();
        List<SObject> result = orderClass.process((List<SObject>)steps);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
        
        Test.stopTest();
        
        System.assertEquals(value.CSPOFA__Status__c,'Complete');
        
        String svcSpecsJSON = csedm.API_1.getServiceSpecificationsById(subs[0].Id);
		List<CS_SpecificationDTO.ServiceSpecification> svcSpecList = CS_SpecificationDTO.parseServiceSpec(svcSpecsJSON, 'FULFILMENT');

		for(CS_SpecificationDTO.ServiceSpecification spec: svcSpecList){
			System.debug('spec.guid::'+spec.guid);
			System.debug('spec.status::'+spec.status);
			System.debug('spec.code::'+spec.code);
			if(spec.guid == '3072dad2-5546-eb71-8e13-bd04b7f9824a'){
				System.assertEquals('Disconnect In Progress', spec.status);
				System.assertEquals('CWPSpec01_Fulfilment', spec.code);

			}
			else if(spec.guid == '3df57fcf-7c28-c50a-140b-0d21e80714e7'){
				System.assertEquals('Cancellation In Progress', spec.status);
				System.assertEquals('IPAccessSpec01_Fulfilment', spec.code);

			}
			else if(spec.guid == '495bbebb-5166-6dce-24cd-648084f6241c'){
				System.assertEquals('In Progress', spec.status);
				System.assertEquals('IPAccessSpec01_Fulfilment', spec.code);

			}
		}
    }
	
}