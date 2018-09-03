//
//  MLWindowsControllerAccounts.h
//  moolah
//
//  Created by Steven Hamilton on 23/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Account.h"
#import "Envelope.h"

@class MyDocument;

@interface MLAccountController : NSWindowController {

	IBOutlet NSTableView	*accountsTable;
	IBOutlet NSArrayController *accountsController;
	IBOutlet NSArrayController *accountTypeController;
}

- (IBAction)addAccount:(id)sender;
- (IBAction)delAccount:(id)sender;
- (IBAction)reloadTable:(id)sender;

-(NSArray *)nameSortDescriptors;

@end
