//
//  Account.h
//  moolah
//
//  Created by Steven Hamilton on 28/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Account :  NSManagedObject  
{
}

@property (retain) NSString * name;
@property (retain) NSNumber * envelopeVisible;
@property (retain) NSSet* accounts;
@property (retain) NSSet* credit;
@property (retain) NSManagedObject * type;
@property (retain) NSManagedObject * isDefaultImportAccount;
@property (retain) NSSet* debit;
@property (retain) NSManagedObject * envelope;

// custom stuff
- (NSNumber *)balance;
- (NSNumber *)trueBalance;

@end

@interface Account (CoreDataGeneratedAccessors)
- (void)addAccountsObject:(NSManagedObject *)value;
- (void)removeAccountsObject:(NSManagedObject *)value;
- (void)addAccounts:(NSSet *)value;
- (void)removeAccounts:(NSSet *)value;

- (void)addCreditObject:(NSManagedObject *)value;
- (void)removeCreditObject:(NSManagedObject *)value;
- (void)addCredit:(NSSet *)value;
- (void)removeCredit:(NSSet *)value;

- (void)addDebitObject:(NSManagedObject *)value;
- (void)removeDebitObject:(NSManagedObject *)value;
- (void)addDebit:(NSSet *)value;
- (void)removeDebit:(NSSet *)value;

@end

