<!--
* @Author   :   Maqsood Alam
* @Date     :   10 Oct 2018
* @Desc     :   Wrapper application for sObject Lookup - Lightning Component
* -->
<aura:application access="GLOBAL" extends="ltng:outApp"> 
    <aura:dependency resource="c:ContractSignatoriesComponent"/> 
    <aura:dependency resource="markup://force:navigateToURL" type="EVENT"/>
    <aura:dependency resource="markup://force:navigateToComponent" type="EVENT"/>
    <aura:dependency resource="markup://force:navigateToSObject" type="EVENT"/>
    <!-- <aura:dependency resource="markup://force:*" type="EVENT"/> -->
</aura:application>