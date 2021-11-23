/********************************************************************************
* Class Name  : C2O_ProductConfigurationTrigger
* Description : C2O_ProductConfigurationTrigger executes logic on product configuration on before insert/update.   
* Created By  : Uday Dunna 
* Change Log  : Created
********************************************************************************/
trigger C2O_ProductConfigurationTrigger on cscfga__Product_Configuration__c (before insert,before update,after insert,after update) { 
    new C2O_ProductConfigurationTriggerHandler().run(); 
}