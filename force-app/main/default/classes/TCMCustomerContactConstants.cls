/**
* @Description : Get Customer and Contacts from TCM application based on CIDN and insert/update in Force.com.
* @Author : ChandrakanthReddy B.
* @Date : 14/Nov/2017
* @Story : EDGE-4090
*/

public with sharing class TCMCustomerContactConstants {
    
    public static final String TCMERRORCODE_FAILURE = 'Error';
    public static final String TCMERRORCODE_SUCCESS = 'Completed';
	public static final String TCM_CUSTOMER_SEEDING_SOURCEFROM = 'SEEDING';
    public static final String TCM_CUSTOMER_SFDCUI_SOURCEFROM ='SFDC_UI';
    
}