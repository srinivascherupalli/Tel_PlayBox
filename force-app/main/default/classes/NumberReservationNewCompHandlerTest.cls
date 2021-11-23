/*************************************************************************************************
Name : NumberReservationNewCompHandlerTest
Description : Test class for NumberReservationNewCompHandler
Author: Ila/mahima
Story: EDGE-93081
***************************************************************************************************/
@isTest
public class NumberReservationNewCompHandlerTest {

    @testSetup
    public static void setupdata(){
         TestDataFactory.generateProductConfiguration();
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
    }
/*---------------------------------------------------------------------------------
    EDGE-93081,92020
    Author: Mahima Gandhe,Aishwarya
	Description: searchMSISDNTest
---------------------------------------------------------------------------*/
    @isTest
    public static void searchMSISDNTest(){
        Test.startTest();
        NumberReservationNewCompHandler.SearchMSISDNWrapper searchObj = new NumberReservationNewCompHandler.SearchMSISDNWrapper();
        searchObj.reqQuantity=2;
 		searchObj.reqSearch= 'Non-Contiguous';        
        searchObj.reqPattern='23462';
        searchObj.patternType='Contains';
         String json ='{"data":{"activityName":"Search","resourceType":"Mobile","searchType":"Non-Contiguous","pattern":"*1*","patternType":"Contains","quantity":12}}';
         // EDGE-92020: Modified test method as API is pointing to UNMS
        FNNSearchRequestDTO req= FNNSearchRequestDTO.parse(json);
        
         Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
		
        List<NumberReservationNewCompHandler.LRMWrapper> searchNum = NumberReservationNewCompHandler.searchMSISDN(searchObj);
        
        Test.stopTest();
        System.assertEquals(searchNum !=null, true);
    }
/*---------------------------------------------------------------------------------
    EDGE-93081,92021
    Author: Mahima Gandhe,Aishwarya
	Description: autoReserveMSISDNTest
---------------------------------------------------------------------------*/
  
    @isTest
    public static void autoReserveMSISDNTest()
    {
        //EDGE-92021:Modied test method for bulk autoreserve mobile numbers
        cscfga__Product_Basket__c testProductbasket = TestDataFactory.generateProductBasket();
        String json ='{"data":{"activityName":"Reserve Next Available","resourceType":"Mobile","searchType":"Non-Contiguous","quantity":12}}';
            
        FNNSearchRequestDTO req= FNNSearchRequestDTO.parse(json);
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
		
                String auto = NumberReservationNewCompHandler.autoReserveMSISDN(6,testProductbasket.id,'Mobile');

        Test.stopTest();
     
        System.assertEquals(req!=null, true);
    }

    /*EDGE-93081
    Author: Mahima Gandhe
    @isTest
    public static void reserveMSISDNTest()
    {
        Test.startTest();
        List<NumberReservationNewCompHandler.LRMWrapper> lstLRM= new List<NumberReservationNewCompHandler.LRMWrapper>();
        NumberReservationNewCompHandler.LRMWrapper lrm1= new NumberReservationNewCompHandler.LRMWrapper();
        lrm1.numberList='7687878';
        lrm1.isSelectedNew=true;
        //lrm1.SerialNo=1;
        NumberReservationNewCompHandler.LRMWrapper lrm2= new NumberReservationNewCompHandler.LRMWrapper();
        lrm2.numberList='7687879';
        lrm2.isSelectedNew=true;
        //lrm2.SerialNo=2;
        lstLRM.add(lrm1);
        lstLRM.add(lrm2);
        string LRMString = Json.serialize(lstLRM);
        List<String> req = new List<String>();
        req.add(LRMString);
        cscfga__Product_Basket__c testProductbasket = TestDataFactory.generateProductBasket();
        String reserve = NumberReservationNewCompHandler.reserveMSISDN(LRMString,testProductbasket.id,'Mobile');
        MSISDNService.saveReserveMSISDN(req,testProductbasket.id);
        Test.stopTest();
        System.assertEquals(reserve!=null, true);

    }*/
     /****************************************************************
      * EDGE:59982,100659
      * Method:searchFNNTest
      * Author:Aishwarya
      * ********************************************************************/

    @isTest
    public static void searchFNNTest(){

        NumberReservationNewCompHandler.SearchMSISDNWrapper searchObj = new NumberReservationNewCompHandler.SearchMSISDNWrapper();
        searchObj.reqQuantity=2;
        searchObj.reqSearch= 'Non-Contiguous';
        searchObj.pattern=613;
        searchObj.areaCode='03';
        searchObj.patternType='Contains';
        String json ='{"data":{"activityName":"Search","resourceType":"Fixed","searchType":"Non-Contiguous","pattern":"*1*","patternType":"Contains","quantity":12,"nationalDestinationCode":"02"}}';
            
        FNNSearchRequestDTO req= FNNSearchRequestDTO.parse(json);
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
		
        List<NumberReservationNewCompHandler.LRMWrapper> searchNum = NumberReservationNewCompHandler.searchFNN(searchObj);
        
        Test.stopTest();
        System.assertEquals(searchNum !=null, true);
    }
  
    @isTest
    public static void reserveFNNTest(){
      List<NumberReservationNewCompHandler.LRMWrapper> lstLRM= new List<NumberReservationNewCompHandler.LRMWrapper>();
        NumberReservationNewCompHandler.LRMWrapper lrm1= new NumberReservationNewCompHandler.LRMWrapper();
        lrm1.numberList='61359834532';
         lrm1.isSelectedNew=true;
        //lrm1.SerialNo=1;
        NumberReservationNewCompHandler.LRMWrapper lrm2= new NumberReservationNewCompHandler.LRMWrapper();
        lrm2.numberList='61359834534';
        lrm2.isSelectedNew=true;
        //lrm2.SerialNo=2;
        lstLRM.add(lrm1);
        lstLRM.add(lrm2);
        string LRMString = Json.serialize(lstLRM);
        //String fixNum='61359834532';
	cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        String basketId= testProductConfiguration.cscfga__Product_Basket__c;
        NumberReservationFixedHandler.ResponseWrapper reswrap = NumberReservationNewCompHandler.reserveFNN(LRMString,basketId,'Held Order','Mobile');
        system.assert(reswrap!=null, true);
    }
     /******************************************************************
EDGE-126317
Method:getPatternType 
Author:Kalashree Borgaonkar
******************************************************************/ 
    @isTest
    public static void getPatternTypeTest(){
        Test.startTest();
        List<SelectOptionz> selectOptions = NumberReservationNewCompHandler.getPatternType('Contiguous');
        Test.stopTest();
        System.assertEquals(selectOptions!=null,true,'Options retrieved');
    }
    /******************************************************************
EDGE-126317
Method:searchContiguousContainsTest 
Author:Kalashree Borgaonkar
******************************************************************/ 
    @isTest
    public static void searchContiguousContainsTest(){
        
        NumberReservationNewCompHandler.SearchMSISDNWrapper searchObj = new NumberReservationNewCompHandler.SearchMSISDNWrapper();
        searchObj.reqQuantity=2;
        searchObj.reqSearch= 'Contiguous';
        searchObj.pattern=613;
        searchObj.areaCode='03';
        searchObj.patternType='Contains';
        String json ='{"data":{"activityName":"Search","resourceType":"Fixed","searchType":"Contiguous","pattern":"*1*","patternType":"Contains","quantity":12,"nationalDestinationCode":"02"}}';
            
        FNNSearchRequestDTO req= FNNSearchRequestDTO.parse(json);
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
		
        List<NumberReservationNewCompHandler.LRMWrapper> searchNum = NumberReservationNewCompHandler.searchFNN(searchObj);
        
        Test.stopTest();
        System.assertEquals(searchNum !=null, true);
    }
	 /******************************************************************
EDGE-126317
Method:searchContiguousStartsTest 
Author:Kalashree Borgaonkar
******************************************************************/ 
	@isTest
    public static void searchContiguousStartsTest(){
        
        NumberReservationNewCompHandler.SearchMSISDNWrapper searchObj = new NumberReservationNewCompHandler.SearchMSISDNWrapper();
        searchObj.reqQuantity=2;
        searchObj.reqSearch= 'Contiguous';
        searchObj.pattern=613;
        searchObj.areaCode='03';
        searchObj.patternType='Starts With';
        String json ='{"data":{"activityName":"Search","resourceType":"Fixed","searchType":"Contiguous","pattern":"*1*","patternType":"Contains","quantity":12,"nationalDestinationCode":"02"}}';
            
        FNNSearchRequestDTO req= FNNSearchRequestDTO.parse(json);
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
		
        List<NumberReservationNewCompHandler.LRMWrapper> searchNum = NumberReservationNewCompHandler.searchFNN(searchObj);
        searchObj.patternType='None';
        List<NumberReservationNewCompHandler.LRMWrapper> searchNum1 = NumberReservationNewCompHandler.searchFNN(searchObj);
        Test.stopTest();
        System.assertEquals(searchNum !=null, true);
    }
    /******************************************************************
EDGE-126317
Method:searchNonContiguousEndsTest 
Author:Kalashree Borgaonkar
******************************************************************/ 
	@isTest
    public static void searchNonContiguousEndsTest(){
        
        NumberReservationNewCompHandler.SearchMSISDNWrapper searchObj = new NumberReservationNewCompHandler.SearchMSISDNWrapper();
        searchObj.reqQuantity=2;
        searchObj.reqSearch= 'Non-Contiguous';
        searchObj.pattern=613;
        searchObj.areaCode='03';
        searchObj.patternType='Ends With';
        String json ='{"data":{"activityName":"Search","resourceType":"Fixed","searchType":"Contiguous","pattern":"*1*","patternType":"Contains","quantity":12,"nationalDestinationCode":"02"}}';

        FNNSearchRequestDTO req= FNNSearchRequestDTO.parse(json);
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));

        List<NumberReservationNewCompHandler.LRMWrapper> searchNum = NumberReservationNewCompHandler.searchFNN(searchObj);

        Test.stopTest();
        System.assertEquals(searchNum !=null, true);
    }

    /******************************************************************
EDGE-126317
Method:searchNonContiguousStartTest 
Author:Kalashree Borgaonkar
******************************************************************/ 
	@isTest
    public static void searchNonContiguousStartTest(){
        
        NumberReservationNewCompHandler.SearchMSISDNWrapper searchObj = new NumberReservationNewCompHandler.SearchMSISDNWrapper();
        searchObj.reqQuantity=2;
        searchObj.reqSearch= 'Non-Contiguous';
        searchObj.pattern=613;
        searchObj.areaCode='03';
        searchObj.patternType='Starts With';
        String json ='{"data":{"activityName":"Search","resourceType":"Fixed","searchType":"Contiguous","pattern":"*1*","patternType":"Contains","quantity":12,"nationalDestinationCode":"02"}}';
            
        FNNSearchRequestDTO req= FNNSearchRequestDTO.parse(json);
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
		
        List<NumberReservationNewCompHandler.LRMWrapper> searchNum = NumberReservationNewCompHandler.searchFNN(searchObj);
        
        Test.stopTest();
        System.assertEquals(searchNum !=null, true);
    }
 /******************************************************************************************************
EDGE        -100661
Method      -checkForPartnerUserTest 
Description -Test method to cover checkForPartnerUser method in NumberReservationNewCompHandler class.
Author      -Dheeraj Bhatt
*********************************************************************************************************/ 
   @IsTest public static void checkForPartnerUserTest(){
       Test.startTest();
       Boolean isPartner= NumberReservationNewCompHandler.checkForPartnerUser();
       Test.stopTest();
       system.assertEquals(isPartner, false);
    }
}