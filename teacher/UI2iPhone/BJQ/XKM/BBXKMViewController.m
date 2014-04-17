

#import "BBXKMViewController.h"

@interface BBXKMViewController ()

@end

@implementation BBXKMViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"科目";
    
    kmList = @[@"不指定科目",@"语文",@"数学"];
    
    //_selectedIndex = 0;
    
    colorList = @[[UIColor colorWithRed:238/255.0 green:140/255.0 blue:35/255.0 alpha:1.0],
                 [UIColor colorWithRed:250/255.0 green:80/255.0 blue:97/255.0 alpha:1.0],
                 [UIColor colorWithRed:87/255.0 green:131/255.0 blue:237/255.0 alpha:1.0],
                 [UIColor brownColor],
                 [UIColor greenColor],
                 [UIColor yellowColor],
                 [UIColor purpleColor]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kmList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
        [cell.contentView addSubview:label];
        label.tag = 111;
    }
    
    cell.textLabel.text = kmList[indexPath.row];
    
    if (_selectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:111];
    label.backgroundColor = colorList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedIndex = indexPath.row;
    [tableView reloadData];
    
    if (_xkmDelegate&&[_xkmDelegate respondsToSelector:@selector(bbXKMViewController:didSelectedIndex:)]) {
        [_xkmDelegate bbXKMViewController:self didSelectedIndex:_selectedIndex];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
