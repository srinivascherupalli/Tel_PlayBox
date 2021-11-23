/********************************************************************************************
@Class Name                 :   updatePRMContactinfo
@Description                :   EDGE-176104:Alexandria Added code to add Personal details for Partners
@Date                       :   20 Oct 2020
@Author                     :   Bhargava
@Comments                   :   EditName Component On Contact, Server side Controller

*********************************************************************************************/

public  without sharing class updatePRMContactinfo {
    
  //  @AuraEnabled
   // public contact con;
    @AuraEnabled
    public static void  updatepersonalDetails(String Changereason,String NewFirstName,  String NewLastName,String NewMiddleName,
                                              boolean ClearMiddleName,  String NewTitle,String FirstName,String MiddleName
                                              ,String LastName,String Title,String recordTypeId,String recordId)
    {
        system.debug('NewLastName'+NewLastName);
        
        system.debug('ClearMiddleName'+ClearMiddleName);
            Update_Personal_Details__c personaldetails=new Update_Personal_Details__c();
      
            personaldetails.Change_reason__c=Changereason;
            personaldetails.New_First_Name__c=NewFirstName;
            personaldetails.New_Last_Name__c=NewLastName;
            personaldetails.New_Middle_Name__c=NewMiddleName;
            personaldetails.Clear_Middle_Name__c=ClearMiddleName;
            personaldetails.New_Title__c=NewTitle;
            personaldetails.First_Name__c=FirstName;
            personaldetails.Middle_Name__c=MiddleName;
            personaldetails.Last_Name__c=LastName;
            personaldetails.Title__c=Title;
            personaldetails.RecordTypeId=recordTypeId;
          	personaldetails.Contact__c=recordId;
           system.debug('personaldetails1'+personaldetails);
        
            insert personaldetails;
        
             
    }

}