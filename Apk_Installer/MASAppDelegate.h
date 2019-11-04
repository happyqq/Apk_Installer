//
//  MASAppDelegate.h
//  Apk_Installer
//
//  Created by 黄启清 on 12-12-20.
//  Copyright (c) 2012年 黄启清. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MASAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
- (IBAction)btnInstall:(id)sender;
- (IBAction)btnWeibo:(id)sender;
- (IBAction)btnAlipay:(id)sender;

@end
