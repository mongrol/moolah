//
//  MyDocument.h
//  moolah
//
//  Created by Steven Hamilton on 16/06/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MLAccountController.h"
#import "MLBudgetController.h"
#import "MLimportController.h"

@class MLTransactionController;

@interface MyDocument : NSPersistentDocument {
	MLTransactionController *transactionWindowController;
	MLAccountController *accountsWindowController;
	MLBudgetController *budgetWindowController;
	MLimportController *importWindowController;
	NSMutableArray *sortedTransactions;
	NSManagedObject *documentPrefs;
}

@property (nonatomic, assign) NSManagedObject *documentPrefs;

-(IBAction)openBudget:(id)sender;
-(IBAction)openAccounts:(id)sender;
-(IBAction)openTransactions:(id)sender;
-(IBAction)importTransactionFile:(id)sender;

-(void) deleteTransactionAtRow:(int)row;


@end
