//
//  DelegateProxy.m
//  ATListView
//
//  Created by 凯文马 on 2018/3/1.
//

#import "DelegateProxy.h"
#import <objc/runtime.h>

static NSMutableDictionary *delegateClassMap = nil;

@interface DelegateProxy ()

@property (nonatomic, weak) id<UITableViewDelegate> heightResponser;

@end

@implementation DelegateProxy

+ (instancetype)delegateWithListView:(id<UITableViewDelegate>)listView realDelegate:(id<UITableViewDelegate>)realDelegate forObject:(id)object
{
    NSString *clsN = NSStringFromClass([object class]);
    if (clsN == nil) {
        return [[DelegateProxy alloc] initWithListView:listView realDelegate:realDelegate];
    }
    NSMutableDictionary *map = self.classMap;
    Class cls = map[clsN];
    if (cls) {
        return [[cls alloc] initWithListView:listView realDelegate:realDelegate];
    }
    
    cls = objc_allocateClassPair([DelegateProxy class], [NSString stringWithFormat:@"%@_DelegateProxy",clsN].UTF8String, 0);
    map[clsN] = cls;
    return [[cls alloc] initWithListView:listView realDelegate:realDelegate];
}

+ (NSMutableDictionary *)classMap
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegateClassMap = [@{} mutableCopy];
    });
    return delegateClassMap;
}

- (instancetype)initWithListView:(id<UITableViewDelegate>)listView realDelegate:(id<UITableViewDelegate>)realDelegate
{
    self = [super init];
    if (self) {
        _listView = listView;
        _realDelegate = realDelegate;
        _heightResponser = listView;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    
    if ([_realDelegate respondsToSelector:aSelector]) {
        if ([NSStringFromSelector(aSelector) isEqualToString:@"tableView:heightForRowAtIndexPath:"]) {
            _heightResponser = _realDelegate;
        }
        return YES;
    } else if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_heightResponser tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _realDelegate;
}

@end


