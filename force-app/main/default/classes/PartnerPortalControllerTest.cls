@isTest
private class PartnerPortalControllerTest {
    
    @isTest
    static void testGetSecurityMetrics_Success() {
        Test.startTest();
        Map<String, String> metrics = PartnerPortalController.getSecurityMetrics();
        Test.stopTest();
        
        System.assertNotEquals(null, metrics, 'Metrics should not be null');
        System.assertEquals(4, metrics.size(), 'Should return 4 metrics');
        System.assert(metrics.containsKey('endpointsProtected'), 'Should contain endpointsProtected metric');
        System.assert(metrics.containsKey('threatsBlocked'), 'Should contain threatsBlocked metric');
        System.assert(metrics.containsKey('activePartners'), 'Should contain activePartners metric');
        System.assert(metrics.containsKey('uptimeSLA'), 'Should contain uptimeSLA metric');
        System.assertEquals('9M+', metrics.get('endpointsProtected'), 'Endpoints protected should be 9M+');
        System.assertEquals('2B+', metrics.get('threatsBlocked'), 'Threats blocked should be 2B+');
        System.assertEquals('500+', metrics.get('activePartners'), 'Active partners should be 500+');
        System.assertEquals('99.9%', metrics.get('uptimeSLA'), 'Uptime SLA should be 99.9%');
    }
    
    @isTest
    static void testGetFeaturedResources_Success() {
        Test.startTest();
        List<PartnerPortalController.ResourceWrapper> resources = PartnerPortalController.getFeaturedResources();
        Test.stopTest();
        
        System.assertNotEquals(null, resources, 'Resources should not be null');
        System.assertEquals(4, resources.size(), 'Should return 4 resources');
        
        PartnerPortalController.ResourceWrapper firstResource = resources[0];
        System.assertEquals('1', firstResource.Id, 'First resource ID should be 1');
        System.assertEquals('N-central RMM Best Practices', firstResource.Title, 'First resource title should match');
        System.assertNotEquals(null, firstResource.Description, 'Description should not be null');
        System.assertEquals('Guide', firstResource.Type, 'Type should be Guide');
        System.assertEquals('doctype:pdf', firstResource.Icon, 'Icon should be doctype:pdf');
        
        for (PartnerPortalController.ResourceWrapper resource : resources) {
            System.assertNotEquals(null, resource.Id, 'Resource ID should not be null');
            System.assertNotEquals(null, resource.Title, 'Resource title should not be null');
            System.assertNotEquals(null, resource.Description, 'Resource description should not be null');
            System.assertNotEquals(null, resource.Type, 'Resource type should not be null');
            System.assertNotEquals(null, resource.Icon, 'Resource icon should not be null');
        }
    }
    
    @isTest
    static void testGetSecurityAlerts_Success() {
        Test.startTest();
        List<PartnerPortalController.SecurityAlertWrapper> alerts = PartnerPortalController.getSecurityAlerts();
        Test.stopTest();
        
        System.assertNotEquals(null, alerts, 'Alerts should not be null');
        System.assertEquals(4, alerts.size(), 'Should return 4 alerts');
        
        PartnerPortalController.SecurityAlertWrapper firstAlert = alerts[0];
        System.assertEquals('1', firstAlert.id, 'First alert ID should be 1');
        System.assertEquals('Critical Ransomware Variant Detected', firstAlert.title, 'First alert title should match');
        System.assertNotEquals(null, firstAlert.description, 'Description should not be null');
        System.assertEquals('critical', firstAlert.severity, 'Severity should be critical');
        System.assertNotEquals(null, firstAlert.timestamp, 'Timestamp should not be null');
        System.assertEquals('Threat Intelligence', firstAlert.category, 'Category should be Threat Intelligence');
        
        for (PartnerPortalController.SecurityAlertWrapper alert : alerts) {
            System.assertNotEquals(null, alert.id, 'Alert ID should not be null');
            System.assertNotEquals(null, alert.title, 'Alert title should not be null');
            System.assertNotEquals(null, alert.description, 'Alert description should not be null');
            System.assertNotEquals(null, alert.severity, 'Alert severity should not be null');
            System.assertNotEquals(null, alert.timestamp, 'Alert timestamp should not be null');
            System.assertNotEquals(null, alert.category, 'Alert category should not be null');
        }
    }
    
    @isTest
    static void testResourceWrapper_Constructor() {
        Test.startTest();
        PartnerPortalController.ResourceWrapper resource = new PartnerPortalController.ResourceWrapper(
            'test-id',
            'Test Title',
            'Test Description',
            'Test Type',
            'test:icon'
        );
        Test.stopTest();
        
        System.assertEquals('test-id', resource.Id, 'ID should match constructor parameter');
        System.assertEquals('Test Title', resource.Title, 'Title should match constructor parameter');
        System.assertEquals('Test Description', resource.Description, 'Description should match constructor parameter');
        System.assertEquals('Test Type', resource.Type, 'Type should match constructor parameter');
        System.assertEquals('test:icon', resource.Icon, 'Icon should match constructor parameter');
    }
    
    @isTest
    static void testSecurityAlertWrapper_Constructor() {
        DateTime testTime = DateTime.now();
        
        Test.startTest();
        PartnerPortalController.SecurityAlertWrapper alert = new PartnerPortalController.SecurityAlertWrapper(
            'test-id',
            'Test Alert',
            'Test Description',
            'high',
            testTime,
            'Test Category'
        );
        Test.stopTest();
        
        System.assertEquals('test-id', alert.id, 'ID should match constructor parameter');
        System.assertEquals('Test Alert', alert.title, 'Title should match constructor parameter');
        System.assertEquals('Test Description', alert.description, 'Description should match constructor parameter');
        System.assertEquals('high', alert.severity, 'Severity should match constructor parameter');
        System.assertNotEquals(null, alert.timestamp, 'Timestamp should not be null');
        System.assertEquals('Test Category', alert.category, 'Category should match constructor parameter');
    }
}
