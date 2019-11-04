//
//  MASAppDelegate.m
//  Apk_Installer
//
//  Created by 黄启清 on 12-12-20.
//  Copyright (c) 2012年 黄启清. All rights reserved.
//

#import "MASAppDelegate.h"

@implementation MASAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "HappyQQ.cn.Apk_Installer" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"HappyQQ.cn.Apk_Installer"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Apk_Installer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Apk_Installer.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}
-(void) AndroidStartServer:(BOOL) isStart
{
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString* resourcePath = [NSString stringWithFormat:@"%@/Contents/Resources", bundlePath];
    NSString* adbExec = [NSString stringWithFormat:@"%@/adb",resourcePath];
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: adbExec];
    //[task setLaunchPath: @"/usr/bin/grep"];
    
    NSArray *arguments;
    if (isStart == YES) {
        
         arguments = [NSArray arrayWithObjects: @"start-server",  nil];
    }
    else
    {
        arguments = [NSArray arrayWithObjects: @"kill-server",  nil];

    }
   
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"Returned:\n%@", string);
    
}

- (void) openPanelDidEnd: (NSOpenPanel *) sheet
              returnCode: (int) returnCode
             contextInfo: (void *) context
{
    if (returnCode == NSOKButton) {
        NSArray *files = [sheet filenames];
        
        NSLog (@"选择转换的文件是: %@", [files objectAtIndex: 0]);
        
        // 下面这个获得resourcepath 的真实路径，为shell作准备。
        
        NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString* resourcePath = [NSString stringWithFormat:@"%@/Contents/Resources", bundlePath];
        NSString* adbExec = [NSString stringWithFormat:@"%@/adb",resourcePath];
        NSString* aaptExec = [NSString stringWithFormat:@"%@/aapt",resourcePath];
        
        NSLog (@"bundlePath:\n%@", bundlePath);
        NSLog (@"resourcePath:\n%@", resourcePath);
        
        NSLog (@"adbExec:\n%@", adbExec);
        NSLog (@"aaptExec:\n%@", aaptExec);
        
        // 以下部分为调用shell命令部分
        
        
        //[self AndroidStartServer:NO];
        [self AndroidStartServer:YES];
        
        NSTask *task;
        task = [[NSTask alloc] init];
        [task setLaunchPath: adbExec];
        //[task setLaunchPath: @"/usr/bin/grep"];
        
        NSArray *arguments;
        arguments = [NSArray arrayWithObjects: @"install", [files objectAtIndex: 0], nil];
        [task setArguments: arguments];
        
        NSPipe *pipe;
        pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        
        NSFileHandle *file;
        file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData *data;
        data = [file readDataToEndOfFile];
        
        NSString *string;
        string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        NSLog (@"Returned:\n%@", string);
        
        NSRange range;
        range = [string rangeOfString:@"Success"];
        
        
        NSString *theAlertMessage ;
       
        
        if (range.location!=NSNotFound) {
            theAlertMessage = [NSString stringWithFormat:
                                @"安装成功：%@", [files objectAtIndex: 0]];
        }
        else
        {   //INSTALL_FAILED_ALREADY_EXISTS
            NSRange tmp;
            tmp = [string rangeOfString:@"INSTALL_FAILED_ALREADY_EXISTS"];
        if (range.location!=NSNotFound)
        {
            
            theAlertMessage = [NSString stringWithFormat:
                               @"失败喽，真不好意思啦，你是不是没接好手机呀，请重新选择一下这个文件吧：%@", [files objectAtIndex: 0]];
        }
            else
            {
                
                theAlertMessage = [NSString stringWithFormat:
                                   @"亲，你不要重复安装啦，手机上早就存在这个软件啦！！", [files objectAtIndex: 0]];
            }
           
           
            
        }
        
         NSRunAlertPanel( @"提醒", theAlertMessage, @"OK", nil, nil );
        

        
        /*
        
        NSString *path = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@".o"];
        NSLog (@"PATH:\n%@", path);
        
        NSBundle* myBundle = [NSBundle mainBundle];
        NSString* myImage = [myBundle pathForResource:@"Seagull" ofType:@"jpg"];
        NSLog (@"myImage:\n%@", myImage);
         */
        
        
       // int retCode = 10;
       // NSString *theAlertMessage = [NSString stringWithFormat:
       //                              @"Return code is %d", retCode];
        //Success
        
       // NSString *theAlertMessage = [NSString stringWithFormat:
       //                              @"安装成功：%@", [files objectAtIndex: 0]];
       // NSRunAlertPanel( @"提醒", theAlertMessage, @"OK", nil, nil );
        
        //NSRunAlertPanel( @"目录测试", resourcePath, @"OK", nil, nil );
        
    }
    
}

- (IBAction)btnInstall:(id)sender {
   // NSString *mystr = @"123";
   // NSLog(@"%@",mystr);
    
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setPrompt: @"选择APK文件"];
    
    
    
    [panel beginSheetForDirectory: nil
     
     
                             file: nil
                            types: [NSArray arrayWithObject: @"apk"] // 文件类型
                   modalForWindow: _window
     
     
                    modalDelegate: self
                   didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:)
                      contextInfo: nil];
    

   

    

    
    //[string release];
    //[task release];
}

-(void) runScript:(NSString*)scriptName
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments;
    NSString* newpath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] privateFrameworksPath], scriptName];
    NSLog(@"shell script path: %@",newpath);
    arguments = [NSArray arrayWithObjects:newpath, nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"script returned:\n%@", string);
}

NSString *runCommand(NSString *commandToRun)
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command: %@",commandToRun);
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return output;
}

- (void)openURL:(NSString *)url inBackground:(BOOL)background
{
    if (background)
    {
        NSArray* urls = [NSArray arrayWithObject:[NSURL URLWithString:url]];
        [[NSWorkspace sharedWorkspace] openURLs:urls withAppBundleIdentifier:nil options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:nil];
    }
    else
    {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    }
}

- (IBAction)btnWeibo:(id)sender {
    [self openURL:@"http://weibo.com/HappyQQ" inBackground:NO];
}

- (IBAction)btnAlipay:(id)sender {
    [self openURL:@"https://me.alipay.com/HappyQQ" inBackground:NO];

}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
