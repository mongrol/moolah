//
//  MLimportController.m
//  moolah
//
//  Created by Steven Hamilton on 18/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MLimportController.h"
#import "MyDocument.h"

@implementation MLimportController
@synthesize selectedAccount;
@synthesize selectedTransferIndex;
@synthesize importedTransactions;

- (void)windowDidLoad{	
	//register as oberver of arrangedObjects. Once the ArrayController is initialised (2nd runloop) we set the import account 
	[accountsController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	//Sure we don't need this anymore as we load selectedAccount from the docPrefs instead of the Account Controller.
    if ([keyPath isEqual:@"arrangedObjects"]) {
		self.selectedAccount = [[self.document documentPrefs] valueForKey:@"defaultImportAccount"];
		[accountsController removeObserver:self forKeyPath:@"arrangedObjects"];
    }
}


- (void) setAccountSortDescriptors: (NSArray *) descriptors
{
}

- (NSArray *) accountSortDescriptors
{
    NSSortDescriptor *sorter;
    sorter = [[[NSSortDescriptor alloc]
			   initWithKey: @"name"
			   ascending: YES] autorelease];
	
    return ([NSArray arrayWithObject: sorter]);
}


- (void) importFile:(NSString *)aFile{
	
	//convert file to string
	NSString *importFile = [NSString stringWithContentsOfFile:aFile];
	
	//next we must extract the transactions. 1 per dictionary in an array
	//first split the file into lines
	NSMutableArray *importFileRows = [NSMutableArray arrayWithCapacity:10];
	[importFileRows addObjectsFromArray:[importFile componentsSeparatedByString:@"\n"]];
	
	//Remove last object as objectEnumerator barfs on EOF
	[importFileRows removeLastObject];
	
	//enumerate the array and extract the data. We test each row and based on the starting char
	// plonk that data into the correct field for a dictionary. If we hit a ^, its the end of a
	// transaction. We then create the dictionary and place it in the array.
	NSEnumerator *importEnumerator = [importFileRows objectEnumerator];
	NSString *transactionDetail;
	
	NSMutableArray *unsortedTransactions = [[[NSMutableArray alloc] init] autorelease];
	
	while ((transactionDetail = [importEnumerator nextObject])){
		//NSLog(@"%@ : %d",transactionDetail, [transactionDetail characterAtIndex:0]);
		NSDate *date;
		NSString *memo;
		NSNumber *transferIndex = [NSNumber numberWithInt:0];
		NSNumber *credit;
		NSNumber *debit;
		//skip blank lines?
		if (!transactionDetail){
			NSLog(@"Skip to next line");
			continue;
		}
		if ([transactionDetail characterAtIndex:0] == 68){
			NSDateFormatter *dateformatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateformatter setDateStyle:NSDateFormatterShortStyle];
			date = [dateformatter dateFromString:[transactionDetail substringFromIndex:1]];
		//	NSLog (@"%@",date);
		}
		if ([transactionDetail characterAtIndex:0] == 84){
			NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:[transactionDetail substringFromIndex:1]];
			if ([amount floatValue] < 0){
				NSString *amountString = [[amount stringValue] substringFromIndex:1];
				debit = [NSDecimalNumber decimalNumberWithString:amountString];
				credit = (id)[NSNull null];
			} else {
				credit = amount;
				debit = (id)[NSNull null];
			}
			NSLog (@"debit=%@, credit=%@",debit,credit);
		}
		if ([transactionDetail characterAtIndex:0] == 80){
			memo = [transactionDetail substringFromIndex:1];
		//	NSLog (@"%@",memo);
		}
		if ([transactionDetail characterAtIndex:0] == 94){
			//end of transaction ^. add it to array.
			//NSLog(@"adding %@, %@, %@, %@, %@", date, memo, transferIndex, credit, debit);
			NSMutableDictionary *transdic = [NSMutableDictionary dictionaryWithObjectsAndKeys:date, @"date", memo, @"memo", transferIndex, @"transferIndex", credit, @"credit", debit, @"debit", nil];
			//NSLog(@"added %@, %@, %@, %@, %@", [transdic objectForKey:@"date"],[transdic objectForKey:@"memo"],[transdic objectForKey:@"transferIndex"],[transdic objectForKey:@"credit"],[transdic objectForKey:@"debit"]);
			[unsortedTransactions addObject:transdic];
			//NSLog(@"unsortedtransactions count=%d",[unsortedTransactions count]);

		}
	}
	NSSortDescriptor *dateDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES] autorelease];
	NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
	NSLog(@"unsortedtransactions count=%d",[[unsortedTransactions sortedArrayUsingDescriptors:sortDescriptors] count]);
	NSMutableArray *transactions = [[NSMutableArray alloc] init];
	[transactions addObjectsFromArray:[unsortedTransactions sortedArrayUsingDescriptors:sortDescriptors]];
	self.importedTransactions = transactions;
	[transactionTable reloadData];
}

- (IBAction) recordTransactions:(id)sender
{
	//records all transactions in the import table into the model
//	NSLog(@"Import: Selected account: %@",[selectedAccount name]);
//	NSLog(@"Import: 1st transfer account is %@",[[[accountsController arrangedObjects] objectAtIndex:0] name]);
	NSDictionary *transdic;
	for (transdic in self.importedTransactions){
//		NSLog (@"%@",[transdic objectForKey:@"memo"]);
		NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:[self.document managedObjectContext]];	
		[entity setValue:[transdic objectForKey:@"date"] forKey:@"date"];
		[entity setValue:[transdic objectForKey:@"memo"] forKey:@"memo"];
		
		//check if credit is not null. selected account is toAccount
		if (![[[transdic objectForKey:@"credit"] className] isEqualToString:@"NSNull"]){
			[entity setValue:[transdic objectForKey:@"credit"] forKey:@"amount"];
			[entity setValue:selectedAccount forKey:@"toAccount"];
			NSManagedObject *transferAccount = [[accountsController arrangedObjects] objectAtIndex:[[transdic objectForKey:@"transferIndex"] intValue]];
			[entity setValue:transferAccount forKey:@"fromAccount"];
		}
		else{
			[entity setValue:[transdic objectForKey:@"debit"] forKey:@"amount"];
			[entity setValue:selectedAccount forKey:@"fromAccount"];
			NSManagedObject *transferAccount = [[accountsController arrangedObjects] objectAtIndex:[[transdic objectForKey:@"transferIndex"] intValue]];
//			NSLog(@"transferAccount: %@", [transferAccount name]);
			[entity setValue:transferAccount forKey:@"toAccount"];
		}
	}
	[[self.document managedObjectContext] processPendingChanges];
	[self close];
}

- (IBAction) deleteSelectedTransactions:(id)sender
{
	[self.importedTransactions removeObjectsAtIndexes:[transactionTable selectedRowIndexes]];
	[transactionTable reloadData];
}

- (IBAction) saveDefaultImportAccount:(id)sender
{
	//store docprefs
	NSLog (@"selectedAccount now set to %@", [[self selectedAccount] valueForKey:@"name"]);

	[[self.document documentPrefs] setValue:[self selectedAccount] forKeyPath:@"defaultImportAccount"];
	NSLog (@"defaultImportAccount now set to %@", [[self.document documentPrefs] valueForKeyPath:@"defaultImportAccount.name"]);
}

//table delegate methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return ([self.importedTransactions count]);
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	
	if ([[tableColumn identifier] isEqualToString:@"transferIndex"]){	
		self.selectedTransferIndex = [[self.importedTransactions objectAtIndex:row] objectForKey:[tableColumn identifier]];	
	}
//	NSLog(@"column %@: %@",[tableColumn identifier], [[importedTransactions objectAtIndex:row] objectForKey:[tableColumn identifier]]);
	return ([[self.importedTransactions objectAtIndex:row] objectForKey:[tableColumn identifier]]);	
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)newValue forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
//	NSLog(@"newValue = %@ : selectedTransferIndex = %@ : selectedAccount = %@",newValue, selectedTransferIndex, [selectedAccount name]);
	if ([[tableColumn identifier] isEqualToString:@"transferIndex"]){
		[[self.importedTransactions objectAtIndex:row] setValue:newValue forKey:@"transferIndex"];
	} else {
		[[self.importedTransactions objectAtIndex:row] setValue:newValue forKey:[tableColumn identifier]];
	}
	[transactionTable reloadData];
}

@end
