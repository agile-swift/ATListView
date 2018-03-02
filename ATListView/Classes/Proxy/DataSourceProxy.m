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

+ (instancetype)dataSourceWithMainProxy:(id<UITableViewDataSource>)main secondProxy:(id<UITableViewDataSource>)second forObject:(id)object
{
    NSString *clsN = NSStringFromClass([object class]);
    if (clsN == nil) {
        return [[DataSourceProxy alloc] initWithMainProxy:main secondProxy:second];
    }
    NSMutableDictionary *map = self.classMap;
    Class cls = map[clsN];
    if (cls) {
        return [[cls alloc] initWithMainProxy:main secondProxy:second];
    }
    
    cls = objc_allocateClassPair([DataSourceProxy class], [NSString stringWithFormat:@"%@_DelegateProxy",clsN].UTF8String, 0);
    map[clsN] = cls;
    return [[cls alloc] initWithMainProxy:main secondProxy:second];
}

+ (NSMutableDictionary *)classMap
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataSourceClassMap = [@{} mutableCopy];
    });
    return dataSourceClassMap;
}

- (instancetype)initWithMainProxy:(id<UITableViewDataSource>)main secondProxy:(id<UITableViewDataSource>)second
{
    self = [super init];
    if (self) {
        _mainProxy = main;
        _secondProxy = second;
    }
    return self;
}

- (void)exchangeProxy
{
    if (!self.mainProxy || !self.secondProxy) {
        return;
    }
    id temp = self.mainProxy;
    self.mainProxy = self.secondProxy;
    self.secondProxy = temp;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL sp = [super respondsToSelector:aSelector];
    BOOL m = [self.mainProxy respondsToSelector:aSelector];
    BOOL s = [self.secondProxy respondsToSelector:aSelector];
    return sp || m || s;
}


- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([_mainProxy respondsToSelector:aSelector]) {
        return _mainProxy;
    } else if ([_secondProxy respondsToSelector:aSelector]) {
        return _secondProxy;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    id<UITableViewDataSource> proxy = _mainProxy ?: _secondProxy;
    if (proxy) {
        return [proxy tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return [[UITableViewCell alloc] init];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<UITableViewDataSource> proxy = _mainProxy ?: _secondProxy;
    if (proxy) {
        return [proxy tableView:tableView numberOfRowsInSection:section];
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    id<UITableViewDataSource> proxy = _mainProxy ?: _secondProxy;
    if (proxy) {
        return [proxy numberOfSectionsInTableView:tableView];
    }
    return 1;
}

@end
