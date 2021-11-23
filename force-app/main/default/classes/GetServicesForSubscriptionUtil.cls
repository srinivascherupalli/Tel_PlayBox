public with sharing class GetServicesForSubscriptionUtil {

    public static GetServicesResponse getServicesForSubscription(String subscriptionId, String cidn) {
        GetServicesResponse retval;

        try {
            retval = CS_SubscriptionDataMapper.getServicesForSubscription(subscriptionId, cidn);
        } catch (Exception ex) {
            throw new GetServicesForSubscriptionException(ex.getMessage(), ex);
        }

        return retval;
    }

    public static GetServicesResponse genErrorResponse(String errCode, String errMsg) {
        return new GetServicesResponse(errCode, errMsg);
    }

}