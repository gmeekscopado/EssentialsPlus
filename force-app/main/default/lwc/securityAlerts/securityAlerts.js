import { LightningElement, wire } from 'lwc';
import getSecurityAlerts from '@salesforce/apex/PartnerPortalController.getSecurityAlerts';

export default class SecurityAlerts extends LightningElement {
    alerts = [];
    error;

    @wire(getSecurityAlerts)
    wiredAlerts({ error, data }) {
        if (data) {
            this.alerts = data.map(alert => ({
                ...alert,
                severityClass: this.getSeverityClass(alert.severity),
                severityIcon: this.getSeverityIcon(alert.severity),
                timeAgo: this.getTimeAgo(alert.timestamp)
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.alerts = this.getDefaultAlerts();
        }
    }

    getDefaultAlerts() {
        const defaultData = [
            {
                id: '1',
                title: 'Critical Ransomware Variant Detected',
                description: 'New LockBit 4.0 variant targeting MSP infrastructure',
                severity: 'critical',
                timestamp: new Date(Date.now() - 3600000).toISOString(),
                category: 'Threat Intelligence'
            },
            {
                id: '2',
                title: 'Security Patch Available',
                description: 'N-central RMM version 2024.1 addresses CVE-2024-1234',
                severity: 'high',
                timestamp: new Date(Date.now() - 7200000).toISOString(),
                category: 'Updates'
            },
            {
                id: '3',
                title: 'Compliance Alert',
                description: 'SOC 2 audit documentation due in 14 days',
                severity: 'medium',
                timestamp: new Date(Date.now() - 86400000).toISOString(),
                category: 'Compliance'
            },
            {
                id: '4',
                title: 'Best Practice Update',
                description: 'New MFA guidelines for partner portal access',
                severity: 'low',
                timestamp: new Date(Date.now() - 172800000).toISOString(),
                category: 'Security'
            }
        ];

        return defaultData.map(alert => ({
            ...alert,
            severityClass: this.getSeverityClass(alert.severity),
            severityIcon: this.getSeverityIcon(alert.severity),
            timeAgo: this.getTimeAgo(alert.timestamp)
        }));
    }

    getSeverityClass(severity) {
        const classes = {
            critical: 'severity-critical',
            high: 'severity-high',
            medium: 'severity-medium',
            low: 'severity-low'
        };
        return classes[severity] || 'severity-low';
    }

    getSeverityIcon(severity) {
        const icons = {
            critical: 'utility:error',
            high: 'utility:warning',
            medium: 'utility:info',
            low: 'utility:info_alt'
        };
        return icons[severity] || 'utility:info';
    }

    getTimeAgo(timestamp) {
        const now = new Date();
        const then = new Date(timestamp);
        const diffMs = now - then;
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMs / 3600000);
        const diffDays = Math.floor(diffMs / 86400000);

        if (diffMins < 60) return `${diffMins}m ago`;
        if (diffHours < 24) return `${diffHours}h ago`;
        return `${diffDays}d ago`;
    }

    handleAlertClick(event) {
        const alertId = event.currentTarget.dataset.id;
        console.log('Alert clicked:', alertId);
    }
}
