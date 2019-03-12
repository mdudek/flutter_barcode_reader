//
// Created by Matthew Smith on 11/7/17.
//

#import "BarcodeScannerViewController.h"
#import <MTBBarcodeScanner/MTBBarcodeScanner.h>
#import "ScannerOverlay.h"


@implementation BarcodeScannerViewController

- (id)initWithTheme:(NSString *)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationBar *bar = [self.navigationController navigationBar];
   

    UIColor *barBgColor = NULL; // Navigation bar background color
    UIColor *primaryColor = NULL; // Navigation bar text/foreground color + scan rect corners
    
    if ([@"kalium" isEqualToString:self.theme]) {
        barBgColor = [UIColor colorWithRed:0.13 green:0.13 blue:0.14 alpha:1.0];
        primaryColor = [UIColor colorWithRed:0.98 green:0.87 blue:0.07 alpha:1.0];
    } else if ([@"natrium" isEqualToString:self.theme]) {
        barBgColor = [UIColor colorWithRed:0.16 green:0.23 blue:0.30 alpha:1.0];
        primaryColor = [UIColor colorWithRed:0.64 green:0.80 blue:1.00 alpha:1.0];
    } else if ([@"beryllium" isEqualToString:self.theme]) {
        barBgColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.10 alpha:1.0];
        primaryColor = [UIColor colorWithRed:0.74 green:0.63 blue:1.00 alpha:1.0];
    } else if ([@"titanium" isEqualToString:self.theme]) {
        barBgColor = [UIColor colorWithRed:0.02 green:0.13 blue:0.16 alpha:1.0];
        primaryColor = [UIColor colorWithRed:0.38 green:0.78 blue:0.68 alpha:1.0];
    } else if ([@"iridium" isEqualToString:self.theme]) {
        barBgColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
        primaryColor = [UIColor colorWithRed:0.00 green:0.56 blue:0.33 alpha:1.0];
    } else if ([@"ruthium" isEqualToString:self.theme]) {
        barBgColor = [UIColor colorWithRed:1.00 green:0.79 blue:0.82 alpha:1.0];
        primaryColor = [UIColor colorWithRed:0.84 green:0.45 blue:0.49 alpha:1.0];
    } else if ([@"radium" isEqualToString:self.theme]) {
        barBgColor = [UIColor colorWithRed:0.10 green:0.02 blue:0.21 alpha:1.0];
        primaryColor = [UIColor colorWithRed:0.22 green:0.89 blue:0.54 alpha:1.0];
    } else if ([@"indium" isEqualToString:self.theme]) {
        barBgColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
        primaryColor = [UIColor colorWithRed:0.00 green:0.31 blue:0.73 alpha:1.0];
    } else if ([@"neptunium" isEqualToString:self.theme]) {
        barBgColor = [UIColor colorWithRed:0.03 green:0.03 blue:0.25 alpha:1.0];
        primaryColor = [UIColor colorWithRed:0.29 green:0.56 blue:0.89 alpha:1.0];
    } else if ([@"thorium" isEqualToString:self.theme]) {
        barBgColor = [UIColor colorWithRed:0.16 green:0.06 blue:0.32 alpha:1.0];
        primaryColor = [UIColor colorWithRed:0.46 green:0.95 blue:1.00 alpha:1.0];
    } else {
        primaryColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }

    if (barBgColor != NULL && primaryColor != NULL) {
        bar.barTintColor = barBgColor;
        bar.tintColor = primaryColor;
    }
  
    self.previewView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.previewView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_previewView];
    [self.view addConstraints:[NSLayoutConstraint
            constraintsWithVisualFormat:@"V:[previewView]"
                                options:NSLayoutFormatAlignAllBottom
                                metrics:nil
                                  views:@{@"previewView": _previewView}]];
    [self.view addConstraints:[NSLayoutConstraint
            constraintsWithVisualFormat:@"H:[previewView]"
                                options:NSLayoutFormatAlignAllBottom
                                metrics:nil
                                  views:@{@"previewView": _previewView}]];
    self.scanRect = [[ScannerOverlay alloc] initWithFrameAndTheme:self.view.bounds theme:primaryColor];
  self.scanRect.translatesAutoresizingMaskIntoConstraints = NO;
  self.scanRect.backgroundColor = UIColor.clearColor;
  [self.view addSubview:_scanRect];
  [self.view addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"V:[scanRect]"
                             options:NSLayoutFormatAlignAllBottom
                             metrics:nil
                             views:@{@"scanRect": _scanRect}]];
  [self.view addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:[scanRect]"
                             options:NSLayoutFormatAlignAllBottom
                             metrics:nil
                             views:@{@"scanRect": _scanRect}]];
    self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_previewView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
  [self updateFlashButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.scanner.isScanning) {
        [self.scanner stopScanning];
    }
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            [self startScan];
        } else {
          [self.delegate barcodeScannerViewController:self didFailWithErrorCode:@"PERMISSION_NOT_GRANTED"];
          [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.scanner stopScanning];
    [super viewWillDisappear:animated];
    if ([self isFlashOn]) {
        [self toggleFlash:NO];
    }
}

- (void)startScan {
    NSError *error;
    [self.scanner startScanningWithResultBlock:^(NSArray<AVMetadataMachineReadableCodeObject *> *codes) {
        [self.scanner stopScanning];
         AVMetadataMachineReadableCodeObject *code = codes.firstObject;
        if (code) {
            [self.delegate barcodeScannerViewController:self didScanBarcodeWithResult:code.stringValue];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    } error:&error];
}

- (void)cancel {
    [self.delegate barcodeScannerViewController:self didScanBarcodeWithResult:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)updateFlashButton {
    if (!self.hasTorch) {
        return;
    }
    if (self.isFlashOn) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flash Off"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(toggle)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flash On"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(toggle)];
    }
}

- (void)toggle {
    [self toggleFlash:!self.isFlashOn];
    [self updateFlashButton];
}

- (BOOL)isFlashOn {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        return device.torchMode == AVCaptureFlashModeOn || device.torchMode == AVCaptureTorchModeOn;
    }
    return NO;
}

- (BOOL)hasTorch {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        return device.hasTorch;
    }
    return false;
}

- (void)toggleFlash:(BOOL)on {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) return;

    NSError *err;
    if (device.hasFlash && device.hasTorch) {
        [device lockForConfiguration:&err];
        if (err != nil) return;
        if (on) {
            device.flashMode = AVCaptureFlashModeOn;
            device.torchMode = AVCaptureTorchModeOn;
        } else {
            device.flashMode = AVCaptureFlashModeOff;
            device.torchMode = AVCaptureTorchModeOff;
        }
        [device unlockForConfiguration];
    }
}


@end
