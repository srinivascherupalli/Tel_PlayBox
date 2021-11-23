@IsTest
public class ReplicatorGetSiteDataObjectTest {
    
    static testMethod void parseTest() {
		String json = '{'+
        '    \"Correlation_Id\": \"123456\",'+
        '    \"CIDN\": \"212\",'+
        '    \"Ultimate_CIDN\": \"213\",'+
        '    \"Enterprise_Id\": \"553\",'+
        '    \"Error_Code\": \"\",'+
        '    \"Error_Description\": \"\",'+
        '    \"Site\": [{'+
        '        \"adbor_id\": \"111\",'+
        '        \"Media_Type\": \"NBN\",'+
        '        \"Site_Nick_Name\": \"Melbourne CBD\",'+
        '        \"Address_No_From\": \"22\",'+
        '        \"Address_No_To\": \"25\",'+
        '        \"Suffix_From\": \"\",'+
        '        \"Suffix_To\": \"\",'+
        '        \"Street_Name\": \"Lonsdale\",'+
        '        \"Street_Type\": \"Street\",'+
        '        \"Loc_Name\": \"\",'+
        '        \"ADBoR_Postcode\": \"3000\",'+
        '        \"State\": \"\",'+
        '        \"Name\": \"\",'+
        '        \"Address1\": \"\",'+
        '        \"Address2\": \"\",'+
        '        \"Sub1_CodeSet_Abbrev\": \"\",'+
        '        \"Sub1_Descriptor_1\": \"\",'+
        '        \"Sub1_Descriptor_2\": \"\",'+
        '        \"Sub2_CodeSet_Abbrev\": \"\",'+
        '        \"Sub2_Descriptor_1\": \"\",'+
        '        \"Sub2_Descriptor_2\": \"\",'+
        '        \"Sub3_CodeSet_Abbrev\": \"\",'+
        '        \"Sub3_Descriptor_1\": \"\",'+
        '        \"Sub3_Descriptor_2\": \"\",'+
        '        \"Sub4_CodeSet_Abbrev\": \"\",'+
        '        \"Sub4_Descriptor_1\": \"\",'+
        '        \"Sub4_Descriptor_2\": \"\",'+
        '        \"Disconnection_Date\": \"\",'+
        '        \"LastReplicator_UpdateDate\": \"\",'+        
        '        \"In_Flight_Order\": \"\",'+
        '        \"RFS_Site\": \"\",'+
        '        \"RFS_Date\": \"\",'+
        '        \"Serviceability\": \"\",'+
        '        \"NBN_Service_Type\": \"\",'+
        '        \"Disconnect_Wave\": \"\",'+
        '        \"Site_Address_Status\": \"\",'+
        '        \"NBN_Loc_Id\": \"\",'+
        '        \"Site_Composition\": \"\",'+
        '        \"Complex_Site_Flg\": \"\",'+
        '        \"Site_Migration_Flg\": \"\",'+
        '        \"Order_Stability_Date\": \"\",'+
        '        \"Service_Class\": \"\",'+
        '        \"Notes\": \"\",'+
        '        \"Error_Code\": \"\",'+
        '        \"Error_Description\": \"\",'+
        '        \"Contact\": [{'+
        '            \"Site_Contact_First_Name\": \"Ben\",'+
        '            \"Site_Contact_Last_Name\": \"Smith\",'+
        '            \"Site_Contact_Telephone\": \"0356789078\",'+
        '            \"Site_Contact_Mobile\": \"0456764532\",'+
        '            \"Site_Contact_Fax\": \"\",'+
        '            \"Site_Contact_Email\": \"ben.smith@gmail.com\"'+
        '        }]'+
        '    }]'+
        '}';     
        ReplicatorGetSiteDataObject obj = ReplicatorGetSiteDataObject.parse(json);
        System.debug('Obj: ' + obj.toString());
        
        ReplicatorGetSiteDataObject obj2 = new ReplicatorGetSiteDataObject();
        obj2.CIDN = '212';
        obj2.Enterprise_Id = '553';
        obj2.Error_Code = '';
        obj2.Error_Description = '';
        obj2.Site = new List<ReplicatorGetSiteDataObject.SiteDTO>();
        ReplicatorGetSiteDataObject.SiteDTO siteRec = new ReplicatorGetSiteDataObject.SiteDTO();
        siteRec.ADBoR_ID = '111';
        siteRec.Street_Name = 'Lonsdale';
        siteRec.Street_Type = 'Street';
        siteRec.ADBoR_Postcode = '3000';
        siteRec.State = '';
        siteRec.Name = '';
        siteRec.Site_Address_Status = '';
        siteRec.NBN_Location_Id = '';
        siteRec.Address_No_From = '22';
        siteRec.Address_No_To = '25';      
        siteRec.Loc_Name = '';
        siteRec.Suffix_From = '';
        siteRec.Suffix_To = '';
        siteRec.Media_Type = 'NBN';
        siteRec.Site_Nick_Name = 'Melbourne CBD';
        siteRec.Sub1_CodeSet_Abbrev = '';        
        siteRec.Sub1_Descriptor_1 = '';
        siteRec.Sub1_Descriptor_2 = '';
        siteRec.Sub2_CodeSet_abbrev = '';        
        siteRec.Sub2_Descriptor_1 = '';
        siteRec.Sub2_Descriptor_2 = '';               
        siteRec.Sub3_CodeSet_Abbrev = '';
        siteRec.Sub3_Descriptor_1 = '';
        siteRec.Sub3_Descriptor_2 = '';
        siteRec.Sub4_CodeSet_Abbrev = '';
        siteRec.Sub4_Descriptor_1 = '';
        siteRec.Sub4_Descriptor_2 = '';
        siteRec.Disconnection_Date = '';
        siteRec.LastReplicator_UpdateDate = '';
        siteRec.In_Flight_Order = '';
        siteRec.RFS_Date = '';
        siteRec.Serviceability = '';
        siteRec.NBN_Access_type = '';
        siteRec.Disconnect_Wave = '';
        siteRec.Site_Composition = '';
        siteRec.Complex_Site_Flag = '';
        siteRec.Site_Migration_Flag = '';
        siteRec.Order_Stability_Date = '';
        siteRec.Service_Class = '';
        siteRec.Error_Description = '';
        siteRec.Error_Code = '';
        siteRec.Contact  = new List<ReplicatorGetSiteDataObject.SiteContactDTO>();
        ReplicatorGetSiteDataObject.SiteContactDTO contactRec = new ReplicatorGetSiteDataObject.SiteContactDTO();
        contactRec.Site_Contact_First_Name = 'Ben';
        contactRec.Site_Contact_Last_Name = 'Smith';
        contactRec.Site_Contact_Telephone = '0356789078';
        contactRec.Site_Contact_Mobile = '0456764532';
        contactRec.Site_Contact_Fax = '';
        contactRec.Site_Contact_Email = 'ben.smith@gmail.com';
        siteRec.Contact.add(contactRec);
        obj2.Site.add(siteRec);     
        System.debug('Obj2: ' + obj2.toString());
        System.assert(!obj.equals(obj2), 'Error during JSON parsing');
    }
}