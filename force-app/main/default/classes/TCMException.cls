/**
* @Description : Get Customer and Contacts from TCM application based on CIDN and insert/update in Force.com.
* @Author : ChandrakanthReddy B.
* @Date : 14/Nov/2017
* @Story : EDGE-4090
*/
public class TCMException extends Exception {

    public class TCMCustomerCreationException extends Exception{}
    public class TCMContactCreationException extends Exception{}
    public class TCMCallOutException extends Exception{}

}