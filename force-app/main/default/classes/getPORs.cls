/*
  Bhargava:14/07/2020
EDGE-151592 This is a generic class to check the Patner of Records (POR) count for a give Partner and Enterprise Account.
returns Boolean value
 */

public with sharing class getPORs {
  //EDGE-151592 this method takes the partner Account and customeraccount as input and returns the POR exists flag
  public static boolean isPOR(Id PartnerAcc,Id CustomerAcc,String status)
  {
      boolean hasPOR=false;
      try{
          if(!String.isEmpty(PartnerAcc) && 
             !String.isEmpty(CustomerAcc) && 
             !String.isEmpty(status)
            )
          {
              Integer por=[SELECT Count() FROM Partner_of_Record__c WHERE 
                                                    Customer__c=: CustomerAcc AND 
                                                    Partner__c=:PartnerAcc AND 
                                                    Status__c=:status];
              if(por>0)
              {
                  hasPOR=true;
              }
              
          }
      }//try close
         catch(exception e)
        {
        system.debug('exception : '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());
        throw e;  
        }
      return hasPOR;
  }
  
  //Changes Start for Adaptive Care (DPG-1878); This method takes CustomerAcc and status as input parameter and return the POR exist flag.
  Public static Boolean isPORADC(Id CustomerAcc,String status)
  {
       Boolean isPartnerOfRecord = false;
   
            //DPG-2228 - Condition added for POR Status
            if(!String.isEmpty(CustomerAcc) && !String.isEmpty(status)){
                Integer porCnt= [SELECT Count() FROM Partner_of_Record__c WHERE Customer__c =:CustomerAcc and Status__c=:status];
                if(porCnt>0){
                    isPartnerOfRecord = true;
                }   
            }
             
      return isPartnerOfRecord;
  }
 

 //Changes Start for Adaptive Care (DPG-1878); This method takes CustomerAcc and status as input parameter and return the POR exist flag.
  
   @AuraEnabled(cacheable=true)
  Public static Boolean getporofcontact(Id contactId)
  {
       Boolean isPartnerOfRecord = false;
           //get userinfo 
           Id PartnerAccountId;
           Id CustomerAcc;
           Id userContactId ;
          String userid=UserInfo.getUserId();
         // String userid='0052N000000hUBQ';
           if(userid!=null)
           {
               List<User> users =[SELECT ContactId FROM user WHERE Id=:userid];
               if(users.Size()>0)
               {
               userContactId =users[0].ContactId;
               }
               
          }
          System.debug('userContactId '+userContactId );
          
          if(userContactId !=null)
          {
              List<Contact> userconlist  =[SELECT AccountId FROM Contact WHERE Id=:userContactId];
                PartnerAccountId =userconlist [0].AccountId;
          }
          
          System.debug('PartnerAccountId '+PartnerAccountId);
          
           if(contactId !=null)
          {
              List<Contact> conlist  =[SELECT AccountId FROM Contact WHERE Id=:contactId];
              if(conlist.Size()>0)
              {
                CustomerAcc =conlist[0].AccountId;
              }
          }
          
          System.debug('CustomerAcc '+CustomerAcc ); 
                
           //DPG-2228 - Condition added for POR Status
            if(!String.isEmpty(CustomerAcc) &&  !String.isEmpty(PartnerAccountId)){
                Integer porCnt= [SELECT Count() FROM Partner_of_Record__c WHERE Customer__c =:CustomerAcc AND Partner__c=:PartnerAccountId AND Status__c='Active'];
                if(porCnt>0){
                    isPartnerOfRecord = true;
                }   
            }
           
          System.debug('isPartnerOfRecord '+isPartnerOfRecord);   
               
      return isPartnerOfRecord;
  }

  @AuraEnabled(cacheable=true)
    Public static Map<Boolean,List<String>> getPORDomainsList(ID accountId)
    {
        Boolean isPartner = FeatureManagement.checkPermission('Partner_User');
        List<String> domainList= new List<String>();
        Map<Boolean,List<String>> resultMap= new Map<Boolean,List<String>>();
        if(isPartner){
            String userid=UserInfo.getUserId();
            User userRecord=[select accountid from user where id=:userid ];
            for(Partner_of_Record_Domain__c porDomain: [select id,Domain_Name__c,Status__c from Partner_of_Record_Domain__c where 
                                                        Partner_of_Record__r.Customer__r.id=:accountId AND 
                                                        Partner_of_Record__r.Partner__r.id=:userRecord.accountid AND 
                                                        Status__c ='Active'])
            {
                domainList.add(porDomain.Domain_Name__c);
            }
            resultMap.put(true,domainList);
        }else
            resultMap.put(false,domainList);
        return resultMap;
    }
 

}