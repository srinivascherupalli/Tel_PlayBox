/* 
* @Author : Rahul/Ritika 
* @Date : 5th May 2019
* @Desc : Custom Apex Connector for ExternalObject BasketSnapshot, for obtaining basket-lineItems to be displayed in quote/orderform
* @Jira : EDGE-66165, EDGE-66484
*/
 /***History of Updates
 * Ritika Jaiswal:  19/08/2019  EDGE-98246  For CMP services and devicesIOTServicesOC
 * Aniket Srivastava : 11/09/2019 Egde - 98374 - TC New Quote/Orderform 
 * Purushotama Sahu : EDGE-80783 - Get MDM Professional Service Details
 * Kiran Sattikar : 16/09/2019 EDGE-99894 - For DoP
 * Vijayalakshmi S : 28/09/2019 EDGE-99894 - For DOP
 * Vishal Arbune:   01/01/2020  EDGE-117967 : Capture POS redemption information in Quotes
 * Vishal Arbune:   10/01/2020  EDGE-114970 : Capturing redemption information in Order form for customer sign off 
 * Aniket S: 12/02/2020 EDGE-127780 : Quote changes for TID cancellation
 * Jayesh : 20/02/2020 DPG-1454: Added to retrieve ETC charges for IOT Cancellation Services
 * Vishal Arbune:   30/03/2020 : EDGE-121387 : Telstra Collaboration (Next Gen UC): EAP discounts to be displayed in the Quote and Order form documents(New Orders)
 * Vishal Arbune:   10/04/2020 : EDGE-133760 : Telstra Collaboration (Next Gen UC): EAP discounts to be displayed in the Quote and Order form documents(MAC Orders)


 * Ravi Shankar: Added changes for EDGE-173365
 * Rajashekar: Added changes for EDGE-175105
 * Suyash/lalit : Added changes for DPG-4421 and DPG-3919
 * Purushottam  : Added changes for EDGE-202822
 * Mahima G     : DPG-5624
 * Purushottam  : Added changes for EDGE-202822
 * Aruna Aware  : DIGI-1593 Offer Name change (Cloudsense) part-2, update Price schedule
 * Sharmila/Payel: Added changes for DIGI-929 and DIGI-930 recommit
 * Natasha Ambre: Added changes for DIGI-6139 & DIGI-6141
 * Natasha Ambre: Added changes for DIGI-22598 & DIGI-22599
 * Payel: Added changes for DIGI-13857 and DIGI-13858
 ***/ 
global with sharing class ProductBasketDataSourceConnection extends DataSource.Connection {
    global ProductBasketDataSourceConnection(){
    }   
    override global List<DataSource.Table> sync(){
        List<DataSource.Table> tables = new List<DataSource.Table>();
        List<DataSource.Column> columns = new List<DataSource.Column>();
        columns.add(DataSource.Column.text('Total_Once_Off', 255));
        columns.add(DataSource.Column.text('Total_Recurring_Charges',255));
        columns.add(DataSource.Column.text('Product_Module_Name', 255));
        columns.add(DataSource.Column.text('Site_Name',255));
        columns.add(DataSource.Column.text('Site_Address',255));
        columns.add(DataSource.Column.text('Quantity',255));
        columns.add(DataSource.Column.text('Type',255));
        columns.add(DataSource.Column.text('Recurring_Charges',255));
        columns.add(DataSource.Column.text('Once_Off',255));
        columns.add(DataSource.Column.text('Term', 255));
        //US-33959
        columns.add(DataSource.Column.text('GSTIncl_Total_Onceoff_Charges',255));
        columns.add(DataSource.Column.text('GSTIncl_Total_Recurring_Charges',255));
        columns.add(DataSource.Column.text('Response_time',255));
        columns.add(DataSource.Column.text('Restoration_time',255));
        columns.add(DataSource.Column.text('Serviceability_Location', 255));
        columns.add(DataSource.Column.lookup('Product_Basket', 'cscfga__Product_Basket__c'));
        columns.add(DataSource.Column.lookup('Product_Configuration', 'cscfga__Product_Configuration__c')); 
        columns.add(DataSource.Column.text('ExternalId', 255));
        columns.add(DataSource.Column.url('DisplayUrl'));   
        //US - 10811 
        columns.add(DataSource.Column.text('Commercial_Config',255));   
        /* JIRA -EDGE-25920 -Enhance external basket snapshot to ensure we capture metadata needed for contract generation : Maq*/
        columns.add(DataSource.Column.number('Total_Contract_Value', 16,2));
        columns.add(DataSource.Column.lookup('Account_Owner', 'User'));
        columns.add(DataSource.Column.lookup('Primary_contact', 'Contact')); 
        //Changes Start- EDGE-44968
        columns.add(DataSource.Column.text('Order_Type', 255)); 
        columns.add(DataSource.Column.text('Existing_Service', 255)); 
        columns.add(DataSource.Column.text('Query_Type', 255)); 
        //Changes End- EDGE-44968
        //Manoj : EDGE : 63432 : 05/Feb/2019 : Start
        columns.add(DataSource.Column.text('GSTIncl_TotalETC', 255));
        columns.add(DataSource.Column.text('GSTExcl_TotalETC', 255)); 
        //Manoj : EDGE : 63432 : 05/Feb/2019 : End
        //EDGE-88163 - Start
        columns.add(DataSource.Column.boolean('isCWP'));
        columns.add(DataSource.Column.boolean('isPPHH'));
        //EDGE-88163 - End
        //EDGE 105921 - start
        columns.add(DataSource.Column.boolean('isCommittedData'));
        // EDGE 105921 - end
        //EDGE-81548 - Start
        columns.add(DataSource.Column.boolean('isMDM'));
        //EDGE-12356 Start
        columns.add(DataSource.Column.boolean('isPSMDM'));
        columns.add(DataSource.Column.boolean('isMobilityManagedService'));
        columns.add(DataSource.Column.boolean('isPSTelstraCollaboration'));
        //EDGE-12356 End
        // RPL
        columns.add(DataSource.Column.boolean('is_TC'));
        //EDGE-81548 - End
        //EDGE-85582 - Start
        columns.add(DataSource.Column.text('Discount_Text', 255));
        //EDGE-85582 - End
        //EDGE-99894 - Start
        columns.add(DataSource.Column.boolean('isDOP'));
        //EDGE-99894 - End
        //changes for DPG-4421 and DPG-3919
        system.debug('before issdwan add');
        columns.add(DataSource.Column.boolean('isSDWAN'));
        //changes for DPG-4421 and DPG-3919 end
        //EDGE-98336 - Start
        columns.add(DataSource.Column.boolean('isTID'));
        //EDGE-98336 - End
        //EDGE-117967 : Capture POS redemption information in Quotes   
        columns.add(DataSource.Column.text('BasketRedeemAmtQuote', 255));
        columns.add(DataSource.Column.text('GSTInclBasketRedeemAmtQuote', 255));
       //EDGE-114970 : Capturing redemption information in Order form for customer sign off
        columns.add(DataSource.Column.boolean('isDOPRedeemable'));
        columns.add(DataSource.Column.boolean('isTCRedeemable'));
        //EDGE-117967 : Capture POS redemption information in Quotes   
        columns.add(DataSource.Column.text('BasketRedeemAmtQuote', 255));
        columns.add(DataSource.Column.text('GSTInclBasketRedeemAmtQuote', 255));
       //EDGE-114970 : Capturing redemption information in Order form for customer sign off
        columns.add(DataSource.Column.boolean('isDOPRedeemable'));
        columns.add(DataSource.Column.boolean('isTCRedeemable'));
           //EDGE-123788  Display Delegated Discounts in Quote Document
        columns.add(DataSource.Column.boolean('isPromotionsApplied'));
        columns.add(DataSource.Column.text('Discount_Template_Name', 255));
         columns.add(DataSource.Column.text('MonthlyRCPromotionsExclGST', 255));
        columns.add(DataSource.Column.text('MonthlyRCPromotionsInclGST', 255));
        //EDGE-117967 : Capture POS redemption information in Quotes   
        columns.add(DataSource.Column.text('BasketRedeemAmtQuote', 255));
        columns.add(DataSource.Column.text('GSTInclBasketRedeemAmtQuote', 255));
       //EDGE-114970 : Capturing redemption information in Order form for customer sign off
        columns.add(DataSource.Column.boolean('isDOPRedeemable'));
        columns.add(DataSource.Column.boolean('isTCRedeemable'));
           //EDGE-123788  Display Delegated Discounts in Quote Document
        columns.add(DataSource.Column.boolean('isPromotionsApplied'));
        columns.add(DataSource.Column.text('Discount_Template_Name', 255));
        //DPG-2317
        columns.add(DataSource.Column.boolean('IsAdaptiveCare'));
        columns.add(DataSource.Column.boolean('IsAdaptiveCare_Cancel'));
        columns.add(DataSource.Column.boolean('isMobilityManagedService_Cancel'));
    //EDGE-171311- deployed with DPG-5624 regression impact
        columns.add(DataSource.Column.boolean('isBsktInflight_Cancel'));
        
        columns.add(DataSource.Column.boolean('isAMMSLifecycleNew')); //DIGI-5562
         columns.add(DataSource.Column.boolean('isAMMSLifecycleCancel')); //DIGI-5562
         columns.add(DataSource.Column.boolean('isAMMS')); //DIGI-5562
         columns.add(DataSource.Column.boolean('isAMMSNew'));
         columns.add(DataSource.Column.boolean('isAMMSCancel')); //DIGI-5562
         columns.add(DataSource.Column.text('OCT_URL_WITH_TEXT', 255)); //DIGI-5562
         columns.add(DataSource.Column.text('OCT_URL_with_Service_Terms', 255)); //DIGI-5562
         columns.add(DataSource.Column.url('OCT_URL')); //DIGI-5562
         columns.add(DataSource.Column.boolean('isAMMSIntuneNew')); //DIGI 23858
         columns.add(DataSource.Column.boolean('isAMMSIntuneCancel')); //DIGI 23858

        tables.add(DataSource.Table.get('BasketSnapshot', 'Name', columns));
        return tables;
    }
    override global DataSource.TableResult query(DataSource.QueryContext context) {
        List<Map<String,Object>> rows = getRows(context);
        system.debug('valueofcontextinclass'+context);
        return DataSource.TableResult.get(context,rows);
    }
    // Helper method to get record values from the external system for the Sample table.
    private List<Map<String, Object>> getRows (DataSource.QueryContext context) {
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        String filterColumnName = '';
        String filterColumnValues = '';
        Map<String,String> subfilters = new Map<String,String>(); 
        if(context.tableSelection.filter!=null){
            System.debug('***Telstra:ProductBasketDataSourceConnection:Filters:'+context.tableSelection.filter);
            if(context.tableSelection.filter.subfilters!=null){
                List<DataSource.Filter> filter = context.tableSelection.filter.subfilters;
                filterColumnName = filter[0].columnName;
                System.debug('Filters col:'+filter[0].columnName);
                filterColumnValues = String.valueOf(filter[0].columnValue);
                //start EDGE-66165,66484 - refactoring covered
                for(DataSource.Filter sfilter:filter){
                    subfilters.put(sfilter.columnName, String.valueOf(sfilter.columnValue));    
                }
                System.debug('***Telstra:ProductBasketDataSourceConnection:Filter values:'+subfilters);    
            }else
            {
                DataSource.Filter filter = context.tableSelection.filter;
                filterColumnName = filter.columnName;
                filterColumnValues = String.valueOf(filter.columnValue);
            }
        }
        ProductBasketDataHandler dataHandler= new ProductBasketDataHandler();
        RF_ProductBasketDataHandler rfdataHandler= new RF_ProductBasketDataHandler(); //Refactored code
        NGEMDataHandler ngemHandler= new NGEMDataHandler();
        TCDataHandler tcHandler= new TCDataHandler();//EDGE-210438
        IoTDataHandler iotHandler = new IoTDataHandler();
        //changes for DPG-4421 and DPG-3919 start
        SDWANDataHandler sdwanHandler = new SDWANDataHandler();
        //changes for DIGI-6139 and DIGI-6141 by Natasha Ambre
        DMSDataHandler DMSHandler = new DMSDataHandler();
        //changes for DPG-4421 and DPG-3919 end
        DealQuoteDataHandler dealHandler = new DealQuoteDataHandler();

        TCDealQuoteDataHandler TCdealHandler = new TCDealQuoteDataHandler();
        IOTDealQuoteDataHandler IOTDealHandler = new IOTDealQuoteDataHandler();
        PORDataHandler PorHandler= new PORDataHandler();

        if(filterColumnName!=null && subfilters.get('Query_Type')=='SummaryForChangesToExisting'){
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getSummaryForChangesToExisting(filterColumnValues); else return rfdataHandler.getSummaryForChangesToExisting(filterColumnValues);//refactored code
        }
        else if(filterColumnName!=null && subfilters.get('Query_Type')=='SummaryForNewServices'){ //Changes Start - EDGE-41351
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getSummaryForNewServices(filterColumnValues); else return rfdataHandler.getSummaryForNewServices(filterColumnValues);//refactored code
        }    
        //Changes End - EDGE-41351                  
        else if (filterColumnName!=null && subfilters.get('Query_Type')=='Cancel'){
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getCancelTypeProducts(filterColumnValues); else return rfdataHandler.getCancelTypeProducts(filterColumnValues);
        }
        //Changes End - EDGE-78601                  
        else if (filterColumnName!=null && subfilters.get('Query_Type')=='CancelMobility'){
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getMobilityCancelTypeProducts(filterColumnValues); else return rfdataHandler.getMobilityCancelTypeProducts(filterColumnValues); //Refactored code
        }
        else if (filterColumnName != null && subfilters.get('Query_Type')=='MobilityProducts'){
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getMobilityTypeProducts(filterColumnValues,subfilters); else return rfdataHandler.getMobilityTypeProducts(filterColumnValues,subfilters);//Refactored code
        }
        //EDGE-88163 - Start | Desc: Get Parent Products for Minimum Commitment
        else if (filterColumnName != null && subfilters.get('Query_Type')=='ProductType'){
               return dataHandler.getParentProducts(filterColumnValues);
        }
        //EDGE-88163 - End
        //EDGE-81549 - Start
        else if (filterColumnName != null && subfilters.get('Query_Type')=='CMPDeviceDetails'){
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getCMPDevices(filterColumnValues, subfilters); else return rfdataHandler.getCMPDevices(filterColumnValues, subfilters); //Refactored code
        }
        //EDGE-188100 Added CMPServiceDetailsReact
        else if (filterColumnName != null && (subfilters.get('Query_Type')=='CMPServiceDetails' || subfilters.get('Query_Type')=='CMPServiceDetailsReact')){
            system.debug('subfilters' + subfilters);   
             if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getCMPServices(filterColumnValues,subfilters); else return rfdataHandler.getCMPServices(filterColumnValues,subfilters); //Refactored code
        }//EDGE-81549 - End
        
    // EDGE - 117738 End
        else if (filterColumnName != null && subfilters.get('Query_Type')=='CMPCancelDetails'){
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getCMPDevices(filterColumnValues, subfilters); else return rfdataHandler.getCMPDevices(filterColumnValues, subfilters); //Refactored code
        }
        /*//Start Egde - 98374
        else if (filterColumnName != null && subfilters.get('Query_Type')=='TCServiceDetails'){
            system.debug('subfilters' + subfilters);   
            return dataHandler.getTCServices(filterColumnValues,subfilters);
        }//End Edge - 98374*/
       //changes start for 99894
        else if (filterColumnName != null && subfilters.get('Query_Type')=='DOPServiceDetails'){
            system.debug('subfilters' + subfilters);
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getDOPServices(filterColumnValues,subfilters); else  return rfdataHandler.getDOPServices(filterColumnValues,subfilters);  //Refactored code
        }
        //changes end for 99894
        //EDGE-127780 Start
        else if (filterColumnName != null && subfilters.get('Query_Type')=='TIDCancel'){
            system.debug('EDGE-127783 & EDGE-127780 - Start TID Cancel - subfilters' + subfilters); 
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getTIDCancel(filterColumnValues,subfilters); else return rfdataHandler.getTIDCancel(filterColumnValues,subfilters); //Refactored code
        }//EDGE-127780 End
        //EDGE - 113930 Start
        /*else if (filterColumnName != null && subfilters.get('Query_Type')=='ngUCSLADetails'){
            system.debug('subfilters' + subfilters); 
            system.debug('Inside ngUCSLADetails');
            return dataHandler.ngUCSLADetails(filterColumnValues,subfilters); 
        } //EDGE - 113930 End*/
        //EDGE - 109389 Start
        else if (filterColumnName != null && subfilters.get('Query_Type')=='ngUCDevicesOCDetails'){
            system.debug('subfilters' + subfilters); 
            system.debug('Inside Device OC');
            return tcHandler.getngUCDevicesOC(filterColumnValues,subfilters);
        }
        /*else if (filterColumnName != null && subfilters.get('Query_Type')=='ngUCDevicesRCDetails'){
            system.debug('subfilters' + subfilters); 
            system.debug('Inside Device RC');
            return dataHandler.getngUCDevicesRC(filterColumnValues,subfilters);
        } 
        //EDGE - 109389 End*/
        //
        //EDGE-80783 - Start | Desc: Get MDM Professional Service Details
        else if (filterColumnName != null && subfilters.get('Query_Type')=='MDMProfServiceDetails'){
               system.debug('subfilters' + subfilters); 
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getMDMProfServices(filterColumnValues,subfilters); else return rfdataHandler.getMDMProfServices(filterColumnValues,subfilters);//Refactored code
        } 
        //EDGE-80783 - End
         //DPG-598 : Added to retrieve One off charges for IOT Services
        else if (filterColumnName != null && (subfilters.get('Query_Type')=='IOTServicesOC')){
               system.debug('subfilters' + subfilters); 
               //return dataHandler.getIOTServicesOC(filterColumnValues,subfilters);
               return iotHandler.getIOTServicesOC(filterColumnValues,subfilters);
        } 
    //DIGI-1593 - Offer Name change (Cloudsense) part-2, update Price schedule
        else if (filterColumnName != null && (subfilters.get('Query_Type')=='M2MServicesOC')){
            system.debug('subfilters' + subfilters); 
            //return dataHandler.getIOTServicesOC(filterColumnValues,subfilters);
            return iotHandler.getM2MServicesOC(filterColumnValues,subfilters);
        } 
        //DPG-1454 and DPG-1033: Added to retrieve ETC charges for IOT Cancellation Services 
        else if (filterColumnName != null && subfilters.get('Query_Type')=='IoTCancelServices'){
               system.debug('subfilters' + subfilters); 
               return iotHandler.getIoTCancelServices(filterColumnValues,subfilters);


        } 
        //changes DPG-4421 and DPG-3919 Start
        else if (filterColumnName != null && subfilters.get('Query_Type')=='SECUREEDGEServices'){
            system.debug('SECUREEDGEServices' + subfilters); 
            return sdwanHandler.getSDWANServicesSecureEdge(filterColumnValues,subfilters);
        }

        //changes DIGI-13858 and DIGI-13857 Start
        else if (filterColumnName != null && subfilters.get('Query_Type')=='SECUREEDGEModify'){
            system.debug('SECUREEDGEModify' + subfilters); 
            return sdwanHandler.getSDWANServicesSecureEdgeModify(filterColumnValues);
        }
        else if (filterColumnName != null && subfilters.get('Query_Type')=='SECUREEDGECancel'){
            system.debug('SECUREEDGECancel' + subfilters); 
            return sdwanHandler.getSDWANServicesSecureEdgeCancel(filterColumnValues);
        }
        
        else if (filterColumnName != null && (subfilters.get('Query_Type')=='SDWANServices')){
            system.debug('subfilters BSSDWANServices' + subfilters); 
            return sdwanHandler.getSDWANServices(filterColumnValues,subfilters);
        }
		 //changes DIGI-929 and DPG-930 Start recommit
    else if (filterColumnName != null && (subfilters.get('Query_Type')=='SDWANCancel')){
            system.debug('subfilters BSSDWANCancel' + subfilters); 
            return sdwanHandler.getSDWANCancelServices(filterColumnValues);
        }
        //changes DIGI-6139 and DIGI-6141 by Natasha Ambre
        
     else if (filterColumnName != null && subfilters.get('Query_Type')=='DMSServices'){
            system.debug('DMSServices' + subfilters); 
            return DMSHandler.getDMSServices(filterColumnValues,subfilters);
         }
         //Changes DIGI-22598 and DIGI-22599 by Natasha Ambre - DMS Cancel
     else if (filterColumnName != null && subfilters.get('Query_Type')=='DMSCancelServices'){
           system.debug('subfilters' + subfilters); 
            return DMSHandler.getDMSCancelServices(filterColumnValues,subfilters);
         }
        //changes for DPG-4421 and DPG-3919 end
          // EDGE-101077 - Quote and Order form updates for Mobility Managed Service
       /* else if (filterColumnName != null && (subfilters.get('Query_Type')=='Mobility Platform Management' ||subfilters.get('Query_Type')=='User Support')){
               system.debug('subfilters' + subfilters); 
               return dataHandler.getMobiltyManagedServceDetails(filterColumnValues,subfilters);
        } */
          else if (filterColumnName != null && (subfilters.get('Query_Type')=='TenancyDetails')){
               system.debug('subfilters' + subfilters); 
              if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getTenancyDetails(filterColumnValues,subfilters); else return rfdataHandler.getTenancyDetails(filterColumnValues,subfilters);//Refactored code
        }
          else if (filterColumnName != null && (subfilters.get('Query_Type')=='BSMobilityTransaction')){//EDGE-173365
               if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getBSMobilityTransition(filterColumnValues); else return rfdataHandler.getBSMobilityTransition(filterColumnValues);//Refactored code
        }
          else if (filterColumnName != null && subfilters.get('Query_Type')=='MobilityTransitionHardwareAndDevice'){//EDGE-175105
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getMobilityTransitionHardwareAndDevice(filterColumnValues,subfilters); else return rfdataHandler.getMobilityTransitionHardwareAndDevice(filterColumnValues,subfilters);//Refactored code        
        }    
        //EDGE-101077 - End
          // EDGE-117631 - Quote and Order form updates for Telstra Collaboration Professional Services
        /*else if (filterColumnName != null && subfilters.get('Query_Type')=='TelstraCollabPS'){
               system.debug('subfilters' + subfilters); 
               return dataHandler.getTelstraCollaborationPS(filterColumnValues,subfilters);
        }*/
        //EDGE-117631 - End        
        //EDGE - 105921 - START - CMP-Committed Offer 
        else if (filterColumnName != null && subfilters.get('Query_Type')=='CMPCommittedData'){
               system.debug('subfilters' + subfilters); 
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getCMPCommittedData(filterColumnValues,subfilters); else return rfdataHandler.getCMPCommittedData(filterColumnValues,subfilters);//Refactored code
        }
        //EDGE - 105921 - End - CMP-Committed Offer 
        else if (filterColumnName != null && subfilters.get('Query_Type')=='CancelCMPProducts'){
               system.debug('subfilters' + subfilters); 
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getCMPCancelProducts(filterColumnValues,subfilters); else return rfdataHandler.getCMPCancelProducts(filterColumnValues,subfilters);//Refactored code
        }
          // EDGE-117631 - Quote and Order form updates for Telstra Collaboration Professional Services
        else if (filterColumnName != null && subfilters.get('Query_Type')=='TelstraCollabPS'){
               system.debug('subfilters' + subfilters); 
               return tcHandler.getTelstraCollaborationPS(filterColumnValues,subfilters);
        }
        //EDGE-117631 - End     
       //EDGE - 109389 ngUC Cancel Start
        else if (filterColumnName != null && subfilters.get('Query_Type')=='ngUCCancelDetails'){
               system.debug('subfilters' + subfilters); 
               return tcHandler.getngUCCancel(filterColumnValues,subfilters);
        }
        //EDGE - 109389 ngUC Cancel End
        //EDGE - 105921 - END
         
        else if (filterColumnName != null && subfilters.get('Query_Type')=='ngUCDevicesRepayment'){
            system.debug('subfilters' + subfilters); 
            system.debug('Inside ngUCDevicesRepayment');
            return tcHandler.getngUCDevicesRCRepayment(filterColumnValues,subfilters);
        }
          
         
        //EDGE-98336 - Start | EDGE-127778 - Added MAC Scenario condition
        else if (filterColumnName != null && (subfilters.get('Query_Type')=='TIDDetails' || subfilters.get('Query_Type')=='TIDDetailsMAC')){
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getTIDDetails(filterColumnValues,subfilters); else return rfdataHandler.getTIDDetails(filterColumnValues,subfilters); //Refactored code               
        }else if (filterColumnName != null && subfilters.get('Query_Type')=='PromotionsAppliedDetails'){
            //EDGE-123788  Display Delegated Discounts in Quote Document
          return dataHandler.getPromotionsApplied(filterColumnValues,subfilters);
           //return null;
        }else if(filterColumnName!=null && subfilters.get('Query_Type')=='SmryForNewServicesRC'){ //Changes Start - EDGE-41351
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getSummaryForNewServicesRC(filterColumnValues); else return rfdataHandler.getSummaryForNewServicesRC(filterColumnValues);//Refactored code
        }
        //EDGE-121387, EDGE-133760
        else if (filterColumnName != null && subfilters.get('Query_Type')=='BSEAPPromoApplied'){            
            return dataHandler.getPromotionsApplied(filterColumnValues,subfilters);    
        }else if (filterColumnName != null && subfilters.get('Query_Type')=='BSEAPPromoAppliedTC'){
            return dataHandler.getPromotionsApplied(filterColumnValues,subfilters);           
        }
        //EDGE-98336 - End
        //EDGE - 117738 End
       
        //EDGE-148728 Start // Uncommented to enable Cancel scinario of Am devices.
    else if (filterColumnName != null && (subfilters.get('Query_Type')=='NGEMDeviceOC' || subfilters.get('Query_Type')=='NGEMDeviceRC')){
            return ngemHandler.getNGEMDevices(filterColumnValues,subfilters);           
        }//EDGE-171311 Added NGEMDeviceOCIC and NGEMDeviceRCIC for Inflight Basket
        //EDGE-148728 Start
        //EDGE-210438
    else if (filterColumnName != null && (subfilters.get('Query_Type')=='TCServices')){
            return tcHandler.getTCServices(filterColumnValues,subfilters);           
        }
        //EDGE-165326 - Start

        else if (filterColumnName != null && (subfilters.get('Query_Type')=='NGEMPlanWLS' 
                                              || subfilters.get('Query_Type')=='NGEMPlanMBB' 
                                              || subfilters.get('Query_Type')=='NGEMPlanHH' 
                                              || subfilters.get('Query_Type')=='NGEMPlanWLSMAC' 
                                              || subfilters.get('Query_Type')=='NGEMPlanMBBMAC' 
                                              || subfilters.get('Query_Type')=='NGEMPlanHHMAC' 
                                              || subfilters.get('Query_Type')=='NGEMPlanWLSCancel' 
                                              || subfilters.get('Query_Type')=='NGEMPlanMBBCancel' 
                                              || subfilters.get('Query_Type')=='NGEMPlanHHCancel' 
                                              || subfilters.get('Query_Type')=='NGEMPlanHHReact' 
                                              || subfilters.get('Query_Type')=='NGEMPlanWLSReact' 
                                              || subfilters.get('Query_Type')=='NGEMPlanMBBReact'
                                             )){//EDGE-155059 & EDGE-162542 Added cancel query_type EDGE-188100 Added Reactivate queries

            return ngemHandler.getNGEMPlans(filterColumnValues,subfilters);           
        }
        //EDGE-165326 - End
        //DPG-3508- start
        else if(filterColumnName != null &&(subfilters.get('Query_Type')=='NGEMDeviceOC_AMaccessoryOC')){            
            
      List<String> filters= subfilters.get('Query_Type').split('_');
      Map<string, Map<string, string>> filter= new Map<string, Map<string, string>>();
      for(string fltr:filters)
      {
        if(fltr.contains('NGEMDevice')){
           Map<string, string> subFil= new Map<string, string>();
          subFil.put('Query_Type','NGEMDeviceOC');
          subFil.put('Type',subfilters.get('Type'));
          filter.put('NGEMDevice',subFil);
        }
        else if(fltr.contains('AMaccessory')){
           Map<string, string> subFil1= new Map<string, string>();
          subFil1.put('Query_Type','AMaccessoryOC');
          subFil1.put('Type',subfilters.get('Type'));
          filter.put('AMaccessory',subFil1);
        }
        system.debug('filter==> '+filter);
      }
            return ngemHandler.getDeviceAccessoryMobility(filterColumnValues,filter);  
        }
        else if(filterColumnName != null &&(subfilters.get('Query_Type')=='NGEMDeviceRC_AMaccessoryRC' )){            
            
           List<String> filters= subfilters.get('Query_Type').split('_');
      
      Map<string, Map<string, string>> filter= new Map<string, Map<string, string>>();
      for(string fltr:filters)
      {
        if(fltr.contains('NGEMDevice')){
           Map<string, string> subFil= new Map<string, string>();
          subFil.put('Query_Type','NGEMDeviceRC');
          subFil.put('Type',subfilters.get('Type'));
          filter.put('NGEMDevice',subFil);
        }
        else if(fltr.contains('AMaccessory')){
           Map<string, string> subFil1= new Map<string, string>();
          subFil1.put('Query_Type','AMaccessoryRC');
          subFil1.put('Type',subfilters.get('Type'));
          filter.put('AMaccessory',subFil1);
        }
        system.debug('filter==> '+filter);
      }
            return ngemHandler.getDeviceAccessoryMobility(filterColumnValues,filter); 
        }
        //DPG-3508- End

        //EDGE-171311 Start
        else if(filterColumnName != null &&(subfilters.get('Query_Type')=='NGEMDeviceOCIC_AMaccessoryOCIC')){            
            
            List<String> filters= subfilters.get('Query_Type').split('_');
            Map<string, Map<string, string>> filter= new Map<string, Map<string, string>>();
            for(string fltr:filters)
            {
                if(fltr.contains('NGEMDevice')){
                     Map<string, string> subFil= new Map<string, string>();
                    subFil.put('Query_Type','NGEMDeviceOCIC');
                    subFil.put('Type',subfilters.get('Type'));
                    filter.put('NGEMDevice',subFil);
                }
                else if(fltr.contains('AMaccessory')){
                     Map<string, string> subFil1= new Map<string, string>();
                    subFil1.put('Query_Type','AMaccessoryOCIC');
                    subFil1.put('Type',subfilters.get('Type'));
                    filter.put('AMaccessory',subFil1);
                }
                system.debug('filter==> '+filter);
            }
            return ngemHandler.getDeviceAccessoryMobility(filterColumnValues,filter);  
        }
        else if(filterColumnName != null &&(subfilters.get('Query_Type')=='NGEMDeviceRCIC_AMaccessoryRCIC' )){            
            
           List<String> filters= subfilters.get('Query_Type').split('_');
          
            Map<string, Map<string, string>> filter= new Map<string, Map<string, string>>();
            for(string fltr:filters)
            {
                if(fltr.contains('NGEMDevice')){
                     Map<string, string> subFil= new Map<string, string>();
                    subFil.put('Query_Type','NGEMDeviceRCIC');
                    subFil.put('Type',subfilters.get('Type'));
                    filter.put('NGEMDevice',subFil);
                }
                else if(fltr.contains('AMaccessory')){
                     Map<string, string> subFil1= new Map<string, string>();
                    subFil1.put('Query_Type','AMaccessoryRCIC');
                    subFil1.put('Type',subfilters.get('Type'));
                    filter.put('AMaccessory',subFil1);
                }
                system.debug('filter==> '+filter);
            }
            return ngemHandler.getDeviceAccessoryMobility(filterColumnValues,filter); 
        }
        //EDGE-171311 End       


        //EDGE-171311 Start
    /* Commenting the below method found duplicate  
     *   else if(filterColumnName != null &&(subfilters.get('Query_Type')=='NGEMDeviceOCIC_AMaccessoryOC')){            
            
            List<String> filters= subfilters.get('Query_Type').split('_');
            Map<string, Map<string, string>> filter= new Map<string, Map<string, string>>();
            for(string fltr:filters)
            {
                if(fltr.contains('NGEMDevice')){
                     Map<string, string> subFil= new Map<string, string>();
                    subFil.put('Query_Type','NGEMDeviceOCIC');
                    subFil.put('Type',subfilters.get('Type'));
                    filter.put('NGEMDevice',subFil);
                }
                else if(fltr.contains('AMaccessory')){
                     Map<string, string> subFil1= new Map<string, string>();
                    subFil1.put('Query_Type','AMaccessoryOC');
                    subFil1.put('Type',subfilters.get('Type'));
                    filter.put('AMaccessory',subFil1);
                }
                system.debug('filter==> '+filter);
            }
            return ngemHandler.getDeviceAccessoryMobility(filterColumnValues,filter);  
        } 
        else if(filterColumnName != null &&(subfilters.get('Query_Type')=='NGEMDeviceRCIC_AMaccessoryRC' )){            
            
           List<String> filters= subfilters.get('Query_Type').split('_');
          
            Map<string, Map<string, string>> filter= new Map<string, Map<string, string>>();
            for(string fltr:filters)
            {
                if(fltr.contains('NGEMDevice')){
                     Map<string, string> subFil= new Map<string, string>();
                    subFil.put('Query_Type','NGEMDeviceRCIC');
                    subFil.put('Type',subfilters.get('Type'));
                    filter.put('NGEMDevice',subFil);
                }
                else if(fltr.contains('AMaccessory')){
                     Map<string, string> subFil1= new Map<string, string>();
                    subFil1.put('Query_Type','AMaccessoryRC');
                    subFil1.put('Type',subfilters.get('Type'));
                    filter.put('AMaccessory',subFil1);
                }
                system.debug('filter==> '+filter);
            }
            return ngemHandler.getDeviceAccessoryMobility(filterColumnValues,filter); 
        } */
        //EDGE-171311 End       



       //EDGE-165834 - Start
        else if (filterColumnName != null && subfilters.get('Query_Type')=='TotalChargesSummary'){
            if (FeatureEligibilityChecker.determineFeatureEligiblity('GSTToggle', 'Old')) return dataHandler.getSummaryForNewCharges(filterColumnValues); else return rfdataHandler.getSummaryForNewCharges(filterColumnValues);  //Refactored code
        }
        //EDGE-165834 - End 



    //EDGE-180110 & EDGE-177567 Start   
        else if (subfilters.get('Query_Type')=='DPR_DealQuotePlanWLS' || subfilters.get('Query_Type')=='DPR_DealQuotePlanMBB' || subfilters.get('Query_Type')=='DPR_DealQuotePlanHH' || subfilters.get('Query_Type')=='DPR_DealQuoteDeviceOC' || subfilters.get('Query_Type')=='DPR_DealQuoteDeviceRC'|| subfilters.get('Query_Type')=='DPRQuoteConditionalCheck'){  
            system.debug('subfilters' + subfilters);   
            return dealHandler.getRows(filterColumnValues,subfilters);  
        }  
        //EDGE-180110 & EDGE-177567 End
    //EDGE-202822 Start
    else if (subfilters.get('Query_Type')=='PORCategories' && filterColumnName != null){  
            system.debug('subfilters' + subfilters);   
            return PorHandler.getPORCategories(filterColumnValues,subfilters);  
        }
    //EDGE-202822 End

        else if (subfilters.get('Query_Type')=='IOTRateCardLTE' || subfilters.get('Query_Type')=='IOTRateCardLPWAN' || subfilters.get('Query_Type')=='IOTRateCardUtilities' || subfilters.get('Query_Type')=='DPRQuoteIoT'){  
            system.debug('subfilters' + subfilters);   
            return IOTDealHandler.getIOTPlanRateCard(filterColumnValues,subfilters);  
        } 
    //EDGE-134662 Start   
        else if (subfilters.get('Query_Type')=='TCRateCard' && filterColumnName != null){  
            system.debug('subfilters' + subfilters);   
            return TCdealHandler.getTCPlanRateCard(filterColumnValues,subfilters);  
        }  
        else if (subfilters.get('Query_Type')=='DPR_DealQuoteTC' && filterColumnName != null){  
            system.debug('subfilters' + subfilters);   
            return TCdealHandler.getRows(filterColumnValues,subfilters);  
        } 
        //EDGE134662 End 
      
      //EDGE-202822 Start
   /* else if (subfilters.get('Query_Type')=='PORCategories' && filterColumnName != null){  
            system.debug('subfilters' + subfilters);   
            return PorHandler.getPORCategories(filterColumnValues,subfilters);  
        }*/
    //EDGE-202822 End




        ////EDGE-92327 - Start 
        /*else if (filterColumnName != null && subfilters.get('Query_Type')=='SOWItems'){
               system.debug('subfilters' + subfilters); 
               return dataHandler.getSOWitems(filterColumnValues);
        }*/
        //EDGE-92327 - End
        //end EDGE-66165,66484 - refactoring covered
        // EDGE-66165,66484 - commenting out old implementation of BasketSnapshot for flatenning PC-data
     
    //EDGE-142319 End | 20.16 FDR Code Override fix 
        else
            return rows;
    }
}