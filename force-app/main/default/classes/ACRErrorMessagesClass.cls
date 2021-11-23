/*EDGE-58472
Usage:ContactVerifiedDate VF Page
*/
public With Sharing class ACRErrorMessagesClass
{
    public Boolean ACRVer {set;get;}
    public Boolean ACRVercode {set;get;}
    public list<Boolean> ACRVerList {set;get;}
    public ACRErrorMessagesClass(ApexPages.StandardController controller)
    {
     ACRVerList = new list<Boolean>();
     String strContactId = apexpages.currentpage().getparameters().get('id');
     if(strContactId != null)
     {
     ACRVercode = True;
         system.debug('****');
         for(AccountContactRelation objACR : [SELECT Id,ContactId,Job_Description__c,Seniority_Level__c,AccountId,Contact_Usage__c FROM AccountContactRelation WHERE 
                                              ContactId =: strContactId])
         {
             system.debug(objACR+'objACR');
             if(objACR.Job_Description__c != null && objACR.Seniority_Level__c != null &&  objACR.Contact_Usage__c!=null && objACR.AccountId !=null && objACR.ContactId !=null )
             {
                 ACRVerList.add(True);
                 system.debug('entering1:::');
             }
             else if(objACR.Job_Description__c == null || objACR.Seniority_Level__c == null || objACR.Contact_Usage__c==null || objACR.AccountId ==null || objACR.ContactId ==null)
             {
                 ACRVerList.add(False);
                 system.debug('entering:::');
             }
         }
         system.debug(ACRVerList+'ACRVerList');
         If(ACRVerList.contains(False)){
             ACRVer = False;
         }
        If (!ACRVerList.contains(False)&&ACRVerList.size()!=null){
             ACRVer=True;
         }
     }
     
    }
    
}