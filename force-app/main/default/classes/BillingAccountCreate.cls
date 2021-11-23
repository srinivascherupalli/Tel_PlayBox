//   Prajakta    19/07/2021         DIGI-855 Enhance billing account create/update flow to filter out digitally ineligible customer contacts so that it can't be assigned as a billing contact

public with sharing class BillingAccountCreate {
    private static BillingAccountCreate singleton = new BillingAccountCreate();
   
    /* A private Constructor prevents any other
* class from instantiating.
*/
    private BillingAccountCreate() {}
    /* Static 'instance' method */
    public static BillingAccountCreate getInstance() {
        return singleton;
    }
    @AuraEnabled
    public static List < AccountContactRelation > fetchAccount(String searchKeyWord, String acct, List < AccountContactRelation > secondaryConList, Boolean isAllCon) {
        system.debug('Apex class++');
        String searchKey = searchKeyWord + '%';
        System.debug('--- searchKey: ' + searchKey);
        //Delegating call to BillingAccountService
        List <AccountContactRelation> returnList = BillingAccountService.fetchAccountOperation(
            searchKey, acct, secondaryConList, isAllCon);
        return returnList;
    }
    @AuraEnabled
    public static List < AccountContactRelation > fetchAccountSecondaryContact(String searchKeyWord, String acct, String conID, List < AccountContactRelation > secondaryConList, Boolean isAllCon) {
        system.debug('Apex class++');
        String searchKey = searchKeyWord + '%';
        List < AccountContactRelation > returnList = new List < AccountContactRelation > ();
        if (searchKey == '%') {
            return fetchSecondaryContact(acct, conID, secondaryConList, isAllCon);
        } else {
            Boolean topLevelParent = true;
            String objId = acct;
            List < Id > allParentIds = new List < Id > ();
            if (acct != null) {
                allParentIds.add(acct);
            }
            if(isAllCon){
                topLevelParent = false;
            }
            Account allAccountsInHierarachy = [Select Id, ParentId From Account where Id =: objId limit 1];
            while (topLevelParent) {
                if (allAccountsInHierarachy.ParentId != null) {
                    objId = allAccountsInHierarachy.ParentId;
                    allParentIds.add(objId);
                    topLevelParent = false; //INC000095967476 Fix
                } else {
                    topLevelParent = false;
                }
            }
            List < id > secondaryConListId = new List < id > ();
            for (AccountContactRelation acrChild: secondaryConList) {
                secondaryConListId.add(acrChild.id);
            }
            List < AccountContactRelation > lstOfContact = [SELECT Id, AccountId, ContactId, StartDate, IsActive, Roles, Contact.Account.Name, Contact_Type__c, Contact_Usage__c, Account.Name, Account.Account_UUID__c, Contact.Name, Contact.Email,Contact.Sales_Contact_Status__c,Contact.Raise_Billing_Disputes__c FROM AccountContactRelation where Contact.Name LIKE: searchKey and AccountId in: allParentIds and Id !=: conID and Roles != 'Non-Authorised' and  Contact.Sales_Contact_Status__c ='Eligible' and Contact.Raise_Billing_Disputes__c = true and ID NOT IN: secondaryConListId];//DIGI-855
                                                           
            system.debug('lstOfContact' + lstOfContact);
            for (AccountContactRelation acc: lstOfContact) {
                returnList.add(acc);
            }
        }
        return returnList;
    }
    @AuraEnabled
    public static List < cscrm__Address__c > fetchAdd(String SearchKeyWordAdd, String acct, Boolean isAllCon) {
        String searchKey = SearchKeyWordAdd + '%';
        System.debug('-----' + searchKey);
        List < cscrm__Address__c > returnList = new List < cscrm__Address__c > ();
        if (searchKey == '%') {
            return fetchBillingAddress(acct, isAllCon);
        } 
        else {
            searchKey = '%' + searchKey + '%';
            returnList = [select name from cscrm__Address__c where Name LIKE:  searchKey LIMIT 10];
            system.debug('returnList' + returnList);
        }
        return returnList;
    }
    @AuraEnabled
    public static String fetchAccountDefault(String id) {
        List < Account > returnList = new List < Account > ();
        if (id.length() > 0) {
            List < Account > lstOfAccount = [select id, Name, CIDN__c from account where Id =: id];
            if (lstOfAccount != null && !lstOfAccount.isEmpty()) {
                for (Account acc: lstOfAccount) {
                    returnList.add(acc);
                }
                system.debug('returnList' + returnList);
            }
        }
        system.debug('returnListFinal' + JSON.serialize(returnList[0]));
        return JSON.serialize(returnList[0]);
    }
    @AuraEnabled
    public static String fetchban(String id) {
        //List < Billing_Account__c > returnList = new List < Billing_Account__c > ();
        if (id != NULL) {
            Billing_Account__c lstOfAccount = [select id, Include_related_Customer_Account_Contact__c, Name,Retention__c, 
                                               Status__c, Account__r.Name, Account__r.Id, Customer_Account_Number__c, 
                                               Account__r.CIDN__c, Billing_Account_Number__c, Billing_Account_Owner__r.Name, 
                                               Billing_Address__r.Name, CreatedDate, LastModifiedDate,Written_Off__c,Write_off_in_U2C__c,PreDebt__c,BillCycleday__c
                                               from Billing_Account__c where Id =: id LIMIT 1];
            if (lstOfAccount != null) {
                return JSON.serialize(lstOfAccount);
            }
        }
        return null;
    }
    @AuraEnabled
    public static User getCreatedBy(Id recordId) {
        Billing_Account__c vehicle = [select id, CreatedById from Billing_Account__c where Id =: recordId];
        User user = null;
        if (vehicle.CreatedById != null) {
            user = [select id, Name from User where Id =: vehicle.CreatedById];
        }
        return user;
    }
    @AuraEnabled
    public static User getModifiedBy(Id recordId) {
        Billing_Account__c vehicle = [select id, LastModifiedById from Billing_Account__c where Id =: recordId];
        User user = null;
        if (vehicle.LastModifiedById != null) {
            user = [select id, Name from User where Id =: vehicle.LastModifiedById];
        }
        return user;
    }
    @AuraEnabled
    public static String saveRecs(String billNumber, String paymentterms, String billCycleDay, String custAccName, 
                                  AccountContactRelation billingAccOwner, cscrm__Address__c billingAdd, 
                                  List < AccountContactRelation > contactList, Boolean allConAdd,Boolean preDebtFlag,Boolean retentionFlag) {
                                //EDGE-223836. Kalashree Borgaonkar. Segreagating Legacy digi vs legacy billing accounts by assigning recordtype. start  
                                      String billingRecordTypeid=null;
                                      List<RecordType> recordtype =  [SELECT id, DeveloperName FROM RecordType where DeveloperName = 'Digitised'  ];
                                      if(!recordtype.isEmpty()){
                                          billingRecordTypeid=recordtype[0].id;
                                      }
                                     
                                //EDGE-223836. Kalashree Borgaonkar. Segreagating Legacy digi vs legacy billing accounts by assigning recordtype. end  
                                      system.debug('Inside save apex: preDebtFlag'+preDebtFlag);
                                      preDebtFlag = (preDebtFlag!=null)?preDebtFlag:false; 
                                      Billing_Account__c billAcc = [select id, PreDebt__c,BillCycleday__c,Status__c, Account__c, Billing_Account_Number__c, Billing_Account_Owner__c, Billing_Address__c, Include_related_Customer_Account_Contact__c from Billing_Account__c where Billing_Account_Number__c =: billNumber][0];
                                      system.debug('billAcc' + billAcc);
                                      if (billAcc != null) {
                                          try {
                                              billAcc.Billing_Account_Number__c = billNumber;
                                              billAcc.Include_related_Customer_Account_Contact__c = allConAdd;
                                              billAcc.PreDebt__c = preDebtFlag;
                                              billAcc.BillCycleday__c = Integer.valueOf(billCycleDay);//EDGE-131005
                                              system.debug('BillCycleDay------------------------->'+Integer.valueOf(billCycleDay) +billAcc.BillCycleday__c);
                                              if(billingRecordTypeid!=null){
                                                   billAcc.RecordTypeId  = billingRecordTypeid;
                                              }
                                              if (custAccName != null) {
                                                  billAcc.Account__c = custAccName;
                                                  system.debug('ACCOUNT::' + billAcc.Account__c);
                                              }
                                              if (billingAccOwner != null) {
                                                  billAcc.Billing_Account_Owner__c = billingAccOwner.ContactId;
                                              }
                                              if (billingAdd != null) {
                                                  billAcc.Billing_Address__c = billingAdd.Id;
                                              }
                                              if(retentionFlag != null){
                                                  billAcc.Retention__c=retentionFlag;
                                              }
                                              system.debug('Status value is' + billAcc.Status__c);
                                              update billAcc;
                                              List < Functional_Contact_Role__c > FCRList = new List < Functional_Contact_Role__c > ();
                                              //Create FCR lines goes here:
                                              Id recordTypeId = Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Billing Account Role').getRecordTypeId();
                                              Functional_Contact_Role__c FCR = new Functional_Contact_Role__c(RecordTypeId = recordTypeId);
                                              FCR.Billing_Account_Number__c = billAcc.id;
                                              FCR.ContactID__c = billAcc.Billing_Account_Owner__c;
                                              FCR.Is_Primary__c = true;
                                              FCR.Role__c = 'Billing Contact';
                                              FCRList.add(FCR);
                                              system.debug('FCRList' + FCRList);
                                              for (AccountContactRelation acrChild: contactList) {
                                                  system.debug('acrChild ' + acrChild);
                                                  system.debug('acrChild.ContactId ' + acrChild.ContactId);
                                                  if (acrChild.ContactId != null && !String.isBlank(acrChild.ContactId)) {
                                                      system.debug('acrChild.ContactId------ ' + acrChild.ContactId);
                                                      Functional_Contact_Role__c FCRObj = new Functional_Contact_Role__c(RecordTypeId = recordTypeId);
                                                      FCRObj.Billing_Account_Number__c = billAcc.id;
                                                      FCRObj.ContactID__c = acrChild.ContactId;
                                                      FCRObj.Is_Primary__c = false;
                                                      FCRObj.Role__c = 'Billing Contact';
                                                      FCRList.add(FCRObj);
                                                  }
                                              }
                                              system.debug('FCRList1' + FCRList);
                                              insert FCRList;
                                              return billAcc.Id;
                                          } catch (Exception e) {
                                              System.debug('Exception e in saveRecs: '+e.getStackTraceString());
                                              billAcc.Status__c = 'Error';
                                              update billAcc;
                                              return billAcc.Id;
                                          }
                                      }
                                      return null;
                                  }
    @AuraEnabled
    public static String saveEditedRecords(String billNumber, String billingAccOwner, String billingAdd, 
                                           List < AccountContactRelation > contactList, boolean allConAdd,
                                           String billingstatus,boolean checkRetension, String billcycleDate) {
                                               
                                                checkRetension = (checkRetension!=null)?checkRetension:false;
                                               system.debug('*********'+checkRetension);
                                               Billing_Account__c billAcc = [select id, Status__c, Include_related_Customer_Account_Contact__c, Account__c, Billing_Account_Number__c, Billing_Account_Owner__c, Billing_Address__c from Billing_Account__c where Billing_Account_Number__c =: billNumber LIMIT 1];
                                               system.debug('billAcc' + billAcc);
                                               String msg = '';
                                               if (billAcc != null) {
                                                   try {
                                                       List < Functional_Contact_Role__c > FCRList = [Select id, Billing_Account_Number__c, ContactID__c from Functional_Contact_Role__c where Billing_Account_Number__c =: billAcc.id and Is_Primary__c = false and Role__c = 'Billing Contact'];
                                                       System.debug('Inside fetchOtherContactListForView Method FCRList' + FCRList);
                                                       delete FCRList;
                                                       Id recordTypeId = Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Billing Account Role').getRecordTypeId();
                                                       List < Functional_Contact_Role__c > FCREditedList = new List < Functional_Contact_Role__c > ();
                                                       if (billingAccOwner != null && billAcc.Billing_Account_Owner__c != billingAccOwner) {
                                                           /*
Functional_Contact_Role__c FCROld = [Select id from Functional_Contact_Role__c where Billing_Account_Number__c =: billAcc.id And ContactID__c =: billAcc.Billing_Account_Owner__c And Is_Primary__c =: true LIMIT 1];
if(FCROld !=null)
{
system.debug('FCROld' + FCROld);
Delete FCROld;
}
*/
                                                           
                                                           billAcc.Billing_Account_Owner__c = billingAccOwner;
                                                           system.debug('billAcc1' + billAcc);
                                                           
                                                           Functional_Contact_Role__c FCRNew = new Functional_Contact_Role__c(RecordTypeId = recordTypeId);
                                                           FCRNew.Billing_Account_Number__c = billAcc.id;
                                                           FCRNew.ContactID__c = billAcc.Billing_Account_Owner__c;
                                                           FCRNew.Is_Primary__c = true;
                                                           FCRNew.Role__c = 'Billing Contact';
                                                           FCREditedList.add(FCRNew);
                                                           
                                                           system.debug('FCREditedList' + FCREditedList);
                                                           
                                                       }
                                                       for (AccountContactRelation acrChild: contactList) {
                                                           if (acrChild.ContactId != null && !String.isBlank(acrChild.ContactId)) {
                                                               Functional_Contact_Role__c FCRObj = new Functional_Contact_Role__c(RecordTypeId = recordTypeId);
                                                               FCRObj.Billing_Account_Number__c = billAcc.id;
                                                               FCRObj.ContactID__c = acrChild.ContactId;
                                                               FCRObj.Is_Primary__c = false;
                                                               FCRObj.Role__c = 'Billing Contact';
                                                               FCREditedList.add(FCRObj);
                                                           }
                                                       }
                                                       system.debug('FCREditedList' + FCREditedList);
                                                       if(FCREditedList !=null)
                                                       {
                                                           insert FCREditedList;
                                                       }
                                                       if (billingAdd != null) {
                                                           billAcc.Billing_Address__c = billingAdd;
                                                       }
                                                       system.debug('billingaccount' +billcycleDate);
                                                       boolean billcycleaccess = False;
                                                       Billcycledate__c billingday = Billcycledate__c.getInstance();
               											 billcycleaccess= billingday.billcycleEdit__c;
                                                       if (billcycleDate != null && billcycleaccess ) {
                                                           billAcc.BillCycleday__c = Integer.valueOf(billcycleDate);
                                                       }
                                                       billAcc.Include_related_Customer_Account_Contact__c = allConAdd;
                                                       billAcc.IsUpdated__c = true;
                                                       //EDGE-147511
                                                       billAcc.Status__c = billingstatus;
                                                       billAcc.Retention__c = checkRetension;
                                                       
                                                       system.debug('Status value is' + billAcc);
                                                       update billAcc;
                                                       msg = billAcc.Id;
                                                       return billAcc.Id;
                                                   } catch (Exception e) {
                                                       System.debug('Exception>>>' + e.getMessage());
                                                       billAcc.Status__c = 'Error';
                                                       update billAcc;
                                                       //return billAcc.Id;
                                                       msg = e.getMessage();
                                                   }
                                               }
                                               return msg;
                                               
                                               
                                           }
    @AuraEnabled
    public static String saveEditedRecordsFromView(String billNumber, String billingAccOwner, String billingAdd, List < AccountContactRelation > contactList, boolean allConAdd) {
        Billing_Account__c billAcc = [select id, Status__c, Include_related_Customer_Account_Contact__c, Account__c, Billing_Account_Number__c, Billing_Account_Owner__c, Billing_Address__c from Billing_Account__c where Billing_Account_Number__c =: billNumber LIMIT 1];
        system.debug('billAcc' + billAcc);
        if (billAcc != null) {
            try {
                Id recordTypeId = Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Billing Account Role').getRecordTypeId();
                List < Functional_Contact_Role__c > FCREditedList = new List < Functional_Contact_Role__c > ();
                if (billingAccOwner != null && billAcc.Billing_Account_Owner__c != billingAccOwner) {
                    Functional_Contact_Role__c FCROld = [Select id from Functional_Contact_Role__c where Billing_Account_Number__c =: billAcc.id And ContactID__c =: billAcc.Billing_Account_Owner__c And Is_Primary__c =: true LIMIT 1];
                    system.debug('FCROld' + FCROld);
                    Delete FCROld;
                    billAcc.Billing_Account_Owner__c = billingAccOwner;
                    system.debug('');
                    Functional_Contact_Role__c FCRNew = new Functional_Contact_Role__c(RecordTypeId = recordTypeId);
                    FCRNew.Billing_Account_Number__c = billAcc.id;
                    FCRNew.ContactID__c = billAcc.Billing_Account_Owner__c;
                    FCRNew.Is_Primary__c = true;
                    FCRNew.Role__c = 'Billing Contact';
                    insert FCRNew;
                }
                if (billingAdd != null) {
                    billAcc.Billing_Address__c = billingAdd;
                }
                billAcc.Include_related_Customer_Account_Contact__c = allConAdd;
                billAcc.IsUpdated__c = true;
                system.debug('Status value is' + billAcc.Status__c);
                update billAcc;
                return billAcc.Id;
            } catch (Exception e) {
                billAcc.Status__c = 'Error';
                update billAcc;
                return billAcc.Id;
            }
        }
        return null;
    }
    @AuraEnabled
    public static List < AccountContactRelation > fetchOtherContactListForView(String acct, String billNumber) {
        Billing_Account__c billAcc = [select id, Status__c, Account__c, Billing_Account_Number__c, Billing_Account_Owner__c, Billing_Address__c from Billing_Account__c where Billing_Account_Number__c =: billNumber LIMIT 1];
        List < Functional_Contact_Role__c > FCRList = [Select id, Billing_Account_Number__c, ContactID__c from Functional_Contact_Role__c where Billing_Account_Number__c =: billAcc.id and Is_Primary__c = false and Role__c = 'Billing Contact'];
        List < id > secondaryConListId = new List < id > ();
        for (Functional_Contact_Role__c FCRObj: FCRList) {
            secondaryConListId.add(FCRObj.ContactID__c);
        }
        List < AccountContactRelation > lstOfContact = [SELECT Roles, Account.Name, Contact.Name, Contact.Email FROM AccountContactRelation where AccountId =: acct and Roles != 'Non-Authorised'
                                                        and ContactId IN: secondaryConListId
                                                       ];
        system.debug('lstOfContact' + lstOfContact);
        return lstOfContact;
    }
    @AuraEnabled
    public static List < AccountContactRelation > fetchBillingAccount(String acct, List < AccountContactRelation > secondaryConList, Boolean isAllCon) {
        system.debug('contact++');
        Boolean topLevelParent = true;
        String objId = acct;
        List < Id > allParentIds = new List < Id > ();
        if (acct != null) {
            allParentIds.add(acct);
        }
        if(isAllCon){
            topLevelParent = false;
        }
        Account allAccountsInHierarachy = [Select Id, ParentId From Account where Id =: objId limit 1];
        while (topLevelParent) {
            if (allAccountsInHierarachy.ParentId != null) {
                objId = allAccountsInHierarachy.ParentId;
                allParentIds.add(objId);
                topLevelParent = false;//INC000095967476 Fix
            } else {
                topLevelParent = false;
            }
        }
        List < id > secondaryConListId = new List < id > ();
        for (AccountContactRelation acrChild: secondaryConList) {
            secondaryConListId.add(acrChild.id);
        }
        List < AccountContactRelation > lstOfContact = [SELECT Roles, Account.Name, Contact.Name, Contact.Email,Contact.Sales_Contact_Status__c,Contact.Raise_Billing_Disputes__c FROM AccountContactRelation where AccountId IN: allParentIds and Contact.Sales_Contact_Status__c ='Eligible' and Contact.Raise_Billing_Disputes__c = true and Roles != 'Non-Authorised' and ID NOT IN: secondaryConListId]; // DIGI-855
                                                       
        system.debug('lstOfContact' + lstOfContact);
        return lstOfContact;
    }
    @AuraEnabled
    public static List < AccountContactRelation > fetchBillingAccountView(String acct, String billingAccountId, Boolean isAllCon) {
        system.debug('contact++');
        Boolean topLevelParent = true;
        String objId = acct;
        List < Id > allParentIds = new List < Id > ();
        if (acct != null) {
            allParentIds.add(acct);
        }
        if(isAllCon){
            topLevelParent = false;
        }
        Account allAccountsInHierarachy = [Select Id, ParentId From Account where Id =: objId limit 1];
        while (topLevelParent) {
            if (allAccountsInHierarachy.ParentId != null) {
                objId = allAccountsInHierarachy.ParentId;
                allParentIds.add(objId);
            } else {
                topLevelParent = false;
            }
        }
        List < Functional_Contact_Role__c > FCRList = [Select id, Billing_Account_Number__c, ContactID__c, ContactID__r.id from Functional_Contact_Role__c where Billing_Account_Number__c =: billingAccountId and Is_Primary__c = false and Role__c = 'Billing Contact'];
        List < id > contactIds = new List < Id > ();
        for (Functional_Contact_Role__c fcr: FCRList) {
            contactIds.add(fcr.ContactID__r.id);
        }
        List < AccountContactRelation > lstOfContact = [SELECT Roles, Account.Name, Contact.Name, Contact.Email FROM AccountContactRelation where AccountId IN: allParentIds and Roles != 'Non-Authorised'
                                                        and Contact.id NOT IN: contactIds
                                                       ];
        system.debug('lstOfContact' + lstOfContact);
        return lstOfContact;
    }
    @AuraEnabled
    public static List < AccountContactRelation > fetchSecondaryContact(String acct, string conID, List < AccountContactRelation > secondaryConList, Boolean isAllCon) {
        system.debug('contact++');
        Boolean topLevelParent = true;
        String objId = acct;
        List < Id > allParentIds = new List < Id > ();
        if (acct != null) {
            allParentIds.add(acct);
        }
        if(isAllCon){
            topLevelParent = false;
        }
        Account allAccountsInHierarachy = [Select Id, ParentId From Account where Id =: objId limit 1];
        while (topLevelParent) {
            if (allAccountsInHierarachy.ParentId != null) {
                objId = allAccountsInHierarachy.ParentId;
                allParentIds.add(objId);
                topLevelParent = false; //INC000095967476 Fix
            } else {
                topLevelParent = false;
            }
        }
        List < id > secondaryConListId = new List < id > ();
        for (AccountContactRelation acrChild: secondaryConList) {
            secondaryConListId.add(acrChild.id);
        }
        List < AccountContactRelation > lstOfContact = [SELECT id, Roles, Account.Name, Contact.Name, Contact.Email,Contact.Sales_Contact_Status__c,Contact.Raise_Billing_Disputes__c FROM AccountContactRelation where AccountId in: allParentIds and Contact.Sales_Contact_Status__c ='Eligible' and Contact.Raise_Billing_Disputes__c = true and ID !=: conID and Roles != 'Non-Authorised' and ID NOT IN: secondaryConListId]; //DIGI-855
                                                       
                                                        
        system.debug('lstOfContact' + lstOfContact);
        return lstOfContact;
    }
    @AuraEnabled
    public static List < cscrm__Address__c > fetchBillingAddress(String acct, Boolean isAllCon) {
        system.debug('id is' + acct);
        //Get  Addresses from all Parent Account
        Boolean topLevelParent = isAllCon;
        String objId = acct;
        List < cscrm__Address__c > returnList = new List < cscrm__Address__c > ();
        returnList = [select name from cscrm__Address__c LIMIT 10];
        system.debug('returnList' + returnList);
        return returnList;
    }
    /*
@AuraEnabled
public static string fetchBillingAccountNumber() {
system.debug('i am here in aPEX');
Billing_Account__c bill = new Billing_Account__c();
bill = BillingOrderManager.allocateBillingAccount();
system.debug('Bill No' + bill + '   ' + bill.Billing_Account_Number__c);
return bill.Billing_Account_Number__c;
}
*/
    @AuraEnabled
    public static string fetchBillingAccountNumber() {
        system.debug('i am here in aPEX');
        system.debug('fetchBillingAccountNumber');
        //Billing_Account__c bill = new Billing_Account__c();
        //string bill;
        string bill = BillingOrderManager.allocateBillingAccount();
        //system.debug('Bill No' + bill + '   ' + bill.Billing_Account_Number__c);
        //return bill.Billing_Account_Number__c;
        system.debug('Bill No' + bill);
        return bill;
    }
    @AuraEnabled
    public static string fetchBillingAccountNumberFromBDS(String ban) {
        system.debug('i am here in aPEX ');
        system.debug('i am here in aPEX ' + String.valueOf(ban));
        String resp = JSON.serialize(BillingOrderManager.fetchBillingDetailsFromBDS(ban));
        System.debug(resp);
        return resp;
    }
    @AuraEnabled
    public static String fetchAccountContactRelObj(String accountv, String contactv) {
        system.debug('>>>>'+accountv + '=====' + contactv);
        if (accountv != NULL && contactv != NULL) {
            List<AccountContactRelation> accRelcCon = [select id, Roles, Account.Name, Contact.Name, Contact.Email 
                                                       from AccountContactRelation where AccountId =: accountv 
                                                       and Roles != 'Non-Authorised'
                                                       and ContactId =: contactv LIMIT 1
                                                      ];
            system.debug('>>>>'+JSON.serialize(accRelcCon));
            if (!accRelcCon.isEmpty()) {
                return JSON.serialize(accRelcCon);
            }
        }
        return null;
    }
    @AuraEnabled
    public static Map < String, String > getLabels() {
        String type = 'billing_account__c';
        Map < String, Schema.SObjectType > schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map < String, Schema.SObjectField > fieldMap = leadSchema.getDescribe().fields.getMap();
        Map < String, String > fieldsLabel = new Map < String, String > ();
        for (String fieldName: fieldMap.keySet()) {
            fieldsLabel.put(fieldName, fieldMap.get(fieldname).getDescribe().getLabel());
        }
        return fieldsLabel;
    }
    @AuraEnabled
    public static boolean featureToggle() {
        Feature_Flag__mdt ft = FeatureFlagUtility.getFeatureTogglingByName('B2B2');
        return ft.IsActive__c;
    }
    @AuraEnabled
    public static void checkBillingAccountStatus(string bill){
        BillingOrderManager.createBillingAccount(bill);
    }
    @AuraEnabled
    public static string BillingAccountStatus(string id){
        Billing_Account__c lstOfAccount = [select id, Status__c from Billing_Account__c where Id =: id LIMIT 1];
        return lstOfAccount.Status__c;
    }
    //EDGE-147511
    @AuraEnabled
    public static boolean isCheckForFinal(string billingaccId){
        boolean checkstatus = true;
        List<String> lstStaus = System.label.Service_Status.split(',');
        if(billingaccId != null){
            List<csord__Subscription__c> lstsubscription = [SELECT id,csord__Status__c,Billing_Account__c FROM csord__Subscription__c
                                                            WHERE Billing_Account__c =:billingaccId];
            for(csord__Subscription__c subs: lstsubscription){
                if(!lstStaus.contains(subs.csord__Status__c) ){
                    checkstatus = false;
                }
            }
        }
        return checkstatus;
    }
    //EDGE-147511
    //EDGE-200254
    @AuraEnabled
    public static list<csord__Subscription__c> isCheckForFinalise(string billingaccId){
		List<csord__Subscription__c> lstMACDSubLst = new List<csord__Subscription__c>();
        if(billingaccId != null){
            lstMACDSubLst = BillingAccountCreateHelper.isCheckForFinal(billingaccId);
        }
		return lstMACDSubLst;
    }
    //EDGE-200254	    
    @AuraEnabled  
    public static List<ConstantMetadataUtility.picklistWrapper> findPicklistOptions(string objAPIName, string fieldAPIname) {
        //ConstantMetadataUtility.findPicklistOptions('Billing_Account__c','Status__c');
        List<ConstantMetadataUtility.picklistWrapper> picklistvalues = ConstantMetadataUtility.findPicklistOptions(objAPIName,fieldAPIname);
        return picklistvalues;
    }
    /*@AuraEnabled
public static void saveFCRContacts(List<Functional_Contact_Role__c> ListFCRContact){
Insert ListFCRContact;
}*/
    /******************************************************************
EDGE        -147506
Method      -handleDisplay 
Description -handle displaying of fields on create and edit screen
Author      -Kalashree Borgaonkar
******************************************************************/
    @AuraEnabled  
    public static HandleDisplay handleDisplay(Boolean isEdit) {
        HandleDisplay display = new HandleDisplay();
        List<PermissionSetAssignment>  permissions = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name 
                                                      FROM PermissionSetAssignment 
                                                      WHERE Assignee.id=:UserInfo.getUserId()];
        List<String> permissionList = new List<String>();
        for(PermissionSetAssignment permission: permissions){
            permissionList.add(permission.PermissionSet.Name);
        }
        Boolean hasInsolvencyPermission ;
        if(permissionList.contains('Insolvency_for_Billing_Consultant')){
            hasInsolvencyPermission=true;
        }
        else{
            hasInsolvencyPermission=false;
        }
        if(hasInsolvencyPermission){ 
            if(isEdit){
                display.showBillingStatus = true;
                display.showPreDebt = false;
            } 
            else{
                display.showPreDebt = true;
                display.showBillingStatus = false;
            }
        }
        System.debug('display: '+display);
        return display;
    }
    
    
    public class HandleDisplay{
        @AuraEnabled
        public Boolean showPreDebt;
        @AuraEnabled
        public Boolean showBillingStatus;
        @AuraEnabled
        public Boolean isApprovalBtnDisabled;
        @AuraEnabled
        public Boolean isApprovalBtnShown;
        public HandleDisplay(){
            showPreDebt=false;
            showBillingStatus=false;
        }
        
        
    }
    /******************************************************************
EDGE        -153317
Method      -fetchActiveBaskets 
Description -Checks if any active baskets are associated with billing account
Author      -Aishwarya
******************************************************************/ 
    @AuraEnabled
    public static List<cscfga__Product_Basket__c> fetchActiveBaskets(string billingaccId){
        List<cscfga__Product_Basket__c> bsktAcc=new List<cscfga__Product_Basket__c>();
        
        List<String> basketStaus = System.label.BasketStage.split(',');
        if(billingaccId != null){
            Billing_Account__c billAcc = [select id, Status__c, Account__c, Billing_Account_Number__c from Billing_Account__c where id =: billingaccId LIMIT 1];
            bsktAcc= [SELECT id,csordtelcoa__Basket_Stage__c,Name,Description__c
                      FROM cscfga__Product_Basket__c where csbb__Account__c =:billAcc.Account__c
                      AND csordtelcoa__Basket_Stage__c NOT IN :basketStaus];
        }
        List< cscfga__Product_Configuration__c > productsAlreadyInTheBasket = new List < cscfga__Product_Configuration__c > ();
        
        productsAlreadyInTheBasket = [SELECT id,cscfga__Root_Configuration__c,cscfga__Product_Basket__c ,
                                      ( SELECT id,cscfga__Value__c,name,cscfga__Product_Configuration__r.Name,cscfga__Product_Configuration__c 
                                       FROM cscfga__Attributes__r where name =:'BillingAccountLookup')
                                      FROM cscfga__Product_Configuration__c
                                      WHERE cscfga__Product_Basket__c IN :bsktAcc
                                      
                                     ];
        List<Id> activeBaskets=new List<Id>();
        
        if(productsAlreadyInTheBasket!=null){
            for(cscfga__Product_Configuration__c pc:productsAlreadyInTheBasket){
                if(pc.cscfga__Attributes__r!= null && pc.cscfga__Attributes__r.size()>0){
                    if( pc.cscfga__Attributes__r[0].cscfga__Value__c==billingaccId){
                        activeBaskets.add(pc.cscfga__Product_Basket__c);
                    }
                    
                }
            }
        }
        
        List<cscfga__Product_Basket__c> listOfActiveBaskets=new List<cscfga__Product_Basket__c>();
        for(cscfga__Product_Basket__c basket:bsktAcc){
            if(activeBaskets.contains(basket.id)){
                listOfActiveBaskets.add(basket);
            }
        }
        return listOfActiveBaskets;
    }
    /******************************************************************
EDGE        -151581
Method      -getWriteoffApprovalDisplay 
Description -handle displaying of 'Submit write off Approval' button
Author      -Kalashree Borgaonkar
******************************************************************/
    @AuraEnabled  
    public static HandleDisplay getWriteoffApprovalDisplay(String billingAccId){
        HandleDisplay display = new HandleDisplay();
        Boolean hasWrittenPermission = FeatureManagement.checkPermission('Collection_Agent_Written_Off_Permission');
        List<Billing_Account__c> billAccount = new List<Billing_Account__c>();//Added by Aman Soni as it was throwing null pointer exception for EDGE-207867
        if(hasWrittenPermission){
            display.isApprovalBtnShown = true;
            billAccount = [SELECT Balance_Amount__c, Status__c,ApprovalLevelResult__c,Written_Off__c, Write_off_in_U2C__c
                           FROM Billing_Account__c 
                           WHERE Id =:billingAccId];
        }
        //Add condition for group as well
        if(!billAccount.isEmpty()){ 
            if(isLevel3GroupMember() && billAccount[0].Balance_Amount__c>0 
               && billAccount[0].Status__c=='Final' && !Approval.isLocked(billAccount[0].id) 
               && ( billAccount[0].Written_Off__c == false && billAccount[0].Write_off_in_U2C__c==false)) {
                   display.isApprovalBtnDisabled = false;
               }
            else{
                display.isApprovalBtnDisabled = true; 
            }
        }        
        return display;  
    }
    /******************************************************************
EDGE        -151581
Method      -isLevel3GroupMember 
Description -check whether submitter is Level3 Group Member
Author      -Kalashree Borgaonkar
******************************************************************/
    public static Boolean isLevel3GroupMember(){
        Boolean isGroupMember=false;
        List<Group> Level3Group = [SELECT id FROM Group where DeveloperName  = 'Credit_Management_Level3'];
        List<GroupMember> groupMemberList;
        if(!Level3Group.isEmpty()){
            groupMemberList = [SELECT GroupId,UserOrGroupId 
                               FROM GroupMember 
                               WHERE GroupId=: Level3Group[0].id AND UserOrGroupId = :UserInfo.getUserId()];
            if(!groupMemberList.isEmpty()){
                isGroupMember = true;
            } 
        }
        return isGroupMember;
    } 
    /******************************************************************
EDGE        -151581
Method      -isLevel3GroupMember 
Description -check whether submitter is Level3 Group Member
Author      -Kalashree Borgaonkar
******************************************************************/ 
    @AuraEnabled
    public static Boolean initiateApprovalProcess(String billAccid){
        Boolean isApprovalProcessInitiated=false;
        try{
            Billing_Account__c billingAcc = [SELECT id,Approval_submitter__c FROM Billing_Account__c WHERE id= :billAccid];
            billingAcc.Approval_submitter__c = UserInfo.getUserid();
            update billingAcc;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('Submitting approval request');        
            req.setObjectId(billAccid);
            // Submit the approval request for the Opportunity        
            Approval.ProcessResult result = Approval.process(req);  
            isApprovalProcessInitiated = true;
            System.debug('isSuccess(): '+result.isSuccess());
            System.debug('getErrors(): '+result.getErrors());
        }
        catch (Exception e){
            isApprovalProcessInitiated = false;
            System.debug('Exception in initiateApprovalProcess: '+e.getStackTraceString());
        }
        return isApprovalProcessInitiated;
    }
    
    /******************************************************************
EDGE        -EDGE-167053 
Method      -isPartner 
Description -check whether login user is PRM user 
Author      -RaviTeja
******************************************************************/ 
    @AuraEnabled
    public static boolean isPartner() {
        boolean isPartner = false;
        try{
            if(FeatureManagement.checkPermission('Partner_User')){
                isPartner=true;
            }
        }
        catch(Exception e){
            system.debug('prmPartnerCheck'+e.getMessage());
        }
        return isPartner;
    }
    /******************************************************************
EDGE        -131004
Method      -showBillCycleDays 
Description -Display billCycledays On UI
Author      -Aishwarya
******************************************************************/ 
    @AuraEnabled
    public static List<Integer> showBillCycleDays(){
        List<String> lstofBillCycleDay = System.label.BillCycleday.split(',');
        
        List<Integer> billCycleDays=new List<Integer>();
        for(String s : lstofBillCycleDay) {
            billCycleDays.add(Integer.valueOf(s));
        }
        system.debug('billCycleDays'+billCycleDays);
        return billCycleDays;
    }
/***********************************************************************************************************
EDGE        - 170964
Method      - checkNotificationPreferenceForExistingPrimaryContact
Description - Check Notification Preference exist for Primary Billing Contact
Author      - Dheeraj Bhatt
**************************************************************************************************************/
    @AuraEnabled public static Boolean checkNotificationPreferenceForExistingPrimaryContact(String contactId){
        List<Notification_Preference__c> notificationPreferenceList=[SELECT Id,Contact_Id__c FROM Notification_Preference__c
                                                                     WHERE Contact_Id__c =: contactId];
        return notificationPreferenceList.isEmpty() ?false:true;
    }
/***********************************************************************************************************
EDGE        - 170964
Method      - checkNotificationPreferenceForExistingPrimaryContact
Description -Change Notification Preference to new primary Billing Contact
Author      - Dheeraj Bhatt
**************************************************************************************************************/
    @AuraEnabled public static void changeNotificationPreferenceToNewPrimaryContact(String existingContactId,String newContactId){
        List<Notification_Preference__c> notificationPreferenceList =new List<Notification_Preference__c>();
        if(String.isNotBlank(newContactId)){
            for(Notification_Preference__c notification:[SELECT Id,Contact_Id__c FROM Notification_Preference__c
                                                         WHERE Contact_Id__c =: existingContactId]){
                                                             notification.Contact_Id__c= newContactId;
                                                             notificationPreferenceList.add(notification);                                                                    
                                                         }
            if(!notificationPreferenceList.IsEmpty()){
                update notificationPreferenceList;
            }
        }
    }
    /*--added For EDGE-198145 */
     @AuraEnabled public static boolean checkFieldpermission(String mode){
         Retention_Settings__c retentionFlag= Retention_Settings__c.getInstance();
         system.debug('**mode**'+mode);
         if(mode=='Create'){
             return retentionFlag.Create__c;
         }else
             return retentionFlag.Edit__c;
    }
    /*-- EDGE-198145 ended --*/
    /*-- EDGE-217496 --*/
    @AuraEnabled
    public static boolean checkstatus (String accountIds ){
        
        boolean por = false;
        system.debug('record'+accountIds);
        system.debug('permission'+FeatureManagement.checkPermission('Partner_User'));
        /*list<Partner_of_Record__c> lstPOR;*/
        try{
            if(FeatureManagement.checkPermission('Partner_User')){
                Id usrId = userinfo.getUserId();
            	Id partnerId;
            	list<Partner_of_Record__c> lstPOR;
            	list<User> usrLst = [SELECT Id, Contact.AccountId FROM User WHERE Id = :usrId];
            	partnerId = usrLst[0].Contact.AccountId;
            	/*lstPOR = [SELECT Id,Customer__c,Partner__c FROM Partner_of_Record__c WHERE 
                                    Customer__c = :accountIds AND Partner__c = :partnerId AND Status__c = 'Active'];*/
              lstPOR = [SELECT Id,Customer__c FROM Partner_of_Record__c WHERE 
                                    Customer__c = :accountIds AND Status__c = 'Active'];
            	if(lstPOR.size() > 0){
                	por=false;
                     return por;
                    system.debug('POR staus'+por);
            		}
                else{
                    por=true;
                    system.debug('POR staus1'+por);
                    return por;
                }
            	
       	 	}
        }
        catch(Exception e){
            system.debug('prmPartnerPORCheck'+e.getMessage());
        	}
            return por;
    }
     @AuraEnabled
      public static boolean checkActivePOR (String accountIdss ){
        boolean isActPOR = false;
        try{
            if(FeatureManagement.checkPermission('Partner_User')){
                
                list<Billing_Account__c> lstCustAcct = [SELECT Id, Account__c FROM Billing_Account__c WHERE Id= :accountIdss];                
				isActPOR = BillingAccountCreate.checkstatus(lstCustAcct[0].Account__c);    
                return isActPOR;
                }
            }
		
        catch(Exception e){
            system.debug('prmPartnerPORCheck'+e.getMessage());
        }
         return isActPOR;
    }
    /*-- EDGE-217496 --*/
    /*-- DIGI-2055--*/
    @AuraEnabled
    public static boolean billcycleAcc() {
        boolean billcycleacc = false;
        try{
            if(FeatureManagement.checkPermission('Bill_Cycle_Date')){
                Billcycledate__c bill = Billcycledate__c.getInstance();
                billcycleacc= bill.billcycleEdit__c;
            }
        }
        catch(Exception e){
            system.debug('prmPartnerCheck'+e.getMessage());
        }
        return billcycleacc;
    }


}