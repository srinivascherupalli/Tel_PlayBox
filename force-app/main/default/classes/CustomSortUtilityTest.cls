/*
 * Developer Name: Kunal Dixit
 * Description: test Class for CustomSortUtility
 */



@isTest
public class CustomSortUtilityTest {
    @isTest
    public static void test1(){
        Opportunity[] oppyList = new List<Opportunity>();
        Date closeDate = Date.today().addDays(10);
        Opportunity op1=new Opportunity(Name='Edge Installation',CloseDate=closeDate,StageName='Prospecting',Amount=50000);
        Opportunity op2=new Opportunity(Name='United Oil Installations',CloseDate=closeDate,StageName='Needs Analysis',Amount=100000);
        Opportunity op3=new Opportunity(Name='Grand Hotels SLA',CloseDate=closeDate,StageName='Prospecting',Amount=25000);
        oppyList.add(op1);
        oppyList.add(op2);
        oppyList.add(op3);
       
        Test.startTest();
        List<Opportunity> returnedList=(List<Opportunity>)CustomSortUtility.customSort(oppyList,'Amount','Integer');
        List<Opportunity> returnedListDateTime=(List<Opportunity>)CustomSortUtility.customSort(oppyList,'createddate','DateTime');

        Test.stopTest();
        
        System.debug(returnedList);
        // Verify the sort order
        System.assertEquals('Grand Hotels SLA',String.valueOf(returnedList[0].get('Name')));  
        System.assertEquals(25000, Integer.valueOf((returnedList[0].get('Amount'))));
        System.assertEquals('Edge Installation',String.valueOf(returnedList[1].get('Name')));
        System.assertEquals(50000,Integer.valueOf((returnedList[1].get('Amount'))));
        System.assertEquals('United Oil Installations', String.valueOf(returnedList[2].get('Name')));
        System.assertEquals(100000,Integer.valueOf((returnedList[2].get('Amount'))));
        // Write the sorted list contents to the debug log.
        
        
    }
}