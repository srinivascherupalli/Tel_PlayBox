/*
Version     Team        Author              Description
1.0         Hawaii      Vivian Charlie      Initial Draft : DIGI-15298
*/
@isTest
public without sharing class PRMHawaiiUtilTest {
    public static testMethod void utilTest() {
        String strDomain = PRMHawaiiUtil.returnMetadataRecord('PRM_EOI_Visualforce_Domain');
        System.assertNotEquals(strDomain, null);
    }
}