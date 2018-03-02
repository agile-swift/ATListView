//
//  DelegateProxy.h
//  ATListView
//
//  Created by 凯文马 on 2018/3/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DelegateProxy : NSObject<UITableViewDelegate>

+ (instancetype)delegateWithMainProxy:(id<UITableViewDelegate>)main secondProxy:(id<UITableViewDelegate>)second forObject:(id)object;

- (instancetype)initWithMainProxy:(id<UITableViewDelegate>)main secondProxy:(id<UITableViewDelegate>)second;

@property (nonatomic, weak) id<UITableViewDelegate> mainProxy;

@property (nonatomic, weak) id<UITableViewDelegate> secondProxy;

- (void)exchangeProxy;

@end

