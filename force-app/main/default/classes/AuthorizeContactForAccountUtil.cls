public with sharing class AuthorizeContactForAccountUtil {

    public static AuthorizeContactResponse validate(String emailId, String cidn) {
        AuthorizeContactResponse retval;

        final AccountContactRelation acr = getACR(emailId, cidn);            
        retval = new AuthorizeContactResponse(APIConstants.AUTHORIZE_CONTACT_STATUS.VALID, system.label.Authorization_Success);
        retval.AccountId = acr.AccountId;
        retval.ContactId = acr.ContactId;
        retval.message = system.label.Authorization_Success;

        return retval;

    }

    public static AccountContactRelation getACR(String emailId, String cidn) {
        AccountContactRelation retval;
        String errorCode = '';

        try {
            // first query contacts based on email id
            final List<Contact> contactsList = ContactDataMapper.getContacts(emailId);

            if(contactsList.isEmpty()) {
                errorCode = 'AUTHERR_003';
            } else if(contactsList.size() != 1) {
                errorCode = 'AUTHERR_004';
            } else {
                // query AccountContactRelation object filtering on needed roles
                String contactId = contactsList.get(0).id;
                final List<AccountContactRelation> acrList = ContactDataMapper.getAuthorizedAccounts(contactId, cidn);

                if(acrList.isEmpty()) {
                    errorCode = 'AUTHERR_005';
                } else if(acrList.size() != 1) {
                    errorCode = 'AUTHERR_006';
                } else {
                    retval = acrList.get(0);
                }
            }

        } catch(Exception ex) {
            throw new AuthorizationException(system.label.Unexpected_Exception, ex);
        }

        if (null != errorCode && '' != errorCode) {
            throw new AuthorizationException(errorCode);
        }

        return retval;

    }

    public static AuthorizeContactResponse genErrorResponse(String code) {
        return new AuthorizeContactResponse(APIConstants.AUTHORIZE_CONTACT_STATUS.INVALID, code, true);
    }
}