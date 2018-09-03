// 
//  Account.m
//  moolah
//
//  Created by Steven Hamilton on 28/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Account.h"


@implementation Account 

@dynamic name;
@dynamic envelopeVisible;
@dynamic accounts;
@dynamic credit;
@dynamic type;
@dynamic debit;
@dynamic envelope;
@dynamic isDefaultImportAccount;

//custom stuff
- (NSNumber *)balance
{
	NSDecimalNumber *balance;
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	[request setEntity:entity];
	
	// first we fetch all the toAccount transactions
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"toAccount = %@", self];
	[request setPredicate:predicate];
	NSError *error = nil;
	NSArray *transactions = [moc executeFetchRequest:request error:&error];
	if (transactions == nil){
		NSLog(@"Account toBalance fetch returned nil");
	}
	NSDecimalNumber *toBalance = [transactions valueForKeyPath:@"@sum.amount"];

	//then we get all the fromAccount transactions
	predicate = [NSPredicate predicateWithFormat:@"fromAccount = %@", self];
	[request setPredicate:predicate];
	error = nil;
	transactions = [moc executeFetchRequest:request error:&error];
	if (transactions == nil){
		NSLog(@"Account fromBalance fetch returned nil");
	}
	NSDecimalNumber *fromBalance = [transactions valueForKeyPath:@"@sum.amount"];

	//then we then check polarity and subtract the debits from the credits
	BOOL polarity = [[self valueForKeyPath:@"type.polarity"] boolValue];
	if (!polarity){
		balance = [toBalance decimalNumberBySubtracting:fromBalance];
	} else {
		balance = [fromBalance decimalNumberBySubtracting:toBalance];
	}
	
	return balance;
}

//trueBalance presents Assets and Expenses with inverted balances.
//Envelopes all have positive polarity so we need to view expenses negatively. Expenses mean money is going out.
- (NSNumber *)trueBalance
{
	NSDecimalNumber *balance;
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	[request setEntity:entity];
	
	// first we fetch all the toAccount transactions
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"toAccount = %@", self];
	[request setPredicate:predicate];
	NSError *error = nil;
	NSArray *transactions = [moc executeFetchRequest:request error:&error];
	if (transactions == nil){
		NSLog(@"Account toBalance fetch returned nil");
	}
	NSDecimalNumber *toBalance = [transactions valueForKeyPath:@"@sum.amount"];
	//NSLog(@"toBalance is %@",toBalance);
	
	//then we get all the fromAccount transactions
	predicate = [NSPredicate predicateWithFormat:@"fromAccount = %@", self];
	[request setPredicate:predicate];
	error = nil;
	transactions = [moc executeFetchRequest:request error:&error];
	if (transactions == nil){
		NSLog(@"Account fromBalance fetch returned nil");
	}
	NSDecimalNumber *fromBalance = [transactions valueForKeyPath:@"@sum.amount"];
	//NSLog(@"fromBalance is %@",fromBalance);

	//no checking of polarity. We present the true balance.
	//this is backwards as we want expenses to be reflected negatively.
	//what about asset envelopes when we implement them?
	balance = [fromBalance decimalNumberBySubtracting:toBalance];
	
	return balance;
}
@end
