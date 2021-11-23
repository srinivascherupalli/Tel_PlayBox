public with sharing class ServiceDetailsController {

    private Id serviceId;
    private csord__service__c service;

    public ServiceDetailsController(ApexPages.StandardController stdController) {
        this.serviceId = ((csord__service__c)stdController.getRecord()).id;
        this.service = [SELECT id, name, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Basket__c,
        csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.csordtelcoa__Screen_Flow_For_Service_Changes__r.name
        FROM csord__service__c
        WHERE id = :serviceId];
    }

    public PageReference initFlow() {
        String customUrl = '/apex/c__customConfiguration?cancelURL=%2F' + serviceId +
                '&ConfigId=' + service.csordtelcoa__Product_Configuration__c +
                '&linkedId='+ service.csordtelcoa__Product_Basket__c +
                '&retURL=%2F' + serviceId +
                '&ScreenFlowName=' + service.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.csordtelcoa__Screen_Flow_For_Service_Changes__r.name;
        PageReference enrichmentPage = new PageReference(customUrl);
        return enrichmentPage;
    }
}