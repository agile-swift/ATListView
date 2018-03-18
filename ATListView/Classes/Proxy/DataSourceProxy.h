//
//  DataSourceProxy.h
//  Alamofire
//
//  Created by 凯文马 on 2018/3/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataSourceProxy : NSObject <UITableViewDataSource>

+ (instancetype)dataSourceWithListView:(id<UITableViewDataSource>)listView realDataSource:(id<UITableViewDataSource>)realDataSource forObject:(id)object;

- (instancetype)initWithListView:(id<UITableViewDataSource>)listView realDataSource:(id<UITableViewDataSource>)realDataSource;

@property (nonatomic, weak, readonly) id<UITableViewDataSource> listView;

@property (nonatomic, weak, readonly) id<UITableViewDataSource> realDataSource;

@end
