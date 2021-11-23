/**================================================================
 * @Author : Kamlesh Kumar
 * @Date : 15th July 2020
 * @Desc : Source code taken from ProductBasketDataHandler. The class contains the reusable code like calculate GST or string valid which can be used in different handler class.
 * @Jira :
 ==================================================================*/

/***
 * History of Updates
 ***/

public with sharing class BasketSnapshotUtility {
    
  static list<cscfga__Product_Configuration__c> prodcList = null, parentProdcList = null;
  //EDGE-80772 : Updated for Solution Console retrofit
  //EDEG-98246 :Start
  //DIGI-3352 : NameChange
  static Map<String, String> Offer_vs_OfferFamily = new Map<String, String>{
    'Connected Workplace Package' => 'Connected Workplace',
    'Connected Workplace' => 'Connected Workplace',
    'CWP Mobility' => 'Connected Workplace',
    'Connected Workplace Solution' => 'Connected Workplace',
    'Adaptive Collaboration' => 'Adaptive Collaboration',
    'Adaptive Collaboration Solution' => 'Adaptive Collaboration',
    //changes start for 99894
    'Device Outright Purchase Solution' => 'Device Outright Purchase',
    'Device Outright Purchase' => 'Device Outright Purchase',
    //changes end for 99894
    //EDGE-117967
    'Device' => 'Device Outright Purchase',
    'Corporate Mobile Plus-FairPlay Data' => 'Corporate Mobile Plus',
    'Corporate Mobile Plus' => 'Corporate Mobile Plus',
    'Corporate Mobile Plus-Committed Data' => 'Corporate Mobile Plus',
    Label.TMDM_VMwareOfferName => Label.TMDM_VMwareOfferFamily, //Added as part of EDGE-144574 by Amsterdam Team
    //'Telstra Mobile Device Management powered by VMware' => 'Telstra Mobile Device Management',
    'T-MDM' => 'Telstra Mobile Device Management',
    'Adaptive Collaboration Professional Servi' => 'Adaptive Collaboration Professional Services',
    'Adaptive Collaboration Professional Services' => 'Adaptive Collaboration Professional Services ',
    'Enterprise Mobility Managed Service' => 'Enterprise Mobility Managed Service ',
    'Professional Services-MDM Config' => 'T-MDM Professional Services',
    'Internet Of Things' => Label.IoTOfferName, //Added as part of DPG-1311
    'IoT Connectivity' => Label.IoTOfferName, //Added as part of DPG-1311
    'IOT Offer' => Label.IoTOfferName, //Added as part of DPG-1311
    'Telstra Internet Direct' => 'Telstra Internet Direct',
    'Next Generation Mobile Device' => Label.NGEMOfferName
  }; //EDGE-148728 | Added NGEM

  //Defect - EDGE-109988
  static List<String> minimumCommitmentAvailable = new List<String>{
    'DMCAT_Offer_000303',
    'DMCAT_Offer_000646',
    'DMCAT_Offer_000618',
    'DMCAT_Offer_000854',
    'DMCAT_Offer_000709',
    'DMCAT_Offer_001231'
  };
  static List<String> importantInformationAvailable = new List<String>{
    'DMCAT_Offer_000303',
    'DMCAT_Offer_000618',
    'DMCAT_Offer_000854',
    'DMCAT_Offer_000750',
    'DMCAT_Offer_000936',
    'DMCAT_Offer_000709'
  };
  static Set<String> offers = null;
  static final String cwpId = 'DMCAT_Offer_000303';
  static final String pphhId = 'DMCAT_Offer_000646';
  //EDGE-81548
  static final String mdmId = 'DMCAT_Offer_000681';
  static final String tcId = 'DMCAT_Offer_000618';
  //changes start for 99894
  static final String dopId = 'DMCAT_Offer_000783';
  //EDGE-123562
  static final String mmsId = 'DMCAT_Offer_000854';
  static final String psMdmId = 'DMCAT_Offer_000750';
  static final String telCollabPSId = 'DMCAT_Offer_000936';
  //change start for DPG-598
  static final String iotId = 'DMCAT_Offer_000964'; //change end for DPG-598
  //EDGE-98336
  static final String tidId = 'DMCAT_Offer_000709';
  static final String ngemId = 'DMCAT_Offer_001231'; //EDGE-148728

  /**
   * @Date :
   * @Description : Helper method to get distinct offers added in the basket
   */
  public static Set<String> getOffersInBasket(String basketId) {
    if (offers != null)
      return offers;
    else {
      offers = new Set<String>();
      system.debug('getOffersInBasket: offers..' + offers);
      //list<cscfga__Product_Configuration__c> prodcList = getPCsForBasket(basketId);
      String temp = '';
      for (cscfga__Product_Configuration__c pcloop : getPCsForBasket(basketId)) {
        System.debug(pcloop.Offername__c + ':');
        if (!String.isBlank(pcloop.Offername__c))
          offers.add(getOfferFamily(pcloop.Offername__c));
        if (pcloop.cscfga__Parent_Configuration__c != null && !String.isBlank(pcloop.cscfga__Parent_Configuration__r.Offername__c))
          offers.add(getOfferFamily(pcloop.cscfga__Parent_Configuration__r.Offername__c));
      }
      system.debug('getOffersInBasket outside for : ' + offers);
      return offers;
    }
  }

  /**
   * @Date
   * @Description : Helper method to get child product-configurations of basket
   */
  public static list<cscfga__Product_Configuration__c> getPCsForBasket(String basketId) {
    if (prodcList != null)
      return prodcList;
    else {
      //EDGE-113291 Added 'Telstra Collaboration' in below query
      //EDGE-117967 Added 'Device Outright Purchase' in below query
      String pcsoqlQuery =
        'SELECT id,cscfga__Parent_Configuration__r.Offername__c,cscfga__Parent_Configuration__r.Offer_Reference__r.Name,cscfga__Parent_Configuration__r.Name,' +
        ' cscfga__Parent_Configuration__c,cscfga__Contract_Term__c,cscfga__total_one_off_charge__c,cscfga__Parent_Configuration__r.cscfga__total_one_off_charge__c,' +
        ' TotalGSTInclusiveTOC__c,type__c,cscfga__total_recurring_charge__c,cscfga__Parent_Configuration__r.cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,' +
        ' cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,cscfga__Product_Family__c,Offername__c,Offer_Reference__r.Name,' +
        ' (select id,name,cscfga__Value__c from cscfga__Attributes__r where name=\'CaseStatus\') ' +
        ' from cscfga__Product_Configuration__c where cscfga__Product_Basket__c= \'' +
        String.escapeSingleQuotes(basketId) +
        '\'' +
        ' and (Commercial_Config__c=\'Yes\' or cscfga__Product_Family__c=\'Professional Services-MDM Config\' or cscfga__Product_Family__c=\'Tenancy\' or cscfga__Product_Family__c=\'Telstra Collaboration Professional Servi\' or cscfga__Product_Family__c=\'Managed Services\' or cscfga__Product_Family__c=\'Telstra Collaboration Solution\' or cscfga__Product_Family__c=\'Device Outright Purchase Solution\' or cscfga__Product_Family__c=\'Enterprise Mobility\'  or cscfga__Product_Family__c=\'Internet Of Things\' or cscfga__Product_Family__c=\'IOT Subscription\' or cscfga__Product_Family__c=\'Device Outright Purchase\' or cscfga__Product_Family__c=\'Internet Site\' or cscfga__Product_Family__c=\'Tenancy Solution\' or cscfga__Product_Family__c=\'Next Generation Mobile Device\' or cscfga__Product_Family__c=\'Mobile Device Care\')'; //EDGE-80783 AND EDGE-148728 //EDGE-148722 - Added Mobile Device Care
      prodcList = Database.query(pcsoqlQuery);
      system.debug('Inside ProductBasketDataHandler:: prodcList = ' + prodcList);
      return prodcList;
    }
  }

  /**
   * @Date :
   * @Description : Identify the offer-family for a selected offer
   */
  public static String getOfferFamily(String offerName) {
    return Offer_vs_OfferFamily.get(offerName);
  }

  /**
   * @Date :
   * @Description : EDGE-98246 - utility Method to check if value is a record-id
   */
  public Boolean isValidId(String strId) {
    Boolean isValid = (strId instanceof ID) ? true : false;
    return isValid;
  }

  /* ****************************************************************************
   * Author : Manoj Kumar
   * Date : 29 Jan 2019
   * Description : This method is used to calculate the GST price of product
   * Parameters : integer, Integer
   * Return Integer
   * *****************************************************************************/
  public Decimal calculateGSTIncludedPrice(Decimal onceOffCharge) {
    Decimal rateOfGST = Decimal.valueOf(Label.GSTChargeRate);
    onceOffCharge = onceOffCharge + onceOffCharge * rateOfGST;
    Decimal chargesIncGST = onceOffCharge.setScale(2);
    return chargesIncGST;
  }

  /**
   * @Date :
   * @Description : The method calculates the total GB data
   */
  public String calculateTotalDataforCommittedPlan(String Plan_Data, String Bonus_Data) {
    Integer cmp_plan_data = Integer.valueof(Plan_Data);
    Integer cmp_bonus_data = Integer.valueof(Bonus_Data);
    String total_data;
    Integer total_value;
    total_value = cmp_plan_data + cmp_bonus_data;
    total_data = String.valueOf(total_value) + ' GB';
    system.debug('total_data: ' + total_data);
    return total_data;
  }

  /**
   * @Date :
   * @Description :
   */
  public List<String> getDiscountApplied(String pCId, Map<String, List<Discount_Line_Item__c>> mapOfDiscounts) {
    List<String> listOfDiscountText = new List<String>();
    Map<String, String> mapOfBuisnessIdVsHelpText = new Map<String, String>();
    List<MobilePlanDiscount__mdt> lstOfMobilePlanDis = [SELECT Id, MasterLabel, Discount_Name__c, Discount_Template_Text__c, Discount_Type__c FROM MobilePlanDiscount__mdt];
    if (lstOfMobilePlanDis != null && !lstOfMobilePlanDis.isEmpty()) {
      for (MobilePlanDiscount__mdt mpd : lstOfMobilePlanDis) {
        mapOfBuisnessIdVsHelpText.put(mpd.MasterLabel, mpd.Discount_Template_Text__c);
      }
    }
    if (mapOfDiscounts != null && !mapOfDiscounts.isEmpty()) {
      List<Discount_Line_Item__c> lstOfDiscounts = mapOfDiscounts.get(pCId);
      System.debug('###########---lstOfDiscounts>' + lstOfDiscounts);
      if (lstOfDiscounts != null && !lstOfDiscounts.isEmpty()) {
        for (Discount_Line_Item__c dli : lstOfDiscounts) {
          System.debug('###########---DLI-->' + dli);
          if (dli != null && mapOfBuisnessIdVsHelpText != null) {
            String DiscountText = mapOfBuisnessIdVsHelpText.get(dli.BusinessID__c);
            String DiscountApplied = '';
            if (DiscountText != null && DiscountText.contains('####')) {
              if (dli.discountValue__c != null) {
                DiscountApplied = DiscountText.replace('####', dli.discountValue__c);
                if (dli.duration__c != null) {
                  DiscountApplied = DiscountApplied.replace('@@@', dli.duration__c);
                }
              }
            } else {
              DiscountApplied = DiscountText;
            }
            listOfDiscountText.add(DiscountApplied);
          }
        }
      }
    }
    return listOfDiscountText;
  }

  /**
   * @Date :
   * @Desc : EDGE-88163 - Start Descr: Get parent products to dynamically show/hide Minimum Commitment table
   * Defect - EDGE-109988 : Fix applied in below method for deciding if minimum-commitment,important-information table to be shown or not.
   */
  public List<Map<String, Object>> getParentProducts(String basketId) {
    List<Map<String, Object>> rows = new List<Map<String, Object>>();
    //EDGE-114970 : Capturing redemption information in Order form for customer sign off
    List<Double> validDOPRedeemAmtList = new List<Double>();
    List<Double> validTCRedeemAmtList = new List<Double>();
    List<Double> validNGEMRedeemAmtList = new List<Double>(); //EDGE-148728
    try {
      Integer externalID = 1;
      Set<String> offers = getOffersInBasket(basketId);
      Map<String, Object> row = new Map<String, Object>();
      System.debug('inside getParentProducts');
      String basket_Id = String.escapeSingleQuotes(basketId);
      //INC000093040240 change showHideMinimumCommitment from Boolean to Decimal
      Decimal showHideMinimumCommitment = 0;
      Boolean showHideImportantInfo = false;
      //list<cscfga__Product_Configuration__c> prodList = [SELECT id,name,Offername__c,Marketable_Offer__r.Offer_ID__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basket_Id];
      //EDGE-144228 Added Inner Query
      list<cscfga__Product_Configuration__c> prodList = [SELECT id,name,Offername__c,Marketable_Offer__r.Offer_ID__c,(SELECT Id,Name,cscfga__Product_Configuration__c,cscfga__Display_Value__c,cscfga__Value__c,cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c,cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c,cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r WHERE name = 'OfferTypeString') FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c = :basket_Id];
      system.debug('offers' + offers);
      // for(String offer:offers){
      //system.debug('@@offer'+offer) ;
      //EDGE-114970 : Capturing redemption information in Order form for customer sign off
      //DIGI-3352 : Modified offerName parameter from Telstra Collaboration -> Adapative Collaboration
      validDOPRedeemAmtList = offerWiseRedeemedAmountList(basketId, 'Device Outright Purchase');
      validTCRedeemAmtList = offerWiseRedeemedAmountList(basketId, 'Adaptive Collaboration');
      validNGEMRedeemAmtList = offerWiseRedeemedAmountList(basketId, 'Next Generation Mobile Device'); //EDGE-148728
      //EDGE-123788  Display Delegated Discounts in Quote Document
      boolean isProApplied = isPromotionApplied(basketId);
      Boolean isFairplay = false; //EDGE-145184/INC000092558413 Changes
      for (cscfga__Product_Configuration__c pc1 : prodList) {
        if (pc1.Marketable_Offer__r.Offer_ID__c == cwpId) {
          System.debug('inside CWP Offerspecid');
          row.put('isCWP', true);
          if (minimumCommitmentAvailable.contains(cwpId) == true) {
            //INC000093040240 Start
            showHideMinimumCommitment = showHideMinimumCommitment + 1;
          }
          //showHideMinimumCommitment = minimumCommitmentAvailable.contains(cwpId);//INC000093040240 End
          showHideImportantInfo = importantInformationAvailable.contains(cwpId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == ngemId) {
          //EDGE-148728 START
          System.debug('inside NGEM Offerspecid');
          row.put('isNGEM', true);
          if (!validNGEMRedeemAmtList.isEmpty())
            row.put('isNGEMRedeemable', true);
          else
            row.put('isNGEMRedeemable', false);
          if (minimumCommitmentAvailable.contains(ngemId) == true) {
            showHideMinimumCommitment = showHideMinimumCommitment + 1;
          }
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == pphhId) {
          //EDGE-148728 END
          row.put('isPPHH', true);
          system.debug('isPPHH@@::');
          if (minimumCommitmentAvailable.contains(pphhId) == true) {
            //INC000093040240 Start
            showHideMinimumCommitment = showHideMinimumCommitment + 1;
          }
          //showHideMinimumCommitment = minimumCommitmentAvailable.contains(pphhId);//INC000093040240 End
          //EDGE-147419 Added if to skip this execution if showHideImportantInfo is already true.
          if (showHideImportantInfo == false) {
            showHideImportantInfo = importantInformationAvailable.contains(pphhId);
          }
          //EDGE-147419
          //EDGE - 105921 - START
          /*if(pc1.name=='Corporate Mobile Plus-FairPlay Data'){
                            row.put('isFairplayData',True);//EDGE-137773
                            system.debug('FairPlay Data@@::' + row);//EDGE-137773
                        }
                        if(pc1.name=='Corporate Mobile Plus-Committed Data'){
                            row.put('isCommittedData',True);
                            system.debug('Committed Data@@::' + row);//EDGE-137773
                        }
                        system.debug('ROWS@@::' + row);//EDGE-137773*/
          //EDGE-144228 Start
          /* for(cscfga__Attribute__c attribute:pc1.cscfga__Attributes__r) {
                            System.debug('attribute:'+attribute.name);
                            if(attribute.cscfga__Value__c == 'Committed Data'){
                              row.put('isCommittedData',True);
                              system.debug('Committed Data@@::' + row);  
                            }
                        }*/
          //EDGE-145184/INC000092558413 Changes Start Here
          for (cscfga__Attribute__c attribute : pc1.cscfga__Attributes__r) {
            System.debug('attribute:' + attribute.name);
            if (!isFairplay) {
              if (attribute.cscfga__Value__c == 'FairPlay Data' && attribute.Name == 'OfferTypeString') {
                isFairplay = true;
              }
            }
          }
          system.debug('valueoFAIRPLAY' + isFairplay);
          if (isFairplay)
            row.put('isCommittedData', false);
          else
            row.put('isCommittedData', true);
          //EDGE-145184/INC000092558413 Changes End Here
          system.debug('ROWS@@::' + row);
          //EDGE-144228 End
          //EDGE-123788   Display Delegated Discounts in Quote Document
          if (isProApplied) {
            row.put('isPromotionsApplied', true);
          } else {
            row.put('isPromotionsApplied', false);
          }
          //EDGE - 105921 - End
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == mdmId) {
          //EDGE-81548 - Start
          row.put('isMDM', true);
          // EDGE-138986 | Commenting Important Info and Minimum Commitment for MDM | No change in flow
          /* showHideMinimumCommitment = minimumCommitmentAvailable.contains(mdmId);
           showHideImportantInfo = importantInformationAvailable.contains(mdmId); */
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == dopId) {
          //changes start for 99894
          row.put('isDOP', true);
          //EDGE-114970 : Capturing redemption information in Order form for customer sign off
          if (!validDOPRedeemAmtList.isEmpty()) {
            row.put('isDOPRedeemable', true);
          } else {
            row.put('isDOPRedeemable', false);
          }
          if (minimumCommitmentAvailable.contains(dopId) == true) {
            //INC000093040240 Start
            showHideMinimumCommitment = showHideMinimumCommitment + 1;
          }
          //showHideMinimumCommitment = minimumCommitmentAvailable.contains(dopId);//INC000093040240 End
          showHideImportantInfo = importantInformationAvailable.contains(dopId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == tcId) {
          //changes end for 99894
          row.put('is_TC', true);
          //EDGE-114970 : Capturing redemption information in Order form for customer sign off
          if (!validTCRedeemAmtList.isEmpty()) {
            row.put('isTCRedeemable', true);
          } else {
            row.put('isTCRedeemable', false);
          }
          if (minimumCommitmentAvailable.contains(tcId) == true) {
            //INC000093040240 Start
            showHideMinimumCommitment = showHideMinimumCommitment + 1;
          }
          //showHideMinimumCommitment = minimumCommitmentAvailable.contains(tcId);//INC000093040240 End
          showHideImportantInfo = importantInformationAvailable.contains(tcId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == iotId) {
          //changes for DPG-598
          System.debug('PDH : Inside IOT ....' + iotId);
          row.put('is_IOT', true);
          if (minimumCommitmentAvailable.contains(iotId) == true) {
            //INC000093040240 Start
            showHideMinimumCommitment = showHideMinimumCommitment + 1;
          }
          // showHideMinimumCommitment = minimumCommitmentAvailable.contains(iotId);//INC000093040240 End
          showHideImportantInfo = importantInformationAvailable.contains(iotId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == mmsId) {
          //EDGE-123562 Start
          row.put('isMobilityManagedService', true);
          if (minimumCommitmentAvailable.contains(mmsId) == true) {
            //INC000093040240 Start
            showHideMinimumCommitment = showHideMinimumCommitment + 1;
          }
          //showHideMinimumCommitment = minimumCommitmentAvailable.contains(mmsId);//INC000093040240 End
          showHideImportantInfo = importantInformationAvailable.contains(mmsId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == psMdmId) {
          row.put('isPSMDM', true);
          showHideImportantInfo = importantInformationAvailable.contains(psMdmId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == telCollabPSId) {
          row.put('isPSTelstraCollaboration', true);
          showHideImportantInfo = importantInformationAvailable.contains(telCollabPSId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == mmsId) {
          //EDGE-123562 End
          //EDGE-123562 Start
          row.put('isMobilityManagedService', true);
          if (minimumCommitmentAvailable.contains(mmsId) == true) {
            //INC000093040240 Start
            showHideMinimumCommitment = showHideMinimumCommitment + 1;
          }
          //showHideMinimumCommitment = minimumCommitmentAvailable.contains(mmsId);//INC000093040240 End
          showHideImportantInfo = importantInformationAvailable.contains(mmsId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == psMdmId) {
          row.put('isPSMDM', true);
          showHideImportantInfo = importantInformationAvailable.contains(psMdmId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == telCollabPSId) {
          row.put('isPSTelstraCollaboration', true);
          showHideImportantInfo = importantInformationAvailable.contains(telCollabPSId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == mmsId) {
          //EDGE-123562 End
          //EDGE-123562 Start
          row.put('isMobilityManagedService', true);
          if (minimumCommitmentAvailable.contains(mmsId) == true) {
            //INC000093040240 Start
            showHideMinimumCommitment = showHideMinimumCommitment + 1;
          }
          // showHideMinimumCommitment = minimumCommitmentAvailable.contains(mmsId);//INC000093040240 End
          showHideImportantInfo = importantInformationAvailable.contains(mmsId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == psMdmId) {
          row.put('isPSMDM', true);
          showHideImportantInfo = importantInformationAvailable.contains(psMdmId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == telCollabPSId) {
          row.put('isPSTelstraCollaboration', true);
          showHideImportantInfo = importantInformationAvailable.contains(telCollabPSId);
        } else if (pc1.Marketable_Offer__r.Offer_ID__c == tidId) {
          //EDGE-123562 End
          //EDGE-98336 - Start
          row.put('isTID', true);
          if (minimumCommitmentAvailable.contains(tidId) == true) {
            //INC000093040240 Start
            showHideMinimumCommitment = showHideMinimumCommitment + 1;
          }
          //showHideMinimumCommitment = minimumCommitmentAvailable.contains(tidId);//INC000093040240 End
          showHideImportantInfo = importantInformationAvailable.contains(tidId);
        }
        //EDGE-98336 - End
        //EDGE-81548 - End
        row.put('ExternalId', String.valueOf(externalID));
        //Reusing Type,Order-type field to store boolean for show/hide
        //row.put('Type',showHideMinimumCommitment);//INC000093040240 fix
        row.put('Order_Type', showHideImportantInfo);
        system.debug('@@@row1234' + row);
      }
      //INC000093040240 Start
      if (showHideMinimumCommitment > 0) {
        row.put('Type', true);
      } else {
        row.put('Type', false);
      }
      //INC000093040240 End
      //}
      system.debug('@@@row' + row);
      rows.add(row);
      system.debug('@@@rows' + rows);
      externalID++;
    } catch (Exception e) {
      System.debug('e:' + e.getMessage() + ' :' + e.getLineNumber());
    }
    return rows;
  }

  /**
   * @Date :
   * @Description : Helper method to get status of Case-record(for ETC waiver) created for an opportunity
   */
  public Map<id, String> getCaseStatusMap(String basketId) {
    Map<id, String> caseStatusMap = new Map<id, String>();
    // list<cscfga__Product_Configuration__c> prodcList = getPCsForBasket(basketId);
    for (cscfga__Product_Configuration__c pcloop : getPCsForBasket(basketId)) {
      for (cscfga__Attribute__c at : pcloop.cscfga__Attributes__r) {
        if (at.cscfga__Value__c != null) {
          caseStatusMap.put(pcloop.cscfga__Parent_Configuration__c, at.cscfga__Value__c);
        }
      }
    }
    return caseStatusMap;
  }

  /**
   * @Date :
   * @Description : Helper method to check if the account has an active Contract for the same offer
   */
  public boolean checkifContractExistsForAccount(String basketId, String Offer) {
    Boolean ExistingContract = false;
    //start defect - 59875
    List<String> inactiveContractStatus = new List<String>{ 'Signature Declined', 'Cancelled', 'Void' };
    String soqlOnExistingContract =
      'select id from ContractJunction__c where Related_Basket__c!=\'' +
      String.escapeSingleQuotes(basketId) +
      '\' and account__c IN(select csbb__Account__c from cscfga__Product_Basket__c where id=\'' +
      String.escapeSingleQuotes(basketId) +
      '\') and BSA_Generated__c =true and Status__c not in :inActiveContractStatus';
    //end defect - 59875
    List<ContractJunction__c> Cj = Database.query(soqlOnExistingContract);
    if (Cj.size() > 0)
      return true;
    else
      return false;
  }

  /**
   * @Date :
   * @Description : EDGE-114970 : Capturing redemption information in Order form for customer sign off
   */
  public List<Double> offerWiseRedeemedAmountList(String basketId, String offerName) {
    List<Double> validRedeemAmtList = new List<Double>();
    if (offerName != null) {
      List<cscfga__Attribute__c> redeemAmtList = [
        SELECT cscfga__Value__c
        FROM cscfga__Attribute__c
        WHERE cscfga__Product_Configuration__r.cscfga__Product_Basket__c = :basketId AND name = 'RedeemFund' AND cscfga__Product_Configuration__r.Offername__c = :offerName
      ];
      if (redeemAmtList.size() > 0) {
        for (cscfga__Attribute__c amtList : redeemAmtList) {
          if (Double.valueOf(amtList.cscfga__Value__c) != 0.00) {
            validRedeemAmtList.add(Double.valueOf(amtList.cscfga__Value__c));
          }
        }
      }
    }
    return validRedeemAmtList;
  }

  /**
   * @Date :
   * @Description : EDGE-123788   Display Delegated Discounts in Quote Document
   */
  public Boolean isPromotionApplied(String basketId) {
    List<Discount_Line_Item__c> lstOfDLI = [SELECT Id, Name FROM Discount_Line_Item__c WHERE chargeInstance__r.basketId__c = :basketId];
    if (lstOfDLI != null && !lstOfDLI.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }
}