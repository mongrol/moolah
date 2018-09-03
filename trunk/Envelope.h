//
//  Envelope.h
//  moolah
//
//  Created by Steven Hamilton on 30/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//


#import <CoreData/CoreData.h>

@class Account;

@interface Envelope :  NSManagedObject  
{
}

@property (retain) NSDecimalNumber * allocation;
@property (retain) NSDate * date;
@property (retain) NSNumber * priority;
@property (retain) NSDecimalNumber * target;
@property (retain) Account * account;
@property (retain) NSSet* credit;
@property (retain) NSSet* debit;
@property (retain) NSManagedObject * targetType;
@property (retain) NSString * note;

// custom stuff
- (NSNumber *)balance;

@end


// coalesce these into one @interface Envelope (CoreDataGeneratedAccessors) section
@interface Envelope (CoreDataGeneratedAccessors)
- (void)addCreditObject:(NSManagedObject *)value;
- (void)removeCreditObject:(NSManagedObject *)value;
- (void)addCredit:(NSSet *)value;
- (void)removeCredit:(NSSet *)value;

- (void)addDebitObject:(NSManagedObject *)value;
- (void)removeDebitObject:(NSManagedObject *)value;
- (void)addDebit:(NSSet *)value;
- (void)removeDebit:(NSSet *)value;

@end


