//
//  NSManagedObject.Transaction.h
//  moolah
//
//  Created by Steven Hamilton on 16/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSEntityDescription (Transaction)

@property(retain) NSDate* date;
@property(retain) NSString* memo;
@property(retain) NSNumber* amount;

@end
