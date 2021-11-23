/*
* Developer: Kunal Dixit
* Description: Test class for CustomSortInteger class
*/

@istest
public class CustomSortIntegerTest {
    
    @isTest
    public static void method1(){
        Date closeDate = Date.today().addDays(10);
        Opportunity op1=new Opportunity(Name='Edge Installation',CloseDate=closeDate,StageName='Prospecting',Amount=50000);
        Opportunity op2=new Opportunity(Name='United Oil Installations',CloseDate=closeDate,StageName='Needs Analysis',Amount=100000);
        Opportunity op3=new Opportunity(Name='Grand Hotels SLA',CloseDate=closeDate,StageName='Prospecting',Amount=25000);
        Opportunity op4=new Opportunity(Name='Test Opportunity',CloseDate=closeDate,StageName='Prospecting',Amount=25000);
        
        List<CustomSortInteger> listToSort=new List<CustomSortInteger>();
        listToSort.add(new CustomSortInteger(op1));
        listToSort.add(new CustomSortInteger(op2));
        listToSort.add(new CustomSortInteger(op3));
        listToSort.add(new CustomSortInteger(op4));
        CustomSortInteger.fieldName='Amount';
        Test.startTest();
        listToSort.sort();
        Test.stopTest();
        
        List<SObject> returnedList=new List<Opportunity>();
        for(CustomSortInteger myObject:listToSort){
            returnedList.add(myObject.obj);
        }
        System.assertEquals('Grand Hotels SLA',String.valueOf(returnedList[0].get('Name')));  
        System.assertEquals(25000, Integer.valueOf((returnedList[0].get('Amount'))));
        System.assertEquals('Test Opportunity',String.valueOf(returnedList[1].get('Name')));  
        System.assertEquals(25000, Integer.valueOf((returnedList[1].get('Amount'))));
        System.assertEquals('Edge Installation',String.valueOf(returnedList[2].get('Name')));
        System.assertEquals(50000,Integer.valueOf((returnedList[2].get('Amount'))));
        System.assertEquals('United Oil Installations', String.valueOf(returnedList[3].get('Name')));
        System.assertEquals(100000,Integer.valueOf((returnedList[3].get('Amount'))));
        
        
    }
}