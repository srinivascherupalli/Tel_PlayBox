@isTest
private class CS_TranslateTransitionNumbertoNCSTest {
    
    static{
        TestDataFactory.generateCommercialSchema();
        csbb__Product_Configuration_Request__c pcIPSite = TestDataFactory.genProdConfRequest('DMCAT_ProductOffering_000304', 'IP Site');
        csbb__Product_Configuration_Request__c ucePDSpec = TestDataFactory.genProdConfRequest('DMCAT_ProductOffering_000323', 'ucePDSpec');
    //String TransitionJSONData='{"Source_System_Id":"Replicator","site":[{"siteName":null,"productList":[{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[],"Service_Type":"Voice","Service_Id":"0893490044","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":""}],"disableCheck":null,"checkValue":false},{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[],"Service_Type":"Voice","Service_Id":"0893490045","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":""}],"disableCheck":null,"checkValue":false}],"Product_Type":"PSTN","disableCheck":null,"checkValue":true},{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[{"Services_To":"0893457399","Services_From":"0893457334","disableCheck":null,"checkValue":false},{"Services_To":"0893457332","Services_From":"0893457300","disableCheck":null,"checkValue":false}],"Service_Type":"Voice","Service_Id":"0893457333","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"In Dial","Association_Role":"Primary"}],"disableCheck":null,"checkValue":false}],"Product_Type":"ISDN2DID","disableCheck":null,"checkValue":true}],"Error_Description":"","Error_Code":"","ADBOR_Id":"402260799"}],"serviceCount":1,"Error_Description":"","Error_Code":"","Correlation_Id":"SFDC_REP_GETSERVICE476dadf94c4f78f9cb","CIDN":"8873362089"}';
        //TestDataFactory.generateAttachment('TransitionJSONData.json', TestDataFactory.jsonDefaultTransitionJSOn, pcIPSite.Id);
    /*Attachment attach = new Attachment(  
                    Name = 'TransitionJSONData.json',
                    body = Blob.valueOf(TransitionJSONData),
                    parentId = pcIPSite.Id
                  );
    
    insert attach;  */
    }

    @isTest static void test_TranslateTransistionNumbertoNCS() {
        List<cscfga__Product_Basket__c> prodBaskets = [SELECT Id, Name FROM cscfga__Product_Basket__c];
        System.debug('prodBasket : ' + prodBaskets);
        List<cscfga__Product_Configuration__c> productConfigs = [SELECT Id, Name, cscfga__product_definition__r.product_Specification__c FROm cscfga__Product_Configuration__c where cscfga__product_definition__r.product_Specification__c='DMCAT_ProductOffering_000304'];
        TestDataFactory.generateAttachment('TransitionJSONData.json', TestDataFactory.jsonDefaultTransitionJSOn, productConfigs[0].Id);
        List<Attachment> attach = [SELECT Id, Name FROM Attachment];

        System.debug('product configuration : ' + productConfigs);
        System.debug('attach : ' + attach);

        List<Attachment> legacyServices = [SELECT Id, Name, Body, BodyLength, ParentId
                                            FROM Attachment
                                            WHERE ParentId IN (SELECT Id FROM cscfga__Product_Configuration__c
                                                    WHERE cscfga__product_definition__r.product_Specification__c = 'DMCAT_ProductOffering_000304'
                                                    AND cscfga__Product_Basket__c = :prodBaskets[0].Id
                                                )
                                            AND Name = 'TransitionJSONData.json'
                                            ];

        System.debug('legacy : ' + legacyServices);
        Test.StartTest();
        CS_TranslateTransitionNumbertoNCS.TranslateTransistionNumbertoNCS(prodBaskets[0].Id);
        Test.stopTest();
        List<Attachment> numbers = [SELECT Id, Name, Body, BodyLength, ParentId FROM Attachment
                                            WHERE ParentId IN (SELECT Id FROM cscfga__Product_Configuration__c
                                                              WHERE cscfga__product_definition__r.product_Specification__c = 'DMCAT_ProductOffering_000323'
                                                              AND cscfga__Product_Basket__c = :prodBaskets[0].Id)
                                           AND Name = 'NumberManagementv1_schema.json'];

        System.debug('list of number : ' + numbers);

        List<Attachment> attach1 = [SELECT Id, Name FROM Attachment];
        System.debug('attach1::'+attach1);
    
        System.assert(attach1.size() > 0);

    }
    
    @isTest static void test_TranslateTransistionNumbertoNCSADBorId() {
        
        List<cscfga__Product_Basket__c> prodBaskets = [SELECT Id, Name FROM cscfga__Product_Basket__c];
        System.debug('prodBasket : ' + prodBaskets);
        List<cscfga__Product_Configuration__c> productConfigs = [SELECT Id, Name, cscfga__product_definition__r.product_Specification__c FROm cscfga__Product_Configuration__c where cscfga__product_definition__r.product_Specification__c='DMCAT_ProductOffering_000304'];
        TestDataFactory.generateAttachment('TransitionJSONData.json', TestDataFactory.jsonDefaultTransitionJSOn, productConfigs[0].Id);
		List<Attachment> attach = [SELECT Id, Name FROM Attachment];

        System.debug('product configuration : ' + productConfigs);
        System.debug('attach : ' + attach);
                
        cscfga__Attribute__c attr = new cscfga__Attribute__c();
        attr.name = 'AdborID';
        attr.cscfga__Product_Configuration__c = productConfigs[0].Id;
        attr.cscfga__Value__c = '262135088';
        Insert attr;

        List<Attachment> legacyServices = [SELECT Id, Name, Body, BodyLength, ParentId
                                            FROM Attachment
                                            WHERE ParentId IN (SELECT Id FROM cscfga__Product_Configuration__c
                                                    WHERE cscfga__product_definition__r.product_Specification__c = 'DMCAT_ProductOffering_000304'
                                                    AND cscfga__Product_Basket__c = :prodBaskets[0].Id
                                                )
                                            AND Name = 'TransitionJSONData.json'
                                            ];
        
        System.debug('legacy : ' + legacyServices);
        Test.StartTest();
        CS_TranslateTransitionNumbertoNCS.TranslateTransistionNumbertoNCS(prodBaskets[0].Id);
        Test.stopTest();
        List<Attachment> numbers = [SELECT Id, Name, Body, BodyLength, ParentId FROM Attachment
                                            WHERE ParentId IN (SELECT Id FROM cscfga__Product_Configuration__c
                                                              WHERE cscfga__product_definition__r.product_Specification__c = 'DMCAT_ProductOffering_000323'
                                                              AND cscfga__Product_Basket__c = :prodBaskets[0].Id)
                                           AND Name = 'NumberManagementv1_schema.json'];

        System.debug('list of number : ' + numbers);
        List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2> rplServiceList = new List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2>();
        for(Attachment att: legacyServices){
            if(att.Body !=null && String.valueOf(att.Body) != null && String.valueOf(att.Body) != ''){
                System.debug('attbody'+att.Body.toString());
                ReplicatorGetServiceDataObject_V2 rplService = (ReplicatorGetServiceDataObject_V2) JSON.deserialize(att.Body.toString(), ReplicatorGetServiceDataObject_V2.Class); 
                rplServiceList.addAll(rplService.site);
            }
        }
        List<Attachment> attach1 = [SELECT Id, Name FROM Attachment];
        System.debug('attach1::'+attach1);
    
        System.assert(attach1.size() > 0);

    }
}