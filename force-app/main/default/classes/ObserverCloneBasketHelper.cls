global with sharing class ObserverCloneBasketHelper {
  global static void CreateStiteAndaddresses(ID pcrID,String CIDN, String Enterprise_Id)
  { 
    string OptionalJson=null;
    String adborId=null;
    Map<Id,ID> PCR_Account= new Map<Id,ID>();
    for(csbb__Product_Configuration_Request__c pcr:[select id,csbb__Optionals__c,csbb__Product_Configuration__c,csbb__Product_Basket__r.csbb__Account__r.CIDN__c from csbb__Product_Configuration_Request__c where id =:pcrID]){
        if(pcr.csbb__Optionals__c != null){
            if(OptionalJson == '' || OptionalJson == null ){OptionalJson = pcr.csbb__Optionals__c ;}
            else{OptionalJson = OptionalJson + ',' +pcr.csbb__Optionals__c ;}
        }   
    }
    OptionalJson = '['+OptionalJson+']';
    system.debug('@@pcr OptionalJson@@'+OptionalJson);
    //PARSE THE OPTIONALS FROM PCR AND FETCH ADBORID
    List<Optional_PCR> optionalLs = (List<Optional_PCR>)System.JSON.deserialize(OptionalJson , List<Optional_PCR>.class);
    List<cscrm__Site__c> SiteToBeInsertedList= new List<cscrm__Site__c>();
    List<String> AdborIdList= new List<String>();
    List<String> CompositeKeyList = new List<String>();
    List<cscrm__Address__c > addressListToBeInserted= new List<cscrm__Address__c>(); 
	system.debug('@@optionalLs@@'+optionalLs);
    for(Optional_PCR op: optionalLs){
        if(op.HiddenParam1 != null){
            AdborIdList.add(op.HiddenParam1);
            CompositeKeyList.add(op.composite_key_c);
        }
    }
    Map<String,cscrm__Site__c> aboridAlreadypresent=new  Map<String,cscrm__Site__c>();
    Map<String,cscrm__Site__c> compKeyAlreadypresent=new Map<String,cscrm__Site__c>();
    for(cscrm__Site__c site:[select id,AdborID__c, Composite_Key__c from cscrm__Site__c where Composite_Key__c IN:CompositeKeyList]){
        aboridAlreadypresent.put(site.AdborID__c,site);
        compKeyAlreadypresent.put(site.Composite_Key__c,site);
    }
    ReplicatorGetSiteDataObject sitesTobeInserted= new ReplicatorGetSiteDataObject();
    List<ReplicatorGetSiteDataObject.SiteDTO> addressToBeInsertedList= new List<ReplicatorGetSiteDataObject.SiteDTO>();
    List<String> AdborIdListTobeinserted= new List<String>();
    for(Optional_PCR op: optionalLs){
        ReplicatorGetSiteDataObject.SiteDTO addressToBeInserted=new ReplicatorGetSiteDataObject.SiteDTO();
        if(op.HiddenParam1 != null){
            if(!aboridAlreadypresent.containskey(op.HiddenParam1)){
                addressToBeInserted.adbor_id=op.HiddenParam1;
                AdborIdListTobeinserted.add(op.HiddenParam1);
                addressToBeInserted.Site_Address_Status=op.status_c;
                addressToBeInserted.Street_Name=op.cscrm_installation_address_r_cscrm_street_name_c   ;
                addressToBeInserted.loc_name=op.cscrm_installation_address_r_locality_c ;
                addressToBeInserted.State=op.cscrm_installation_address_r_cscrm_state_province_c ;
                addressToBeInserted.ADBoR_Postcode=op.cscrm_installation_address_r_cscrm_zip_postal_code_c ;
                addressToBeInserted.Address_No_To=op.cscrm_installation_address_r_street_number_to_c;
                addressToBeInserted.Address_No_From=op.cscrm_installation_addressr_street_number_from_calc_c;
                addressToBeInserted.Street_Type=op.cscrm_installation_address_r_cscrm_street_type_c;
                addressToBeInserted.Suffix_From=op.cscrm_installation_address_r_streetnumberstartsuffix_c;
                addressToBeInserted.Suffix_To=op.cscrm_installation_address_r_streetnumberendsuffix_c;
                addressToBeInserted.Sub2_Descriptor_1=op.cscrm_installation_address_r_sub_address2_number_c;
                addressToBeInserted.Sub2_CodeSet_Abbrev=op.cscrm_installation_address_r_sub_address2_type_c;
                addressToBeInserted.Sub1_Descriptor_1=op.cscrm_installation_address_r_sub_address1_number_c;
                addressToBeInserted.Sub1_CodeSet_Abbrev=op.cscrm_installation_address_r_sub_address1_type_c;
                addressToBeInserted.Sub3_Descriptor_1=op.cscrm_installation_address_r_sub_address_3_number_c;
                addressToBeInserted.Sub3_CodeSet_Abbrev=op.cscrm_installation_address_r_sub_address_3_type_c;
                addressToBeInserted.Sub4_Descriptor_1=op.cscrm_installation_address_r_sub_address_4_number_c;
                addressToBeInserted.Sub4_CodeSet_Abbrev=op.cscrm_installation_address_r_sub_address_4_type_c;
                addressToBeInserted.rfs_date=op.ready_for_service_date_c  ;
                addressToBeInserted.disconnection_date=op.disconnection_date_c ;
                addressToBeInserted.in_flight_order=op.in_flight_order_c ;
                addressToBeInserted.serviceability=op.Servicability_c ;
                addressToBeInserted.disconnect_wave=op.Disconnect_wave_c ;
                addressToBeInserted.site_composition=op.Site_Composition_c ;
                addressToBeInserted.order_stability_date=op.Order_Stability_Date_c ;
                addressToBeInserted.service_class=op.Service_Class_c ;
                addressToBeInserted.Site_Migration_Flag=op.Site_Migration_Flag_c;
				addressToBeInserted.Site_Nick_Name=op.Site_Nick_Name;
                addressToBeInsertedList.add(addressToBeInserted);
            }
            
        }
    }
    sitesTobeInserted.CIDN=CIDN;
    sitesTobeInserted.Enterprise_Id=Enterprise_Id;
    if(addressToBeInsertedList.size()>0){
        sitesTobeInserted.Site=addressToBeInsertedList;
    }
    if(sitesTobeInserted!=null){
        // start EDGE-72118  Validate ADBOR id provided by Replicator with EASTsystem 
       // 					prior to using that site information in CPQ journey.
       
        AddressAndSiteObjectUtility.upsertEastAddressAndSite(AdborIdListTobeinserted,sitesTobeInserted);
        //AddressAndSiteObjectUtility.upsertReplicatorAddressAndSiteList(AdborIdListTobeinserted,sitesTobeInserted);
       /* List<cscrm__Site__c> siteList = [select id from cscrm__Site__c where cscrm__Installation_Address__r.Address_ID__c IN: AdborIdListTobeinserted AND  cscrm__Account__r.CIDN__c =: CIDN ];
        system.debug('PCRTriggerHandler - siteList to updatewithLegacy ' + siteList);
        for(cscrm__Site__c site : siteList){
            site.Legacy__c=true;
        }
        update siteList;
		*/
       
     //End  EDGE-72118 
       
    }

    System.debug('sitesTobeInserted<><>'+sitesTobeInserted);
  }
  global static void UpdateBasketStage(cscfga__Product_Configuration__c pc)
  {
    cscfga__Product_Basket__c ProductBasket=[select id,csordtelcoa__Basket_Stage__c,IsCloned__c from cscfga__Product_Basket__c where id In (select cscfga__Product_Basket__c from cscfga__Product_Configuration__c where id=:pc.id) and IsCloned__c=true and csordtelcoa__Basket_Stage__c!='Commercial Configuration'];
    system.debug('Basket@@@'+ProductBasket);
    ProductBasket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
    update ProductBasket;
  }
   global class Optional_PCR {        
         global string hiddenParam1  {get;set;}
         global string cscrm_installation_address_details_c  {get;set;}
         global string cscrm_account_c  {get;set;}
         global string cscrm_installation_address_c  {get;set;}
         global string adborid_c  {get;set;}
         global string display_name_c  {get;set;}
         global string disconnection_date_c  {get;set;}
         global string in_flight_order_c  {get;set;}
         global string servicability_c  {get;set;}
         global string disconnect_wave_c  {get;set;}
         global string site_composition_c  {get;set;}
         global string order_stability_date_c  {get;set;}
         global string service_class_c  {get;set;}
         global string site_migration_flag_c  {get;set;}
         global string composite_key_c  {get;set;}
         global string cscrm_installation_address_r_street_number_to_c  {get;set;}
         global string cscrm_installation_addressr_street_number_from_calc_c  {get;set;}
         global string cscrm_installation_address_r_cscrm_street_type_c  {get;set;}
         global string cscrm_installation_address_r_streetnumberstartsuffix_c  {get;set;}
         global string cscrm_installation_address_r_streetnumberendsuffix_c  {get;set;}
         global string cscrm_installation_address_r_sub_address2_number_c  {get;set;}
         global string cscrm_installation_address_r_sub_address2_type_c  {get;set;}
         global string cscrm_installation_address_r_sub_address1_number_c  {get;set;}
         global string cscrm_installation_address_r_sub_address1_type_c  {get;set;}
         global string cscrm_installation_address_r_sub_address_3_number_c  {get;set;}
         global string cscrm_installation_address_r_sub_address_3_type_c  {get;set;}
         global string cscrm_installation_address_r_sub_address_4_number_c  {get;set;}
         global string cscrm_installation_address_r_sub_address_4_type_c  {get;set;}
         global string cscrm_installation_address_r_cscrm_street_name_c  {get;set;}
         global string cscrm_installation_address_r_locality_c  {get;set;}
         global string cscrm_installation_address_r_cscrm_state_province_c  {get;set;}
         global string cscrm_installation_address_r_cscrm_zip_postal_code_c  {get;set;}
         global string status_c {get;set;}
         global string address_status_c {get;set;}
         global string ready_for_service_date_c {get;set;}
		 global string Site_Nick_Name {get; set;}
    }
}