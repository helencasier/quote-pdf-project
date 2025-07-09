// ROBUST DATA SET
// Create multiple Quotes and Line Items for testing

// Account
Account testAccount = new Account(
    Name = 'Test Account - Quote PDF (Full)',
    BillingStreet = '456 Enterprise Dr',
    BillingCity = 'San Jose',
    BillingState = 'CA',
    BillingPostalCode = '95131',
    BillingCountry = 'USA'
);
insert testAccount;

// Contact
Contact testContact = new Contact(
    FirstName = 'John',
    LastName = 'Smith',
    Email = 'john.smith@example.com',
    AccountId = testAccount.Id
);
insert testContact;

// Opportunity
Opportunity testOpp = new Opportunity(
    Name = 'Test Opportunity - Quote PDF (Full)',
    StageName = 'Proposal/Price Quote',
    CloseDate = Date.today().addDays(60),
    AccountId = testAccount.Id
);
insert testOpp;

// Assign Standard Pricebook
Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
testOpp.Pricebook2Id = standardPB.Id;
update testOpp;

// Products
List<Product2> products = [SELECT Id, Name FROM Product2 LIMIT 5];
List<PricebookEntry> pbes = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :standardPB.Id AND Product2Id IN :products];

// Create multiple Quotes
for (Integer i = 1; i <= 3; i++) {
    Quote quote = new Quote(
        Name = 'Test Quote ' + i + ' - Quote PDF',
        OpportunityId = testOpp.Id,
        AccountId = testAccount.Id,
        Pricebook2Id = standardPB.Id,
        ExpirationDate = Date.today().addDays(30 + (i * 5)),
        Primary_Contact__c = testContact.Id,
        Reseller_Quote__c = (i % 2 == 0)
    );
    insert quote;

    // Add multiple Quote Line Items
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

System.debug('✅ Robust Data Set Created with multiple Quotes and Line Items');
