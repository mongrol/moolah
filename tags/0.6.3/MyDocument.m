//
//  MyDocument.m
//  moolah
//
//  Created by Steven Hamilton on 16/06/08.
//  Copyright 2008 .  All rights reserved.
//

#import "MyDocument.h"
#import "MLTransactionController.h"

@implementation MyDocument

@synthesize documentPrefs;

- (id)init 
{
    self = [super init];
    if (self != nil) {
        // initialization code
    }
    return self;
}

- (id)initWithType:(NSString *)type error:(NSError **)error
{
	//override to create new document.
	self = [super initWithType:type error:error];
	if (self != nil)
    {
		[[[self managedObjectContext] undoManager] disableUndoRegistration];
        // Add account types
		NSEntityDescription *accountTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"AccountType" inManagedObjectContext:[self managedObjectContext]];	
		[accountTypeEntity setValue:@"Assets" forKey:@"name"];
		[accountTypeEntity setValue:[NSNumber numberWithInt:0] forKey:@"polarity"];
		accountTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"AccountType" inManagedObjectContext:[self managedObjectContext]];	
		[accountTypeEntity setValue:@"Liabilities" forKey:@"name"];
		[accountTypeEntity setValue:[NSNumber numberWithInt:1] forKey:@"polarity"];
		accountTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"AccountType" inManagedObjectContext:[self managedObjectContext]];	
		[accountTypeEntity setValue:@"Income" forKey:@"name"];
		[accountTypeEntity setValue:[NSNumber numberWithInt:1] forKey:@"polarity"];
		accountTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"AccountType" inManagedObjectContext:[self managedObjectContext]];	
		[accountTypeEntity setValue:@"Expenses" forKey:@"name"];
		[accountTypeEntity setValue:[NSNumber numberWithInt:0] forKey:@"polarity"];
		
		// Add target types
		NSEntityDescription *targetTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"TargetType" inManagedObjectContext:[self managedObjectContext]];	
		[targetTypeEntity setValue:@"Weekly" forKey:@"name"];
		targetTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"TargetType" inManagedObjectContext:[self managedObjectContext]];	
		[targetTypeEntity setValue:@"Biweekly" forKey:@"name"];
		targetTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"TargetType" inManagedObjectContext:[self managedObjectContext]];	
		[targetTypeEntity setValue:@"Monthly" forKey:@"name"];
		targetTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"TargetType" inManagedObjectContext:[self managedObjectContext]];	
		[targetTypeEntity setValue:@"Yearly" forKey:@"name"];
		targetTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"TargetType" inManagedObjectContext:[self managedObjectContext]];
		[targetTypeEntity setValue:@"Quarterly" forKey:@"name"];
		targetTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"TargetType" inManagedObjectContext:[self managedObjectContext]];	
		[targetTypeEntity setValue:@"Bimonthly" forKey:@"name"];
		
		// Add documentPrefs
		[NSEntityDescription insertNewObjectForEntityForName:@"DocumentPrefs" inManagedObjectContext:[self managedObjectContext]];	
		[[self managedObjectContext] processPendingChanges];
		[[[self managedObjectContext] undoManager] enableUndoRegistration];

    }
	return self;
}

- (NSString *)windowNibName 
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
    // user interface preparation code
}

- (void)makeWindowControllers
{
	transactionWindowController = [[MLTransactionController alloc] initWithWindowNibName:@"MLTransactions"];
	[self addWindowController:transactionWindowController];
}

- (IBAction)openTransactions:(id)sender
{
	if (!transactionWindowController){
		transactionWindowController = [[MLTransactionController alloc] initWithWindowNibName:@"MLTransactions"];
	}
	[self addWindowController:transactionWindowController];
	[transactionWindowController showWindow:sender];
}

- (IBAction)openBudget:(id)sender
{
	if (!budgetWindowController){
		budgetWindowController = [[MLBudgetController alloc] initWithWindowNibName:@"MLBudget"];
	}
	[self addWindowController:budgetWindowController];
	[budgetWindowController showWindow:sender];
}

- (IBAction)openAccounts:(id)sender
{
	if (!accountsWindowController){
		accountsWindowController = [[MLAccountController alloc] initWithWindowNibName:@"MLAccounts"];
	}
	[self addWindowController:accountsWindowController];
	[accountsWindowController showWindow:sender];
}

-(void) deleteTransactionAtRow:(int)row
{
	[self.managedObjectContext deleteObject:[sortedTransactions objectAtIndex:row]];
}

-(IBAction)importTransactionFile:(id)sender
{
	//this is the start of the QIF/OFX/CSV import process
	//first open dialog to select file
	int result;
	NSString *aFile;
	NSArray *fileTypes = [NSArray arrayWithObject:@"qif"];
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	[oPanel setAllowsMultipleSelection:NO];
	result = [oPanel runModalForDirectory:nil file:nil types:fileTypes];
	if (result == NSOKButton){
		NSArray *fileToOpen = [oPanel filenames];
		aFile = [fileToOpen objectAtIndex:0];
		NSLog (@"%@", aFile);
		// Instantiate an importController
		if (!importWindowController){
			importWindowController = [[MLimportController alloc]initWithWindowNibName:@"MLimport"];
		}
		//add it to the window list
		[self addWindowController:importWindowController];
		[importWindowController showWindow:sender];
		//kick off import process
		[importWindowController importFile:aFile];
	}
}

//migration override
- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL*)url 
										   ofType:(NSString*)fileType
							   modelConfiguration:(NSString*)configuration
									 storeOptions:(NSDictionary*)storeOptions
											error:(NSError**)error
{
	NSMutableDictionary *options = nil;
	if (storeOptions != nil) {
		options = [storeOptions mutableCopy];
	} else {
		options = [[NSMutableDictionary alloc] init];
	}
	
	[options setObject:[NSNumber numberWithBool:YES] 
				forKey:NSMigratePersistentStoresAutomaticallyOption];
	
	BOOL result = [super configurePersistentStoreCoordinatorForURL:url
															ofType:fileType
												modelConfiguration:configuration
													  storeOptions:options
															 error:error];
	[options release], options = nil;
	return result;
}

- (NSManagedObject *)documentPrefs
{
    if (documentPrefs != nil) {
        return documentPrefs;
    }
	
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *fetchError = nil;
    NSArray *fetchResults;
	
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DocumentPrefs"
                                              inManagedObjectContext:moc];
	
    [fetchRequest setEntity:entity];
    fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
	
	//make sure there's only 1 Entity returned
	NSLog(@"documentPrefs Entity count is %d", [fetchResults count]);
	
    if ((fetchResults != nil) && ([fetchResults count] == 1) && (fetchError == nil)) {
        self.documentPrefs = [fetchResults objectAtIndex:0];
        return documentPrefs;
    }
	if ((fetchResults != nil) && ([fetchResults count] == 0) && (fetchError == nil)) {
		NSLog(@"docPrefs count is nil. Creating new Entity");
		[NSEntityDescription insertNewObjectForEntityForName:@"DocumentPrefs" inManagedObjectContext:[self managedObjectContext]];	
		return nil;
    }
    if (fetchError != nil) {
        [self presentError:fetchError];
    }
    else {
        NSLog(@"Oops, documentPrefs fetch error");
    }
    return nil;
}
@end
