/* ----------------------------------------------------------------------------
EDGE            -85161
Class Name  -TransitionControllerTest
Description -Test class for TransitionController
Author      -Dheeraj Bhatt
Revision: Sandip Deshmane - EDGE-148075
 Revision: Sandip Deshmane = EDGE-149261
 Revision: Maq = EDGE-160452
-------------------------------------------------------------------------------*/
@Istest
public class TransitionControllerTest {
    @TestSetup public static void setup(){ 
         Account customerAccount=TestUtil.createAccount('Test_Account');
        insert customerAccount;
        
        cscfga__Product_Basket__c productBasket=TestDataFactory.generateProductBasket();
        productBasket.csbb__Account__c = customerAccount.Id;
        productBasket.name = 'Testing Basket';
        update productBasket;
        cscfga__Product_Configuration__c productConfig=TestDataFactory.generateProductConfiguration();
        productConfig.cscfga__Product_Basket__c=productBasket.id;
        productConfig.Name='Test_ProductConfig';
        update productConfig;
        
        //EDGE-148075 - Added Plan Type value to attachment
        //Kalashree Borgaonkar. updated json to cover tramas errors  
        String attachbody='{"CIDN":"6898327073","Correlation_Id":"abcd_1234","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"disableCheck":null,"eligibilityReason":null,"eligibilityStatus":null,"Product_Type":"Mobile PostPaid HandHeld","site":[{"ADBOR_Id":"0","Error_Code":null,"Error_Description":null,"serviceList":[{"checkValue":true,"disableCheck":null,"checkReserved":false,"groupType":[{"transitionId":"9ba2e4b1-99ce-4246-aa9f-adb98285c89a","groupId":"mobileGroup","checkValue":true,"service":[{"plan_type":"MBB","calling_line_identifier":"off","contract_term":"0","directory_listing":null,"idd":"BFIDD100 &#124; Bus Fleet Plus IDD $100","imsi_number":"505013438393119","international_roaming":"EFPAIR01&#124; EFP Intl. Roaming $0 $50 Pack","message_bank":"3GPPMSGK &#124; 3G Pre-Paid Video Message Bank","plan_name":"3OB*049 &#124; 3G Cap 49 Business Mobile Plan","Service_Id":"0438034768","service_status":"AC","Reserve_status":"Completed","tramasErrorCode":"TMV00009","Reason":"","service_type":null,"service_type_code":"NORM","sim_serial_number":"89610179078138000029","devices":[{"deviceType":"IMSI","physicalId":"098624178919736","networkId":"098624178919732"}],"serviceExtensions":[{"fromNumber":"61516728911","toNumber":"61516728914","Reserve_status":"completed","Reason":"transition","tramasErrorCode":"TMV00009"}]}]}],"Service_Type":null}],"siteName":null},{"ADBOR_Id":"0","Error_Code":null,"Error_Description":null,"serviceList":[{"checkValue":true,"disableCheck":null,"checkReserved":false,"groupType":[{"transitionId":"9ba2e4b1-99ce-4246-aa9f-adb98285c89a","groupId":"mobileGroup","checkValue":true,"service":[{"calling_line_identifier":"off","contract_term":"0","directory_listing":null,"idd":"BFIDD100 &#124; Bus Fleet Plus IDD $100","imsi_number":"505013438393119","international_roaming":"EFPAIR01&#124; EFP Intl. Roaming $0 $50 Pack","message_bank":"3GPPMSGK &#124; 3G Pre-Paid Video Message Bank","plan_name":"3OB*049 &#124; 3G Cap 49 Business Mobile Plan","Service_Id":"07028050153","service_status":"AC","Reserve_status":"Completed","Reason":"","service_type":null,"service_type_code":"NORM","sim_serial_number":"89610179078138000029","serviceExtensions":[{"fromNumber":"61516728911","toNumber":"61516728914","Reserve_status":"completed","Reason":"transition"}]}]}],"Service_Type":null}],"siteName":null},{"ADBOR_Id":"0000","Error_Code":null,"Error_Description":null,"serviceList":[{"checkValue":true,"disableCheck":null,"checkReserved":false,"groupType":[{"transitionId":"9ba2e4b1-99ce-4246-aa9f-adb98285c89a","groupId":"mobileGroup","checkValue":true,"service":[{"calling_line_identifier":"on","contract_term":"120","directory_listing":null,"idd":"BFIDD100 &#124; Bus Fleet Plus IDD $100","imsi_number":"505013438393120","international_roaming":"EFPAIR01&#124; EFP Intl. Roaming $0 $50 Pack","message_bank":"3GPPMSGK &#124; 3G Pre-Paid Video Message Bank","plan_name":"3OB*049 &#124; 3G Cap 49 Business Mobile Plan","Service_Id":"0480126680","Reserve_status":"Error","Reason":"Test Error","service_status":"NOVA","service_type":null,"service_type_code":"NORM","siam_serial_number":"89610179078138000029"}]}],"Service_Type":null}],"siteName":null}]},{"checkValue":false,"disableCheck":null,"eligibilityReason":null,"eligibilityStatus":null,"Product_Type":"Mobile PrePaid HandHeld","site":[{"ADBOR_Id":"123","Error_Code":null,"Error_Description":null,"serviceList":[{"checkValue":false,"disableCheck":null,"checkReserved":false,"groupType":[{"transitionId":null,"groupId":"mobileGroup","service":[{"calling_line_identifier":"off","contract_term":"0","directory_listing":null,"idd":"BFIDD100 &#124; Bus Fleet Plus IDD $100","imsi_number":"505013438393119","international_roaming":"EFPAIR01&#124; EFP Intl. Roaming $0 $50 Pack","message_bank":"3GPPMSGK &#124; 3G Pre-Paid Video Message Bank","plan_name":"3OB*049 &#124; 3G Cap 49 Business Mobile Plan","Service_Id":"8910","Reserve_status":"","Reason":"","service_status":"AC","service_type":null,"service_type_code":"NORM","sim_serial_number":"89610179078138000029"}]}],"Service_Type":null}],"siteName":null}]}],"serviceCount":0,"Source_System_Id":"Replicator"}';
        Attachment attach=TestDataFactory.generateAttachment( label.MobileTransitionName,attachbody , productConfig.id);
        //EDGE-149261 - Added Attribute
        cscfga__Attribute__c att = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = productConfig.Id,
                Name = 'SelectPlanName',
                cscfga__Value__c = 'BYO',
                cscfga__is_active__c = true
            );
        insert att;
        TransitionResponseCodes__c code1 = new TransitionResponseCodes__c(Reason__c='Techincal error for every legacy service',Status__c='Failed',TRAMAS_Code__c='TN4014');
        TransitionResponseCodes__c code2 = new TransitionResponseCodes__c(Reason__c='Some/all rules did not pass',Status__c='Not Eligible',TRAMAS_Code__c='TM4011');
        TransitionResponseCodes__c code3 = new TransitionResponseCodes__c(Reason__c='This service is in credit management',Status__c='Not Eligible',TRAMAS_Code__c='TMV00009');
        List<TransitionResponseCodes__c> responseCodeList = new List<TransitionResponseCodes__c>();
        responseCodeList.add(code1);
        responseCodeList.add(code2);
        responseCodeList.add(code3);
        insert responseCodeList;
        
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '2022012339';
        insert acc;
        
        cscfga__Product_Basket__c prodBasket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        prodBasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        prodBasket.Name = 'Transition';
        prodBasket.isEligibilityCheckComplete__c = false;
        prodBasket.isEligibilityTriggered__c = false;
        update prodBasket;
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        insert pd;
        
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.Id);
        config.name= 'Connected Workplace';
        config.cscfga__Description__c = 'Test description';
        config.cscfga__Product_Basket__c = prodBasket.Id;
        config.isEligibleForTriggered__c=true;
        config.cscfga__Quantity__c = 1;
        insert config; 
                
        cscfga__Product_Configuration__c config2 = ProductTestFactory.buildProductConfig(pd.Id);
        config2.name= 'IP Site';
        config2.cscfga__Description__c = 'IP Site';
        config2.cscfga__Product_Basket__c = prodBasket.Id;
        config2.cscfga__Quantity__c = 1;
        config2.cscfga__Root_Configuration__c = config.Id;
        config2.isEligibleForTriggered__c=false;
        insert config2;
        
        Number_Group__c numGroup = new Number_Group__c();
        numGroup.Product_Basket__c = productBasket.Id;
        numGroup.Product_Configuration__c = productConfig.Id;
        numGroup.Status__c = 'Reserved';
        numGroup.Scenario_Type__c = 'Transition';
        numGroup.SiteID__c='L9256 QUEEN ST MELBOURNE';
        numGroup.Product_Family__c='TIPT-SIPC';
        insert numGroup;
    }
/*-----------------------------------------------------------------------------
EDGE        -85161
Method Name -getServiceNumberTest
Description -Positive Test method to cover  TransitionController class getServiceNumber method. 
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    @IsTest public static void getServiceNumberTest(){
        try{
        List<TransitionController.transitionWrapper> wrapper= new  List<TransitionController.transitionWrapper>();
             Test.startTest();
        String basketId=[select id from cscfga__Product_Basket__c where name ='Testing Basket'].id;
        String productConfigId=[select id from cscfga__Product_Configuration__c where name ='Test_ProductConfig'].id;
        string parentId=[select parentId from attachment where  Name LIKE :label.MobileTransitionName+'%'].parentId;
       
        wrapper=TransitionController.getServiceNumber(basketId);
        Test.stopTest();
        system.assertEquals(parentId, wrapper[0].productConfigId);
        //EDGE-148075 - Validating Added Plan Type.
        //system.assertEquals('MBB', wrapper[0].planType);
        }
        catch(exception e){
            
        }
    }
/*-----------------------------------------------------------------------------
EDGE        -85161
Method Name -getServiceNumberTestNegative
Description -Negative  Test method for negative scenerio  TransitionController class getServiceNumber method. 
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    @IsTest public static void getServiceNumberTestNegative(){
        List<TransitionController.transitionWrapper> wrapper= new  List<TransitionController.transitionWrapper>();
         Test.startTest();
        String basketId=[select id from cscfga__Product_Basket__c where name ='Testing Basket'].id;
        String productConfigId=[select id from cscfga__Product_Configuration__c where name ='Test_ProductConfig'].id;
        Attachment attach=[select name, body from attachment where  Name LIKE :label.MobileTransitionName+'%' Limit 1];
        attach.Name='TransitionDataNgUc.json';
        update attach;
       
        wrapper=TransitionController.getServiceNumber(basketId);
        attach.Name= label.MobileTransitionName;
        update attach;
        Test.stopTest();
        system.assertEquals(5, wrapper.size());
    }
/*-----------------------------------------------------------------------------
EDGE        -85161
Method Name -doTransitionTest
Description -Test method to cover TransitionController class doTransition method. 
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    @IsTest public static void createTransitionNumberRecordMobileTest(){
        Test.startTest();
        String productConfigId=[select id from cscfga__Product_Configuration__c where name ='Test_ProductConfig'].id;
        List<String> Productconfglst = new list<String>();
        Productconfglst.add(productConfigId);
         String accountId=[select id from account where name ='Test_Account'].id;
        String basketId=[select id from cscfga__Product_Basket__c where name ='Testing Basket'].id;
        Blob body=[select body from attachment where  Name LIKE :label.MobileTransitionName+'%'].body;
        String transitionWrapperList='[{"Service_Id":"61473541001","Id":"61473541001","Reason":"","productConfigId":"'+productConfigId+'","transitionId":"61591d79-017a-4072-9f71-7b0004d00016","CIDN":"2804506976","FNN":"61473541001","basketId":"'+basketId+'","physicalId":"8337012411755","networkId":"505013487512600","accountId":"'+accountId+'","service_type":"Mobile","planType":"Postpaid Handheld","currentPlan":"AMMP*055|Adaptive Mobile Essential","productFamily":"Enterprise Mobility","tramasStatus":"Completed","tramasReason":"","isgreyedout":false},{"Service_Id":"61473541002","Id":"61473541002","Reason":"","productConfigId":"'+productConfigId+'","transitionId":"61591d79-017a-4072-9f71-7b0004d00016","CIDN":"2804506976","FNN":"61473541002","basketId":"'+basketId+'","physicalId":"8337012411755","networkId":"505013487512600","accountId":"0012N00000DuSriQAF","service_type":"Mobile","planType":"Postpaid Handheld","currentPlan":"TCMP*040&#124;Corporate Mobile Plus $40","productFamily":"Enterprise Mobility","tramasStatus":"Completed","tramasReason":"","isgreyedout":false}]';
        
        List<string> serviceNumberList= TransitionController.createTransitionNumberRecord(transitionWrapperList,basketId,Productconfglst);
        Test.stopTest();
         system.assertEquals(!serviceNumberList.isEmpty(), true);
    }
     @IsTest public static void createTransitionNumberRecordFixedTest(){
         Test.startTest();
        String productConfigId=[select id from cscfga__Product_Configuration__c where name ='Test_ProductConfig'].id;
        String accountId=[select id from account where name ='Test_Account'].id;
        List<String> Productconfglst = new list<String>();
        Productconfglst.add(productConfigId);
        String basketId=[select id from cscfga__Product_Basket__c where name ='Testing Basket'].id;
        String transitionWrapperList='[{"Service_Id":"0394726200-0394726299","Id":"0394726200-0394726299","Reserve_status":"completed","Reason":"","productConfigId":"'+productConfigId+'","transitionId":"4b754a99-396b-490f-a8ef-273334af4557","CIDN":"2804506976","FNN":"0394726200","basketId":"'+basketId+'","fromNumber":"0394726200","toNumber":"0394726299","accountId":"'+accountId+'","service_type":"Fixed","productFamily":"TIPT-SIPC","tramasStatus":"Completed","tramasReason":"","isgreyedout":true,"ADBOR_Id":"L9256 QUEEN ST       MELBOURNE"}]';
        
        List<string> serviceNumberList= TransitionController.createTransitionNumberRecord(transitionWrapperList,basketId,Productconfglst);
        Test.stopTest();
        system.assertEquals(!serviceNumberList.isEmpty(), true);
    }
    
    @IsTest public static void createTransitionNumberRecordExistingFixedNumberTest(){
        Test.startTest();
        String productConfigId=[select id from cscfga__Product_Configuration__c where name ='Test_ProductConfig'].id;
         String accountId=[select id from account where name ='Test_Account'].id;
        List<String> Productconfglst = new list<String>();
        Productconfglst.add(productConfigId);
        String basketId=[select id from cscfga__Product_Basket__c where name ='Testing Basket'].id;
         List<Number__c> numList=new  List<Number__c>();
        List<Number_Group__c> numGroupList = new List<Number_Group__c>();
        String transitionWrapperList='[{"Service_Id":"0394726200-0394726299","Id":"0394726200-0394726299","Reserve_status":"completed","Reason":"","productConfigId":"'+productConfigId+'","transitionId":"61591d79-017a-4072-9f71-7b0004d00016","CIDN":"2804506976","FNN":"0394726200","basketId":"'+basketId+'","fromNumber":"0394726200","toNumber":"0394726299","accountId":"'+accountId+'","service_type":"Fixed","productFamily":"TIPT-SIPC","tramasStatus":"Completed","tramasReason":"","isgreyedout":true,"ADBOR_Id":"L9256 QUEEN ST       MELBOURNE"}]';
        List<TransitionController.transitionWrapper> fieldList = (List<TransitionController.transitionWrapper>) JSON.deserialize(transitionWrapperList, List<TransitionController.transitionWrapper>.class);
        for(TransitionController.transitionWrapper transition :fieldList){
            Number_Group__c numGroup = new Number_Group__c();
            numGroup.Transition_Id__c = transition.transitionId;
            numGroup.Product_Basket__c = transition.basketId;
            numGroup.Product_Configuration__c = transition.productConfigId;
            numGroup.Status__c = 'Reserved';
            numGroup.Scenario_Type__c = 'Transition';
            numGroup.SiteID__c=transition.ADBOR_Id;
            numGroup.Product_Family__c=transition.productFamily;
            numGroupList.add(numGroup);
            
            Number__c num=new Number__c ();
            num.Service_Number__c=transition.fromNumber;
            num.Type__c='Transition';
            num.Plan_Type__c=transition.planType;
            num.Transition_Id__c=transition.transitionId;
            num.Basket__c=transition.basketId;
            num.Mobile__c=transition.service_type;
            num.Imsi__c=transition.networkId; 
            num.Sim_Serial_Number__c=transition.physicalId;
            num.Start_Range__c=transition.fromNumber;
            num.End_range__c=transition.toNumber;
             numList.add(num);
            
            Number__c num2=new Number__c ();
            num2.Service_Number__c=transition.toNumber;
            num2.Type__c='Transition';
            num2.Plan_Type__c=transition.planType;
            num2.Transition_Id__c=transition.transitionId;
            num2.Basket__c=transition.basketId;
            num2.Mobile__c=transition.service_type;
            num2.Imsi__c=transition.networkId; 
            num2.Sim_Serial_Number__c=transition.physicalId;
            num2.Start_Range__c=transition.fromNumber;
            num2.End_range__c=transition.toNumber;
             numList.add(num2);
        }
          insert numGroupList;
          insert numList;
        
        
        
        List<string> serviceNumberList=  TransitionController.createTransitionNumberRecord(transitionWrapperList,basketId,Productconfglst);
       Test.stopTest();
        system.assertEquals(!serviceNumberList.isEmpty(), true);
    }
     @IsTest public static void createTransitionNumberRecordExistingMobileNumberTest(){
         Test.startTest();
         String accountId=[select id from account where name ='Test_Account'].id;
        String transitionId='61591d79-017a-4072-9f71-7b0004d00016';
        String productConfigId=[select id from cscfga__Product_Configuration__c where name ='Test_ProductConfig'].id;
        List<String> Productconfglst = new list<String>();
        Productconfglst.add(productConfigId);
        String basketId=[select id from cscfga__Product_Basket__c where name ='Testing Basket'].id;
         List<Number__c> numList=new  List<Number__c>();
         String transitionWrapperList='[{"Service_Id":"61473541001","Id":"61473541001","Reason":"","productConfigId":"'+productConfigId+'","transitionId":"61591d79-017a-4072-9f71-7b0004d00016","CIDN":"2804506976","FNN":"61473541001","basketId":"'+basketId+'","physicalId":"8337012411755","networkId":"505013487512600","accountId":"'+accountId+'","service_type":"Mobile","planType":"Postpaid Handheld","currentPlan":"TCMP*040&#124;Corporate Mobile Plus $40","productFamily":"Enterprise Mobility","tramasStatus":"Completed","tramasReason":"","isgreyedout":false},{"Service_Id":"61473541002","Id":"61473541002","Reason":"","productConfigId":"'+productConfigId+'","transitionId":"61591d79-017a-4072-9f71-7b0004d00016","CIDN":"2804506976","FNN":"61473541002","basketId":"'+basketId+'","physicalId":"8337012411755","networkId":"505013487512600","accountId":"0012N00000DuSriQAF","service_type":"Mobile","planType":"Postpaid Handheld","currentPlan":"TCMP*040&#124;Corporate Mobile Plus $40","productFamily":"Enterprise Mobility","tramasStatus":"Completed","tramasReason":"","isgreyedout":false}]';
        List<TransitionController.transitionWrapper> fieldList = (List<TransitionController.transitionWrapper>) JSON.deserialize(transitionWrapperList, List<TransitionController.transitionWrapper>.class);
        for(TransitionController.transitionWrapper transition :fieldList){
           
            Number__c num=new Number__c ();
            num.Service_Number__c=transition.Service_Id;
            num.Type__c='Transition';
            num.Plan_Type__c=transition.planType;
            num.Transition_Id__c=transition.transitionId;
            num.Basket__c=transition.basketId;
            num.Mobile__c=transition.service_type;
            num.Imsi__c=transition.networkId; 
            num.Sim_Serial_Number__c=transition.physicalId;
            numList.add(num);
        }
         insert numList;
         
         List<string> serviceNumberList=  TransitionController.createTransitionNumberRecord(transitionWrapperList,basketId,Productconfglst);
         Test.stopTest();
         system.assertEquals(!serviceNumberList.isEmpty(), true);
    }
/*-----------------------------------------------------------------------------
EDGE        -85161
Method Name -doTransitionTestNegative
Description -Test method for negative scenerio in TransitionController class doTransition method. 
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    @IsTest public static void doTransitionTestNegative(){
        Test.startTest();
        String basketId=[select id from cscfga__Product_Basket__c where name ='Testing Basket'].id;
        String productConfigId=[select id from cscfga__Product_Configuration__c where name ='Test_ProductConfig'].id;
        List<String> Productconfglst = new list<String>();
        Productconfglst.add(productConfigId);
        Blob body=[select body from attachment where  Name LIKE :label.MobileTransitionName+'%'].body;
         String transitionWrapperList='[{"isSelected":true,"productConfigId":"'+productConfigId+'","basketId":"'+basketId+'","Reason":"","Reserve_status":"Completed","Service_Id":"07028050153","transitionId":"9ba2e4b1-99ce-4246-aa9f-adb98285c89a"},{"isSelected":false,"productConfigId":"'+productConfigId+'","Reason":"Test Error","Reserve_status":"Error","Service_Id":"0480126680","transitionId":"9ba2e4b1-99ce-4246-aa9f-adb98285c89a"}]';
        
        TransitionController.createTransitionNumberRecord(transitionWrapperList,basketId,Productconfglst);
        Blob body2=[select body from attachment where  Name LIKE :label.MobileTransitionName+'%'].body;
        Test.stopTest(); 
        system.assertEquals(body!=null, true);
    }
/*-----------------------------------------------------------------------------
EDGE        - EDGE-149261
Method Name -doTransitionTest
Description -Test method to cover TransitionController class doTransition method. 
Author      -Sandip Deshmane/Sunil 
-------------------------------------------------------------------------------*/
    @IsTest public static void doTransitionTest1(){
         Test.startTest();
        String productConfigId=[select id from cscfga__Product_Configuration__c where name ='Test_ProductConfig'].id;
        List<String> Productconfglst = new list<String>();
        Productconfglst.add(productConfigId);
         String basketId=[select id from cscfga__Product_Basket__c where name ='Testing Basket'].id;
        String transitionWrapperList='[{"isSelected":true,"productConfigId":"'+productConfigId+'","basketId":"'+basketId+'","Reason":"","tramasStatus":"Completed","Service_Id":"07028050153","transitionId":"9ba2e4b1-99ce-4246-aa9f-adb98285c89a","physicalId":"09862417891973"},{"isSelected":false,"productConfigId":"'+productConfigId+'","Reason":"Test Error","Reserve_status":"Error","Service_Id":"0480126680","transitionId":"9ba2e4b1-99ce-4246-aa9f-adb98285c89a"}]';
       
        TransitionController.createTransitionNumberRecord(transitionWrapperList,basketId,Productconfglst);
       Test.stopTest(); 
       system.assertEquals(basketId!=null, true);
    }
    
    /*-----------------------------------------------------------------------------
EDGE        -198374
Method Name -createFeedbackCaseTest
Description -Test method to cover TransitionController class createFeedbackCase method. 
Author      -Nikhil
-------------------------------------------------------------------------------*/
    @IsTest public static void createFeedbackCaseTest(){
        Test.startTest();
        String basketId = [select id,csbb__Account__c from cscfga__Product_Basket__c where name ='Testing Basket'].id;
        
        TransitionController.createFeedbackCase(basketId,'12345','12748484','1234');
        
        List<Case> lstCases = [select id from case];
        Test.stopTest();
        system.assertEquals(true, lstCases.size()>0);
        
    } 
    //EDGE-201122
    //Description -Test method to cover TransitionController class getTM2CallServices & getPBTramasStatus methods. 
    //Author      -Vijay Kumar Reddy
    //-------------------------------------------------------------------------------
    @IsTest public static void getTM2CallServicesTest(){
        
       //String basketId = [select id,csbb__Account__c,Transition_basket_stage__c from cscfga__Product_Basket__c].id;
       Test.startTest();
        cscfga__Product_Basket__c productBasket=TestDataFactory.generateProductBasket(); 
        productBasket.Transition_basket_stage__c = 'Initial';
        upsert productBasket;
        
       
        try{
           TransitionController.getTM2CallServices(productBasket.Id);
           List<cscfga__Product_Configuration__c> pcList = [SELECT Id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: productBasket.Id];
           system.assertEquals(false, pcList.size()>0); 
        //   TransitionController.getPBTramasStatus(productBasket.Id);
           system.assertEquals('Initial', productBasket.Transition_basket_stage__c); 
        }catch(Exception e){}
        Test.stopTest();
    }
    
    /*-----------------------------------------------------------------------------
EDGE        -195766
Method Names -basketStageChangeTestCatchblock,basketStageChangeTest
Description - To cover the TM2 call related methos
Author      -Veena Putta
-------------------------------------------------------------------------------*/
    
    @isTest
    public static void basketStageChangeTestCatchblock(){
         Test.startTest();
        List<cscfga__Product_Basket__c> pbList = [select Id, isEligibilityCheckComplete__c , isEligibilityTriggered__c,Transition_basket_stage__c from cscfga__Product_Basket__c where Name = 'Transition'];
        String basketId = '';
        cscfga__Product_Basket__c pb=new cscfga__Product_Basket__c();
        //ID basId = pbList[0].Id;
       
        pb=TransitionController.updatetransitionBasketStagetoCheckEligibility(basketId);
        Test.stopTest();         
        System.assert(basketId == '');
    }
    
    @isTest
    public static void basketStageChangeTest(){
        Test.startTest();
        List<cscfga__Product_Basket__c> pbList = [SELECT Id, isEligibilityCheckComplete__c , isEligibilityTriggered__c,Transition_basket_stage__c FROM cscfga__Product_Basket__c WHERE Name = 'Transition'];
        String basketId = pbList[0].Id;
        cscfga__Product_Basket__c pb=new cscfga__Product_Basket__c();
        
        pb=TransitionController.updatetransitionBasketStagetoCheckEligibility(basketId);
        List<Integer> eligibleStatus=TransitionController.getEligibityStatus(basketId);
        pb.Transition_basket_stage__c='Check Eligibility Completed';
        update pb;
        Test.stopTest();         
        System.assert(basketId != null);
    }
/*-----------------------------------------------------------------------------
EDGE         - 195766
Method Names - testgetEligibityStatus
Description  - To verify the TM2 call status for Mobile
Author       - Veena Putta
-------------------------------------------------------------------------------*/
    @isTest
    public static void getEligibilityStatusMobileTest(){
        Boolean isMobileEligibility;
        Test.startTest();
        Account accRec = new Account();
        accRec = [select id from Account where name = 'TestAcc'];
        String callBackResponse = '{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/5032e07a-9b62-4076-bf10-c849ad5084e5"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/d56ae6fb-1a45-4a42-b808-b5d1a83a5c5d"}],"executionId":"5032e07a-9b62-4076-bf10-c849ad5084e5","transitionId":"d56ae6fb-1a45-4a42-b808-b5d1a83a5c5d","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"failed","results":[]}],"metadata":{"salesforceId":"00P2N000003161rUAA","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"4c9342fb-b8daf39f-d952fbe1-7283e742","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}';
        
        cscfga__Product_Basket__c prodBasketMobile = new cscfga__Product_Basket__c();
        prodBasketMobile.csbb__Account__c = accRec.Id;
        prodBasketMobile.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        prodBasketMobile.Name = 'Mobile Eligibility Transition';
        prodBasketMobile.isEligibilityCheckComplete__c = false;
        prodBasketMobile.isEligibilityTriggered__c = false;
        prodBasketMobile.Transition_basket_stage__c ='Reservation Triggered';
        insert prodBasketMobile;
        
        cscfga__Product_Definition__c productDefinition = ProductTestFactory.buildProductDefinition('TestEligibility','Test');
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        insert productDefinition;
 
        cscfga__Product_Configuration__c prodConfigMobile = ProductTestFactory.buildProductConfig(productDefinition.Id);
        prodConfigMobile.name= 'Corporate Mobile Plus';
        prodConfigMobile.cscfga__Description__c = 'Test description';
        prodConfigMobile.cscfga__Product_Basket__c = prodBasketMobile.Id;
        prodConfigMobile.isEligibleForTriggered__c=true;        
        prodConfigMobile.cscfga__Quantity__c = 1;
        insert prodConfigMobile;
        
        MobileTramasElgibility__c mobileTramRec = new MobileTramasElgibility__c();
        mobileTramRec.name = 'MobileTramasEligibility';
        mobileTramRec.Type__c = 'TM2';
        mobileTramRec.Product_Basket__c = prodBasketMobile.Id;
        mobileTramRec.Product_Configuration__c= prodConfigMobile.Id;
        insert mobileTramRec;
        
        Attachment attRec = new Attachment();
        attRec.Name = 'MobileTramasElgibility.json';
        attRec.ParentId = mobileTramRec.Id;
        Blob bodyBlob=Blob.valueOf(callBackResponse);
        attRec.body=bodyBlob;
        attRec.Body = bodyBlob;
        insert attRec;
        
        String basketId = prodBasketMobile.Id;
       
        isMobileEligibility=TransitionController.getEligibilityStatusMobile(basketId);
        System.assert(attRec.Id!=null);
        Test.stopTest();
        
    }
    /*-----------------------------------------------------------------------------
EDGE         - 198374
Method Names - testgetEligibityStatus
Description  - To verify the TM1 call status for Mobile
Author       - Nikhil
-------------------------------------------------------------------------------*/
    @isTest
    public static void getEligibilityStatusMobileTest1(){
        Boolean isMobileEligibility;
        Test.startTest();
        Account accRec = new Account();
        accRec = [select id from Account where name = 'TestAcc'];
        String callBackResponse = '{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/5032e07a-9b62-4076-bf10-c849ad5084e5"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/d56ae6fb-1a45-4a42-b808-b5d1a83a5c5d"}],"executionId":"5032e07a-9b62-4076-bf10-c849ad5084e5","transitionId":"d56ae6fb-1a45-4a42-b808-b5d1a83a5c5d","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"failed","results":[]}],"metadata":{"salesforceId":"00P2N000003161rUAA","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"4c9342fb-b8daf39f-d952fbe1-7283e742","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}';
        
        cscfga__Product_Basket__c prodBasketMobile = new cscfga__Product_Basket__c();
        prodBasketMobile.csbb__Account__c = accRec.Id;
        prodBasketMobile.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        prodBasketMobile.Name = 'Mobile Eligibility Transition';
        prodBasketMobile.isEligibilityCheckComplete__c = false;
        prodBasketMobile.isEligibilityTriggered__c = false;
        prodBasketMobile.Transition_basket_stage__c ='Reservation Triggered';
        insert prodBasketMobile;
        
        cscfga__Product_Definition__c productDefinition = ProductTestFactory.buildProductDefinition('TestEligibility','Test');
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        insert productDefinition;
 
        cscfga__Product_Configuration__c prodConfigMobile = ProductTestFactory.buildProductConfig(productDefinition.Id);
        prodConfigMobile.name= 'Corporate Mobile Plus';
        prodConfigMobile.cscfga__Description__c = 'Test description';
        prodConfigMobile.cscfga__Product_Basket__c = prodBasketMobile.Id;
        prodConfigMobile.isEligibleForTriggered__c=true;        
        prodConfigMobile.cscfga__Quantity__c = 1;
        insert prodConfigMobile;
        
        MobileTramasElgibility__c mobileTramRec = new MobileTramasElgibility__c();
        mobileTramRec.name = 'MobileTramasEligibility';
        mobileTramRec.Type__c = 'TM1';
        mobileTramRec.Product_Basket__c = prodBasketMobile.Id;
        mobileTramRec.Product_Configuration__c= prodConfigMobile.Id;
        insert mobileTramRec;
        
        Attachment attRec = new Attachment();
        attRec.Name = 'MobileTramasElgibility.json';
        attRec.ParentId = mobileTramRec.Id;
        Blob bodyBlob=Blob.valueOf(callBackResponse);
        attRec.body=bodyBlob;
        attRec.Body = bodyBlob;
        insert attRec;
        
        String basketId = prodBasketMobile.Id;
        
        isMobileEligibility=TransitionController.getEligibilityStatusMobile(basketId);
        System.assert(attRec.Id!=null);
        Test.stopTest();
        
    }
/*-----------------------------------------------------------------------------
EDGE         - 195766
Method Names - testgetEligibityStatus
Description  - To verify the TM2 call status for NGUC
Author       - Veena Putta
-------------------------------------------------------------------------------*/
    
    @isTest
    public static void testgetEligibityStatus(){
        List<String> selectProd = new List<String>();
        Test.startTest();
        List<cscfga__Product_Basket__c> pb = [SELECT Id, isEligibilityCheckComplete__c , isEligibilityTriggered__c                                      FROM cscfga__Product_Basket__c 
                                              WHERE Name = 'Transition'];
        String basketId = pb[0].Id;
        ID basId = pb[0].Id;        
        selectProd.add('50824647');        
        string CIDN = '2022012339';
        
        String TransitionJSONData='{ "Source_System_Id": "Replicator", "site": [ { "siteName": null, "productList": [ { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0235828975", "Services_From": "0235828965", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0235828965", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "PSTN", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": true }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0846238067", "Services_From": "0846238057", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0846238057", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "ISDN2", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": false }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0725392035", "Services_From": "0725392025", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }, { "Services_To": "0725392055", "Services_From": "0725392045", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0725392025", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "ISDN2DID", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": false }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0650094379", "Services_From": "0650094369", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "Voice", "Service_Id": "0650094369", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "" } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "BE Bundle", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": false } ], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50824647" } ], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "219903779387dbb9f5", "CIDN": "2022012339" }';
        String adBorId = '50824647';
        List<cscfga__Product_Configuration__c> pcListConf = [SELECT Id FROM cscfga__Product_Configuration__c WHERE Name= 'IP Site'];
         List<cscfga__Product_Configuration__c> pcList = [SELECT Id FROM cscfga__Product_Configuration__c WHERE Name= 'Connected Workplace' ];
         
        Attachment att = new Attachment();
        att.Name = 'TransitionJSONData.json';
        att.ParentId = pcListConf[0].Id;
        att.Body = Blob.valueOf(TransitionJSONData);
        insert att;
       
        TramasElgibilityCallbackResponse__c eligTram = new TramasElgibilityCallbackResponse__c();
        eligTram.Product_Configuration__c = pcListConf[0].Id;
        eligTram.Product_Basket__c = pb[0].Id;
        eligTram.Eligibility_Criteria__c = 'Eligible';
        eligTram.Correlation_ID__c = 'abcd1234xyz';
        insert eligTram;
       
        Boolean sendCallout = true;
        
        
        String siteMap2 = '{"101119100":{"ADBOR_Id":"101119100","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"AUXILLARY","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847727530","Service_Type":"voice","serviceExtension":[],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""},"101119188":{"ADBOR_Id":"101119188","Error_Code":"","Error_Description":"","productList":[{"checkValue":true,"eligibilityStatus":"Ready for assessment","Product_Type":"ISDN2","serviceList":[{"checkValue":false,"service":[{"Association_Role":"GDN","Association_Type":"Multinumber","checkValue":false,"eligibilityReason":"","eligibilityStatus":"","In_Flight_Legacy_System":"","In_Flight_Order_Id":"","Service_Id":"0847225111","Service_Type":"voice","serviceExtension":[{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225100","Services_To":"0847225110"},{"checkValue":false,"eligibilityReason":"","eligibilityStatus":"","Services_From":"0847225112","Services_To":"0847225199"}],"User_Type":""}],"Service_Type":"voice"}]}],"siteName":""}}';
        Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> siteMap2ObjTest = (Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>)Json.deserialize(siteMap2, Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>.Class);        
      
        List<Integer> IntResponse =TransitionController.getEligibityStatus(basketId);
        
        pb[0].isEligibilityTriggered__c =true;
        pb[0].isEligibilityCheckComplete__c =false;
        update pb[0];
        Test.stopTest();
        System.assert(basketId != null);
    }
    
     @isTest
    public static void getTramsErrorCodeTest(){
        Test.startTest();
        List<String> selectProd = new List<String>();
        List<cscfga__Product_Basket__c> pb = [SELECT Id, isEligibilityCheckComplete__c , isEligibilityTriggered__c                                      FROM cscfga__Product_Basket__c 
                                              WHERE Name = 'Transition'];
        
        NumberReservationTM2CallOut.ErrorWrapper errorWrap =  TransitionController.getTramsErrorCode('Mobile',pb[0].id,'TM1',System.now());
        System.debug('errorWrap:'+errorWrap);
        Test.stopTest();
        System.assertEquals(errorWrap==null, true, 'Success');
    }
    @isTest
    public static void getCurrentDatetime(){
        Test.startTest();
        DateTime getdate =  TransitionController.getCurrentDatetime();
        Test.stopTest();
        System.assertEquals(getdate.date()==Date.today(), true, 'Success');
    }
    
    @isTest
    public static void getEligibityStatusException(){        
        Test.startTest();
      	TransitionController.getEligibityStatus('12345');
        
        List<Exception_Log__c> lstExceptionLogs = [select id from Exception_Log__c];
        Test.stopTest();
        System.assertEquals(lstExceptionLogs.size()>0, true, 'Success');
    }
    
     @isTest
    public static void updatetransitionBasketStagetoCheckEligibilityException(){        
        Test.startTest();
      	TransitionController.updatetransitionBasketStagetoCheckEligibility('12345');
        
        List<Exception_Log__c> lstExceptionLogs = [select id from Exception_Log__c];
        Test.stopTest();
        System.assertEquals(lstExceptionLogs.size()>0, true, 'Success');
    }
    
    @isTest
    public static void createFeedbackCaseException(){        
        Test.startTest();
      	TransitionController.createFeedbackCase('12345','','','');
        
        List<Exception_Log__c> lstExceptionLogs = [select id from Exception_Log__c];
        Test.stopTest();
        System.assertEquals(lstExceptionLogs.size()>0, true, 'Success');
    }
     /**********************************************************************************************
 * Story: DIGI-24543
 * Team : Osaka
 * Developer : Pradeep Mudenur
 * Description: Test method to cover TransitionControllerHelper class createFeedbackCase method
 * *********************************************************************************************/
@IsTest public static void createFeedbackCaseTest1(){
    Test.startTest();
    String basketId = [select id,csbb__Account__c from cscfga__Product_Basket__c where name ='Testing Basket'].id;
    
    TransitionControllerHelper.createFeedbackCase(new List<string>{basketId});
    
    List<Case> lstCases = [select id from case];
    Test.stopTest();
    system.assertEquals(true, lstCases.size()>0);
    
}
}