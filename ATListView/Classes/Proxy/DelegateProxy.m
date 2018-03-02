//
//  DelegateProxy.m
//  ATListView
//
//  Created by 凯文马 on 2018/3/1.
//

#import "DelegateProxy.h"
#import <objc/runtime.h>

static NSMutableDictionary *delegateClassMap = nil;

@implementation DelegateProxy

+ (instancetype)delegateWithMainProxy:(id<UITableViewDelegate>)main secondProxy:(id<UITableViewDelegate>)second forObject:(id)object
{
    NSString *clsN = NSStringFromClass([object class]);
    if (clsN == nil) {
        return [[DelegateProxy alloc] initWithMainProxy:main secondProxy:second];
    }
    NSMutableDictionary *map = self.classMap;
    Class cls = map[clsN];
    if (cls) {
        return [[cls alloc] initWithMainProxy:main secondProxy:second];
    }
    
    cls = objc_allocateClassPair([DelegateProxy class], [NSString stringWithFormat:@"%@_DelegateProxy",clsN].UTF8String, 0);
    map[clsN] = cls;
    return [[cls alloc] initWithMainProxy:main secondProxy:second];
}

+ (NSMutableDictionary *)classMap
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegateClassMap = [@{} mutableCopy];
    });
    return delegateClassMap;
}

- (instancetype)initWithMainProxy:(id<UITableViewDelegate>)main secondProxy:(id<UITableViewDelegate>)second
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

@end

