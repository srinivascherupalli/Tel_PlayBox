/*************************************************************************************************
EDGE -104930
Name: AdjustmentsResponseDTO
Description: DTO class for BAN adjustment API controller. 
Author:Mahima 
***************************************************************************************************/
public class AdjustmentsResponseDTO {
    
    public Integer code { get; set; }
    public Integer status { get; set; }
    public string message { get; set; }
    public string billingAccountNumber { get; set; }
    public List<Adjustment> adjustments { get; set; }
    public List<Error> errors { get; set; }
    
    //Inner class for adjustment data
    public class Adjustment
    {
        public string description { get; set; }
        public string dateApplied { get; set; }
        public decimal adjustmentAmount { get; set; }
        public decimal amountApplied { get; set; }
        public decimal amountUnapplied { get; set; }
        public String adjustmentId { get; set; }
    }
    
    //Inner class for error data
    public class Error
    {
        public Integer code { get; set; }
        public string field { get; set; }
        public string message { get; set; }
    }
}