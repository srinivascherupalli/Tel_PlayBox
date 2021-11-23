/*********************************************************************************************************************************
*Class Name      :   EventMSCallBackDTO
Test Class : EventMSCallBackDTOTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Prajakta Patil          12/12/2019       EDGE-115932
*********************************************************************************************************************************
*/
// EventMSCallBack platform event DTO
// 
public class EventMSCallBackDTO {

    public String msCorrelationId;
    public String orderItemId;
    public String status;

    
    public static List<EventMSCallBackDTO> parse(String json) {
        return (List<EventMSCallBackDTO>) System.JSON.deserialize(json, List<EventMSCallBackDTO>.class);
    }
}