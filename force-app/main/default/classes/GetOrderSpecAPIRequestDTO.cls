/********************************************************************************************************
*This Test class is to handle request DTO for Custom wrapper API to support high volume orders.
* Developer: Vanita Mude
* Date: 11 June 2019
* Description: EDGE-86669 expose OrderSpecs via Custom wrapper API to support high volume orders
* Modified :Manjunath Ediga added OrderNum__c as a part of EDGE: 105942 for getting Order specification details with Order Number as input
********************************************************************************************************/
public class GetOrderSpecAPIRequestDTO{

    public String OrderID;  //a4b2O0000004Wbk
    public String CorrelationId;    //008415e6-f785-66b8-811b-bc94838dde4d
    public String targetSystem; //FULFILMENT
    //Start of EDGE: 105942: added order Number Variable to fectch order details based on Order Number 
    public String Order_Number;// Changed OrderNum to Order_Number
    //End of EDGE: 105942
    public set<serviceId> serviceId;   
    
    public static GetOrderSpecAPIRequestDTO parse(String dtoReq){          
        dtoReq=dtoReq.replace('"OrderID__c":','"OrderID":');
        dtoReq=dtoReq.replace('"CorrelationId__c":','"CorrelationId":');
        //Start of EDGE: 105942: added order Number Variable to fectch order details based on Order Number
        dtoReq=dtoReq.replace('"Order_Number__c":','"Order_Number":');//Added as part of EDGE: 105942
        //End of EDGE: 105942
        //dtoReq=dtoReq.replace('"serviceId":','"serviceId":');//Added as part of EDGE: 105942
        System.debug('dtoReq==>'+dtoReq);
        return (GetOrderSpecAPIRequestDTO) System.JSON.deserialize(dtoReq, GetOrderSpecAPIRequestDTO.class);
    }

    public class serviceId {
		public String Id{get;set;}//a4e2N0000006w6iQAA
	}
    
}