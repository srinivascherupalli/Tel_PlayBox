@isTest
private class CustomButtonAttachDocumentsTest {
	
	/**
	 * Test adding new attachment
	 */
	@isTest static void testAddAttachment() {

		Account acc = AccountTestFactory.buildAccount('Test Account');
		cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
		Test.setCurrentPageReference(new PageReference('attachDocumentInformation.page'));
		System.currentPageReference().getParameters().put('basketId', basket.Id);		

		Test.startTest();
			CustomButtonAttachDocuments ad = new CustomButtonAttachDocuments();
			ad.save();
		Test.stopTest();	

		// Attachments should exist
		System.assert(ad.extList.size() == 1, 'List size does not equal 1');
	}
    
    /**
	 * Test adding new attachment for Closed Basket
	 */
	@isTest static void testAddAttachmentClosedBasket() {

		createCustomSettingValues();
        Account acc = AccountTestFactory.buildAccount('Test Account');
		cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        update basket;
		Test.setCurrentPageReference(new PageReference('attachDocumentInformation.page'));
		System.currentPageReference().getParameters().put('basketId', basket.Id);		

		Test.startTest();
			CustomButtonAttachDocuments ad = new CustomButtonAttachDocuments();
			String result = ad.performAction(basket.Id);
		Test.stopTest();	
	}
    
    /**
	 * Test adding new attachment for Cancelled Basket
	 */
	@isTest static void testAddAttachmentCancelledBasket() {

		createCustomSettingValues();
        Account acc = AccountTestFactory.buildAccount('Test Account');
		cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = 'Cancelled';
        update basket;
		Test.setCurrentPageReference(new PageReference('attachDocumentInformation.page'));
		System.currentPageReference().getParameters().put('basketId', basket.Id);		

		Test.startTest();
			CustomButtonAttachDocuments ad = new CustomButtonAttachDocuments();
			String result = ad.performAction(basket.Id);
		Test.stopTest();	
	}
	
    /**
	 * Test adding new attachment from Account
	 */
    @isTest static void testAddAttachmentAccount() {

		Account acc = AccountTestFactory.buildAccount('Test Account');
        insert acc;
		Test.setCurrentPageReference(new PageReference('attachDocumentInformation.page'));
		System.currentPageReference().getParameters().put('accountId', acc.Id);		

		Test.startTest();
			CustomButtonAttachDocuments ad = new CustomButtonAttachDocuments();
			ad.save();
		Test.stopTest();	
	}
    
    /**
	 * Test exception
	 */
    @isTest static void testAddAttachmentException() {

		Account acc = AccountTestFactory.buildAccount('Test Account');
		cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
		Test.setCurrentPageReference(new PageReference('attachDocumentInformation.page'));
		System.currentPageReference().getParameters().put('accountId', acc.Id);		

		Test.startTest();
			CustomButtonAttachDocuments ad = new CustomButtonAttachDocuments();
			ad.save();
		Test.stopTest();	
	}
    
	/**
	 * Test cancellation of adding new attachment
	 */
	@isTest static void testCancelAttachment() {
		Account acc = AccountTestFactory.buildAccount('Test Account');
		cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
		Test.setCurrentPageReference(new PageReference('attachDocumentInformation.page'));
		System.currentPageReference().getParameters().put('basketId', basket.Id);

		Test.startTest();
			CustomButtonAttachDocuments ad = new CustomButtonAttachDocuments();
			ad.cancel();
		Test.stopTest();

		// No attachments should exist
		System.assert(ad.extList.size() == 0, 'List size does not equal 0');
	}
    
    /**
	 * Test cancellation of adding new attachment from Account
	 */
	@isTest static void testCancelAttachmentAccount() {
		Account acc = AccountTestFactory.buildAccount('Test Account');
        insert acc;
		Test.setCurrentPageReference(new PageReference('attachDocumentInformation.page'));
		System.currentPageReference().getParameters().put('accountId', acc.Id);

		Test.startTest();
			CustomButtonAttachDocuments ad = new CustomButtonAttachDocuments();
			ad.cancel();
		Test.stopTest();
	}

	/**
	 * Test deleting attachment
	 */
	@isTest static void testDeleteAttachment() {

		Account acc = AccountTestFactory.buildAccount('Test Account');
		cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
		Test.setCurrentPageReference(new PageReference('attachDocumentInformation.page'));
		System.currentPageReference().getParameters().put('basketId', basket.Id);		

		Test.startTest();
			CustomButtonAttachDocuments ad = new CustomButtonAttachDocuments();
			External_Attachment__c extAddDelete = new External_Attachment__c();
			insert extAddDelete;
			ad.extList.add(extAddDelete);
			ad.selectedAtt = extAddDelete.Id;
			ad.deleteAtt();
		Test.stopTest();

		// No attachments should exist
		System.assert(ad.extList.size() == 0, 'List size does not equal 0');
	}

	/**
	 * Test deleting attachment
	 */
	@isTest static void testEditAttachment() {

		Account acc = AccountTestFactory.buildAccount('Test Account');
		cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
		Test.setCurrentPageReference(new PageReference('attachDocumentInformation.page'));
		System.currentPageReference().getParameters().put('basketId', basket.Id);		

		Test.startTest();
			CustomButtonAttachDocuments ad = new CustomButtonAttachDocuments();
			External_Attachment__c extAddEdit = new External_Attachment__c(File_Name__c = 'Edit Test');
			insert extAddEdit;
			ad.extList.add(extAddEdit);
			ad.selectedAtt = extAddEdit.Id;
			extAddEdit.File_Name__c = 'Edit Test Updated';
			ad.editAtt();
		Test.stopTest();

		// No attachments should exist
		System.assert(extAddEdit.File_Name__c == 'Edit Test Updated', 'Record has not been updated');
	}	
    
    
    /**
	 * Test editing attachment from Account
	 */
	@isTest static void testEditAttachmentAccount() {

		Account acc = AccountTestFactory.buildAccount('Test Account');
        insert acc;
		Test.setCurrentPageReference(new PageReference('attachDocumentInformation.page'));
		System.currentPageReference().getParameters().put('accountId', acc.Id);		

		Test.startTest();
			CustomButtonAttachDocuments ad = new CustomButtonAttachDocuments();
			External_Attachment__c extAddEdit = new External_Attachment__c(File_Name__c = 'Edit Test');
			insert extAddEdit;
			ad.extList.add(extAddEdit);
			ad.selectedAtt = extAddEdit.Id;
			extAddEdit.File_Name__c = 'Edit Test Updated';
			ad.editAtt();
		Test.stopTest();
	}

    static void createCustomSettingValues() {
 
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Service Detailing'); 
        customSetting.Name = 'ServiceDetailing';
        customSetting.External_Id__c = 'CCO_T_1';
        insert customSetting;

        CustomConfigurationOptions__c customSetting1 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Valid'); 
        customSetting1.Name = 'ClosedWon';
        customSetting1.External_Id__c = 'CCO_T_2';
        insert customSetting1;

        CustomConfigurationOptions__c customSetting2 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Cancelled');
        customSetting2.Name = 'CancelBasket';
        customSetting2.External_Id__c = 'CCO_T_3';
        insert customSetting2;
    }    

	
}