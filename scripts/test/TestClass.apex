public with sharing class TestDataFactory {

    // Quick sanity test: 1 Account, 1 Opp, 1 Quote, 1 QLI, 1 Legal Doc
    public static void createQuickTestData() {
        // Account
        Account acct = new Account(
            Name = 'Test Account - Quote PDF',
            BillingStreet = '123 Main St',
            BillingCity = 'Pleasanton',
            BillingState = 'CA',
            BillingPostalCode = '94588',
            BillingCountry = 'USA'
        );
        insert acct;

        // Contact
        Contact contact = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@example.com',
            AccountId = acct.Id
        );
        insert contact;

        // Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity - Quote PDF',
            StageName = 'Proposal/Price Quote',
            CloseDate = Date.today().addDays(30),
            AccountId = acct.Id
        );
        insert opp;

        // Assign Standard Pricebook
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        opp.Pricebook2Id = standardPB.Id;
        update opp;

        // Quote
        Quote quote = new Quote(
            Name = 'Test Quote - Quote PDF',
            OpportunityId = opp.Id,
            AccountId = acct.Id,
            Pricebook2Id = standardPB.Id,
            ExpirationDate = Date.today().addDays(30),
            Primary_Contact__c = contact.Id,
            Reseller_Quote__c = false
        );
        insert quote;

        // Product & PricebookEntry
        Product2 product = [SELECT Id, Name FROM Product2 LIMIT 1];
        PricebookEntry pbe = [
            SELECT Id, UnitPrice FROM PricebookEntry 
            WHERE Product2Id = :product.Id AND Pricebook2Id = :standardPB.Id LIMIT 1
        ];

        // Quote Line Item
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quote.Id,
            Quantity = 2,
            UnitPrice = pbe.UnitPrice,
            PricebookEntryId = pbe.Id
        );
        insert qli;

        // Legal Document
        Legal_document__c legalDoc = new Legal_document__c(
            Name = 'Standard Terms and Conditions',
            Content__c = 'These are standard terms and conditions for testing.',
            Status__c = 'Active',
            Type__c = 'T&C',
            Component__c = 'Direct'
        );
        insert legalDoc;

        System.debug('✅ Quick Test Data Created: Quote Id = ' + quote.Id);
    }

    // Robust test: multiple Quotes and Line Items
    public static void createRobustTestData() {
        // Account
        Account acct = new Account(
            Name = 'Test Account - Quote PDF (Full)',
            BillingStreet = '456 Enterprise Dr',
            BillingCity = 'San Jose',
            BillingState = 'CA',
            BillingPostalCode = '95131',
            BillingCountry = 'USA'
        );
        insert acct;

        // Contact
        Contact contact = new Contact(
            FirstName = 'John',
            LastName = 'Smith',
            Email = 'john.smith@example.com',
            AccountId = acct.Id
        );
        insert contact;

        // Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity - Quote PDF (Full)',
            StageName = 'Proposal/Price Quote',
            CloseDate = Date.today().addDays(60),
            AccountId = acct.Id
        );
        insert opp;

        // Assign Standard Pricebook
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        opp.Pricebook2Id = standardPB.Id;
        update opp;

        // Products & PricebookEntries
        List<Product2> products = [SELECT Id, Name FROM Product2 LIMIT 5];
        List<PricebookEntry> pbes = [
            SELECT Id, UnitPrice, Product2Id FROM PricebookEntry 
            WHERE Pricebook2Id = :standardPB.Id AND Product2Id IN :products
        ];

        // Create multiple Quotes with multiple Line Items
        for (Integer i = 1; i <= 3; i++) {
            Quote quote = new Quote(
                Name = 'Test Quote ' + i + ' - Quote PDF',
                OpportunityId = opp.Id,
                AccountId = acct.Id,
                Pricebook2Id = standardPB.Id,
                ExpirationDate = Date.today().addDays(30 + (i * 5)),
                Primary_Contact__c = contact.Id,
                Reseller_Quote__c = (i % 2 == 0)
            );
            insert quote;

            // Add Line Items
            List<QuoteLineItem> lineItems = new List<QuoteLineItem>();
            for (PricebookEntry pbe : pbes) {
                lineItems.add(new QuoteLineItem(
                    QuoteId = quote.Id,
                    Quantity = i,
                    UnitPrice = pbe.UnitPrice,
                    PricebookEntryId = pbe.Id
                ));
            }
            insert lineItems;
        }

        // Legal Document
        Legal_document__c legalDoc = new Legal_document__c(
            Name = 'Advanced Terms and Conditions',
            Content__c = 'These are advanced terms and conditions for comprehensive testing.',
            Status__c = 'Active',
            Type__c = 'T&C',
            Component__c = 'Direct'
        );
        insert legalDoc;

        System.debug('✅ Robust Test Data Created with multiple Quotes and Line Items');
    }
}
