/*******************************************************************
Created By          :   Garg / Ashish
Created Date        :   
Desc                :   This is used to show craousel data on partner community
Covered by          :   PRMOffersCarouselTest
Date            Version             Modified By             Desc
2-Sept-2019        1              Ashish garg  
6-Aug-2020         2              Paresh Patil              Added new variable to store category label    
5-Sep-2020         3              Megha                     Added all knowledge article detail in single sobject variable 
***********************************************************************/

public with sharing class PRMCarouselWrapper {

    @auraenabled
    public string categoryName{get;set;}
    
    @AuraEnabled
    public string categoryLabel{get;set;}
    
    //P2OB-8030 && P20B-7893 - Added new variable to store top category name
    @AuraEnabled
    public string topCategoryName{get;set;}
    
    @AuraEnabled 
    public Sobject sobjectRecord {get;set;} 
    
   
    public PRMCarouselWrapper(string categoryName, Sobject sobjectRecord) {
        this.categoryName = categoryName;
        this.sobjectRecord = sobjectRecord;
    }
   
}