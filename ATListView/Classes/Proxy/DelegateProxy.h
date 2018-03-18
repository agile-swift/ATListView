//
//  DelegateProxy.h
//  ATListView
//
//  Created by 凯文马 on 2018/3/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DelegateProxy : NSObject<UITableViewDelegate>

+ (instancetype)delegateWithListView:(id<UITableViewDelegate>)listView realDelegate:(id<UITableViewDelegate>)realDelegate forObject:(id)object;

- (instancetype)initWithListView:(id<UITableViewDelegate>)listView realDelegate:(id<UITableViewDelegate>)realDelegate;

@property (nonatomic, weak, readonly) id<UITableViewDelegate> listView;

@property (nonatomic, weak, readonly) id<UITableViewDelegate> realDelegate;

@end

