#import "ZMMenuController.h"
#import "ZMLicenseManager.h"

// ---- Feature flags (toggle per build) ----
static BOOL zmAimbotEnabled = NO;
static BOOL zmVisualsEnabled = NO;
static BOOL zmNoReloadEnabled = NO;
static BOOL zmSpeedEnabled = NO;
static BOOL zmNoFogEnabled = NO;

@interface ZMMenuController ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) BOOL isValidated;
@property (nonatomic, assign) BOOL isValidating;
@end

@implementation ZMMenuController

+ (instancetype)sharedController {
    static ZMMenuController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZMMenuController alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isVisible = NO;
        _isValidated = NO;
        _isValidating = NO;
    }
    return self;
}

- (void)toggle {
    if (_isValidating) return;

    if (_isValidated) {
        // Already validated — just show/hide menu
        if (_isVisible) {
            [self hideMenu];
        } else {
            [self showMenu];
        }
        return;
    }

    // First tap — validate license
    _isValidating = YES;
    [ZMLicenseManager validateWithCallback:^(BOOL success, NSString *message) {
        self.isValidating = NO;
        if (success) {
            self.isValidated = YES;
            [self showMenu];
        } else {
            // Show KEY INCORRECT alert — no key entry prompt
            UIAlertController *alert = [UIAlertController
                alertControllerWithTitle:@"ZOMBI MOD"
                message:@"KEY INCORRECT"
                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
            [alert addAction:ok];

            UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (root.presentedViewController) root = root.presentedViewController;
            [root presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (void)showMenu {
    if (_isVisible) return;
    _isVisible = YES;

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) return;

    [self setupMenuInWindow:window];

    _containerView.transform = CGAffineTransformMakeScale(0.85, 0.85);
    _containerView.alpha = 0;
    [UIView animateWithDuration:0.25
                          delay:0
         usingSpringWithDamping:0.75
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.containerView.transform = CGAffineTransformIdentity;
        self.containerView.alpha = 1;
    } completion:nil];
}

- (void)hideMenu {
    if (!_isVisible) return;
    _isVisible = NO;

    [UIView animateWithDuration:0.2
                     animations:^{
        self.containerView.alpha = 0;
        self.containerView.transform = CGAffineTransformMakeScale(0.85, 0.85);
    } completion:^(BOOL finished) {
        [self.containerView removeFromSuperview];
        self.containerView = nil;
    }];
}

- (void)setupMenuInWindow:(UIWindow *)window {
    CGFloat menuWidth = 280;
    CGFloat menuHeight = 420;
    CGFloat x = (window.bounds.size.width - menuWidth) / 2;
    CGFloat y = (window.bounds.size.height - menuHeight) / 2;

    _containerView = [[UIView alloc] initWithFrame:CGRectMake(x, y, menuWidth, menuHeight)];
    _containerView.backgroundColor = [UIColor colorWithRed:0.07 green:0.09 blue:0.12 alpha:0.97];
    _containerView.layer.cornerRadius = 16;
    _containerView.layer.borderWidth = 1;
    _containerView.layer.borderColor = [UIColor colorWithRed:0.15 green:0.88 blue:0.55 alpha:0.5].CGColor;
    _containerView.layer.shadowColor = [UIColor colorWithRed:0.15 green:0.88 blue:0.55 alpha:0.3].CGColor;
    _containerView.layer.shadowRadius = 20;
    _containerView.layer.shadowOpacity = 1;
    _containerView.layer.shadowOffset = CGSizeZero;
    _containerView.clipsToBounds = NO;

    // Header
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, 50)];
    header.backgroundColor = [UIColor colorWithRed:0.1 green:0.12 blue:0.16 alpha:1];
    [_containerView addSubview:header];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, menuWidth - 80, 50)];
    NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc]
        initWithString:@"ZOMBI MOD"
            attributes:@{
                NSFontAttributeName: [UIFont boldSystemFontOfSize:15],
                NSForegroundColorAttributeName: [UIColor colorWithRed:0.15 green:0.88 blue:0.55 alpha:1],
                NSKernAttributeName: @(2.0)
            }];
    title.attributedText = titleAttr;
    [header addSubview:title];

    // Close button
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(menuWidth - 44, 0, 44, 50);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:closeBtn];

    // Separator
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, 50, menuWidth, 1)];
    sep.backgroundColor = [UIColor colorWithRed:0.15 green:0.88 blue:0.55 alpha:0.2];
    [_containerView addSubview:sep];

    // Scroll content
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 51, menuWidth, menuHeight - 51)];
    _scrollView.showsVerticalScrollIndicator = NO;
    [_containerView addSubview:_scrollView];

    CGFloat yOffset = 12;
    CGFloat rowH = 52;

    struct { NSString *label; SEL action; BOOL *flag; } features[] = {
        { @"Aimbot",    @selector(toggleAimbot:),   &zmAimbotEnabled },
        { @"Visuals",   @selector(toggleVisuals:),  &zmVisualsEnabled },
        { @"No Reload", @selector(toggleNoReload:), &zmNoReloadEnabled },
        { @"Speed Hack",@selector(toggleSpeed:),    &zmSpeedEnabled },
        { @"No Fog",    @selector(toggleNoFog:),    &zmNoFogEnabled },
    };
    int count = sizeof(features) / sizeof(features[0]);

    for (int i = 0; i < count; i++) {
        UIView *row = [self makeRowWithLabel:features[i].label
                                      yPos:yOffset
                                     width:menuWidth
                                    height:rowH
                                    action:features[i].action
                                      flag:features[i].flag];
        [_scrollView addSubview:row];
        yOffset += rowH + 4;
    }

    _scrollView.contentSize = CGSizeMake(menuWidth, yOffset + 12);

    // Drag to move
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_containerView addGestureRecognizer:pan];

    [window addSubview:_containerView];
}

- (UIView *)makeRowWithLabel:(NSString *)label
                       yPos:(CGFloat)y
                      width:(CGFloat)w
                     height:(CGFloat)h
                     action:(SEL)action
                       flag:(BOOL *)flag {
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(12, y, w - 24, h)];
    row.backgroundColor = [UIColor colorWithRed:0.1 green:0.12 blue:0.16 alpha:1];
    row.layer.cornerRadius = 10;
    row.layer.borderWidth = 1;
    row.layer.borderColor = [UIColor colorWithRed:0.15 green:0.88 blue:0.55 alpha:0.1].CGColor;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, w - 100, h)];
    lbl.text = label;
    lbl.textColor = [UIColor colorWithRed:0.85 green:0.9 blue:0.95 alpha:1];
    lbl.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [row addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] init];
    sw.center = CGPointMake(w - 24 - 26, h / 2);
    sw.onTintColor = [UIColor colorWithRed:0.15 green:0.88 blue:0.55 alpha:1];
    sw.on = *flag;
    [sw addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [row addSubview:sw];

    return row;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    UIView *view = pan.view;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGPoint delta = [pan translationInView:window];
    CGPoint newCenter = CGPointMake(view.center.x + delta.x, view.center.y + delta.y);
    newCenter.x = MAX(view.bounds.size.width / 2, MIN(window.bounds.size.width - view.bounds.size.width / 2, newCenter.x));
    newCenter.y = MAX(view.bounds.size.height / 2, MIN(window.bounds.size.height - view.bounds.size.height / 2, newCenter.y));
    view.center = newCenter;
    [pan setTranslation:CGPointZero inView:window];
}

// Feature toggles
- (void)toggleAimbot:(UISwitch *)sw { zmAimbotEnabled = sw.on; }
- (void)toggleVisuals:(UISwitch *)sw { zmVisualsEnabled = sw.on; }
- (void)toggleNoReload:(UISwitch *)sw { zmNoReloadEnabled = sw.on; }
- (void)toggleSpeed:(UISwitch *)sw { zmSpeedEnabled = sw.on; }
- (void)toggleNoFog:(UISwitch *)sw { zmNoFogEnabled = sw.on; }

@end
