/* Class to generate quote-record and form Conga-URL
*  Revisions : 
*   Ritika Jaiswal : 20/08/2019 : EDGE - 98246 : Changes related to CMP
*   Ritika Jaiswal : 30/08/2019 : EDGE-110648,109988 Defect fixing for CMP modify 
* Yash: Updating Tenancy Solution in Product Family as per Colombo's change | No change in flow | EDGE-134876
*   Murlidhar K : 15/11/2019 : DPG - 598
* Changes for IOT Services 
* Aniket S: 12/02/2020 EDGE-127780 : Quote changes for TID cancellation
* Vishal Arbune : 20/03/2020 EDGE-141462 : EDGE-123791_New services is not coming in Order Summary section for Mac Order of CMP and NGUC
* Sunil - 29/08/2020 Prod Specefication code refactoring - EDGE-165831
* V Ravi Shankar : 28-Oct-2020 173365, EDGE-181453 changes
*/
public with sharing class GenerateQuoteHelper {
    @TestVisible private static List<BasketSnapshot__x> mockedRequests = new List<BasketSnapshot__x>();
    @TestVisible private static cscfga__Product_Basket__c productBasket;
    //Static List<String> parentPCs = new list<String>{'Unified Communication','IP Site','MDM Tenancy','Device Outright Purchase Solution'};
                //EDGE-165831 - get all product specefication codes
   public static List<String> prodSpecCodeQHelper;
    public static List<String> CancelSpecCodeQHelper;
                //EDGE-165831 - End
    //EDGE-117738(Created static list & Added ngUC)
    //DPG-598 change - Added IOT specific products in below list
    //Added Enterprise Mobility for EDGE-121558 - & EDGE-117738(Created static list & Added ngUC)
    //EDGE-134876
    //EDGE-137134 Changed name of product to Managed Service Solution To Managed Services

    //Static List<String> productFamilies = new list<String>{'IOT Subscription','Mobile Subscription','Mobility','Tenancy','Telstra Collaboration Solution','Telstra Collaboration Professional Servi','Professional Services-MDM Config','Device','Enterprise Mobility','Managed Services','Next Generation Voice','Internet Site','Tenancy Solution','Internet Solution','Business Calling','Unified Communication Device','Accessory','Next Generation Mobile Device','Mobile Device Care','Enterprise Mobility Plan'}; //EDGE-80783,EDGE-98336 >> +EDGE-132608 AND EDGE-144732 Added Business Calling //EDGE-148728 //EDGE-148722 //EDGE-165326
    //EDGE-142411
    //Static List<String> cancelProductFamilies = new list<String>{'Telstra Collaboration Solution','Enterprise Mobility','Device','Mobile Subscription','Unified Communication Device','Next Generation Voice','Accessory','Business Calling','Next Generation Mobile Device','Enterprise Mobility Plan'}; //EDGE-144732 - Added Business Calling //EDGE-148722//EDGE-155059 & EDGE-162542 Added Enterprise Mobility Plan
   public static String createQuote(string templateid,string productBasketID){
        system.debug('templateid' + templateid + '@productBasketID@ ' + productBasketID);
        //EDGE-165831 - Start
                                AllCQEnvironmentVariable cqVariables = new AllCQEnvironmentVariable();
        CancelSpecCodeQHelper = new List<String>(AllCQEnvironmentVariable.getValueAsList('cancelProductFamilies'));
        prodSpecCodeQHelper = new List<String>(AllCQEnvironmentVariable.getValueAsList('ProductSpeccificationCode'));
        system.debug('prodSpecCodeQHelper-->'+prodSpecCodeQHelper);

        if(productBasketID == '' || productBasketID == null)//EDGE-155059 & EDGE-162542
            return null;
        cscfga__Product_Basket__c productBasket = fetchProductBasket(productBasketID); 
        System.debug(' productBasket '+productBasket);
        if(productBasket == null  ) {
            System.debug('Product basket not found.');
            return null;
        }       
        String queryParams='&QueryId=';
        String delimiter=',';        
        String queryCongaStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Quote_Query__mdt')) + '\n ' +
            ' FROM Quote_Query__mdt \n limit 1 ';
        List<Quote_Query__mdt> congaQueryNamesList = Database.query(queryCongaStr); 
        if(congaQueryNamesList == null || congaQueryNamesList.isEmpty() || templateid == null){
            System.debug('No conga template settings found.');
            return null;
        } 
        List<String> nameOfTemplates = congaQueryNamesList.get(0).QueryNames__c.split(delimiter);       
        System.debug('name of queries:'+nameOfTemplates);
        Map<String,String> mapOfTemplates = CustomButtonOpportunitySync.getTemplateId(nameOfTemplates,'query');
        for(String nameOfTemplate :nameOfTemplates){
            if(nameOfTemplate.contains('Opportunity'))
                queryParams += '['+nameOfTemplate+']'+mapOfTemplates.get(nameOfTemplate)+'?'+congaQueryNamesList.get(0).Basket_Filter_value__c+'='+productBasket.cscfga__Opportunity__c+',';//EDGE-171311
            else
                queryParams += '['+nameOfTemplate+']'+mapOfTemplates.get(nameOfTemplate)+'?'+congaQueryNamesList.get(0).Basket_Filter_value__c+'='+productBasketID+',';         
        }
        queryParams=queryParams.substringBeforeLast(delimiter);
        /*
        List<BasketSnapshot__x> basketSnapshotList=fetchBasketSnapshot(productBasketID);
        if(basketSnapshotList == null || basketSnapshotList.isEmpty()) {
            System.debug('No Basket Snapshots found');
            return null;
        }
        System.debug('BasketSnap query result:'+basketSnapshotList+' result size:'+basketSnapshotList.size());   */     

        return insertQuote(productBasket,queryParams,templateid);
    }
    private static String insertQuote(cscfga__Product_Basket__c productBasket,String queryParams,String templateid)
    {
        String congaUrl= '&Id=';
        populateGSTPricesinPC(productBasket.id);
        Integer showNewServices=0;
        Integer showExistingServices=0;
        Integer showTransitionServices=0;//EDGE-132157
        Integer showChangesToExisting=0; //EDGE-143435 && EDGE-158055
        String CMPConfig= System.Label.ProductSpecificationMobile;//EDGE-117740
        String CWPConfig= System.Label.Product_Specification_for_Cwp;
        String productSpecNgUc= Label.ProductSpecificationNgUc; // EDGE-117738//EDGE-217484
        //EDGE - 117738 Start 
        Integer showCancelServices=0;
        String pasTempId = ''; //EDGE-181453
        //EDGE - 117738 End
        try{
            //vimal: commenting PCR query as we will not be using PCR
            /*for(csbb__Product_Configuration_Request__c prrecord:[select id,csbb__Product_Configuration__r.name,csbb__Product_Configuration__r.Type__c,
                                                                 csbb__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName, csbb__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c 
                                                                 from csbb__Product_Configuration_Request__c  
                                                                 where csbb__Product_Basket__c=:productBasket.id and csbb__Product_Configuration__r.name='IP Site']){                
                if(prrecord.csbb__Product_Configuration__r.Type__c=='New' && prrecord.csbb__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName!='MAC'){
                    showNewServices=showNewServices+1;
                }
                if((prrecord.csbb__Product_Configuration__r.Type__c=='Modify' || prrecord.csbb__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c!=null) && prrecord.csbb__Product_Configuration__r.Type__c!='Cancel' ){
                    showExistingServices=showExistingServices+1;
                    system.debug('loopshowExistingServices'+showExistingServices);
                }
            }*/
        //Changes start : EDGE - 98246  
            //boolean tcPresent = ProductBasketUtil.doesBasketHaveOffer(productBasket, 'Telstra Collaboration Solution');
            //String pcName = tcPresent ? 'Unified Communication' : 'IP Site';
            //system.debug('insertquote: tcPresent = ' + tcPresent+'...pcName....'+pcName);
            //using PC query instead, TBD - refactor code properly
            String developerName='';//EDGE-141462
           //EDGE-173365 --- Start
            List<Legacy_Service__c> legacySrvLst = [SELECT Id FROM Legacy_Service__c WHERE Product_Basket__c=:productBasket.id AND Product_Type__c='Enterprise Mobility' AND Select__c = TRUE];
            if(legacySrvLst != null && legacySrvLst.size()>0){
                showExistingServices=showExistingServices+1;
                List<APXTConga4__Conga_Template__c> templateList = [SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Proposed affected services' ORDER BY APXTConga4__Name__c Limit 1];
                if(templateList != null && templateList.size() > 0){
                    pasTempId = templateList[0].Id;//EDGE-181453
                    pasTempId = pasTempId.substring(0,pasTempId.length() - 3);
                }
            }
            //EDGE-173365 --- End            
            //for(cscfga__Product_Configuration__c pcrecord:[select id, name, Type__c,cscfga__Product_Family__c, cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName, csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,(select id,name from attachments where name like '%Transition%')from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:productBasket.id and (name IN :parentPCs or cscfga__Product_Family__c IN :productFamilies)]){
                                //EDGE-165831 - Changes in filter condition
            for(cscfga__Product_Configuration__c pcrecord:[select id, name, Type__c,cscfga__Product_Family__c, cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName, csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,(select id,name from attachments where name like '%Transition%')
                                                                 from cscfga__Product_Configuration__c
                                                                 where cscfga__Product_Basket__c=:productBasket.id and cscfga__Product_Definition__r.product_Specification__c IN :prodSpecCodeQHelper]){
                                // EDGE-162025
        System.debug('***record'+pcrecord);  
        //EDGE-141462 : Fetch developer name : MAC
        if(String.isNotBlank(pcrecord.cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName)){
             developerName = pcrecord.cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName;           
        }        
        //Changes end : EDGE - 98246    
        if(pcrecord.Type__c=='New' && pcrecord.csordtelcoa__Replaced_Product_Configuration__c==null){
                    showNewServices=showNewServices+1;
                    system.debug('showNewServices is greater than 0');
                }
        //EDGE-127780 Start                                                             
        if(pcrecord.Type__c==null && pcrecord.csordtelcoa__Replaced_Product_Configuration__c!=null && pcrecord.name == 'Internet Solution'){
                    showExistingServices=showExistingServices+1;
                    system.debug('TID Existing');
                }  
        //EDGE-127780 End                                                             
                if((pcrecord.Type__c=='Modify' && pcrecord.csordtelcoa__Replaced_Product_Configuration__c!=null)){
                    showExistingServices=showExistingServices+1;
                    showChangesToExisting=showChangesToExisting+1; //EDGE-143435 && EDGE-158055
                    system.debug('loopshowExistingServices'+showExistingServices);          
                    system.debug('loopshowChangesToExisting'+showChangesToExisting);          
                }
        //EDGE-141270 AND EDGE-142411 Start
        if((pcrecord.Type__c=='Cancel' && pcrecord.csordtelcoa__Replaced_Product_Configuration__c!=null && CancelSpecCodeQHelper.contains(pcrecord.cscfga__Product_Definition__r.product_Specification__c))){
                    showExistingServices=showExistingServices+1;
                    system.debug('loopshowExistingServicesCancel'+showExistingServices);          
                }
        //EDGE-141270 AND EDGE-142411 End
        //EDGE-141462 : Check showNewServices values for the MAC basket if available
        if((pcrecord.Type__c=='New' && developerName == 'MAC')){
                    showNewServices=showNewServices+1;
                    system.debug('showNewServices for MAC'+showNewServices);          
        }              
                // EDGE -117740 & EDGE-117738(Added condition for ngUC)// EDGE-154990 Removed condition for ngUC as Transition is not applicable for NGUC goving forward.
                else if(pcrecord.Type__c=='New' && (pcrecord.cscfga__Product_Definition__r.product_Specification__c == CMPConfig || pcrecord.cscfga__Product_Definition__r.product_Specification__c == CWPConfig || pcrecord.cscfga__Product_Definition__r.product_Specification__c ==productSpecNgUc)){//Added nguc changes for EDGE-217484
                            for(attachment attachment:pcrecord.attachments){
                                showExistingServices=showExistingServices+1;
                                showTransitionServices=showTransitionServices+1;//EDGE-132157
               }
                }
              // EDGE -117740 Start
            }
            Quote quote;
            String quotePresent='SELECT '+ String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Quote')) +' FROM Quote WHERE Product_Basket__c=\''+ String.escapeSingleQuotes(productBasket.Id) +'\'';
            List <Quote> listquote = Database.query(quotePresent);
            System.debug('GenerateQuoteHelper : listquote ..'+listquote );                   
            if(listquote !=null && !listquote.isEmpty()) //to check if quote already present
            {
                System.debug('Quote exists, updating it');
                quote = listquote[0]; 
            }
            else
            {
                Boolean ExistingContract=GenerateContract.isBSALinkedToAccount(productBasket);             
                Quote quo = new Quote();
                quo.Name = productBasket.name;
                quo.Product_Basket__c = productBasket.Id;
                quo.opportunityid=productBasket.cscfga__Opportunity__c;
                quo.ExpirationDate =system.today()+30;
                quo.Conga_Status__c ='InProgress' ;
                //  quo.ContactId = fetchPrimaryContactQuote(productBasket); // EDGE-52268 
                quo.ContactId = fetchQuoteRecipient(productBasket);
                quo.Conga_Request_Time__c = System.now();
                if(productBasket.cscfga__Opportunity__r.type == 'Disconnect'){
                    quo.Existing_Services_Show__c=false; 
          //quo.Transition_Services_Show__c = false;//EDGE-132157
          }
                // Added condition showExistingServices for EDGE-121558
                else if(ExistingContract==true && showExistingServices>0){
                    quo.Existing_Services_Show__c=true;
          //quo.Transition_Services_Show__c =true;//EDGE-132157
                    //EDGE-141462 : Set 'New Services Show' field to true for MAC Basket
                    if(showNewServices>0){
                        quo.New_Services_Show__c=true;
                    }else{
                        quo.New_Services_Show__c=false;
                    }
                }
                else if(showNewServices>0){
                    quo.New_Services_Show__c=true;
                    if(showExistingServices>0){
                        quo.Existing_Services_Show__c=true;
            //quo.Transition_Services_Show__c =true;//EDGE-132157
            }
                }
                else if(showExistingServices>0){
                    quo.Existing_Services_Show__c=true; 
          //quo.Transition_Services_Show__c =true;//EDGE-132157
          }
          //EDGE-143435 && EDGE-158055 START
          if(showChangesToExisting>0){
              quo.Changes_to_Existing__c=true; 
              system.debug('quo.Changes_to_Existing__c@@::' + quo.Changes_to_Existing__c);
          }
          //EDGE-143435 && EDGE-158055 END
                System.debug('Quote'+quo);  
                //EDGE-132157 Start
      if(showTransitionServices>0){
      //quo.Transition_Services_Show__c = false;
      }
                        //system.debug('quo.Transition_Services_Show__c@@::' + quo.Transition_Services_Show__c);
                        system.debug('quo.Existing_Services_Show__c@@::' + quo.Existing_Services_Show__c);
                        //EDGE-132157 End
                insert quo;
                String quoteQuery='SELECT '+ String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Quote')) +' FROM Quote WHERE Id=\'' +quo.Id + '\'';
                quote = Database.query(quoteQuery);
            }
            //congaUrl=congaUrl+ quote.Id +'&TemplateId='+templateId+'&FP0=1'+'&QMode=Attachments';
            if(pasTempId != ''){
                congaUrl=congaUrl+ quote.Id +'&TemplateId='+templateId+','+pasTempId+'&ZipFiles=0'+'&FP0=1'+'&QMode=Attachments';//EDGE-181453
                system.debug('congaURLLL1==='+congaUrl);
            }
            else{
                congaUrl=congaUrl+ quote.Id +'&TemplateId='+templateId+'&FP0=1'+'&QMode=Attachments';
                system.debug('congaURLLL2==='+congaUrl);
            }           
            quote.Conga_URL__c =congaUrl;
            system.debug('congaURLLL3==='+congaUrl);
            if(!Test.isRunningTest()){
          //changes start EDGE-66165
                if(quote.Existing_Services_Show__c){
                    queryParams=queryParams.replace('BSMobilityServices','BSMobilityMAC');
                    queryParams=queryParams.replace('BSMobilityDevicesRC','BSMobilityRCMAC');
                    queryParams=queryParams.replace('BSMobilityDevicesOC','BSMobilityOCMAC');
                }
          //changes end EDGE-66165
                congaUrl=congaUrl+queryParams+ '&OFN=' + EncodingUtil.urlEncode(quote.QuoteNumber, 'UTF-8')+'&AttachmentParentId='+quote.Id;
                system.debug('congaURLLL4==='+congaUrl);
                quote.Conga_URL__c =congaUrl;
                if (quote.Conga_Status__c =='Error'){
                    System.debug('Updating conga status and time:'+quote.Conga_Status__c);
                    quote.Conga_Status__c ='InProgress' ;
                    quote.Conga_Request_Time__c = System.now();   
                }
                upsert quote;
            }
            System.debug('URL:'+quote.Conga_URL__c);
            return quote.Id;
        }
        catch(DmlException e)
        {
            System.debug('Error occured while inserting quote');
            return null;
        }
    }
    /*public static List<BasketSnapshot__x> fetchBasketSnapshot(String basketId) {
        //query BasketSnapshot__x with productBasketID
        if(Test.isRunningTest()) {
            BasketSnapshot__x mockedRequest = new BasketSnapshot__x(
                Once_Off__c='3',
                //Product_Basket__c='a3Q2O0000000lUqUAa',
                Product_Basket__c=basketId,
                Product_Configuration__c='a3T2O0000000xokUAa',
                Product_Module_Name__c='3432',
                Site_Name__c='site name',
                Term__c='0',
                Type__c='2');  mockedRequests.add(mockedRequest);
            return (!mockedRequests.isEmpty()) ? mockedRequests : null;
        }
        String queryBasketSnapshot = 'SELECT '+ String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('BasketSnapshot__x')) +' FROM BasketSnapshot__x WHERE Product_Basket__c=: basketId ';
        return  Database.query(queryBasketSnapshot);  
    } */
    public static cscfga__Product_Basket__c fetchProductBasket(String basketId) {
        String queryProductBasket ='SELECT '+String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cscfga__Product_Basket__c'))+ ' ,cscfga__Opportunity__r.type FROM cscfga__Product_Basket__c WHERE Id =: basketId'; 
        return Database.query(queryProductBasket);
    }
    public static String fetchPrimaryContactQuote(cscfga__Product_Basket__c productBasket) {
        Id contactID = NULL;
        list<OpportunityContactRole> oppContactRole = [SELECT ContactId, Contact.Name,Contact.ID, IsPrimary, Role,Opportunity.name, OpportunityId 
                                                       FROM OpportunityContactRole 
                                                       WHERE OpportunityId =:productBasket.cscfga__Opportunity__c 
                                                       AND IsPrimary = true ORDER BY IsPrimary DESC];
        if(oppContactRole.size() > 0){
            for(OpportunityContactRole OCR : oppContactRole){
                if(OCR.IsPrimary == true){
                    contactID = OCR.Contact.ID; 
                    break;
                }
            }
        }
        if(contactID != null){
            return contactID;   
        }
        else{
            return NULL; 
        }   
    }
    public static void populateGSTPricesinPC(String BasketId){
        List<cscfga__Product_Configuration__c> productConfigurations = [select id,TotalGSTInclusiveTOC__c,TotalGSTInclusiveTRC__c,Unit_of_measurement__c,Serviceability_Location__c,
                                                                        Response_Time__c,Restoration_Time__c,Site_Name__c,Site_Address__c,Rate__c,Quantity_Product_Configuration__c 
                                                                        from cscfga__Product_Configuration__c 
                                                                        where cscfga__Product_Basket__c=:BasketId 
                                                                        and (cscfga__Parent_Configuration__c!=null or Name = 'IP Site' or Commercial_Config__c = 'Yes') 
                                                                        and cscfga__Product_Definition__r.Snapshot_Object__c != null ];        
        Map<id,cscfga__Product_Configuration__c> idtoPC = new Map<id,cscfga__Product_Configuration__c>();
        for(cscfga__Product_Configuration__c pc:productConfigurations){
            idtoPC.put(pc.id, pc);
        }
        List<cscfga__Attribute__c> result = [SELECT name,cscfga__Product_Configuration__c,cscfga__Value__c,cscfga__Product_Configuration__r.cscfga__Parent_Configuration__c,cscfga__Price__c 
                                             FROM cscfga__Attribute__c 
                                             WHERE cscfga__Product_Configuration__c IN :productConfigurations 
                                             and (name like '%UnitOfMeasure%' or name like '%GST%' or name like 'ServiceabilityLocation' or name like 'ResponseTime' 
                                             or name like 'RestorationTime' or name like '%Site Name%' or name like '%Site Address%'  or name like '%UnitPrice%' or name like '%Quantity%') 
                                             order by cscfga__Product_Configuration__c];
        Map<id,List<cscfga__Attribute__c>> AttributesOfPC = new Map<id,List<cscfga__Attribute__c>>();
        for(cscfga__Attribute__c attr:result){
            if(AttributesOfPC.get(attr.cscfga__Product_Configuration__c) == null)
                AttributesOfPC.put(attr.cscfga__Product_Configuration__c,new List<cscfga__Attribute__c>());
            AttributesOfPC.get(attr.cscfga__Product_Configuration__c).add(attr);
        }       
        cscfga__Product_Configuration__c tmp;
        for(id key:AttributesOfPC.keySet()){
            tmp = idtoPC.get(key);           
            tmp.TotalGSTInclusiveTOC__c = 0.00;
            tmp.TotalGSTInclusiveTRC__c = 0.00;           
            for(cscfga__Attribute__c attribute:AttributesOfPC.get(key)){                
                if(attribute.Name.contains('GSTInclusiveTOC') && attribute.cscfga__Value__c!=null){                    
                    tmp.TotalGSTInclusiveTOC__c += decimal.valueOf(attribute.cscfga__Value__c);
                }
                else if(attribute.Name.contains('GSTInclusiveTRC') && attribute.cscfga__Value__c!=null){                    
                    tmp.TotalGSTInclusiveTRC__c += decimal.valueOf(attribute.cscfga__Value__c);                   
                }
                else if(attribute.Name.contains('UnitOfMeasure') && attribute.cscfga__Value__c!=null){
                    if(attribute.cscfga__Value__c.equalsIgnoreCase('Not Applicable') || attribute.cscfga__Value__c.equalsIgnoreCase('NotApplicable'))
                        tmp.Unit_of_measurement__c = '';
                    else
                        tmp.Unit_of_measurement__c = attribute.cscfga__Value__c;                
                }
                else if(attribute.Name.contains('ServiceabilityLocation') && attribute.cscfga__Value__c!=null){                
                    tmp.Serviceability_Location__c=attribute.cscfga__Value__c;
                }
                else if(attribute.Name.contains('ResponseTime') && attribute.cscfga__Value__c!=null){               
                    tmp.Response_Time__c=attribute.cscfga__Value__c;
                }
                else if(attribute.Name.contains('RestorationTime') && attribute.cscfga__Value__c!=null){                
                    tmp.Restoration_Time__c=attribute.cscfga__Value__c;
                }
                else if(attribute.Name.contains('Site Name') && attribute.cscfga__Value__c!=null){                
                    tmp.Site_Name__c=attribute.cscfga__Value__c;
                }
                else if(attribute.Name.contains('Site Address') && attribute.cscfga__Value__c!=null){                
                    tmp.Site_Address__c=attribute.cscfga__Value__c;
                }
                else if(attribute.Name.contains('UnitPrice') && attribute.cscfga__Value__c!=null){
                    tmp.Rate__c = decimal.valueOf(attribute.cscfga__Value__c);
                    System.debug('tmp:'+tmp.Rate__c+' value'+attribute.cscfga__Value__c+' name:'+tmp.Name);
                }/*
                else if(attribute.Name.contains('Quantity') && attribute.cscfga__Value__c!=null){
                    tmp.Quantity_Product_Configuration__c = decimal.valueOf(attribute.cscfga__Value__c);
                }*/
            }
        }
        System.debug('result:'+productConfigurations);
        upsert productConfigurations;
        productConfigurations =[select id,name,cscfga__total_one_off_charge__c,cscfga__total_recurring_charge__c,Product_Module_Name__c,GSTExcl_Total_Recurring_Charges__c,GSTExcl_Total_Onceoff_Charges__c,TotalGSTInclusiveTOC__c,TotalGSTInclusiveTRC__c 
        from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:BasketId and cscfga__Product_Definition__r.Snapshot_Object__c != null and cscfga__Parent_Configuration__c!=null];
        for(cscfga__Product_Configuration__c pc : productConfigurations)
        {   
/*
Author      : Jayesh
Created On  : 25 Mar 2019
Description : EDGE-41492 : As a Sales Enterprise B2B user and Partner user, 
I want to see the product descriptors as defined by offer manager on quote and contract 
So that customer has a unified understanding of the product via quote, contract and bill.
Changes     : Commented below 2 if conditions
*/
          /*  if(String.isBlank(pc.Product_Module_Name__c))
            {
                pc.Product_Module_Name__c = pc.name;
            }
            System.debug('pc:'+pc.name+'  '+pc.Product_Module_Name__c+'  '+pc.TotalGSTInclusiveTOC__c + ' '+ pc.TotalGSTInclusiveTRC__c);
            if((pc.TotalGSTInclusiveTOC__c == null || pc.TotalGSTInclusiveTOC__c == 0.0 )&& (pc.TotalGSTInclusiveTRC__c == null || pc.TotalGSTInclusiveTRC__c == 0.0 ))
            {
                pc.Product_Module_Name__c = pc.name+' *';   
            }*/
            if(pc.TotalGSTInclusiveTOC__c != null && pc.TotalGSTInclusiveTOC__c == 0.0)
            {
                pc.TotalGSTInclusiveTOC__c = pc.cscfga__total_one_off_charge__c;
                pc.GSTExcl_Total_Onceoff_Charges__c = pc.cscfga__total_one_off_charge__c;
            }
            if(pc.TotalGSTInclusiveTRC__c != null && pc.TotalGSTInclusiveTRC__c == 0.0)
            {
                pc.TotalGSTInclusiveTRC__c = pc.cscfga__total_recurring_charge__c;
                pc.GSTExcl_Total_Recurring_Charges__c = pc.cscfga__total_recurring_charge__c;
            }
        }
        System.debug('GST productConfigurations : '+productConfigurations);
       update productConfigurations;
    }  
    /*
Author      : Maq
Created On  : 20 Nov 2018
Description : EDGE-52268 : I want to default the quote recipient as aligned with previously setup contract 
signatory So that I can ensure quote will be sent to the right recipient
Return Type : Contact Id
*/
    public static String fetchQuoteRecipient(cscfga__Product_Basket__c productBasket) {
        if(Limits.getQueries() < 101){
            list<AccountContactRelation> All_ACR = new list<AccountContactRelation>();
            list<Id> listContactIdFCR = New list<Id>();    
            for(AccountContactRelation ACR : [SELECT Id, ContactId FROM AccountContactRelation 
                                              WHERE ( Roles= 'Full Authority' OR Roles = 'Legal Lessee') 
                                              AND AccountId =: productBasket.csbb__Account__c Order By CreatedDate DESC]){
                if(ACR.ContactId != NULL){
                    listContactIdFCR.add(ACR.ContactId);
                    All_ACR.add(ACR);
                } 
            }
            Date todayDate = System.TODAY()-1;
            list<Functional_Contact_Role__c> FCRRecord = [SELECT Id, ContactID__c FROM Functional_Contact_Role__c 
                                                          WHERE Role__c = 'Contract Signatory Role' AND ContactID__c IN: listContactIdFCR 
                                                          AND (Relationship_End_Date__c >: todayDate OR Relationship_End_Date__c = NULL) order by createddate DESC LIMIT 1]; 
            if(FCRRecord.size()>0){
                return FCRRecord[0].ContactID__c;
            }
            else{
                // return NULL;
                if(All_ACR.size() > 0){
                    return All_ACR[0].ContactId;
                }
            }
        }
        return NULL;
    }
    public void validateRelatedContact(List<quote> newQuote,Map<Id,quote> newQuoteMap, List<quote> oldQuote,Map<Id,quote> oldQuoteMap){
        try{           
            set<Id> relatedContactId = new set<Id>();
            Boolean statusChanged = false;
            system.debug('newQuote--->'+newQuote);
            // Because of salesforce limitation of return AccountId null in trigger lightning view, quering the data through SOQL
            // Trigger in a DML on quote returns null AccountID in Lightning Experience
            list<quote> newListQuote = new List<quote>();
            newListQuote= [SELECT Id, AccountId FROM Quote where Id IN :newQuote AND AccountId!=null];
            for(quote newRecord : newQuote){
                if (newRecord.contactId != oldQuoteMap.get(newRecord.Id).contactId)
                {
                    statusChanged = true;
                }
            } 
            if(statusChanged == true){
                list<Id> listContactIdFCR = New list<Id>();
                for(AccountContactRelation ACR : [SELECT Id, ContactId FROM AccountContactRelation 
                                                  WHERE ( Roles= 'Full Authority' OR Roles = 'Legal Lessee') 
                                                  AND AccountId =: newListQuote[0].AccountId Order By CreatedDate DESC]){
                    if(ACR.ContactId != NULL){
                        listContactIdFCR.add(ACR.ContactId);
                        relatedContactId.add(ACR.ContactId);
                    } 
                }
                /*  Date todayDate = System.TODAY()-1;
list<Functional_Contact_Role__c> FCRRecord = [SELECT Id, ContactID__c FROM Functional_Contact_Role__c 
                                              WHERE Role__c = 'Contract Signatory Role' AND ContactID__c IN: listContactIdFCR 
                                              AND (Relationship_End_Date__c >: todayDate OR Relationship_End_Date__c = NULL) order by createddate DESC]; 
if(FCRRecord.size()>0){
for(Functional_Contact_Role__c contactRec : FCRRecord){
relatedContactId.add(contactRec.ContactID__c);
}                   
}
else{
// return NULL;
} */
                if( !relatedContactId.contains(newQuote[0].contactId) && newQuote[0].contactId != null){
                    for(quote q : newQuote){              
                        q.addError('Unrelated contact to the account for which the quote has been generated');
                    } 
                }
            }
        } 
        catch(Exception e) {
        }  
    }
}