//
//  DataSourceProxy.h
//  Alamofire
//
//  Created by 凯文马 on 2018/3/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataSourceProxy : NSObject <UITableViewDataSource>

+ (instancetype)dataSourceWithMainProxy:(id<UITableViewDataSource>)main secondProxy:(id<UITableViewDataSource>)second forObject:(id)object;

- (instancetype)initWithMainProxy:(id<UITableViewDataSource>)main secondProxy:(id<UITableViewDataSource>)second;

@property (nonatomic, weak) id<UITableViewDataSource> mainProxy;

@property (nonatomic, weak) id<UITableViewDataSource> secondProxy;

- (void)exchangeProxy;

@end
