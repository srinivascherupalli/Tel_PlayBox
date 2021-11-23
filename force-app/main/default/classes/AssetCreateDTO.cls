/*
===============================================================================================================================
Class : AssetCreateDTO
Developer Name : Shubhi
Test Class : AssetUpsertionHelperTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia  3/9/2019     Edge-107843 CS should maintain the association of account to 
											subscription / service to device identifiers during 
											NEW / MAC scenarios so that reverse logistics solution can be supported 
2.        shubhi Vijayvergia  24/9/2019 	<Forward Logistics> Device Modelling : Mobile Device and Broadsoft Device Product 
											Module change to rename the device identifier
											attribute name and introduce device identifier type
===============================================================================================================================
*/
public with sharing class AssetCreateDTO {
	public String accountID{get; set;}
    public String name{get; set;}
    public String specCode{get; set;}
    public String description{get; set;}
    public String SKU{get; set;}
    public String assetStatus{get; set;}
    public String serviceId{get; set;}
    public String subcriptionId{get; set;}
    public String offerId{get; set;}
    public String assetUUID{get; set;}
    public String assetID{get; set;} //Edge-112340
    public String assetIDType{get; set;} //Edge-112340
    public String ownership{get; set;}
    public String assetInstanceId{get; set;}  
    public Integer quantity{get; set;}
    public Integer deviceQuantity{get; set;}
}