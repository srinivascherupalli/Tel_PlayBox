@isTest
@testVisible  
private class MetadataServiceTest
{    
    /**
* Dummy Metadata API web service mock class 
**/ 
    @testVisible
    private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
            {
                if(request instanceof MetadataService.readMetadata_element)
                {
                    MetadataService.readMetadata_element requestReadMetadata_element  = 
                        (MetadataService.readMetadata_element) request;
                    if (requestReadMetadata_element.type_x == Constants_PLR.PROFILE) { 
                        MetadataService.ProfileLayoutAssignment pa = new MetadataService.ProfileLayoutAssignment();
                        pa.layout =EncodingUtil.urlencode('Contact-Account Layout','UTF-8');
                        pa.recordType = null;
                        MetadataService.ProfileLayoutAssignment[] pas = new  MetadataService.ProfileLayoutAssignment[]{pa};
                        MetadataService.Profile pf = new MetadataService.Profile();
                        pf.fullName = 'admin';
                        pf.layoutAssignments = pas;
                        MetadataService.Profile[] record = new MetadataService.Profile[]{pf};
                        MetadataService.ReadProfileResult RPR = new MetadataService.ReadProfileResult();
                        RPR.records = record;
                        MetadataService.readprofileResponse_element mockRes = new MetadataService.readprofileResponse_element();
                        mockRes.result = RPR;
                        mockRes.result.records = RPR.records;
                        response.put('response_x', mockRes);
                    }
                    else if (requestReadMetadata_element.type_x == Constants_PLR.LAYOUT) { 
                        MetadataService.layoutItem li = new MetadataService.layoutItem();
                        li.field ='';
                        MetadataService.LayoutItem[] lis = new MetadataService.LayoutItem[]{li};
                        MetadataService.layoutColumn lc =  new MetadataService.layoutColumn();
                        lc.layoutItems = lis;
                        MetadataService.layoutColumn[] lcs= new MetadataService.layoutColumn[]{lc};
                        MetadataService.layoutSection ls = new MetadataService.layoutSection();
                        ls.layoutColumns = lcs;
                        MetadataService.layoutSection[] lss = new MetadataService.layoutSection[]{ls}; 
                        MetadataService.MiniLayout ml = new MetadataService.MiniLayout();
                        ml.fields = new string[]{'Name'};
                        MetadataService.Layout ly = new MetadataService.Layout();
                        ly.layoutSections = lss;
                        Ly.fullName = 'Contact-Account Layout';
                        ly.miniLayout = ml;
                        MetadataService.Layout[] lys = new MetadataService.Layout[]{ly};
                        MetadataService.ReadLayoutResult RPR = new MetadataService.ReadLayoutResult();
                        RPR.records = lys;
                        MetadataService.readlayoutResponse_element mockRes = new MetadataService.readlayoutResponse_element();
                        mockRes.result = RPR;
                        mockRes.result.records = RPR.records;
                        response.put('response_x', mockRes);
                    }                    
                }
                return;
            }
    }
    
    
    @IsTest
    private static void testMetadaReadOperations()
    {   
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        MetadataService metaDataService = new MetadataService();
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.readMetadata('Profile',null);
    }
    
    @IsTest
    private static void testGeneratedCodeTypes()
    {              
        // Reference types
        new MetadataService();
        new  MetadataService.ProfileExternalDataSourceAccess();
        new  MetadataService.Profile();
        new  MetadataService.LogInfo();
        new  MetadataService.ProfileLoginIpRange();
        new  MetadataService.readLayoutResponse_element();
        new  MetadataService.ReadLayoutResult();
        new  MetadataService.ProfileTabVisibility();
        new  MetadataService.ProfileApexPageAccess();
        new  MetadataService.ProfileRecordTypeVisibility();
        new  MetadataService.SessionHeader_element();
        new  MetadataService.DebuggingInfo_element();
        new  MetadataService.DebuggingHeader_element();
        new  MetadataService.CallOptions_element();
        new  MetadataService.AllOrNoneHeader_element();
        new  MetadataService.readMetadata_element();
        new  MetadataService.ReadProfileResult();
        new  MetadataService.readProfileResponse_element();
        new  MetadataService.ProfileObjectPermissions();
        new  MetadataService.ProfileApexClassAccess();
        new  MetadataService.ProfileFieldLevelSecurity();
        new  MetadataService.ProfileUserPermission();
        new  MetadataService.ProfileApplicationVisibility();
        new  MetadataService.ProfileLoginHours();
        new  MetadataService.ProfileLayoutAssignment();
        new  MetadataService.ProfileCustomPermissions();
        new  MetadataService.LayoutSection();
        new  MetadataService.LayoutColumn();
        new  MetadataService.LayoutItem();
        new  MetadataService.MiniLayout();
        new  MetadataService.RelatedListItem();
        new  MetadataService.CustomConsoleComponents();
        new  MetadataService.PrimaryTabComponents();
        new  MetadataService.Container();
        new  MetadataService.SidebarComponent();
        new  MetadataService.RelatedList();
        new  MetadataService.SubtabComponents();
        new  MetadataService.PlatformActionList();
        new  MetadataService.PlatformActionListItem();
        new  MetadataService.QuickActionList();
        new  MetadataService.QuickActionListItem();
        new  MetadataService.RelatedContent();
        new  MetadataService.RelatedContentItem();
        new  MetadataService.SummaryLayout();
        new  MetadataService.FeedLayout();
        new  MetadataService.FeedLayoutFilter();
        new  MetadataService.FeedLayoutComponent();
        new  MetadataService.SummaryLayoutItem();
        new  MetadataService.Layout();
    }
}