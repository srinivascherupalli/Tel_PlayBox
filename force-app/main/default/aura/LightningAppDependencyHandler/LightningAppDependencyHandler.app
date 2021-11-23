<!-- 
	*Modified for edge-120132 by shubhi
     Modified for EDGE-119832 by Maq
-->

<aura:application access="GLOBAL" extends="ltng:outApp" implements="forceCommunity:availableForAllPageTypes">
    <aura:dependency resource="markup://force:*" type="EVENT"/>
    <aura:dependency resource="c:ShowSubscriptionsOnMACButton"/>
    <aura:dependency resource="c:ComparisonUtility_V2"/>
    <aura:dependency resource="c:RateMatrixForManagedServices"/>
    <aura:dependency resource="c:CustomerExistingTenancy"/> 
    <aura:dependency resource="c:HandlingDiscounts"/> 
    <aura:dependency resource="c:GetScheduleHidden"/> 
    <aura:dependency resource="c:customPriceSchedule"/>   
    <aura:dependency resource="ui:button"/>
    <aura:dependency resource="c:SCAddLegacyTenancy"/>
</aura:application>