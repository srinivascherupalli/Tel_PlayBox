/*
* @Author : Shubhi
* @Date : 17 Dec 2019
* @Desc : DiscountLineItem Interaface 
* @Jira : Edge-127073
*@testclass:ComplexChargeDisountFactoryTest 
*/
public abstract with sharing class DiscountLineItem {   
    public Charge_Line_Item__c chargeLineItem;
    public abstract Discount_Line_Item__c getDiscountLineItem(Charge_Line_Item__c cli,Discount_Line_Item__c dli);
}