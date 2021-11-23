public class SingleFNNListingHandler extends IntegrationQueueHandler{
    
    public SingleFNNListingHandler() {
        super(SingleFNNListingHandler.class.getName());
    }
    
    public override void executeWork(List<String> params) {
        system.debug('I am inside handler EDIS');
        String handlerName = 'SingleFNNListingHandler';
        System.debug('SingleFNNListingHandler::' + ':params:' + params +':handlerName:' + handlerName);
        EDISSingleService.callEDISSingleService(params.get(0),handlerName);
        
    }

}