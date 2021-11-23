<aura:application access="global" extends="ltng:outApp">
    <aura:registerEvent name="renderPlanGbbScale" type="c:PLanLevelGbbRender"/>
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    <aura:dependency resource="c:GetDealScorecmp"/>
</aura:application>