/*
* Developer: Kunal Dixit
* Description: Test class for CustomSortDateTime class
*/

@istest
public class CustomSortDateTimeTest {
    
    @isTest
    public static void method1(){
        Date closeDate = Date.today().addDays(10);
        Opportunity op1=new Opportunity(Name='Edge Installation',CloseDate=closeDate,StageName='Prospecting',Amount=50000);
        Opportunity op2=new Opportunity(Name='United Oil Installations',CloseDate=closeDate,StageName='Needs Analysis',Amount=100000);
        Opportunity op3=new Opportunity(Name='Grand Hotels SLA',CloseDate=closeDate,StageName='Prospecting',Amount=25000);
        Opportunity op4=new Opportunity(Name='Test Opportunity',CloseDate=closeDate,StageName='Prospecting',Amount=25000);
        
        List<CustomSortDateTime> listToSort=new List<CustomSortDateTime>();
        listToSort.add(new CustomSortDateTime(op1));
        listToSort.add(new CustomSortDateTime(op2));
        listToSort.add(new CustomSortDateTime(op3));
        listToSort.add(new CustomSortDateTime(op4));
        CustomSortDateTime.fieldName='createddate';
        Test.startTest();
        listToSort.sort();
        Test.stopTest();
        
        List<SObject> returnedList=new List<Opportunity>();
        for(CustomSortDateTime myObject:listToSort){
            returnedList.add(myObject.obj);
        }
        system.debug(returnedList);
        system.assertEquals('Edge Installation', returnedList.get(0).get('Name'));
        system.assertEquals('United Oil Installations', returnedList.get(1).get('Name'));
        system.assertEquals('Grand Hotels SLA', returnedList.get(2).get('Name'));
        system.assertEquals('Test Opportunity', returnedList.get(3).get('Name'));
        
        
    }
}