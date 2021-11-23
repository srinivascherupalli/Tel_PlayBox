/*
===============================================================================================================================
Class : AutoRefreshConfiguratorCache
Developer Name : Rohit
Test Class : AutoRefreshConfiguratorCacheTest
===============================================================================================================================
Sr.No.   			 Developer Name         Modify Date          Story Description
1.Edge-98904		shubhi Vijayvergia		30/7/2019			Validate and save not working for PRM
===============================================================================================================================
*/
global with sharing class AutoRefreshConfiguratorCache implements Schedulable,Database.AllowsCallouts {

    global AutoRefreshConfiguratorCache() {
    }

    global void execute(SchedulableContext ctx) {
        List<csutil__JSON_Data__c> jsonData = [
            select id, csutil__value__c
            from csutil__JSON_Data__c
            where name = 'AutoRefreshConfiguratorCache'
        ];
        if (!jsonData.isEmpty()) {
            AutoRefreshConfiguratorCache.refreshConfiguratorCache();
            Datetime sysTime = System.now().addSeconds(500);
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule('AutoRefreshConfiguratorCache ' + sysTime, chronExpression, new AutoRefreshConfiguratorCache());
            System.abortJob(ctx.getTriggerId());
        }

    }

    @future(callout = true)
    public static void refreshConfiguratorCache() {

        List<csutil__JSON_Data__c> jsonData = [
            select id, csutil__value__c
            from csutil__JSON_Data__c
            where name = 'AutoRefreshConfiguratorCache'
        ];
        cssmgnt__SM_Options__c processingOptions = cssmgnt__SM_Options__c.getInstance(UserInfo.getUserId());
        if (!jsonData.isEmpty()) {
            cscfga__Product_Basket__c basket = [
                select id
                from cscfga__Product_Basket__c
                limit 1
            ];
            List<String> definitionIds = jsonData[0].csutil__value__c.split(',');
            for (String defId : definitionIds) {
                HttpRequest req = new HttpRequest();
                req.setTimeout(30000);
                req.setMethod(cssmgnt.Constants.HTTP_POST);
                req.setEndpoint(processingOptions.cssmgnt__endpoint__c + cssmgnt.Constants.EXECUTE_SCRIPT_ENDPOINT);
                Map<String, Object> requestMap = new Map<String, Object>();
                requestMap.put('definitionId', defId);
                requestMap.put('containerType', 'basket');
                requestMap.put('containerId', basket.id);
                requestMap.put('linkedObjectId', basket.id);
                requestMap.put('basketId', basket.id);
                requestMap.put('persistConfiguration', 'false');
                String script = 'return CS.Rules.evaluateAllRules();';
                requestMap.put('script', script);
                String body = JSON.serialize(requestMap);
                system.debug(LoggingLevel.ERROR, body);
                req.setBody(body);
                String payloadHash = cssmgnt.ConfiguratorHerokuServiceSecurity.calculateRsaPayloadHash(body, cssmgnt.Constants.HEROKU_CONTENT_TYPE);
                req.setHeader(
                    'Authorization',
                    cssmgnt.ConfiguratorHerokuServiceSecurity.generateRsaAuthorizationHeader(
                        processingOptions.cssmgnt__certificate_name__c,
                        UserInfo.getOrganizationId().substring(0, 15),
                        cssmgnt.Constants.HTTP_POST,
                        cssmgnt.Constants.EXECUTE_SCRIPT,
                        payloadHash
                    )
                );
                req.setHeader('content-type', cssmgnt.Constants.HEROKU_CONTENT_TYPE);
                req.setHeader('Username', UserInfo.getUserName());
                req.setHeader('Organization', UserInfo.getOrganizationId().substring(0, 15));
                Http http = new Http();
                HTTPResponse res = http.send(req);
                System.debug(res.getBody());
                System.debug('STATUS:' + res.getStatus());
                System.debug('STATUS_CODE:' + res.getStatusCode());
            }
        }
    }

}