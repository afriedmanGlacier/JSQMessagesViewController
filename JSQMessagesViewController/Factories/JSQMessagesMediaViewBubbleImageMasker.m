//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "JSQMessagesBubbleImageFactory.h"


@implementation JSQMessagesMediaViewBubbleImageMasker

#pragma mark - Initialization

- (instancetype)init
{
    return [self initWithBubbleImageFactory:[[JSQMessagesBubbleImageFactory alloc] init]];
}

- (instancetype)initWithBubbleImageFactory:(JSQMessagesBubbleImageFactory *)bubbleImageFactory
{
    NSParameterAssert(bubbleImageFactory != nil);
    
    self = [super init];
    if (self) {
        _bubbleImageFactory = bubbleImageFactory;
    }
    return self;
}

#pragma mark - View masking

- (void)applyOutgoingBubbleImageMaskToMediaView:(UIView *)mediaView
{
    JSQMessagesBubbleImage *bubbleImageData = [self.bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    [self jsq_maskView:mediaView withImage:[bubbleImageData messageBubbleImage]];
}

- (void)applyIncomingBubbleImageMaskToMediaView:(UIView *)mediaView
{
    // changed to outgoing with affinetransform after due to changes in
    // XCode 12 and iOS 14
    JSQMessagesBubbleImage *bubbleImageData = [self.bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    
    [self jsq_maskView:mediaView withImage:[bubbleImageData messageBubbleImage]];
    mediaView.layer.mask.affineTransform = CGAffineTransformMakeScale(-1, 1);
}

+ (void)applyBubbleImageMaskToMediaView:(UIView *)mediaView isOutgoing:(BOOL)isOutgoing
{
    JSQMessagesMediaViewBubbleImageMasker *masker = [[JSQMessagesMediaViewBubbleImageMasker alloc] init];
    
    if (isOutgoing) {
        [masker applyOutgoingBubbleImageMaskToMediaView:mediaView];
    }
    else {
        [masker applyIncomingBubbleImageMaskToMediaView:mediaView];
    }
}

#pragma mark - Private

- (void)jsq_maskView:(UIView *)view withImage:(UIImage *)image
{
    NSParameterAssert(view != nil);
    NSParameterAssert(image != nil);
    
    //UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    //imageViewMask.frame = CGRectInset(view.frame, 2.0f, 2.0f);
    
    //view.layer.mask = imageViewMask.layer;
    
    // images were not showing up due to changes in XCode 12 and iOS 14
    CGPoint center = CGPointMake(image.size.width / 2.0f, image.size.height / 2.0f);
    UIEdgeInsets insets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = CGRectInset(view.frame, 2.0f, 2.0f);
    maskLayer.contents = (__bridge id)image.CGImage;
    maskLayer.contentsScale = image.scale;
    maskLayer.contentsCenter = CGRectMake(insets.left/image.size.width, insets.top/image.size.height, 1.0/image.size.width, 1.0/image.size.height);
    
    view.layer.mask = maskLayer;
}

@end
