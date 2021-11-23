/********************************************************************************************
@Class Name 				: 	GetContactInformation
@Description 				:	Sprint-19.03,EDGE-58913
@Date           			: 	28th Feb, 2019
@Author         			: 	Team SFO(Amar Chakka)
@Comments       			: 	EditName Component On Contact, Server side Controller

@Last Modified By       	: 	Bhargava
@Last Modified Date     	: 	20 Oct 2020
@Last Modified Comments   	:  EDGE-176104:Alexandria Added code to check if there a Active POR the Account and Partner 
else display message to the user.
                                07/01/2021 21.01 by sravanthi, Team SFO
                            as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
*********************************************************************************************/

public with sharing class GetContactInformation {
    
    // Fetching Exsisting Contact Details to display on Component.
    @AuraEnabled
	public contact con;
    @AuraEnabled
    public static ContactEditNameController getContactDetails(Id recordId){
        ContactEditNameController cr = new ContactEditNameController();
        try{
			if(!String.isBlank(recordId)){
				cr.con = [SELECT Id,Name,firstname,middlename,lastname,Salutation,Pref_Comm_Method__c  FROM Contact where id = :recordId];
			}
		}catch(Exception Ex){
			system.debug('Exception:::: GetContactInformation Class:::: getContactDetails Method'+ Ex.getMessage());
		}
		return cr;
    }
    
    // Fetching and Mapping RecordType Developer Name to RecordEditForm so that Personal details record will get created with the mapped record type.
    @AuraEnabled
    public static string getRecordType(string nameChangeReason){
        string recordTypeId = null;
		try{
            if(nameChangeReason!=null && !String.isBlank(nameChangeReason)){
                if(nameChangeReason == Label.ContactLastName){
                    recordTypeId = Schema.SObjectType.Update_Personal_Details__c.getRecordTypeInfosByName().get(Label.PersonalDetailsLastNameRecordType).getRecordTypeId(); 
                }
                else if(nameChangeReason == Label.ContactFirstAndMiddleName){
                    recordTypeId = Schema.SObjectType.Update_Personal_Details__c.getRecordTypeInfosByName().get(Label.PersonalDetailsFirstNameRecordType).getRecordTypeId(); 
                }
                else if(nameChangeReason == Label.Name_Marriage_or_Divorce){
                    recordTypeId = Schema.SObjectType.Update_Personal_Details__c.getRecordTypeInfosByName().get(Label.PersonalDetailsMarriageRecordType).getRecordTypeId(); 
                }
                else if(nameChangeReason == Label.Name_Legal_Name_Change_Deed_Poll){
                    recordTypeId = Schema.SObjectType.Update_Personal_Details__c.getRecordTypeInfosByName().get(Label.PersonalDetailsLegalNameRecordType).getRecordTypeId(); 
                }
                else if(nameChangeReason == Label.Name_Gender_Reassignment){
                    recordTypeId = Schema.SObjectType.Update_Personal_Details__c.getRecordTypeInfosByName().get(Label.PersonalDetailsGenderReassignmentRecordType).getRecordTypeId(); 
                }
            }
		}catch(Exception Ex){
			system.debug('Exception:::: GetContactInformation Class:::: getRecordType Method'+ Ex.getMessage());
		}
       return recordTypeId;
    }
    
     @AuraEnabled
  public static WrapperActivePOR getporofcontact(Id contactId)
  {		
      WrapperActivePOR returnpor=new WrapperActivePOR();
      Boolean isPartnerOfRecord;//Default value 
       Boolean isPartner;//Default value 
      //If Partner user and POR is inactive return false.
      if(FeatureManagement.checkPermission('Partner_User'))
      {
       isPartner=true; 
       isPartnerOfRecord = getPORs.getporofcontact(contactId);
          if(isPartnerOfRecord==false){isPartnerOfRecord=true;          
                                      }else{isPartnerOfRecord=false;}
             // set to False to Hide the warning message         
          
      }else{isPartnerOfRecord=false; isPartner=false;    
          }
      returnpor.isPartnerOfRecord=isPartnerOfRecord;
      returnpor.isPartner=isPartner;
      return returnpor;
        
  }

    @AuraEnabled
  public static void prmUpdateContactdetails(String Changereason,String NewFirstName,  String NewLastName,String NewMiddleName,
                                              boolean ClearMiddleName,  String NewTitle,String FirstName,String MiddleName
                                              ,String LastName,String Title,String recordTypeId,String recordId)
  {
 updatePRMContactinfo.updatepersonalDetails(Changereason,NewFirstName,NewLastName,NewMiddleName,
                                               ClearMiddleName,NewTitle,FirstName,MiddleName
                                              ,LastName,Title,recordTypeId,recordId);
  }
  
    public class WrapperActivePOR {
      @AuraEnabled  public  boolean isPartnerOfRecord {get;set;}
      @AuraEnabled  public  boolean isPartner {get;set;}
    }

     
    
}