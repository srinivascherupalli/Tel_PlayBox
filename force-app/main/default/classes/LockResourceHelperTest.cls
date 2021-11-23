@isTest
public with sharing class LockResourceHelperTest {
    @isTest 
    static void validateNumbersPartOfRangeTest(){
        
        List<Number__C> numberList = SYS_TestDataFactory.createNumbers(new List<String>{'61260452045','61260452046'},null);
        for(Number__c num : numberList) {
            num.Start_Range__c = '61260452045';
            num.End_range__c = '61260452046';
        }
        Test.startTest();
        Insert numberList; 
        List<Number__C> rangeNumList = [Select Number_Range__c, Service_Number__c from Number__c];
        Map<string, List<Number__c>> status = UpdateNumberInventoryHelper.validateNumbersPartOfRange(rangeNumList); 
        system.debug(status);
        Test.stopTest();

        system.assertEquals(0, status.get('invalid').size());
        system.assertEquals(numberList.size(), status.get('valid').size());
    }

    @isTest 
    static void validateNumberLockedByTest(){
        String systemSource  = 'UCDM';
        List<Number__C> numberList = SYS_TestDataFactory.createNumbers(new List<String>{'61260452045','61260452046'},'locked');
        for(Number__c num : numberList) {
            num.Locked_By__c = 'UCDM';
        }
        Map<string, List<Number__c>> status = UpdateNumberInventoryHelper.validateNumberLockedBy(numberList, systemSource);
        system.assertEquals(0, status.get('invalidSourceSystem').size());
        system.assertEquals(numberList.size(), status.get('valid').size());
    }
    
    @isTest 
    static void validateNumberLockedByInvalidSSTest(){
        String systemSource  = 'Test';
        List<Number__C> numberList = SYS_TestDataFactory.createNumbers(new List<String>{'61260452045','61260452046'},'locked');
        for(Number__c num : numberList) {
            num.Locked_By__c = 'UCDM';
        }
        Map<string, List<Number__c>> status = UpdateNumberInventoryHelper.validateNumberLockedBy(numberList, systemSource);
        system.assertEquals(2, status.get('invalidSourceSystem').size());
        system.assertEquals(0, status.get('valid').size());
    }
        
    @isTest
    static void prepareResponseTest(){ 
        string status = 'Lock';
        List<NumberInventoryResponse.errors> errorList = new List<NumberInventoryResponse.errors>();

        List<String> numberString = new List<String>{'0352426211'};
        
        errorList.add(UpdateNumberInventoryHelper.getErrorMessage(numberString, 'Invalid Number'));

        NumberInventoryResponse response = UpdateNumberInventoryHelper.prepareResponse('400', 'Unable to ' + status, 'Unable to ' + status+' numbers', errorList);

        System.assertEquals('400', response.code);
        System.assertEquals('Unable to Lock', response.Status);
        System.assertEquals('Unable to Lock numbers', response.message);
        System.assertEquals(errorList, response.errors);

    }

    @isTest
    static void validateFormatOfNumbersTest(){ 

        Map<String , List<String>> numbersMap  = new Map<String , List<String>>();
        List<String> num = new List<string>{'4131100223','41311002001','413110020012','613110012123','61311212','61311001001','61311a01001'};
        numbersMap = UpdateNumberInventoryHelper.validateFormatOfNumbers(num);

        List<String> numbers1 = numbersMap.get('valid'); 
        System.assertEquals(new String[]{'61311001001'},numbers1);

        List<String> numbers2 = numbersMap.get('invalid'); 
        System.assertEquals(new String[]{'4131100223','41311002001','413110020012','613110012123','61311212','61311a01001'},numbers2);
        
    }

    @isTest
    static void getActiveInactiveNumbersTest(){ 

        Map<String, List<Number__c>> statusNumberMap  = new Map<String, List<Number__c>>();

        List<Number__C> nbrList = SYS_TestDataFactory.createNumbers(new List<String>{'61352426220','61352426223'},'Active');
        statusNumberMap.put('active',nbrList);
        nbrList = SYS_TestDataFactory.createNumbers(new List<String>{'61352426221'},'Disconnected');
        statusNumberMap.put('disconnected',nbrList);
        nbrList = SYS_TestDataFactory.createNumbers(new List<String>{'61352426226'},'Disconnect Pending');
        statusNumberMap.put('disconnect pending',nbrList);
        nbrList = SYS_TestDataFactory.createNumbers(new List<String>{'61352426222'},'Locked');
        statusNumberMap.put('locked',nbrList);
        nbrList = SYS_TestDataFactory.createNumbers(new List<String>{'61352426224'},'Bill Readiness In Progress'); 
        statusNumberMap.put('bill eadiness n progress',nbrList);
		
        Map<String, List<Number__c>> respStatusNumberMap  = new Map<String, List<Number__c>>();
        respStatusNumberMap = UpdateNumberInventoryHelper.getActiveInactiveNumbers(statusNumberMap);

        List<Number__c> numberListA = new List<Number__C>();
        numberListA.addAll(statusNumberMap.get('active'));
        numberListA.addAll(statusNumberMap.get('disconnect pending'));
        List<Number__c> activeNumbersList = respStatusNumberMap.get('active');
        System.debug('numberListA-->'+Json.serialize(numberListA));
        System.debug('activeNumbersList-->'+Json.serialize(activeNumbersList));
        System.assertEquals(numberListA,activeNumbersList);
        
        List<Number__c> inactiveNumbersList = respStatusNumberMap.get('inactive');
        System.assert(inactiveNumbersList.contains(statusNumberMap.get('disconnected')[0]));
        
    }
    
    @isTest
    static void getErrorMessageStringTest(){ 

        List<String> numberString = new List<String>{'0352426211'};
        NumberInventoryResponse.errors errorRes = UpdateNumberInventoryHelper.getErrorMessage(numberString, 'Invalid Number');

        System.assertEquals('numbers', errorRes.failure);
        System.assertEquals('0352426211', errorRes.value);
        System.assertEquals('Invalid Number', errorRes.message);

    }

    @isTest
    static void getErrorMessageNumberTest(){ 

        List<Number__C> numberList1 = SYS_TestDataFactory.createNumbers(new List<String>{'61352426211','61352426213'},null);
       
        NumberInventoryResponse.errors errorRes1 = UpdateNumberInventoryHelper.getErrorMessage(numberList1, 'Numbers Not In Active state');
        
        System.assertEquals('numbers', errorRes1.failure);
        System.assertEquals('61352426211,61352426213', errorRes1.value);
        System.assertEquals('Numbers Not In Active state', errorRes1.message);

        List<Number__C> numberList2 = SYS_TestDataFactory.createNumbers(new List<String>{'61352426241'},null);
       
        NumberInventoryResponse.errors errorRes2 = UpdateNumberInventoryHelper.getErrorMessage(numberList2, 'Numbers are part of a range.Cannot lock select numbers.');
        
        System.assertEquals('numbers', errorRes2.failure);
        System.assertEquals('61352426241', errorRes2.value);
        System.assertEquals('Numbers are part of a range.Cannot lock select numbers.', errorRes2.message);

    }

    @isTest
    static void getNumbersNotFoundTest(){ 
        Map<String, Number__C> numberMap = new Map<String, Number__C>();
        List<Number__C> numbList = SYS_TestDataFactory.createNumbers(new List<String>{'61352426220','61352426223'},null);

        for(Number__c num : numbList){
            numberMap.put(num.Service_Number__c, num);
        }

        List<String> numbString1 = new List<String>{'61352426223'};
        List<String> numbString2 = new List<String>{'61352426224'};
		system.debug('getNumbersNotFoundTest-->'+numberMap);
        List<String> nbrRespString1 = UpdateNumberInventoryHelper.getNumbersNotFound(numberMap,numbString1);
        system.debug('getNumbersNotFoundTest.nbrRespString1-->'+nbrRespString1);

        System.assert(nbrRespString1.isEmpty());

        List<String> nbrRespString2 = UpdateNumberInventoryHelper.getNumbersNotFound(numberMap,numbString2);
        system.debug('getNumbersNotFoundTest.nbrRespString2-->'+nbrRespString2);
        System.assertEquals(numbString2, nbrRespString2);

    }

}