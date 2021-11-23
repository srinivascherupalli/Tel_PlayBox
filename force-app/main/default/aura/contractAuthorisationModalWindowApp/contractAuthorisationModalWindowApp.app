<!--
* @Author   :   Manish Berad
* @Date     :   23 june 2020
* @Desc     :   EDGE-153347  Lightning Application linked to "Contract Authorisation" button 
*				on CS Basket to capture Pre-Authorisation details for MACD Orders.
* -->
<aura:application access="GLOBAL" extends="ltng:outApp" >
    <aura:dependency resource="c:contractAuthorisationModalWindow"/>
    <aura:dependency resource="markup://force:navigateToURL" type="EVENT"/>
    <aura:dependency resource="markup://force:navigateToComponent" type="EVENT"/>
    <aura:dependency resource="markup://force:navigateToSObject" type="EVENT"/>
</aura:application>