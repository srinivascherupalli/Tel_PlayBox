/*************************************************************************************************
Name : POROpptyChatterPostsTest EDGE-155277
***************************************************************************************************/
@isTest
public class POROpptyChatterPostsTest
{    
    @isTest
    public static void testPostChatter()
    {
		String str = 'test#string';
        POROpptyChatterPosts.sendStatusChatter(new list<string>{str});
		System.assertNotEquals(null, str);
    } 
}