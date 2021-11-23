/*************************************************************************************************
Name : InvoiceResponseDTO
Description : Response DTO for Invoice by Number/PDF Callout
Author: Kalashree Borgaonkar
Story: EDGE-88307
***************************************************************************************************/
public with sharing class InvoiceRequestDTO {
    
	public String customerAccountNumber;
	public Long invoiceNumber;

	public static InvoiceRequestDTO parse(String json) {
		return (InvoiceRequestDTO) System.JSON.deserialize(json, InvoiceRequestDTO.class);
	}
}