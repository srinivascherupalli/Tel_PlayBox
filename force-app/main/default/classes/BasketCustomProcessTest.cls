@isTest
public class BasketCustomProcessTest {
    
    @testsetup static void testdata() {
        Marketable_Offer__c m1 = new Marketable_Offer__c ();
        m1.Name = 'Test';
        m1.Offer_ID__c = 'Test';
        insert m1;
    }
    
    static testMethod void skipValidationsTest() {
        test.startTest();
        set<string> mOffer = new set<String>();
        
        List<Marketable_Offer__c> mofferList = [SELECT id,Offer_ID__c,Config__c,Name from Marketable_Offer__c];
        
        for(Marketable_Offer__c moff :mofferList ){
            mOffer.add(moff.Name);
        }
        system.assertNotEquals(0, mOffer.size());
        
        BasketCustomProcess.isConfigOnlyBasket(moffer);
        test.stopTest();
    }
}