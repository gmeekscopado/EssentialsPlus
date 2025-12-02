public with sharing class PartnerPortalController {
    
    /**
     * Get security metrics for the dashboard
     * @return Map<String, String> containing metric data
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSecurityMetrics() {
        try {
            Map<String, String> metrics = new Map<String, String>();
            metrics.put('endpointsProtected', '9M+');
            metrics.put('threatsBlocked', '2B+');
            metrics.put('activePartners', '500+');
            metrics.put('uptimeSLA', '99.9%');
            
            return metrics;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving security metrics: ' + e.getMessage());
        }
    }
    
    /**
     * Get featured resources for partners
     * @return List<ResourceWrapper> containing resource information
     */
    @AuraEnabled(cacheable=true)
    public static List<ResourceWrapper> getFeaturedResources() {
        try {
            List<ResourceWrapper> resources = new List<ResourceWrapper>();
            
            resources.add(new ResourceWrapper(
                '1',
                'N-central RMM Best Practices',
                'Comprehensive guide to optimize your RMM deployment',
                'Guide',
                'doctype:pdf'
            ));
            
            resources.add(new ResourceWrapper(
                '2',
                'Cybersecurity Threat Report 2024',
                'Latest trends and mitigation strategies',
                'Report',
                'doctype:pdf'
            ));
            
            resources.add(new ResourceWrapper(
                '3',
                'Cove Data Protection Setup',
                'Step-by-step backup configuration guide',
                'Documentation',
                'doctype:pdf'
            ));
            
            resources.add(new ResourceWrapper(
                '4',
                'MSP Sales Enablement Kit',
                'Marketing materials and sales tools',
                'Kit',
                'doctype:zip'
            ));
            
            return resources;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving featured resources: ' + e.getMessage());
        }
    }
    
    /**
     * Get security alerts and notifications
     * @return List<SecurityAlertWrapper> containing alert information
     */
    @AuraEnabled(cacheable=true)
    public static List<SecurityAlertWrapper> getSecurityAlerts() {
        try {
            List<SecurityAlertWrapper> alerts = new List<SecurityAlertWrapper>();
            
            alerts.add(new SecurityAlertWrapper(
                '1',
                'Critical Ransomware Variant Detected',
                'New LockBit 4.0 variant targeting MSP infrastructure',
                'critical',
                DateTime.now().addHours(-1),
                'Threat Intelligence'
            ));
            
            alerts.add(new SecurityAlertWrapper(
                '2',
                'Security Patch Available',
                'N-central RMM version 2024.1 addresses CVE-2024-1234',
                'high',
                DateTime.now().addHours(-2),
                'Updates'
            ));
            
            alerts.add(new SecurityAlertWrapper(
                '3',
                'Compliance Alert',
                'SOC 2 audit documentation due in 14 days',
                'medium',
                DateTime.now().addDays(-1),
                'Compliance'
            ));
            
            alerts.add(new SecurityAlertWrapper(
                '4',
                'Best Practice Update',
                'New MFA guidelines for partner portal access',
                'low',
                DateTime.now().addDays(-2),
                'Security'
            ));
            
            return alerts;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving security alerts: ' + e.getMessage());
        }
    }
    
    /**
     * Wrapper class for resource data
     */
    public class ResourceWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Title { get; set; }
        @AuraEnabled public String Description { get; set; }
        @AuraEnabled public String Type { get; set; }
        @AuraEnabled public String Icon { get; set; }
        
        public ResourceWrapper(String id, String title, String description, String type, String icon) {
            this.Id = id;
            this.Title = title;
            this.Description = description;
            this.Type = type;
            this.Icon = icon;
        }
    }
    
    /**
     * Wrapper class for security alert data
     */
    public class SecurityAlertWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String severity { get; set; }
        @AuraEnabled public String timestamp { get; set; }
        @AuraEnabled public String category { get; set; }
        
        public SecurityAlertWrapper(String id, String title, String description, String severity, DateTime timestamp, String category) {
            this.id = id;
            this.title = title;
            this.description = description;
            this.severity = severity;
            this.timestamp = timestamp.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            this.category = category;
        }
    }
}
