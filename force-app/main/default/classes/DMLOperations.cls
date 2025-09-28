/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author May Keam
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account myAccount = new Account();

        // Set some fields on the Account
        myAccount.Name = 'Andor';
        myAccount.Industry = 'Apparel';

        // Insert the Account into the database
        Database.insert(myAccount, AccessLevel.USER_MODE);
        // Return the Id of the newly created Account
        return myAccount.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account newAcct = new Account(Name = name, Industry = industry);

        // Insert the Account
        Database.insert(newAcct, AccessLevel.USER_MODE);
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newContact = new Contact();
        // Set some fields on the Contact
        newContact.LastName = 'Andor';
        newContact.FirstName = 'Bix';
        // Set the AccountId field to the given accountId
        newContact.AccountId = accountId;
        // Insert the Contact into the database
        Database.insert(newContact, AccessLevel.USER_MODE);
        // Return the Id of the newly created Contact
        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        Contact contToUpdate = [SELECT Id FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED];
        // Update the Contact's last name
        contToUpdate.LastName = newLastName;
        // Update the Contact in the database
        Database.update(contToUpdate, AccessLevel.USER_MODE);
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        Opportunity oppStageToUpdate = [SELECT Id FROM Opportunity WHERE Id = :oppId WITH SECURITY_ENFORCED];

        // Update the Opportunity's stage
        oppStageToUpdate.StageName = newStage;
        // Update the Opportunity in the database
        Database.update(oppStageToUpdate, AccessLevel.USER_MODE);
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        Account acctToUpdate = [SELECT Id FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED];
        acctToUpdate.Name = newName;
        acctToUpdate.Industry = newIndustry;

        // Update the Account with the given Id with the new name and industry
        Database.update(acctToUpdate, AccessLevel.USER_MODE);
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        // Loop through each Opportunity in the list
        for(Opportunity opps : opportunities) {
            // Set the Opportunity's Stage to Qualification
            opps.StageName = 'Qualification';
            // Set the Opportunity's Close Date to 3 months from today
            opps.CloseDate = date.today().addMonths(3);
            // Set the Opportunity's Amount to 50000
            opps.Amount = 50000;
            oppsToUpdate.add(opps);
        }
        // Upsert the opportunities List so that records are either updated or created
        Database.upsert(oppsToUpdate, AccessLevel.USER_MODE);
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        // create an account to store the accountName
        Account acct;
        List<Account> listOfAccounts = [SELECT Id, Name
                                        FROM Account
                                        WHERE Name = :accountName WITH SECURITY_ENFORCED];
        // if there are no accounts in the list, create a new account using accountName as name
        if(listOfAccounts.isEmpty()) {
            acct = new Account(Name = accountName);
            Database.insert(acct, AccessLevel.USER_MODE);
        }
        // create a map to store the name of the opportunity to the opportunity
        Map<String, Opportunity> oppNameToOpp = new Map<String, Opportunity>();
        // for each oppName in the list get the Id, Name of Opp where the name is in the list of OppNames and the AccountId = accountName
        for(Opportunity opp : [SELECT Id, Name, Account.Name 
                               FROM Opportunity
                               WHERE Name IN :oppNames AND Account.Name = :accountName WITH SECURITY_ENFORCED]) 
                               {
                                oppNameToOpp.put(opp.Name, opp);
                               }
        // create a list to store the opportunities
        List<Opportunity> listOfOpps = new List<Opportunity>();
        // Loop through each Opportunity name to see if in the map othewise create a new opp
        for(String oppName : oppNames) {
            if(oppNameToOpp.containsKey(oppName)) {
                listOfOpps.add(oppNameToOpp.get(oppName));
            }
            else {
                // Create an Opportunity with the given name
                Opportunity newOpp = new Opportunity
                (
                    Name = oppName,
                    AccountId = acct.id,
                    StageName = 'Closed Won',
                    CloseDate = Date.today()
                ); 
                listOfOpps.add(newOpp);
            }
        }
                // Add the Opportunity to the list
        Database.upsert(listOfOpps, AccessLevel.USER_MODE);
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName WITH SECURITY_ENFORCED];

		// if the Account exists, update the description

        // create the Account
        Account myAcct;
        if(!accounts.isEmpty())
        {
            myAcct = accounts.get(0);
            myAcct.Description = 'Updated Account';
        } else // otherwise, create a new Account and set the description
        {
            myAcct = new Account(Name = accountName);
            myAcct.Description = 'New Account';
        }
		// Upsert the Account
        Database.upsert(myAcct, AccessLevel.USER_MODE);

		return myAcct;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
        
        // Loop through each Contact to get the lastnames from the contacts
        for(Contact cont : contactsToUpsert) 
        {
            // assign the Account name (contact last name) to a string 
            String accountName = cont.LastName;
            // Get the account based on the name or create one if it doesn't exist
            List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName WITH SECURITY_ENFORCED];
            // Instantiate an account
            Account myAccount = null;
            // Check to see if tf the account exists, if it does update it
            if(accounts.isEmpty())
            {
                myAccount = new Account (Name = accountName);
            } else 
            {
                // Otherwise the account that we are using is in the list of accounts
                myAccount = accounts[0];
            }
            Database.upsert(myAccount, AccessLevel.USER_MODE);
            // Link the Contact to its Account using the Account Id
            cont.AccountId = myAccount.Id;
        }
		// Upsert the Contacts
        Database.upsert(contactsToUpsert, AccessLevel.USER_MODE);
    }                
	

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Loop through each Lead name
        List<Lead> leadsToProcess = new List<Lead>();
        Lead newLead = null;
        for(String leads : leadNames)
        {
            newLead = new Lead (
                LastName = leads,
                Company = 'Lead Company', 
                Status = 'Open - Not Contacted'
                );
            leadsToProcess.add(newLead);
        }
        
        // Insert the Leads
        Database.insert(leadsToProcess, AccessLevel.USER_MODE);
         // Delete the Leads
        Database.delete(leadsToProcess, AccessLevel.USER_MODE);
        }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> casesToProcess = new List<Case>();
        Case newCase = null;
        for(Integer i = 0; i < numOfCases; i++)
        {
            newCase = new Case ( 
                AccountId = accountId,
                Status = 'New',
                Origin = 'Web'
            );
            casesToProcess.add(newCase);
        }
        // Insert the cases
        Database.insert(casesToProcess, AccessLevel.USER_MODE);

        // Delete the cases
        Database.delete(casesToProcess, AccessLevel.USER_MODE);
    }
}