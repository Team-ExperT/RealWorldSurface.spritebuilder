//
//  RealSourceManager.m
//  RealWorldSurface
//
//  Created by Morris on 4/2/16.
//  Copyright © 2016 Apportable. All rights reserved.
//
#define TIMEOUT 30
#import "RealSourceManager.h"
#import "VSConstant.h"
static RealSourceManager* sharedManager;
@implementation RealSourceManager
@synthesize regionArray = _regionArray;
- (instancetype)init
{
    self = [super init];
    if (self) {
        operationQueue = [[NSOperationQueue alloc]init];
    }
    return self;
}
-(NSArray *)getSubRegionArrayByAreaId:(NSString *)areaId
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",areaId]];
    return [NSArray arrayWithContentsOfFile:plistPath];
}
-(void)deleteAllPlist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    for(NSDictionary* thisArea in self.regionArray)
    {
        NSString* areaKey = [thisArea objectForKey:AreaKey];
        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",areaKey]];
        [[NSFileManager defaultManager]removeItemAtPath:plistPath error:nil];
        
        
    }
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Area.plist"]];
    [[NSFileManager defaultManager]removeItemAtPath:plistPath error:nil];
}
-(NSArray *)regionArray
{
    if(!_regionArray)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"Area.plist"];
        _regionArray = [NSArray arrayWithContentsOfFile:plistPath];
    }
    return _regionArray;
}
-(void)checkDataNumberFromServerWithCompletionHandler:(void (^)(bool))completionHandler
{
    [operationQueue addOperationWithBlock:^(){
        NSString *str=@"http://vicsurv.cloudapp.net:5780/api/get_current_version";
        NSURL *url=[NSURL URLWithString:str];
        NSData *data=[NSData dataWithContentsOfURL:url];
        NSError *error=nil;
        NSDictionary* response=[NSJSONSerialization JSONObjectWithData:data options:
                           NSJSONReadingMutableContainers error:&error];
        
        if(!error)
        {
          
            NSString* clientVersion = [[NSUserDefaults standardUserDefaults]objectForKey:@"version"];
            NSString* serverVersion = [response objectForKey:@"version"];
            if([clientVersion intValue] < [serverVersion intValue])
            {
                [self deleteAllPlist];
                [[NSUserDefaults standardUserDefaults]setObject:serverVersion forKey:@"version"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            completionHandler(YES);
            
        }
        else
        {
            completionHandler(NO);
        }
        
    }];

}
-(void)listAllRegionFromServerWithCompletionHandler: (void (^)(BOOL errorMessage)) completionHandler

{
    
    [operationQueue addOperationWithBlock:^(){
        NSString *str=@"http://vicsurv.cloudapp.net:5780/api/get_areas";
        NSURL *url=[NSURL URLWithString:str];
        NSData *data=[NSData dataWithContentsOfURL:url];
        NSError *error=nil;
        NSArray* response=[NSJSONSerialization JSONObjectWithData:data options:
                           NSJSONReadingMutableContainers error:&error];
        
        if(!error)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"Area.plist"];
            // NSArray* thisArrau = @[@"1",@"2",@"3"];
            //[thisArrau writeToFile:plistPath atomically:YES];
            NSMutableArray* newArray = [NSMutableArray array];
            
            ///  [response writeToFile:plistPath atomically:YES];
            for(NSDictionary* thisDic in response)
            {
                NSString* area = [thisDic objectForKey:@"area"];
                NSString* area_id = [thisDic objectForKey:@"area_id"];;
                CCLOG(@"area:%@ id:%@",area,area_id);
                NSDictionary* newDic = @{AreaName:area,AreaKey:area_id};
                [newArray addObject:newDic];
                
                
            }
            [newArray writeToFile:plistPath atomically:YES];
            _regionArray = newArray;
            completionHandler(YES);
            
        }
        else
        {
            completionHandler(NO);
        }

    }];
   
}
-(void)listDataWithAreaId:(NSString*)areaId  withCompletionHandler: (void (^)(BOOL errorMessage)) completionHandler;
{
    NSString *str=[NSString stringWithFormat:@"http://vicsurv.cloudapp.net:5780/api/get_regions/%@",areaId];
    NSURL *url=[NSURL URLWithString:str];
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error=nil;
    NSArray* response=[NSJSONSerialization JSONObjectWithData:data options:
                       NSJSONReadingMutableContainers error:&error];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",areaId]];
    [response writeToFile:plistPath atomically:YES];
    
    if(!error)
    {
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"Area.plist"];
//        [response writeToFile:plistPath atomically:YES];
//        for(NSDictionary* thisDic in response)
//        {
//            NSString* area = [thisDic objectForKey:@"area"];
//            NSString* area_id = [thisDic objectForKey:@"area_id"];;
//            CCLOG(@"area:%@ id:%@",area,area_id);
//            
//            
//        }
        completionHandler(YES);

    }
    else
    {
        completionHandler(NO);
    }
   
}
+(RealSourceManager *)shared
{
    if(!sharedManager)
    {
        sharedManager = [[RealSourceManager alloc]init];
    }
    return sharedManager;
}
@end