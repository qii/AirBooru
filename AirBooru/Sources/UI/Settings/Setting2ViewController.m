//
// Created by qii on 7/11/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "Setting2ViewController.h"
#import "SettingCell.h"
#import "ThemeHelper.h"
#import "SettingSwitchCell.h"
#import "ServersManagerViewController.h"

typedef NS_ENUM(NSInteger, SettingSection) {
    SettingSectionServers = 0,
    SettingSectionBrowsing = 2,
    SettingSectionCache = 3,
    SettingSectionInfo = 1
};

@interface Setting2ViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation Setting2ViewController

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [ThemeHelper settingBackgroundColor];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark - TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SettingSectionServers) {
        return 1;
    } else if (section == SettingSectionBrowsing) {
        return 2;
    } else if (section == SettingSectionCache) {
        return 1;
    } else if (section == SettingSectionInfo) {
        return 3;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SettingIdentifier";
    SettingCell *settingCell = (SettingCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!settingCell) {
        settingCell = [[SettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    static NSString *switchCellIdentifier = @"SwitchSettingIdentifier";
    SettingSwitchCell *switchCell = (SettingSwitchCell *) [tableView dequeueReusableCellWithIdentifier:switchCellIdentifier];
    if (!switchCell) {
        switchCell = [[SettingSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:switchCellIdentifier];
    }

    if (indexPath.section == SettingSectionServers) {
        settingCell.title = NSLocalizedString(@"Manage Servers",nil);
        settingCell.top = YES;
        settingCell.bottom = YES;
    }

    if (indexPath.section == SettingSectionBrowsing) {
        if (indexPath.row == 0) {
            switchCell.title = NSLocalizedString(@"Safe Browsing",nil);
            switchCell.top = YES;
            switchCell.bottom = NO;
            return switchCell;
        }

        if (indexPath.row == 1) {
            settingCell.title = NSLocalizedString(@"Rating Levels",nil);
            settingCell.top = NO;
            settingCell.bottom = YES;
        }
    }

    if (indexPath.section == SettingSectionCache) {
        if (indexPath.row == 0) {
            settingCell.title = NSLocalizedString(@"Clear Local Cache",nil);
            settingCell.top = YES;
            settingCell.bottom = YES;
        }

        if (indexPath.row == 1) {
            settingCell.title = NSLocalizedString(@"Limit Max Cache Size",nil);
            settingCell.top = NO;
            settingCell.bottom = YES;
        }
    }

    if (indexPath.section == SettingSectionInfo) {
        if (indexPath.row == 0) {
            settingCell.title = NSLocalizedString(@"Author",nil);
            settingCell.rightTitle = @"qiibeta";
            settingCell.top = YES;
            settingCell.bottom = NO;
        }

        if (indexPath.row == 1) {
            settingCell.title = NSLocalizedString(@"Version",nil);
            settingCell.rightTitle = @"0.1";
            settingCell.top = NO;
            settingCell.bottom = NO;
        }

        if (indexPath.row == 2) {
            settingCell.title = NSLocalizedString(@"Write a review",nil);
            settingCell.rightTitle = @"";
            settingCell.top = NO;
            settingCell.bottom = YES;
        }
    }
    return settingCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == SettingSectionServers) {
        [self.navigationController pushViewController:[[ServersManagerViewController alloc] initWithStyle:UITableViewStylePlain] animated:YES];
    }

    if (indexPath.section == SettingSectionInfo) {
        if (indexPath.row == 2) {
            NSString *iTunesLink = @"https://itunes.apple.com/us/app/airbooru/id1018160420?l=zh&ls=1&mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

@end