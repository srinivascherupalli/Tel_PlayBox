/****************************************************************************************************************************************
 * @Author : Murugula Srinivasarao from Radium Salesforce team
 * @Date   : 25th Aug 2021
 * @Desc   : Handler class for ProductBasketDataSourceConnection
 *@JIRA    : DIGI-6141
  *Modified:
    NAME                             DESCRIPTION                              DATE
    Kanhaiya Pasoria                 custom label change to Metadata          27/08/2021
	Murugula Srinivasarao			 Method to Cancel DMS Offer				  04/10/2021
    ****************************************************************************************************************************************/
//Test Change
global class DMSDataHandler {
    /*
     *@purpose : To create DMS row data for conga template
     *@param   : 1)basket Id   2)subfilters (passing as empty)
     *@return  : Rows for conga template (list of map row key and value pair)
     */
      private static final String CONST_INTERFACENAME = 'DMSDataHandler';
	  private static String correlationId = GuidUtil.NewGuid();
  
    public List < Map < String, Object >> getDMSServices (String basketId, Map < String, String > subfilters)
    {
        List < cscfga__Product_Configuration__c > planPCList;
        List < Map < String, Object > > rows = new List < Map < String, Object > > ();
        Map < String, Object > newRow = new Map < String, Object > ();
        
        // Defining Externalid for Product Basket Snapshot object
        Integer externalId = 1;
        
        //Defining Query_Type value
         String queryType = subfilters.get('Query_Type');

        //Fetch ProductSpecification from Metadata for DMS Offer
        ProductSpecificationCode__mdt  PdLabel = ProductSpecificationCode__mdt.getInstance('DMS_Product');
        String ProductSpecification = PdLabel.ProdSpecId__c;
        try {
            // fetch product configuration data
            planPCList = [
                 SELECT     Id 
                            ,Name
                            ,OfferName__c
                            ,cscfga__Quantity__c
                            ,cscfga__Product_Definition__r.product_Specification__c
                            FROM cscfga__Product_Configuration__c
                            WHERE Type__c = 'New'
                			AND cscfga__Product_Basket__c =:basketId
                            AND csordtelcoa__Replaced_Product_Configuration__c = null
                			AND cscfga__Product_Definition__r.product_Specification__c =:ProductSpecification 
            ];
        //'DMS Product'
       for (cscfga__Product_Configuration__c pc: planPCList)
                {
                    if (pc.cscfga__Product_Definition__r.product_Specification__c == ProductSpecification) 
                    { 
                          newRow.put('Quantity', pc.cscfga__Quantity__c); 
                        
                          newRow.put('Offer_Name', pc.OfferName__c); 
                         
                          newRow.put('ExternalId', String.valueOf(externalId)); 
                        
                          newRow.put('Query_Type', String.valueOf(QueryType)); 
                        }
                    rows.add(newRow);   
                    
                    externalId++;
                 }
        }catch (Exception exp) 
        {
logException('getDMSServices','',correlationId, exp.getMessage(), 'Telstra: Generate Quote/Contract order form for DMS failed.',CONST_INTERFACENAME);
        }
       return rows;
     }
/*----------------------------------------------------------------
    Method     : getDMSCancelServices
    Description: Method to Cancel DMS Offer
    Author     : Murugula Srinivasarao
    Story      : DIGI-22598
	Date       : 4th Oct 2021
    -------------------------------------------------------------------------------------*/ 
    public List < Map < String, Object >> getDMSCancelServices (String basketId, Map < String, String > subfilters)
    {
        List < cscfga__Product_Configuration__c > planPCList ;
        List < Map < String, Object > > rows = new List < Map < String, Object > > ();
        Map < String, Object > newRow = new Map < String, Object > ();
        
        // Defining Externalid for Product Basket Snapshot object
        Integer externalId = 1;
        
        //Defining Query_Type value
         String queryType = subfilters.get('Query_Type');
        
        //Defining ETC Charge.ETC will be 0 for DMS Offer
        Integer ETC_Charge=0;
                
        //Fetch ProductSpecification from Metadata for DMS Offer
        ProductSpecificationCode__mdt  PdLabel = ProductSpecificationCode__mdt.getInstance('DMS_Product');
        String ProductSpecification = PdLabel.ProdSpecId__c; 
        try {
            // fetch product configuration data
            planPCList = [
                 	SELECT 	Id 
                            ,Name
                            ,OfferName__c
                            ,cscfga__Quantity__c
                            ,Type__c
                            ,cscfga__Product_Definition__r.product_Specification__c
                            FROM cscfga__Product_Configuration__c
                            WHERE cscfga__Product_Basket__c =:basketId
                            AND Type__c = 'Cancel'
                 AND csordtelcoa__Replaced_Product_Configuration__c != null
                AND cscfga__Product_Definition__r.product_Specification__c =:ProductSpecification
                 ];
            	
        //Cancel DMS Product
       for (cscfga__Product_Configuration__c pc: planPCList)
                {
                    if (pc.cscfga__Product_Definition__r.product_Specification__c == ProductSpecification) 
                    { 
                          newRow.put('Quantity', pc.cscfga__Quantity__c); 
                        
                          newRow.put('Offer_Name', pc.OfferName__c); 
                         
                          newRow.put('ExternalId', String.valueOf(externalId)); 
                        
                          newRow.put('Query_Type', String.valueOf(QueryType)); 
                          
                          newRow.put('Type', pc.Type__c);
                           
                          newRow.put('Product_Module_Name',pc.Name);
                        newRow.put('GSTExcl_TotalETC',ETC_Charge);
                		newRow.put('GSTIncl_TotalETC',ProductBasketDataHandler.calculateGSTIncludedPrice(ETC_Charge));
                         }
                    rows.add(newRow);   
                  	
                    externalId++;
                 }
              
        }catch (Exception exp) 
        {
logException('getDMSCancelServices','',correlationId, exp.getMessage(), 'Telstra: Generate Quote/Contract order form for Cancelling DMS offer has been failed.',CONST_INTERFACENAME);
        }
       return rows; 
     }
/*----------------------------------------------------------------
    Method     : logException
    Description: Method to create log exceptions
    Author     : Murugula Srinivasarao
    Story      : DIGI-6141 
    -------------------------------------------------------------------------------------*/ 
public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription,String CONST_INTERFACENAME)
{
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
}