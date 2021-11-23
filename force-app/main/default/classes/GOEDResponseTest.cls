/****************************************************************************
@Name: GOEDResponseTest
@Author: Einstein Team(Khazan)
@CreateDate:
@Description: P2OB-1653 to see the Opportunity Scoring against each Opportunity
********************************************************************************/
@isTest
public class GOEDResponseTest {

    static testmethod void mainTest(){
        GOEDResponse res = new GOEDResponse();
        res.status = GOEDResponse.SUCCESS;
        res.msg = 'Successful!';         
        system.assertEquals(res.msg, 'Successful!');
    }
    
}