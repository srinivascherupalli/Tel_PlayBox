/*------------------------------------------------------------ 
Company: Infosys
Description: Class to read data from the CSV file which is stored in the Static Resource named AdborIdCSVFile
Test Class: ReadDataFromCSV_Test
History :
<23-05-2019> <Sasidhar Devarapalli> <EDGE-85839 <Address Fix> Data Cleansing for Address Records - replace invalid Adbor ID> 
------------------------------------------------------------*/

public without sharing class  ReadDataFromCSV{
      
    /**
     * 
     * @name splitData
     * @description             :The method will execute from the "InvokeEASTCalloutBatch" class and It will help read the data from static resources.
     * @return List<String>     : List of ADBORIDs
     * @jiraStoryRef            : EDGE-85839
     * @createdBy               : Sasidhar Devarapalli,OSAKA
     * 
     **/
    public static List<String> splitData(String resourcename){
        String adborStaticResourceName = Label.AdborData;
        StaticResource defaultResource = [SELECT Body FROM StaticResource WHERE Name = :adborStaticResourceName];
        blob tempB = defaultResource.Body;
        String contentFile = tempB.toString();
        String filelines = contentFile.replaceAll('(\r\n|\r)','\n');
        List<String> slist = filelines.split('\n');
        List<String> adborIDList = new List<String>();
        for(String adborIDs : slist){
            adborIDList.add(adborIDs);
        }
        return adborIDList;
   }
}