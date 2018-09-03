//
//  MLWindowControllerBudget.h
//  moolah
//
//  Created by Steven Hamilton on 23/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
 
#import <Cocoa/Cocoa.h>
#import "Envelope.h"
#import "MLCalculator.h"

@class MyDocument;

@interface MLBudgetController : NSWindowController {

	IBOutlet NSArrayController *expenseEnvelopeController;
	IBOutlet NSArrayController *incomeEnvelopeController;
	IBOutlet NSArrayController *envelopeTransactionController;
	IBOutlet NSTableView *expenseTable;
	IBOutlet NSTableView *payEnvelopeTable;
	IBOutlet NSTableView *envelopeTransactionsTable;
	IBOutlet NSWindow *budgetWindow;
	IBOutlet NSWindow *allocationSheet;
	IBOutlet NSTextField *incomeBalanceTextField;
	
	NSMutableArray *payEnvelopeSheetArray;
	NSArray *firstAddendPopupStrings;
	NSArray *expenseEnvelopeBalances;
	Envelope *selectedIncomeEnvelope;
	NSDecimalNumber *selectedIncomeBalance;
	NSDecimalNumber *totalAllocated;
	NSDecimalNumber *netBalanceAfterAllocation;
	NSDecimalNumber *totalAllocatedInPayAllocationSheet;
	NSDecimalNumber *firstAddend;
	NSNumber *selectedFirstAddendIndex;
	NSNumber *expenseEnvelopeControllerReady;
	NSNumber *incomeEnvelopeControllerReady;
	NSNumber *envelopeTransactionControllerReady;
}

@property Envelope *selectedIncomeEnvelope;
@property (copy) NSDecimalNumber *selectedIncomeBalance;
@property (copy) NSDecimalNumber *totalAllocated;
@property (copy) NSDecimalNumber *netBalanceAfterAllocation;
@property (copy) NSDecimalNumber *totalAllocatedInPayAllocationSheet;
@property (copy) NSDecimalNumber *firstAddend;
@property (copy) NSArray *firstAddendPopupStrings;
@property (copy) NSNumber *selectedFirstAddendIndex;
@property (copy) NSNumber *expenseEnvelopeControllerReady;
@property (copy) NSNumber *incomeEnvelopeControllerReady;
@property (copy) NSNumber *envelopeTransactionControllerReady;
@property (copy) NSArray *expenseEnvelopeBalances;


-(IBAction)refreshDisplay:(id)sender;
-(IBAction)payEnvelopes:(id)sender;
-(IBAction)addEnvelopeTransaction:(id)sender;
-(void)calcAllocation;
-(void)calcSummarySum;
-(void)updateTables;
-(void)updateBalances;

//delegates
- (IBAction)allocationSheetOK:(id)sender;
- (IBAction)allocationSheetCancel:(id)sender;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)newValue forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;


-(NSArray *)nameSortDescriptors;
- (NSPredicate *)incomePredicate;
- (NSPredicate *)expensePredicate;
- (NSPredicate *)incomeTargetTypePredicate;
- (NSPredicate *)expenseTargetTypePredicate;
@end
