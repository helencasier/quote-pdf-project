public with sharing class QuoteController {
    public Quote quote { get; set; }
    public Boolean hasDiscounts { get; set; }
    public String currentUserEmail { get; set; }
    public String preparedByDisplay { get; set; }
    public String primaryContactName { get; set; }
    public String primaryContactEmail { get; set; }
    public List<QuoteLineItemWrapper> wrappedLineItems { get; set; }
    public Legal_document__c legalTerms { get; set; }
    public Boolean isMinimalTerms { get; set; }

    public class QuoteLineItemWrapper {
        public QuoteLineItem qli { get; set; }
        public Decimal discountPercent { get; set; }
        public String rowColor { get; set; }

        public QuoteLineItemWrapper(QuoteLineItem qli) {
            this.qli = qli;
            if (qli.UnitPrice != null && qli.UnitPrice > 0 && qli.TotalPrice < qli.UnitPrice) {
                discountPercent = (1 - (qli.TotalPrice / qli.UnitPrice)) * 100;
            } else {
                discountPercent = 0;
            }
        }
    }

    public QuoteController(ApexPages.StandardController stdCtrl) {
        Id quoteId = stdCtrl.getId();
        quote = [
            SELECT Id, Name, QuoteNumber, CreatedDate, ExpirationDate, GrandTotal, Term__c,
                   Quote_Notes__c, Internal_Only__c, Internal_Notes__c, Include_Signatures__c, Reseller_Quote__c,
                   BillingName, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                   OpportunityId,
                   Account.Name,
                   (SELECT Quantity, UnitPrice, TotalPrice, Description, Discount, Product2.Name, Product2.ProductCode 
                    FROM QuoteLineItems)
            FROM Quote
            WHERE Id = :quoteId
        ];

        hasDiscounts = false;
        wrappedLineItems = new List<QuoteLineItemWrapper>();
        for (Integer i = 0; i < quote.QuoteLineItems.size(); i++) {
            QuoteLineItem item = quote.QuoteLineItems[i];
            QuoteLineItemWrapper wrapper = new QuoteLineItemWrapper(item);
            wrapper.rowColor = (Math.mod(i, 2) == 0) ? '#f9f9f9' : '#ffffff';
            if (wrapper.discountPercent > 0) {
                hasDiscounts = true;
            }
            wrappedLineItems.add(wrapper);
        }

        User currentUser = [SELECT Name, Email FROM User WHERE Id = :UserInfo.getUserId()];
        currentUserEmail = currentUser.Email;
        preparedByDisplay = currentUser.Name + ' (' + currentUser.Email + ')';

        // Set Primary Contact Name and Email
        setPrimaryContactInfo();

        String component = quote.Reseller_Quote__c ? 'Reseller' : 'Direct';

        List<Legal_document__c> docs = [
            SELECT Name, Content__c, Version__c
            FROM Legal_document__c
            WHERE Component__c = :component
              AND Type__c = 'T&C'
              AND Status__c = 'Active'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (!docs.isEmpty()) {
            legalTerms = docs[0];
            isMinimalTerms = legalTerms.Name != null && legalTerms.Name.toLowerCase().contains('minimal');
        } else {
            isMinimalTerms = false;
        }
    }

    private void setPrimaryContactInfo() {
        primaryContactName = 'Not specified';
        primaryContactEmail = 'Not specified';

        if (quote.OpportunityId != null) {
            List<OpportunityContactRole> roles = [
                SELECT Contact.Name, Contact.Email
                FROM OpportunityContactRole
                WHERE OpportunityId = :quote.OpportunityId AND IsPrimary = true
                LIMIT 1
            ];
            if (!roles.isEmpty()) {
                primaryContactName = roles[0].Contact.Name != null ? roles[0].Contact.Name : 'Not specified';
                primaryContactEmail = roles[0].Contact.Email != null ? roles[0].Contact.Email : 'Not specified';
            }
        }
    }

    public List<QuoteLineItemWrapper> getWrappedLineItems() {
        return wrappedLineItems;
    }

    public Legal_document__c getLegalTerms() {
        return legalTerms;
    }

    public Boolean getIsMinimalTerms() {
        return isMinimalTerms;
    }
}
