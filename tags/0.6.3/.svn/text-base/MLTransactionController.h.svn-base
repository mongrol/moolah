//
//  MLWindowControllerTransaction.h
//  moolah
//
//  Created by Steven Hamilton on 19/06/08.
//  Copyright 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Account.h"
@class MyDocument;


@interface MLTransactionController : NSWindowController {

	IBOutlet NSOutlineView					*MLoutlineView;
	IBOutlet NSTableView					*MLtableView;
	
	NSMutableArray	*sortedTransactions;
	NSMutableArray	*formattedTransactions;
	NSMutableArray	*transferAccounts;
	NSArray			*outlineRoots;
	NSMutableDictionary *outlineTree; 
	NSColor			*inColor;
	NSColor			*outColor;
	Account *selectedAccount;
	NSDecimalNumber *selectedAccountBalanceString;
}

@property (copy) NSColor *inColor;
@property (copy) NSColor *outColor;
@property Account *selectedAccount;
@property (copy) NSDecimalNumber *selectedAccountBalanceString;
@property (assign) NSMutableArray *sortedTransactions;
@property (assign) NSMutableArray *formattedTransactions;

-(IBAction)transactionButtons:(id)sender;

-(void)displaySelectedAccount;
-(void)buildSourceList;

//delegates
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item;
-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item;

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)newValue forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

@end
