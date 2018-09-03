// 
//  Envelope.m
//  moolah
//
//  Created by Steven Hamilton on 30/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Envelope.h"
#import "Account.h"

@implementation Envelope 

@dynamic allocation;
@dynamic target;
@dynamic date;
@dynamic targetType;
@dynamic account;
@dynamic credit;
@dynamic debit;
@dynamic note;
@dynamic priority;

//custom stuff
- (NSNumber *)balance
{
	// envelope balance is the account balance with "asset" polarity of 0 + the tally of the envelopeTransactions
	NSDecimalNumber *balance;
	//get the account balance
	NSDecimalNumber *accountBalance;
	accountBalance = [self valueForKeyPath:@"account.trueBalance"];
	//NSLog (@"accountBalance is : %@",accountBalance);
	
	//get the envelopeTransactions and tally them
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"EnvelopeTransaction" inManagedObjectContext:moc];
	[request setEntity:entity];
	
	// first we fetch all the toEnvelope transactions
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"toEnvelope = %@", self];
	[request setPredicate:predicate];
	NSError *error = nil;
	NSArray *transactions = [moc executeFetchRequest:request error:&error];
	if (transactions == nil){
		NSLog(@"Account toBalance fetch returned nil");
	}
	NSDecimalNumber *toBalance = [transactions valueForKeyPath:@"@sum.amount"];
	
	//then we get all the fromEnvelope transactions
	predicate = [NSPredicate predicateWithFormat:@"fromEnvelope = %@", self];
	[request setPredicate:predicate];
	error = nil;
	transactions = [moc executeFetchRequest:request error:&error];
	if (transactions == nil){
		NSLog(@"Account fromBalance fetch returned nil");
	}
	NSDecimalNumber *fromBalance = [transactions valueForKeyPath:@"@sum.amount"];
	
	//then we sum the accountBalance and the envelope debits and credits
	balance = [accountBalance decimalNumberByAdding:toBalance];
	balance = [balance decimalNumberBySubtracting:fromBalance];
	
	return balance;
}

@end
