/*******************************************************************************************************************
Name : StockCheckResponseDto
EDGE-> 80857
Description : Response dto for the callout to the Stock Check API to get the stock availability details of the selected product
====================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Ravi Shankar     12/06/2019   As a salesforce user, I want to Perform Stock Check for the selected device
                                        so that I can present the information to customer : Stock Enquiry API Consumption
====================================================================================================================
********************************************************************************************************************/
public class StockCheckResponseDto {
	public List<Products> products;
	public String lineOfBusinessCode;
    public String productId;
    public String idSource;
    public String warehouseId;
    public Boolean isServiceable;    
    public List<Inventory> inventory;
    public String Status;
    public String Message;
    public String Code;

    public class Inventory {
        public Integer availableQuantity;
        public String description;
        public String nextReplenishmentDate;
    }
	public class Products {
		public String id;
		public Boolean isServiceable;
		public Integer availableQuantity;
		public String description;
		public String nextReplenishmentDate;
	}
    
    public static StockCheckResponseDto parse(String json) {
        return (StockCheckResponseDto) System.JSON.deserialize(json, StockCheckResponseDto.class);
    }
}