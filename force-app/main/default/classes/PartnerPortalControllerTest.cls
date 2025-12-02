@isTest
private class PartnerPortalControllerTest {
    
    @isTest
    static void testGetSecurityMetrics_Success() {
        // Test successful retrieval of security metrics
        Test.startTest();
        Map<String, String> metrics = PartnerPortalController.getSecurityMetrics();
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, metrics, 'Metrics should not be null');
        System.assertEquals(4, metrics.size(), 'Should return 4 metrics');
        System.assert(metrics.containsKey('endpointsProtected'), 'Should contain endpointsProtected metric');
        System.assert(metrics.containsKey('threatsBlocked'), 'Should contain threatsBlocked metric');
        System.assert(metrics.containsKey('activePartners'), 'Should contain activePartners metric');
        System.assert(metrics.containsKey('uptimeSLA'), 'Should contain uptimeSLA metric');
        
        // Verify values
        System.assertEquals('9M+', metrics.get('endpointsProtected'), 'Endpoints protected should be 9M+');
        System.assertEquals('2B+', metrics.get('threatsBlocked'), 'Threats blocked should be 2B+');
        System.assertEquals('500+', metrics.get('activePartners'), 'Active partners should be 500+');
        System.assertEquals('99.9%', metrics.get('uptimeSLA'), 'Uptime SLA should be 99.9%');
    }
    
    @isTest
    static void testGetFeaturedResources_Success() {
        // Test successful retrieval of featured resources
        Test.startTest();
        List<PartnerPortalController.ResourceWrapper> resources = PartnerPortalController.getFeaturedResources();
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, resources, 'Resources should not be null');
        System.assertEquals(4, resources.size(), 'Should return 4 resources');
        
        // Verify first resource
        PartnerPortalController.ResourceWrapper firstResource = resources[0];
        System.assertEquals('1', firstResource.Id, 'First resource ID should be 1');
        System.assertEquals('N-central RMM Best Practices', firstResource.Title, 'First resource title should match');
        System.assertNotEquals(null, firstResource.Description, 'Description should not be null');
        System.assertEquals('Guide', firstResource.Type, 'Type should be Guide');
        System.assertEquals('doctype:pdf', firstResource.Icon, 'Icon should be doctype:pdf');
        
        // Verify all resources have required fields
        for (PartnerPortalController.ResourceWrapper resource : resources) {
            System.assertNotEquals(null, resource.Id, 'Resource ID should not be null');
            System.assertNotEquals(null, resource.Title, 'Resource title should not be null');
            System.assertNotEquals(null, resource.Description, 'Resource description should not be null');
            System.assertNotEquals(null, resource.Type, 'Resource type should not be null');
            System.assertNotEquals(null, resource.Icon, 'Resource icon should not be null');
        }
    }
    
    @isTest
    static void testResourceWrapper_Constructor() {
        // Test ResourceWrapper constructor
        Test.startTest();
        PartnerPortalController.ResourceWrapper resource = new PartnerPortalController.ResourceWrapper(
            'test-id',
            'Test Title',
            'Test Description',
            'Test Type',
            'test:icon'
        );
        Test.stopTest();
        
        // Assertions
        System.assertEquals('test-id', resource.Id, 'ID should match constructor parameter');
        System.assertEquals('Test Title', resource.Title, 'Title should match constructor parameter');
        System.assertEquals('Test Description', resource.Description, 'Description should match constructor parameter');
        System.assertEquals('Test Type', resource.Type, 'Type should match constructor parameter');
        System.assertEquals('test:icon', resource.Icon, 'Icon should match constructor parameter');
    }
    
    @isTest
    static void testGetSecurityMetrics_CacheableAnnotation() {
        // Verify that the method is cacheable by calling it multiple times
        Test.startTest();
        Map<String, String> metrics1 = PartnerPortalController.getSecurityMetrics();
        Map<String, String> metrics2 = PartnerPortalController.getSecurityMetrics();
        Test.stopTest();
        
        // Both calls should return the same data
        System.assertEquals(metrics1.size(), metrics2.size(), 'Both calls should return same number of metrics');
        System.assertEquals(metrics1.get('endpointsProtected'), metrics2.get('endpointsProtected'), 'Cached data should be consistent');
    }
    
    @isTest
    static void testGetFeaturedResources_CacheableAnnotation() {
        // Verify that the method is cacheable by calling it multiple times
        Test.startTest();
        List<PartnerPortalController.ResourceWrapper> resources1 = PartnerPortalController.getFeaturedResources();
        List<PartnerPortalController.ResourceWrapper> resources2 = PartnerPortalController.getFeaturedResources();
        Test.stopTest();
        
        // Both calls should return the same data
        System.assertEquals(resources1.size(), resources2.size(), 'Both calls should return same number of resources');
        System.assertEquals(resources1[0].Title, resources2[0].Title, 'Cached data should be consistent');
    }
}