//
//  MLcalculator.m
//  moolah
//
//  Created by Steven Hamilton on 29/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MLcalculator.h"


@implementation MLCalculator

- (NSArray *) enumerateBalance:(NSArray *)transactions withPolarity:(BOOL *)polarity
{
	//takes the formattedTransactions from displayAccount and returns a balance.
	//NSLog(@"Doing balance with polarity %d",polarity);
	NSDecimalNumber *balance = [NSDecimalNumber zero];
	NSDecimalNumber *previousBalance = [NSDecimalNumber zero];
	NSDictionary *transdic;
	if (polarity){
		//income and liabilities
		for (transdic in transactions){
			NSDecimalNumber *in = [transdic objectForKey:@"debit"];
			NSDecimalNumber *out = [transdic objectForKey:@"credit"];
			if (transdic == [transactions objectAtIndex:0]){
				if (![[out className] isEqualToString:@"NSNull"]){
					balance = out;
				} else {
					balance = [balance decimalNumberBySubtracting:in];
				}
			} else {
				if (![[out className] isEqualToString:@"NSNull"]){
					balance = [out decimalNumberByAdding:previousBalance];
				} else {
					balance = [previousBalance decimalNumberBySubtracting:in];
				}
			}
			//set balance in table
			[transdic setValue:balance forKey:@"balance"];
			//set previous balance for next iteration
			previousBalance = balance;
			//NSLog(@"current balance is: %@",balance);
		}
	} else {
		//assets and expenses
		for (transdic in transactions){
			NSDecimalNumber *in = [transdic objectForKey:@"debit"];
			NSDecimalNumber *out = [transdic objectForKey:@"credit"];
			//NSLog(@"in classname is %@",[in className]);
			//NSLog(@"out classname is %@",[out className]);

			if (transdic == [transactions objectAtIndex:0]){
				if (![[in className] isEqualToString:@"NSNull"]){
					balance = in;
				} else {
					balance = [balance decimalNumberBySubtracting:out];
				}
			} else {
				if (![[in className] isEqualToString:@"NSNull"]){
					//NSLog(@"balance is %@, previousBalance is %@",balance, previousBalance);
					balance = [in decimalNumberByAdding:previousBalance];
				} else {
					balance = [previousBalance decimalNumberBySubtracting:out];
				}
			}
			//set balance in table
			[transdic setValue:balance forKey:@"balance"];
			//set previous balance for next iteration
			previousBalance = balance;
			//NSLog(@"current balance is: %@",balance);
		}
	}
	return (transactions);
}

// this returns the last outgoing transactions from an Income account. It sums together multiple entries from the same day.
-(NSDecimalNumber *) lastIncomeForEnvelope:(Envelope *)envelope
{
	NSDecimalNumber *lastIncome;
	//first check if Income account then fetch all outgoing transactions
	if ([[envelope valueForKeyPath:@"account.type.name"] isEqualToString:@"Income"]){
		NSManagedObjectContext *moc = [envelope managedObjectContext];
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
		[request setEntity:entity];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fromAccount = %@", [envelope valueForKeyPath:@"account"]];
		[request setPredicate:predicate];
		NSError *error = nil;
		NSArray *transactions = [moc executeFetchRequest:request error:&error];
		if (transactions == nil){
			NSLog (@"lastIncome fetch returned nil");
		}
		//sort by date
		NSSortDescriptor *dateDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:dateDescriptor, nil];
		transactions = [transactions sortedArrayUsingDescriptors:sortDescriptors];
		//filter array and @sum entries from the same date
		NSDate *date = [[transactions objectAtIndex:0] valueForKeyPath:@"date"];
		NSPredicate *incomeDate = [NSPredicate predicateWithFormat:@"date = %@", date];
		transactions = [transactions filteredArrayUsingPredicate:incomeDate];
		NSLog (@"%@, transaction count %d, lastobject is %@", date, [transactions count], [[transactions lastObject] valueForKeyPath:@"amount"]);
		lastIncome = [transactions valueForKeyPath:@"@sum.amount"];
		NSLog (@"lastIncome in Income account is %@",lastIncome);
	} else {
		lastIncome = [NSDecimalNumber zero];
		//NSLog (@"Not an Income account so lastIncome is %@",lastIncome);
	}
	//NSLog (@"returning lastIncome is %@",lastIncome);
	return lastIncome;
}	

-(NSDecimalNumber *) averageIncomeForEnvelope:(Envelope *)envelope
{
	NSDecimalNumber *averageIncome;
	NSDecimalNumber *totalIncome;
	NSDecimalNumber *incomeMod;
	NSDecimalNumberHandler *incomeModHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:YES raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES];
	NSDecimalNumberHandler *averageIncomeHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:2 raiseOnExactness:YES raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES];

	
	//change this with a preference
	NSDecimalNumber *averagePeriod = [NSDecimalNumber decimalNumberWithString:@"90"];
	
	//fetch Income targetType (period and work out our average modifer
	NSString *incomeType = [envelope valueForKeyPath:@"targetType.name"];
	if ([incomeType isEqualToString:@"Weekly"]){
		incomeMod = [NSDecimalNumber  decimalNumberWithString:@"7"];
	} else if ([incomeType isEqualToString:@"Biweekly"]){
		incomeMod = [NSDecimalNumber  decimalNumberWithString:@"14"];
	} else if ([incomeType isEqualToString:@"Monthly"]){
		incomeMod = [NSDecimalNumber  decimalNumberWithString:@"30"];
	}
	incomeMod = [averagePeriod decimalNumberByDividingBy:incomeMod withBehavior:incomeModHandler];
	NSLog (@"first incomeMod is %@",incomeMod);
	
	//first check if Income account then fetch all outgoing transactions
	if ([[envelope valueForKeyPath:@"account.type.name"] isEqualToString:@"Income"]){
		NSManagedObjectContext *moc = [envelope managedObjectContext];
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
		[request setEntity:entity];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fromAccount = %@", [envelope valueForKeyPath:@"account"]];
		[request setPredicate:predicate];
		NSError *error = nil;
		NSArray *transactions = [moc executeFetchRequest:request error:&error];
		if (transactions == nil){
			NSLog (@"lastIncome fetch returned nil");
		}
		//sort by date
		NSSortDescriptor *dateDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:dateDescriptor, nil];
		transactions = [transactions sortedArrayUsingDescriptors:sortDescriptors];
		
		//filter array with date range and @sum entries from the same date
		//todo: replace time Interval with preference.
		NSDate *lastDate = [[transactions objectAtIndex:0] valueForKeyPath:@"date"];
		NSDate *firstDate = [lastDate initWithTimeInterval:-7776000 sinceDate:lastDate];
		NSPredicate *incomeDate = [NSPredicate predicateWithFormat:@"date <= %@ AND date > %@", lastDate, firstDate];
		transactions = [transactions filteredArrayUsingPredicate:incomeDate];
		NSLog (@"%@, transaction count %d, lastobject is %@", firstDate, [transactions count], [[transactions lastObject] valueForKeyPath:@"amount"]);
		totalIncome = [transactions valueForKeyPath:@"@sum.amount"];
		NSLog (@"totalIncome in average Income period is %@",totalIncome);
		averageIncome = [totalIncome decimalNumberByDividingBy:incomeMod withBehavior:averageIncomeHandler];
		NSLog (@"averageIncome in Income account is %@",averageIncome);
	} else {
		averageIncome = [NSDecimalNumber zero];
		//NSLog (@"Not an Income account so lastIncome is %@",lastIncome);
	}
	//NSLog (@"returning lastIncome is %@",lastIncome);
	return averageIncome;
}

@end
