//
//  MLWindowsControllerAccounts.m
//  moolah
//
//  Created by Steven Hamilton on 23/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MLAccountController.h"


@implementation MLAccountController

-(void) awakeFromNib{
	//enable bottombar
	[[self window] setContentBorderThickness:22.0 forEdge:NSMinYEdge];
}

- (IBAction)addAccount:(id)sender
{
	//we need to add an account entity and a matching envelope
	NSManagedObjectContext *moc = [self.document managedObjectContext];
	NSEntityDescription *account = [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:moc];
	NSEntityDescription *envelope = [NSEntityDescription insertNewObjectForEntityForName:@"Envelope" inManagedObjectContext:moc];
	[envelope setValue:account forKey:@"account"];
	//targetType is mandatory for envelopes so we need to set to one that all accountTypes can use. We choose weekly.
	//we have an arraycontroller just for this purpose. Lazy or what?
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *weeklyTargetType = [NSEntityDescription entityForName:@"TargetType" inManagedObjectContext:moc];
	[request setEntity:weeklyTargetType];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = 'Weekly'"];
	[request setPredicate:predicate];
	NSError *error = nil;
	NSArray *targetTypes = [moc executeFetchRequest:request error:&error];
		if (targetTypes == nil){
			NSLog(@"fetch returned nil");
		}
		NSLog(@"targetType fetch returned %d",[targetTypes count]);
	[envelope setValue:[targetTypes objectAtIndex:0] forKeyPath:@"targetType"];
	[moc processPendingChanges];
	[accountsTable reloadData];
}

- (IBAction)delAccount:(id)sender
{
	//to delete an account we also need to delete the envelope
	//we only allow deletion of accounts that have no transactions or envelopeTransactions.
	//if transactions exist then deletion will knock everything out of whack. So we do not allow it while transactions exist.
	NSManagedObjectContext *moc = [self.document managedObjectContext];
	Account *selectedAccount = [[accountsController arrangedObjects] objectAtIndex:[accountsController selectionIndex]];
	Envelope *relatedEnvelope = [selectedAccount valueForKeyPath:@"envelope"];
	NSLog(@"Account %@ will be deleted",[selectedAccount name]);
	[moc deleteObject:relatedEnvelope];
	[moc deleteObject:selectedAccount];
	[moc processPendingChanges];
	[accountsTable reloadData];
}


-(NSArray *)nameSortDescriptors
{
	NSSortDescriptor *sorter;
	sorter = [[[NSSortDescriptor alloc]
			   initWithKey: @"name"
			   ascending: YES] autorelease];
	return ([NSArray arrayWithObject: sorter]);
}

@end
