//
//  MLWindowControllerTransaction.h
//  moolah
//
//  Created by Steven Hamilton on 19/06/08.
//  Copyright 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>
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
	NSManagedObject *selectedAccount;
	NSString *selectedAccountBalanceString;
}

@property NSColor *inColor;
@property NSColor *outColor;
@property NSManagedObject *selectedAccount;
@property NSString *selectedAccountBalanceString;

-(IBAction)transactionButtons:(id)sender;
-(IBAction)recordTransaction:(id)sender;

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
