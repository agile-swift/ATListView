//
//  DataSourceProxy.m
//  Alamofire
//
//  Created by 凯文马 on 2018/3/2.
//

#import "DataSourceProxy.h"
#import <objc/runtime.h>

static NSMutableDictionary *dataSourceClassMap = nil;

@implementation DataSourceProxy

+ (instancetype)dataSourceWithListView:(id<UITableViewDataSource>)listView realDataSource:(id<UITableViewDataSource>)realDataSource forObject:(id)object
{
    NSString *clsN = NSStringFromClass([object class]);
    if (clsN == nil) {
        return [[DataSourceProxy alloc] initWithListView:listView realDataSource:realDataSource];
    }
    NSMutableDictionary *map = self.classMap;
    Class cls = map[clsN];
    if (cls) {
        return [[cls alloc] initWithListView:listView realDataSource:realDataSource];
    }
    
    cls = objc_allocateClassPair([DataSourceProxy class], [NSString stringWithFormat:@"%@_DelegateProxy",clsN].UTF8String, 0);
    map[clsN] = cls;
    return [[cls alloc] initWithListView:listView realDataSource:realDataSource];
}

+ (NSMutableDictionary *)classMap
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataSourceClassMap = [@{} mutableCopy];
    });
    return dataSourceClassMap;
}

- (instancetype)initWithListView:(id<UITableViewDataSource>)listView realDataSource:(id<UITableViewDataSource>)realDataSource
{
    self = [super init];
    if (self) {
        _listView = listView;
        _realDataSource = realDataSource;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([_realDataSource respondsToSelector:aSelector]) {
        return YES;
    } else if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}


- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _realDataSource;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [_listView tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_listView tableView:tableView numberOfRowsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_listView numberOfSectionsInTableView:tableView];
}

@end
