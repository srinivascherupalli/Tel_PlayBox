/*
 * This class implements the service to search on external object
 */
public class HandlerFindService implements BotHandler {
    
    // http://grahambarnard.com/development/2016/02/08/mocking-external-objects/
    public static List<WC_CSSA_ServicesFunction_VW__x> mockedRequests = new List<WC_CSSA_ServicesFunction_VW__x>();

    public BotResponse handle(String utterance, String[] params, Map<String, String> session) {
        String key = params[0];
        try {
         
            List<WC_CSSA_ServicesFunction_VW__x> services = ExternalSearchServiceRequest.findByServiceDescription(key);
        
            if (services != null && services.size() >0)
            {
                List<BotRecord> records = new List<BotRecord>();
        
                for (WC_CSSA_ServicesFunction_VW__x a : services) {
                    List<BotField> fields = new List<BotField>();
                    
                    fields.add(new BotField('Service Type', a.Svc_Type__c, '#/sObject/' + a.Id + '/view' ));
                    fields.add(new BotField('Plan Description', a.Plan1__c, '#/sObject/' + a.Id + '/view'));
                    fields.add(new BotField('CIDN', a.CIDN__c, '#/sObject/' + a.Id+ '/view'));
                    //fields.add(new BotField('Plan Description', a.Plan1__c));
                    //fields.add(new BotField('CIDN', a.CIDN__c));
                    
                    records.add(new BotRecord(fields));
                }
                return new BotResponse(new BotMessage('Bot', 'Here is a list of services matching "' + params[0] + '":', records));
            } else
                return new BotResponse(new BotMessage('Bot', 'Sorry, no results found.'));
        } catch (Exception e)
        {
            return new BotResponse(new BotMessage('Bot', 'Sorry, no results found.'));
        }
    }   
}