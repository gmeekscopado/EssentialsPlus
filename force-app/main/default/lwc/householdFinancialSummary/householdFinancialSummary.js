import { LightningElement, api, wire } from 'lwc';
import getHouseholdSummary from '@salesforce/apex/HouseholdFinancialSummaryController.getHouseholdSummary';

export default class HouseholdFinancialSummary extends LightningElement {
    @api recordId;
    summary;
    error;

    @wire(getHouseholdSummary, { accountId: '$recordId' })
    wiredSummary({ error, data }) {
        if (data) {
            this.summary = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.summary = undefined;
            console.error('Error loading household summary:', error);
        }
    }

    get hasData() {
        return this.summary && this.summary.totalAUM > 0;
    }
}