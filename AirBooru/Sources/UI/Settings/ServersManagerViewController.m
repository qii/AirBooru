//
// Created by qii on 7/21/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "ServersManagerViewController.h"
#import "ServersManager.h"
#import "ThemeHelper.h"
#import "ToastView.h"
#import "UrlHelper.h"

@interface ServersManagerViewController ()
@property(nonatomic, strong) NSMutableArray *servers;
@end

@implementation ServersManagerViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self loadServers];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                 target:self action:@selector(addServer)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"config_servers"]) {
        [self showTipDialog];
        [defaults setBool:YES forKey:@"config_servers"];
        [defaults synchronize];
    }
}

- (void)showTipDialog {
    UIAlertController *alertController = [UIAlertController
            alertControllerWithTitle:@"Tip"
                             message:@"You can add your own booru server, the content is controlled by yourself."
                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
            actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *action) {
                        NSLog(@"OK action");
                    }];

    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)loadServers {
    self.servers = [ServersManager sharedInstance].imageBoardArray;
    [self.tableView reloadData];
}

- (void)addServer {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Url"
                                                                                   message:@"Please enter your server url"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    [actionSheetController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Server url";
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *field = actionSheetController.textFields[0];
        NSString *content = field.text;
        if (!content || [content length] == 0 || ![UrlHelper validateUrl:content]) {
            [ToastView toastWithTitle:@"Please enter correct url"];
            return;
        }
        [self addServer:content];
        [actionSheetController dismissViewControllerAnimated:YES completion:nil];
    }];
    [actionSheetController addAction:okAction];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [actionSheetController dismissViewControllerAnimated:YES completion:nil];
    }];
    [actionSheetController addAction:cancel];

    actionSheetController.view.tintColor = [ThemeHelper tintColor];
    [self presentViewController:actionSheetController animated:YES completion:nil];
    [actionSheetController.textFields[0] becomeFirstResponder];
}

- (void)addServer:(NSString *)url {
    NSError *error;
    if ([[ServersManager sharedInstance] addServer:url error:&error]) {
        self.servers = [ServersManager sharedInstance].imageBoardArray;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.servers.count - 1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [ToastView toastWithTitle:error.localizedDescription];
    }
}

- (void)deleteServer:(int)index {
    Danbooru *danbooru = self.servers[index];
    [[ServersManager sharedInstance] deleteServer:danbooru];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.servers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    Danbooru *danbooru = self.servers[indexPath.row];
    NSString *name = danbooru.isUserConfig ? danbooru.name : [NSString stringWithFormat:@"%@(default demo)", danbooru.name];
    cell.textLabel.text = name;
    cell.detailTextLabel.text = danbooru.isUserConfig ? danbooru.url : [NSString stringWithFormat:@"default (filter enabled)"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Danbooru *danbooru = self.servers[indexPath.row];
    if (!danbooru.isUserConfig) {
        [ToastView toastWithTitle:@"Can't modify or delete AirBooru default server!"];
        return;
    }
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self deleteServer:indexPath.row];
    }];
    [actionSheetController addAction:alertAction];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [actionSheetController dismissViewControllerAnimated:YES completion:nil];
    }];
    [actionSheetController addAction:cancel];

    actionSheetController.view.tintColor = [ThemeHelper tintColor];
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    Danbooru *danbooru = self.servers[indexPath.row];
    if (!danbooru.isUserConfig) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteServer:indexPath.row];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
@end