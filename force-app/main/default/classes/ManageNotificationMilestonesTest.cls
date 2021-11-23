@isTest
private class ManageNotificationMilestonesTest {
	
	@Testsetup
	static void dataSetup(){
		Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
       	csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
		insert ordReq;
        
      	csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
		csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        insert subs;

		List<csord__Service__c> servs = new List<csord__Service__c>();
		csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        servs.add(serv);

        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service2';
        serv1.csord__Identification__c  = 'test identify2';
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csord__Subscription__c = subs.Id;
        serv1.csord__Status__c = 'Service Created';
        serv1.csord__Order_Request__c = ordReq.Id;
        serv1.csord__Order__c = ord.Id;
        servs.add(serv1);
        
        insert servs;

        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        atts.add(att1);

        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"30a0f36c-b496-185e-6330-c7a9c317d223","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}}],"serviceId":"'+serv1.Id+'","legacyAttributes":[]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = serv1.Id;
        atts.add(att2);


        insert atts;

	}

	@isTest
	static void testProcessNotificationRec(){
		csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
		List<String> parameters = new List<String>();
        Notification__c notif = new Notification__c();
		notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
		notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|495bbebb-5166-6dce-24cd-648084f6241c';
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"},{"name":"milestoneName", "value":"Design Completed"},{"name":"milestoneStatus", "value":"Achieved"},{"name":"milestoneStartDate", "value":"2018-02-24T06:08-11:00"},{"name":"milestoneEndDate", "value":"2018-02-29T06:08-11:00"}]';
		notif.orderItemDetails__c = '"product":{"productId":"495bbebb-5166-6dce-24cd-648084f6241c","status":"In Progress","attributes":[{"name":"Customer Facing Service ID","value":"T11111"}]}';
		notif.eventType__c = 'milestoneNotification';
		notif.sourceSystem__c = 'Fulfilment';
		notif.Status__c = 'Pending';
        notif.orderItemVersion__c = 1;
		insert notif;
        
		parameters.add(ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|6789:::"attributes":[{"name":"status", "value":"Complete"},{"name":"MilestoneName", "value":"Design Completed"},{"name":"MilestoneStatus", "value":"Achieved"},{"name":"MilestoneStartDate", "value":"2018-02-24T06:08-11:00"},{"name":"MilestoneEndDate", "value":"2018-02-29T06:08-11:00"}]:::milestoneNotification:::"product":{"productId":"495bbebb-5166-6dce-24cd-648084f6241c","status":"In Progress","attributes":[{"name":"Customer Facing Service ID","value":"T11111"}]}:::Fulfilment'+':::'+notif.Id);
        Test.startTest();
		ManageNotificationMilestones.processNotificationRecord(parameters);
		Test.stopTest();

		csord__Service__c svc2 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        
        String svcSpecsJSON = csedm.API_1.getServiceSpecificationsById(svc2.Id);
		List<CS_SpecificationDTO.ServiceSpecification> svcSpecList = CS_SpecificationDTO.parseServiceSpec(svcSpecsJSON, 'FULFILMENT');

		for(CS_SpecificationDTO.ServiceSpecification spec: svcSpecList){
			System.debug('spec.guid::'+spec.guid);
			System.debug('spec.status::'+spec.status);
			System.debug('spec.code::'+spec.code);
			
			if(spec.guid == '495bbebb-5166-6dce-24cd-648084f6241c'){
				for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
					if(attr.name == 'Customer Facing Service ID'){
						System.assertEquals('Customer Facing Service ID', attr.name); 
						System.assertEquals('T11111', attr.value); 
					}
				}

			}
		}

	}


	@isTest
	static void testupdateServiceRecord(){
		String paramList;
		csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        
        ManageOrderNotificationUtil.Parameters params2 = new ManageOrderNotificationUtil.Parameters();
		params2.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|3072dad2-2911-eb71-8e13-bd04b7f9824a';
		params2.notifyAttributes = '{"attributes":[{"name":"status", "value":"In Progress"}]}';
        params2.orderItemDetails = '{"product":{"productId":"495bbebb-5166-6dce-24cd-648084f6241c","status":"In Progress","attributes":[{"name":"Customer Facing Service ID","value":"T11111"},{"name":"Start Date","value":"2018-05-29T12:00:00-0400"},{"name":"Customer Preferred Name","value":"150 Lonsdale Level 8"},{"name":"Installation Date","value":"2018-05-29T12:00:00-0400"}]}}';
		params2.eventType = 'milestoneNotification';
		paramList = JSON.serialize(params2);

        Notification__c notif = new Notification__c();
		notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|495bbebb-5166-6dce-24cd-648084f6241c';
		notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"In Progress"}]';
        notif.externalOrderId__c = ord.csord__Order_Number__c;
		notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
		notif.orderItemDetails__c = '"product":{"productId":"495bbebb-5166-6dce-24cd-648084f6241c","status":"In Progress","attributes":[{"name":"Customer Facing Service ID","value":"T11111"},{"name":"Start Date","value":"2018-05-29T12:00:00-0400"},{"name":"Customer Preferred Name","value":"150 Lonsdale Level 8"},{"name":"Installation Date","value":"2018-05-29T12:00:00-0400"}]}';
		notif.eventType__c = 'milestoneNotification';
		notif.sourceSystem__c = 'Fulfilment';
		notif.Status__c = 'Pending';
        notif.orderItemVersion__c = 1;
		insert notif;
        
		Test.startTest();
		ManageNotificationMilestones.processMileStones(paramList,String.valueOf(notif.id));
		Test.stopTest();
        
        csord__Service__c svc2 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        String svcSpecsJSON = csedm.API_1.getServiceSpecificationsById(svc2.Id);
		List<CS_SpecificationDTO.ServiceSpecification> svcSpecList = CS_SpecificationDTO.parseServiceSpec(svcSpecsJSON, 'FULFILMENT');
		for(CS_SpecificationDTO.ServiceSpecification spec: svcSpecList){
			System.debug('spec.guid::'+spec.guid);
			System.debug('spec.status::'+spec.status);
			System.debug('spec.code::'+spec.code);
			
			if(spec.guid == '495bbebb-5166-6dce-24cd-648084f6241c'){
				for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
					if(attr.name == 'Customer Facing Service ID'){
						System.assertEquals('Customer Facing Service ID', attr.name); 
						System.assertEquals('T11111', attr.value); 
					}
				}
			}
		}
	}
    
    
    @isTest
	static void testprocessMileStonesChildService(){
		String paramList;
		csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
		ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
		List<String> parameters = new List<String>();
		params.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|495bbebb-5166-6dce-24cd-648084f6241c';
		params.notifyAttributes = '{"attributes":[{"name":"status", "value":"In Progress"}]}';
        params.orderItemDetails = '{"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress","attributes":[{"name":"Customer Facing Service ID","value":"T11111"},{"name":"Start Date","value":"2018-05-29T12:00:00-0400"},{"name":"Customer Preferred Name","value":"150 Lonsdale Level 8"},{"name":"Installation Date","value":"2018-05-29T12:00:00-0400"}],"childProduct":[{"productId":"30a0f36c-b496-185e-6330-c7a9c317d223","status":"In Progress","attributes":[{"name":"Customer Facing Service ID","value":"T11112"},{"name":"Start Date","value":"2018-05-29T12:00:00-0400"},{"name":"Customer Preferred Name","value":"150 Lonsdale Level 8 Port"},{"name":"Installation Date","value":"2018-05-29T12:00:00-0400"}]}]}}';
		params.eventType = 'milestoneNotification';
		paramList = JSON.serialize(params);

        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
		notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|495bbebb-5166-6dce-24cd-648084f6241c';
		notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
		notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"In Progress"}]';
		notif.orderItemDetails__c = '"product":{"productId":"495bbebb-5166-6dce-24cd-648084f6241c","status":"In Progress","attributes":[{"name":"Customer Facing Service ID","value":"T11111"},{"name":"Start Date","value":"2018-05-29T12:00:00-0400"},{"name":"Customer Preferred Name","value":"150 Lonsdale Level 8"},{"name":"Installation Date","value":"2018-05-29T12:00:00-0400"}]}';
		notif.eventType__c = 'milestoneNotification';
		notif.sourceSystem__c = 'Fulfilment';
		notif.Status__c = 'Pending';
        notif.orderItemVersion__c = 1;
		insert notif;
        
		Test.startTest();
		ManageNotificationMilestones.processMileStones(paramList,notif.id);
		Test.stopTest();
		String svcSpecsJSON = csedm.API_1.getServiceSpecificationsById(svc1.Id);
		List<CS_SpecificationDTO.ServiceSpecification> svcSpecList = CS_SpecificationDTO.parseServiceSpec(svcSpecsJSON, 'FULFILMENT');
		for(CS_SpecificationDTO.ServiceSpecification spec: svcSpecList){
			System.debug('spec.guid::'+spec.guid);
			System.debug('spec.status::'+spec.status);
			System.debug('spec.code::'+spec.code);
			
			if(spec.guid == '3072dad2-5546-eb71-8e13-bd04b7f9824a'){

				for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
					if(attr.name == 'Customer Facing Service ID'){
						System.assertEquals('Customer Facing Service ID', attr.name); 
						System.assertEquals('T11111', attr.value); 
					}
				}

			}

			if(spec.guid == '30a0f36c-b496-185e-6330-c7a9c317d223'){

				for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
					if(attr.name == 'Customer Facing Service ID'){
						System.assertEquals('Customer Facing Service ID', attr.name); 
						System.assertEquals('T11111', attr.value); 
					}
				}

			}


		}

	}
    
    
	
}