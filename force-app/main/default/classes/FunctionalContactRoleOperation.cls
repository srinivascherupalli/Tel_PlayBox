/*********************************************************************************************************************************
 *Class Name      :   FunctionalContactRoleOperation
 *Story             :   EDGE-78293  Create PB to attach Dummy PC for Legacy Transition Services
 *Developer         :   Rohit Tripathi


Test Class : FunctionalContactRoleOperationTest
===============================================================================================================================
Sr.No.    Developer Name          Date              Story Description
2.       Abinash Barik          24/7/2019         MDM Tenancy Enrichment to capture the Tenancy Primary Contact (91164-30181)
3.       Venkata Ramanan G .    07/08/2019        MDM Tenancy Primary Contact to be created as FCR to the Order (91164 - EDGE-106457)
4.       RaviTeja               10/09/2019        FCR has to be created for Professional Service Technical Contact(EDGE-80828)
5.       RaviTeja               19/11/2020        Updated Custom Label for Professional Service in Query-EDGE-187354

 *********************************************************************************************************************************
*/
public with sharing class FunctionalContactRoleOperation {

    private class FCRWrapper {
        public List<Functional_Contact_Role__c> updateFCR{get;set;}
        public List<Functional_Contact_Role__c> insertFCR{get;set;}
        public Set<Functional_Contact_Role__c> deleteFCR{get;set;}
        public Id siteId{get;set;}
        public Id orderId{get;set;}
        public Id contactId{get;set;}
        public String roleType{get;set;}
        public String professionalServiceName{get;set;}
    }

        public static void upsertFunctionalContactRole(List<Id> lstServiceIds)
        {
            system.debug('Inside upsertFunctionalContactRole');
            List<Functional_Contact_Role__c> lstFunConRolInsert = new List<Functional_Contact_Role__c>();
            Set<Functional_Contact_Role__c> setFunConRolDelete = new Set<Functional_Contact_Role__c>();
            List<csord__Service__c> lstServices = [select SiteId__c,Primary_Contact__c, Technical_Contact__c, After_Hours_Site_Contact__c,Project_Contact__c, Site_Delivery_Contact__c, Order_Primary_Contact__c,csord__Order__c,csord__Order__r.csord__Primary_Order__c,
                                                   csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Type__c,csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,TenancyPrimaryContact__c from csord__Service__c 
                                                   where Id in :lstServiceIds and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name in 
                                                   ('IP Site',:System.Label.UC_Enterprise,:System.Label.Mobility,:System.Label.Tenancy,:System.Label.TID,:System.Label.PROFESSIONALSERVICES_PDNAME)];//Query Updated by Venkata for EDGE-106457 Query Edited by Laxmi to ad TID system label, Added PROFESSIONAL_SERVICES as part of EDGE-80828. 19 Nov-20-updated professional service label: EDGE-187354
            List<Functional_Contact_Role__c> lstFunConRolPresent = [select Id,SiteID__c,Role__c,ContactID__c,OrderID__c from Functional_Contact_Role__c where Role_Type__c = 'Site' OR Role_Type__c = 'Order'];
                    
                    system.debug('lstServices'+lstServices.size());
           
           for(csord__Service__c serv : lstServices) {
                FCRWrapper fcrWrapper = new FCRWrapper();
                fcrWrapper.updateFCR = lstFunConRolPresent;
                fcrWrapper.insertFCR = lstFunConRolInsert;
                fcrWrapper.deleteFCR = setFunConRolDelete;
                fcrWrapper.siteId = serv.SiteId__c;
                fcrWrapper.orderId = serv.csord__Order__c;
                fcrWrapper.professionalServiceName = null;
                
                
                //END EDGE-80828
                system.debug('@@PD@@'+serv.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name);
                if(serv.Primary_Contact__c != null)
                {
                    fcrWrapper.roleType = 'Primary Site Contact';
                    fcrWrapper.contactId = serv.Primary_Contact__c;
                    getFunctionalContactRole(fcrWrapper);
//                    getFunctionalContactRole(lstFunConRolPresent,serv.SiteId__c,serv.csord__Order__c,'Primary Site Contact',serv.Primary_Contact__c,lstFunConRolInsert,setFunConRolDelete);
                }
                if(serv.Technical_Contact__c != null)
                {
                    system.debug('Technical Contact'+serv.Technical_Contact__c);
                    fcrWrapper.roleType = 'Technical Contact';
                    fcrWrapper.contactId = serv.Technical_Contact__c;
                    //EDGE-80828: As a Sales User I want to see an additional role - "Professional Service Technical Contact" against Basket/Order Functional Role so that the Contact associated to Professional Service can be identified
                    if(serv.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Type__c==System.Label.PROFESSIONAL_SERVICE){
                            fcrWrapper.professionalServiceName = serv.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name;
                    }
                      getFunctionalContactRole(fcrWrapper);
//                    getFunctionalContactRole(lstFunConRolPresent,serv.SiteId__c,serv.csord__Order__c,'Technical Contact',serv.Technical_Contact__c,lstFunConRolInsert,setFunConRolDelete);
                }
                if(serv.After_Hours_Site_Contact__c != null)
                {
                    fcrWrapper.roleType = 'After Hours Contact';
                    fcrWrapper.contactId = serv.After_Hours_Site_Contact__c;
                    getFunctionalContactRole(fcrWrapper);
//                    getFunctionalContactRole(lstFunConRolPresent,serv.SiteId__c,serv.csord__Order__c,'After Hours Contact',serv.After_Hours_Site_Contact__c,lstFunConRolInsert,setFunConRolDelete);
                }
                if(serv.Project_Contact__c != null)
                {
                    fcrWrapper.roleType = 'Project Contact';
                    fcrWrapper.contactId = serv.Project_Contact__c;
                    getFunctionalContactRole(fcrWrapper);
//                    getFunctionalContactRole(lstFunConRolPresent,serv.SiteId__c,serv.csord__Order__c,'Project Contact',serv.Project_Contact__c,lstFunConRolInsert,setFunConRolDelete);
                }
                if(serv.Site_Delivery_Contact__c != null)
                {
                    fcrWrapper.roleType = 'Delivery Contact';
                    fcrWrapper.contactId = serv.Site_Delivery_Contact__c;
                    getFunctionalContactRole(fcrWrapper);
//                    getFunctionalContactRole(lstFunConRolPresent,serv.SiteId__c,serv.csord__Order__c,'Delivery Contact',serv.Site_Delivery_Contact__c,lstFunConRolInsert,setFunConRolDelete);
                }
                if(serv.Order_Primary_Contact__c != null)
                {
                    fcrWrapper.roleType = 'Order Primary Contact';
                    fcrWrapper.contactId = serv.Order_Primary_Contact__c;
                    getFunctionalContactRole(fcrWrapper);
//                    getFunctionalContactRole(lstFunConRolPresent,serv.SiteId__c,serv.csord__Order__c,'Order Primary Contact', serv.Order_Primary_Contact__c, lstFunConRolInsert,setFunConRolDelete);
                }
                // EDGE-91164 FCR Created for Tenancy Primary Contact of MDM Tenancy upon CWP Mobility 
                // and Corporate Mobile Plus Order
                if(serv.TenancyPrimaryContact__c != null)       
                {
                    fcrWrapper.roleType = 'Tenancy Primary Contact';
                    fcrWrapper.contactId = serv.TenancyPrimaryContact__c;
                    getFunctionalContactRole(fcrWrapper);
//                    getFunctionalContactRole(lstFunConRolPresent,serv.SiteId__c,serv.csord__Order__c,'Tenancy Primary Contact', serv.TenancyPrimaryContact__c, lstFunConRolInsert,setFunConRolDelete);
                }
            }
            try
            {
                if(!setFunConRolDelete.isEmpty())
                {
                    system.debug('*********setFunConRolDelete : '+ setFunConRolDelete);
                    List<Functional_Contact_Role__c> lstFunConRolDelete = new List<Functional_Contact_Role__c>();
                    lstFunConRolDelete.addAll(setFunConRolDelete);
                    delete lstFunConRolDelete;
                    system.debug('*********setFunConRolDelete : '+ setFunConRolDelete);
                }
                if(!lstFunConRolInsert.isEmpty())
                {
                    system.debug('*********lstFunConRolInsert : '+ lstFunConRolInsert);
                    for(Functional_Contact_Role__c fcr:lstFunConRolInsert){
                        system.debug('*********fcr'+ fcr);  
                    }
                    insert lstFunConRolInsert;
                    system.debug('*********lstFunConRolInsert : '+ lstFunConRolInsert);
                }
            }
            catch(DmlException  e)
            {
                system.debug(e.getMessage());
            }
        }

    public static void getFunctionalContactRole(FCRWrapper fcrWrapper){
        List<Functional_Contact_Role__c> lstFunConRolPresent = fcrWrapper.updateFCR;
        List<Functional_Contact_Role__c> lstFunConRolInsert = fcrWrapper.insertFCR;
        Set<Functional_Contact_Role__c> setFunConRolDelete = fcrWrapper.deleteFCR;
        String sSiteId = fcrWrapper.siteId;
        String sOrderId = fcrWrapper.orderId;
        String sRole = fcrWrapper.roleType;
        String sConId = fcrWrapper.contactId;
        system.debug('Inside getFunctionalContactRole');
        Boolean isFunctionalContactRolePresent = false;
        Integer index = -1;
        Integer indexMatched = -1;
        Id funConRoleRecordTypeId = Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Basket/Order Role').getRecordTypeId();
        Id Subscription_Role_RecordTypeId = Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Subscription Role').getRecordTypeId();

        for(Functional_Contact_Role__c funConRole : lstFunConRolPresent)
        {
            if(sSiteId != null)
            {
                if(funConRole.Role__c == sRole && funConRole.SiteID__c == sSiteId)
                {
                    if(funConRole.ContactID__c != sConId)
                    {
                        setFunConRolDelete.add(funConRole);
                    }else
                    {
                        isFunctionalContactRolePresent = true;
                    }
                    break;
                }
            }
            else if(sOrderId != null)
            {
                if(funConRole.Role__c == sRole && funConRole.OrderID__c == sOrderId)
                {
                    if(funConRole.ContactID__c != sConId)
                    {
                        setFunConRolDelete.add(funConRole);
                    }else
                    {
                        isFunctionalContactRolePresent = true;
                    }
                    break;
                }
            }
        }
        for(Functional_Contact_Role__c funConRole : lstFunConRolInsert)
        {

            index ++;
            if((funConRole.SiteID__c == sSiteId && funConRole.Role_Type__c == 'Site' ||
                    funConRole.OrderID__c == sOrderId && funConRole.Role_Type__c == 'Order') && funConRole.Role__c == sRole)
            {
                if(funConRole.ContactID__c  != sConId)
                {
                    system.debug('********Index : '+ index);
                    indexMatched = index;
                    isFunctionalContactRolePresent = false;
                    break;
                }
                else
                {
                    isFunctionalContactRolePresent = true;
                }
            }
        }
        if(indexMatched != -1)
        {
            lstFunConRolInsert.remove(indexMatched);
        }

        if(!isFunctionalContactRolePresent)
        {
            Functional_Contact_Role__c funConRole = new Functional_Contact_Role__c();
            if(sRole != 'Order Primary Contact' && sRole != 'Tenancy Primary Contact')
            //Condition Updated by Venkata for EDGE-106457
            {
                system.debug('sRole'+sRole);
                if(fcrWrapper.professionalServiceName != null && fcrWrapper.professionalServiceName != '' && sRole=='Technical Contact' ){
                    funConRole.RecordTypeId=Subscription_Role_RecordTypeId;
                    funConRole.Role_Type__c=System.Label.PROFESSIONAL_SERVICE;  
                     funConRole.OrderID__c = sOrderId;
                } else {
                    funConRole.SiteID__c = sSiteId;
                    funConRole.Role_Type__c = 'Site';
                }
            }
            else
            {
                funConRole.OrderID__c = sOrderId;
                funConRole.Role_Type__c = 'Order';
                if(funConRoleRecordTypeId !=null){
                    system.debug('@@recordtype'+funConRoleRecordTypeId);
                }
                funConRole.RecordtypeID=funConRoleRecordTypeId;
            }
            funConRole.Role__c = sRole;
            funConRole.ContactID__c = sConId;
            system.debug('funConRole'+funConRole);
            lstFunConRolInsert.add(funConRole);
        }
    }

//        public static void getFunctionalContactRole(List<Functional_Contact_Role__c> lstFunConRolPresent, String sSiteId, String sOrderId, String sRole, String sConId,List<Functional_Contact_Role__c> lstFunConRolInsert,Set<Functional_Contact_Role__c> setFunConRolDelete)
//        {
//            system.debug('Inside getFunctionalContactRole');
//            Boolean isFunctionalContactRolePresent = false;
//            Integer index = -1;
//            Integer indexMatched = -1;
//            Id funConRoleRecordTypeId = Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Basket/Order Role').getRecordTypeId();
//            for(Functional_Contact_Role__c funConRole : lstFunConRolPresent)
//            {
//          if(sSiteId != null)
//          {
//            if(funConRole.Role__c == sRole && funConRole.SiteID__c == sSiteId)
//            {
//              if(funConRole.ContactID__c != sConId)
//              {
//                setFunConRolDelete.add(funConRole);
//              }else
//              {
//                isFunctionalContactRolePresent = true;
//              }
//              break;
//            }
//          }
//          else if(sOrderId != null)
//          {
//            if(funConRole.Role__c == sRole && funConRole.OrderID__c == sOrderId)
//            {
//              if(funConRole.ContactID__c != sConId)
//              {
//                setFunConRolDelete.add(funConRole);
//              }else
//              {
//                isFunctionalContactRolePresent = true;
//              }
//              break;
//            }
//          }
//            }
//            for(Functional_Contact_Role__c funConRole : lstFunConRolInsert)
//            {
//
//          index ++;
//                if((funConRole.SiteID__c == sSiteId && funConRole.Role_Type__c == 'Site' ||
//                   funConRole.OrderID__c == sOrderId && funConRole.Role_Type__c == 'Order') && funConRole.Role__c == sRole)
//                {
//            if(funConRole.ContactID__c  != sConId)
//                    {
//                        system.debug('********Index : '+ index);
//                        indexMatched = index;
//                        isFunctionalContactRolePresent = false;
//                        break;
//                    }
//                    else
//                    {
//              isFunctionalContactRolePresent = true;
//                    }
//                }
//            }
//            if(indexMatched != -1)
//            {
//                lstFunConRolInsert.remove(indexMatched);
//            }
//
//            if(!isFunctionalContactRolePresent)
//            {
//                Functional_Contact_Role__c funConRole = new Functional_Contact_Role__c();
//                if(sRole != 'Order Primary Contact' && sRole != 'Tenancy Primary Contact')
//                    //Condition Updated by Venkata for EDGE-106457
//                {
//                system.debug('sRole'+sRole);
//                    funConRole.SiteID__c = sSiteId;
//                    funConRole.Role_Type__c = 'Site';
//                }
//                else
//                {
//                    funConRole.OrderID__c = sOrderId;
//                    funConRole.Role_Type__c = 'Order';
//                    if(funConRoleRecordTypeId !=null){
//                        system.debug('@@recordtype'+funConRoleRecordTypeId);
//                    }
//                    funConRole.RecordtypeID=funConRoleRecordTypeId;
//                }
//                funConRole.Role__c = sRole;
//                funConRole.ContactID__c = sConId;
//                system.debug('funConRole'+funConRole);
//                lstFunConRolInsert.add(funConRole);
//            }
//        }
    }