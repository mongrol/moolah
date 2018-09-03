//
//  MLWindowControllerTransaction.m
//  moolah
//
//  Created by Steven Hamilton on 19/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MLTransactionController.h"
#import "MyDocument.h"
#import "NSEntityDescription+Transaction.h"
#import "MLCalculator.h"
#import "Account.h"
#import "NSManagedObject.h"
@implementation MLTransactionController

@synthesize inColor;
@synthesize outColor;
@synthesize selectedAccount;
@synthesize selectedAccountBalanceString;
@synthesize sortedTransactions;
@synthesize formattedTransactions;
@synthesize searchString;

- (void)awakeFromNib{
	//enable bottombar
	[[self window] setContentBorderThickness:32.0 forEdge:NSMinYEdge];
	
	//jump to build the sourcelist 
	[self buildSourceList];
	
	//register as observer of outlineView. Starts a transaction fetch when we select a new account
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displaySelectedAccount) name:NSOutlineViewSelectionDidChangeNotification object:MLoutlineView];
	//register as observer of the MOC. Starts a sourcelist rebuild and redisplay of accounts if moc has changed.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buildSourceList) name:NSManagedObjectContextObjectsDidChangeNotification object:[self.document managedObjectContext]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displaySelectedAccount) name:NSManagedObjectContextObjectsDidChangeNotification object:[self.document managedObjectContext]];

	//this may be moved after datasource refactor.
	[transferAccounts initWithObjects:nil];
	//trigger populate table
	[self displaySelectedAccount];
}

- (void)displaySelectedAccount{
	
	//setup our instance objects
	self.formattedTransactions = [[NSMutableArray alloc] init];
	
	//ensure it is clear
	[self.formattedTransactions removeAllObjects];
	[self.sortedTransactions removeAllObjects];
	
	//get selected account in outlineView. Check its an account and not a groupItem.
	//NSLog(@"selectedItem className = %@", [[MLoutlineView itemAtRow:[MLoutlineView selectedRow]] className]);
	
	if ([[[MLoutlineView itemAtRow:[MLoutlineView selectedRow]] className] isEqualToString: @"Account"]){
		self.selectedAccount = [MLoutlineView itemAtRow:[MLoutlineView selectedRow]];
		// get the polarity of the account. Differentiaties between Asset/Expense and Income/Liability.
		BOOL polarity = [[[self.selectedAccount type] polarity] boolValue];
		NSLog(@"polarity = %d",polarity);
		
		//set our headers and colours based on polarity
		NSTableHeaderCell *debitHeader = [[MLtableView tableColumnWithIdentifier:@"debit"] headerCell];
		NSTableHeaderCell *creditHeader = [[MLtableView tableColumnWithIdentifier:@"credit"] headerCell];		
		if(polarity == FALSE){
			//set column headers
			[debitHeader setStringValue:@"Increase"];
			[creditHeader setStringValue:@"Decrease"];
			//set column colours
			self.inColor = [NSColor blueColor];
			self.outColor = [NSColor redColor];
		} else {
			[debitHeader setStringValue:@"Decrease"];
			[creditHeader setStringValue:@"Increase"];
			self.inColor = [NSColor redColor];
			self.outColor = [NSColor blueColor];
		}
		
		//fetch all the transactions related to that account
		//NSLog(@"transactionsForAccount: %@ with polarity:%d",[selectedAccount name],polarity);
		//setup for the transactions fetch
		NSArray *rawTransactions = [[NSArray alloc] init];
		NSManagedObjectContext *moc = [self.document managedObjectContext];
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
		[request setEntity:entity];
		if (selectedAccount){
			NSLog(@"search = %@",self.searchString);
			NSPredicate *predicate;
			if (self.searchString){
				predicate = [NSPredicate predicateWithFormat:@"(fromAccount = %@ OR toAccount = %@ OR fromAccount = NULL) AND memo CONTAINS[cd] %@", selectedAccount, selectedAccount, self.searchString];
			} else {
				predicate = [NSPredicate predicateWithFormat:@"fromAccount = %@ OR toAccount = %@ OR fromAccount = NULL", selectedAccount, selectedAccount];
			}
			[request setPredicate:predicate];
			NSError *error = nil;
			rawTransactions = [moc executeFetchRequest:request error:&error];
			if (rawTransactions == nil){
				NSLog(@"fetch returned nil");
			}
			NSLog(@"fetch returned %d",[rawTransactions count]);
		}
		
		//sort the results
		NSSortDescriptor *dateDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES] autorelease];
		NSSortDescriptor *memoDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"memo" ascending:YES] autorelease];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:dateDescriptor, memoDescriptor, nil];
		self.sortedTransactions = [[rawTransactions sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
		NSLog(@"rawTransactions count (sorted): %d",[[rawTransactions sortedArrayUsingDescriptors:sortDescriptors] count]);

		NSLog(@"sortedTransactions count: %d",[self.sortedTransactions count]);
		//--
		//Convert entity array into Transaction tableView format
		[self.formattedTransactions removeAllObjects];
		for (entity in sortedTransactions){
			NSDate *date = [entity date];
			NSString *memo = [entity memo];
			if (!memo) {
				memo = @"";
			}
			NSString *transfer;
			NSNumber *credit;
			NSNumber *debit;
			NSNumber *balance = [NSNumber numberWithInt:0]; //placeholder balance
			NSMutableDictionary *transdic;
			if ([entity valueForKeyPath:@"fromAccount"] == selectedAccount){
				transfer = [entity valueForKeyPath:@"toAccount"];
				credit = [entity amount];
				//build the transaction dictionary leaving out debit as its nil
				transdic = [NSMutableDictionary dictionaryWithObjectsAndKeys:date, @"date", memo, @"memo", transfer, @"transfer", credit, @"credit", balance, @"balance", nil];		
			}
			else{
				transfer = [entity valueForKeyPath:@"fromAccount"];
				debit = [entity amount];
				//build the transaction dictionary leaving out credit as its nil
				transdic = [NSMutableDictionary dictionaryWithObjectsAndKeys:date, @"date", memo, @"memo", transfer, @"transfer", debit, @"debit", balance, @"balance", nil];		
			}
			[self.formattedTransactions addObject:transdic];
//			NSLog (@"%d: %@, %@, %@, %@, %@",[self.formattedTransactions count], date, memo, transfer, debit, credit);
		}
		
		//do balance. First we initiate our calculator class
		MLCalculator *calculator = [[MLCalculator alloc] init];
		self.formattedTransactions = [calculator enumerateBalance:self.formattedTransactions withPolarity:polarity];
		NSLog(@"returning %d for transactions for %@",[self.formattedTransactions count], [selectedAccount name]);

		//reload the tableView
		[MLtableView reloadData];
		//set the balance string at the bottom
		self.selectedAccountBalanceString = [self.selectedAccount valueForKey:@"balance"];
	} else {
		//its a groupItem. Clear the tableview and return
		[self.formattedTransactions removeAllObjects];
		[MLtableView reloadData];
		return;
	}
}

- (void)buildSourceList
{	
	outlineRoots = [NSArray arrayWithObjects:@"Assets",@"Liabilities",@"Income",@"Expenses",nil];
	outlineTree = [NSMutableDictionary dictionaryWithObjects:outlineRoots forKeys:outlineRoots];
	//fetch all accounts for each account type
	NSManagedObjectContext *moc = [self.document managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:moc];
	[request setEntity:entity];
	//fetch all accounts for each type and add to dictionary
	for (NSString *element in outlineRoots){
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type.name LIKE %@", element];
		[request setPredicate:predicate];
		NSError *error = nil;
		NSArray *accounts = [moc executeFetchRequest:request error:&error];
		if (accounts == nil)
		{
			NSLog(@"outline account fetch returned nil");
		}
		//sort the array
		NSSortDescriptor *sorter;
		sorter = [[[NSSortDescriptor alloc]
				   initWithKey: @"name"
				   ascending: YES] autorelease];
		NSArray *sortDescriptors = [NSArray arrayWithObject: sorter];
		accounts = [accounts sortedArrayUsingDescriptors:sortDescriptors];
		//build the tree
		[outlineTree setObject:accounts	forKey:element];
		//log
		//		NSLog(@"Build sourcelist: %@ accounts = %d",element,[[outlineTree objectForKey:element] count]);
	}
	
}

- (IBAction)transactionButtons:(id)sender
{
	//first check we're selecting an account instead of a group item
	if (![[[MLoutlineView itemAtRow:[MLoutlineView selectedRow]] className] isEqualToString: @"NSCFString"]){
		int clickedSegment = [sender selectedSegment];
		if (clickedSegment == 0){
			//add a new instance of Transaction entity			
			NSLog (@"Adding Transaction");
			NSEntityDescription *transaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:[self.document managedObjectContext]];
			[transaction setValue:[MLoutlineView itemAtRow:[MLoutlineView selectedRow]] forKey:@"toAccount"];
			[transaction setValue:[MLoutlineView itemAtRow:[MLoutlineView selectedRow]] forKey:@"fromAccount"];
			[self displaySelectedAccount];
			//jump to last row
			[MLtableView selectRow:([self.formattedTransactions count] - 1) byExtendingSelection:NO];
			[MLtableView editColumn:0 row:([self.formattedTransactions count] - 1) withEvent:nil select:YES];
		}
		if (clickedSegment == 1){
			//deleted selected row
			NSManagedObjectContext *moc = [self.document managedObjectContext];
			[moc deleteObject:[self.sortedTransactions objectAtIndex:[MLtableView selectedRow]]];
			[self displaySelectedAccount];
		}
		if (clickedSegment == 2){
			//import transaction file
			[NSApp sendAction:@selector(importTransactionFile:) to:self.document from:self];
		}
	}
}

- (IBAction)filterOnSearch:(id)sender
{
	[self displaySelectedAccount];
}

//-------
//OutlineView delegate methods
//-------
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (!item) {
		return [outlineTree count];
	}
	return [[outlineTree objectForKey:item] count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	// is child item?
	if (item){
		return [[outlineTree objectForKey:item] objectAtIndex:index];
	}
	return ([outlineRoots objectAtIndex:index]);
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	//Check whether its asking for root value
	if ([[item className] isEqualToString: @"NSCFString"]){
		return item;
	}
	return [item name];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if ([[item className] isEqualToString: @"NSCFString"]){
		return YES;
	}
	return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	if ([[item className] isEqualToString: @"NSCFString"]){
		return YES;
	}
	return NO;
}

//-------
//Tableview delegate methods
//-------

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	NSLog (@"formattedTransactions count is:%d",[self.formattedTransactions count]);
	return [self.formattedTransactions count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{	
	if ([[tableColumn identifier] isEqualToString:@"transfer"])
	{
		return ([[self.formattedTransactions objectAtIndex:row] valueForKeyPath:@"transfer.name"]);
	}
	return ([[self.formattedTransactions objectAtIndex:row] objectForKey:[tableColumn identifier]]);
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)newValue forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	
	//we have access to self.sortedTransactions which is in sync with formattedTransactions.
	//we can directly update sortedTransactions which updates the model.
		
	if ([[tableColumn identifier] isEqualToString:@"date"])
	{
		NSLog(@"setColumn: date entered");
		[[self.sortedTransactions objectAtIndex:row] setValue:newValue forKey:@"date"];
		return;
	}
	else if ([[tableColumn identifier] isEqualToString:@"memo"])
	{
		NSLog(@"setColumn: memo entered");
		[[self.sortedTransactions objectAtIndex:row] setValue:newValue forKey:@"memo"];
		return;
	}
	else if ([[tableColumn identifier] isEqualToString:@"transfer"])
	{
		//fetch the Account object represented by the transfer column
		NSManagedObjectContext *moc = [self.document managedObjectContext];
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:moc];
		[request setEntity:entity];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", newValue];
		[request setPredicate:predicate];
		NSError *error = nil;
		NSArray *accounts = [moc executeFetchRequest:request error:&error];
		if ([accounts count] == 0)
		{
			NSLog(@"transfer account does not exist");
			return;
		}
		NSLog(@"transferAccount is %@",[[accounts objectAtIndex:0] name]);
	
		//we need to look at whether debit or credit has a number in it and set toAccount and fromAccount accordingly
		NSLog(@"debit value is %@ in row %d", [self tableView:tableView objectValueForTableColumn:[MLtableView tableColumnWithIdentifier:@"debit"] row:row], row);
		NSDecimalNumber *debit = [self tableView:tableView objectValueForTableColumn:[MLtableView tableColumnWithIdentifier:@"debit"] row:row];
		//NSDecimalNumber *credit = [self tableView:tableView objectValueForTableColumn:[MLtableView tableColumnWithIdentifier:@"credit"] row:row];
		if (debit){
			[[self.sortedTransactions objectAtIndex:row] setValue:[accounts objectAtIndex:0] forKey:@"fromAccount"];
			[[self.sortedTransactions objectAtIndex:row] setValue:self.selectedAccount forKey:@"toAccount"];
			return;
		} else {
			[[self.sortedTransactions objectAtIndex:row] setValue:[accounts objectAtIndex:0] forKey:@"toAccount"];
			[[self.sortedTransactions objectAtIndex:row] setValue:self.selectedAccount forKey:@"fromAccount"];
		}
	}
	else if ([[tableColumn identifier] isEqualToString:@"debit"])
	{
		//fetch the Account object represented by the transfer column
		NSString *transferName = [self tableView:tableView objectValueForTableColumn:[MLtableView tableColumnWithIdentifier:@"transfer"] row:row];		
		NSManagedObjectContext *moc = [self.document managedObjectContext];
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:moc];
		[request setEntity:entity];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", transferName];
		[request setPredicate:predicate];
		NSError *error = nil;
		NSArray *accounts = [moc executeFetchRequest:request error:&error];
		NSLog(@"transferAccount is %@",[[accounts objectAtIndex:0] name]);
		
		if (newValue){
			[[self.sortedTransactions objectAtIndex:row] setValue:newValue forKey:@"amount"];
			[[self.sortedTransactions objectAtIndex:row] setValue:[accounts objectAtIndex:0] forKey:@"fromAccount"];
			[[self.sortedTransactions objectAtIndex:row] setValue:self.selectedAccount forKey:@"toAccount"];
		}
		return;
	}
	else if ([[tableColumn identifier] isEqualToString:@"credit"])
	{
		//fetch the Account object represented by the transfer column
		NSString *transferName = [self tableView:tableView objectValueForTableColumn:[MLtableView tableColumnWithIdentifier:@"transfer"] row:row];		
		NSManagedObjectContext *moc = [self.document managedObjectContext];
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:moc];
		[request setEntity:entity];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", transferName];
		[request setPredicate:predicate];
		NSError *error = nil;
		NSArray *accounts = [moc executeFetchRequest:request error:&error];
		NSLog(@"transferAccount is %@",[[accounts objectAtIndex:0] name]);
		
		if (newValue){
			[[self.sortedTransactions objectAtIndex:row] setValue:newValue forKey:@"amount"];
			[[self.sortedTransactions objectAtIndex:row] setValue:[accounts objectAtIndex:0] forKey:@"toAccount"];
			[[self.sortedTransactions objectAtIndex:row] setValue:self.selectedAccount forKey:@"fromAccount"];
		}
		return;
	}
	
//	[[self.sortedTransactions objectAtIndex:row] setValue:memo forKey:@"memo"];
	
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    float dividerThickness = [sender dividerThickness];
	
    NSView *left = [[sender subviews] objectAtIndex:0];
    NSView *right = [[sender subviews] objectAtIndex:1];
	
    NSRect newFrame = [sender frame]; // the splitvies's new frame
    NSRect leftFrame = [left frame];
    NSRect rightFrame = [right frame];
	
    leftFrame.size.height = newFrame.size.height;
	
    rightFrame.size.width = newFrame.size.width -
	leftFrame.size.width - dividerThickness;
    rightFrame.size.height = newFrame.size.height;
    rightFrame.origin.x = leftFrame.size.width + dividerThickness;
	
    [left setFrame:leftFrame];
    [right setFrame:rightFrame];
}

- (void)windowWillClose:(NSNotification *)notification
{
	//remove observer when window closes.
	[[NSNotificationCenter defaultCenter] removeObserver:self];			
}	
@end
