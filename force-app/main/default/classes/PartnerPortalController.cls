public with sharing class PartnerPortalController {
    
    /**
     * Get security metrics for the dashboard
     * @return Map<String, String> containing metric data
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSecurityMetrics() {
        try {
            // In a real scenario, these would come from custom objects or external APIs
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
            
            // Sample resources - in production, these would come from ContentDocument or custom object
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
}