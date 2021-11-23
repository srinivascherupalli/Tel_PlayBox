/*************************************************************************************************
Name : getFAOnProdBasket
TestClass:getFAOnProdBasketTest
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.        Parmanand           15-Sept-2021      DIGI-15376 
===============================================================================================================================
***************************************************************************************************/
global class getFAOnProdBasket implements csbb.LookupPlugin
{
     global static String query (Map<String, String> params, String parentFieldValue)
    {
        List<Map<String, String>> returnList = new List<Map<String, String>>();
        List<csconta__frame_agreement__c> faList = [select Id, Name, csconta__Agreement_Name__c from csconta__frame_agreement__c where csconta__Account__c = :parentFieldValue and Check_Todays_date__c = true and csconta__status__c = 'Active' order by Name Asc];
        if(faList != null && !faList.isEmpty()){
            for(csconta__frame_agreement__c fa :faList){
                returnList.add(new Map<String,String>{'id'=> fa.Id,'name'=> fa.Name,'csconta__Agreement_Name__c' => fa.csconta__Agreement_Name__c });
            }
        }
        Boolean Ted_115 = Test.IsRunningTest()? true : FeatureEligibilityChecker.determineFeatureEligiblity('TED_115','');
        if(Ted_115){
            List<csconta__Account_Frame_Agreement_Association__c> faAssList = [select ID,csconta__Frame_Agreement__c, csconta__Frame_Agreement__r.Name, csconta__Frame_Agreement__r.csconta__Agreement_Name__c from csconta__Account_Frame_Agreement_Association__c where csconta__Account__c = :parentFieldValue and csconta__Frame_Agreement__r.Check_Todays_date__c = true and csconta__Frame_Agreement__r.csconta__status__c = 'Active' order by Name Asc];
            if(faAssList != null && !faAssList.isEmpty()){
                for(csconta__Account_Frame_Agreement_Association__c faAss :faAssList){
                    returnList.add(new Map<String,String>{'id'=> faAss.csconta__Frame_Agreement__c,'name'=> faAss.csconta__Frame_Agreement__r.Name, 'csconta__Agreement_Name__c' => faAss.csconta__Frame_Agreement__r.csconta__Agreement_Name__c});
                }
            }
        }
        return JSON.serialize(returnList);
    }
}