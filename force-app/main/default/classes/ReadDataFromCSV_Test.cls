/*
 * Test class for ReadDataFromCSV
 */
 @IsTest
public class ReadDataFromCSV_Test{
    @isTest
     static void splitDataTest(){
         List<String> adborIdMap = readDataFromCSV.splitData('AdborIdCSVFileTest');
         System.assertNotEquals(null,adborIdMap);
     }
}