//
//  MLWindowControllerBudget.m
//  moolah
//
//  Created by Steven Hamilton on 23/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MLBudgetController.h"
#import "Envelope.h"
#import "MyDocument.h"

@implementation MLBudgetController

@synthesize selectedIncomeEnvelope;
@synthesize selectedIncomeBalance;
@synthesize totalAllocated;
@synthesize netBalanceAfterAllocation;
@synthesize totalAllocatedInPayAllocationSheet;
@synthesize firstAddend;
@synthesize firstAddendPopupStrings;
@synthesize selectedFirstAddendIndex;
@synthesize expenseEnvelopeControllerReady;
@synthesize incomeEnvelopeControllerReady;
@synthesize envelopeTransactionControllerReady;
@synthesize expenseEnvelopeBalances;

-(void) awakeFromNib{
}

- (void)windowDidLoad{
	//register as observer of the MOC. We can then update our tables when balances change.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTables) name:NSManagedObjectContextObjectsDidChangeNotification object:[self.document managedObjectContext]];

	//register as oberver of arrangedObjects. Once the ArrayController is initialised (2nd runloop) we set the incomeEvelope
	self.expenseEnvelopeControllerReady = [NSNumber numberWithBool:NO];
	self.incomeEnvelopeControllerReady = [NSNumber numberWithBool:NO];
	self.envelopeTransactionControllerReady = [NSNumber numberWithBool:NO];
	
	[incomeEnvelopeController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
	[expenseEnvelopeController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
	self.firstAddendPopupStrings = [NSArray arrayWithObjects:@"Ave Income:", @"Last Income:", nil];
	self.selectedFirstAddendIndex = [NSNumber numberWithInt:0];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:incomeEnvelopeController] && [keyPath isEqual:@"arrangedObjects"]) {
		self.selectedIncomeEnvelope = [[self.document documentPrefs] valueForKey:@"defaultIncomeEnvelope"];
		[incomeEnvelopeController removeObserver:self forKeyPath:@"arrangedObjects"];
		self.selectedIncomeBalance = [self.selectedIncomeEnvelope valueForKeyPath:@"balance"];
		self.incomeEnvelopeControllerReady = [NSNumber numberWithBool:YES];
    }
	else if ([object isEqual:envelopeTransactionController] && [keyPath isEqual:@"arrangedObjects"]) {
		[envelopeTransactionController removeObserver:self forKeyPath:@"arrangedObjects"];
		self.envelopeTransactionControllerReady = [NSNumber numberWithBool:YES];
	}
	else if ([object isEqual:expenseEnvelopeController] && [keyPath isEqual:@"arrangedObjects"]) {
		[expenseEnvelopeController removeObserver:self forKeyPath:@"arrangedObjects"];
		self.expenseEnvelopeControllerReady = [NSNumber numberWithBool:YES];
		self.expenseEnvelopeBalances = [[expenseEnvelopeController arrangedObjects] valueForKeyPath:@"balance"];
    }
	if ([self.incomeEnvelopeControllerReady boolValue] == YES && [self.expenseEnvelopeControllerReady boolValue] == YES){
		//controllers ready. Set data.
		[envelopeTransactionsTable reloadData];
		[envelopeTransactionsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:([envelopeTransactionsTable numberOfRows] -1)] byExtendingSelection:NO];
		[envelopeTransactionsTable editColumn:3 row:([envelopeTransactionsTable numberOfRows] -1) withEvent:nil select:YES];
		
		self.totalAllocated = [[expenseEnvelopeController arrangedObjects] valueForKeyPath:@"@sum.allocation"];
		[self calcSummarySum];
	}
}


-(IBAction)refreshDisplay:(id)sender
{
	//this is our main action loop. We store budget UI prefs, refresh display data and refresh any calcs.
	//store the selected income envelope as default.
	[[self.document documentPrefs] setValue:self.selectedIncomeEnvelope forKey:@"defaultIncomeEnvelope"];
	// refresh the current income envelope balance.
	self.selectedIncomeBalance = [self.selectedIncomeEnvelope valueForKeyPath:@"balance"];

	[self updateBalances];
	[self calcAllocation];
	[self calcSummarySum];
}	

-(void)updateBalances
{
	//fetch balances and save them. This stops constant balance calcs with bindings.
	self.expenseEnvelopeBalances = [[expenseEnvelopeController arrangedObjects] valueForKeyPath:@"balance"];
}

-(void)calcAllocation
{
	//when the targettype is clicked we calculate the allocation.
	//as its a small list we'll recalc all envelopes everytime there's a change.
	
	//only 1 income envelope is supported so we do that first
	//todo: Shrink income TargetTypes as some are daft.
	NSManagedObject *incomeEnvelope = selectedIncomeEnvelope;
	NSString *incomeType = [incomeEnvelope valueForKeyPath:@"targetType.name"];
	int incomePeriod = 7;
	if ([incomeType isEqualToString:@"Weekly"]){
		incomePeriod = 7;
	} else if ([incomeType isEqualToString:@"Biweekly"]){
		incomePeriod = 14;
	} else if ([incomeType isEqualToString:@"Monthly"]){
		incomePeriod = 30;
	} else if ([incomeType isEqualToString:@"Yearly"]){
		incomePeriod = 365;
	}
	//NSLog(@"income period is for %@ is %@",[incomeEnvelope valueForKeyPath:@"account.name"], incomeType);
	
	//we now iterate around all expense envelopes doing the allocations
	NSArray *expenseEnvelopes = [expenseEnvelopeController arrangedObjects];
		
	Envelope *envelope;
	for (envelope in expenseEnvelopes){
		//assign values to the Types
		NSString *expenseType = [envelope valueForKeyPath:@"targetType.name"];
		int targetInt = [[envelope valueForKeyPath:@"target"] intValue];
		int expensePeriod;
		
		if ([expenseType isEqualToString:@"Weekly"]){
			expensePeriod = 7;
			int modifier = 1;
			//check is iPeriod more than xPeriod?
			if (expensePeriod == incomePeriod){
				[envelope setValue:[envelope target] forKey:@"allocation"];
			} else {
				modifier = incomePeriod / expensePeriod;
				NSNumber *allocation = [NSNumber numberWithInt:targetInt * modifier];
				[envelope setValue:allocation forKey:@"allocation"];
			}
			//NSLog (@"Allocating %@ for %@ : xPeriod %d, iPeriod %d with mod %d",[envelope allocation],[envelope valueForKeyPath:@"targetType.name"], expensePeriod, incomePeriod, modifier); 		
		
		} else if ([expenseType isEqualToString:@"Biweekly"]){
			expensePeriod = 14;
			int modifier = 1;
			if (expensePeriod == incomePeriod){
				[envelope setValue:[envelope target] forKey:@"allocation"];
			} else if (expensePeriod > incomePeriod){
				modifier = expensePeriod / incomePeriod;
				NSNumber *allocation = [NSNumber numberWithInt:targetInt / modifier];
				[envelope setValue:allocation forKey:@"allocation"];
			} else if (expensePeriod < incomePeriod){
				modifier = incomePeriod / expensePeriod;
				NSNumber *allocation = [NSNumber numberWithInt:targetInt * modifier];
				[envelope setValue:allocation forKey:@"allocation"];
			}
			//NSLog (@"Allocating %@ for %@ : xPeriod %d, iPeriod %d with mod %d",[envelope allocation],[envelope valueForKeyPath:@"targetType.name"], expensePeriod, incomePeriod, modifier); 		
		
		} else if ([expenseType isEqualToString:@"Monthly"]){
			expensePeriod = 30;
			int modifier = 1;
			if (expensePeriod == incomePeriod){
				[envelope setValue:[envelope target] forKey:@"allocation"];
			} else if (expensePeriod > incomePeriod){
				modifier = expensePeriod / incomePeriod;
				NSNumber *allocation = [NSNumber numberWithInt:targetInt / modifier];
				[envelope setValue:allocation forKey:@"allocation"];
			} else if (expensePeriod < incomePeriod){
				modifier = incomePeriod / expensePeriod;
				NSNumber *allocation = [NSNumber numberWithInt:targetInt * modifier];
				[envelope setValue:allocation forKey:@"allocation"];
			}
			//NSLog (@"Allocating %@ for %@ : xPeriod %d, iPeriod %d with mod %d",[envelope allocation],[envelope valueForKeyPath:@"targetType.name"], expensePeriod, incomePeriod, modifier); 		
			
		} else if ([expenseType isEqualToString:@"Bimonthly"]){
			expensePeriod = 60;
			int modifier = 1;
			if (expensePeriod == incomePeriod){
				[envelope setValue:[envelope target] forKey:@"allocation"];
			} else if (expensePeriod > incomePeriod){
				modifier = expensePeriod / incomePeriod;
				NSNumber *allocation = [NSNumber numberWithInt:targetInt / modifier];
				[envelope setValue:allocation forKey:@"allocation"];
			} else if (expensePeriod < incomePeriod){
				modifier = incomePeriod / expensePeriod;
				NSNumber *allocation = [NSNumber numberWithInt:targetInt * modifier];
				[envelope setValue:allocation forKey:@"allocation"];
			}
			//NSLog (@"Allocating %@ for %@ : xPeriod %d, iPeriod %d with mod %d",[envelope allocation],[envelope valueForKeyPath:@"targetType.name"], expensePeriod, incomePeriod, modifier); 		
			
		} else if ([expenseType isEqualToString:@"Quarterly"]){
			expensePeriod = 90;
			int modifier = 1;
			if (expensePeriod == incomePeriod){
				[envelope setValue:[envelope target] forKey:@"allocation"];
			} else if (expensePeriod > incomePeriod){
				modifier = expensePeriod / incomePeriod;
				NSNumber *allocation = [NSNumber numberWithInt:targetInt / modifier];
				[envelope setValue:allocation forKey:@"allocation"];
			} else if (expensePeriod < incomePeriod){
				modifier = incomePeriod / expensePeriod;
				NSNumber *allocation = [NSNumber numberWithInt:targetInt * modifier];
				[envelope setValue:allocation forKey:@"allocation"];
			}
			//NSLog (@"Allocating %@ for %@ : xPeriod %d, iPeriod %d with mod %d",[envelope allocation],[envelope valueForKeyPath:@"targetType.name"], expensePeriod, incomePeriod, modifier); 		
			
		} else if ([expenseType isEqualToString:@"Yearly"]){
			expensePeriod = 365;
			int modifier = 1;
			if (expensePeriod == incomePeriod){
				[envelope setValue:[envelope target] forKey:@"allocation"];
			} else if (expensePeriod > incomePeriod){
				modifier = expensePeriod / incomePeriod;
				//NSLog (@"Allocating %@ for %@ : xPeriod %d, iPeriod %d with mod %d",[envelope allocation],[envelope valueForKeyPath:@"targetType.name"], expensePeriod, incomePeriod, modifier); 		

				NSNumber *allocation = [NSNumber numberWithInt:targetInt / modifier];
				[envelope setValue:allocation forKey:@"allocation"];
			} else if (expensePeriod < incomePeriod){
				modifier = incomePeriod / expensePeriod;
				NSNumber *allocation = [NSNumber numberWithInt:targetInt * modifier];
				[envelope setValue:allocation forKey:@"allocation"];
			}
			//NSLog (@"Allocating %@ for %@ : xPeriod %d, iPeriod %d with mod %d",[envelope allocation],[envelope valueForKeyPath:@"targetType.name"], expensePeriod, incomePeriod, modifier); 		
		}
		//NSLog(@"%@ period is %@ and gets %@",[envelope valueForKeyPath:@"account.name"], expenseType, [envelope valueForKeyPath:@"allocation"]);
	}
	[expenseTable reloadData];	
}

-(void)calcSummarySum
{
	//first we display the correct data in the Summary Addends.
	//set first Addend depending on popup
	MLCalculator *calculator = [[MLCalculator alloc] init];
	if ([self.selectedFirstAddendIndex isEqualToNumber:[NSNumber numberWithInt:0]]){
		self.firstAddend = [calculator averageIncomeForEnvelope:self.selectedIncomeEnvelope];
	}
	if ([self.selectedFirstAddendIndex isEqualToNumber:[NSNumber numberWithInt:1]]){
		self.firstAddend = [calculator lastIncomeForEnvelope:self.selectedIncomeEnvelope];
	}
	
	//set second Addend
	self.totalAllocated = [[expenseEnvelopeController arrangedObjects] valueForKeyPath:@"@sum.allocation"];
	self.netBalanceAfterAllocation = [self.firstAddend decimalNumberBySubtracting:self.totalAllocated];
	//NSLog (@"selectedFirstAddendIndex = %@",self.selectedFirstAddendIndex);
	//NSLog (@"firstAddend = %@",firstAddend);
}	

//payEnvelopes
//this distributes funds amongst expenses from the income envelope
-(IBAction)payEnvelopes:(id)sender
{
	//first we grab all the expense envelopes that are enabled (visible) and get their allocation amount
	//then build a table for the tableView delegate to display. We want to be able to change any amounts before they are distributed
	NSArray *expenseEnvelopes = [expenseEnvelopeController arrangedObjects];
	payEnvelopeSheetArray = [[NSMutableArray alloc] init];
	Envelope *entity;
	for (entity in expenseEnvelopes){
		NSString *name = [entity valueForKeyPath:@"account.name"];
		NSNumber *amount = [entity allocation];
		NSMutableDictionary *payEnvelopeDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:name,@"name",amount,@"amount",nil];
		[payEnvelopeSheetArray addObject:payEnvelopeDic];
	}
	
	//bring down the sheet
	[NSApp beginSheet: allocationSheet
	   modalForWindow: budgetWindow
		modalDelegate: self
	   didEndSelector: @selector(sheetDidEnd: returnCode: contextInfo:)
		  contextInfo:NULL];
	[payEnvelopeTable reloadData];
	//set the total property
	self.totalAllocatedInPayAllocationSheet = [payEnvelopeSheetArray valueForKeyPath:@"@sum.amount"];
	//NSLog(@"totalAllocatedInPayAllocationSheet = %@",self.totalAllocatedInPayAllocationSheet);
}

- (IBAction)allocationSheetOK:(id)sender
{
	//close the sheet
	[NSApp endSheet:allocationSheet returnCode: NSOKButton];
	[allocationSheet orderOut:nil];
	//make the transactions;
	//NSManagedObject *incomeEnvelope = self.selectedIncomeEnvelope;
	NSMutableDictionary *payEnvelopeDic;
	for (payEnvelopeDic	in payEnvelopeSheetArray){
		NSEntityDescription *envelopeTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"EnvelopeTransaction" inManagedObjectContext:[self.document managedObjectContext]];	
		[envelopeTransaction setValue:[NSDate date] forKey:@"date"];
		[envelopeTransaction setValue:[payEnvelopeDic valueForKey:@"amount"] forKey:@"amount"];
		[envelopeTransaction setValue:self.selectedIncomeEnvelope forKey:@"fromEnvelope"];
		NSManagedObject *expenseEnvelope = [[expenseEnvelopeController arrangedObjects] objectAtIndex:[payEnvelopeSheetArray indexOfObject:payEnvelopeDic]];
		[envelopeTransaction setValue:expenseEnvelope forKey:@"toEnvelope"];
	}
	[expenseTable reloadData];
	self.selectedIncomeBalance = [self.selectedIncomeEnvelope valueForKeyPath:@"balance"];
}

- (IBAction)allocationSheetCancel:(id)sender
{
	[NSApp endSheet:allocationSheet returnCode: NSCancelButton];
	[allocationSheet orderOut:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
		NSBeep();
}
//end payEnvelopes

//drawerActions
- (IBAction)addEnvelopeTransaction:(id)sender
{
	//add a new EnvelopeTransaction		
	NSLog (@"Adding EnvelopeTransaction");
	NSLog(@"[envelopeTransactionsTable numberOfRows] is %d",[envelopeTransactionsTable numberOfRows]);
	NSEntityDescription *envelopeTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"EnvelopeTransaction" inManagedObjectContext:[self.document managedObjectContext]];
	[envelopeTransaction setValue:self.selectedIncomeEnvelope forKey:@"fromEnvelope"];
	[envelopeTransaction setValue:[[expenseEnvelopeController selectedObjects] objectAtIndex:0] forKey:@"toEnvelope"];
	[envelopeTransaction setValue:[NSDate date] forKey:@"date"];
	[envelopeTransaction setValue:[NSDecimalNumber zero] forKey:@"amount"];
	
	//setup observer so we can jump to last row
	[envelopeTransactionController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
}
	
//tableDelegates
//only for payAllocationSheet so no tableView check
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	NSLog (@"payEnvelopeSheetArray count is %d",[payEnvelopeSheetArray count]);
	return [payEnvelopeSheetArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	if ([tableView isEqualTo:payEnvelopeTable]){
		return ([[payEnvelopeSheetArray objectAtIndex:row] objectForKey:[tableColumn identifier]]);
	}
	else if ([tableView isEqualTo:expenseTable]){
		if ([[tableColumn identifier] isEqualToString:@"envBalance"]){
			return ([self.expenseEnvelopeBalances objectAtIndex:row]);
			}
	}
	return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)newValue forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	if ([tableView isEqualTo:payEnvelopeTable]){
		[[payEnvelopeSheetArray objectAtIndex:row] setValue:newValue forKey:[tableColumn identifier]];
		self.totalAllocatedInPayAllocationSheet = [payEnvelopeSheetArray valueForKeyPath:@"@sum.amount"];
		NSLog(@"totalAllocatedInPayAllocationSheet = %@",self.totalAllocatedInPayAllocationSheet);
		[self updateBalances];
		[expenseTable reloadData];
	}
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	
	if ([tableView isEqualTo:expenseTable]){
		//check envelope balance and change colour if negative
		if ([[tableColumn identifier] isEqualToString:@"envBalance"]){
			NSColor *red = [NSColor redColor];
			NSColor *black = [NSColor blackColor];
			int balance = [cell intValue];
			if (balance < 0){
				[cell setTextColor:red];
			} else {
				[cell setTextColor:black];
			}
		}
	}
}

-(NSArray *)nameSortDescriptors
{
	NSSortDescriptor *accountNameDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"account.name" ascending:YES] autorelease];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:accountNameDescriptor, nil];
	return sortDescriptors;
}

-(NSPredicate *)incomePredicate
{
	NSPredicate *incomePredicate = [NSPredicate predicateWithFormat:@"(account.type.name == 'Income') AND (account.envelopeVisible == YES)"];
	return incomePredicate;
}

-(NSPredicate *)expensePredicate
{
	NSPredicate *expensePredicate = [NSPredicate predicateWithFormat:@"(account.type.name == 'Expenses') AND (account.envelopeVisible == YES)"];
	return expensePredicate;
}

-(NSPredicate *)incomeTargetTypePredicate
{
	NSPredicate *incomePredicate = [NSPredicate predicateWithFormat:@"(name == 'Weekly') OR (name == 'Biweekly') OR (name == 'Monthly')"];
	return incomePredicate;
}

-(NSPredicate *)expenseTargetTypePredicate
{
	NSPredicate *expensePredicate = [NSPredicate predicateWithFormat:@"(name != 'Once')"];
	return expensePredicate;
}

-(void) updateTables
{
	self.selectedIncomeBalance = [self.selectedIncomeEnvelope valueForKeyPath:@"balance"];
	[self updateBalances];
	[expenseTable reloadData];
}

- (void)windowWillClose:(NSNotification *)notification
{
	//remove observer when window closes.
	[[NSNotificationCenter defaultCenter] removeObserver:self];			
}	
@end
