global with sharing class PREApiV4Pricings implements cssmgnt.RemoteActionDataProvider {

    @RemoteAction
    global static Map<String, Object> getData(Map<String, Object> inputMap) {
        system.debug('input'+ inputMap);
        String payload = inputMap.get('payload').toString();

        HttpResponse resp = RequestUtil.sendRequest(
            'POST',
            '/pre/v5/pricings',
            payload
        );

        return new Map<String, Object> {
            'status' => resp.getStatus(),
            'statusCode' => resp.getStatusCode(),
            'body' => resp.getBody()
        };
    }
}