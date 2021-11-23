/*********************************************************************************************************************************
 *Class Name      :   CS_TypeFromPriceItem

Test Class : CS_TypeFromPriceItemTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Rohit  Tripathi       20/7/2019       EDGE-101221->User Fixed seat status is getting changed to incomplete when the basket stage is Contract Accepted for PRM user
2.             shubhi Vijay         20/7/2019       EDGE-96230 Getting error when clicked on Fixed seat drop down
3.            Venkata Ramanan       29/07/2019      Resolved Null pointer error when clicked on Fixed Seat drop down
 *********************************************************************************************************************************
*/global with sharing class CS_TypeFromPriceItem extends cscfga.ALookupSearch {

    public override String getRequiredAttributes(){
        return '["ListOfSelectedUser1","Prod_Cnf_Id", "OfferId", "OfferName"]';
    }
    
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
        Integer pageOffset, Integer pageLimit){
        //EDGE-22590 Custom Lookup for TypeUser attribute in User PD to return only relevant searchValue based on User Type already added. 
        //String searchValue = ApexPages.currentPage().getParameters().get('id');
        System.debug('pageLimit in doLookupSearch : ' + pageLimit);
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT = (pageLimit==null)?25:pageLimit + 1;
        System.debug('SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT in doLookupSearch : ' + SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT);
system.debug('searchfields size'+searchFields.size());
for(String a: searchFields.keyset()){
system.debug('map'+searchFields.get(a));
}
        //Get filter attributes from search fields
        String searchValue = getSearchValue(searchFields);
        List<String> lstSelectedUsr = getSelectedUsersList(searchFields);
        cscfga__Product_Configuration__c config = getExistingConfiguration(searchFields);
        system.debug('config'+config);
        String existingOfferSpecId = (config == null)?'':config.cscfga__originating_offer__r.Offer_Spec_Id__c;
        String existingUserProdName = (config == null)?'':config.Name;
        system.debug('existingOfferSpecId'+existingOfferSpecId);
        String offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
        system.debug(LoggingLevel.INFO, 'CS_TypeFromPriceItem.offerId = ' + offerId);

        String offerName = searchFields.get('OfferName') != null ? searchFields.get('OfferName') : '';
        system.debug(LoggingLevel.INFO, 'CS_TypeFromPriceItem.offerId = ' + offerName);
        
        List<cspmb__Price_Item__c> priceList = new List<cspmb__Price_Item__c>();
/*
        if(existingOfferSpecId == '' && String.isblank(existingOfferSpecId))
        {
          System.debug('Query 1');
            priceList = [SELECT 
                          billInAdvance__c, billingSpecId__c, billing_description__c, ChargeFrequency__c, chargetype__c, Check_todays_date__c, cspmb__one_off_charge__c, cspmb__Price_Item_Code__c, cspmb__recurring_charge__c, currency__c, Frequency__c, id, name, Offer_Id__c, Package_Name__c, prorate__c, taxTreatment__c, Type__c, Unit_Of_Measure__c, Zone__c
                        from 
                          cspmb__Price_Item__c 
                        where 
                          //cspmb__Is_Active__c = TRUE AND //EDGE-96230
                          cspmb__Product_Definition_Name__c ='User' AND 
                          //Package_Name__c =:offerName AND 
                          cspmb__Effective_End_Date__c >= today AND 
                          cspmb__Effective_Start_Date__c <= today AND 
                          //Offer_Id__c=:existingOfferSpecId AND 
                          Type__c like :searchValue 
                          AND Type__c != 'Fixed Seat' 
                           AND Type__c != null
                        LIMIT 
                          :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT ];
        }
        else{
          System.debug('Query 2');
           priceList = [SELECT 
                          billInAdvance__c, billingSpecId__c, billing_description__c, ChargeFrequency__c, chargetype__c, Check_todays_date__c, cspmb__one_off_charge__c, cspmb__Price_Item_Code__c, cspmb__recurring_charge__c, currency__c, Frequency__c, id, name, Offer_Id__c, Package_Name__c, prorate__c, taxTreatment__c, Type__c, Unit_Of_Measure__c, Zone__c
                        from 
                          cspmb__Price_Item__c 
                        where 
                          //cspmb__Is_Active__c = TRUE AND //EDGE-96230
                          cspmb__Product_Definition_Name__c ='User' AND 
                          Package_Name__c =:offerName AND 
                          //Type__c != 'Fixed Seat' AND
                          Offer_Id__c=:existingOfferSpecId AND
                          cspmb__Effective_End_Date__c >= today AND 
                          cspmb__Effective_Start_Date__c <= today  AND 
                          Type__c like :searchValue 
                           AND Type__c != null
                        LIMIT 
                          :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT ];
        }
        System.debug('Price List = ' + priceList);
        *///Venkat starts
        //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
        String Query = 'SELECT billInAdvance__c, billingSpecId__c, billing_description__c, ChargeFrequency__c, chargetype__c, Check_todays_date__c, cspmb__one_off_charge__c, cspmb__Price_Item_Code__c, Commercial_Product_Code__c,cspmb__recurring_charge__c, currency__c, Frequency__c, id, name, Offer_Id__c, Package_Name__c, prorate__c, taxTreatment__c, Type__c, Unit_Of_Measure__c, Zone__c'; 
        Query+= ' from cspmb__Price_Item__c';
        Query+= ' where cspmb__Product_Definition_Name__c =\'User\' AND Package_Name__c =: OfferName and Type__c !=null AND cspmb__Effective_End_Date__c >= today AND cspmb__Effective_Start_Date__c <= today';//cspmb__Is_Active__c = TRUE AND //EDGE-96230
        if(existingOfferSpecId != ''&& !String.isBlank(existingOfferSpecId) && !String.isBlank(searchValue)&& searchValue != '')//Changes by Venkat
        {
          System.debug('Query 1');
          Query += ' and Offer_Id__c=:existingOfferSpecId AND Type__c like :searchValue ';
          }
          else if(existingOfferSpecId != ''&& !String.isBlank(existingOfferSpecId)){
          System.debug('Query 2');
          Query += ' and Offer_Id__c=:existingOfferSpecId ';
          }
          else if((existingOfferSpecId != '' || !String.isBlank(existingOfferSpecId)) && (!String.isBlank(searchValue) && searchValue !='')){
          System.debug('Query 3');
          Query += ' and Type__c like :searchValue ';
          }
          else{
          system.debug('Query 4');
          if(!lstSelectedUsr.isEmpty())
          Query += ' and Type__c != \'Fixed Seat\' ';
          }
          Query += ' LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT ';
          priceList = Database.query(Query);
          //Venkat ends*/
        System.debug('Price List -Venkat = ' + priceList);
        //Additional logic to restrict the list of available price items & keep only unique type values
        Map<String,cspmb__Price_Item__c> typeMap = new  Map<String,cspmb__Price_Item__c>();

          for(cspmb__Price_Item__c item : priceList)
          {
          system.debug('item'+item);
           system.debug('canAdd'+canAdd(existingUserProdName,lstSelectedUsr, item));
            if (canAdd(existingUserProdName,lstSelectedUsr, item))
            {
              typeMap.put(item.Type__c, item);
            }
            system.debug('typemap'+typeMap);
          }
         // return (typeMap.size()>0)?typeMap.Values():null;
          return typeMap.Values();
          
    }
    public boolean canAdd(String configName, List<String> lstSelectedUsr, cspmb__Price_Item__c item)
    {
      if (lstSelectedUsr==null || lstSelectedUsr.size() == 0)
      {
        return true;
      }
      else if (!lstSelectedUsr.contains(item.Type__c))
      {
        if (configName == '') return true;
        if (configName.contains('Fax Line') && item.Type__c == 'Fixed Seat') return true;//Changes by Venkat
        if (configName.contains('User') && item.Type__c == 'User') return true;
        if (configName.contains('Fixed Seat') && item.Type__c.startsWith('Fax Line')) return true; //Changes by Venkat
      }
      return false;
    } 

  public String getSearchValue(Map<String,String> searchFields)
  {
    //User-specified search terms (type ahead)
    System.debug('SearchValue in getSearchValue : ' + searchFields.get('searchValue'));
    return (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != null && !String.isBlank(searchFields.get('searchValue')))?'%'+searchFields.get('searchValue')+'%':'';//Changes by Venkat
  }

  public List<String> getSelectedUsersList(Map<String, String> searchFields)
  {
    //List of selected user types, e.g. "Fixed,Fax" (read from value stored on site)
    //converted to Apex List<String>, i.e. ["Fixed", "Fax"]
    String selectedUsr = '';
    List<String> lstSelectedUsr = new List<String>();
    if (searchFields.containsKey('ListOfSelectedUser1'))
    {
      selectedUsr = searchFields.get('ListOfSelectedUser1').removeEnd(',undefined');
        
      if(String.isNotBlank(selectedUsr))
      {
        lstSelectedUsr = selectedUsr.split(',');
      }
    }
    return lstSelectedUsr;
  }

  public cscfga__Product_Configuration__c getExistingConfiguration(Map<String, String> searchFields)
  {
    //Get configuration id of existing User config (for change order scenarios)
    List<cscfga__Product_Configuration__c> configList=new List<cscfga__Product_Configuration__c>();
    cscfga__Product_Configuration__c config = null;
    if(searchFields.containsKey('Prod_Cnf_Id'))
    {
      configList =[SELECT Name,cscfga__Configuration_Status__c,cscfga__originating_offer__r.Offer_Spec_Id__c from cscfga__Product_Configuration__c where Id =: searchFields.get('Prod_Cnf_Id')];
      if (!configList.isEmpty() && configList.size()>0)
      {
        config = configList[0];
      }
    }
    return config;
  }
}