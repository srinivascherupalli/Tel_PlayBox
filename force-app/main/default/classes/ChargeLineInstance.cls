/*
* @Author : Shubhi
* @Date : 17 Dec 2019
* @Desc : ChargeLineInstance Interaface 
* @Jira : Edge-127073
* @testclass: ComplexChargeDisountFactory
*/
public interface ChargeLineInstance {
    Charge_Line_Item__c getChargeLineItem(Charge_Line_Item__c cli);
}