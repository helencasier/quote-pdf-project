// QUICK SANITY TEST
// Create minimal test data for Quote PDF

// Account
Account testAccount = new Account(
    Name = 'Test Account - Quote PDF',
    BillingStreet = '123 Main St',
    BillingCity = 'Pleasanton',
    BillingState = 'CA',
    BillingPostalCode = '94588',
    BillingCountry = 'USA'
);
insert testAccount;

// Contact
Contact testContact = new Contact(
    FirstName = 'Jane',
    LastName = 'Doe',
    Email = 'jane.doe@example.com',
    AccountId = testAccount.Id
);
insert testContact;

// Opportunity
Opportunity testOpp = new Opportunity(
    Name = 'Test Opportunity - Quote PDF',
    StageName = 'Proposal/Price Quote',
    CloseDate = Date.today().addDays(30),
    AccountId = testAccount.Id
);
insert testOpp;

// Assign Standard Pricebook
Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
testOpp.Pricebook2Id = standardPB.Id;
update testOpp;

// Quote
Quote testQuote = new Quote(
    Name = 'Test Quote - Quote PDF',
    OpportunityId = testOpp.Id,
    AccountId = testAccount.Id,
    Pricebook2Id = standardPB.Id,
    ExpirationDate = Date.today().addDays(30),
    Primary_Contact__c = testContact.Id,
    Reseller_Quote__c = false
);
insert testQuote;

// Product + PricebookEntry
Product2 testProduct = [SELECT Id, Name FROM Product2 LIMIT 1];
PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :testProduct.Id AND Pricebook2Id = :standardPB.Id LIMIT 1];

// Quote Line Item
QuoteLineItem qli = new QuoteLineItem(
    QuoteId = testQuote.Id,
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

System.debug('✅ Quick Sanity Test Data Created: ' + testQuote.Id);
