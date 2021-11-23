/*************************************************************************************************
Name : OneFundInvoiceRequestDTO
Description : Response DTO for Invoice by Number/PDF Callout
Author: Vamshi
Story: EDGE-124053
***************************************************************************************************/
public with sharing class OneFundInvoiceRequestDTO {
    
	public String customerAccountNumber;
	public Long invoiceNumber;

	public static OneFundInvoiceRequestDTO parse(String json) {
		return (OneFundInvoiceRequestDTO) System.JSON.deserialize(json, OneFundInvoiceRequestDTO.class);
	}
}