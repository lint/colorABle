
#import "UIColor+CSColorPicker.h"


@interface CABHeaderView : UIView
@property(strong, nonatomic) UIImageView *arrowImageView;
@property(strong, nonatomic) UILabel *authorLabel;
@property(strong, nonatomic) UILabel *flairLabel;
@property(strong, nonatomic) UILabel *rightInfoLabel;
@property(strong, nonatomic) UIImageView *circleImage;
@end

@implementation CABHeaderView

@synthesize arrowImageView, authorLabel, flairLabel, rightInfoLabel, circleImage;

-(id) initWithFrame:(CGRect) frame{
	self = [super initWithFrame:frame];
	
	if (self){
		
		[self setUserInteractionEnabled:NO];
		
		arrowImageView = [[UIImageView alloc] initWithImage:nil];
		authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
		flairLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
		rightInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
		//circleImage = [[UIImageView alloc] initWithImage:nil];
		
		[arrowImageView setUserInteractionEnabled:NO];
		[authorLabel setUserInteractionEnabled:NO];
		[flairLabel setUserInteractionEnabled:NO];
		[rightInfoLabel setUserInteractionEnabled:NO];
		//[circleImage setUserInteractionEnabled:NO];
		
		[self addSubview:arrowImageView];
		[self addSubview:authorLabel];
		[self addSubview:flairLabel];
		[self addSubview:rightInfoLabel];
		//[self addSubview:circleImage];
	}
	
	return self;
}

@end

@interface ABToolbar : UIToolbar
@end

@interface TransparentToolbar: ABToolbar
@end

@interface ABBundleManager
+(id) sharedManager;
-(id) createFontForKey:(id) arg1;
@end

@interface VoteableElement
@property(strong, nonatomic) NSString *author;
@property(strong, nonatomic) NSString *formattedScore;
@property(strong, nonatomic) NSString *formattedScoreTiny;
@property(strong, nonatomic) NSString *formattedScoreTinyWithPlus;
@property(strong, nonatomic) NSString *formattedScoreWithText;
@property(strong, nonatomic) NSString *tinyTimeAgo;
@property(assign, nonatomic) BOOL isFromAdmin;
@property(assign, nonatomic) BOOL isFromModerator;
@property(assign, nonatomic) BOOL isMine;
@property(assign, nonatomic) int voteState;
@end

@interface Comment : VoteableElement
@property(strong, nonatomic) NSString *flairText;
@end

@interface Post : VoteableElement
@end

@interface CommentNode
@property(strong, nonatomic) Comment *comment;
@property(strong, nonatomic) Post *post;
@property(assign, nonatomic) BOOL isContext;

//custom elements
@property(assign, nonatomic) CGFloat leftPad;
@property(assign, nonatomic) BOOL hasLeftPad;
@end

@interface NCommentCell : UIView
@property(strong, nonatomic) id headerBar;
@property(strong, nonatomic) id threadLinesOverlay;
@property(strong, nonatomic) id dottedLineSeparatorOverlay;
@property(strong, nonatomic) id drawerView;
@property(strong, nonatomic) Comment *comment;
@property(assign, nonatomic) BOOL selected;

//custom elements
@property(strong, nonatomic) CABHeaderView *cabHeaderView;
-(void) createCABHeaderView;
@end

@interface JMViewOverlay
@property(assign, nonatomic) CGFloat left;
@property(assign, nonatomic) CGRect frame;
@end

@interface CommentHeaderBarOverlay : JMViewOverlay
@property(strong, nonatomic) CommentNode *commentNode;
@property(assign, nonatomic) BOOL collapsed;
@property(assign, nonatomic) CGRect frame;
@property(assign, nonatomic) CGRect initialFrame;
@property(assign, nonatomic) CGRect initialParentBounds;
@property(assign, nonatomic) CGFloat horizontalPadding;

//custom elements
@property(strong, nonatomic) NCommentCell *nCommentCell;
@end

@interface ThreadLinesOverlay : JMViewOverlay
@property(assign, nonatomic) NSUInteger level;
@end

@interface UIImage (AverageColor)
-(UIColor *) averageColor;
@end

//from http://www.bobbygeorgescu.com/2011/08/finding-average-color-of-uiimage/
@implementation UIImage (AverageColor) 
-(UIColor *) averageColor{
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);  
	
	return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0 green:((CGFloat)rgba[1])/255.0 blue:((CGFloat)rgba[2])/255.0 alpha:((CGFloat)rgba[3])/255.0];
}
@end


static BOOL isEnabled;
static UIColor *upvoteColor;
static UIColor *downvoteColor;
static UIColor *opHighlightColor;
static UIColor *tintColor;
static UIColor *inboxColor;

static BOOL colorsAreEqual(UIColor* color1, UIColor *color2){
	
	const CGFloat *color1Parts = CGColorGetComponents([color1 CGColor]);
	CGFloat r1 = color1Parts[0];
	CGFloat g1 = color1Parts[1];
	CGFloat b1 = color1Parts[2];
	
	const CGFloat *color2Parts = CGColorGetComponents([color2 CGColor]);
	CGFloat r2 = color2Parts[0];
	CGFloat g2 = color2Parts[1];
	CGFloat b2 = color2Parts[2];
	
	if (fabs(r1 - r2) <= .001 && fabs(g1 - g2) <= .001 && fabs(b1 - b2) <= .001){
		return YES;
	} else {
		return NO;
	}
}


%hook UIColor

+(id) colorForUpvote{
	return upvoteColor;
}

+(id) colorForDownvote{
	return downvoteColor;
}

+(id) colorForOpHighlight{
	return opHighlightColor;
}

+(id) colorForTint{
	return tintColor;
}

+(id) colorForHighlightedOptions{
	return tintColor;
}

+(id) colorForInboxAlert{
	return inboxColor;
}

//username highlight color when getting context
+(id) colorWithCGColor:(CGColorRef) arg1{
	
	id orig = %orig;
	
	UIColor *compColor = [UIColor colorWithRed:183.0/255 green:106.0/255 blue:255.0/255 alpha:1.0];
	
	if (colorsAreEqual(orig, compColor)){
		orig = opHighlightColor;
	}
	
	return orig;
}


%end


//New mail alert
%hook ABToolbar

-(void) handleTintSwitch{
	%orig;
	
	NSArray *items = [self items];
	
	for (UIBarButtonItem *item in items){
		UIView *view = [item customView];
		
		if ([view isKindOfClass:[UIButton class]]){
			UIButton *button = (UIButton *)view;
			
			UIImage *image = button.currentImage;
			UIColor *avgColor = [image averageColor];
			
			if (colorsAreEqual(avgColor, [UIColor colorWithRed:0.109804 green:0.0470588 blue:0.0392157 alpha:0.117647])){	
				
				UIImage *newImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/colorABlePrefs.bundle/newmail.png"];
				newImage = [UIImage imageWithCGImage:[newImage CGImage] scale:2.0 orientation:UIImageOrientationUp];
				newImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
				
				[button setImage:newImage forState:UIControlStateNormal];
				[button setTintColor:inboxColor];
				
				break;
			}
		}
	}
}

%end


//Upvote arrow color in top nav bar
%hook TransparentToolbar

-(void) layoutSubviews{
	%orig;
	
	NSArray *items = [self items];
	
	for (UIBarButtonItem *item in items){
		UIView *view = [item customView];
		
		if ([view isKindOfClass:[UIButton class]]){
			
			UIButton *button = (UIButton *)view;
			UIImage *btnImage = [button currentImage];
			UIColor *avgColor = [btnImage averageColor];
			
			if (colorsAreEqual(avgColor, [UIColor colorWithRed:0.0352941 green:0.0196078 blue:0.00784314 alpha:0.0])){
				[button setImage:[button.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal] ;
				[button setTintColor:upvoteColor];
			}
		}
	}
}

%end


//Header 4 and show table colors
%hook Comment

-(id) styledBody{
	
	id orig = %orig;
	
	if (orig != nil){
	
		NSMutableAttributedString *styledText;	
		CGFloat compR1, compG1, compB1, compR2, compG2, compB2;
		
		compR1 = 0.678431;
		compG1 = 0.286275;
		compB1 = 0.882353;
		
		compR2 = 0.854902;
		compG2 = 0.290196;
		compB2 = 0.729412;
		
		if (![orig isKindOfClass:[NSMutableAttributedString class]] && [orig isKindOfClass:[NSAttributedString class]]){
			styledText = [orig mutableCopy];
		} else {
			styledText = (NSMutableAttributedString *) orig;
		}

		[styledText enumerateAttribute:@"CTForegroundColor" inRange:NSMakeRange(0, [styledText length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop){
			
			CGColor *color = (__bridge CGColor *) value;
			
			if (color != nil){

				const CGFloat *components = CGColorGetComponents(color);
				CGFloat origRed = components[0];
				CGFloat origGreen = components[1];
				CGFloat origBlue = components[2];
				
				if (fabs(origRed - compR1) <= .001 && fabs(origGreen - compG1) <= .001 && fabs(origBlue - compB1) <= .001){ //color of header 4
					[styledText addAttribute:@"CTForegroundColor" value:tintColor range:range];
				} else if (fabs(origRed - compR2) <= .001 && fabs(origGreen - compG2) <= .001 && fabs(origBlue - compB2) <= .001){ //color of show table
					[styledText addAttribute:@"CTForegroundColor" value:tintColor range:range];
				} 
			}
		}];
		
		return styledText;
	}
	else{
		
		return orig;
	}
}

%end


%hook CommentNode 
%property(assign, nonatomic) CGFloat leftPad;
%property(assign, nonatomic) BOOL hasLeftPad;

-(id) initWithComment:(id) arg1 level:(NSUInteger) arg2{
	id orig = %orig;
	
	[orig setHasLeftPad:NO];
	[orig setLeftPad:-1];
	
	return orig;
}

%end


%hook CommentHeaderBarOverlay
%property(strong, nonatomic) NCommentCell *nCommentCell;

-(void) drawRect:(CGRect) arg1{
	//%orig;
	[[self nCommentCell] createCABHeaderView];
}

%end


%hook NCommentCell
%property(strong, nonatomic) CABHeaderView *cabHeaderView;

-(void) layoutCellOverlays{
	%orig;
	
	[[self headerBar] setNCommentCell:self];
}

//Recreating the comment header overlay from scratch
%new
-(void) createCABHeaderView{
	
	CommentHeaderBarOverlay *headerOverlay = [self headerBar];
	JMViewOverlay *dottedSepOverlay = [self dottedLineSeparatorOverlay];
	
	CommentNode *commentNode = [headerOverlay commentNode];
	Comment *comment = [self comment];
	
	BOOL hasDrawer = NO;
	BOOL isCollapsed = NO;
	
	if ([self drawerView]){
		hasDrawer = YES;
	}
	
	if ([headerOverlay collapsed]){
		isCollapsed = YES;
	}
	
	CABHeaderView *cabHeaderView  = [self cabHeaderView]; 
	
	if (!cabHeaderView){
		cabHeaderView = [[%c(CABHeaderView) alloc] initWithFrame:CGRectMake(0,0,0,0)];
		[self setCabHeaderView:cabHeaderView];
		[self addSubview:cabHeaderView];
	}
	
	CGFloat cabXOrigin;
	
	

	if ([commentNode hasLeftPad]){
		cabXOrigin = [commentNode leftPad];
	} else {
		if (hasDrawer){
			cabXOrigin = 22 * [[self threadLinesOverlay] level] + 12;
		} else {
			CGFloat newLeftPad = [dottedSepOverlay left];
			cabXOrigin = newLeftPad;
			[commentNode setLeftPad:newLeftPad];
			[commentNode setHasLeftPad:YES];
		}
	}
		
	CGRect overlayFrame = [headerOverlay frame];
	CGRect cabFrame = CGRectMake(cabXOrigin, overlayFrame.origin.y, self.frame.size.width - cabXOrigin - 15, overlayFrame.size.height);
	cabHeaderView.frame = cabFrame;

	UIColor *textColor = tintColor; 
	UIColor *rightTextColor = [UIColor colorWithRed:128.0/255 green:128.0/255 blue:128.0/255 alpha:1.0];
	UIColor *collapsedColor = [UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0];
	UIColor *flairTextColor = [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0];
	UIColor *flairBackgroundColor = [UIColor colorWithRed:233.0/255 green:234.0/255 blue:235.0/255 alpha:1.0];
	
	ABBundleManager *bundleManager = [%c(ABBundleManager) sharedManager];
	UIFont *headerFont = [bundleManager createFontForKey:@"kBundleFontCommentSubdetails"];

	//arrow indicator part
	UIImageView *arrowImageView = [cabHeaderView arrowImageView];
	UIImage *arrowImage;
	
	if (isCollapsed){
		arrowImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/colorABlePrefs.bundle/arrow_right.png"];
		arrowImage = [[UIImage imageWithCGImage:[arrowImage CGImage] scale:(arrowImage.scale * 4.0) orientation:(arrowImage.imageOrientation)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];		
		arrowImageView.tintColor = collapsedColor;
	} else {
		arrowImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/colorABlePrefs.bundle/arrow_down.png"];
		arrowImage = [[UIImage imageWithCGImage:[arrowImage CGImage] scale:(arrowImage.scale * 4.0) orientation:(arrowImage.imageOrientation)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];		
		arrowImageView.tintColor = tintColor;
	}
	
	CGSize arrowImageSize = arrowImage.size;

	arrowImageView.image = arrowImage;
	arrowImageView.frame = CGRectMake(0, (cabFrame.size.height - arrowImageSize.height) / 2, arrowImageSize.width , arrowImageSize.height);
	
	//author and distinguished part
	NSMutableAttributedString *authorText = [[NSMutableAttributedString alloc] initWithString:[[comment author] stringByAppendingString:@" "]];
	NSString *distText;
	
	if ([[comment author] isEqualToString:[[commentNode post] author]]){
		textColor = opHighlightColor;
		arrowImageView.tintColor = opHighlightColor;
		distText = @" op";
	} else if ([comment isFromAdmin]){
		textColor = opHighlightColor;
		arrowImageView.tintColor = opHighlightColor;
		distText = @" a";
	} else if ([comment isFromModerator]){
		textColor = opHighlightColor;
		arrowImageView.tintColor = opHighlightColor;
		distText = @" m";
	} else if ([commentNode isContext]){
		textColor = opHighlightColor;
		arrowImageView.tintColor = opHighlightColor;
	} 
	if ([comment isMine]){
		textColor = opHighlightColor;
		arrowImageView.tintColor = opHighlightColor;
		distText = nil;
	}
	
	if (distText){
		
		UIImage *dottedLineImage = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/colorABlePrefs.bundle/dotted_line_2.png"];
		dottedLineImage = [[UIImage imageWithCGImage:[dottedLineImage CGImage] scale:(dottedLineImage.scale * 4) orientation:(dottedLineImage.imageOrientation)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		
		NSTextAttachment *dottedLineAttachment = [NSTextAttachment alloc];
		dottedLineAttachment.image = dottedLineImage;
		
		CGFloat mid = headerFont.descender + headerFont.capHeight;
		dottedLineAttachment.bounds = CGRectIntegral(CGRectMake(0, headerFont.descender - dottedLineImage.size.height / 2 + mid + 2, dottedLineImage.size.width, dottedLineImage.size.height));
		
		NSAttributedString *dottedLineString = [NSAttributedString attributedStringWithAttachment:dottedLineAttachment];
		[authorText appendAttributedString:dottedLineString];
		
		NSAttributedString *distAttributedString = [[NSAttributedString alloc] initWithString:distText];
		[authorText appendAttributedString:distAttributedString];
		
	} else if (isCollapsed){
		textColor = collapsedColor;
	}
	
	[authorText addAttribute:NSFontAttributeName value:headerFont range:NSMakeRange(0, authorText.length)];
	
	UILabel *authorLabel = [cabHeaderView authorLabel];
	authorLabel.textColor = textColor;
	authorLabel.attributedText = authorText;
	
	CGRect authorTextRect = [authorText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, cabFrame.size.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
	authorLabel.frame = CGRectIntegral(CGRectMake(arrowImageView.frame.size.width + 10, 0, authorTextRect.size.width, cabFrame.size.height));
	
	//right info (vote status and time ago) part
	UILabel *rightInfoLabel = [cabHeaderView rightInfoLabel];
	
	NSMutableAttributedString *rightText = [[NSMutableAttributedString alloc] initWithString:[comment formattedScoreTinyWithPlus]];
	
	if (hasDrawer){
		NSAttributedString *timeAgoText = [[NSAttributedString alloc] initWithString:[@" ∙ " stringByAppendingString:[comment tinyTimeAgo]]];
		[rightText appendAttributedString:timeAgoText];
	}
	
	if ([comment voteState] == 1){
		rightTextColor = upvoteColor;
	} else if ([comment voteState] == -1){
		rightTextColor = downvoteColor;
	}
	
	if (isCollapsed){
		rightTextColor = collapsedColor;
	}
	
	[rightText addAttribute:NSFontAttributeName value:headerFont range:NSMakeRange(0, rightText.length)];
	
	rightInfoLabel.textColor = rightTextColor;
	rightInfoLabel.attributedText = rightText;
	
	CGRect rightTextRect = [rightText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, cabFrame.size.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
	rightInfoLabel.frame = CGRectIntegral(CGRectMake(cabFrame.size.width - rightTextRect.size.width, 0, rightTextRect.size.width, cabFrame.size.height));
	
	//flair part
	NSString *flairText = [comment flairText];
	UILabel *flairLabel = [cabHeaderView flairLabel];
	
	if (![flairText isEqualToString:@""]){
		
		NSMutableAttributedString *flairAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@  ", flairText]];
		
		[flairAttributedString addAttribute:NSFontAttributeName value:headerFont range:NSMakeRange(0, flairAttributedString.length)];
		
		flairLabel.textColor = flairTextColor;
		flairLabel.backgroundColor = flairBackgroundColor;
		
		flairLabel.attributedText = flairAttributedString;
		
		CGRect flairTextRect = [flairAttributedString boundingRectWithSize:CGSizeMake(rightInfoLabel.frame.origin.x - (authorLabel.frame.origin.x + authorLabel.frame.size.width) - 35, cabFrame.size.height - 10) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
		flairLabel.frame = CGRectIntegral(CGRectMake(authorLabel.frame.origin.x + authorLabel.frame.size.width + 10, (cabFrame.size.height - (cabFrame.size.height - 10)) / 2, flairTextRect.size.width, cabFrame.size.height - 10));
		
		flairLabel.layer.cornerRadius = 5;
		flairLabel.layer.masksToBounds = YES;
	} else {
		flairLabel.frame = CGRectMake(0,0,0,0);
		flairLabel.attributedText = nil;
	}
}

%end


static void loadPrefs(){
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/com.lint.colorable.prefs.plist"];
	
	if (prefs){
		
		if ([prefs objectForKey:@"isEnabled"] != nil){
			isEnabled = [[prefs objectForKey:@"isEnabled"] boolValue];
		} else {
			isEnabled = YES;
		}
		
		if ([prefs objectForKey:@"upvoteColor"]){
			upvoteColor = [UIColor cscp_colorFromHexString:[prefs objectForKey:@"upvoteColor"]];
		} else {
			upvoteColor = [UIColor cscp_colorFromHexString:@"FF4500"];
		}
		
		if ([prefs objectForKey:@"downvoteColor"]){
			downvoteColor = [UIColor cscp_colorFromHexString:[prefs objectForKey:@"downvoteColor"]];
		} else {
			downvoteColor = [UIColor cscp_colorFromHexString:@"659BFD"];
		}
		
		if ([prefs objectForKey:@"opHighlightColor"]){
			opHighlightColor = [UIColor cscp_colorFromHexString:[prefs objectForKey:@"opHighlightColor"]];
		} else {
			opHighlightColor = [UIColor cscp_colorFromHexString:@"D40CBF"];
		}
		
		if ([prefs objectForKey:@"tintColor"]){
			tintColor = [UIColor cscp_colorFromHexString:[prefs objectForKey:@"tintColor"]];
		} else {
			tintColor = [UIColor cscp_colorFromHexString:@"0D7EAC"];
		}
		
		if ([prefs objectForKey:@"newInboxColor"]){
			inboxColor = [UIColor cscp_colorFromHexString:[prefs objectForKey:@"newInboxColor"]];
		} else {
			inboxColor = [UIColor cscp_colorFromHexString:@"7D26CD"];
		}
		
	} else {
		isEnabled = NO;
	}	
}


static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  loadPrefs();
}


%ctor {
	HBLogDebug(@"start");
	
	loadPrefs();
	
	if (isEnabled){
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, prefsChanged, CFSTR("com.lint.colorable.prefs.changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		%init;
	}
}
