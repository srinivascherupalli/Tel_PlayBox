@isTest
public class APTPS_TemplateTriggerHandlerTest {
    private static Apttus__APTS_Template__c initialTemplateSetup(){
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Name = 'Test';
        template.Apttus__Type__c = 'Clause';
        template.Apttus__TextContent__c = 'This is content';
        insert template;
        return template;
    }
    static testMethod void insertClausewithApttusTemplateTest(){
		Apttus__APTS_Template__c template = initialTemplateSetup();
        APTPS_TemplateTriggerHandler aggrTemplateTrigger = new APTPS_TemplateTriggerHandler();
        Map<Id,Apttus__APTS_Template__c> templateMap =  new Map<Id,Apttus__APTS_Template__c>();
        templateMap.put(template.Id, template);
        system.debug('templateMap :' + templateMap);
        String response = aggrTemplateTrigger.insertClausewithApttusTemplate(templateMap);
        system.assert(response == 'Success');
	}
    
    static testMethod void updateClausewithApttusTemplateTest(){
        Clause__c clause = new Clause__c();
        insert clause;
		Apttus__APTS_Template__c template = initialTemplateSetup();
        template.Apttus__TextContent__c = 'This is updated content';
        template.Clause__c = clause.id;
        update template;
        APTPS_TemplateTriggerHandler aggrTemplateTrigger = new APTPS_TemplateTriggerHandler();
        APTPS_TemplateTriggerHandler.isExecutingInsert = False;
        Map<Id,Apttus__APTS_Template__c> templateMap =  new Map<Id,Apttus__APTS_Template__c>();
        templateMap.put(template.Id, template);
        system.debug('templateMap :' + templateMap);
        String response = aggrTemplateTrigger.updateClausewithApttusTemplate(templateMap);
        system.assert(response == 'Success');
	}

}