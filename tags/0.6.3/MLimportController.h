//
//  MLimportController.h
//  moolah
//
//  Created by Steven Hamilton on 18/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MLTransactionController.h"
#import "Account.h"

@interface MLimportController : NSWindowController {

	IBOutlet NSTableView	*transactionTable;
	IBOutlet NSArrayController *accountsController;
	
	NSMutableArray	*importedTransactions;
	Account *selectedAccount;
	NSNumber *selectedTransferIndex;
}

@property Account *selectedAccount;
@property (copy) NSNumber *selectedTransferIndex;
@property (assign) NSMutableArray *importedTransactions;

- (IBAction) recordTransactions:(id)sender;
- (IBAction) deleteSelectedTransactions:(id)sender;
- (IBAction) saveDefaultImportAccount:(id)sender;
- (void) setAccountSortDescriptors: (NSArray *) descriptors;
- (NSArray *) accountSortDescriptors;
- (void) importFile:(NSString *)aFile;

//datasource
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)newValue forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

@end
