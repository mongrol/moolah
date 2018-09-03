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

@implementation MLTransactionController

@synthesize inColor;
@synthesize outColor;
@synthesize selectedAccount;
@synthesize selectedAccountBalanceString;

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
	formattedTransactions = [[NSMutableArray alloc] init];
	
	//get selected account in outlineView
	id selectedItem = [MLoutlineView itemAtRow:[MLoutlineView selectedRow]];
	//check its an account and not a groupItem. Must be better way to do this.
	NSLog(@"selectedItem className = %@", [selectedItem className]);
	if ([[selectedItem className] isEqualToString: @"Account"]){
		self.selectedAccount = selectedItem;
		// get the polarity of the account. Differentiaties between Asset/Expense and Income/Liability.
		BOOL polarity = [[[selectedAccount type] polarity] boolValue];
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

			
		NSLog(@"transactionsForAccount: %@ with polarity:%d",[selectedAccount name],polarity);
		//setup for the transactions fetch
		NSArray *rawTransactions = [[NSArray alloc] init];
		NSManagedObjectContext *moc = [self.document managedObjectContext];
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
		[request setEntity:entity];
		
		//fetch transactions
		if (selectedAccount){
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fromAccount = %@ OR toAccount = %@ OR fromAccount = NULL", selectedAccount, selectedAccount];
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
		sortedTransactions = [rawTransactions sortedArrayUsingDescriptors:sortDescriptors];
		NSLog(@"sortedTransactions count: %d",[sortedTransactions count]);
		//--
		//Convert entity array into Transaction tableView format
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
			if ([entity valueForKeyPath:@"fromAccount"] == selectedAccount){
				transfer = [entity valueForKeyPath:@"toAccount.name"];
				credit = [entity amount];
				debit = [NSNull null];
			}
			else{
				transfer = [entity valueForKeyPath:@"fromAccount.name"];
				debit = [entity amount];
				credit = [NSNull null];
			}
			NSMutableDictionary *transdic = [NSMutableDictionary dictionaryWithObjectsAndKeys:date, @"date", memo, @"memo", transfer, @"transfer", credit, @"credit", debit, @"debit", balance, @"balance", nil];		
			[formattedTransactions addObject:transdic];
			//NSLog (@"%d: %@, %@, %@, %d, %d",[formattedTransactions count], date, memo, transfer, credit, debit);
		}
		
		//do balance. First we initiate our calculator class
		MLCalculator *calculator = [[MLCalculator alloc] init];
		formattedTransactions = [calculator enumerateBalance:formattedTransactions withPolarity:polarity];
		NSLog(@"returning %d for transactions for %@",[formattedTransactions count], [selectedAccount name]);
		//reload the tableView
		[MLtableView reloadData];
		//set the balance string at the bottom
		NSString *balanceString = [NSString stringWithString:@"Balance: "];
		self.selectedAccountBalanceString = [balanceString stringByAppendingString:[[self.selectedAccount valueForKey:@"balance"] stringValue]];
		NSLog(@"selectedAccountBalanceString = %@",self.selectedAccountBalanceString);
	} else {
		//its a groupItem. Clear the tableview and return
		[formattedTransactions removeAllObjects];
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
			[MLtableView selectRow:([formattedTransactions count] - 1) byExtendingSelection:NO];
			[MLtableView editColumn:0 row:([formattedTransactions count] - 1) withEvent:nil select:YES];
		}
		if (clickedSegment == 1){
			//deleted selected row
			NSManagedObjectContext *moc = [self.document managedObjectContext];
			[moc deleteObject:[sortedTransactions objectAtIndex:[MLtableView selectedRow]]];
			[self displaySelectedAccount];
		}
		if (clickedSegment == 2){
			//import transaction file
			[NSApp sendAction:@selector(importTransactionFile:) to:self.document from:self];
		}
	}
}

- (IBAction)recordTransaction:(id)sender
{
	//get selected account in outlineView
	NSManagedObject *selectedAccount;	
	id selectedItem = [MLoutlineView itemAtRow:[MLoutlineView selectedRow]];
	//check its an account and not a groupItem. Must be better way to do this.
	if ([[selectedItem className] isEqualToString: @"NSCFString"]){
		return;
	} else {
		selectedAccount = selectedItem;
	}
	
	//fetch selected row and pull the dictionary for that row
	int row = [MLtableView selectedRow];
	
	NSMutableDictionary *transdic = [formattedTransactions objectAtIndex:row];
	
	//replace the transaction at $row with $transdic
	//we need to reverse transform the transaction into the Transaction entity format
	NSLog (@"updating with %@",[transdic objectForKey:@"date"]);
	NSDate *date = [transdic objectForKey:@"date"];
	NSString *memo = [transdic objectForKey:@"memo"];
	
	//fetch the transfer account object entered
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:[self.document managedObjectContext]];
	[request setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name LIKE %@)", [transdic objectForKey:@"transfer"]];
	[request setPredicate:predicate];
	NSError *error = nil;
	NSArray *transferAccount = [[self.document managedObjectContext] executeFetchRequest:request error:&error];
	NSLog (@"Selected Account:%@ Transfer account:%@ ",[selectedAccount name],[[transferAccount objectAtIndex:0] name]);
	
	//store the easy ones
	[[sortedTransactions objectAtIndex:row] setValue:date forKey:@"date"];
	[[sortedTransactions objectAtIndex:row] setValue:memo forKey:@"memo"];
	
	//check if credit is not null. selected account is toAccount
	if (![[[transdic objectForKey:@"debit"] className] isEqualToString:@"NSNull"]){
		[[sortedTransactions objectAtIndex:row] setValue:[transdic objectForKey:@"debit"] forKey:@"amount"];
		[[sortedTransactions objectAtIndex:row] setValue:selectedAccount forKey:@"toAccount"];
		[[sortedTransactions objectAtIndex:row] setValue:[transferAccount objectAtIndex:0] forKey:@"fromAccount"];
	}
	else{
		[[sortedTransactions objectAtIndex:row] setValue:[transdic objectForKey:@"credit"] forKey:@"amount"];
		[[sortedTransactions objectAtIndex:row] setValue:selectedAccount forKey:@"fromAccount"];
		[[sortedTransactions objectAtIndex:row] setValue:[transferAccount objectAtIndex:0] forKey:@"toAccount"];
	}
	
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
	NSLog (@"formattedTransactions count is:%d",[formattedTransactions count]);
	return [formattedTransactions count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{	
	return ([[formattedTransactions objectAtIndex:row] objectForKey:[tableColumn identifier]]);
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)newValue forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	//we update the local dictionary and array and send it back to MyDocument if fully populated.
	//then the document sorts it out for entry into the store
	//---
	//in and out (debit and credit) are exclusive so we enforce that.
	NSLog(@"%@",newValue);
	if ([[tableColumn identifier] isEqualToString:@"credit"]){
		[[formattedTransactions objectAtIndex:row] setValue:[NSNull null] forKey:@"debit"];
	}
	if ([[tableColumn identifier] isEqualToString:@"debit"]){
		[[formattedTransactions objectAtIndex:row] setValue:[NSNull null] forKey:@"credit"];
	}
	//update the formatted transactions
	[[formattedTransactions objectAtIndex:row] setValue:newValue forKey:[tableColumn identifier]];
	//reload the table. Note the table is not stored until Record button actioned.
	[MLtableView reloadData];
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
