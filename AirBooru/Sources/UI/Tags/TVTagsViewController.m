//
// Created by qii on 7/28/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "TVTagsViewController.h"
#import "FixUIRefreshUITableView.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "PostByTagViewController.h"
#import "ServersManager.h"
#import "Tag.h"

@interface TVTag : NSObject
@property(nonatomic, strong) NSString *tagName;
@property(nonatomic, strong) NSString *displayName;

+ (instancetype)tagWithTagName:(NSString *)tagName displayName:(NSString *)displayName;
@end

@implementation TVTag
+ (instancetype)tagWithTagName:(NSString *)tagName displayName:(NSString *)displayName {
    TVTag *tag = [[TVTag alloc] init];
    tag.tagName = tagName;
    tag.displayName = displayName;
    return tag;
}
@end

@interface TVTagsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property(nonatomic, strong) NSMutableArray *tagList;
@property(nonatomic, copy) ABUServersManagerImageBoardChangeBlock changeBlock;
@end

@implementation TVTagsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tagList = [NSMutableArray array];
        [self loadTags:[ServersManager sharedInstance].imageBoard];
        __weak TVTagsViewController *weakSelf = self;
        self.changeBlock = ^void(ImageBoard2 *imageBoard) {
            [weakSelf loadTags:[ServersManager sharedInstance].imageBoard];
        };
        [[ServersManager sharedInstance] addImageBoardChangedBlock:self.changeBlock];
    }
    return self;
}

- (void)loadTags:(Danbooru *)board {
    [self.tagList removeAllObjects];
    if (board.isUserConfig) {
        [self.tagList addObject:[TVTag tagWithTagName:@"kantai_collection" displayName:@"艦隊これくしょん - 艦これ -"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"love_live" displayName:@"Love Live"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"touhou" displayName:@"東方 Project"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"vocaloid" displayName:@"Vocaloid"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"fate/stay_night" displayName:@"Fate Stay Night"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"neon_genesis_evangelion" displayName:@"EVA"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"oreimo" displayName:@"俺の妹がこんなに可愛"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"angel_beats!" displayName:@"Angel Beats!"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"k-on" displayName:@"K-ON"]];

        [self.tagList addObject:[TVTag tagWithTagName:@"steins_gate" displayName:@"Steins Gate"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"xxxholic " displayName:@"xxxHolic"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"macross" displayName:@"Macross"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"durarara!!" displayName:@"Durarara!"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"kara_no_kyokai" displayName:@"空の境界"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"spice_and_wolf" displayName:@"狼と香辛料"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"working!!" displayName:@"Working!!"]];
        [self.tagList addObject:[TVTag tagWithTagName:@"gintama" displayName:@"銀魂"]];
    } else {

    }
    [self.tagList addObject:[TVTag tagWithTagName:@"code_geass" displayName:@"Code Geass"]];
    [self.tagList addObject:[TVTag tagWithTagName:@"cowboy_bebop" displayName:@"Cowboy Bebop"]];
    [self.tagList addObject:[TVTag tagWithTagName:@"gundam" displayName:@"Gundam"]];
    [self.tagList addObject:[TVTag tagWithTagName:@"mushishi" displayName:@"蟲師"]];
    [self.tagList addObject:[TVTag tagWithTagName:@"slam_dunk" displayName:@"SLAMDUNK"]];
    [self.tagList addObject:[TVTag tagWithTagName:@"prince_of_tennis" displayName:@"テニスの王子様"]];
    [self.tagList addObject:[TVTag tagWithTagName:@"fullmetal_alchemist" displayName:@"鋼の錬金術師"]];
    [self.tableView reloadData];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.tableView = [[FixUIRefreshUITableView alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(64 + 2, 0, 49 + 2, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 49, 0);
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:NO];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.title = @"Tags";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tagList != nil) {
        return [self.tagList count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    TVTag *tag = self.tagList[indexPath.row];
    cell.textLabel.text = tag.displayName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TVTag *tvTag = self.tagList[indexPath.row];
    PostByTagViewController *controller = [[PostByTagViewController alloc] init];
    controller.imageBoard = [ServersManager sharedInstance].imageBoard;
    Tag *tag = [[Tag alloc] init];
    tag.name = tvTag.tagName;
    controller.postTag = tag;
    [self.navigationController pushViewController:controller animated:YES];
}

@end