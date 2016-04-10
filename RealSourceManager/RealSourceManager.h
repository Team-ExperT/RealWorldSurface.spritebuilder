//
//  RealSourceManager.h
//  RealWorldSurface
//
//  Created by Morris on 4/2/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RealSourceManager : NSObject <NSXMLParserDelegate>
{
    NSOperationQueue* operationQueue;
}
@property (nonatomic, readonly) NSArray* regionArray;

#pragma mark Client Method
-(NSArray*)getSubRegionArrayByAreaId:(NSString*)areaId;


#pragma mark Server Method;
-(void)checkDataNumberFromServerWithCompletionHandler: (void (^)(BOOL errorMessage)) completionHandler;
-(void)listAllRegionFromServerWithCompletionHandler: (void (^)(BOOL errorMessage)) completionHandler;
-(void)listDataWithAreaId:(NSString*)areaId  withCompletionHandler: (void (^)(BOOL errorMessage)) completionHandler;
+(RealSourceManager*)shared;
@end