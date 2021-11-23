/************************************************************************
  Name: MACDObserver
  Description: Implements the ObserverApi interface
=================================================================================================================================
Change.No.    Developer Name          Date          Story Description
  1 .         Auntun                                Post upgrade changes start
  ************************************************************************/
  global with sharing class MACDObserver implements csordcb.ObserverApi.IObserver{
  /***********************************************************************
  Name: MACDObserver
  Description: Constructor 
  *******************************************************************/
  global MACDObserver()
  {}

  /*******************************************************************
  Name: execute
  Parameters: csordcb.ObserverApi.Observable o, Object arg
  Return Type: void
  Description: Method executed when MACD process is invoked
  *******************************************************************/
  global void execute(csordcb.ObserverApi.Observable o, Object arg) {
    System.debug('*************Inside MACD observer***************');
    csordtelcoa.ChangeRequestObservable observable = (csordtelcoa.ChangeRequestObservable) o;
    List<Id> clonedIds = observable.getProductConfigurationIds();
    System.debug('Clone ids: ' + clonedIds);
    //AB: post upgrade changes start
	// not needed as this logic needs to be on the custom MACD page that initiates MACD	
      /*
        List<cscfga__Product_Configuration__c> macPClist= new List<cscfga__Product_Configuration__c >([Select Id,Name, cscfga__Product_Basket__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,(SELECT Id, Name,cscfga__Value__c from cscfga__Attributes__r WHERE Name LIKE '%isMainComponent%') FROM cscfga__Product_Configuration__c  WHERE ID IN: clonedIds ]); 
        Id MACbasketId = macPClist[0].cscfga__Product_Basket__c;
        Id macOpportunityId=macPClist[0].cscfga__Product_Basket__r.cscfga__Opportunity__c;
        system.debug('macPClist---->'+macPClist[0]);
        system.debug('MACbasketId---->'+MACbasketId);
        system.debug('macOpportunityId---->'+macOpportunityId);
        //Id macOpportunityId = macBasket.cscfga__Opportunity__c;
            csordtelcoa.StatusResult statusResultMac =  csordtelcoa.API_V1.pollOpportunitySubscriptionsResult(macOpportunityId);
            system.debug('statusResultMac---->'+statusResultMac);
            //system.debug('show status===>>>>'+statusResultMac+'==='+statusResultMac.status+string.valueof(statusResultMac.status));
            while(string.valueof(statusResultMac.status)!='SUCCESS'){
                system.debug('keep running babe');
                statusResultMac =  csordtelcoa.API_V1.pollOpportunitySubscriptionsResult(macOpportunityId);
            
            }
      boolean checkMACDisForSolution = false;
      for(cscfga__Product_Configuration__c macPC: macPCList){
          for(cscfga__Attribute__c attrbute: macPC.cscfga__Attributes__r){
              system.debug('check attribute value for main===='+attrbute.cscfga__Value__c);
              if(attrbute.cscfga__Value__c=='Yes'){
                  checkMACDisForSolution = true;
                  break;
              }
          }
      }
      if(statusResultMac != null){
        if(checkMACDisForSolution == true && string.valueof(statusResultMac.status)!='SUCCESS'){
            system.debug('yes it was a success');
            cssmgnt.API_1.processMACDBasket(macbasketId, 'createMACOpportunityFromSubscriptions');
        }
      }
      */ //AB: post upgrade changes end
    List<Id> filteredProdConfigIdList=deleteRemovedProductConfigurations(clonedIds);   
    updateProductConfigurationOrderType(filteredProdConfigIdList);
    //updateProductConfigurationOrderType(clonedIds);
    deleteCustomerRequestedDatesConfigurations(clonedIds);
    updateReadOnlyForMACandMLE(clonedIds);
  }
 
 /*******************************************************************
  Name: deleteRemovedProductConfigurations
  Parameters: List<Id> clonedIds
  Return Type: List
  Description: Method for removing MACD productconfiguration for the services which are disconnected status
  *******************************************************************/
 
 public List <Id> deleteRemovedProductConfigurations(List<Id> clonedIds)
  {
    Set<Id> cloneIdset = new Set<Id>();
    cloneIdset.addAll(clonedIds);
    Set<Id> removeList = new Set<Id>();
    List<Id> updatedClonedIds = new List<Id>();
    
    Map<Id,cscfga__Product_Configuration__c> disconnectedList = new Map<ID, cscfga__Product_Configuration__c>([select Id,Name,csordtelcoa__Replaced_Service__c from cscfga__Product_Configuration__c where Id In :clonedIds and csordtelcoa__Replaced_Service__c!=null and csordtelcoa__Replaced_Service__r.csord__Status__c= 'Disconnected']);
    removeList = disconnectedList.keySet();
    
    cloneIdset.removeAll(removeList);
    
    updatedClonedIds.addAll(cloneIdset); 
    
    if(!disconnectedList.isEmpty())
    {
    delete  disconnectedList.values();
    }
    return updatedClonedIds;
    
 }
     
      
  /********************************************************************
  Name: updateOrderType
  Parameters: Map<Id,cscfga__Product_Configuration__c> PCIdRecordMap
  Return Type: void
  Description: Method to update OrderType field of the 
  product configuration record
  *******************************************************************/
  public void updateOrderType(Map<Id,cscfga__Product_Configuration__c> PCIdRecordMap){

    Set<String> attrValue = new Set<String>();
    List<Id> attrList = new List<Id>();
    List<cscfga__Attribute__c> attrFinalList = new List<cscfga__Attribute__c>();
    Map<Id,Id> replacedPCMap = new Map<Id,Id>();
    List<cscfga__Product_Configuration__c> productConfigList = new List<cscfga__Product_Configuration__c>();
    if(PCIdRecordMap != null && !PCIdRecordMap.isEmpty()){
      for(cscfga__Product_Configuration__c productconfigRecord : PCIdRecordMap.values()){
        productconfigRecord.type__c = 'Modify';
        productConfigList.add(productconfigRecord);
      }
    } 
    System.debug('productConfigList----> ' + productConfigList);
    if(productConfigList != null && !productConfigList.isEmpty())
      update productConfigList;
  }

  /*
  Set type__c for cloned Product Configuration to Replaced Subscription csordtelcoa__Change_Type__c value
  */
  public void updateProductConfigurationOrderType( List<Id> productConfigurationIdList ){
    List<cscfga__Product_Configuration__c> productConfigurationList = new List<cscfga__Product_Configuration__c>();

    productConfigurationList =  [
      SELECT Id, type__c, csordtelcoa__Replaced_Subscription__r.csordtelcoa__Change_Type__c
      FROM cscfga__Product_Configuration__c
      WHERE Id = :productConfigurationIdList
    ];

    for (cscfga__Product_Configuration__c productConfiguration : productConfigurationList){
      productConfiguration.type__c = productConfiguration.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Change_Type__c;
    }

    update productConfigurationList;
  }
  // delete CRD configs
  public void deleteCustomerRequestedDatesConfigurations(List<Id> productConfigurationIdList)
  {
    Integer configCount = productConfigurationIdList.size();
    String crdLabel = 'Customer Requested Dates';
    system.debug('Configurations in observer'+configCount);

    List<cscfga__Product_Configuration__c> crdPClist = new List<cscfga__Product_Configuration__c>();
    
    crdPClist=[SELECT id,name 
              FROM cscfga__Product_Configuration__c 
              WHERE cscfga__Product_Definition__r.Name=:crdLabel
              AND csoe__Commercial_Configuration__c IN :productConfigurationIdList];

    if(!crdPClist.isEmpty()&&crdPClist!=null){
        delete crdPClist;
    }
    else {
        crdPClist.clear();
        system.debug('No configurations to delete');
    }
  }
  
  // EDGE-80901 fix for MAC and MLE, setting specific attribute read-only to false
   public void updateReadOnlyForMACandMLE(List<Id> configIds) {
        if (configIds != null) {
            List<cscfga__Attribute__c> attrForUpdate = [
                SELECT Id, 
                    Name, 
                    cscfga__Is_Read_Only__c, 
                    cscfga__Product_Configuration__c 
                    FROM cscfga__Attribute__c 
                WHERE Name = 'MESSAGEBANK' 
                    AND cscfga__Product_Configuration__c IN :configIds];
            for (cscfga__Attribute__c attr : attrForUpdate) {
                attr.cscfga__Is_Read_Only__c = false;
            }
            update attrForUpdate;
        }
    }
}