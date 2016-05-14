//
// Created by qii on 5/17/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "MenuView.h"
#import "MenuCell.h"

@interface MenuView () <UITableViewDelegate, UITableViewDataSource>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) NSArray *sectionTitleArray;
@property(strong, nonatomic) NSArray *sectionImageNameArray;
@end

@implementation MenuView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.sectionTitleArray = @[@"Posts", @"Tags", @"Search", @"Settings"];
        self.sectionImageNameArray = @[@"section_latest", @"section_nodes", @"section_latest", @"section_nodes"];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([MenuCell class]) bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:NSStringFromClass([MenuCell class])];
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews {
    self.tableView.frame = (CGRect) {0, 0, self.bounds.size.width, self.bounds.size.height};
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setCenter:(CGPoint)center {
    [super setCenter:center];
}


#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sectionTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MenuCell class]) forIndexPath:indexPath];
    cell.title.text = self.sectionTitleArray[indexPath.row];
    cell.icon.image = [UIImage imageNamed:self.sectionImageNameArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat contentHeight = 0.0;
    for (int section = 0; section < [self numberOfSectionsInTableView:tableView]; section++) {
        for (int row = 0; row < [self tableView:tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            contentHeight += [self tableView:tableView heightForRowAtIndexPath:indexPath];
        }
    }
    return (tableView.bounds.size.height - contentHeight) / 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectedIndexBlock) {
        self.didSelectedIndexBlock(indexPath.row);
    }
}
@end