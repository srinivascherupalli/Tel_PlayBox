/***************************************************************************************************
Name          : SolutionHelper
Created By    : Mahaboob Basha
Created Date  : May 10 2019
Description   : This class is the remote action helper used by JavaScript Plugin in Solution Console
-------
History
-------
VERSION     AUTHOR          DATE            DETAIL
-------     ------          -----           ---------
1.1         Mahaboob        10-05-2019      Created
1.1         Mahaboob        10-05-2019      Added methods getUserAttributeDetails, getUserUnitPrice
1.2         Mahaboob        03-06-2019      Added methods getIPSiteBandwidth
1.3         Mahaboob        21-06-2019      Added methods getUserTotalETC
1.4         Manjunath Ediga 24-07-2019      Updated method getDeviceMROBonus
***************************************************************************************************/
global with sharing class SolutionHelper implements cssmgnt.RemoteActionDataProvider {

    // --- main method that needs to be implemented ---
    /****************************************************************************************************
    * Method Name : getData
    * Description : Default method to be overwritten from the Interface to perform Remote Actions
    * Parameters  : Map<String, Object>     -   inputMap passed from the JavaScript Plugin
    * Return      : Map<String, Object>     -   ReturnMap with the details required for JavaScript Plugin
    ****************************************************************************************************/
    global Map<String, Object> getData(Map<String, Object> inputMap) {
        System.debug('Enter remote action');
        System.debug('Input Map ' + inputMap);
        //return getRequiredInfo(inputMap);

        Map<String, Object> returnMap = new Map<String, Object>();

        if (inputMap.containsKey('siteNetworkZone')) {
            returnMap = getUserAttributeDetails(inputMap);
        }
        else if (inputMap.containsKey('Offer Id')) {
            returnMap = getUCEUserAttributeDetails(inputMap);
        }
        else if (inputMap.containsKey('TypeUser') && inputMap.containsKey('ZonefromParent')) {
            returnMap = getUserUnitPrice(inputMap);
        }
        else if (inputMap.containsKey('CountTotalUserQty') && inputMap.containsKey('TierSelected') && inputMap.containsKey('Technology')) {
            returnMap = getIPSiteBandwidth(inputMap);
        }
        else if (inputMap.containsKey('Quantity') && inputMap.containsKey('TypeUser') && inputMap.containsKey('DisconnectionDate') && inputMap.containsKey('ProdConfigId')) {
            returnMap = getUserTotalETC(inputMap);
        }
        else if (inputMap.containsKey('DeviceId') && inputMap.containsKey('PlanId')) {
            returnMap = getDeviceMROBonus(inputMap);
        }

        return returnMap;

    }

    /***********************************************************************************************
    * Method Name : getUCEUserAttributeDetails
    * Description : Used to fetch the User Type and its realted attributes for UCE
    * Parameters  : Map<String, Object>     -   inputMap containing Offer Id
    * Return      : Map<String, Object>     -   ReturnMap with the User attribute details
    ***********************************************************************************************/
    private Map<String, Object> getUCEUserAttributeDetails(Map<String, Object> inputMap) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String existingUserTypeId = (String)inputMap.get('ListOfSelectedUser1');
        String offerId = (String)inputMap.get('Offer Id');
        List<Object> attributesData = new List<Object>();
        String userType = '';
        
        for (cspmb__Price_Item__c pi : [SELECT Name,Type__c FROM cspmb__Price_Item__c WHERE cspmb__Is_Active__c = TRUE AND cspmb__Product_Definition_Name__c = 'User' AND Package_Name__c = 'Telstra Collaboration' AND Type__c = 'User' AND cspmb__Effective_End_Date__c >= TODAY AND cspmb__Effective_Start_Date__c <= TODAY LIMIT 1]) {
            userType = pi.Type__c;
            Map<String, Object> attribute1 = new Map<String, Object>();
            Map<String, Object> attribute1Values = new Map<String, Object>();
            attribute1.put('name','TypeUser');
            attribute1Values.put('value', pi.Id);
            attribute1Values.put('displayValue', pi.Type__c);
            attribute1Values.put('readOnly', true);
            attribute1Values.put('required', false);
            attribute1.put('value',attribute1Values);
            attributesData.add(attribute1);
            Map<String, Object> attribute2 = new Map<String, Object>();
            Map<String, Object> attribute2Values = new Map<String, Object>();
            attribute2.put('name','Quantity');
            attribute2Values.put('value', 1);
            attribute2Values.put('displayValue', 1);
            attribute2Values.put('readOnly', false);
            attribute2Values.put('required', false);
            attribute2.put('value',attribute2Values);
            attributesData.add(attribute2);
            Map<String, Object> attribute3 = new Map<String, Object>();
            Map<String, Object> attribute3Values = new Map<String, Object>();
            attribute3.put('name','ListOfSelectedUser1');
            attribute3Values.put('value', String.isNotBlank(existingUserTypeId) ? existingUserTypeId+pi.Id+',' : pi.Id+',');
            attribute3Values.put('displayValue', String.isNotBlank(existingUserTypeId) ? existingUserTypeId+pi.Id+',' : pi.Id+',');
            attribute3Values.put('readOnly', true);
            attribute3Values.put('required', false);
            attribute3.put('value',attribute3Values);
            attributesData.add(attribute3);
        }
        List<cspmb__Price_Item__c> userPIs = [SELECT Id, Name, cspmb__recurring_charge__c, Type__c, Zone__c, Frequency__c FROM cspmb__Price_Item__c WHERE Type__c = :userType  LIMIT 1];
        if (userPIs != NULL && !userPIs.isEmpty()) {
            cspmb__Price_Item__c userPI = userPIs[0];
            Map<String, Object> attribute5 = new Map<String, Object>();
            Map<String, Object> attribute5Values = new Map<String, Object>();
            attribute5.put('name','UnitPrice');
            attribute5Values.put('value', userPI.cspmb__recurring_charge__c);
            attribute5Values.put('displayValue', userPI.cspmb__recurring_charge__c);
            attribute5Values.put('readOnly', true);
            attribute5Values.put('required', false);
            attribute5.put('value',attribute5Values);
            attributesData.add(attribute5);
            Map<String, Object> attribute6 = new Map<String, Object>();
            Map<String, Object> attribute6Values = new Map<String, Object>();
            attribute6.put('name','Frequency');
            attribute6Values.put('value' , userPI.Frequency__c);
            attribute6Values.put('displayValue', userPI.Frequency__c);
            attribute6Values.put('readOnly', true);
            attribute6Values.put('required', false);
            attribute6.put('value',attribute6Values);
            attributesData.add(attribute6);
        }
        returnMap.put('User', attributesData);
        System.debug('Final Output : '+ JSON.serialize(attributesData));
        return returnMap;
    }
    
    /***********************************************************************************************
    * Method Name : getUserAttributeDetails
    * Description : Used to fetch the Fixed Seat User Type and its realted attributes
    * Parameters  : Map<String, Object>     -   inputMap containing Zone from IP Site
    * Return      : Map<String, Object>     -   ReturnMap with the Fixed Seat User attribute details
    ***********************************************************************************************/
    private Map<String, Object> getUserAttributeDetails(Map<String, Object> inputMap) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String existingUserTypeId = (String)inputMap.get('ListOfSelectedUser1');
        String siteNetworkZone = (String)inputMap.get('siteNetworkZone');
        List<Object> attributesData = new List<Object>();
        String userType = '';
        String userZone = siteNetworkZone;
        for (cspmb__Price_Item__c pi : [SELECT Name,Type__c FROM cspmb__Price_Item__c WHERE cspmb__Is_Active__c = TRUE AND cspmb__Product_Definition_Name__c = 'User' AND Package_Name__c = 'Connected Workplace' AND Type__c = 'Fixed Seat' AND cspmb__Effective_End_Date__c >= TODAY AND cspmb__Effective_Start_Date__c <= TODAY LIMIT 1]) {
            userType = pi.Type__c;
            Map<String, Object> attribute1 = new Map<String, Object>();
            Map<String, Object> attribute1Values = new Map<String, Object>();
            attribute1.put('name','TypeUser');
            attribute1Values.put('value', pi.Id);
            attribute1Values.put('displayValue', pi.Type__c);
            attribute1Values.put('readOnly', true);
            attribute1Values.put('required', false);
            attribute1.put('value',attribute1Values);
            attributesData.add(attribute1);
            Map<String, Object> attribute2 = new Map<String, Object>();
            Map<String, Object> attribute2Values = new Map<String, Object>();
            attribute2.put('name','Quantity');
            attribute2Values.put('value', 3);
            attribute2Values.put('displayValue', 3);
            attribute2Values.put('readOnly', false);
            attribute2Values.put('required', false);
            attribute2.put('value',attribute2Values);
            attributesData.add(attribute2);
            Map<String, Object> attribute3 = new Map<String, Object>();
            Map<String, Object> attribute3Values = new Map<String, Object>();
            attribute3.put('name','ListOfSelectedUser1');
            attribute3Values.put('value', String.isNotBlank(existingUserTypeId) ? existingUserTypeId+pi.Id+',' : pi.Id+',');
            attribute3Values.put('displayValue', String.isNotBlank(existingUserTypeId) ? existingUserTypeId+pi.Id+',' : pi.Id+',');
            attribute3Values.put('readOnly', true);
            attribute3Values.put('required', false);
            attribute3.put('value',attribute3Values);
            attributesData.add(attribute3);
            Map<String, Object> attribute4 = new Map<String, Object>();
            Map<String, Object> attribute4Values = new Map<String, Object>();
            attribute4.put('name','ZonefromParent');
            attribute4Values.put('value', siteNetworkZone);
            attribute4Values.put('displayValue', siteNetworkZone);
            attribute4Values.put('readOnly', true);
            attribute4Values.put('required', false);
            attribute4.put('value',attribute4Values);
            attributesData.add(attribute4);
        }
        List<cspmb__Price_Item__c> userPIs = [SELECT Id, Name, cspmb__recurring_charge__c, Type__c, Zone__c, Frequency__c FROM cspmb__Price_Item__c WHERE Type__c = :userType AND Zone__c = :userZone LIMIT 1];
        if (userPIs != NULL && !userPIs.isEmpty()) {
            cspmb__Price_Item__c userPI = userPIs[0];
            Map<String, Object> attribute5 = new Map<String, Object>();
            Map<String, Object> attribute5Values = new Map<String, Object>();
            attribute5.put('name','UnitPrice');
            attribute5Values.put('value', userPI.cspmb__recurring_charge__c);
            attribute5Values.put('displayValue', userPI.cspmb__recurring_charge__c);
            attribute5Values.put('readOnly', true);
            attribute5Values.put('required', false);
            attribute5.put('value',attribute5Values);
            attributesData.add(attribute5);
            Map<String, Object> attribute6 = new Map<String, Object>();
            Map<String, Object> attribute6Values = new Map<String, Object>();
            attribute6.put('name','Frequency');
            attribute6Values.put('value' , userPI.Frequency__c);
            attribute6Values.put('displayValue', userPI.Frequency__c);
            attribute6Values.put('readOnly', true);
            attribute6Values.put('required', false);
            attribute6.put('value',attribute6Values);
            attributesData.add(attribute6);
        }
        returnMap.put('User', attributesData);
        System.debug('Final Output : '+ JSON.serialize(attributesData));
        return returnMap;
    }

    /***********************************************************************************************
    * Method Name : getUserUnitPrice
    * Description : Used to fetch the Unit Price for the selected User Type
    * Parameters  : Map<String, Object>     -   inputMap containing Zone from IP Site and User Type
    * Return      : Map<String, Object>     -   ReturnMap with the Unit Price of selected User Type
    ***********************************************************************************************/
    private Map<String, Object> getUserUnitPrice(Map<String, Object> inputMap) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String userType = (String)inputMap.get('TypeUser');
        String userZone = (String)inputMap.get('ZonefromParent');
        List<Object> attributesData = new List<Object>();
        for (cspmb__Price_Item__c pi : [SELECT Id, Name, cspmb__recurring_charge__c, Type__c, Zone__c, Frequency__c FROM cspmb__Price_Item__c WHERE Type__c = :userType AND Zone__c = :userZone LIMIT 1]) {
            List<Map<String, Object>> outputData = new List<Map<String, Object>>();
            Map<String, Object> attribute1 = new Map<String, Object>();
            Map<String, Object> attribute1Values = new Map<String, Object>();
            attribute1.put('name','UnitPrice');
            attribute1Values.put('value' , pi.cspmb__recurring_charge__c);
            attribute1Values.put('displayValue', pi.cspmb__recurring_charge__c);
            attribute1Values.put('readOnly', true);
            attribute1Values.put('required', false);
            attribute1.put('value',attribute1Values);
            attributesData.add(attribute1);
            Map<String, Object> attribute2 = new Map<String, Object>();
            Map<String, Object> attribute2Values = new Map<String, Object>();
            attribute2.put('name','Frequency');
            attribute2Values.put('value' , pi.Frequency__c);
            attribute2Values.put('displayValue', pi.Frequency__c);
            attribute2Values.put('readOnly', true);
            attribute2Values.put('required', false);
            attribute2.put('value',attribute2Values);
            attributesData.add(attribute2);
        }
        returnMap.put('User', attributesData);
        System.debug('Final Output : '+ JSON.serialize(attributesData));
        return returnMap;
    }

    /********************************************************************************************************
    * Method Name : getIPSiteBandwidth
    * Description : Used to fetch the Bandwidth on IP Site
    * Parameters  : Map<String, Object>     -   inputMap containing Bandwidth Tier & Fixed Seat User Quantity
    * Return      : Map<String, Object>     -   ReturnMap with the Bandwidth fetched
    ********************************************************************************************************/
    private Map<String, Object> getIPSiteBandwidth(Map<String, Object> inputMap) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String countTotalUserQtyStr = (String)inputMap.get('CountTotalUserQty');
        String tierSelectedStr = String.valueOf(inputMap.get('TierSelected'));
        String technology = (String)inputMap.get('Technology');
        String technologyType = (String)inputMap.get('TechnologyType');
        Decimal countTotalUserQty = Decimal.valueOf(countTotalUserQtyStr);
        Integer tierSelected = Integer.valueOf(tierSelectedStr);
        List<Object> attributesData = new List<Object>();
        Bandwidth_Calculation__c bwCalc;
        if (technology == 'NBN Access') {
            bwCalc = [SELECT Id, Name, Bandwidth__c, Bandwidth_value__c, Router_Model__c, Router_Vendor__c, Count_Bandwidth_Clip_On__c, Max_User_Count__c, Min_User_Count__c, Technology__c FROM Bandwidth_Calculation__c WHERE Count_Bandwidth_Clip_On__c = :tierSelected AND Max_User_Count__c >= :countTotalUserQty AND Min_User_Count__c <= :countTotalUserQty AND Technology__c = :technology AND Technology_Type__c = :technologyType LIMIT 1];
        } else  if (technology == 'Mobile Access') {
            bwCalc = [SELECT Id, Name, Bandwidth__c, Bandwidth_value__c, Router_Model__c, Router_Vendor__c, Count_Bandwidth_Clip_On__c, Max_User_Count__c, Min_User_Count__c, Technology__c FROM Bandwidth_Calculation__c WHERE  Max_User_Count__c >= :countTotalUserQty AND Min_User_Count__c <= :countTotalUserQty AND Technology__c = :technology LIMIT 1];
        } else {
            bwCalc = [SELECT Id, Name, Bandwidth__c, Bandwidth_value__c, Router_Model__c, Router_Vendor__c, Count_Bandwidth_Clip_On__c, Max_User_Count__c, Min_User_Count__c, Technology__c FROM Bandwidth_Calculation__c WHERE Count_Bandwidth_Clip_On__c = :tierSelected AND Max_User_Count__c >= :countTotalUserQty AND Min_User_Count__c <= :countTotalUserQty AND Technology__c = :technology LIMIT 1];
        }

       // for (Bandwidth_Calculation__c bwCalc : [SELECT Id, Name, Bandwidth__c, Bandwidth_value__c, Router_Model__c, Router_Vendor__c, Count_Bandwidth_Clip_On__c, Max_User_Count__c, Min_User_Count__c, Technology__c FROM Bandwidth_Calculation__c WHERE Count_Bandwidth_Clip_On__c = :tierSelected AND Max_User_Count__c > :countTotalUserQty AND Min_User_Count__c < :countTotalUserQty AND Technology__c = :technology LIMIT 1]) {
        if (bwCalc != null) {
            System.debug('Inside For Loop');
            List<Map<String, Object>> outputData = new List<Map<String, Object>>();
            Map<String, Object> attribute1 = new Map<String, Object>();
            Map<String, Object> attribute1Values = new Map<String, Object>();
            attribute1.put('name','Bandwidth');
            attribute1Values.put('value' , bwCalc.Bandwidth__c);
            attribute1Values.put('displayValue', bwCalc.Bandwidth__c);
            attribute1Values.put('readOnly', true);
            attribute1Values.put('required', false);
            attribute1.put('value',attribute1Values);
            attributesData.add(attribute1);
            Map<String, Object> attribute2 = new Map<String, Object>();
            Map<String, Object> attribute2Values = new Map<String, Object>();
            attribute2.put('name','Router Model');
            attribute2Values.put('value' , bwCalc.Router_Model__c);
            attribute2Values.put('displayValue', bwCalc.Router_Model__c);
            attribute2Values.put('readOnly', true);
            attribute2Values.put('required', false);
            attribute2.put('value',attribute2Values);
            attributesData.add(attribute2);
            Map<String, Object> attribute3 = new Map<String, Object>();
            Map<String, Object> attribute3Values = new Map<String, Object>();
            attribute3.put('name','Router Vendor');
            attribute3Values.put('value' , bwCalc.Router_Vendor__c);
            attribute3Values.put('displayValue', bwCalc.Router_Vendor__c);
            attribute3Values.put('readOnly', true);
            attribute3Values.put('required', false);
            attribute3.put('value',attribute3Values);
            attributesData.add(attribute3);
        }
        returnMap.put('IPSite', attributesData);
        System.debug('Return Map : ' + returnMap);
        System.debug('Final Output : '+ JSON.serialize(attributesData));
        return returnMap;
    }

    /****************************************************************************************
    * Method Name : getUserTotalETC
    * Description : Used to fetch the Total ETC on User
    * Parameters  : Map<String, Object>     -   inputMap containing required params from User
    * Return      : Map<String, Object>     -   ReturnMap with the Total ETC of User
    ****************************************************************************************/
    private Map<String, Object> getUserTotalETC(Map<String, Object> inputMap) {
        Map<String, Object> returnMap = new Map<String, Object>();
        Integer userQty = Integer.valueOf((String)inputMap.get('Quantity'));
        String userType = (String)inputMap.get('TypeUser');
        Date disconnectionDate = Date.valueOf((String)inputMap.get('DisconnectionDate'));
        String prodConfigId = (String)inputMap.get('ProdConfigId');
        System.debug('userQty=' + userQty + ', userType=' + userType + ', disconnectionDate=' + disconnectionDate + ', prodConfigId=' + prodConfigId);
        List<Object> attributesData = new List<Object>();
        if (String.isNotEmpty(prodConfigId) && disconnectionDate != NULL) {
            System.debug('Inside main if');
            List<cscfga__Product_Configuration__c> configs = [SELECT Id, Name, csordtelcoa__replaced_product_configuration__c FROM cscfga__Product_Configuration__c WHERE Id = :prodConfigId LIMIT 1];
            cscfga__Product_Configuration__c replacedConfig = configs != NULL && !configs.isEmpty() ? configs[0] : NULL;
            System.debug('replacedConfig=' + replacedConfig);
            if (replacedConfig != NULL) {
                List<csord__Service__c> services = [SELECT Id, Name, csord__subscription__r.right_to_bill_date__c FROM csord__Service__c WHERE csordtelcoa__Product_Configuration__c = :replacedConfig.csordtelcoa__replaced_product_configuration__c];
                csord__Service__c service = services != NULL && !services.isEmpty() ? services[0] : NULL;
                System.debug('service=' + service);
                if (service != NULL && service.csord__subscription__r.right_to_bill_date__c != NULL) {
                    Date rightToBillDate = Date.valueOf(service.csord__subscription__r.right_to_bill_date__c);
                    Integer noOfMonths = rightToBillDate.monthsBetween(disconnectionDate);
                    System.debug('noOfMonths=' + noOfMonths);
                    noOfMonths = disconnectionDate >= rightToBillDate ? noOfMonths + 1 : noOfMonths;
                    Integer etcServicePeriod;
                    if (noOfMonths < 0) {
                        etcServicePeriod = 0;
                    }
                    else {
                        etcServicePeriod = noOfMonths;
                    }
                    System.debug('etcServicePeriod=' + etcServicePeriod);
                    List<cspmb__Price_Item__c> userPIs = [SELECT Id, Name, cspmb__one_off_charge__c, Unit_Of_Measure__c FROM cspmb__Price_Item__c WHERE billingSubtype__c = 'ETC' AND From_Duration__c <= :etcServicePeriod AND To_Duration__c >= :etcServicePeriod AND Unit_Of_Measure__c IN ('Per Fix Seat', 'Per Site')];
                    Decimal perUserETC = 0.0, fixedETC = 0.0;
                    System.debug('userPIs=' + userPIs);
                    for(cspmb__Price_Item__c userPI : userPIs) {
                        if (userPI.Unit_Of_Measure__c != NULL && userPI.Unit_Of_Measure__c.equalsIgnoreCase('Per Fix Seat')) {
                            perUserETC = userPI.cspmb__one_off_charge__c;
                        }
                        else if (userPI.Unit_Of_Measure__c != NULL && userPI.Unit_Of_Measure__c.equalsIgnoreCase('Per Site')) {
                            fixedETC = userPI.cspmb__one_off_charge__c;
                        }
                    }
                    System.debug('perUserETC=' + perUserETC);
                    System.debug('fixedETC=' + fixedETC);
                    userQty = userQty != NULL ? userQty : 0;
                    perUserETC = perUserETC != NULL ? perUserETC : 0.0;
                    fixedETC = fixedETC != NULL ? fixedETC : 0.00;
                    Decimal totalETC = (userQty * perUserETC) + fixedETC;
                    Map<String, Object> attribute1 = new Map<String, Object>();
                    Map<String, Object> attribute1Values = new Map<String, Object>();
                    attribute1.put('name','TotalETC');
                    attribute1Values.put('value' , totalETC);
                    attribute1Values.put('displayValue', totalETC);
                    attribute1Values.put('readOnly', true);
                    attribute1Values.put('required', false);
                    attribute1.put('value',attribute1Values);
                    attributesData.add(attribute1);
                }
            }
        }
        returnMap.put('User', attributesData);
        System.debug('Final Output : '+ JSON.serialize(attributesData));
        return returnMap;
    }
    
    /*************************************************************************************************
    * Method Name : getDeviceMROBonus
    * Description : Used to fetch the MRO Bonus for the selected Plan and Device
    * Parameters  : Map<String, Object>     -   inputMap containing selected DeviceId & PlanId 
    * Return      : Map<String, Object>     -   ReturnMap with the MRO Bonus of selected Plan & Device
    *************************************************************************************************/
    private Map<String, Object> getDeviceMROBonus(Map<String, Object> inputMap) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String deviceId = (String)inputMap.get('DeviceId');
        String planId = (String)inputMap.get('PlanId');
        System.debug('deviceId ' + deviceId);
        System.debug('planId ' + planId);
        List<Object> attributesData = new List<Object>();
        //Start: EDGE-93036 changes to Attribute mapping and SOQL query to replace Device Plan association to Product to Product Association object
        Product_To_Product_Association__c discountDetail = [SELECT Id, Name, Governing_Product__c, Governed_Product__c, Governed_Attribute_Name__c,  Governed_Attribute_Value_Type__c, One_Off_Charge__c, Recurring_Charge__c FROM Product_To_Product_Association__c WHERE Governing_Product__c =:deviceId AND Governed_Product__c =:planId AND Governed_Attribute_Name__c = 'PlanDiscount' AND Check_todays_date__c = true LIMIT 1];
        if(discountDetail != null){    
        List<Map<String, Object>> outputData = new List<Map<String, Object>>();
                Map<String, Object> attribute1 = new Map<String, Object>();
                Map<String, Object> attribute1Values = new Map<String, Object>();
                attribute1.put('name','TotalPlanBonus');
                attribute1Values.put('value' , discountDetail.Recurring_Charge__c);
                attribute1Values.put('displayValue', discountDetail.Recurring_Charge__c);
                attribute1Values.put('readOnly', true);
                attribute1Values.put('required', false);
                attribute1.put('value',attribute1Values);
                attributesData.add(attribute1);
            //End: EDGE-93036
            returnMap.put('MRO Bonus', attributesData);
        }
        System.debug('Final Output : '+ JSON.serialize(attributesData));
        return returnMap;
    }
}