#import "ZMFloatingButton.h"
#import "ZMMenuController.h"

@interface ZMFloatingButton ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIWindow *window;
@end

@implementation ZMFloatingButton

+ (instancetype)sharedButton {
    static ZMFloatingButton *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZMFloatingButton alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.window = [UIApplication sharedApplication].keyWindow;
        if (!self.window) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{ [self setup]; });
            return;
        }
        [self createButton];
    });
}

- (void)createButton {
    CGFloat size = 52;
    CGFloat x = UIScreen.mainScreen.bounds.size.width - size - 16;
    CGFloat y = UIScreen.mainScreen.bounds.size.height * 0.35;

    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(x, y, size, size);
    _button.layer.cornerRadius = size / 2;
    _button.backgroundColor = [UIColor colorWithRed:0.07 green:0.09 blue:0.12 alpha:0.95];
    _button.layer.borderWidth = 2;
    _button.layer.borderColor = [UIColor colorWithRed:0.15 green:0.88 blue:0.55 alpha:0.8].CGColor;
    _button.layer.shadowColor = [UIColor colorWithRed:0.15 green:0.88 blue:0.55 alpha:0.5].CGColor;
    _button.layer.shadowRadius = 8;
    _button.layer.shadowOpacity = 1;
    _button.layer.shadowOffset = CGSizeZero;

    // Label: "Z"
    UILabel *label = [[UILabel alloc] initWithFrame:_button.bounds];
    label.text = @"Z";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:22];
    label.textColor = [UIColor colorWithRed:0.15 green:0.88 blue:0.55 alpha:1];
    [_button addSubview:label];

    [_button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];

    // Drag support
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_button addGestureRecognizer:pan];

    [_window addSubview:_button];

    // Pulse animation
    [self startPulse];
}

- (void)startPulse {
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    pulse.fromValue = @8;
    pulse.toValue = @14;
    pulse.duration = 1.4;
    pulse.autoreverses = YES;
    pulse.repeatCount = HUGE_VALF;
    pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_button.layer addAnimation:pulse forKey:@"pulse"];
}

- (void)buttonTapped {
    [[ZMMenuController sharedController] toggle];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    UIView *view = pan.view;
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    CGPoint delta = [pan translationInView:win];
    CGPoint newCenter = CGPointMake(view.center.x + delta.x, view.center.y + delta.y);
    CGFloat half = view.bounds.size.width / 2;
    newCenter.x = MAX(half + 8, MIN(win.bounds.size.width - half - 8, newCenter.x));
    newCenter.y = MAX(half + 40, MIN(win.bounds.size.height - half - 40, newCenter.y));
    view.center = newCenter;
    [pan setTranslation:CGPointZero inView:win];
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.button.hidden = NO;
    });
}

- (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.button.hidden = YES;
    });
}

@end
