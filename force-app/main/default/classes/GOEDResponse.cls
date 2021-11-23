/****************************************************************************
@Name: GOEDResponse
@Author: Einstein Team(Kazan)
@CreateDate:
@Description: P2OB-1653 to see the Opportunity Scoring against each Opportunity
********************************************************************************/

public class GOEDResponse {
    public static final String SUCCESS = 'SUCCESS';
    public static final String ERROR = 'ERROR';

    public String status = SUCCESS;
    public String msg = '';
    public Object data;
}