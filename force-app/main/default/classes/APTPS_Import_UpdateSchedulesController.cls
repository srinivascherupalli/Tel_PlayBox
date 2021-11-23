/*************************************************************************************************************************
 @Name: APTPS_Import_UpdateSchedulesController
 @Author: Shishir Bose
 @Created Date: 07/01/2016
 @updated Niranjan Mehta, Durga Raghupathy
 @Descripton: This controller is created for handling the CSV file provided by PA approval.
 System will update Headterms, Insert/Update Schedules, Insert/Update Funds data based on this csv 
 @Used By: APTPS_Init_ImportUpdateSchedules  VF page
*******************************************************************************************************************************/
public class APTPS_Import_UpdateSchedulesController {
    
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public string agreementName{get;set;}
    public Apttus__APTS_Agreement__c parentAgreement {get; set;}
    public Apttus__APTS_Agreement__c headTerms {get; set;}
    public ApexPages.Message errorMessage {get; set;}
    public boolean errorFound {get; set;}
    public boolean errorActivatedSchedulesFound {get; set;}
    public boolean showWarning {get; set;}
    public string productUsed {get; set;}
    public decimal maxScheduleNumber {get; set;}
    public boolean missingProduct {get; set;}
    public Id scheduleRecordTypeId {get; set;}    
    public Apttus__AgreementLineItem__c productAgreementLineItem {get; set;}
  
    
    public Apttus__APTS_Agreement__c productSchedule  {get; set;}
    //Changing APTPS_Agreement_Pricing_Data_Map__c as transient to fix view state error issue
    // Original Code - public Map<string,APTPS_Agreement_Pricing_Data_Map__c> agreementPricingMap {get; set;}
    transient public Map<string,APTPS_Agreement_Pricing_Data_Map__c> agreementPricingMap {get; set;} //New Code 
    Map<Id,APTPS_Agreement_Pricing_Data_Map__c> onlyProductPricingMap {get; set;}
    Map<string,Id> fundsRecordType = null;
    
    public Fund_Product__c fundProduct {get; set;}
    Map<Id,string> productPCMSCodeMapping {get; set;}
    Map<Id,Fund_Product__c> fundProductsForEachProductTIF {get; set;}
    Map<Id,Fund_Product__c> fundProductsForEachProductMOTIF {get; set;}
    Map<Id,Fund_Product__c> fundProductsForEachProductGROWTH {get; set;}
    Map<Id,Fund_Product__c> fundProductsForEachProductLOYALTY {get; set;}
    Map<Id,Fund_Product__c> fundProductsForEachProductMBRS {get; set;}    
    Map<Id, Apttus__AgreementLineItem__c> agreementLineItemsForUpsert {get; set;}
    Map<Id, Map<string, APTPS_Component__c>> agreementLineItemsComponents {get; set;}
    Map<string, Apttus__APTS_Agreement__c> agreementsForUpsert  {get; set;}
    Map<string,Id> allProducts = new Map<string,Id>();
    Set<Id> productIds = new Set<Id>();
    
    List<APTPS_Component__c> componentsToBeUpserted {get; set;}
    Map<Id, Fund__c> headTermsFunds {get; set;}
    public boolean displayError{get; set;}
    List<string> warningMessagesToBeMailed {get; set;}
    
    
    public string cancelButtonName {get; set;}
    
    Map<Id, Apttus__APTS_Agreement__c> activatedSchedules  {get; set;}
    
    //Start: Added by Manthan Shah for Apttus Case #00220130  
    Map<Id, Apttus__APTS_Agreement__c> inprocessSchedules  {get; set;}  
    Map<Id, Apttus__APTS_Agreement__c> terminatedSchedules  {get; set;}  
    Map<string, Apttus__APTS_Agreement__c> terminatedagreements  {get; set;}  
    Map<string, Apttus__APTS_Agreement__c> inRequestgreements  {get; set;}  
    		  
    
    public APTPS_Import_UpdateSchedulesController(){
    
    
          
    }
    
    //This is the constructor of the class. Here system perform select operations for HeadTerms, Schedules, Agreement Line Items and Funds data
    public APTPS_Import_UpdateSchedulesController(ApexPages.StandardController stdController){
        
        try
        {
            if(!Test.isRunningTest()){
                stdController.addFields(new List<string>{'Apttus__FF_Agreement_Number__c','Name','Apttus__Status_Category__c', 'Apttus__Status__c','Apttus__Account__c'
                    ,'Apttus__Term_Months__c','APTPS_Customer_Primary_Contact__c','Apttus_Approval__Approval_Status__c'});//00220130 : Added Field Apttus_Approval__Approval_Status__c 
                }
            parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
            agreementName = parentAgreement.Name;
            csvFileLines = new String[]{};

            //Getting the record type of schedule
            scheduleRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Schedule').getRecordTypeId();


           agreementPricingMap = new Map<string,APTPS_Agreement_Pricing_Data_Map__c>();
           onlyProductPricingMap = new Map<Id,APTPS_Agreement_Pricing_Data_Map__c>();

            //Getting data for all the pricing map fields.
            for(APTPS_Agreement_Pricing_Data_Map__c agrmntPricingMap: [select Object_Name__c, APTPS_Field_Name__c, Field_Type__c,
                                                            APTPS_Product__c, APTPS_Product_Family__c,
                                                              Related_Service_Schedule__c, 
                                                              Tag__c,APTPS_Fund_Type__c, 
                                                             APTPS_Tag_Type__c, APTPS_Translates_To_Field__c from APTPS_Agreement_Pricing_Data_Map__c 
                                                           ])

            {
                //Pricing map will not have Tag value for record representing the Product
                //In those cases Product code will be the Key for the map
                 agreementPricingMap.put(agrmntPricingMap.Tag__c, agrmntPricingMap);
                if(agrmntPricingMap.APTPS_Product__c != null)
                {
                    if(!productIds.contains(agrmntPricingMap.APTPS_Product__c))
                    {
                        productIds.add(agrmntPricingMap.APTPS_Product__c);
                    }
                    if(onlyProductPricingMap.get(agrmntPricingMap.APTPS_Product__c) == null)
                    {
                        onlyProductPricingMap.put(agrmntPricingMap.APTPS_Product__c, agrmntPricingMap);
                    }
                    
                }             
            }

            //Getting all the products and creating map for further processing
            for(Product2 product : [select Id, Name from Product2 where Id in : productIds])
            {
                allProducts.put(product.Name.trim().toUpperCase(), product.Id);
            }



            //Creating the Map for Funds Record Type and Name
            fundsRecordType = new Map<string,Id>(); 
            for(RecordType fundRecord : [SELECT Id,Name FROM RecordType WHERE SobjectType='Fund__c'])
            {
                fundsRecordType.put(fundRecord.Name, fundRecord.Id); 

            }

            //Creating individual maps of Product for different funds type

            productPCMSCodeMapping = new  Map<Id,string>();

            fundProductsForEachProductTIF = new Map<Id,Fund_Product__c>(); 
            fundProductsForEachProductMOTIF = new Map<Id,Fund_Product__c>();
            fundProductsForEachProductGROWTH = new Map<Id,Fund_Product__c>();
            fundProductsForEachProductLOYALTY = new Map<Id,Fund_Product__c>();
            fundProductsForEachProductMBRS = new Map<Id,Fund_Product__c>();

            headTermsFunds = new  Map<Id, Fund__c>();
            for(Fund__c fnd : [select Id,recordTypeId,Agreement__c, 
                               (select Id, Fund__c,  APTPS_PCMS_Code__c, Product__c, APTPS_Year_1__c, APTPS_Year_2__c, 
                APTPS_Year_3__c, APTPS_Year_4__c, APTPS_Year_5__c from Fund_Products__r )
                               from Fund__c where Agreement__c =: parentAgreement.Id and recordTypeId in : fundsRecordType.values()])
            {
               headTermsFunds.put(fnd.recordTypeId, fnd);
               for(Fund_Product__c fndProduct : fnd.Fund_Products__r)
               {
                   if(fnd.recordTypeId == fundsRecordType.get('Growth'))
                   {
                       fundProductsForEachProductGROWTH.put(fndProduct.Product__c, fndProduct);
                   }
                   else if(fnd.recordTypeId == fundsRecordType.get('Other'))
                   {
                       fundProductsForEachProductLOYALTY.put(fndProduct.Product__c, fndProduct);
                   }
                   else if(fnd.recordTypeId == fundsRecordType.get('MBRS'))
                   {
                       fundProductsForEachProductMBRS.put(fndProduct.Product__c, fndProduct);
                   }
                   else if(fnd.recordTypeId == fundsRecordType.get('MOTIF'))
                   {
                       fundProductsForEachProductMOTIF.put(fndProduct.Product__c, fndProduct);
                   }
                   else if(fnd.recordTypeId == fundsRecordType.get('TIF'))
                   {
                       fundProductsForEachProductTIF.put(fndProduct.Product__c, fndProduct);
                   }
               }
            }       



          //Creating the maps for Schedule, Agreement Line Item and Components for further processing.Creating
            //This will also help in avoiding select soql's as all the data will be captured and kept in maps

            //Map for Agreement Line Item
            agreementLineItemsForUpsert = new Map<Id, Apttus__AgreementLineItem__c>();

            //Map for Schedules
            agreementsForUpsert = new Map<string, Apttus__APTS_Agreement__c>();
	    //Start : Niranjan Mehta: Changes for User story EDGE-13251
            terminatedagreements = new Map<string, Apttus__APTS_Agreement__c>();
            inRequestgreements = new Map<string, Apttus__APTS_Agreement__c>();
            //End : Niranjan Mehta: Changes for User story EDGE-13251
            //Maps and list for components to be inserted and deleted
             maxScheduleNumber = 0;
             agreementLineItemsComponents = new Map<Id, Map<string, APTPS_Component__c>> ();
             
             componentsToBeUpserted = new List<APTPS_Component__c>();
             List<Id> temAgreementLineItem = new List<Id>();
           
             activatedSchedules = new Map<Id, Apttus__APTS_Agreement__c>();
            //Start : Niranjan Mehta: Changes for User story EDGE-13251 --Added by Manthan Shah for Apttus Case #00220130  
             inprocessSchedules = new Map<Id, Apttus__APTS_Agreement__c>();
             terminatedSchedules = new Map<Id, Apttus__APTS_Agreement__c>();
 	     //End : Niranjan Mehta: Changes for User story EDGE-13251
           
             for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, Apttus__FF_Agreement_Number__c, RecordTypeId, Apttus__Status_Category__c, 
                                                     Apttus__Status__c, Apttus__Agreement_Category__c, APTPS_Agreement_Subcategory__c, Apttus__Subtype__c,
                                                     Apttus__Parent_Agreement__c, APTPS_Data_Plans__c, APTPS_Group_Data_Plans__c,
                                                     APTPS_Data_PLUS_Plans__c, APTPS_Group_Data_PLUS_Plans__c,APTPS_Schedule_Number_Text__c,
                                                     APTPS_Location_Services__c, APTPS_Direct_customer__c,APTPS_Master_Value_Added_Reseller__c,
                                                     APTPS_Value_Added_Reseller__c,APTPS_Variation__c,Apttus_Approval__Approval_Status__c,
                                                     (select Id, Apttus__AgreementId__c, Apttus__ProductId__c, 
                                                     Name, APTPS_Billings_Codes__c, APTPS_Product_Minimum_Spend__c, APTPS_frequency__c                                                 
                                                     from Apttus__AgreementLineItems__r) from Apttus__APTS_Agreement__c
                                                     where Apttus__Parent_Agreement__c =:  parentAgreement.Id and APTPS_Agreement_Subcategory__c != null and Apttus__Subtype__c != null and Apttus__Status__c != 'Being Amended'] )
             {
                 //Creating the Map for schedules and using Agreement Sub Category and Sub Type for the key of this maps
                 //This will help in identifying association of schedules and agreement line item
                 //Using Upper Case to avoid errors due to case sensistive nature of keys.

                 //Start : Niranjan Mehta: Changes for User story EDGE-13251
                 if(agrmnt.Apttus__Status_Category__c != APTPS_Constants.TERMINATED_STATUS_CATEGORY && agrmnt.Apttus__Status_Category__c != APTPS_Constants.CANCELLED_STATUS_CATEGORY)
                 {

                     agreementsForUpsert.put(agrmnt.APTPS_Agreement_Subcategory__c.trim().toUpperCase() + '_' + agrmnt.Apttus__Subtype__c.trim().toUpperCase(), agrmnt);
                }
               
                 calculateMaxScheduleNumber(agrmnt.APTPS_Schedule_Number_Text__c);
                if(((agrmnt.Apttus__Status_Category__c == APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS || agrmnt.Apttus__Status_Category__c == APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY) 
                        && ( agrmnt.Apttus__Status__c == APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS ||  agrmnt.Apttus__Status__c == APTPS_Constants.IN_AUTHOR_CONTRACT_STATUS)) || (agrmnt.Apttus__Status__c == APTPS_Constants.INAMENDMENT_STATUS ) && ( agrmnt.Apttus_Approval__Approval_Status__c != APTPS_Constants.PENDINGAPPROVAL))
                {
                        inprocessSchedules.put(agrmnt.Id, agrmnt);
                       // presentAgrs.add(agrmnt);
                        inRequestgreements.put(agrmnt.APTPS_Agreement_Subcategory__c.trim().toUpperCase() + '_' + agrmnt.Apttus__Subtype__c.trim().toUpperCase(), agrmnt);
                }
                else
                {
                //Added Status as per agreement with Jacqui
                    if((agrmnt.Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY 
                        /*&& agrmnt.Apttus__Status__c == APTPS_Constants.IN_EFFECT_STATUS*/) || (agrmnt.Apttus__Status__c== APTPS_Constants.FULLY_SIGNED_STATUS || agrmnt.Apttus__Status__c== APTPS_Constants.FULLY_SIGNED_MIGRATED_STATUS || agrmnt.Apttus__Status__c== APTPS_Constants.SUPERSEDED_STATUS || agrmnt.Apttus__Status__c== APTPS_Constants.OTHER_PARTY_SIGNATURES_STATUS || agrmnt.Apttus__Status__c== APTPS_Constants.ROLLING_STATUS 
                        || agrmnt.Apttus__Status__c == APTPS_Constants.BEINGRENEWED_STATUS || agrmnt.Apttus__Status__c == APTPS_Constants.BEINGTERMINATED_STATUS || agrmnt.Apttus__Status__c == APTPS_Constants.BEINGAMENDED_STATUS ) || (agrmnt.Apttus_Approval__Approval_Status__c == APTPS_Constants.PENDINGAPPROVAL))
                    {
                        activatedSchedules.put(agrmnt.Id, agrmnt);
                    }
                    else if(agrmnt.Apttus__Status_Category__c == APTPS_Constants.TERMINATED_STATUS_CATEGORY || agrmnt.Apttus__Status_Category__c == APTPS_Constants.CANCELLED_STATUS_CATEGORY)
                            
                        {
                            terminatedSchedules.put(agrmnt.Id, agrmnt);

                            terminatedagreements.put(agrmnt.APTPS_Agreement_Subcategory__c.trim().toUpperCase() + '_' + agrmnt.Apttus__Subtype__c.trim().toUpperCase(), agrmnt);
                            //maxScheduleNumber = decimal.valueOf(agrmnt.APTPS_Schedule_Number_Text__c.substring(0, 1))-2;
  
                        }
                    
                     //  commented by akanksha for schedule number type change 
                     
                    
                }
              //End: Added by Manthan Shah for Apttus Case #00220130
	      //End : Niranjan Mehta: Changes for User story EDGE-13251
                /* if(agrmnt.APTPS_Schedule_Number_Text__c > maxScheduleNumber)
                 {
                     maxScheduleNumber = agrmnt.APTPS_Schedule_Number_Text__c;
                 }
                  */
                 for(Apttus__AgreementLineItem__c lineItem : agrmnt.Apttus__AgreementLineItems__r)
                 {
                     //Creating the map of Agreement line Item, the kep is product Id
                     //The key will help in associating the agreement line item to components.

                     if((agrmnt.Apttus__Status_Category__c != APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS && agrmnt.Apttus__Status_Category__c != APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY && agrmnt.Apttus__Status_Category__c != APTPS_Constants.TERMINATED_STATUS_CATEGORY && agrmnt.Apttus__Status_Category__c != APTPS_Constants.CANCELLED_STATUS_CATEGORY) 
                        || ( agrmnt.Apttus__Status__c != APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS &&  agrmnt.Apttus__Status__c != APTPS_Constants.IN_AUTHOR_CONTRACT_STATUS && agrmnt.Apttus__Status_Category__c != APTPS_Constants.TERMINATED_STATUS_CATEGORY && agrmnt.Apttus__Status_Category__c != APTPS_Constants.CANCELLED_STATUS_CATEGORY)
                         )
                    {
                     agreementLineItemsForUpsert.put(lineItem.Apttus__ProductId__c, lineItem);
                     temAgreementLineItem.add(lineItem.Id);
                    }
                 }
             }

            //Creating the map of Components for each agreement line item.
            Map<string, APTPS_Component__c> tempComponents = new Map<string, APTPS_Component__c>();
            if(agreementLineItemsForUpsert.size() > 0)
            {
                for(APTPS_Component__c component : [select Id, Agreement_Line_Item__c,Tag__c  from APTPS_Component__c where Agreement_Line_Item__c in : temAgreementLineItem ])
                {
                    if(agreementLineItemsComponents.get(component.Agreement_Line_Item__c) != null)
                     {
                        tempComponents = agreementLineItemsComponents.get(component.Agreement_Line_Item__c);
                        tempComponents.put(component.Tag__c, component);

                        agreementLineItemsComponents.remove(component.Agreement_Line_Item__c);
                        agreementLineItemsComponents.put(component.Agreement_Line_Item__c, tempComponents);
                    }
                    else
                    {
                       tempComponents = new Map<string, APTPS_Component__c>();
                       tempComponents.put(component.Tag__c, component);
                       agreementLineItemsComponents.put(component.Agreement_Line_Item__c, tempComponents);
                    }
                }
            }
            
            warningMessagesToBeMailed = new List<string>();
            cancelButtonName = 'Cancel';
            
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));              
        }
         
       
    }
     /*************************************************************************************************************************
    @Name: calculateMaxScheduleNumber
    @Author: Akanksha Trivedi
    @Created Date: 03/06/2017
    @Descripton: This method to calculate max schedule number.
    *************************************************************************************************************************/
    public void calculateMaxScheduleNumber(String scheduleNumber){
        Decimal tempMaxNumber=0;
       
        if(scheduleNumber != null){
           tempMaxNumber= decimal.valueOf(scheduleNumber.substring(0, 1));
        }
        if(tempMaxNumber > maxScheduleNumber)
         {
           maxScheduleNumber = tempMaxNumber;
         }
    }
    /*************************************************************************************************************************
    @Name: importUpdateCSVFile
    @Author: Shishir Bose
    @Created Date: 04/28/2016
    @Descripton: This method parses the incoming CSV and populates data for Insert/Update. 
    *************************************************************************************************************************/
    public PageReference importUpdateCSVFile(){

        //Start: Added by Manthan Shah for Apttus Case #00220130
       
        List<Apttus__APTS_Agreement__c> presentAgrs = [select Id, Apttus__Status__c, Apttus__Status_Category__c,APTPS_Agreement_Subcategory__c,Apttus__Subtype__c  from Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c =: parentAgreement.Id];
        List<Apttus__APTS_Agreement__c> inprocAgrs = new List<Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c agr: presentAgrs)
        {
            if(((agr.Apttus__Status_Category__c == APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS || agr.Apttus__Status_Category__c == APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY || agr.Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY) 
                        && (agr.Apttus__Status__c == APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS ||  agr.Apttus__Status__c == APTPS_Constants.IN_AUTHOR_CONTRACT_STATUS ||  agr.Apttus__Status__c == APTPS_Constants.BEINGAMENDED_STATUS)) || (agr.Apttus__Status__c == APTPS_Constants.INAMENDMENT_STATUS))
                {
                        inprocessSchedules.put(agr.Id,agr);
                        inprocAgrs.add(agr);
                        //agreementsForUpsert.remove(agr.APTPS_Agreement_Subcategory__c.trim().toUpperCase() + '_' + agr.Apttus__Subtype__c.trim().toUpperCase());
                }

               
               
            
        }

        //delete inprocAgrs;
        System.debug('**activatedSchedules: '+activatedSchedules+' inprocessSchedules:'+inprocessSchedules);
        //End: Added by Manthan Shah for Apttus Case #00220130
        
        //If the file name is empty show the error message
        string[] csvRecordData = null;
        PageReference pageRef = new PageReference('/'+parentAgreement.Id);
        displayError = false;
        if(string.isEmpty(csvAsString))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Select CSV File to upload Schedules.'));
            return null;
        }
        //Sachin - Niranjan Mehta : Updated Error Message for Special Characters : Included new character to avoid checkin issue
        else if (parentAgreement.Apttus__Status_Category__c == APTPS_Constants.TERMINATED_STATUS_CATEGORY || parentAgreement.Apttus__Status_Category__c == APTPS_Constants.CANCELLED_STATUS_CATEGORY || parentAgreement.Apttus__Status__c== APTPS_Constants.FULLY_SIGNED_STATUS || parentAgreement.Apttus__Status__c == APTPS_Constants.ACTIVATED_STATUS || parentAgreement.Apttus__Status_Category__c == APTPS_Constants.IN_FILING_STATUS_CATEGORY 
        || parentAgreement.Apttus__Status__c == APTPS_Constants.BEINGAMENDED_STATUS || parentAgreement.Apttus__Status__c == APTPS_Constants.BEINGRENEWED_STATUS || parentAgreement.Apttus__Status__c == APTPS_Constants.BEINGTERMINATED_STATUS || parentAgreement.Apttus_Approval__Approval_Status__c == APTPS_Constants.PENDINGAPPROVAL)
               {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'This record cannot be edited because it has been either Fully Signed, Activated or Terminated or Cancelled or \'In Filling\' or \'Pending Approval\'. To make changes to this contract create a new record using Create Variation, Clone buttons available or Renew agreement.'));
                   return null;
               }
        else
        {
            try{
                headTerms = new Apttus__APTS_Agreement__c();
                headTerms = APTPS_CommonUtilities.getAgreementData(parentAgreement.Id);
                csvAsString = csvFileBody.toString();
                csvFileLines = csvAsString.split('\n'); 
                errorFound = false;
                showWarning = false;
                productUsed = null;
                csvFileBody = null;
                errorActivatedSchedulesFound = false;
                
                if(agreementPricingMap == null)
                {
                    agreementPricingMap = new Map<string,APTPS_Agreement_Pricing_Data_Map__c>();
                    onlyProductPricingMap = new Map<Id,APTPS_Agreement_Pricing_Data_Map__c>();
                     for(APTPS_Agreement_Pricing_Data_Map__c agrmntPricingMap: [select Object_Name__c, APTPS_Field_Name__c, Field_Type__c,
                                                                    APTPS_Product__c, APTPS_Product_Family__c,
                                                                      Related_Service_Schedule__c, 
                                                                      Tag__c,APTPS_Fund_Type__c, 
                                                                     APTPS_Tag_Type__c, APTPS_Translates_To_Field__c from APTPS_Agreement_Pricing_Data_Map__c 
                                                                   ])

                    {
                        //Pricing map will not have Tag value for record representing the Product
                        //In those cases Product code will be the Key for the map
                         agreementPricingMap.put(agrmntPricingMap.Tag__c, agrmntPricingMap);
                        if(agrmntPricingMap.APTPS_Product__c != null)
                        {
                            if(!productIds.contains(agrmntPricingMap.APTPS_Product__c))
                            {
                                productIds.add(agrmntPricingMap.APTPS_Product__c);
                            }
                            if(onlyProductPricingMap.get(agrmntPricingMap.APTPS_Product__c) == null)
                            {
                                onlyProductPricingMap.put(agrmntPricingMap.APTPS_Product__c, agrmntPricingMap);
                            }

                        }             
                    }
                }
                //Iterate through each row, each row is processed separately bases on Tag Type field of CSV. 
                for(Integer i = 1;i < csvFileLines.size();i++){
                   
                    if(errorFound)
                    {
                        displayError = true;
                        return null;
                    }
                    csvRecordData = csvFileLines[i].split(',');
                    
                    if(checkEmptyRow(csvRecordData))
                    {
                        continue;
                    }
                    
                    if(csvRecordData[0] == 'Head Terms')
                    {
                        populateHeadTerms(csvRecordData[4],csvRecordData[7], csvRecordData[6]);
                    }
                    if(csvRecordData[0] == 'Schedule')
                    {
                        populateSchedulesData(csvRecordData[3],csvRecordData[4],csvRecordData[5],csvRecordData[7],csvRecordData[6], csvRecordData[8]);
                    }   
                    
                    if(csvRecordData[0] == 'Minimum Spend')
                    {
                        populateMinimuSpendData(csvRecordData[3], csvRecordData[4], csvRecordData[7], csvRecordData[6]);
                    }   
                    
                     if(csvRecordData[0] == 'Funds')
                    {
                       populateFundsData(csvRecordData[3], csvRecordData[4], csvRecordData[7], csvRecordData[6]);                     
                    } 
                }
                
                
                if(errorFound || errorActivatedSchedulesFound)
                {
                    displayError =true;
                    return null;
                }
                
                //Updating the headTerms and Pricing Specilaist
                updatePricingSpecialist();
                update headTerms;
                
                //Update Funds information
                updateFundsData();
                
                
                //Performing the insert/Update operations on Schedules, Agreement Line Items and Components
                 if(agreementsForUpsert.size() > 0)
                 {
                    List<Apttus__APTS_Agreement__c> agreementsUpserted = new List<Apttus__APTS_Agreement__c>();

                    for(Apttus__APTS_Agreement__c agr : agreementsForUpsert.values())
                    {
                         
                        if(agr.APTPS_Schedule_Number_Text__c == null)
                        {
                            if(terminatedagreements.containsKey(agr.APTPS_Agreement_Subcategory__c.trim().toUpperCase() + '_' + agr.Apttus__Subtype__c.trim().toUpperCase()))
                            {

                                Apttus__APTS_Agreement__c tempAgr = terminatedagreements.get(agr.APTPS_Agreement_Subcategory__c.trim().toUpperCase() + '_' + agr.Apttus__Subtype__c.trim().toUpperCase());

                                
                                agr.APTPS_Schedule_Number_Text__c = tempAgr.APTPS_Schedule_Number_Text__c;
                                
                            }
                            else
                            {
                                
                                maxScheduleNumber = maxScheduleNumber + 1;
                                
                                // changes made by akanksha for schedule number type change
                                agr.APTPS_Schedule_Number_Text__c = maxScheduleNumber.toPlainString();
                            }
                        }
                            
                        agreementsUpserted.add(agr);                       
                    }

                     upsert agreementsUpserted;

                     //Creating the map, that will be used to get the schedule id for inserting agreement line items.
                     agreementsForUpsert = new Map<string, Apttus__APTS_Agreement__c>();
                     for(Apttus__APTS_Agreement__c agrmnt : agreementsUpserted)
                     {
                         agreementsForUpsert.put(agrmnt.APTPS_Agreement_Subcategory__c.trim().toUpperCase() + '_' + agrmnt.Apttus__Subtype__c.trim().toUpperCase(), agrmnt);                 
                     }

                     if(agreementLineItemsForUpsert.size() > 0)
                     {
                         List<Apttus__AgreementLineItem__c> agreementLineItemssUpserted = new List<Apttus__AgreementLineItem__c>();
                         for(Apttus__AgreementLineItem__c lnItem : agreementLineItemsForUpsert.values())
                         {
                             if(lnItem.Apttus__AgreementId__c == null)
                             {
                                 APTPS_Agreement_Pricing_Data_Map__c agreementMap  = onlyProductPricingMap.get(lnItem.Apttus__ProductId__c);

                                 //Getting the Schedule Id
                                 lnItem.Apttus__AgreementId__c = agreementsForUpsert.get(agreementMap.APTPS_Product_Family__c.trim().toUpperCase() 
                                                                                         + '_' + agreementMap.Related_Service_Schedule__c.trim().toUpperCase()).Id;
                             }

                             agreementLineItemssUpserted.add(lnItem);

                         }

                         upsert agreementLineItemssUpserted;
                        

                         //Creating the MAp which will use to insert Components by helping in association
                         agreementLineItemsForUpsert = new Map<Id, Apttus__AgreementLineItem__c>();
                         for(Apttus__AgreementLineItem__c lineItem : agreementLineItemssUpserted)
                         {
                             agreementLineItemsForUpsert.put(lineItem.Apttus__ProductId__c, lineItem);                 
                         }

                         if(componentsToBeUpserted.size() > 0)
                         {
                             List<APTPS_Component__c> componentsList = new List<APTPS_Component__c>();
                             for(APTPS_Component__c comp : componentsToBeUpserted)
                             {
                                 if(comp.Agreement_Line_Item__c == null)
                                 {
                                    comp.Agreement_Line_Item__c = agreementLineItemsForUpsert.get(comp.APTPS_Product_Id_For_Upsert__c).Id;
                                 }
                                 componentsList.add(comp);
                             }
                             System.debug('Shishir componentsList:' + componentsList);
                             upsert componentsList;
                             agreementLineItemssUpserted = null;
                         }
                         
                         agreementLineItemssUpserted = null;
                     }
                     
                     agreementsUpserted = null;
                 }       
                
                
                 if(showWarning)
                 {
                     displayError = true;
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Please note. If only warnings are displayed at the end '
                                                                + 'of the process, then system has saved the data for all the matching tags. ' 
                                                                + 'Only the data of unmatched tags is not saved, please contact the Salesforce '
                                                                + 'Administrator to resolve them. On clicking cancel you can go back to agreement '
                                                                + 'page and verify your change'));
                     
                     sendMail();
                     cancelButtonName = 'Continue';
                     agreementPricingMap = null;
                     onlyProductPricingMap = null;
                     return null;
                 }
                return pageRef;
                
            }   
            catch (Exception e)
            {
                agreementPricingMap = null;
                onlyProductPricingMap = null;
                string errorMessageText;
                displayError = true;                

               if(csvRecordData != null)
                {
                   if(csvRecordData[4] == 'Cust_CIDN')
                   {
                       errorMessageText = 'Error occured for ' + csvRecordData[0] + ', the CIDN - ' +csvRecordData[7]+ 
                           ' does not match with CIDN of the account ' + parentAgreement.Apttus__Account__c;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessageText));
                   }
                   else if(errorFound || errorActivatedSchedulesFound)
                   {
                  	  displayError =true;
                 	   return null;
                   }
                 else 
                  {
                    errorMessageText = 'Error occured for ' + csvRecordData[0] + ' for tag ' + csvRecordData[4] + ' and value ' + csvRecordData[7];
                    //errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, errorMessageText);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessageText));
                       
                       
                        errorMessageText = e.getMessage();
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,errorMessageText));
                   }
                   return null;
                }
               
                
               errorMessageText = e.getMessage();
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,errorMessageText));
                
               
              
                return null;
            }
            
        } 
    }
    /*************************************************************************************************************************
 @Name: sendMail
 @Author: Shishir Bose
 @Created Date: 05/27/2016
 @Descripton: This method is called for sending mails in case an error occurs while activation agreements
*************************************************************************************************************************/
    @testVisible private void sendMail()
    {
        // Now create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Strings to hold the email addresses to which you are sending the email.
        string userEmail = Userinfo.getUserEmail();

        //String[] toAddresses = new String[] {userEmail}; 
        List<String> toAddresses = new List<String>();
        toAddresses.add(userEmail);   
        Apttus__ComplySystemProperties__c complyCustomSettings = 
            Apttus__ComplySystemProperties__c.getValues('System Properties');

        string supportEmailAddress = complyCustomSettings.APTPS_CALMs_Support_Email_Address__c; 
        String[] addlToAddresses = null;
        if (supportEmailAddress != null && supportEmailAddress != '') {
                    addlToAddresses = supportEmailAddress.split(';');
                }
        if(addlToAddresses != null && addlToAddresses.size() > 0)
        {
            for(string addrs : addlToAddresses)
            {
                toAddresses.add(addrs);
            }
        }

        // String[] toAddresses = new String[] {}; 
        // Assign the addresses for the To lists to the mail object.
        mail.setToAddresses(toAddresses);


        // Specify the address used when the recipients reply to the email. 
        //mail.setReplyTo('support@acme.com');

        // Specify the name used as the display name.
        mail.setSenderDisplayName('Salesforce Support');

        // Specify the subject line for your email address.
        mail.setSubject('PA CSV upload warnings for Agreement: ' + parentAgreement.Name);



        // Specify the text content of the email. Apttus__FF_Agreement_Number__c

        APTPS_AgreementSelection selectedAgreement = null;


        string mailBody = 'Dear ' + Userinfo.getName();

        //These agreements are successfully activated
        integer warningNumber = 1;
        if(warningMessagesToBeMailed.size() > 0)
        {
            mailBody = mailBody + ',<br/><br/><br/> The following tags do not match in PA CSV Pricing Approval Map for Agreement: '
                + parentAgreement.Apttus__FF_Agreement_Number__c + ': <br/><br/>';

            for(string warningMessage : warningMessagesToBeMailed)
            {
               mailBody = mailBody + warningNumber + '. ' + warningMessage +'<br/>';
               warningNumber++;
            }

            mailBody = mailBody + '<br/>' + 'Please contact the System Administrator to resolve this warning(s).';
        }


        mail.setHtmlBody(mailBody);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });


    }
    private boolean checkEmptyRow(string[] csvRecordData)
    {
        boolean isEmptyRecord = false;
        
        if(string.isEmpty(csvRecordData[0].trim()) && string.isEmpty(csvRecordData[1].trim()) && string.isEmpty(csvRecordData[2].trim()) 
           && string.isEmpty(csvRecordData[3].trim()) && string.isEmpty(csvRecordData[4].trim()) && string.isEmpty(csvRecordData[5].trim()) 
           && string.isEmpty(csvRecordData[6].trim()) && string.isEmpty(csvRecordData[7].trim()) && string.isEmpty(csvRecordData[8].trim()))           
        {
            isEmptyRecord = true;
        }
        
        return isEmptyRecord;
    }
    
    
     /*************************************************************************************************************************
    @Name: populateHeadTerms
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method is used to set the fields of headterms (Parent Agreement)
    *************************************************************************************************************************/
     private void populateHeadTerms(string tagName, string value, string fieldType)
    {        
        //The below section is hard coding to perform validations and certain operation where
        //the tags cannot be mapped to a single field of agreement 
         
        //Hard coding section starts
        if(tagName == 'Cust_CIDN')
        {
            errorFound = !validateCustomerCIDN(value);
            return;
        }
        
        if(tagName == 'Related_Companies_additional')
        {
           if(value == 'Yes')
           {
               headTerms.APTPS_Agreement_Subcategory__c = 'Company Group';
              // update headTerms;
           }
           else if(value == 'No')
           {
               headTerms.APTPS_Agreement_Subcategory__c = 'Single Customer';
              // update headTerms;
           }
            return;
        }
         
        if(tagName == 'Rltd_Com_Fran_Agr')
        {
           if(value == 'Yes')
           {
               headTerms.Apttus__Agreement_Category__c = 'Franchisee';
               //update headTerms;
           }         
            return;
        }
        
        if(tagName == 'Rltd_Com_Asso_Agr')
        {
           if(value == 'Yes')
           {
               headTerms.Apttus__Agreement_Category__c = 'Association';
              // update headTerms;
           }         
            return;
        }
        //Hard coding ends
        
        
         //Getting the tag name from Map
        APTPS_Agreement_Pricing_Data_Map__c dataMaps = agreementPricingMap.get(tagName);
        
        //Show warning in case the tag is missing
        if(dataMaps == null)
        {
            showWarning = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'The tag ' + tagName + ' is not mapped.'));

warningMessagesToBeMailed.add('The tag ' + tagName + ' is not mapped.');
        }
        else
        {
            //Update the head terms field with values from CSv
            updateFieldData(dataMaps.Object_Name__c, dataMaps.APTPS_Field_Name__c, value, fieldType);     
        }
    }
    
     /*************************************************************************************************************************
    @Name: validateCustomerCIDN
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method is used to validate the CIDN of Account in the CSV
    *************************************************************************************************************************/
    private boolean validateCustomerCIDN(string value)
    {
        Account[] agreementAccounts  = [select Id, Name, CIDN__c from Account where CIDN__c =: value ];
        if(agreementAccounts.isEmpty())        
        {
            string messageText = 'The CIDN do not match for Account ';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, messageText));
            
            return false;
        }
        return true;
    }
    
    /*************************************************************************************************************************
    @Name: updateFieldData
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method is used to populate the fields of sObject with value from CSV
    *************************************************************************************************************************/
   
    private void updateFieldData(string objectName, string strFieldNames, string value, string fieldType) {        
      SObjectType strObjectType = Schema.getGlobalDescribe().get(objectName);
        //Map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.Apttus__APTS_Agreement__c.fields.getMap();
      Map<String,Schema.SObjectField> fieldMap = strObjectType.getDescribe().fields.getMap();
        
        //Update Head Terms field
        if(objectName == 'Apttus__APTS_Agreement__c')
        {
            if(fieldMap.get(strFieldNames) != null)
            {

                if(fieldType == 'Decimal')
                {
                    if(String.isBlank(value))
                    {
                        headTerms.put(strFieldNames, 0);
                    }
                    else
                    {
                        headTerms.put(strFieldNames, Decimal.valueOf(value));
                    }
                }

                if(fieldType == 'Integer')
                {
                    if(String.isBlank(value))
                    {
                        headTerms.put(strFieldNames, 0);
                    }
                    else
                    {
                       headTerms.put(strFieldNames, Integer.valueOf(value));
                    }
                    
                }

                if(fieldType == 'Date')
                {
                  headTerms.put(strFieldNames, APTPS_CommonUtilities.setStringToDateFormat(value));  
                }                  

                if(fieldType == 'Text')
                {
                    Schema.DisplayType fielddataType = fieldMap.get(strFieldNames).getDescribe().getType();

                    if(fielddataType == Schema.DisplayType.Boolean)
                    {
                        if(value == 'Yes')
                        {
                            headTerms.put(strFieldNames, True);
                        }
                        else if(value == 'No')
                        {
                            headTerms.put(strFieldNames, False);
                        }
                    }
                    else
                    {
                        if(value.contains('_'))
                        {
                           value =  value.replace('_',', ');
                        }
                        headTerms.put(strFieldNames, value);
                    }
                }
            }
            //update headTerms;
        }
        
        
        //Update Agreement Line Items field
        
        if(objectName == 'Apttus__AgreementLineItem__c')
        {
            if(fieldMap.get(strFieldNames) != null)
            {

                if(fieldType == 'Decimal')
                {
                    if(String.isBlank(value))
                    {
                        productAgreementLineItem.put(strFieldNames, 0);
                    }
                    else
                    {
                        productAgreementLineItem.put(strFieldNames, Decimal.valueOf(value));
                    }
                    
                }

                if(fieldType == 'Integer')
                {
                    if(String.isBlank(value))
                    {
                        productAgreementLineItem.put(strFieldNames, 0);
                    }
                    else
                    {
                        productAgreementLineItem.put(strFieldNames, Integer.valueOf(value));
                    }
                }

                if(fieldType == 'Date')
                {
                  productAgreementLineItem.put(strFieldNames, APTPS_CommonUtilities.setStringToDateFormat(value));  
                }                  

                if(fieldType == 'Text')
                {
                    Schema.DisplayType fielddataType = fieldMap.get(strFieldNames).getDescribe().getType();

                    if(fielddataType == Schema.DisplayType.Boolean)
                    {
                        if(value == 'Yes')
                        {
                            productAgreementLineItem.put(strFieldNames, True);
                        }
                        else if(value == 'No')
                        {
                            productAgreementLineItem.put(strFieldNames, False);
                        }
                    }
                    else
                    {
                        if(value.contains('_'))
                        {
                           value =  value.replace('_',', ');
                        }
                        productAgreementLineItem.put(strFieldNames, value);
                    }
                }
            }
            //update productAgreementLineItem;
        }
  }
    
    
    /*************************************************************************************************************************
    @Name: populateSchedulesData
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method is used to create/update schedules (child Agreement), Agreement line items and components
    *************************************************************************************************************************/
    private void populateSchedulesData(string product, string tagName, string translatesToField, string value, string fieldType, string billingCode)
    {
        APTPS_Agreement_Pricing_Data_Map__c dataMaps = agreementPricingMap.get(tagName);
        
        Double value11 = 33;

        //Show warning if the tag is not in the Agreement Pricing Data Map
        if(dataMaps == null)
        {
            showWarning = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'The tag ' + tagName + ' is not mapped.'));   
warningMessagesToBeMailed.add('The tag ' + tagName + ' is not mapped.');
            return;
        }
        
        //This block will help in case the previous row was for the same product.
      if(product == productUsed)
        {
            //If the product does not exist in map ignore further processing
            if(missingProduct)
            {
                return;
            }
         
          //Insert component
          if(fieldType == 'Pricelist')
          {
                updatePriceList(value);
          }
            else
            {
                insertComponent(productAgreementLineItem.Id, tagName, translatesToField,value, allProducts.get(product.trim().toUpperCase())) ;

                //Insert/Update Billing codes
                if(billingCode != null && billingCode.trim().length() > 0)
                {
                    updateBillingCode(billingCode);
                }
                
                if(product == 'Wireless M2M Control Centre')
                {
                    updateScheduleFieldsForWirelessM2MControlCentre(translatesToField);
                    updateScheduleFieldsForWirelessM2MControlCentreByTag(tagName);
                }
                //Start: Added by Manthan Shah for Apttus Case #216341
         
                List<APTS_Tags_For_Minimum_SIO_Field__c> tags = APTS_Tags_For_Minimum_SIO_Field__c.getall().values();
                List<String> lstTags = tags[0].List_of_tags__c.split(',');
                Set<String> stTags = new Set<String>(lstTags);

                if(stTags.contains(tagName))
                {
                    productSchedule.APTPS_Minimum_Number_of_SIOs__c= Double.ValueOf(value.trim());

                    System.debug('**5-->'+billingCode+'*'+value);
                }
                //End: Added by Manthan Shah for Apttus Case #216341
            }
        }
        else
        {
           
             //if the product is missing in the map show warning
             if(allProducts.get(product.trim().toUpperCase()) == null)
             {
                missingProduct = true;
                productUsed = product;
                
                showWarning = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'The product ' + product + ' is not mapped.'));
warningMessagesToBeMailed.add('The product ' + product + ' is not mapped.');
                return;
             }
            
            
            
             //Resetting all fields for new product
            //Create/Update schedule and agreement line item data
            
            missingProduct = false;
            productUsed = product;
            productAgreementLineItem = null;
            productSchedule = null;
            
            //Get the Agreement Line item
            //productAgreementLineItem = getAgreementLineItem(allProducts.get(product.trim().toUpperCase()));
            productAgreementLineItem = getAgreementLineItem(dataMaps);
            
            //Start: Added by Manthan Shah for Apttus Case #216341
            List<APTS_Tags_For_Minimum_SIO_Field__c> tags = APTS_Tags_For_Minimum_SIO_Field__c.getall().values();
            List<String> lstTags = tags[0].List_of_tags__c.split(',');
            Set<String> stTags = new Set<String>(lstTags);

            if(stTags.contains(tagName))
            {
                productSchedule.APTPS_Minimum_Number_of_SIOs__c= Double.ValueOf(value.trim());

                System.debug('**5-->'+billingCode+'*'+value);
            }
            //End: Added by Manthan Shah for Apttus Case #216341

            if(errorFound || errorActivatedSchedulesFound)
                {
                    displayError =true;
                    return ;
                }
            //Sachin
            //If agreement line Item record is not returned. Show Warning
            if(productAgreementLineItem == null)
            {
                missingProduct = true;
                
                
                if(errorActivatedSchedulesFound)
                {
                    return;
                }   
                
                showWarning = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'The product ' + product + ' is not mapped.'));
warningMessagesToBeMailed.add('The product ' + product + ' is not mapped.');
                return;
            }
            
            
            if(fieldType == 'Pricelist')
          {
                updatePriceList(value);
          }
            else
            {
                System.debug('22**-->'+tagName+'**'+billingCode);
                insertComponent(productAgreementLineItem.Id, tagName, translatesToField,value, allProducts.get(product.trim().toUpperCase())) ;

                //Insert/Update Billing codes
                if(billingCode != null && billingCode.trim().length() > 0)
                {
                    updateBillingCode(billingCode);
                }
                
                if(product == 'Wireless M2M Control Centre')
                {
                    updateScheduleFieldsForWirelessM2MControlCentre(translatesToField);
                    updateScheduleFieldsForWirelessM2MControlCentreByTag(tagName);
                }
            }
          
            
        }
    }
    
     /*************************************************************************************************************************
    @Name: populateMinimuSpendData
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method is used to update Minimum Spend data
    *************************************************************************************************************************/
    private void populateMinimuSpendData(string product, string tagName, string value, string fieldType)
    {
       APTPS_Agreement_Pricing_Data_Map__c dataMaps = agreementPricingMap.get(tagName);
        
        //Sachin
            if(errorFound || errorActivatedSchedulesFound)
                {
                    displayError =true;
                    return ;
                }
        //Sachin
        //Show warning if the tag is not in the Agreement Pricing Data Map
        if(dataMaps == null)
        {
            showWarning = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'The tag ' + tagName + ' is not mapped.'));   
            warningMessagesToBeMailed.add('The tag ' + tagName + ' is not mapped.');
            return;
        }
        
        
        if(product == productUsed)
        {
            //If the product does not exist in map ignore further processing
            if(missingProduct)
            {
                return;
            }
         //Updating Minimum Spend
           updateFieldData(dataMaps.Object_Name__c, dataMaps.APTPS_Field_Name__c, value, fieldType);
        }
        else
        {
            
            if(allProducts.get(product.trim().toUpperCase()) == null)
             {
                missingProduct = true;
                productUsed = product;
                showWarning = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'The product ' + product + ' is not mapped.'));
                warningMessagesToBeMailed.add('The product ' + product + ' is not mapped.');
                return;
             }
            //Resetting all fields for new product
            //Create/Update schedule and agreement line item data
            //This variable will determine if the product is missing from mapping
            missingProduct = false;
            productUsed = product;
            productAgreementLineItem = null;
            productSchedule = null;
            
            
            productAgreementLineItem = getAgreementLineItem(dataMaps);
            
            if(productAgreementLineItem == null)
            {
                missingProduct = true;
                
                if(errorActivatedSchedulesFound)
                {
                    return;
                }   
                
                showWarning = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'The product ' + product + ' is not mapped.'));
                warningMessagesToBeMailed.add('The product ' + product + ' is not mapped.');
                return;
            }            
         
            //Updating Minimum Spend
            updateFieldData(dataMaps.Object_Name__c, dataMaps.APTPS_Field_Name__c, value, fieldType);
           
         
               
        }
    }
    
    
    
    private void updateScheduleFieldsForWirelessM2MControlCentre(string transaltesToField)
    {
        if(transaltesToField.contains('Data+ Plan') && !transaltesToField.contains('Group Data+ Plan'))
        {
            productSchedule.APTPS_Data_PLUS_Plans__c = true;
        }
        else if(transaltesToField.contains('Group Data+ Plan'))
        {
           productSchedule.APTPS_Group_Data_PLUS_Plans__c = true;
        }
        else if(transaltesToField.contains('Data Plan')  && !transaltesToField.contains('Group Data Plan'))
        {
            productSchedule.APTPS_Data_Plans__c = true;
        }
        else if(transaltesToField.contains('Group Data Plan'))
        {
           productSchedule.APTPS_Group_Data_Plans__c = true;
        }   
        
      
    }
    
    private void updateScheduleFieldsForWirelessM2MControlCentreByTag(string tag)
    {
        if(tag.contains('L_S_AYCE') || tag.contains('L_S_PAYG'))
        {
            productSchedule.APTPS_Location_Services__c = true;
        }
        else if(tag.contains('Dir_Cust'))
        {
            productSchedule.APTPS_Direct_customer__c = true;
        }
        else if(tag.contains('VAR')  && !tag.contains('MVAR'))
        {
           productSchedule.APTPS_Value_Added_Reseller__c = true;
        }
        else if(tag.contains('MVAR'))
        {
            productSchedule.APTPS_Master_Value_Added_Reseller__c = true;
        }   
        
      
    }
      /*************************************************************************************************************************
    @Name: getAgreementLineItem
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method returns the Agreement Line Item Record for a product Id. 
    *************************************************************************************************************************/
    private Apttus__AgreementLineItem__c getAgreementLineItem(APTPS_Agreement_Pricing_Data_Map__c dataMap)
    {
        //Get the schedule data
        Apttus__APTS_Agreement__c schedule = getSchedule(dataMap);
        
        //If the schedule does not exist return null. And it will be handled in the calling method to display warning
        if(schedule == null || errorActivatedSchedulesFound)
        {
            return null;
        }        
        
       Id productId = dataMap.APTPS_Product__c;
       productSchedule = schedule;
        
        Apttus__AgreementLineItem__c lineItem  = agreementLineItemsForUpsert.get(productId);
        
        //If the Line Item does not exist create a new record and add to Map for further processing
        if(lineItem == null)
        {   
            lineItem = new Apttus__AgreementLineItem__c();            
            lineItem.Apttus__ProductId__c = productId;
            agreementLineItemsForUpsert.put(productId, lineItem);            
            return lineItem;
        }
        else
        {
            agreementLineItemsForUpsert.remove(productId);
            lineItem.APTPS_Billings_Codes__c = null;
            agreementLineItemsForUpsert.put(productId, lineItem);  
                      
            return lineItem;
        }
        return null;
    }
    
    
       /*************************************************************************************************************************
    @Name: getSchedule
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method returns the Agreement Record for a product Id. 
    *************************************************************************************************************************/
    private Apttus__APTS_Agreement__c getSchedule(APTPS_Agreement_Pricing_Data_Map__c dataMap)
    {  
        //Check whether schedule exists for Agreement Sub Category and sub type
       //APTPS_Agreement_Pricing_Data_Map__c agreementMap  = agreementPricingMap.get(productId);       
        Apttus__APTS_Agreement__c existingSchedules  = agreementsForUpsert.get(dataMap.APTPS_Product_Family__c.trim().toUpperCase() 
                                                                               + '_' + dataMap.Related_Service_Schedule__c.trim().toUpperCase());

	//Start: Added by Manthan Shah for Apttus Case #00220130
        if(existingSchedules!= null && inprocessSchedules.containsKey(existingSchedules.Id))
         {
            List<Apttus__AgreementLineItem__c> lis = [Select ID,Apttus__ProductId__c from Apttus__AgreementLineItem__c where Apttus__AgreementId__c =: existingSchedules.Id];

            for(Apttus__AgreementLineItem__c li : lis)
            {
                agreementLineItemsForUpsert.remove(li.Apttus__ProductId__c);
                delete li ;
            }
         }
         
         //Start: Added by Manthan Shah for Apttus Case #00220130

        List<Apttus__APTS_Agreement__c> presentAgrs = [select Id, Apttus__Status__c, Apttus__Status_Category__c  from Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c =: parentAgreement.Id];

        for(Apttus__APTS_Agreement__c agr: presentAgrs)
        {
            if(((agr.Apttus__Status_Category__c == APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS || agr.Apttus__Status_Category__c == APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY) 
                        && ( agr.Apttus__Status__c == APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS ||  agr.Apttus__Status__c == APTPS_Constants.IN_AUTHOR_CONTRACT_STATUS)) || (agr.Apttus__Status__c == APTPS_Constants.INAMENDMENT_STATUS))
                {
                        inprocessSchedules.put(agr.Id,agr);
                }
            
        }

      



        //Create a new schedule record if schedule does not exists
        if(existingSchedules == null)
        {
            Apttus__APTS_Agreement__c schedule = new Apttus__APTS_Agreement__c();
            schedule.Apttus__Parent_Agreement__c = parentAgreement.Id ;
            schedule.Apttus__Account__c = parentAgreement.Apttus__Account__c;
            schedule.Apttus__Term_Months__c = parentAgreement.Apttus__Term_Months__c;
            schedule.APTPS_Customer_Primary_Contact__c = parentAgreement.APTPS_Customer_Primary_Contact__c;
            schedule.RecordTypeId = scheduleRecordTypeId;
            schedule.Apttus__Agreement_Category__c = 'Carriage';
            schedule.APTPS_Agreement_Subcategory__c = dataMap.APTPS_Product_Family__c;
            schedule.Apttus__Subtype__c = dataMap.Related_Service_Schedule__c;
            agreementsForUpsert.put(schedule.APTPS_Agreement_Subcategory__c.trim().toUpperCase() + '_' + schedule.Apttus__Subtype__c.trim().toUpperCase(), schedule);           
            return schedule;
        }
        else
        {
            if(activatedSchedules.containsKey(existingSchedules.Id))
            {
                string errorMessageText = 'You are trying to update an activated record (' + existingSchedules.Name + '). Please create the variation of this Schedule before importing the csv. You can not update schedule which is pending for approval';
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessageText));
                
                errorActivatedSchedulesFound = true;
                return null;
            }
            //Start: Added by Manthan Shah for Apttus Case #00220130
            else if(terminatedSchedules.containsKey(existingSchedules.Id))
            {
                return null;
            }
            return existingSchedules;
        }
        return null;
    }
    
    /*************************************************************************************************************************
    @Name: updatePriceList
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method inserts/ updates the billing code for agreement line item
    *************************************************************************************************************************/
    private void updatePriceList(string priceList)
    {
       string insertedPriceList = productAgreementLineItem.APTPS_Price_List__c;
        
        priceList = priceList.trim();
         
        
        if(insertedPriceList != null && insertedPriceList.length() > 0)
        {
            insertedPriceList = insertedPriceList + ', ' + priceList;
        }
        else
        {
            insertedPriceList = priceList;
        }
        
        productAgreementLineItem.APTPS_Price_List__c = insertedPriceList;
       // update productAgreementLineItem;
    }
    
    /*************************************************************************************************************************
    @Name: updateBillingCode
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method inserts/ updates the billing code for agreement line item
    *************************************************************************************************************************/
    private void updateBillingCode(string billingCode)
    {
       string insertedBillingCode = productAgreementLineItem.APTPS_Billings_Codes__c;
        
        billingCode = billingCode.trim();
         if(billingCode.contains(';'))
         {
             billingCode =  billingCode.replace(';',', ');
         }
        
        
        if(insertedBillingCode != null && insertedBillingCode.length() > 0)
        {
            insertedBillingCode = insertedBillingCode + ', ' + billingCode;
        }
        else
        {
            insertedBillingCode = billingCode;
        }
        
        productAgreementLineItem.APTPS_Billings_Codes__c = insertedBillingCode;
       // update productAgreementLineItem;
    }
    
    
    /*************************************************************************************************************************
    @Name: insertComponent
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method inserts components  for agreement line item
    *************************************************************************************************************************/
    private void insertComponent(Id lineItemId, string tagName, string componentName, string value, Id productId)
    {
        APTPS_Component__c component = null;
        System.debug('Shishir lineItemId:' + lineItemId);
        System.debug('Shishir tagName:' + tagName);
        if(lineItemId != null)
        {
            if(agreementLineItemsComponents.get(lineItemId) != null)
            {
                Map<string, APTPS_Component__c> tempComponents = new Map<string, APTPS_Component__c>();
                
                tempComponents = agreementLineItemsComponents.get(lineItemId);
                
                if(tempComponents.get(tagName) != null)
                {
                    component = tempComponents.get(tagName);
                    System.debug('Shishir component:' + component);
                }
            }
        }   
        
            
        if(component == null)
        {
            
            component = new APTPS_Component__c();
            if(lineItemId != null)  
            {
                component.Agreement_Line_Item__c = productAgreementLineItem.Id;
            }
            component.Tag__c = tagName;
            System.debug('Shishir component == null:' + component);
        }
        
        component.APTPS_Attribute__c = componentName;
        component.APTPS_Product_Id_For_Upsert__c = productId;
         if(value.contains('_'))
         {
             value =  value.replace('_',', ');
         }
        component.Value__c = value;
        componentsToBeUpserted.add(component);
        System.debug('Shishir componentsToBeUpserted:' + componentsToBeUpserted);
        
    }
    
    /*************************************************************************************************************************
    @Name: updateFundsData
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method is used to insert/ update the funds data
    *************************************************************************************************************************/
    private void updateFundsData()
    {
        string pcmsCode;
        List<Fund_Product__c> fundProducts = new List<Fund_Product__c>();
        List<Fund__c> fundsToBeUpserted = new List<Fund__c>();
        
       
         //Upserting funds data
        for(Fund__c fnd : headTermsFunds.values())
        {
        fundsToBeUpserted.add(fnd);
            
        }
         upsert fundsToBeUpserted;
        
        
        //Creating map that will help to associate Funds to Product Funds
        headTermsFunds = new Map<Id, Fund__c>();
        for(Fund__c fnd : fundsToBeUpserted)
        {
            headTermsFunds.put(fnd.recordTypeId, fnd);
        }
        
        //For Different type of funds updating the PCMS code and Fund Id
        
        for(Fund_Product__c fndProduct : fundProductsForEachProductGROWTH.values())
        {
            pcmsCode = null;
            pcmsCode = productPCMSCodeMapping.get(fndProduct.Product__c);
            if(fndProduct.Fund__c == null)
            {
                fndProduct.Fund__c = headTermsFunds.get(fundsRecordType.get('Growth')).Id;
            }
            
            if(pcmsCode != null)
            {
               fndProduct.APTPS_PCMS_Code__c = pcmsCode;
            }
            
            fundProducts.add(fndProduct);
            
        }
        
        for(Fund_Product__c fndProduct : fundProductsForEachProductLOYALTY.values())
        {
            pcmsCode = null;
            pcmsCode = productPCMSCodeMapping.get(fndProduct.Product__c);
            
            if(fndProduct.Fund__c == null)
            {
            fndProduct.Fund__c = headTermsFunds.get(fundsRecordType.get('Other')).Id;
            }
            
            
            if(pcmsCode != null)
            {
               fndProduct.APTPS_PCMS_Code__c = pcmsCode;
            }
            
            fundProducts.add(fndProduct);
        }
        
        for(Fund_Product__c fndProduct : fundProductsForEachProductMBRS.values())
        {
            pcmsCode = null;
            pcmsCode = productPCMSCodeMapping.get(fndProduct.Product__c);
            
            if(fndProduct.Fund__c == null)
            {
            fndProduct.Fund__c = headTermsFunds.get(fundsRecordType.get('MBRS')).Id;
            }
            
            
            if(pcmsCode != null)
            {
               fndProduct.APTPS_PCMS_Code__c = pcmsCode;
            }
            
            fundProducts.add(fndProduct);
        }
        
        
        for(Fund_Product__c fndProduct : fundProductsForEachProductMOTIF.values())
        {
            pcmsCode = null;
            
            if(fndProduct.Fund__c == null)
            {
            fndProduct.Fund__c = headTermsFunds.get(fundsRecordType.get('MOTIF')).Id;
            }
            
            
            pcmsCode = productPCMSCodeMapping.get(fndProduct.Product__c);
            if(pcmsCode != null)
            {
               fndProduct.APTPS_PCMS_Code__c = pcmsCode;
            }
            
            fundProducts.add(fndProduct);
        }
        
        for(Fund_Product__c fndProduct : fundProductsForEachProductTIF.values())
        {
            pcmsCode = null;
            
            if(fndProduct.Fund__c == null)
            {
            fndProduct.Fund__c = headTermsFunds.get(fundsRecordType.get('TIF')).Id;
            }
            
            
            pcmsCode = productPCMSCodeMapping.get(fndProduct.Product__c);
            if(pcmsCode != null)
            {
               fndProduct.APTPS_PCMS_Code__c = pcmsCode;
            }
            
            fundProducts.add(fndProduct);
        }
        
       
        upsert fundProducts;
    }
    
    /*************************************************************************************************************************
    @Name: updateFundsData
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method is used to crete funds and fund products records
    *************************************************************************************************************************/
    private void populateFundsData(string product, string tagName, string value, string fieldType)
    {
        APTPS_Agreement_Pricing_Data_Map__c dataMaps = agreementPricingMap.get(tagName);
        Fund__c fundHeadTerms = null;
        
        //Show warning if tag does not exists in Mapping
        if(dataMaps == null)
        {
            showWarning = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 'The tag ' + tagName + ' is not mapped.'));  
            warningMessagesToBeMailed.add('The tag ' + tagName + ' is not mapped.');
            return;
        }
        
        if(tagName.contains('PCMS'))
        {
            productPCMSCodeMapping.put(dataMaps.APTPS_Product__c, value);
            return;
        }
        
     
        string upperCaseTagName = dataMaps.APTPS_Fund_Type__c.toUpperCase();
        
      Id fundRecordTypeId = null;
        
        //Update/ Insert Maps for fund products of different fund type
        if(upperCaseTagName.contains('GROWTH'))
        {
            fundRecordTypeId = fundsRecordType.get('Growth');
            fundHeadTerms = getFundHeadTerms(fundRecordTypeId);
            
            if(dataMaps.Object_Name__c == 'Fund__c')
            {
                updateFundHeadTerms(fundRecordTypeId, dataMaps.APTPS_Field_Name__c, value, fieldType);
            }
            else
            {
                fundProductsForEachProductGROWTH = updateFundsMaps(fundProductsForEachProductGROWTH, dataMaps.APTPS_Product__c, dataMaps.APTPS_Field_Name__c, value);            
            }
        }
        
        if(upperCaseTagName.contains('OTHER'))
        {
            fundRecordTypeId = fundsRecordType.get('Other');
            fundHeadTerms = getFundHeadTerms(fundRecordTypeId);
            
            if(dataMaps.Object_Name__c == 'Fund__c')
            {
                updateFundHeadTerms(fundRecordTypeId, dataMaps.APTPS_Field_Name__c, value, fieldType);
            }
            else
            {
                fundProductsForEachProductLOYALTY = updateFundsMaps(fundProductsForEachProductLOYALTY, dataMaps.APTPS_Product__c, dataMaps.APTPS_Field_Name__c, value);          
            }
                
        }
        
        
        if(upperCaseTagName.contains('MBRS'))
        {
            fundRecordTypeId = fundsRecordType.get('MBRS');
            fundHeadTerms = getFundHeadTerms(fundRecordTypeId);
            
            if(dataMaps.Object_Name__c == 'Fund__c')
            {
                updateFundHeadTerms(fundRecordTypeId, dataMaps.APTPS_Field_Name__c, value, fieldType);
            }
            else
            {
                fundProductsForEachProductMBRS = updateFundsMaps(fundProductsForEachProductMBRS, dataMaps.APTPS_Product__c, dataMaps.APTPS_Field_Name__c, value);          
            }
            
            
        }
        
        if(upperCaseTagName.contains('MOTIF'))
        {
            fundRecordTypeId = fundsRecordType.get('MOTIF');
            fundHeadTerms = getFundHeadTerms(fundRecordTypeId);
            
            if(dataMaps.Object_Name__c == 'Fund__c')
            {
                updateFundHeadTerms(fundRecordTypeId, dataMaps.APTPS_Field_Name__c, value, fieldType);
            }
            else
            {
                fundProductsForEachProductMOTIF = updateFundsMaps(fundProductsForEachProductMOTIF, dataMaps.APTPS_Product__c, dataMaps.APTPS_Field_Name__c, value);            
            }
            
        }
        
        if(upperCaseTagName.contains('TIF') && !upperCaseTagName.contains('MOTIF'))
        {
            fundRecordTypeId = fundsRecordType.get('TIF');
            fundHeadTerms = getFundHeadTerms(fundRecordTypeId);
            
            if(dataMaps.Object_Name__c == 'Fund__c')
            {
                updateFundHeadTerms(fundRecordTypeId, dataMaps.APTPS_Field_Name__c, value, fieldType);
            }
            else
            {
                fundProductsForEachProductTIF = updateFundsMaps(fundProductsForEachProductTIF, dataMaps.APTPS_Product__c, dataMaps.APTPS_Field_Name__c, value);         
            }
            
        }
       
    }
    
     /*************************************************************************************************************************
    @Name: updateFundsMaps
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method is used to update the fundproduct maps for different type of funds
    *************************************************************************************************************************/
     private Map<Id,Fund_Product__c> updateFundsMaps(Map<Id,Fund_Product__c> fundMap, Id productId, string fieldName, string value) 
     {      
        fundProduct = null;
       fundProduct = fundMap.get(productId);
       
         
         if(fundProduct == null)
         {
             fundProduct = new Fund_Product__c();
             fundProduct.Product__c = productId;
             
             updateFundsField(fieldName, value);                
             fundMap.put(productId, fundProduct);

         }
         else
         {
             updateFundsField(fieldName, value);
             fundMap.remove(productId);
             fundMap.put(productId, fundProduct);
         }
      
        return fundMap;
   }
    
    private void updateFundsField(string strFieldNames, string value) {        
        Map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.Fund_Product__c.fields.getMap();
      
         if(fieldMap.get(strFieldNames) != null)
        {
           if(String.isBlank(value))
           {
               fundProduct.put(strFieldNames, 0);  
           }
           else
           {
                fundProduct.put(strFieldNames, Decimal.valueOf(value));       
           }
        }
  }
    
      /*************************************************************************************************************************
    @Name: getFundHeadTerms
    @Author: Shishir Bose
    @Created Date: 07/01/2016
    @Descripton: This method is used to get the Funds record of the Agreement (Head Terms)
    *************************************************************************************************************************/
    private Fund__c getFundHeadTerms(Id fundRecordTypeId)
    {
        Fund__c headtermFund = headTermsFunds.get(fundRecordTypeId);
        
        //If the fund record do not exist create a new record 
        if(headtermFund != null)
        {
            return headtermFund;
        }
        
        headtermFund = new Fund__c();
        headtermFund.Name = 'name';
        headtermFund.Agreement__c = parentAgreement.Id;
        headtermFund.RecordTypeId = fundRecordTypeId;
        headTermsFunds.put(headtermFund.RecordTypeId,headtermFund);
        
        
        return headtermFund;
      
    }
    
      /*************************************************************************************************************************
    @Name: updateFundHeadTerms
    @Author: Shishir Bose
    @Created Date: 08/24/2016
    @Descripton: This method is used to update the funds object
    *************************************************************************************************************************/
    private void updateFundHeadTerms(Id fundRecordTypeId, string strFieldNames, string value, string fieldType)
    {
        Fund__c headtermFund = headTermsFunds.get(fundRecordTypeId);
        
        //If the fund record do not exist create a new record 
        if(headtermFund == null)
        {
            headtermFund = new Fund__c();
            headtermFund.Name = 'name';
            headtermFund.Agreement__c = parentAgreement.Id;
            headtermFund.RecordTypeId = fundRecordTypeId;
            headTermsFunds.put(headtermFund.RecordTypeId,headtermFund);
        }
        
        
        SObjectType strObjectType = Schema.getGlobalDescribe().get('Fund__c');
        //Map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.Apttus__APTS_Agreement__c.fields.getMap();
        Map<String,Schema.SObjectField> fieldMap = strObjectType.getDescribe().fields.getMap();
        
       if(fieldMap.get(strFieldNames) != null)
       {

           if(fieldType == 'Decimal')
           {
               if(String.isBlank(value))
               {
                   headtermFund.put(strFieldNames, 0);
               }
               else
               {
                   headtermFund.put(strFieldNames, Decimal.valueOf(value));
               }
           }

           if(fieldType == 'Integer')
           {
               if(String.isBlank(value))
               {
                   headtermFund.put(strFieldNames, 0);
               }
               else
               {
                   headtermFund.put(strFieldNames, Integer.valueOf(value));
               }

           }

           if(fieldType == 'Date')
           {
               headtermFund.put(strFieldNames, APTPS_CommonUtilities.setStringToDateFormat(value));  
           }                  

           if(fieldType == 'Text')
           {
               Schema.DisplayType fielddataType = fieldMap.get(strFieldNames).getDescribe().getType();

               if(fielddataType == Schema.DisplayType.Boolean)
               {
                   if(value == 'Yes')
                   {
                       headtermFund.put(strFieldNames, True);
                   }
                   else if(value == 'No')
                   {
                       headtermFund.put(strFieldNames, False);
                   }
               }
               else
               {
                   if(value.contains('_'))
                   {
                       value =  value.replace('_',', ');
                   }
                   headtermFund.put(strFieldNames, value);
               }
           }
       }
        
       
      
    }
    
    /*************************************************************************************************************************
    @Name: cancel
    @Author: Shishir Bose
    @Created Date: 04/28/2016
    @Descripton: This method is called on clicking cancel button on VF page and takes the user back on agreement page
    *************************************************************************************************************************/
    public PageReference cancel()
    {
        PageReference pageRef = new PageReference('/'+parentAgreement.Id);
        //pageRef.setredirect(true);
        
        return pageRef;
    }
    
    private void updatePricingSpecialist()
    {
        Profile[] pricingProfiles = null;
        pricingProfiles = [select Id, Name from Profile where Name = 'Telstra Pricing'];
        
        if(!pricingProfiles.isEmpty())
        {
            if(pricingProfiles[0].Id == UserInfo.getProfileId())
            {
              headTerms.APTPS_Pricing_Specialist__c = UserInfo.getUserId();
            }
        }
    }
}