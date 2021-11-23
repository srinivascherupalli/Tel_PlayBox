/*   
* @Author  : Vivek 
* @Date   : 03rd Jan 2021
* @Desc  : Base class having generic method to fetch RateCardLineItems for rate card and Quote & Contract , RTB Json as per New CS Model.
* @Jira : EDGE-189344 , EDGE-189346 , EDGE-189763 , EDGE-189327
*/

public with sharing class RetrieveRateCard {

  // Generic Method to return a wrapper with 
  // 1. RateCardLineItems for RateCard 
  // 2. Quote & Contract 
  // 3. Map of Combination of Commercial product with line items for RTB Json.

  public static PriceItemWrapper getLinesFromCPGeneric( String callingPlan, String Mode, String offerId ) {
        String query                = 'SELECT Id , cspmb__Price_Item__r.Mode__c,cspmb__Price_Item__r.ChargeFrequency__c, cspmb__Price_Item__c, cspmb__Price_Item__r.Plan__c,cspmb__Price_Item__r.cspmb__Master_Price_item__c, cspmb__Rate_Card__r.Charge_ID__c, cspmb__Rate_Card__c, cspmb__Rate_Card__r.External_Rate_Row_ID__c, cspmb__Price_Item__r.Name FROM cspmb__Price_Item_Rate_Card_Association__c WHERE cspmb__Price_Item__r.Check_todays_date__c = TRUE AND cspmb__Price_Item__r.cspmb__Is_Active__c = TRUE AND cspmb__Price_Item__r.Offer_Id__c =: offerId ' ;
        
        if ( !String.isBlank( callingPlan ) && !String.isBlank( Mode ) ) { 
            query                  += ' AND ( ( cspmb__Price_Item__r.Mode__c =: Mode AND cspmb__Price_Item__r.Plan__c =: callingPlan ) OR cspmb__Price_Item__r.cspmb__Master_Price_item__c = null ) ';
        }
        
        List<cspmb__Price_Item_Rate_Card_Association__c> commercialProductAssociationList = Database.query(query);
        Map<String, String> cpToRcMap           =       new Map<String,String>();

        PriceItemWrapper wrap  = new PriceItemWrapper();
        // dms changes added by shashank DIGI-32149
        String chargeFreq;

        for( cspmb__Price_Item_Rate_Card_Association__c associations : commercialProductAssociationList ) {

            String combo;

            if (  associations.cspmb__Price_Item__c != null && String.isBlank( associations.cspmb__Price_Item__r.Mode__c ) && String.isBlank( associations.cspmb__Price_Item__r.Plan__c ) ) {
                    if (  associations.cspmb__Rate_Card__c != null ) {
                            //wrap.externalId             =       associations.cspmb__Rate_Card__r.External_Rate_Row_ID__c;
                            wrap.chargeId               =       associations.cspmb__Rate_Card__r.Charge_ID__c;
                    }
                   /* if (  associations.cspmb__Price_Item__c != null ) {
                            wrap.desciption             =       associations.cspmb__Price_Item__r.Name;
                    }*/
            }
                if (  associations.cspmb__Price_Item__c != null && associations.cspmb__Price_Item__r.cspmb__Master_Price_item__c != null) {
                        combo = associations.cspmb__Price_Item__r.Mode__c + '-' +  associations.cspmb__Price_Item__r.Plan__c;
                }
                else if (  associations.cspmb__Price_Item__c != null && associations.cspmb__Price_Item__r.cspmb__Master_Price_item__c == null) {
                  combo = associations.cspmb__Rate_Card__c;
          }
                cpToRcMap.put(  String.valueOf(associations.cspmb__Rate_Card__c) , combo ); // CP ID ---> Rate Card
                chargeFreq = associations.cspmb__Price_Item__r.ChargeFrequency__c;
          
        }
        // added by shashank DIGI-32149	
        system.debug('chargeFreq'+chargeFreq);	
        wrap.chargeFrequency = chargeFreq;
        List<cspmb__Rate_Card_Line__c>  rateCardLines   =       new List <cspmb__Rate_Card_Line__c>();
        rateCardLines                                   =       fetchRelatedLines( cpToRcMap.keySet() , new List<String>() );
        
        wrap.rateCardLinesWrap = rateCardLines;
        Map<String , List<cspmb__Rate_Card_Line__c>> comboToLines = new Map<String , List<cspmb__Rate_Card_Line__c>>();

        for( cspmb__Rate_Card_Line__c lines : rateCardLines ) {
            if ( lines.cspmb__Rate_Card__c != null ) {
                if ( !comboToLines.containsKey( cpToRcMap.get(String.valueOf( lines.cspmb__Rate_Card__c )) ) ) {
                    comboToLines.put( cpToRcMap.get(String.valueOf( lines.cspmb__Rate_Card__c )) , new List<cspmb__Rate_Card_Line__c>() );
                }
                    comboToLines.get( cpToRcMap.get( String.valueOf( lines.cspmb__Rate_Card__c ))).add( lines );
            }
           
        }
        wrap.comboToLinesWrap  = comboToLines;
        return wrap;
    }


  // Method is used to Query the related lines to a commercial product based on offerId or ratecard Id's
  public static List<cspmb__Rate_Card_Line__c> fetchRelatedLines( Set<String> rateCardIdSet , List<String> rateCardCodeList ) {
      List<cspmb__Rate_Card_Line__c> priceItemLineList   =  new List<cspmb__Rate_Card_Line__c>();
      String Linequery                  =  Model_RateCardLineItem.getRelatedLines(  rateCardIdSet , rateCardCodeList );
      priceItemLineList                 =  Database.query(Linequery);
      return  priceItemLineList;
  }
 
    public class PriceItemWrapper {
        /*public string externalId;
        public String desciption;*/
        public String chargeId;
        public Map<String , List<cspmb__Rate_Card_Line__c>> comboToLinesWrap;
        public String chargeFrequency; // added by shashank DIGI-32149
        public List<cspmb__Rate_Card_Line__c>  rateCardLinesWrap;
    }

    
}