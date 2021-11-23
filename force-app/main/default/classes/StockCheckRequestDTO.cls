/*******************************************************************************************************************
Name : StockCheckResquestDTO
EDGE-> 80860
Description : Request dto for the callout to the Stock Check API to get the stock availability details of the selected product
====================================================================================================================
Sr.No.    Developer Name              Date          						Story Description
1.        Kalashree Borgoankar     10/07/2019   		As a salesforce user, I want to perform Stock Check for multiple selected 
Mobile/NGUC devices 
====================================================================================================================
********************************************************************************************************************/
public class StockCheckRequestDTO {
    public class Products {
        public String id;
    }
    
    public List<Products> products;
    public String idSource;
    public Integer zipcode;
    public String lineOfBusinessCode;
    public Boolean includeDescription;
    
    
    public static StockCheckRequestDTO parse(String json) {
        return (StockCheckRequestDTO) System.JSON.deserialize(json, StockCheckRequestDTO.class);
    }
}