/*
 * Copyright 2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 * http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    application.applicationIconBadgeNumber = 0;
    
    UIMutableUserNotificationAction *readAction = [[UIMutableUserNotificationAction alloc] init];
    readAction.identifier = @"READ_IDENTIFIER";
    readAction.title = @"Read";
    readAction.activationMode = UIUserNotificationActivationModeForeground;
    readAction.destructive = NO;
    readAction.authenticationRequired = YES;
    
    UIMutableUserNotificationAction *ignoreAction = [[UIMutableUserNotificationAction alloc] init];
    ignoreAction.identifier = @"IGNORE_IDENTIFIER";
    ignoreAction.title = @"Ignore";
    ignoreAction.activationMode = UIUserNotificationActivationModeBackground;
    ignoreAction.destructive = NO;
    ignoreAction.authenticationRequired = NO;
    
    UIMutableUserNotificationAction *deleteAction = [[UIMutableUserNotificationAction alloc] init];
    deleteAction.identifier = @"DELETE_IDENTIFIER";
    deleteAction.title = @"Delete";
    deleteAction.activationMode = UIUserNotificationActivationModeForeground;
    deleteAction.destructive = YES;
    deleteAction.authenticationRequired = YES;
    
    UIMutableUserNotificationCategory *messageCategory = [[UIMutableUserNotificationCategory alloc] init];
    messageCategory.identifier = @"MESSAGE_CATEGORY";
    [messageCategory setActions:@[readAction, ignoreAction, deleteAction] forContext:UIUserNotificationActionContextDefault];
    [messageCategory setActions:@[readAction, deleteAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObject:messageCategory];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    if(launchOptions!=nil){
        NSString *msg = [NSString stringWithFormat:@"%@", launchOptions];
        NSLog(@"%@",msg);
        [self createAlert:msg];
    }
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    NSLog(@"deviceToken: %@", deviceToken);
    NSLog(@"deviceToken: %@", deviceToken);
    
    NSString *token = deviceToken.description;
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableDictionary *mutalbleDic = [[NSMutableDictionary alloc]init];
    [mutalbleDic setValue:@"ios" forKey:@"os"];
    [mutalbleDic setValue:token forKey:@"token"];
    
    NSData *rawData = [NSJSONSerialization dataWithJSONObject:mutalbleDic options:NSJSONWritingPrettyPrinted error:nil] ;
    NSString *json = [ [NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
    NSData *requestData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL: [NSURL URLWithString:@"https://4lbwnz74eg.execute-api.ap-northeast-1.amazonaws.com/group4-stage/add-user-subscript"]];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:60.0];
    [request setValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody: requestData];
    
     [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
         if(connectionError){
            NSLog(@"connectionError: %@", connectionError);
             return;
         }
         
         NSInteger statusCode = [(NSHTTPURLResponse *) response statusCode];
         if(statusCode != 200){
             NSLog(@"statusCode: %li", (long)statusCode);
             NSLog(@"response: %@", (NSHTTPURLResponse *) response );
             return;
         }
        
         NSLog(@"sendAsynchronousRequest: Finish");
     }];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    NSLog(@"Failed to register with error : %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    application.applicationIconBadgeNumber = 0;
    NSLog(@"%@", userInfo);
    NSString *msg =  [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    [self createAlert:msg];
}

- (void)createAlert:(NSString *)msg {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Received" message:[NSString stringWithFormat:@"%@", msg]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    NSLog(@"%@",msg);
    
    [alertView show];
}

- (void)application:(UIApplication *) application handleActionWithIdentifier:(NSString *)identifier
       forRemoteNotification:(NSDictionary *)notification completionHandler:(void (^)())completionHandler{
    if ([identifier isEqualToString:@"READ_IDENTIFIER"]){
        NSString *msg = [NSString stringWithFormat:@"%@", @"read"];
        [self createAlert:msg];
    }else if ([identifier isEqualToString:@"DELETE_IDENTIFIER"]){
        NSString *msg = [NSString stringWithFormat:@"%@", @"delete"];
        [self createAlert:msg];
    }
    
    completionHandler();
}

@end
